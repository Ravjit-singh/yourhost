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

# We create a mini-script that will run INSIDE Debian
cat << 'EOF' > setup_debian.sh
apt update -y && apt install wget unzip -y
mkdir -p /root/server
cd /root/server

# DOWNLOAD THE ZIP 
wget -qO bundle.zip https://github.com/Ravjit-singh/yourhost/releases/download/v1.0/backend_bundle.zip

# Unzip and clean up the zip file
unzip -qo bundle.zip
rm bundle.zip

# Force execution permissions to Node and Bedrock
chmod +x bedrock_server node

# Create an internal boot file
echo "cd /root/server && ./node server.js" > /root/start.sh
chmod +x /root/start.sh
EOF

# Move the mini-script into Debian and execute it
mv setup_debian.sh $PREFIX/var/lib/proot-distro/installed-rootfs/debian/root/
proot-distro login debian -- bash /root/setup_debian.sh

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
