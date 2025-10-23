#!/bin/bash
# Hetzner Server Setup Script für TTSG Trainingsplaner
# Führe dieses Script auf deinem frischen Hetzner Server aus

set -e  # Exit bei Fehler

echo "======================================"
echo "TTSG Trainingsplaner - Server Setup"
echo "======================================"
echo ""

# Farben für Output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. System Update
echo -e "${GREEN}[1/8] System-Updates installieren...${NC}"
apt update
apt upgrade -y
apt install -y curl wget unzip git

# 2. Caddy installieren (Reverse Proxy + automatisches SSL)
echo -e "${GREEN}[2/8] Caddy installieren...${NC}"
apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
apt update
apt install -y caddy

# 3. PocketBase herunterladen
echo -e "${GREEN}[3/8] PocketBase herunterladen...${NC}"
cd /opt
POCKETBASE_VERSION="0.22.0"
wget "https://github.com/pocketbase/pocketbase/releases/download/v${POCKETBASE_VERSION}/pocketbase_${POCKETBASE_VERSION}_linux_amd64.zip"
unzip "pocketbase_${POCKETBASE_VERSION}_linux_amd64.zip"
chmod +x pocketbase
rm "pocketbase_${POCKETBASE_VERSION}_linux_amd64.zip"

# 4. PocketBase als systemd Service einrichten
echo -e "${GREEN}[4/8] PocketBase Service konfigurieren...${NC}"
cat > /etc/systemd/system/pocketbase.service <<EOF
[Unit]
Description=PocketBase Backend for TTSG Trainingsplaner
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt
ExecStart=/opt/pocketbase serve --http=127.0.0.1:8090
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 5. PocketBase Service aktivieren
echo -e "${GREEN}[5/8] PocketBase Service starten...${NC}"
systemctl daemon-reload
systemctl enable pocketbase
systemctl start pocketbase

# Warte kurz damit PocketBase hochfährt
sleep 3

# 6. Frontend-Verzeichnis erstellen
echo -e "${GREEN}[6/8] Frontend-Verzeichnis erstellen...${NC}"
mkdir -p /var/www/trainingsplaner
chown -R www-data:www-data /var/www/trainingsplaner

# 7. Caddy konfigurieren
echo -e "${GREEN}[7/8] Caddy konfigurieren...${NC}"
echo ""
echo -e "${YELLOW}WICHTIG: Welche Domain soll verwendet werden?${NC}"
echo -e "${YELLOW}(z.B. trainingsplaner.dein-verein.de)${NC}"
read -p "Domain: " DOMAIN

cat > /etc/caddy/Caddyfile <<EOF
# TTSG Trainingsplaner - Caddy Konfiguration

${DOMAIN} {
    # Frontend (Static Files)
    root * /var/www/trainingsplaner
    file_server

    # Single Page Application - alle Routes zu index.html
    try_files {path} /index.html

    # API-Endpunkte zu PocketBase weiterleiten
    reverse_proxy /api/* 127.0.0.1:8090
    reverse_proxy /_/* 127.0.0.1:8090
}

# Admin-UI (optional, nur für dich zugänglich)
admin.${DOMAIN} {
    reverse_proxy 127.0.0.1:8090
}
EOF

# 8. Caddy neustarten
echo -e "${GREEN}[8/8] Caddy starten...${NC}"
systemctl restart caddy

# 9. Firewall konfigurieren (optional, aber empfohlen)
echo -e "${GREEN}[Bonus] Firewall konfigurieren...${NC}"
if command -v ufw &> /dev/null; then
    ufw allow 22/tcp    # SSH
    ufw allow 80/tcp    # HTTP
    ufw allow 443/tcp   # HTTPS
    echo "y" | ufw enable
    echo -e "${GREEN}Firewall aktiviert${NC}"
else
    echo -e "${YELLOW}ufw nicht installiert - überspringe Firewall-Setup${NC}"
fi

# Status-Check
echo ""
echo "======================================"
echo -e "${GREEN}✅ Setup abgeschlossen!${NC}"
echo "======================================"
echo ""
echo "Nächste Schritte:"
echo ""
echo "1. DNS konfigurieren:"
echo "   - A-Record: ${DOMAIN} → $(curl -s ifconfig.me)"
echo "   - A-Record: admin.${DOMAIN} → $(curl -s ifconfig.me)"
echo ""
echo "2. PocketBase Admin-UI öffnen:"
echo "   https://admin.${DOMAIN}/_/"
echo "   (Erstelle dort deinen Admin-Account)"
echo ""
echo "3. Deployment-User für GitHub Actions erstellen:"
echo "   adduser deployer"
echo "   mkdir -p /home/deployer/.ssh"
echo "   echo 'DEIN_SSH_PUBLIC_KEY' >> /home/deployer/.ssh/authorized_keys"
echo "   chown -R deployer:deployer /home/deployer/.ssh"
echo "   chmod 700 /home/deployer/.ssh"
echo "   chmod 600 /home/deployer/.ssh/authorized_keys"
echo ""
echo "Services Status:"
systemctl status pocketbase --no-pager | head -5
echo ""
systemctl status caddy --no-pager | head -5
echo ""
echo -e "${GREEN}Server ist bereit! 🚀${NC}"
