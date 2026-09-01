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

DB_HOST="${DB_HOST:-localhost}"
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

if [[ ! "${DB_USER}" =~ ^[A-Za-z0-9_]+$ ]]; then
	echo "DB_USER may only contain letters, numbers, and underscores."
	exit 1
fi

if [[ ! "${DB_NAME}" =~ ^[A-Za-z0-9_]+$ ]]; then
	echo "DB_NAME may only contain letters, numbers, and underscores."
	exit 1
fi

if [[ ! "${DB_HOST}" =~ ^[A-Za-z0-9._-]+$ ]]; then
	echo "DB_HOST contains unsupported characters."
	exit 1
fi

read_existing_credentials() {
	local creds_file="/root/.violet-db-credentials"
	if [[ -z "${DB_PASS}" && -f "${creds_file}" ]]; then
		DB_PASS="$(grep '^DB_PASS=' "${creds_file}" | tail -n 1 | cut -d= -f2-)"
	fi
}

generate_credentials_if_missing() {
	if [[ -n "${DB_PASS}" ]]; then
		return
	fi

	if command -v openssl >/dev/null 2>&1; then
		DB_PASS="$(openssl rand -hex 24)"
	else
		DB_PASS="$(python3 - <<'PY'
import secrets
print(secrets.token_hex(24))
PY
)"
	fi
	local creds_file="/root/.violet-db-credentials"
	(
		umask 077
		{
			echo "DB_NAME=${DB_NAME}"
			echo "DB_USER=${DB_USER}"
			echo "DB_PASS=${DB_PASS}"
		} > "${creds_file}"
	)
	echo "Generated DB_PASS automatically and saved it to ${creds_file}."
}

if [[ -z "${DB_PASS}" ]]; then
	read_existing_credentials
	generate_credentials_if_missing
fi

if [[ ! "${DB_PASS}" =~ ^[A-Za-z0-9._-]+$ ]]; then
	echo "DB_PASS contains unsupported characters. Use only letters, numbers, dot, underscore, or dash."
	exit 1
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
		php-cli php-mysql php-curl php-xml php-mbstring php-fpm \
		nginx
}

bootstrap_database() {
	local db_pass_sql="${DB_PASS//\\/\\\\}"
	db_pass_sql="${db_pass_sql//\'/\'\'}"
	mariadb -e "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;"
	mariadb -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${db_pass_sql}';"
	mariadb -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'127.0.0.1' IDENTIFIED BY '${db_pass_sql}';"
	mariadb -e "ALTER USER '${DB_USER}'@'localhost' IDENTIFIED BY '${db_pass_sql}';"
	mariadb -e "ALTER USER '${DB_USER}'@'127.0.0.1' IDENTIFIED BY '${db_pass_sql}';"
	mariadb -e "GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost'; FLUSH PRIVILEGES;"
	mariadb -e "GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'127.0.0.1'; FLUSH PRIVILEGES;"
	if [[ "${DB_HOST}" != "localhost" && "${DB_HOST}" != "127.0.0.1" ]]; then
		mariadb -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'${DB_HOST}' IDENTIFIED BY '${db_pass_sql}';"
		mariadb -e "ALTER USER '${DB_USER}'@'${DB_HOST}' IDENTIFIED BY '${db_pass_sql}';"
		mariadb -e "GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'${DB_HOST}'; FLUSH PRIVILEGES;"
	fi

	if ! mariadb "${DB_NAME}" -e "SHOW TABLES LIKE 'accounts';" | grep -q accounts; then
		mariadb "${DB_NAME}" < "${GAMESERVER_DIR}/schema.sql"
	fi

	if ! mariadb "${DB_NAME}" -e "SHOW TABLES LIKE 'znote_accounts';" | grep -q znote_accounts; then
		mariadb "${DB_NAME}" < "${ROOT_DIR}/znote/htdocs/engine/database/znote_schema.sql"
	fi
}

write_game_config() {
	if [[ ! -f "${GAME_CONFIG}" ]]; then
		cp "${GAMESERVER_DIR}/config.lua.dist" "${GAME_CONFIG}"
	fi

	VIOLET_DB_PASS="${DB_PASS}" python3 - "${GAME_CONFIG}" "${SERVER_IP}" "${DB_HOST}" "${DB_USER}" "${DB_NAME}" "${DB_PORT}" "${SERVER_NAME}" <<'PY'
import re
import sys
from pathlib import Path
import os

path = Path(sys.argv[1])
ip, db_host, db_user, db_name, db_port, server_name = sys.argv[2:]
db_pass = os.environ.get("VIOLET_DB_PASS", "")
text = path.read_text()

def repl(key, value):
    global text
    escaped = value.replace("\\", "\\\\").replace('"', '\\"')
    text = re.sub(rf'^{re.escape(key)}\s*=.*$', f'{key} = "{escaped}"', text, flags=re.MULTILINE)

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
	VIOLET_DB_PASS="${DB_PASS}" python3 - "${AAC_CONFIG}" "${DB_HOST}" "${DB_USER}" "${DB_NAME}" "${SERVER_IP}" "${SERVER_NAME}" "${GAMESERVER_DIR}" <<'PY'
import re
import sys
from pathlib import Path
import os

path = Path(sys.argv[1])
db_host, db_user, db_name, server_ip, server_name, gameserver_dir = sys.argv[2:]
db_pass = os.environ.get("VIOLET_DB_PASS", "")
text = path.read_text()

def set_php_scalar(name, value):
    global text
    escaped = value.replace("\\", "\\\\").replace("'", "\\'")
    pattern = rf"(\$config\['{re.escape(name)}'\]\s*=\s*)(?:'[^']*'|\"[^\"]*\");"
    text = re.sub(pattern, rf"\1'{escaped}';", text)

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
NoNewPrivileges=true
PrivateTmp=true
ProtectKernelTunables=true
ProtectControlGroups=true

[Install]
WantedBy=multi-user.target
EOF

	systemctl daemon-reload
	systemctl enable violet-gameserver.service
}

configure_webserver() {
	local php_fpm_service
	php_fpm_service="$(systemctl list-unit-files "php*-fpm.service" --no-legend 2>/dev/null | awk 'NR==1 {print $1}')"
	if [[ -z "${php_fpm_service}" ]]; then
		php_fpm_service="$(systemctl list-unit-files "php-fpm.service" --no-legend 2>/dev/null | awk 'NR==1 {print $1}')"
	fi
	if [[ -z "${php_fpm_service}" ]]; then
		echo "Could not detect php-fpm service."
		exit 1
	fi

	systemctl enable "${php_fpm_service}"
	systemctl restart "${php_fpm_service}"

	local php_fpm_sock
	php_fpm_sock="$(ls /run/php/php*-fpm.sock 2>/dev/null | head -n 1 || true)"
	if [[ -z "${php_fpm_sock}" ]]; then
		echo "Could not find php-fpm socket in /run/php."
		exit 1
	fi

	cat >/etc/nginx/sites-available/violet.conf <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    root ${ROOT_DIR}/znote/htdocs;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:${php_fpm_sock};
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

	rm -f /etc/nginx/sites-enabled/default
	ln -sf /etc/nginx/sites-available/violet.conf /etc/nginx/sites-enabled/violet.conf

	systemctl enable mariadb
	systemctl enable nginx
	systemctl restart nginx
}

detect_ip
install_packages
bootstrap_database
write_game_config
write_aac_config
build_gameserver
create_systemd_service
configure_webserver

echo "VPS setup completed."
echo "Review ${GAME_CONFIG} and ${AAC_CONFIG}, then start with: systemctl start violet-gameserver"
