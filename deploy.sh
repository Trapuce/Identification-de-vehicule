#!/bin/bash

# Script de déploiement ANPR
set -e

echo "🚀 Déploiement de l'application ANPR..."

# Variables
APP_DIR="/opt/anpr"
SERVICE_NAME="anpr"
NGINX_SITE="anpr"

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Vérifier si on est root
if [ "$EUID" -ne 0 ]; then
    log_error "Ce script doit être exécuté en tant que root"
    exit 1
fi

# Mettre à jour le système
log_info "Mise à jour du système..."
apt update && apt upgrade -y

# Installer les dépendances système
log_info "Installation des dépendances système..."
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
    supervisor

# Créer le répertoire de l'application
log_info "Création du répertoire de l'application..."
mkdir -p $APP_DIR
cd $APP_DIR

# Cloner ou copier le code (remplacez par votre méthode)
log_info "Copie du code de l'application..."
# git clone https://github.com/votre-repo/anpr.git .  # Décommentez si vous utilisez Git
# Ou copiez manuellement vos fichiers dans $APP_DIR

# Créer l'environnement virtuel
log_info "Création de l'environnement virtuel..."
python3 -m venv venv
source venv/bin/activate

# Installer les dépendances Python
log_info "Installation des dépendances Python..."
pip install --upgrade pip
pip install -r requirements-prod.txt

# Créer les répertoires nécessaires
log_info "Création des répertoires..."
mkdir -p plate_recognition/static/exports
mkdir -p plate_recognition/uploads
mkdir -p logs

# Configurer les permissions
log_info "Configuration des permissions..."
chown -R www-data:www-data $APP_DIR
chmod -R 755 $APP_DIR

# Copier le fichier de service systemd
log_info "Configuration du service systemd..."
cp anpr.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable $SERVICE_NAME

# Configuration Nginx
log_info "Configuration de Nginx..."
cp nginx.conf /etc/nginx/sites-available/$NGINX_SITE
ln -sf /etc/nginx/sites-available/$NGINX_SITE /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Tester la configuration Nginx
nginx -t

# Démarrer les services
log_info "Démarrage des services..."
systemctl start $SERVICE_NAME
systemctl restart nginx

# Vérifier le statut
log_info "Vérification du statut des services..."
systemctl status $SERVICE_NAME --no-pager -l
systemctl status nginx --no-pager -l

log_info "✅ Déploiement terminé !"
log_info "Votre application est accessible sur : http://votre-ip"
log_info "Pour voir les logs : journalctl -u $SERVICE_NAME -f"
log_info "Pour redémarrer : systemctl restart $SERVICE_NAME"
