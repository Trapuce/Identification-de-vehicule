# 🌐 Configuration DNS pour anpr.trapuce.tech

## 📋 Configuration requise

Pour que votre application fonctionne sur `anpr.trapuce.tech`, vous devez configurer les enregistrements DNS suivants :

### 🔧 Enregistrements DNS à ajouter

Dans votre panneau de contrôle DNS (chez votre registrar ou hébergeur DNS) :

```
Type    Nom                    Valeur              TTL
A       anpr.trapuce.tech      IP_DE_VOTRE_VPS     300
CNAME   www.anpr.trapuce.tech  anpr.trapuce.tech   300
```

### 📝 Exemple de configuration

Si l'IP de votre VPS est `192.168.1.100` :

```
Type    Nom                    Valeur              TTL
A       anpr.trapuce.tech      192.168.1.100       300
CNAME   www.anpr.trapuce.tech  anpr.trapuce.tech   300
```

### 🔍 Vérification DNS

Après avoir configuré le DNS, vérifiez avec ces commandes :

```bash
# Vérifier la résolution DNS
nslookup anpr.trapuce.tech
dig anpr.trapuce.tech

# Tester la connectivité
ping anpr.trapuce.tech
curl -I http://anpr.trapuce.tech
```

### ⏱️ Propagation DNS

- **TTL 300** : Propagation en ~5 minutes
- **TTL 3600** : Propagation en ~1 heure
- **TTL 86400** : Propagation en ~24 heures

### 🚨 Dépannage DNS

#### Si le sous-domaine ne fonctionne pas :

1. **Vérifiez la configuration DNS**
   ```bash
   dig anpr.trapuce.tech
   ```

2. **Vérifiez la propagation**
   - Utilisez des outils en ligne : whatsmydns.net
   - Testez depuis différents serveurs DNS

3. **Vérifiez le serveur web**
   ```bash
   # Sur votre VPS
   nginx -t
   systemctl status nginx
   ```

### 📊 Configuration avancée

#### Pour plusieurs sous-domaines :

```
Type    Nom                    Valeur              TTL
A       anpr.trapuce.tech      IP_VPS              300
A       api.trapuce.tech       IP_VPS              300
A       admin.trapuce.tech     IP_VPS              300
```

#### Avec CDN (Cloudflare) :

```
Type    Nom                    Valeur              TTL    Proxy
A       anpr.trapuce.tech      IP_VPS              300    🟠 Proxied
CNAME   www.anpr.trapuce.tech  anpr.trapuce.tech   300    🟠 Proxied
```

### 🔒 SSL pour sous-domaine

Le script de déploiement configurera automatiquement SSL pour `anpr.trapuce.tech` :

```bash
# Le certificat sera généré automatiquement
certbot --nginx -d anpr.trapuce.tech
```

### 📱 Test final

Une fois le DNS configuré et l'application déployée :

```bash
# Test HTTP
curl -I http://anpr.trapuce.tech

# Test HTTPS
curl -I https://anpr.trapuce.tech

# Test dans le navigateur
# Ouvrez : https://anpr.trapuce.tech
```

---

**🎯 Résultat attendu :**
- **URL** : https://anpr.trapuce.tech
- **SSL** : Certificat Let's Encrypt automatique
- **Redirection** : HTTP → HTTPS automatique
