#!/bin/bash

# Script de déploiement optimisé pour VPS
# Gère les timeouts et les ressources limitées

# Variables
APP_NAME="plate-recognition"
COMPOSE_FILE="docker-compose.yml"

# Couleurs pour les messages
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Configuration pour VPS
export COMPOSE_HTTP_TIMEOUT=300
export COMPOSE_PARALLEL_LIMIT=2

check_docker() {
    log_info "Vérification de Docker et Docker Compose..."
    if ! command -v docker &> /dev/null; then
        log_error "Docker n'est pas installé. Veuillez l'installer d'abord."
        exit 1
    fi
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose n'est pas installé. Veuillez l'installer d'abord."
        exit 1
    fi
    log_success "Docker et Docker Compose sont installés."
}

check_resources() {
    log_info "Vérification des ressources système..."
    
    # Vérifier la mémoire disponible
    MEMORY_GB=$(free -g | awk 'NR==2{printf "%.1f", $7/1024}')
    MEMORY_INT=$(echo "$MEMORY_GB" | cut -d. -f1)
    if [ "$MEMORY_INT" -lt 2 ]; then
        log_warning "Mémoire disponible: ${MEMORY_GB}GB (recommandé: 2GB+)"
    else
        log_success "Mémoire disponible: ${MEMORY_GB}GB"
    fi
    
    # Vérifier l'espace disque
    DISK_GB=$(df -BG . | awk 'NR==2{print $4}' | sed 's/G//')
    if [ "$DISK_GB" -lt 5 ]; then
        log_warning "Espace disque disponible: ${DISK_GB}GB (recommandé: 5GB+)"
    else
        log_success "Espace disque disponible: ${DISK_GB}GB"
    fi
}

cleanup_containers() {
    log_info "Nettoyage des conteneurs existants..."
    docker-compose down --remove-orphans 2>/dev/null || true
    docker system prune -f
    log_success "Nettoyage terminé"
}

create_directories() {
    log_info "Création des répertoires nécessaires..."
    mkdir -p plate_recognition/uploads
    mkdir -p plate_recognition/static/exports
    mkdir -p data/db
    log_success "Répertoires créés"
}

start_app_vps() {
    log_info "Démarrage de l'application sur VPS..."
    
    check_docker
    check_resources
    cleanup_containers
    create_directories
    
    log_info "Construction de l'image Docker (peut prendre plusieurs minutes)..."
    
    # Construction avec timeout étendu
    timeout 600 docker-compose build --no-cache || {
        log_error "Timeout lors de la construction. Essayez de redémarrer avec plus de ressources."
        exit 1
    }
    
    log_info "Démarrage des conteneurs..."
    
    # Démarrage avec timeout étendu
    timeout 300 docker-compose up -d || {
        log_error "Timeout lors du démarrage. Vérifiez les logs."
        docker-compose logs
        exit 1
    }
    
    # Attendre que l'application soit prête
    log_info "Attente du démarrage de l'application..."
    sleep 30
    
    # Vérifier que l'application répond
    for i in {1..10}; do
        if curl -f http://localhost:8080/health &>/dev/null; then
            log_success "Application démarrée avec succès!"
            log_info "L'application est accessible sur: http://anpr.trapuce.tech:8080"
            log_info "Interface d'administration: http://anpr.trapuce.tech:8080/admin (mot de passe: admin)"
            return 0
        fi
        log_info "Tentative $i/10 - Attente du démarrage..."
        sleep 10
    done
    
    log_error "L'application ne répond pas après 2 minutes"
    log_info "Vérifiez les logs: docker-compose logs"
    exit 1
}

stop_app() {
    log_info "Arrêt de l'application..."
    docker-compose down
    if [ $? -eq 0 ]; then
        log_success "Application arrêtée."
    else
        log_error "Échec de l'arrêt de l'application."
        exit 1
    fi
}

restart_app() {
    log_info "Redémarrage de l'application..."
    stop_app
    sleep 5
    start_app_vps
}

show_logs() {
    log_info "Affichage des logs de l'application (Ctrl+C pour quitter)..."
    docker-compose logs -f
}

show_status() {
    log_info "Statut des conteneurs:"
    docker-compose ps
    
    log_info "Utilisation des ressources:"
    docker stats --no-stream
}

# Main logic
case "$1" in
    start)
        start_app_vps
        ;;
    stop)
        stop_app
        ;;
    restart)
        restart_app
        ;;
    logs)
        show_logs
        ;;
    status)
        show_status
        ;;
    cleanup)
        cleanup_containers
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|logs|status|cleanup}"
        echo ""
        echo "Commandes:"
        echo "  start   - Démarrer l'application (optimisé pour VPS)"
        echo "  stop    - Arrêter l'application"
        echo "  restart - Redémarrer l'application"
        echo "  logs    - Afficher les logs"
        echo "  status  - Afficher le statut et les ressources"
        echo "  cleanup - Nettoyer les conteneurs et images"
        exit 1
        ;;
esac
