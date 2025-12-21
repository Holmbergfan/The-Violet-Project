# How to Monitor The Violet Project Server Console Output

## Current Server Status

The server was started in **detached mode**, which means it runs in the background without a visible console.

## Methods to Monitor Server Output

### Method 1: View Real-Time Console Output (Recommended)

If you want to see console output, restart the server in foreground mode:

```bash
# 1. Stop the current server (if running)
ps aux | grep tfs  # Find the PID
kill <PID>  # Replace <PID> with the actual process ID

# 2. Start server in foreground (you'll see all output)
cd /home/runner/work/The-Violet-Project/The-Violet-Project/gameserver
./tfs
```

**Note**: This keeps the terminal open. Press `Ctrl+C` to stop the server.

### Method 2: Run in Background with Log File

Redirect output to a log file while running in background:

```bash
cd /home/runner/work/The-Violet-Project/The-Violet-Project/gameserver

# Start with output redirected to log file
nohup ./tfs > server.log 2>&1 &

# View the log in real-time
tail -f server.log

# View last 50 lines
tail -50 server.log

# View specific number of lines
tail -n 100 server.log
```

### Method 3: Using Screen or Tmux (Best for VPS)

#### Using Screen:
```bash
# Install screen if not available
sudo apt-get install screen

# Start a new screen session
screen -S violet-server

# Inside screen, start the server
cd /home/runner/work/The-Violet-Project/The-Violet-Project/gameserver
./tfs

# Detach from screen: Press Ctrl+A, then D
# Reattach to view console: screen -r violet-server
# List sessions: screen -ls
```

#### Using Tmux:
```bash
# Install tmux if not available
sudo apt-get install tmux

# Start a new tmux session
tmux new -s violet-server

# Inside tmux, start the server
cd /home/runner/work/The-Violet-Project/The-Violet-Project/gameserver
./tfs

# Detach from tmux: Press Ctrl+B, then D
# Reattach to view console: tmux attach -t violet-server
# List sessions: tmux ls
```

### Method 4: Check System Logs

The server may write to system logs:

```bash
# Check recent system messages
dmesg | tail -50

# Check syslog
tail -f /var/log/syslog | grep tfs

# Check for crash logs
ls -la /home/runner/work/The-Violet-Project/The-Violet-Project/gameserver/gamedata/logs/
```

## Monitoring Server Status

### Check if Server is Running:
```bash
ps aux | grep tfs
```

### Check Network Ports:
```bash
# See what ports the server is listening on
ss -tlnp | grep tfs
# or
netstat -tlnp | grep tfs
```

### Check Server Resource Usage:
```bash
# CPU and Memory usage
top -p $(pgrep tfs)

# Detailed info
htop  # if installed
```

## Log File Locations

The server may create logs in these locations:
- `gamedata/logs/` - Player data and game logs
- `data/logs/` - General server logs
- Current directory - If started with output redirection

## Recommended Setup for VPS

For production use on a VPS, I recommend using **systemd service** or **screen/tmux**:

### Option A: Systemd Service (Advanced)
Create a service file to manage the server with automatic restart and logging:

```bash
sudo nano /etc/systemd/system/violet-server.service
```

```ini
[Unit]
Description=The Violet Project Game Server
After=network.target mysql.service

[Service]
Type=simple
User=runner
WorkingDirectory=/home/runner/work/The-Violet-Project/The-Violet-Project/gameserver
ExecStart=/home/runner/work/The-Violet-Project/The-Violet-Project/gameserver/tfs
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

Then:
```bash
# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable violet-server
sudo systemctl start violet-server

# View logs
sudo journalctl -u violet-server -f

# Check status
sudo systemctl status violet-server
```

### Option B: Screen (Simple, Recommended for Manual Management)
```bash
# Start server in screen
screen -S violet-server
cd /home/runner/work/The-Violet-Project/The-Violet-Project/gameserver
./tfs

# Detach: Ctrl+A, then D
# Reattach anytime: screen -r violet-server
```

## Quick Commands Reference

```bash
# Start server (foreground)
cd /home/runner/work/The-Violet-Project/The-Violet-Project/gameserver && ./tfs

# Start with log file (background)
cd /home/runner/work/The-Violet-Project/The-Violet-Project/gameserver && nohup ./tfs > server.log 2>&1 &

# View live log
tail -f /home/runner/work/The-Violet-Project/The-Violet-Project/gameserver/server.log

# Check if running
ps aux | grep tfs

# Check ports
ss -tlnp | grep -E "7171|7172"

# Stop server
kill $(pgrep tfs)
```

## Troubleshooting

### No Output Visible
- If server was started in detached mode (with `&` at the end), there's no console output
- Restart in foreground mode or use screen/tmux

### Server Crashes
- Check for core dumps: `ls -la core*`
- Check system logs: `dmesg | tail`
- Run in foreground to see error messages

### Permission Issues
- Ensure you have write permissions to the gameserver directory
- Check log directory permissions: `ls -la gamedata/logs/`

## Summary

**Easiest method**: Use **screen** or **tmux** to run the server so you can attach/detach anytime to view the console.

**For monitoring**: Start the server with output redirected to a log file and use `tail -f` to monitor it.

**For production**: Set up a **systemd service** for automatic management and logging.
