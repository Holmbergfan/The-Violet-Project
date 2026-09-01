![alt text](https://cdn.discordapp.com/attachments/933483487909011500/933508253105664052/tvp2.png)
# The Violet Project
Tibia 7.72 reverse engineered game server.
In honor of my deceased grandmother, Violeta Morillo.

## Quick VPS setup
Run the automated VPS bootstrap script:

From repository root:

`sudo bash scripts/setup_vps.sh`

Optional environment variables:
- `SERVER_IP` (public/LAN IPv4 for clients)
- `SERVER_NAME` (default: `Violet`)
- `DB_NAME`, `DB_USER`, `DB_PASS`, `DB_HOST`, `DB_PORT`
- `SERVICE_USER`, `SERVICE_GROUP` (systemd gameserver account)
- `SKIP_APT=1` to skip package installation
- `SKIP_BUILD=1` to skip compiling the gameserver

The script installs dependencies, bootstraps MariaDB, configures `gameserver/config.lua` and `znote/htdocs/config.php`, imports Znote AAC SQL tables, builds the server binary, configures nginx + php-fpm for `znote/htdocs`, and registers a `violet-gameserver` systemd service.

# Thanks to
The Forgotten Server developers, and to Splinky.
