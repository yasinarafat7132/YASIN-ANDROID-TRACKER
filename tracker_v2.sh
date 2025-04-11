#!/bin/bash

======================= CONFIG =======================

BOT_TOKEN="8128619794:AAGhkVx-64tgJeoSXB_VDSQk7LnZaOECJcI" CHAT_ID="5548654620" PORT=8888

==================== SETUP SECTION ===================

echo -e "\e[32m[+] Installing dependencies...\e[0m" pkg update -y &>/dev/null pkg install php curl jq termux-api unzip -y &>/dev/null

================== START LOCAL SERVER =================

echo -e "\e[32m[+] Starting PHP server...\e[0m" nohup php -S 127.0.0.1:$PORT > /dev/null 2>&1 & sleep 2

===================== START NGROK =====================

echo -e "\e[32m[+] Starting ngrok...\e[0m" nohup ngrok http $PORT > /dev/null 2>&1 & sleep 5

NGROK_URL=$(curl -s http://127.0.0.1:4040/api/tunnels | jq -r '.tunnels[] | select(.proto=="https") | .public_url')

if [[ -z "$NGROK_URL" ]]; then echo -e "\e[31m[!] Failed to generate ngrok URL\e[0m" exit 1 fi

echo -e "\e[32m[+] Ngrok URL generated: $NGROK_URL\e[0m"

===================== GENERATE QR =====================

echo -e "\e[32m[+] Generating QR Code...\e[0m" echo "$NGROK_URL" | qrencode -o qr.png

==================== SEND TO TELEGRAM =================

echo -e "\e[32m[+] Sending QR and URL to Telegram...\e[0m" curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendPhoto" 
-F chat_id="$CHAT_ID" 
-F photo="@qr.png" 
-F caption="Tracker is live!\n\nLink: $NGROK_URL"

======================= DONE ==========================

echo -e "\e[32m[+] Tracker is live. QR Code & Link sent via Telegram.\e[0m"
