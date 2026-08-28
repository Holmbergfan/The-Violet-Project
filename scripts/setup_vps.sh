#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
	echo "Please run as root (or with sudo)."
	exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GAMESERVER_DIR="${ROOT_DIR}/gameserver"
AAC_CONFIG="${ROOT_DIR}/znote/htdocs/config.php"
GAME_CONFIG="${GAMESERVER_DIR}/config.lua"
BUILD_DIR="${GAMESERVER_DIR}/build"

DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-3306}"
DB_NAME="${DB_NAME:-tibia}"
DB_USER="${DB_USER:-tibia}"
DB_PASS="${DB_PASS:-}"
SERVER_IP="${SERVER_IP:-}"
SERVER_NAME="${SERVER_NAME:-Violet}"
SERVICE_USER="${SERVICE_USER:-${SUDO_USER:-violet}}"
SERVICE_GROUP="${SERVICE_GROUP:-${SERVICE_USER}}"
SKIP_BUILD="${SKIP_BUILD:-0}"
SKIP_APT="${SKIP_APT:-0}"

if [[ -z "${DB_PASS}" ]]; then
	if command -v openssl >/dev/null 2>&1; then
		DB_PASS="$(openssl rand -base64 24 | tr -d '\n' | tr -d '\r' | tr '/+' 'ab')"
	else
		DB_PASS="$(date +%s%N | sha256sum | cut -c1-32)"
	fi
	echo "Generated DB_PASS automatically. Save this password: ${DB_PASS}"
fi

detect_ip() {
	if [[ -n "${SERVER_IP}" ]]; then
		return 0
	fi

	if command -v curl >/dev/null 2>&1; then
		SERVER_IP="$(curl -fsS --max-time 5 https://api.ipify.org || true)"
	fi

	if [[ -z "${SERVER_IP}" ]]; then
		SERVER_IP="$(hostname -I 2>/dev/null | awk '{print $1}')"
	fi

	if [[ -z "${SERVER_IP}" ]]; then
		echo "Could not detect SERVER_IP automatically. Set SERVER_IP and re-run."
		exit 1
	fi
}

install_packages() {
	if [[ "${SKIP_APT}" == "1" ]]; then
		echo "Skipping apt package installation (SKIP_APT=1)."
		return
	fi

	export DEBIAN_FRONTEND=noninteractive
	apt-get update
	apt-get install -y \
		build-essential cmake git pkg-config \
		libboost-date-time-dev libboost-system-dev libboost-filesystem-dev libboost-iostreams-dev \
		libcrypto++-dev libfmt-dev libmariadb-dev libpugixml-dev libluajit-5.1-dev liblua5.1-0-dev \
		mariadb-server \
		php-cli php-mysql php-curl php-xml php-mbstring
}

bootstrap_database() {
	mariadb -e "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;"
	mariadb -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
	mariadb -e "GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost'; FLUSH PRIVILEGES;"

	if ! mariadb "${DB_NAME}" -e "SHOW TABLES LIKE 'accounts';" | grep -q accounts; then
		mariadb "${DB_NAME}" < "${GAMESERVER_DIR}/schema.sql"
	fi
}

write_game_config() {
	if [[ ! -f "${GAME_CONFIG}" ]]; then
		cp "${GAMESERVER_DIR}/config.lua.dist" "${GAME_CONFIG}"
	fi

	python3 - "${GAME_CONFIG}" "${SERVER_IP}" "${DB_HOST}" "${DB_USER}" "${DB_PASS}" "${DB_NAME}" "${DB_PORT}" "${SERVER_NAME}" <<'PY'
import re
import sys
from pathlib import Path
from pathlib import Path

path = Path(sys.argv[1])
ip, db_host, db_user, db_pass, db_name, db_port, server_name = sys.argv[2:]
text = path.read_text()

def repl(key, value):
    global text
    text = re.sub(rf'^{re.escape(key)}\s*=.*$', f'{key} = "{value}"', text, flags=re.MULTILINE)

repl("ip", ip)
repl("mysqlHost", db_host)
repl("mysqlUser", db_user)
repl("mysqlPass", db_pass)
repl("mysqlDatabase", db_name)
text = re.sub(r'^mysqlPort\s*=.*$', f'mysqlPort = {db_port}', text, flags=re.MULTILINE)
repl("serverName", server_name)

path.write_text(text)
PY
}

