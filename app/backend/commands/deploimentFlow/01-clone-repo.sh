#!/bin/bash
################################################################################
# Script: 01-clone-repo.sh
# Description: Clone ou met à jour le dépôt Git du projet
# Usage: ./01-clone-repo.sh <project_slug> <repo_url> <branch>
################################################################################

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_debug() { echo -e "${BLUE}[DEBUG]${NC} $1"; }

################################################################################
# Validation des arguments
################################################################################

if [ $# -lt 3 ]; then
    log_error "Usage: $0 <project_slug> <repo_url> <branch>"
    log_error "Exemple: $0 monprojetreact https://github.com/user/repo.git main"
    exit 1
fi

PROJECT_SLUG="$1"
REPO_URL="$2"
BRANCH="$3"

# Configuration
DEPLOY_USER="${DEPLOY_USER:-deployuser}"
PROJECT_BASE="${PROJECT_BASE:-/var/projects/LocalDeploy}"
PROJECT_DIR="$PROJECT_BASE/$PROJECT_SLUG"
REPO_DIR="$PROJECT_DIR/repo"

log_info "🔄 Clonage/Mise à jour du dépôt Git"
log_info "Projet: $PROJECT_SLUG"
log_info "URL: $REPO_URL"
log_info "Branche: $BRANCH"
log_info "Destination: $REPO_DIR"

################################################################################
# 1. Créer la structure de répertoires
################################################################################

log_info "📁 Création de la structure de répertoires..."

sudo -u "$DEPLOY_USER" mkdir -p "$PROJECT_DIR"/{repo,releases,shared,logs}

log_info "✅ Structure créée:"
log_info "  • $PROJECT_DIR/repo         (clone Git)"
log_info "  • $PROJECT_DIR/releases     (historique des releases)"
log_info "  • $PROJECT_DIR/shared       (fichiers partagés: .env, uploads...)"
log_info "  • $PROJECT_DIR/logs         (logs de déploiement)"

################################################################################
# 2. Cloner ou mettre à jour le dépôt
################################################################################

if [ -d "$REPO_DIR/.git" ]; then
    log_info "📦 Dépôt existant trouvé, mise à jour..."
    
    cd "$REPO_DIR"
    
    # Sauvegarder les modifications locales (si besoin)
    if ! sudo -u "$DEPLOY_USER" git diff-index --quiet HEAD --; then
        log_warn "Des modifications locales détectées, création d'un stash..."
        sudo -u "$DEPLOY_USER" git stash save "Auto-stash avant déploiement $(date +%Y%m%d-%H%M%S)"
    fi
    
    # Fetch les dernières modifications
    log_info "Récupération des dernières modifications..."
    sudo -u "$DEPLOY_USER" git fetch origin --prune
    
    # Checkout la branche
    log_info "Basculement vers la branche $BRANCH..."
    sudo -u "$DEPLOY_USER" git checkout "$BRANCH" 2>/dev/null || \
        sudo -u "$DEPLOY_USER" git checkout -b "$BRANCH" "origin/$BRANCH"
    
    # Pull les dernières modifications
    log_info "Mise à jour de la branche..."
    sudo -u "$DEPLOY_USER" git reset --hard "origin/$BRANCH"
    
    COMMIT_HASH=$(git rev-parse HEAD)
    COMMIT_MSG=$(git log -1 --pretty=format:"%s")
    
    log_info "✅ Dépôt mis à jour"
    log_info "  Commit: $COMMIT_HASH"
    log_info "  Message: $COMMIT_MSG"
    
else
    log_info "📦 Clonage du dépôt pour la première fois..."
    
    # Cloner avec --depth=1 pour gagner du temps (shallow clone)
    sudo -u "$DEPLOY_USER" git clone \
        --depth=1 \
        --branch "$BRANCH" \
        --single-branch \
        "$REPO_URL" \
        "$REPO_DIR"
    
    cd "$REPO_DIR"
    
    # Configuration Git
    sudo -u "$DEPLOY_USER" git config pull.rebase false
    sudo -u "$DEPLOY_USER" git config core.filemode false
    
    COMMIT_HASH=$(git rev-parse HEAD)
    COMMIT_MSG=$(git log -1 --pretty=format:"%s")
    
    log_info "✅ Dépôt cloné avec succès"
    log_info "  Commit: $COMMIT_HASH"
    log_info "  Message: $COMMIT_MSG"
fi

################################################################################
# 3. Vérifications post-clone
################################################################################

log_info "🔍 Vérifications..."

# Vérifier package.json
if [ -f "$REPO_DIR/package.json" ]; then
    log_info "✅ package.json trouvé"
    
    # Extraire le nom et la version du projet
    PROJECT_NAME=$(jq -r '.name // "unknown"' "$REPO_DIR/package.json")
    PROJECT_VERSION=$(jq -r '.version // "0.0.0"' "$REPO_DIR/package.json")
    
    log_info "  Nom: $PROJECT_NAME"
    log_info "  Version: $PROJECT_VERSION"
else
    log_warn "⚠️  package.json non trouvé (pas un projet Node.js?)"
fi

# Lister les fichiers principaux
log_info "📄 Fichiers à la racine:"
ls -lh "$REPO_DIR" | grep -E '^-' | awk '{print "  • " $9 " (" $5 ")"}'

################################################################################
# 4. Sauvegarder les informations du clone
################################################################################

CLONE_INFO_FILE="$PROJECT_DIR/logs/clone-info.json"

cat > "$CLONE_INFO_FILE" <<EOF
{
  "project_slug": "$PROJECT_SLUG",
  "repository_url": "$REPO_URL",
  "branch": "$BRANCH",
  "commit_hash": "$COMMIT_HASH",
  "commit_message": "$COMMIT_MSG",
  "cloned_at": "$(date -Iseconds)",
  "repo_directory": "$REPO_DIR"
}
EOF

chown "$DEPLOY_USER:www-data" "$CLONE_INFO_FILE"

log_info "✅ Informations sauvegardées dans $CLONE_INFO_FILE"

################################################################################
# Résumé
################################################################################

log_info ""
log_info "╔════════════════════════════════════════════════════════╗"
log_info "║  ✅ Clonage terminé avec succès !                     ║"
log_info "╚════════════════════════════════════════════════════════╝"
log_info ""
log_info "📊 Informations:"
log_info "  • Dépôt: $REPO_URL"
log_info "  • Branche: $BRANCH"
log_info "  • Commit: $COMMIT_HASH"
log_info "  • Répertoire: $REPO_DIR"
log_info ""
log_info "🎯 Prochaine étape: Créer le fichier .env"
log_info "   ./02-setup-env.sh $PROJECT_SLUG"

exit 0
