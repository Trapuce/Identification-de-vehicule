# 🚀 Guide de déploiement ANPR sur VPS

## 📋 Prérequis

- VPS avec Ubuntu 20.04+ ou Debian 11+
- Accès root ou sudo
- Au moins 2GB RAM et 20GB d'espace disque
- Domaine (optionnel, pour HTTPS)

## 🛠️ Méthodes de déploiement

### Option 1 : Déploiement automatique (Recommandé)

```bash
# 1. Connectez-vous à votre VPS
ssh root@trapuce.tech

# 2. Téléchargez le script de déploiement
wget https://raw.githubusercontent.com/votre-repo/anpr/main/deploy.sh
chmod +x deploy.sh

# 3. Exécutez le script
./deploy.sh
```

### Option 2 : Déploiement manuel

#### 1. Préparation du serveur

```bash
# Mise à jour du système
sudo apt update && sudo apt upgrade -y

# Installation des dépendances
sudo apt install -y python3 python3-pip python3-venv nginx tesseract-ocr tesseract-ocr-fra ffmpeg git curl
```

#### 2. Configuration de l'application

```bash
# Créer le répertoire
sudo mkdir -p /opt/anpr
cd /opt/anpr

# Copier votre code (remplacez par votre méthode)
# Option A: Git clone
git clone https://github.com/votre-repo/anpr.git .

# Option B: Upload manuel
# scp -r /chemin/vers/votre/projet root@trapuce.tech:/opt/anpr/

# Créer l'environnement virtuel
python3 -m venv venv
source venv/bin/activate

# Installer les dépendances
pip install -r requirements-prod.txt
```

#### 3. Configuration du service systemd

```bash
# Copier le fichier de service
sudo cp anpr.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable anpr
sudo systemctl start anpr
```

#### 4. Configuration Nginx

```bash
# Copier la configuration
sudo cp nginx.conf /etc/nginx/sites-available/anpr
sudo ln -s /etc/nginx/sites-available/anpr /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default

# Tester et redémarrer
sudo nginx -t
sudo systemctl restart nginx
```

### Option 3 : Déploiement avec Docker

```bash
# 1. Installer Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# 2. Installer Docker Compose
sudo apt install docker-compose -y

# 3. Déployer l'application
docker-compose up -d
```

## 🔧 Configuration SSL (HTTPS)

### Avec Let's Encrypt (Certbot)

```bash
# Installer Certbot
sudo apt install certbot python3-certbot-nginx -y

# Obtenir le certificat
sudo certbot --nginx -d trapuce.tech

# Vérifier le renouvellement automatique
sudo certbot renew --dry-run
```

## 📊 Monitoring et logs

### Vérifier le statut des services

```bash
# Statut de l'application
sudo systemctl status anpr

# Logs de l'application
sudo journalctl -u anpr -f

# Logs Nginx
sudo tail -f /var/log/nginx/anpr_access.log
sudo tail -f /var/log/nginx/anpr_error.log
```

### Commandes utiles

```bash
# Redémarrer l'application
sudo systemctl restart anpr

# Redémarrer Nginx
sudo systemctl restart nginx

# Vérifier les ports ouverts
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :443
sudo netstat -tlnp | grep :8000
```

## 🔒 Sécurité

### Configuration du firewall

```bash
# Installer UFW
sudo apt install ufw -y

# Configuration de base
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Autoriser SSH, HTTP et HTTPS
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Activer le firewall
sudo ufw enable
```

### Mise à jour automatique

```bash
# Installer unattended-upgrades
sudo apt install unattended-upgrades -y

# Configuration
sudo dpkg-reconfigure unattended-upgrades
```

## 🚨 Dépannage

### Problèmes courants

1. **Application ne démarre pas**
   ```bash
   sudo journalctl -u anpr -n 50
   ```

2. **Erreur 502 Bad Gateway**
   - Vérifier que l'application écoute sur 127.0.0.1:8000
   - Vérifier les logs Nginx

3. **Problème de permissions**
   ```bash
   sudo chown -R www-data:www-data /opt/anpr
   sudo chmod -R 755 /opt/anpr
   ```

4. **Erreur Tesseract**
   ```bash
   sudo apt install tesseract-ocr tesseract-ocr-fra -y
   ```

### Performance

- **Optimisation mémoire** : Ajustez le nombre de workers Gunicorn
- **Cache** : Configurez le cache Nginx pour les fichiers statiques
- **Base de données** : Considérez PostgreSQL pour la production

## 📈 Mise à l'échelle

### Load Balancer

Pour plusieurs instances :

```bash
# Configuration Nginx avec plusieurs backends
upstream anpr_backend {
    server 127.0.0.1:8000;
    server 127.0.0.1:8001;
    server 127.0.0.1:8002;
}
```

### Monitoring avancé

- **Prometheus + Grafana** pour les métriques
- **ELK Stack** pour les logs centralisés
- **Health checks** automatiques

## 📞 Support

En cas de problème :
1. Vérifiez les logs
2. Testez les services individuellement
3. Vérifiez la configuration réseau
4. Consultez la documentation des composants

---

**Note** : Remplacez `trapuce.tech` et `trapuce.tech` par vos vraies valeurs.
