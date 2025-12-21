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

### Connection Details
- **Server IP**: Use `10.1.0.72` (or the public IP if exposed)
- **Login Port**: 7171
- **Game Port**: 7172
- **Protocol**: 7.72

### Supported Clients

Users can connect using:
- **Tibia 7.72 Client** with IP changer pointing to this server's IP
- **OTClient** configured for protocol 7.72

### How to Connect

1. **Using Original Tibia 7.72 Client with IP Changer**:
   - Download a Tibia 7.72 client
   - Use an IP changer tool to redirect connections to `10.1.0.72`
   - Launch the client and login

2. **Using OTClient**:
   - Download OTClient
   - Configure for protocol 7.72
   - Add server with IP: `10.1.0.72` and port: `7171`
   - Connect and login

3. **Create an Account**:
   - Use the Znote AAC web interface (see Next Steps section)
   - Or manually create an account in the MySQL database:
     ```sql
     INSERT INTO accounts (name, password) VALUES ('test', SHA1('test'));
     INSERT INTO players (name, account_id, level, vocation, health, healthmax, mana, manamax, looktype, lookbody, lookfeet, lookhead, looklegs, maglevel, cap, town_id, posx, posy, posz) 
     VALUES ('Test Character', 1, 8, 0, 185, 185, 40, 40, 136, 114, 94, 78, 58, 0, 470, 1, 32369, 32241, 7);
     ```

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
