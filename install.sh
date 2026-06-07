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

# Execute commands directly inside Debian with visual progress!
proot-distro login debian -- bash -c '
export DEBIAN_FRONTEND=noninteractive

# THE FIX: We tell Debian to install Node.js natively right here!
apt update -y > /dev/null 2>&1
apt install wget unzip nodejs -y > /dev/null 2>&1

mkdir -p /root/server
cd /root/server

echo "-> Fetching Minecraft & UI Bundle from GitHub..."
wget -O bundle.zip https://github.com/Ravjit-singh/yourhost/releases/download/v1.0/backend_bundle.zip

echo "-> Extracting files..."
unzip -o bundle.zip > /dev/null 2>&1
rm bundle.zip

chmod +x bedrock_server

# THE FIX: Change "./node" to just "node" to use the natively installed engine
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

# Boot the backend!
start-mc