write_aac_config() {
	python3 - "${AAC_CONFIG}" "${DB_HOST}" "${DB_USER}" "${DB_PASS}" "${DB_NAME}" "${SERVER_IP}" "${SERVER_NAME}" "${GAMESERVER_DIR}" <<'PY'
import re
import sys

path = Path(sys.argv[1])
db_host, db_user, db_pass, db_name, server_ip, server_name, gameserver_dir = sys.argv[2:]
text = path.read_text()

def set_php_scalar(name, value):
    global text
    pattern = rf"(\$config\['{re.escape(name)}'\]\s*=\s*)'[^']*';"
    text = re.sub(pattern, rf"\1'{value}';", text)

set_php_scalar("sqlUser", db_user)
set_php_scalar("sqlPassword", db_pass)
set_php_scalar("sqlDatabase", db_name)
set_php_scalar("sqlHost", db_host)
set_php_scalar("site_url", f"http://{server_ip}")
set_php_scalar("server_path", gameserver_dir)

text = re.sub(r"(\$config\['client'\]\s*=\s*)\d+;", rf"\g<1>772;", text)
text = re.sub(r"(\$config\['port'\]\s*=\s*)\d+;", rf"\g<1>7171;", text)
text = re.sub(r"(\$config\['login_web_service'\]\s*=\s*)(true|false);", rf"\g<1>false;", text)
text = re.sub(
    r"(\$config\['gameserver'\]\s*=\s*array\(\s*[\r\n]+\s*'ip'\s*=>\s*)'[^']*',",
    rf"\1'{server_ip}',",
    text,
    count=1,
    flags=re.MULTILINE,
)
text = re.sub(
    r"(\$config\['gameserver'\]\s*=\s*array\(.*?[\r\n]+\s*'name'\s*=>\s*)'[^']*'",
    rf"\1'{server_name}'",
    text,
    count=1,
    flags=re.MULTILINE | re.DOTALL,
)

path.write_text(text)
PY
}

build_gameserver() {
	if [[ "${SKIP_BUILD}" == "1" ]]; then
		echo "Skipping gameserver build (SKIP_BUILD=1)."
		return
	fi

	cmake -S "${GAMESERVER_DIR}" -B "${BUILD_DIR}" -DCMAKE_BUILD_TYPE=Release
	cmake --build "${BUILD_DIR}" -j"$(nproc)"
}

create_systemd_service() {
	if ! id -u "${SERVICE_USER}" >/dev/null 2>&1; then
		useradd --system --create-home --shell /usr/sbin/nologin "${SERVICE_USER}"
	fi
	if ! getent group "${SERVICE_GROUP}" >/dev/null 2>&1; then
		groupadd --system "${SERVICE_GROUP}"
		usermod -a -G "${SERVICE_GROUP}" "${SERVICE_USER}" || true
	fi

	chown -R "${SERVICE_USER}:${SERVICE_GROUP}" "${GAMESERVER_DIR}"

	cat >/etc/systemd/system/violet-gameserver.service <<EOF
[Unit]
Description=The Violet Project Game Server
After=network.target mariadb.service

[Service]
Type=simple
User=${SERVICE_USER}
Group=${SERVICE_GROUP}
WorkingDirectory=${GAMESERVER_DIR}
ExecStart=${BUILD_DIR}/tfs
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

	systemctl daemon-reload
	systemctl enable violet-gameserver.service
}

detect_ip
install_packages
bootstrap_database
write_game_config
write_aac_config
build_gameserver
create_systemd_service

echo "VPS setup completed."
echo "Review ${GAME_CONFIG} and ${AAC_CONFIG}, then start with: systemctl start violet-gameserver"
