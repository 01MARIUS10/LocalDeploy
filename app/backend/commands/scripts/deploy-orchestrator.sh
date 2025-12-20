#!/bin/bash
################################################################################
# Script: deploy-orchestrator.sh
# Description: Orchestre le déploiement complet en 4 phases
# Usage: ./deploy-orchestrator.sh <slug> <repo_url> <port>
################################################################################

set -euo pipefail

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Fonction de logging avec format standardisé
log_phase() {
    echo "[PHASE] $1"
}

log_info() {
    echo "[INFO] $1"
}

log_success() {
    echo "[SUCCESS] $1"
}

log_error() {
    echo "[ERROR] $1"
}

log_warn() {
    echo "[WARN] $1"
}

# Gestion des erreurs
trap 'catch_error $? $LINENO' ERR

catch_error() {
    local exit_code=$1
    local line_number=$2
    log_error "Une erreur s'est produite à la ligne $line_number (code: $exit_code)"
    log_error "Arrêt du déploiement"
    exit $exit_code
}

################################################################################
# Validation des arguments
################################################################################

if [ $# -ne 3 ]; then
    log_error "Arguments manquants"
    log_info "Usage: $0 <slug> <repo_url> <port>"
    log_info "Exemple: $0 valentine https://github.com/user/project.git 3000"
    exit 1
fi

SLUG="$1"
REPO_URL="$2"
PORT="$3"

# Configuration
BASE_PATH="/var/www/project"
PROJECT_PATH="$BASE_PATH/$SLUG"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Afficher la configuration
log_info "═══════════════════════════════════════════════════════"
log_info "🚀 Déploiement automatisé - 4 phases"
log_info "═══════════════════════════════════════════════════════"
log_info "Projet: $SLUG"
log_info "Dépôt: $REPO_URL"
log_info "Port: $PORT"
log_info "Destination: $PROJECT_PATH"
log_info "═══════════════════════════════════════════════════════"
echo ""

################################################################################
# PHASE 1: Création du projet
################################################################################

log_phase "1/4 - Création du dossier projet"
log_info "────────────────────────────────────────────────────────"

if [ -f "$SCRIPT_DIR/create-project.sh" ]; then
    bash "$SCRIPT_DIR/create-project.sh" "$SLUG" 2>&1
    
    if [ $? -eq 0 ]; then
        log_success "Phase 1 terminée : Dossier créé"
    else
        log_error "Phase 1 échouée : Impossible de créer le dossier"
        exit 1
    fi
else
    log_error "Script create-project.sh introuvable"
    exit 1
fi

echo ""

################################################################################
# PHASE 2: Clone et installation des dépendances
################################################################################

log_phase "2/4 - Clone du dépôt et installation"
log_info "────────────────────────────────────────────────────────"

if [ -f "$SCRIPT_DIR/clone-and-install.sh" ]; then
    bash "$SCRIPT_DIR/clone-and-install.sh" "$PROJECT_PATH" "$REPO_URL" 2>&1
    
    if [ $? -eq 0 ]; then
        log_success "Phase 2 terminée : Code cloné et dépendances installées"
    else
        log_error "Phase 2 échouée : Problème lors du clone/installation"
        exit 1
    fi
else
    log_error "Script clone-and-install.sh introuvable"
    exit 1
fi

echo ""

################################################################################
# PHASE 3: Build du projet
################################################################################

log_phase "3/4 - Build de production"
log_info "────────────────────────────────────────────────────────"

if [ -f "$SCRIPT_DIR/build-project.sh" ]; then
    bash "$SCRIPT_DIR/build-project.sh" "$PROJECT_PATH" 2>&1
    
    if [ $? -eq 0 ]; then
        log_success "Phase 3 terminée : Build réussi"
    else
        log_error "Phase 3 échouée : Erreur lors du build"
        exit 1
    fi
else
    log_error "Script build-project.sh introuvable"
    exit 1
fi

echo ""

################################################################################
# PHASE 4: Démarrage du serveur de développement
################################################################################

log_phase "4/4 - Démarrage du serveur"
log_info "────────────────────────────────────────────────────────"

if [ -f "$SCRIPT_DIR/dev-project.sh" ]; then
    # Note: dev-project.sh lance un processus en arrière-plan
    bash "$SCRIPT_DIR/dev-project.sh" "$PROJECT_PATH" "$PORT" 2>&1
    
    if [ $? -eq 0 ]; then
        log_success "Phase 4 terminée : Serveur démarré sur le port $PORT"
    else
        log_error "Phase 4 échouée : Impossible de démarrer le serveur"
        exit 1
    fi
else
    log_error "Script dev-project.sh introuvable"
    exit 1
fi

echo ""

################################################################################
# Résumé final
################################################################################

log_info "═══════════════════════════════════════════════════════"
log_success "✅ DÉPLOIEMENT TERMINÉ AVEC SUCCÈS !"
log_info "═══════════════════════════════════════════════════════"
log_info "📦 Projet: $SLUG"
log_info "📁 Chemin: $PROJECT_PATH"
log_info "🌐 URL: http://localhost:$PORT"
log_info "🔗 Dépôt: $REPO_URL"
log_info "═══════════════════════════════════════════════════════"
log_info ""
log_info "💡 Commandes utiles:"
log_info "  • Logs: pm2 logs $SLUG"
log_info "  • Status: pm2 status"
log_info "  • Stop: pm2 stop $SLUG"
log_info "  • Restart: pm2 restart $SLUG"
log_info "═══════════════════════════════════════════════════════"

exit 0
