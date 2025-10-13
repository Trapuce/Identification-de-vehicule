#!/bin/bash

# 🚀 Script de déploiement ANPR pour anpr.trapuce.tech
# Usage: ./deploy.sh

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
APP_DIR="$(pwd)"  # Utiliser le répertoire courant
SERVICE_NAME="anpr"
NGINX_SITE="anpr"
DOMAIN="anpr.trapuce.tech"

echo -e "${BLUE}🚀 Déploiement ANPR sur $DOMAIN${NC}"
echo "=================================="

# Fonction pour afficher les étapes
print_step() {
    echo -e "\n${YELLOW}[ÉTAPE] $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Vérifier si on est root
if [ "$EUID" -ne 0 ]; then
    print_error "Ce script doit être exécuté en tant que root"
    exit 1
fi

print_step "1. Mise à jour du système..."
apt update && apt upgrade -y
print_success "Système mis à jour"

print_step "2. Installation des dépendances système..."
apt install -y python3 python3-pip python3-venv tesseract-ocr tesseract-ocr-fra nginx gunicorn git curl ufw
print_success "Dépendances installées"

print_step "3. Vérification du répertoire de l'application..."
if [ ! -f "requirements.txt" ] || [ ! -d "plate_recognition" ]; then
    print_error "Ce n'est pas le bon répertoire !"
    print_error "Assurez-vous d'être dans le répertoire du projet Identification-de-vehicule"
    print_error "Utilisez: git clone https://github.com/Trapuce/Identification-de-vehicule.git"
    print_error "Puis: cd Identification-de-vehicule"
    exit 1
fi
print_success "Répertoire de l'application trouvé: $APP_DIR"

print_step "4. Configuration de l'environnement Python..."
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# Corriger le problème d'import yolo_pipeline
if [ -f "yolo_pipeline.py" ] && [ ! -f "plate_recognition/yolo_pipeline.py" ]; then
    cp yolo_pipeline.py plate_recognition/
    print_success "Fichier yolo_pipeline.py copié dans plate_recognition/"
fi

print_success "Environnement Python configuré"

print_step "5. Création des répertoires nécessaires..."
mkdir -p plate_recognition/static/exports
mkdir -p plate_recognition/uploads
print_success "Répertoires créés"

print_step "6. Configuration des permissions..."
chown -R www-data:www-data $APP_DIR
chmod -R 755 $APP_DIR
print_success "Permissions configurées"

print_step "7. Configuration du service systemd..."
cat > /etc/systemd/system/$SERVICE_NAME.service << EOF
[Unit]
Description=ANPR Flask Application
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=$APP_DIR
Environment=PATH=$APP_DIR/venv/bin
Environment=PYTHONPATH=$APP_DIR
ExecStart=$APP_DIR/venv/bin/gunicorn --bind 0.0.0.0:3001 --workers 4 --timeout 120 --access-logfile - --error-logfile - plate_recognition.app:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable $SERVICE_NAME
systemctl start $SERVICE_NAME
print_success "Service systemd configuré et démarré"

print_step "8. Désactivation de Nginx système (conflit avec Docker)..."
# Arrêter et désactiver Nginx système
systemctl stop nginx 2>/dev/null || true
systemctl disable nginx 2>/dev/null || true
print_success "Nginx système désactivé"

print_step "9. Configuration du firewall..."
ufw --force enable
ufw allow ssh
ufw allow 3001
print_success "Firewall configuré (port 3001 ouvert)"

print_step "10. Vérification des services..."
sleep 5
if systemctl is-active --quiet $SERVICE_NAME; then
    print_success "Service $SERVICE_NAME actif"
else
    print_error "Service $SERVICE_NAME inactif"
    systemctl status $SERVICE_NAME
fi

# Nginx système désactivé, pas de vérification nécessaire

echo -e "\n${GREEN}🎉 Déploiement terminé !${NC}"
echo "=================================="
echo -e "${BLUE}Prochaines étapes :${NC}"
echo "1. Configurez votre DNS pour pointer $DOMAIN vers cette IP"
echo "2. Votre application sera accessible à : http://$DOMAIN:3001"
echo "3. Pour SSL, configurez votre conteneur Nginx Docker existant"
echo ""
echo -e "${YELLOW}Pour mettre à jour l'application :${NC}"
echo "cd $APP_DIR && git pull origin main && systemctl restart $SERVICE_NAME"
echo ""
echo -e "${YELLOW}Commandes utiles :${NC}"
echo "- Vérifier les logs : journalctl -u $SERVICE_NAME -f"
echo "- Redémarrer le service : systemctl restart $SERVICE_NAME"
echo "- Vérifier le statut : systemctl status $SERVICE_NAME"
echo ""
echo -e "${GREEN}✅ Déploiement réussi !${NC}"
