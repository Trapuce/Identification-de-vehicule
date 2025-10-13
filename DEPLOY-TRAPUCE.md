# 🚀 Déploiement ANPR sur anpr.trapuce.tech

## 📋 Guide de déploiement spécifique pour votre domaine

### 🎯 Étapes de déploiement

#### 1. Préparation de votre VPS

```bash
# Connectez-vous à votre VPS
ssh root@anpr.trapuce.tech

# Téléchargez le script de déploiement
wget https://raw.githubusercontent.com/votre-repo/anpr/main/deploy-trapuce.sh
chmod +x deploy-trapuce.sh

# Exécutez le script
./deploy-trapuce.sh
```

#### 2. Upload de vos fichiers

Après l'exécution du script, vous devez copier vos fichiers :

```bash
# Depuis votre machine locale
scp -r /Users/daoudatraore/Documents/Identification-de-vehicule/* root@anpr.trapuce.tech:/opt/anpr/

# Ou avec rsync (plus efficace)
rsync -avz --progress /Users/daoudatraore/Documents/Identification-de-vehicule/ root@anpr.trapuce.tech:/opt/anpr/
```

#### 3. Finalisation du déploiement

```bash
# Sur le VPS
cd /opt/anpr
source venv/bin/activate
pip install -r requirements-prod.txt

# Redémarrer le service
systemctl restart anpr
systemctl restart nginx
```

### 🔧 Configuration DNS

Assurez-vous que votre domaine `anpr.trapuce.tech` pointe vers l'IP de votre VPS :

```
A    anpr.trapuce.tech    →    IP_DE_VOTRE_VPS
```

### 🔒 SSL/HTTPS

Le script configure automatiquement SSL avec Let's Encrypt :
- Certificat automatique pour `anpr.trapuce.tech`
- Renouvellement automatique
- Redirection HTTP → HTTPS

### 📊 Accès à votre application

Une fois déployé, votre application sera accessible sur :
- **HTTPS** : https://anpr.trapuce.tech
- **HTTP** : http://anpr.trapuce.tech (redirigé vers HTTPS)

### 🛠️ Commandes utiles

```bash
# Vérifier le statut
systemctl status anpr
systemctl status nginx

# Voir les logs
journalctl -u anpr -f
tail -f /var/log/nginx/anpr_access.log

# Redémarrer l'application
systemctl restart anpr

# Redémarrer Nginx
systemctl restart nginx

# Vérifier les certificats SSL
certbot certificates
```

### 🚨 Dépannage

#### Problème de DNS
```bash
# Vérifier la résolution DNS
nslookup anpr.trapuce.tech
dig anpr.trapuce.tech
```

#### Problème SSL
```bash
# Renouveler le certificat
certbot renew --force-renewal
systemctl restart nginx
```

#### Problème d'application
```bash
# Vérifier les logs
journalctl -u anpr -n 50
```

### 📈 Monitoring

#### Vérification de santé
```bash
# Test de l'application
curl -I https://anpr.trapuce.tech
curl -I https://anpr.trapuce.tech/static/

# Test des services
systemctl is-active anpr
systemctl is-active nginx
```

#### Surveillance des ressources
```bash
# Utilisation CPU/Mémoire
htop
free -h
df -h

# Connexions réseau
netstat -tlnp | grep :80
netstat -tlnp | grep :443
netstat -tlnp | grep :8000
```

### 🔄 Mise à jour

Pour mettre à jour votre application :

```bash
# 1. Arrêter le service
systemctl stop anpr

# 2. Sauvegarder les données
cp -r /opt/anpr/plate_recognition/static/exports /tmp/backup-exports

# 3. Mettre à jour le code
cd /opt/anpr
git pull  # ou copier les nouveaux fichiers

# 4. Mettre à jour les dépendances
source venv/bin/activate
pip install -r requirements-prod.txt

# 5. Restaurer les données
cp -r /tmp/backup-exports/* /opt/anpr/plate_recognition/static/exports/

# 6. Redémarrer
systemctl start anpr
```

### 📞 Support

En cas de problème :
1. Vérifiez les logs : `journalctl -u anpr -f`
2. Testez les services : `systemctl status anpr nginx`
3. Vérifiez la configuration : `nginx -t`
4. Testez la connectivité : `curl -I https://anpr.trapuce.tech`

---

**🎉 Félicitations ! Votre application ANPR est maintenant déployée sur https://anpr.trapuce.tech**
