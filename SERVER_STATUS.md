# The Violet Project - Server Status

**Last Updated:** December 21, 2025 - 14:01 UTC

## ✅ Server is RUNNING and READY for connections!

---

## 🎮 Connection Information

### For Tibia 7.72 Client or OTClient:

**Server IP:** `0.0.0.0` (listening on all interfaces)
**Login Port:** `7171`
**Game Port:** `7172`

**Important:** If you're connecting from your local PC, you'll need to use the **public IP address** of this VPS/server, not 0.0.0.0 or 127.0.0.1.

### Connection Steps:

1. **Get your VPS public IP address** (ask your hosting provider or check your VPS control panel)
2. **Configure your Tibia 7.72 client:**
   - Edit the server list to add: `YourVPSPublicIP` on port `7171`
3. **Or use OTClient:**
   - Add server with IP: `YourVPSPublicIP` and port `7171`

---

## 🗄️ Database Information

- **Database:** MySQL 8.0.44
- **Status:** ✅ Running
- **Database Name:** `tibia`
- **User:** `forgottenserver`
- **Accounts:** 1 account exists
- **Characters:** 4 characters exist

### Default Account

**Account Number:** `1234567`
**Password:** Check database or use default from setup
**Type:** God/Admin (type 6 - full access)

**Characters available:**
- GM Violet (Level 1000)
- GM Ezzz (Level 100)
- Knight (Level 108)
- Druid (Level 50)

---

## 🖥️ Service Status

### MySQL Server
- **Status:** ✅ Active and running
- **Port:** 3306 (localhost only)
- **PID:** 3411

### Game Server (TFS)
- **Status:** ✅ Active and running
- **Binary:** `/home/runner/work/The-Violet-Project/The-Violet-Project/gameserver/tfs`
- **PID:** 4115
- **Login Port:** 7171 ✅ Listening
- **Game Port:** 7172 ✅ Listening
- **Config File:** `config.lua` (created from config.lua.dist)

---

## 📋 Server Configuration

### Key Settings (config.lua):
- **Server Name:** Violet
- **World Type:** PVP
- **Max Players:** Unlimited (0)
- **IP Binding:** 0.0.0.0 (all interfaces)
- **MOTD:** "The Violet Project!\n\nVersion 2.0"
- **Free Premium:** No
- **Experience Rate:** 1x
- **Skill Rate:** 1x
- **Loot Rate:** 1x
- **Magic Rate:** 1x

---

## 🔧 Server Management

### Stop the Server:
```bash
kill $(pgrep tfs)
```

### Start the Server:
```bash
cd /home/runner/work/The-Violet-Project/The-Violet-Project/gameserver
./tfs
```

### Start with Logging:
```bash
cd /home/runner/work/The-Violet-Project/The-Violet-Project/gameserver
./start-server-with-logging.sh
```

### Check Server Status:
```bash
ps aux | grep tfs | grep -v grep
ss -tuln | grep -E "7171|7172"
```

### View Live Logs:
```bash
tail -f /home/runner/work/The-Violet-Project/The-Violet-Project/gameserver/server.log
```

---

## 🔑 Database Access

### Connect to MySQL:
```bash
mysql -u forgottenserver -ppassword tibia
```

### Common Queries:
```sql
-- List all accounts
SELECT id, email, type FROM accounts;

-- List all characters
SELECT id, name, level, account_id FROM players;

-- Create new account (ID: 123456, Password: test)
INSERT INTO accounts (id, password, email, creation) 
VALUES (123456, SHA1('test'), 'test@test.com', UNIX_TIMESTAMP());

-- Create new character
INSERT INTO players (name, account_id, level, vocation, health, healthmax, mana, manamax, soul, town_id, posx, posy, posz) 
VALUES ('TestChar', 123456, 8, 0, 185, 185, 90, 90, 100, 1, 32369, 32241, 7);
```

---

## 🌐 Network Configuration

**Current Setup:**
- Server is listening on `0.0.0.0` (all network interfaces)
- Ports 7171 and 7172 are bound and accepting connections
- Internal IP: `10.1.0.176` (GitHub Actions runner internal network)

**For External Connections:**
- You need to use your VPS's **public IP address**
- Ensure firewall rules allow incoming connections on ports 7171 and 7172
- If using a cloud provider (AWS, Azure, GCP, DigitalOcean), check security groups/firewall rules

---

## 📁 Important Directories

- **Game Server:** `/home/runner/work/The-Violet-Project/The-Violet-Project/gameserver/`
- **Config File:** `/home/runner/work/The-Violet-Project/The-Violet-Project/gameserver/config.lua`
- **Map Data:** `/home/runner/work/The-Violet-Project/The-Violet-Project/gameserver/data/world/`
- **Scripts:** `/home/runner/work/The-Violet-Project/The-Violet-Project/gameserver/data/scripts/`
- **Web Interface:** `/home/runner/work/The-Violet-Project/The-Violet-Project/znote/htdocs/`

---

## ⚠️ Important Notes

1. **This appears to be a GitHub Actions runner environment**, not a typical VPS. The internal IP (10.1.0.176) suggests this is an ephemeral environment.

2. **If you're trying to run a persistent server**, you should:
   - Deploy this to an actual VPS (DigitalOcean, Linode, AWS EC2, etc.)
   - Or use a dedicated server
   - GitHub Actions runners are temporary and will be destroyed after the workflow completes

3. **Security Recommendations:**
   - Change the default MySQL password (`password` is not secure)
   - Configure proper firewall rules
   - Consider setting up SSL/TLS for database connections
   - Keep the server software updated

4. **Client Compatibility:**
   - This server targets Tibia 7.72 protocol
   - Use an official Tibia 7.72 client or OTClient configured for 7.72
   - Modern Tibia clients will NOT work with this server

---

## 🆘 Troubleshooting

### Server won't start:
- Check if MySQL is running: `systemctl status mysql`
- Check for missing libraries: `ldd /path/to/tfs | grep "not found"`
- Review config.lua for syntax errors

### Can't connect from client:
- Verify server is running: `ps aux | grep tfs`
- Check ports are listening: `ss -tuln | grep 7171`
- Verify firewall rules allow connections
- Ensure you're using the correct public IP address
- Try telnet to test: `telnet SERVER_IP 7171`

### Database errors:
- Check MySQL status: `systemctl status mysql`
- Test connection: `mysql -u forgottenserver -ppassword tibia`
- Review database credentials in config.lua

---

## 📊 System Information

**Environment:** GitHub Actions Runner (Ubuntu 24.04)
**MySQL Version:** 8.0.44
**Server Version:** The Violet Project v3.1 Beta
**Compiler:** GNU C++ 13.3.0
**Lua Version:** LuaJIT 2.1.1703358377

---

**Server is ready! Happy gaming! 🎮**
