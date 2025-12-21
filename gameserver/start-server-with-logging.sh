#!/bin/bash
# Start The Violet Project server with console logging

echo "Starting The Violet Project server with logging..."
echo "Log file: server.log"
echo ""
echo "To monitor in real-time, open another terminal and run:"
echo "  tail -f server.log"
echo ""
echo "To stop the server:"
echo "  kill \$(pgrep tfs)"
echo ""

# Start server with output to log file
nohup ./tfs > server.log 2>&1 &

echo "Server started! PID: $!"
echo ""
echo "Monitoring log (Press Ctrl+C to stop monitoring, server keeps running):"
sleep 2
tail -f server.log
