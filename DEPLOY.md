# 🚀 Déploiement ANPR sur VPS

Guide simple pour déployer votre application ANPR sur votre VPS avec le domaine `anpr.trapuce.tech`.

## 📋 Prérequis

- VPS Ubuntu/Debian avec accès root
- Domaine `anpr.trapuce.tech` pointant vers votre VPS
- Python 3.8+ installé
- Git installé

## 🛠️ Installation sur le VPS

### 1. Connexion au VPS
```bash
ssh root@anpr.trapuce.tech
```

### 2. Mise à jour du système
```bash
apt update && apt upgrade -y
```

### 3. Installation des dépendances
```bash
# Python et pip
apt install -y python3 python3-pip python3-venv

# Tesseract OCR
apt install -y tesseract-ocr tesseract-ocr-fra

# Autres dépendances
apt install -y nginx gunicorn git curl
```

### 4. Cloner le projet
```bash
cd /opt
git clone https://github.com/votre-username/Identification-de-vehicule.git anpr
cd anpr
```

### 5. Configuration de l'environnement
```bash
# Créer l'environnement virtuel
python3 -m venv venv
source venv/bin/activate

# Installer les dépendances
pip install -r requirements.txt

# Créer les répertoires nécessaires
mkdir -p plate_recognition/static/exports
mkdir -p plate_recognition/uploads
```

### 6. Configuration des permissions
```bash
chown -R www-data:www-data /opt/anpr
chmod -R 755 /opt/anpr
```

## ⚙️ Configuration du service

### 1. Créer le service systemd
```bash
nano /etc/systemd/system/anpr.service
```

Contenu :
```ini
[Unit]
Description=ANPR Flask Application
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=/opt/anpr
Environment=PATH=/opt/anpr/venv/bin
ExecStart=/opt/anpr/venv/bin/gunicorn --bind 127.0.0.1:8000 --workers 4 --timeout 120 --access-logfile - --error-logfile - plate_recognition.app:app
Restart=always

[Install]
WantedBy=multi-user.target
```

### 2. Activer le service
```bash
systemctl daemon-reload
systemctl enable anpr
systemctl start anpr
systemctl status anpr
```

## 🌐 Configuration Nginx

### 1. Créer la configuration Nginx
```bash
nano /etc/nginx/sites-available/anpr
```

Contenu :
```nginx
server {
    listen 80;
    server_name anpr.trapuce.tech;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /static {
        alias /opt/anpr/plate_recognition/static;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

### 2. Activer le site
```bash
ln -s /etc/nginx/sites-available/anpr /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default
nginx -t
systemctl restart nginx
```

## 🔒 Configuration SSL (Let's Encrypt)

### 1. Installer Certbot
```bash
apt install -y certbot python3-certbot-nginx
```

### 2. Obtenir le certificat SSL
```bash
certbot --nginx -d anpr.trapuce.tech
```

### 3. Vérifier le renouvellement automatique
```bash
certbot renew --dry-run
```

## 🔥 Configuration du firewall

```bash
# Installer UFW
apt install -y ufw

# Configurer les règles
ufw allow ssh
ufw allow 'Nginx Full'
ufw --force enable
```

## ✅ Vérification

### 1. Vérifier les services
```bash
systemctl status anpr
systemctl status nginx
```

### 2. Tester l'application
```bash
curl http://localhost:8000
curl https://anpr.trapuce.tech
```

### 3. Vérifier les logs
```bash
journalctl -u anpr -f
tail -f /var/log/nginx/error.log
```

## 🔄 Mise à jour du code

Pour mettre à jour l'application :

```bash
cd /opt/anpr
git pull origin main
source venv/bin/activate
pip install -r requirements.txt
systemctl restart anpr
```

## 🆘 Dépannage

### Problèmes courants :

1. **Service ne démarre pas** :
   ```bash
   journalctl -u anpr -n 50
   ```

2. **Erreur 502 Bad Gateway** :
   - Vérifier que le service anpr fonctionne
   - Vérifier la configuration Nginx

3. **Erreur de permissions** :
   ```bash
   chown -R www-data:www-data /opt/anpr
   chmod -R 755 /opt/anpr
   ```

4. **Problème de dépendances** :
   ```bash
   source venv/bin/activate
   pip install -r requirements.txt
   ```

## 📞 Support

En cas de problème, vérifiez :
- Les logs du service : `journalctl -u anpr -f`
- Les logs Nginx : `tail -f /var/log/nginx/error.log`
- Le statut des services : `systemctl status anpr nginx`

---

**Votre application sera accessible à : https://anpr.trapuce.tech**
