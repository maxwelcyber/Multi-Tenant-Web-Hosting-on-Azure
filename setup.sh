#!/bin/bash
# ============================================================
# Multi-Tenant Web Hosting with Isolated Client Environments
# Author: MaxwelCyber — Lagos, Nigeria
# Platform: Ubuntu 22.04 on Azure
# ============================================================

set -e

echo "=== GizmoFix Multi-Tenant Hosting Setup ==="

# ----- Variables -----
CLIENT1_USER="emeka"
CLIENT1_GROUP="airtel"
CLIENT1_DIR="/var/www/html-airtel"
CLIENT1_PORT="8081"

CLIENT2_USER="ebuka"
CLIENT2_GROUP="mtn"
CLIENT2_DIR="/var/www/html-mtn"
CLIENT2_PORT="8082"

WEB_USER="www-data"

# ----- Update & Install Nginx -----
echo "[1/8] Installing Nginx..."
sudo apt update -y && sudo apt install nginx -y

# ----- Create Directories -----
echo "[2/8] Creating client directories..."
sudo mkdir -p "$CLIENT1_DIR"
sudo mkdir -p "$CLIENT2_DIR"

# ----- Create Groups -----
echo "[3/8] Creating client groups..."
sudo groupadd -f "$CLIENT1_GROUP"
sudo groupadd -f "$CLIENT2_GROUP"

# ----- Create Users -----
echo "[4/8] Creating client users..."
sudo useradd -m -G "$CLIENT1_GROUP" "$CLIENT1_USER" 2>/dev/null || echo "$CLIENT1_USER already exists"
sudo useradd -m -G "$CLIENT2_GROUP" "$CLIENT2_USER" 2>/dev/null || echo "$CLIENT2_USER already exists"

# ----- Set Ownership & Permissions -----
echo "[5/8] Setting ownership and permissions..."
sudo chown -R "$CLIENT1_USER":"$CLIENT1_GROUP" "$CLIENT1_DIR"
sudo chown -R "$CLIENT2_USER":"$CLIENT2_GROUP" "$CLIENT2_DIR"
sudo chmod -R 750 "$CLIENT1_DIR"
sudo chmod -R 750 "$CLIENT2_DIR"

# ----- Add Web Server to Both Groups -----
echo "[6/8] Adding Nginx to client groups..."
sudo usermod -aG "$CLIENT1_GROUP" "$WEB_USER"
sudo usermod -aG "$CLIENT2_GROUP" "$WEB_USER"

# ----- Deploy Sample Pages -----
echo "[7/8] Deploying client pages..."
echo "<h1>Welcome to Airtel</h1><p>Client: $CLIENT1_USER</p><p>Managed by GizmoFix Repair Services</p>" | sudo tee "$CLIENT1_DIR/index.html" > /dev/null
echo "<h1>Welcome to MTN</h1><p>Client: $CLIENT2_USER</p><p>Managed by GizmoFix Repair Services</p>" | sudo tee "$CLIENT2_DIR/index.html" > /dev/null

# ----- Configure Nginx -----
echo "[8/8] Configuring Nginx server blocks..."

sudo tee "/etc/nginx/sites-available/$CLIENT1_USER-$CLIENT1_GROUP" > /dev/null <<EOF
server {
    listen $CLIENT1_PORT;
    root $CLIENT1_DIR;
    index index.html;
    server_name _;
}
EOF

sudo tee "/etc/nginx/sites-available/$CLIENT2_USER-$CLIENT2_GROUP" > /dev/null <<EOF
server {
    listen $CLIENT2_PORT;
    root $CLIENT2_DIR;
    index index.html;
    server_name _;
}
EOF

# Enable sites
sudo ln -sf "/etc/nginx/sites-available/$CLIENT1_USER-$CLIENT1_GROUP" /etc/nginx/sites-enabled/
sudo ln -sf "/etc/nginx/sites-available/$CLIENT2_USER-$CLIENT2_GROUP" /etc/nginx/sites-enabled/

# Test and restart
sudo nginx -t && sudo systemctl restart nginx

echo ""
echo "============================================="
echo " Setup Complete!"
echo " Emeka (Airtel): http://<VM-IP>:8081"
echo " Ebuka (MTN):   http://<VM-IP>:8082"
echo "============================================="
echo ""
echo "To verify isolation, SSH as emeka and run:"
echo "  cat /var/www/html-mtn/index.html"
echo "Expected: Permission denied"
