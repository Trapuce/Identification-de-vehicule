#!/bin/bash

# Script de déploiement pour l'application de reconnaissance de plaques
# Usage: ./deploy.sh [start|stop|restart|logs|status]

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Vérifier que Docker et Docker Compose sont installés
check_dependencies() {
    log_info "Vérification des dépendances..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker n'est pas installé"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose n'est pas installé"
        exit 1
    fi
    
    log_success "Dépendances vérifiées"
}

# Créer les répertoires nécessaires
create_directories() {
    log_info "Création des répertoires nécessaires..."
    
    mkdir -p plate_recognition/uploads
    mkdir -p plate_recognition/static/exports
    
    log_success "Répertoires créés"
}

# Construire et démarrer les conteneurs
start_application() {
    log_info "Démarrage de l'application..."
    
    check_dependencies
    create_directories
    
    # Arrêter les conteneurs existants s'ils existent
    docker-compose down 2>/dev/null || true
    
    # Construire et démarrer
    docker-compose up --build -d
    
    log_success "Application démarrée avec succès!"
    log_info "L'application est accessible sur: http://anpr.trapuce.tech:8080"
    log_info "Interface d'administration: http://anpr.trapuce.tech:8080/admin (mot de passe: admin)"
}

# Arrêter l'application
stop_application() {
    log_info "Arrêt de l'application..."
    
    docker-compose down
    
    log_success "Application arrêtée"
}

# Redémarrer l'application
restart_application() {
    log_info "Redémarrage de l'application..."
    
    stop_application
    start_application
}

# Afficher les logs
show_logs() {
    log_info "Affichage des logs..."
    
    docker-compose logs -f
}

# Afficher le statut
show_status() {
    log_info "Statut des conteneurs:"
    
    docker-compose ps
    
    echo ""
    log_info "Vérification de la santé de l'application:"
    
    if curl -s -f http://localhost:8080/health > /dev/null; then
        log_success "Application accessible sur http://localhost:8080"
    else
        log_warning "Application non accessible sur http://localhost:8080"
    fi
}

# Nettoyer les ressources Docker
cleanup() {
    log_info "Nettoyage des ressources Docker..."
    
    docker-compose down -v
    docker system prune -f
    
    log_success "Nettoyage terminé"
}

# Afficher l'aide
show_help() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commandes disponibles:"
    echo "  start     - Démarrer l'application"
    echo "  stop      - Arrêter l'application"
    echo "  restart   - Redémarrer l'application"
    echo "  logs      - Afficher les logs"
    echo "  status    - Afficher le statut"
    echo "  cleanup   - Nettoyer les ressources Docker"
    echo "  help      - Afficher cette aide"
    echo ""
    echo "Exemples:"
    echo "  $0 start"
    echo "  $0 logs"
    echo "  $0 status"
}

# Gestion des arguments
case "${1:-help}" in
    start)
        start_application
        ;;
    stop)
        stop_application
        ;;
    restart)
        restart_application
        ;;
    logs)
        show_logs
        ;;
    status)
        show_status
        ;;
    cleanup)
        cleanup
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        log_error "Commande inconnue: $1"
        show_help
        exit 1
        ;;
esac
