#!/bin/bash
################################################################################
# Script: deploy-orchestrator.sh
# Description: Orchestre le déploiement complet en 4 phases
# Usage: ./deploy-orchestrator.sh <slug> <repo_url> <port>
################################################################################

set -euo pipefail

# Fonction de logging avec format standardisé
log_phase() {
    echo "[PHASE] $1"
}

log_info() {
    echo " $1"
}

log_success() {
    echo " $1"
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

if [ $# -lt 3 ] || [ $# -gt 6 ]; then
    log_error "Arguments manquants"
    log_info "Usage: $0 <slug> <repo_url> <port> [build_command] [node_version] [env_vars_json]"
    log_info "Exemple: $0 valentine https://github.com/user/project.git 3000"
    log_info "Exemple: $0 valentine https://github.com/user/project.git 3000 \"pnpm run build\" 22"
    log_info "Exemple: $0 valentine https://github.com/user/project.git 3000 \"npm run build\" 22 '{\"API_KEY\":\"123\"}'"
    exit 1
fi

SLUG="$1"
REPO_URL="$2"
PORT="$3"
BUILD_COMMAND="${4:-npm run build}"
NODE_VERSION="${5:-22}"
ENV_VARS_BASE64="${6:-}"

# Décoder les variables d'environnement depuis base64
if [ -n "$ENV_VARS_BASE64" ]; then
    ENV_VARS_JSON=$(echo "$ENV_VARS_BASE64" | base64 -d 2>/dev/null || echo "{}")
else
    ENV_VARS_JSON="{}"
fi

# Configuration
BASE_PATH="/var/www/project"
PROJECT_PATH="$BASE_PATH/$SLUG"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Afficher la configuration
log_info "═══════════════════════════════════════════════════════"
log_info " Déploiement automatisé - 4 phases"
log_info "═══════════════════════════════════════════════════════"
log_info "Projet: $SLUG"
log_info "Dépôt: $REPO_URL"
log_info "Port: $PORT"
log_info "Build: $BUILD_COMMAND"
log_info "Node.js: v$NODE_VERSION"
log_info "Destination: $PROJECT_PATH"
log_info "═══════════════════════════════════════════════════════"
echo ""

################################################################################
# PHASE 1: Création du projet et clonage
################################################################################

log_phase "1/4 - Création et clonage du projet"
log_info "────────────────────────────────────────────────────────"

if [ -f "$SCRIPT_DIR/1-create-project.sh" ]; then
    bash "$SCRIPT_DIR/1-create-project.sh" "$SLUG" "$REPO_URL" "$ENV_VARS_JSON" 2>&1
    
    if [ $? -eq 0 ]; then
        log_success "Projet en place"
    else
        log_error "Echec : Impossible de créer/cloner le projet"
        exit 1
    fi
else
    log_error "Script 1-create-project.sh introuvable"
    exit 1
fi

echo ""

################################################################################
# PHASE 2: Installation des dépendances
################################################################################

log_phase "2/4 - Installation des dépendances"
log_info "────────────────────────────────────────────────────────"

if [ -f "$SCRIPT_DIR/2-install-dependencies.sh" ]; then
    bash "$SCRIPT_DIR/2-install-dependencies.sh" "$PROJECT_PATH" "$NODE_VERSION" 2>&1
    
    if [ $? -eq 0 ]; then
        log_success "Dépendances installées"
    else
        log_error "Echec : Problème lors de l'installation"
        exit 1
    fi
else
    log_error "Script install-dependencies.sh introuvable"
    exit 1
fi

echo ""

################################################################################
# PHASE 3: Build du projet
################################################################################

log_phase "3/4 - Build de production"
log_info "────────────────────────────────────────────────────────"

if [ -f "$SCRIPT_DIR/3-build-project.sh" ]; then
    bash "$SCRIPT_DIR/3-build-project.sh" "$PROJECT_PATH" "$BUILD_COMMAND" 2>&1
    
    if [ $? -eq 0 ]; then
        log_success " Build réussi"
    else
        log_error "Echec : Erreur lors du build"
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

log_phase "4/4 - Environnement et  serveur"
log_info "────────────────────────────────────────────────────────"

if [ -f "$SCRIPT_DIR/4-dev-project.sh" ]; then
    # Note: dev-project.sh lance un processus en arrière-plan

# Générer le fichier .env via le script dédié
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    bash "$SCRIPT_DIR/4-dev-project.sh" "$PROJECT_PATH" "$PORT" 2>&1
    
    if [ $? -eq 0 ]; then
        log_success " Serveur démarré sur le port $PORT"
    else
        log_error "Echec : Impossible de démarrer le serveur"
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

# Obtenir l'IP locale
LOCAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
if [ -z "$LOCAL_IP" ]; then
  LOCAL_IP=$(ip route get 1 2>/dev/null | awk '{print $7; exit}')
fi
if [ -z "$LOCAL_IP" ]; then
  LOCAL_IP="localhost"
fi
DEPLOYMENT_URL="http://$LOCAL_IP:$PORT"

log_info "═══════════════════════════════════════════════════════"
log_success "DÉPLOIEMENT TERMINÉ AVEC SUCCÈS !"
log_info "═══════════════════════════════════════════════════════"
log_info " Projet: $SLUG"
log_info " Chemin: $PROJECT_PATH"
log_info " IP: $LOCAL_IP"
log_info " Port: $PORT"
log_info " URL: $DEPLOYMENT_URL"
log_info " Dépôt: $REPO_URL"
log_info "═══════════════════════════════════════════════════════"

# Émettre l'URL de déploiement pour que le serveur Node puisse la récupérer
echo "[DEPLOYMENT_URL] $DEPLOYMENT_URL"

exit 0
