# The Violet Project - Server Connection Information

## ✅ Server Status

- **MySQL**: ✓ RUNNING
- **Game Server**: ✓ RUNNING (PID: 6213)
- **Listening**: ✓ 0.0.0.0:7171 (Login) and 0.0.0.0:7172 (Game)

---

## 🌐 Network Information

### Available IP Addresses
- **Internal IP**: `10.1.0.173`
- **Docker Bridge**: `172.17.0.1`
- **Localhost**: `127.0.0.1`

### Ports
- **Login/Status Port**: `7171`
- **Game Port**: `7172`

---

## ⚠️ IMPORTANT: Connection Requirements

### If Connecting from LOCAL PC (outside this server):

**You MUST use the PUBLIC IP address of this server!**

The internal IP (`10.1.0.173`) will **NOT** work from outside this network. You need to:

1. **Find the public IP** of this server/VPS:
   - If this is a cloud VPS (AWS, DigitalOcean, Azure, etc.): Check your cloud provider's dashboard
   - If this is a local network server: Find your router's public IP (google "what is my ip" from the server)
   - If this is GitHub Actions runner: This is a temporary CI environment with limited external access

2. **Open firewall ports**:
   ```bash
   # Ubuntu/Debian firewall
   sudo ufw allow 7171/tcp
   sudo ufw allow 7172/tcp
   ```

3. **Configure port forwarding** (if behind NAT/router):
   - Forward ports 7171 and 7172 to internal IP 10.1.0.173

### If Connecting from SAME MACHINE:

You can use:
- `127.0.0.1` (localhost)
- `10.1.0.173` (internal IP)

---

## 🎮 Client Configuration

### Option 1: OTClient (Recommended - Easiest)

1. Download OTClient (supports custom servers)
2. Add new server with these settings:
   - **Name**: The Violet Project
   - **Host**: `[YOUR_PUBLIC_IP]` or `10.1.0.173` (if same network)
   - **Port**: `7171`
   - **Protocol**: `772` (Tibia 7.72)
3. Login with test account (see below)

### Option 2: Tibia 7.72 Client + IP Changer

1. Get original Tibia 7.72 client
2. Use an IP changer tool (TibiaAutoIP, TibiaIP, etc.)
3. Set IP to your server's public IP
4. Launch client and login

### Option 3: Manual Client Modification

1. Get Tibia 7.72 client
2. Use a hex editor to edit `Tibia.dat` or `Tibia.exe`
3. Replace CipSoft's login server address with your IP
4. Launch and login

---

## 🔑 Test Account Credentials

**Account ID**: `1234567`  
**Password**: `tibia`

### Available Characters:
- **GM Violet** - Level 1000 (God/Admin powers)
- **GM Ezzz** - Level 100 (God/Admin powers)
- **Knight** - Level 108
- **Druid** - Level 50

All characters belong to account `1234567`.

---

## 🛠️ Server Management

### Check Server Status
```bash
ps aux | grep tfs | grep -v grep
```

### View Live Server Log
```bash
tail -f /home/runner/work/The-Violet-Project/The-Violet-Project/gameserver/server.log
```

### Stop Server
```bash
kill 6213
```

### Start Server
```bash
cd /home/runner/work/The-Violet-Project/The-Violet-Project/gameserver
./tfs
```

### Start Server in Background
```bash
cd /home/runner/work/The-Violet-Project/The-Violet-Project/gameserver
nohup ./tfs > server.log 2>&1 &
```

### Check Listening Ports
```bash
ss -tuln | grep -E "7171|7172"
```

---

## 💾 Database Access

### Connect to Database
```bash
mysql -u tibia -ptibia tibia
```

### Create New Account
```sql
-- Account password will be SHA1 hashed
INSERT INTO accounts (id, password, email) VALUES (1234568, SHA1('mypassword'), 'user@example.com');

-- Create a character for the account
INSERT INTO players (name, account_id, level, vocation, health, healthmax, mana, manamax, 
                     looktype, lookbody, lookfeet, lookhead, looklegs, cap, town_id, 
                     posx, posy, posz)
VALUES ('My Character', 1234568, 8, 0, 185, 185, 40, 40, 
        136, 114, 94, 78, 58, 470, 1, 
        32369, 32241, 7);
```

---

## 🚨 Troubleshooting

### Server won't start?
```bash
# Check for missing dependencies
ldd /home/runner/work/The-Violet-Project/The-Violet-Project/gameserver/tfs

# Check log for errors
cat /home/runner/work/The-Violet-Project/The-Violet-Project/gameserver/server.log
```

### Can't connect from client?
1. Verify server is running: `ps aux | grep tfs`
2. Check ports are open: `ss -tuln | grep 7171`
3. Verify firewall allows connections
4. Confirm you're using the correct public IP
5. Check client is configured for protocol 7.72

### Database issues?
```bash
# Check MySQL is running
sudo service mysql status

# Test connection
mysql -u tibia -ptibia tibia -e "SELECT COUNT(*) FROM accounts;"
```

---

## 📁 Server Files

- **Server Location**: `/home/runner/work/The-Violet-Project/The-Violet-Project/gameserver/`
- **Executable**: `tfs`
- **Config**: `config.lua`
- **Map**: `data/map.otbm`
- **Scripts**: `data/scripts/`
- **Data**: `data/`

---

## 🌟 Server Information

- **Server Name**: Violet
- **Version**: The Violet Project 2.0
- **Protocol**: 7.72
- **World Type**: PVP
- **Map**: Custom (65000x65000)
- **Monsters**: 23,368 spawns
- **NPCs**: 337

---

## ⚙️ Configuration File

The server configuration is in:
```
/home/runner/work/The-Violet-Project/The-Violet-Project/gameserver/config.lua
```

Key settings:
- IP: `0.0.0.0` (listens on all interfaces)
- Login Port: `7171`
- Game Port: `7172`
- Database: `tibia` (user: `tibia`, pass: `tibia`)

---

## 🎯 Next Steps

1. **Determine your public IP** (from cloud provider or router)
2. **Open firewall ports** 7171 and 7172
3. **Configure your Tibia client** with the public IP
4. **Connect and play!**

---

**Enjoy The Violet Project! 🎮💜**

Created in honor of Violeta Morillo
