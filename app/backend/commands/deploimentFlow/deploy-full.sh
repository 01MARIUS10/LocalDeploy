#!/bin/bash
################################################################################
# Script: deploy-full.sh
# Description: Script maître - Déploiement complet automatisé
# Usage: ./deploy-full.sh <project_slug> <repo_url> <branch> <domain>
################################################################################

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_step() { echo -e "${CYAN}[STEP]${NC} $1"; }

################################################################################
# Banner
################################################################################

show_banner() {
    echo -e "${BLUE}"
    cat <<'EOF'
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║        🚀  LocalDeploy - Déploiement Automatisé  🚀           ║
║                                                                ║
║     Déploiement automatique de projets React/Vue/Node.js      ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

################################################################################
# Validation des arguments
################################################################################

if [ $# -lt 4 ]; then
    show_banner
    log_error "Usage: $0 <project_slug> <repo_url> <branch> <domain> [port]"
    log_error ""
    log_error "Arguments:"
    log_error "  project_slug : Identifiant unique du projet (ex: monprojetreact)"
    log_error "  repo_url     : URL du dépôt Git (ex: https://github.com/user/repo.git)"
    log_error "  branch       : Branche à déployer (ex: main, master, develop)"
    log_error "  domain       : Nom de domaine local (ex: monprojet.local)"
    log_error "  port         : Port HTTP (optionnel, défaut: 80)"
    log_error ""
    log_error "Exemple:"
    log_error "  $0 monprojetreact https://github.com/user/MonProjetReact.git main monprojet.local 80"
    exit 1
fi

PROJECT_SLUG="$1"
REPO_URL="$2"
BRANCH="$3"
DOMAIN="$4"
PORT="${5:-80}"

show_banner

log_info "📋 Configuration du déploiement:"
log_info "  • Projet: $PROJECT_SLUG"
log_info "  • Dépôt: $REPO_URL"
log_info "  • Branche: $BRANCH"
log_info "  • Domaine: $DOMAIN"
log_info "  • Port: $PORT"
log_info ""

################################################################################
# Variables globales
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
START_TIME=$(date +%s)
LOG_FILE="/tmp/deploy-${PROJECT_SLUG}-$(date +%Y%m%d-%H%M%S).log"

# Rediriger tout vers le log ET l'écran
exec > >(tee -a "$LOG_FILE")
exec 2>&1

log_info "📄 Log du déploiement: $LOG_FILE"
log_info ""

################################################################################
# Fonction d'exécution sécurisée
################################################################################

run_step() {
    local step_num="$1"
    local step_name="$2"
    local script_name="$3"
    shift 3
    local args=("$@")
    
    log_step "════════════════════════════════════════════════════════"
    log_step "ÉTAPE $step_num: $step_name"
    log_step "════════════════════════════════════════════════════════"
    
    local step_start=$(date +%s)
    
    if [ -f "$SCRIPT_DIR/$script_name" ]; then
        chmod +x "$SCRIPT_DIR/$script_name"
        
        if "$SCRIPT_DIR/$script_name" "${args[@]}"; then
            local step_end=$(date +%s)
            local step_duration=$((step_end - step_start))
            log_info "✅ Étape $step_num terminée en ${step_duration}s"
            log_info ""
            return 0
        else
            local step_end=$(date +%s)
            local step_duration=$((step_end - step_start))
            log_error "❌ Échec à l'étape $step_num après ${step_duration}s"
            log_error "Consultez le log: $LOG_FILE"
            return 1
        fi
    else
        log_error "❌ Script introuvable: $SCRIPT_DIR/$script_name"
        return 1
    fi
}

################################################################################
# Fonction de rollback en cas d'erreur
################################################################################

cleanup_on_error() {
    log_error ""
    log_error "╔════════════════════════════════════════════════════════╗"
    log_error "║  ❌ ERREUR DÉTECTÉE - Nettoyage en cours...           ║"
    log_error "╚════════════════════════════════════════════════════════╝"
    log_error ""
    
    # Si une release était déployée, proposer un rollback
    if [ -f "$SCRIPT_DIR/08-rollback.sh" ]; then
        log_warn "💡 Vous pouvez restaurer la version précédente avec:"
        log_warn "   sudo $SCRIPT_DIR/08-rollback.sh $PROJECT_SLUG"
    fi
    
    log_error ""
    log_error "📄 Log complet: $LOG_FILE"
    exit 1
}

trap cleanup_on_error ERR

################################################################################
# Vérification des permissions
################################################################################

if [ "$EUID" -ne 0 ]; then
    log_error "Ce script doit être exécuté en tant que root"
    log_error "Utilisez: sudo $0 $*"
    exit 1
fi

################################################################################
# DÉPLOIEMENT - 8 ÉTAPES
################################################################################

log_info "🎬 Démarrage du déploiement..."
log_info ""

# ÉTAPE 0: Configuration de l'environnement (si première fois)
if [ ! -d "/var/projects/LocalDeploy" ]; then
    run_step "0" "Configuration de l'environnement serveur" \
        "00-setup-environment.sh"
fi

# ÉTAPE 1: Clonage du dépôt
run_step "1" "Clonage du dépôt Git" \
    "01-clone-repo.sh" "$PROJECT_SLUG" "$REPO_URL" "$BRANCH"

# ÉTAPE 2: Configuration des variables d'environnement
run_step "2" "Configuration des variables d'environnement" \
    "02-setup-env.sh" "$PROJECT_SLUG"

# ÉTAPE 3: Build du projet
run_step "3" "Build du projet (npm install && npm run build)" \
    "03-build-project.sh" "$PROJECT_SLUG"

# ÉTAPE 4: Création de la release
run_step "4" "Création de la release" \
    "04-create-release.sh" "$PROJECT_SLUG"

# Récupérer l'ID de la dernière release créée
PROJECT_DIR="/var/projects/LocalDeploy/$PROJECT_SLUG"
LATEST_RELEASE=$(ls -1t "$PROJECT_DIR/releases" | head -1)

# ÉTAPE 5: Déploiement de la release
run_step "5" "Déploiement de la release" \
    "05-deploy-release.sh" "$PROJECT_SLUG" "$LATEST_RELEASE"

# ÉTAPE 6: Configuration Nginx
run_step "6" "Configuration Nginx" \
    "06-setup-nginx.sh" "$PROJECT_SLUG" "$DOMAIN" "$PORT"

# ÉTAPE 7: Health Check
log_step "════════════════════════════════════════════════════════"
log_step "ÉTAPE 7: Health Check"
log_step "════════════════════════════════════════════════════════"

if [ -f "$SCRIPT_DIR/07-health-check.sh" ]; then
    chmod +x "$SCRIPT_DIR/07-health-check.sh"
    
    # Le health check peut retourner un code non-zéro, on ne veut pas arrêter le déploiement
    set +e
    "$SCRIPT_DIR/07-health-check.sh" "$PROJECT_SLUG" "$DOMAIN" "$PORT"
    HEALTH_EXIT_CODE=$?
    set -e
    
    if [ $HEALTH_EXIT_CODE -eq 0 ]; then
        log_info "✅ Health check: Tous les tests sont passés"
    elif [ $HEALTH_EXIT_CODE -eq 1 ]; then
        log_warn "⚠️  Health check: Quelques avertissements"
    else
        log_error "❌ Health check: Des problèmes ont été détectés"
        log_warn "Le déploiement continue malgré les erreurs de health check"
    fi
else
    log_warn "Script de health check introuvable, ignoré"
fi

log_info ""

################################################################################
# Résumé final
################################################################################

END_TIME=$(date +%s)
TOTAL_DURATION=$((END_TIME - START_TIME))
MINUTES=$((TOTAL_DURATION / 60))
SECONDS=$((TOTAL_DURATION % 60))

log_info ""
log_info "╔════════════════════════════════════════════════════════╗"
log_info "║                                                        ║"
log_info "║     ✅  DÉPLOIEMENT TERMINÉ AVEC SUCCÈS ! 🎉         ║"
log_info "║                                                        ║"
log_info "╚════════════════════════════════════════════════════════╝"
log_info ""
log_info "⏱️  Durée totale: ${MINUTES}m ${SECONDS}s"
log_info ""
log_info "📊 Informations du déploiement:"
log_info "  • Projet: $PROJECT_SLUG"
log_info "  • Release: $LATEST_RELEASE"
log_info "  • Branche: $BRANCH"
log_info "  • Domaine: $DOMAIN"
log_info "  • Port: $PORT"
log_info ""
log_info "🌐 URLs:"
log_info "  • Site: http://$DOMAIN:$PORT"
log_info "  • Health: http://$DOMAIN:$PORT/health"
log_info ""
log_info "📋 Logs:"
log_info "  • Déploiement: $LOG_FILE"
log_info "  • Nginx Access: /var/log/nginx/${PROJECT_SLUG}_access.log"
log_info "  • Nginx Error: /var/log/nginx/${PROJECT_SLUG}_error.log"
log_info ""
log_info "💡 Commandes utiles:"
log_info "  • Rollback: sudo $SCRIPT_DIR/08-rollback.sh $PROJECT_SLUG"
log_info "  • Health check: sudo $SCRIPT_DIR/07-health-check.sh $PROJECT_SLUG $DOMAIN $PORT"
log_info "  • Logs en temps réel: tail -f /var/log/nginx/${PROJECT_SLUG}_access.log"
log_info "  • Redéployer: sudo $0 $PROJECT_SLUG $REPO_URL $BRANCH $DOMAIN $PORT"
log_info ""
log_info "🎯 Prochain déploiement:"
log_info "  1. Modifiez votre code et commitez"
log_info "  2. Relancez ce script pour un nouveau déploiement"
log_info "  3. En cas de problème, utilisez le rollback"
log_info ""

exit 0
