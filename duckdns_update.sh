#!/bin/bash
# ==============================================================================
# DuckDNS Dynamic DNS Update Script
# Keeps edzkool.duckdns.org and edvoyage.duckdns.org pointed to this EC2 instance
# ==============================================================================

# REPLACE THIS WITH YOUR DUCKDNS TOKEN FROM https://www.duckdns.org
DUCKDNS_TOKEN="YOUR_DUCKDNS_TOKEN_HERE"

DOMAINS="edzkool,edvoyage"

if [ "$DUCKDNS_TOKEN" = "YOUR_DUCKDNS_TOKEN_HERE" ]; then
    echo "ERROR: Please replace DUCKDNS_TOKEN in this script with your token from duckdns.org"
    exit 1
fi

echo "Updating DuckDNS domains: $DOMAINS..."
RESPONSE=$(curl -s "https://www.duckdns.org/update?domains=${DOMAINS}&token=${DUCKDNS_TOKEN}&ip=")

if [ "$RESPONSE" = "OK" ]; then
    echo "✓ DuckDNS update successful! Both domains pointed to current EC2 public IP."
else
    echo "✗ DuckDNS update failed. Response: $RESPONSE"
fi
