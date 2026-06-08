#!/bin/bash
echo "================================================="
echo "  Starting Minecraft Bedrock + UI Setup...       "
echo "================================================="

# 1. Install Termux requirements
echo "[1/4] Installing Termux dependencies..."
pkg update -y
pkg install proot-distro wget unzip termux-api -y

# 2. Install Debian
echo "[2/4] Setting up Debian subsystem..."
proot-distro install debian

# 3. Configure Debian and Download Files
echo "[3/4] Downloading server files... (This may take a minute)"

# Execute commands directly inside Debian
proot-distro login debian -- bash -c '
export DEBIAN_FRONTEND=noninteractive

echo "-> Installing base dependencies & Minecraft Network Libs..."
apt update -y > /dev/null 2>&1
# THE FIX: Added libcurl4 and libcurl3-gnutls so Bedrock can connect to Xbox Live
apt install wget unzip nodejs gnupg libcurl4 libcurl3-gnutls -y > /dev/null 2>&1

echo "-> Installing Box64 (x86_64 Translator for Android)..."
wget -q https://raw.githubusercontent.com/Pi-Apps-Coders/box64-debs/master/box64.list -O /etc/apt/sources.list.d/box64.list
wget -qO- https://raw.githubusercontent.com/Pi-Apps-Coders/box64-debs/master/KEY.gpg | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/box64-debs-archive-keyring.gpg
apt update -y > /dev/null 2>&1
apt install box64-android -y > /dev/null 2>&1

mkdir -p /root/server
cd /root/server

echo "-> Fetching Minecraft & UI Bundle from GitHub..."
wget -O bundle.zip https://github.com/Ravjit-singh/yourhost/releases/download/v1.1/backend_bundle.zip

echo "-> Extracting files..."
unzip -o bundle.zip > /dev/null 2>&1
rm bundle.zip

chmod +x bedrock_server

echo "cd /root/server && node server.js" > /root/start.sh
chmod +x /root/start.sh
'

# 4. Final Polish & Launch
echo "[4/4] Setup complete! Launching server and UI..."

# Create a permanent shortcut in Termux
echo 'proot-distro login debian -- bash /root/start.sh' > $PREFIX/bin/start-mc
chmod +x $PREFIX/bin/start-mc

# Tell Termux to open the user's web browser to your custom frontend
echo "Opening UI..."
termux-open-url http://localhost:3005

# Failsafe: Kill any old processes running on port 3005 to prevent jams
proot-distro login debian -- bash -c "pkill node" > /dev/null 2>&1

# Boot the backend!
start-mc
