# 🚀 Guide de déploiement avec Git

## 📋 Étapes pour déployer avec Git

### 1. Créer un dépôt distant

#### Option A : GitHub (Recommandé)
```bash
# 1. Allez sur https://github.com
# 2. Créez un nouveau dépôt : "anpr-application"
# 3. Ne cochez PAS "Initialize with README" (déjà fait)

# 4. Ajoutez le dépôt distant
git remote add origin https://github.com/VOTRE_USERNAME/anpr-application.git

# 5. Poussez le code
git branch -M main
git push -u origin main
```

#### Option B : GitLab
```bash
# 1. Allez sur https://gitlab.com
# 2. Créez un nouveau projet : "anpr-application"

# 3. Ajoutez le dépôt distant
git remote add origin https://gitlab.com/VOTRE_USERNAME/anpr-application.git

# 4. Poussez le code
git branch -M main
git push -u origin main
```

#### Option C : Bitbucket
```bash
# 1. Allez sur https://bitbucket.org
# 2. Créez un nouveau dépôt : "anpr-application"

# 3. Ajoutez le dépôt distant
git remote add origin https://bitbucket.org/VOTRE_USERNAME/anpr-application.git

# 4. Poussez le code
git branch -M main
git push -u origin main
```

### 2. Déploiement sur le VPS

#### Sur votre VPS (trapuce.tech)
```bash
# 1. Connectez-vous à votre VPS
ssh root@IP_DE_VOTRE_VPS

# 2. Clonez le dépôt
git clone https://github.com/VOTRE_USERNAME/anpr-application.git /opt/anpr
cd /opt/anpr

# 3. Exécutez le script de déploiement
chmod +x deploy-trapuce.sh
./deploy-trapuce.sh

# 4. Créez l'environnement virtuel et installez les dépendances
python3 -m venv venv
source venv/bin/activate
pip install -r requirements-prod.txt

# 5. Redémarrez les services
systemctl restart anpr
systemctl restart nginx
```

### 3. Mise à jour de l'application

#### Depuis votre machine locale
```bash
# 1. Faites vos modifications
# 2. Committez les changements
git add .
git commit -m "Description des modifications"
git push origin main
```

#### Sur le VPS
```bash
# 1. Connectez-vous au VPS
ssh root@IP_DE_VOTRE_VPS

# 2. Allez dans le dossier de l'application
cd /opt/anpr

# 3. Récupérez les dernières modifications
git pull origin main

# 4. Mettez à jour les dépendances si nécessaire
source venv/bin/activate
pip install -r requirements-prod.txt

# 5. Redémarrez l'application
systemctl restart anpr
```

### 4. Script de mise à jour automatique

Créez un script pour automatiser les mises à jour :

```bash
# Sur le VPS, créez le fichier
nano /opt/anpr/update.sh
```

Contenu du script :
```bash
#!/bin/bash
cd /opt/anpr
git pull origin main
source venv/bin/activate
pip install -r requirements-prod.txt
systemctl restart anpr
echo "Application mise à jour avec succès !"
```

```bash
# Rendez le script exécutable
chmod +x /opt/anpr/update.sh
```

### 5. Configuration Git sur le VPS

```bash
# Configurez Git sur le VPS
git config --global user.name "VPS Deploy"
git config --global user.email "deploy@trapuce.tech"

# Pour les dépôts privés, configurez l'authentification
# Option A: Token d'accès personnel
git config --global credential.helper store

# Option B: Clé SSH
ssh-keygen -t rsa -b 4096 -C "deploy@trapuce.tech"
# Copiez la clé publique dans votre compte GitHub/GitLab
```

### 6. Mise à jour automatique avec cron

```bash
# Ajoutez une tâche cron pour mise à jour automatique
crontab -e

# Ajoutez cette ligne pour mise à jour quotidienne à 2h du matin
0 2 * * * /opt/anpr/update.sh >> /var/log/anpr-update.log 2>&1
```

### 7. Sauvegarde automatique

```bash
# Script de sauvegarde
nano /opt/anpr/backup.sh
```

Contenu :
```bash
#!/bin/bash
BACKUP_DIR="/opt/backups/anpr"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Sauvegarder la base de données
cp /opt/anpr/plate_recognition/*.db $BACKUP_DIR/db_$DATE.db 2>/dev/null || true

# Sauvegarder les exports
tar -czf $BACKUP_DIR/exports_$DATE.tar.gz /opt/anpr/plate_recognition/static/exports/

# Garder seulement les 7 dernières sauvegardes
find $BACKUP_DIR -name "*.db" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "Sauvegarde terminée : $DATE"
```

```bash
# Rendez le script exécutable
chmod +x /opt/anpr/backup.sh

# Ajoutez à cron pour sauvegarde quotidienne
crontab -e
# Ajoutez : 0 1 * * * /opt/anpr/backup.sh
```

### 8. Commandes utiles

```bash
# Voir l'historique des commits
git log --oneline

# Voir les différences
git diff

# Annuler le dernier commit (local seulement)
git reset --soft HEAD~1

# Forcer la mise à jour (attention !)
git fetch --all
git reset --hard origin/main

# Voir le statut
git status

# Voir les branches
git branch -a
```

### 9. Dépannage

#### Problème de permissions
```bash
sudo chown -R www-data:www-data /opt/anpr
sudo chmod -R 755 /opt/anpr
```

#### Problème de dépendances
```bash
cd /opt/anpr
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements-prod.txt --force-reinstall
```

#### Problème de service
```bash
systemctl status anpr
journalctl -u anpr -f
systemctl restart anpr
```

---

**🎉 Votre application est maintenant versionnée et prête pour le déploiement !**

**Prochaines étapes :**
1. Créez votre dépôt sur GitHub/GitLab
2. Poussez votre code
3. Déployez sur votre VPS
4. Configurez la mise à jour automatique
