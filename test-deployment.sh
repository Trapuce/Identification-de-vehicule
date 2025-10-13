#!/bin/bash

# Script de test pour vérifier le déploiement anpr.trapuce.tech
set -e

DOMAIN="anpr.trapuce.tech"
IP_VPS=""  # Remplacez par l'IP de votre VPS

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

echo "🧪 Test de déploiement pour $DOMAIN"
echo "=================================="

# Test 1: Résolution DNS
log_step "1. Test de résolution DNS..."
if nslookup $DOMAIN > /dev/null 2>&1; then
    log_info "✅ DNS résolu correctement"
    nslookup $DOMAIN | grep "Address:"
else
    log_error "❌ Problème de résolution DNS"
    log_warn "Vérifiez votre configuration DNS"
fi

# Test 2: Connectivité HTTP
log_step "2. Test de connectivité HTTP..."
if curl -s -I http://$DOMAIN | grep -q "200 OK\|301\|302"; then
    log_info "✅ Serveur HTTP accessible"
else
    log_error "❌ Serveur HTTP inaccessible"
fi

# Test 3: Connectivité HTTPS
log_step "3. Test de connectivité HTTPS..."
if curl -s -I https://$DOMAIN | grep -q "200 OK"; then
    log_info "✅ Serveur HTTPS accessible"
else
    log_warn "⚠️  Serveur HTTPS non accessible (normal si pas encore configuré)"
fi

# Test 4: Redirection HTTP vers HTTPS
log_step "4. Test de redirection HTTP → HTTPS..."
REDIRECT=$(curl -s -I http://$DOMAIN | grep -i "location" | grep -i "https")
if [ ! -z "$REDIRECT" ]; then
    log_info "✅ Redirection HTTP → HTTPS configurée"
else
    log_warn "⚠️  Redirection HTTP → HTTPS non configurée"
fi

# Test 5: Certificat SSL
log_step "5. Test du certificat SSL..."
if openssl s_client -connect $DOMAIN:443 -servername $DOMAIN < /dev/null 2>/dev/null | grep -q "Verify return code: 0"; then
    log_info "✅ Certificat SSL valide"
else
    log_warn "⚠️  Certificat SSL non valide ou absent"
fi

# Test 6: Application Flask
log_step "6. Test de l'application Flask..."
if curl -s https://$DOMAIN | grep -q "ANPR\|Système de détection"; then
    log_info "✅ Application Flask accessible"
else
    log_warn "⚠️  Application Flask non accessible ou erreur"
fi

# Test 7: Fichiers statiques
log_step "7. Test des fichiers statiques..."
if curl -s -I https://$DOMAIN/static/ | grep -q "200 OK\|404"; then
    log_info "✅ Serveur de fichiers statiques configuré"
else
    log_warn "⚠️  Problème avec les fichiers statiques"
fi

echo ""
echo "📊 Résumé des tests :"
echo "===================="

# Résumé
DNS_OK=$(nslookup $DOMAIN > /dev/null 2>&1 && echo "✅" || echo "❌")
HTTP_OK=$(curl -s -I http://$DOMAIN | grep -q "200 OK\|301\|302" && echo "✅" || echo "❌")
HTTPS_OK=$(curl -s -I https://$DOMAIN | grep -q "200 OK" && echo "✅" || echo "❌")
APP_OK=$(curl -s https://$DOMAIN | grep -q "ANPR\|Système de détection" && echo "✅" || echo "❌")

echo "DNS Resolution:     $DNS_OK"
echo "HTTP Access:        $HTTP_OK"
echo "HTTPS Access:       $HTTPS_OK"
echo "Application:        $APP_OK"

echo ""
if [ "$DNS_OK" = "✅" ] && [ "$HTTP_OK" = "✅" ] && [ "$HTTPS_OK" = "✅" ] && [ "$APP_OK" = "✅" ]; then
    log_info "🎉 Déploiement réussi ! Votre application est accessible sur https://$DOMAIN"
else
    log_warn "⚠️  Certains tests ont échoué. Vérifiez la configuration."
fi

echo ""
echo "🔧 Commandes utiles :"
echo "===================="
echo "Voir les logs:      journalctl -u anpr -f"
echo "Redémarrer:         systemctl restart anpr"
echo "Statut:             systemctl status anpr"
echo "Test manuel:        curl -I https://$DOMAIN"
