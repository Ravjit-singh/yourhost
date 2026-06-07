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
echo "[3/4] Downloading server files..."

# We execute the setup commands directly inside Debian! No file moving required.
proot-distro login debian -- bash -c '
apt update -y
apt install wget unzip -y
mkdir -p /root/server
cd /root/server
wget -qO bundle.zip https://github.com/Ravjit-singh/yourhost/releases/download/v1.0/backend_bundle.zip
unzip -qo bundle.zip
rm bundle.zip
chmod +x bedrock_server node
echo "cd /root/server && ./node server.js" > /root/start.sh
chmod +x /root/start.sh
'

# 4. Final Polish & Launch
echo "[4/4] Setup complete! Launching server and UI..."

# Create a permanent shortcut in Termux so the user can easily restart it later
echo 'proot-distro login debian -- bash /root/start.sh' > $PREFIX/bin/start-mc
chmod +x $PREFIX/bin/start-mc

# Tell Termux to open the user's web browser to your custom frontend
echo "Opening UI..."
termux-open-url http://localhost:3005

# Boot the backend! (This will keep running in the Termux terminal)
start-mc
