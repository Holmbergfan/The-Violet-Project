# The Violet Project - Server Setup Complete

## Setup Summary

The Violet Project game server has been successfully set up and is now running.

### What Was Done

1. **MySQL Database Setup**
   - Started MySQL service
   - Created `tibia` database
   - Imported schema from `schema.sql`
   - Created database user `tibia` with password `tibia`

2. **Configuration**
   - Created `config.lua` from `config.lua.dist`
   - Set IP to `0.0.0.0` to accept external connections
   - Updated MySQL credentials to use `tibia/tibia`
   - Map configuration: `mapName = "map"`

3. **Dependencies Installed**
   - libcrypto++-dev
   - libfmt-dev
   - libpugixml-dev
   - libluajit-5.1-dev
   - libboost-all-dev
   - libmysqlclient-dev
   - unrar

4. **Build Process**
   - Compiled game server using CMake and Make
   - Built successfully with GCC 13.3.0
   - Executable: `/home/runner/work/The-Violet-Project/The-Violet-Project/gameserver/tfs`

5. **Map Files**
   - Extracted world.rar from `data/world.rar`
   - Copied map files to data directory:
     - map.otbm (71MB)
     - spawns.xml (1.2MB)
     - houses.xml (104KB)

6. **Server Started**
   - Server is running on PID 6190
   - Listening on ports:
     - 7171 (login/status protocol)
     - 7172 (game protocol)

## Server Information

- **Server Name**: Violet
- **Version**: 3.1 Beta
- **World Type**: PVP
- **IP**: 0.0.0.0 (listening on all interfaces)
- **Login Port**: 7171
- **Game Port**: 7172
- **MOTD**: "The Violet Project!\n\nVersion 2.0"

## Map Statistics

- Map Size: 65000x65000
- Total Monsters: 23,368
- Total NPCs: 337
- Map Load Time: 12.895 seconds

## Database Configuration

- **Host**: localhost
- **Database**: tibia
- **User**: tibia
- **Password**: tibia
- **Port**: 3306

## Client Connection

Users can connect using:
- **Tibia 7.72 Client** with IP changer pointing to this server's IP
- **OTClient** configured for protocol 7.72

To connect, players need to:
1. Set the server IP to the machine's public/private IP address
2. Use port 7171 for login
3. Create an account in the database or use the web interface (Znote AAC)

## Notes

- The server is running in detached mode and will continue running
- Config.lua is in .gitignore (environment-specific, should not be committed)
- Build artifacts in `gameserver/build/` directory
- Server executable copied to `gameserver/tfs`

## Next Steps

To allow players to create accounts, you may want to:
1. Set up the Znote AAC web interface (in `znote/` directory)
2. Configure the web interface to connect to the same database
3. Or manually create accounts in the MySQL database

## Stopping the Server

To stop the server, use:
```bash
kill 6190
```

Or find the PID with:
```bash
ps aux | grep tfs
```

## Restarting the Server

```bash
cd /home/runner/work/The-Violet-Project/The-Violet-Project/gameserver
./tfs
```
