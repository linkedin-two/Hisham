#!/bin/bash

echo "=== EdVoyage System Monitor ==="
echo "Timestamp: $(date)"

echo -e "\n=== Memory & Swap Usage ==="
free -h

echo -e "\n=== CPU Load ==="
uptime

echo -e "\n=== Database Connections ==="
# Adjust connection string as needed
psql -h localhost -U edvoyage -d edvoyage -c "SELECT count(*) as active_connections FROM pg_stat_activity WHERE state = 'active';" 2>/dev/null || echo "PostgreSQL not reachable or psql not installed"

echo -e "\n=== OOM Killer Check (Last 20 lines) ==="
dmesg | grep -i "oom" | tail -20 || echo "No OOM events found in dmesg"

echo -e "\n=== Gunicorn Process Check ==="
ps aux | grep gunicorn | grep -v grep
