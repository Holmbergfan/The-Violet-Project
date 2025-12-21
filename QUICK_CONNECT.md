# Quick Connection Guide

## 🎮 The Violet Project Server - Ready to Connect!

---

## ⚡ Quick Start

### 1. Find Your Server's Public IP

Since this is running on a VPS/server, you need to find the **public IP address**:

```bash
# On the server, run:
curl ifconfig.me
# OR
curl icanhazip.com
# OR check your VPS control panel
```

### 2. Connect with Tibia 7.72 Client

**Option A: Edit Server List**
1. Go to your Tibia 7.72 installation folder
2. Edit the server list file
3. Add: `YOUR_VPS_IP:7171`
4. Save and launch Tibia

**Option B: Use IP Changer Tool**
- Use a Tibia IP changer tool
- Set IP to your VPS public IP
- Set port to 7171

### 3. Connect with OTClient

1. Launch OTClient
2. Add new server
3. Enter:
   - **Server Name:** The Violet Project
   - **Host:** YOUR_VPS_IP
   - **Port:** 7171
   - **Client Version:** 7.72
4. Click "Connect"

---

## 🔑 Default Login

**Account:** `1234567`
**Password:** (check your database or setup documentation)

**Available Characters:**
- GM Violet (Level 1000)
- GM Ezzz (Level 100)
- Knight (Level 108)
- Druid (Level 50)

---

## 🔧 Common Issues

### "Connection Refused" or "Cannot Connect"

**Check Firewall:**
```bash
# Allow ports on Ubuntu/Debian
sudo ufw allow 7171
sudo ufw allow 7172

# Check firewall status
sudo ufw status
```

**Verify Server is Running:**
```bash
# Check if TFS is running
ps aux | grep tfs

# Check if ports are listening
ss -tuln | grep -E "7171|7172"
```

**Test Connection:**
```bash
# From another machine
telnet YOUR_VPS_IP 7171
```

### "Wrong Client Version"

- Make sure you're using Tibia 7.72 client
- Modern Tibia clients (10.x, 11.x, 12.x) will NOT work
- Download OTClient and configure it for version 7.72

### "Invalid Account or Password"

**Reset Account Password:**
```bash
# Connect to database
mysql -u forgottenserver -ppassword tibia

# Reset password to "test" for account 1234567
UPDATE accounts SET password = SHA1('test') WHERE id = 1234567;
```

---

## 🌐 Cloud Provider Specific Notes

### AWS EC2
- Edit Security Group
- Add Inbound Rules for ports 7171 and 7172 (TCP)

### DigitalOcean
- Go to Networking → Firewalls
- Add Inbound Rules for ports 7171 and 7172

### Azure VM
- Configure Network Security Group (NSG)
- Add Inbound security rules for ports 7171 and 7172

### Google Cloud Platform
- Go to VPC Network → Firewall Rules
- Create rules allowing TCP on ports 7171 and 7172

---

## 📱 Test Your Connection

### From Command Line:
```bash
# Test if server responds on login port
nc -zv YOUR_VPS_IP 7171

# Or use telnet
telnet YOUR_VPS_IP 7171
```

### Expected Response:
You should see a connection established. If you type random characters and press Enter, the server might disconnect you (which means it's working!).

---

## 🆘 Need Help?

1. **Check server logs:**
   ```bash
   cd /home/runner/work/The-Violet-Project/The-Violet-Project/gameserver
   tail -f server.log
   ```

2. **Restart the server:**
   ```bash
   # Stop
   kill $(pgrep tfs)
   
   # Start
   cd /home/runner/work/The-Violet-Project/The-Violet-Project/gameserver
   ./tfs
   ```

3. **Check database connection:**
   ```bash
   mysql -u forgottenserver -ppassword tibia -e "SELECT COUNT(*) FROM accounts;"
   ```

---

## ✅ Checklist

- [ ] Found your VPS public IP address
- [ ] Configured firewall to allow ports 7171 and 7172
- [ ] Downloaded Tibia 7.72 client or OTClient
- [ ] Configured client with your server IP and port 7171
- [ ] Have your account credentials ready
- [ ] Server is running (`ps aux | grep tfs`)
- [ ] Ports are listening (`ss -tuln | grep 7171`)

---

**Happy Gaming! 🎮✨**

For detailed information, see [SERVER_STATUS.md](SERVER_STATUS.md)
