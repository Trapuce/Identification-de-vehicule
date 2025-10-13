#!/bin/bash

# Script de déploiement ANPR pour anpr.trapuce.tech
set -e

echo "🚀 Déploiement de l'application ANPR sur anpr.trapuce.tech..."

# Variables
APP_DIR="/opt/anpr"
SERVICE_NAME="anpr"
NGINX_SITE="anpr"
DOMAIN="anpr.anpr.trapuce.tech"

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[ÉTAPE]${NC} $1"
}

# Vérifier si on est root
if [ "$EUID" -ne 0 ]; then
    log_error "Ce script doit être exécuté en tant que root"
    exit 1
fi

log_step "1. Mise à jour du système..."
apt update && apt upgrade -y

log_step "2. Installation des dépendances système..."
apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    nginx \
    tesseract-ocr \
    tesseract-ocr-fra \
    ffmpeg \
    git \
    curl \
    certbot \
    python3-certbot-nginx \
    ufw

log_step "3. Configuration du firewall..."
ufw --force enable
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp

log_step "4. Création du répertoire de l'application..."
mkdir -p $APP_DIR
cd $APP_DIR

# Note: Vous devrez copier vos fichiers ici
log_warn "IMPORTANT: Copiez vos fichiers de l'application dans $APP_DIR"
log_warn "Vous pouvez utiliser: scp -r /chemin/vers/votre/projet/* root@anpr.trapuce.tech:$APP_DIR/"

# Créer l'environnement virtuel
log_step "5. Création de l'environnement virtuel..."
python3 -m venv venv
source venv/bin/activate

# Installer les dépendances Python
log_step "6. Installation des dépendances Python..."
pip install --upgrade pip
pip install -r requirements-prod.txt

# Créer les répertoires nécessaires
log_step "7. Création des répertoires..."
mkdir -p plate_recognition/static/exports
mkdir -p plate_recognition/uploads
mkdir -p logs

# Configurer les permissions
log_step "8. Configuration des permissions..."
chown -R www-data:www-data $APP_DIR
chmod -R 755 $APP_DIR

# Copier le fichier de service systemd
log_step "9. Configuration du service systemd..."
cp anpr.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable $SERVICE_NAME

# Configuration Nginx
log_step "10. Configuration de Nginx..."
cp nginx.conf /etc/nginx/sites-available/$NGINX_SITE
ln -sf /etc/nginx/sites-available/$NGINX_SITE /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Tester la configuration Nginx
nginx -t

# Démarrer les services
log_step "11. Démarrage des services..."
systemctl start $SERVICE_NAME
systemctl restart nginx

# Configuration SSL avec Let's Encrypt
log_step "12. Configuration SSL avec Let's Encrypt..."
log_info "Obtenir le certificat SSL pour $DOMAIN..."
certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN

# Vérifier le statut
log_step "13. Vérification du statut des services..."
systemctl status $SERVICE_NAME --no-pager -l
systemctl status nginx --no-pager -l

# Configuration du renouvellement automatique
log_step "14. Configuration du renouvellement automatique SSL..."
(crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet") | crontab -

log_info "✅ Déploiement terminé !"
log_info "🌐 Votre application est accessible sur : https://$DOMAIN"
log_info "📊 Pour voir les logs : journalctl -u $SERVICE_NAME -f"
log_info "🔄 Pour redémarrer : systemctl restart $SERVICE_NAME"
log_info "🔒 SSL configuré automatiquement avec Let's Encrypt"

echo ""
log_info "📋 Prochaines étapes :"
log_info "1. Copiez vos fichiers dans $APP_DIR"
log_info "2. Redémarrez le service : systemctl restart $SERVICE_NAME"
log_info "3. Testez votre application sur https://$DOMAIN"
