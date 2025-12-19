#!/bin/bash
################################################################################
# Script: 03-build-project.sh
# Description: Build le projet (npm install && npm run build)
# Usage: ./03-build-project.sh <project_slug>
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

################################################################################
# Validation des arguments
################################################################################

if [ $# -lt 1 ]; then
    log_error "Usage: $0 <project_slug>"
    log_error "Exemple: $0 monprojetreact"
    exit 1
fi

PROJECT_SLUG="$1"

# Configuration
DEPLOY_USER="${DEPLOY_USER:-deployuser}"
PROJECT_BASE="${PROJECT_BASE:-/var/projects/LocalDeploy}"
PROJECT_DIR="$PROJECT_BASE/$PROJECT_SLUG"
REPO_DIR="$PROJECT_DIR/repo"
ENV_FILE="$PROJECT_DIR/shared/.env"
BUILD_DIR="${BUILD_DIR:-dist}"
LOG_FILE="$PROJECT_DIR/logs/build-$(date +%Y%m%d-%H%M%S).log"

log_info "🔨 Build du projet"
log_info "Projet: $PROJECT_SLUG"
log_info "Répertoire: $REPO_DIR"
log_info "Log: $LOG_FILE"

################################################################################
# 1. Vérifications préalables
################################################################################

log_info "🔍 Vérifications préalables..."

# Vérifier que le dépôt existe
if [ ! -d "$REPO_DIR" ]; then
    log_error "Dépôt introuvable: $REPO_DIR"
    log_error "Lancez d'abord: ./01-clone-repo.sh"
    exit 1
fi

# Vérifier package.json
if [ ! -f "$REPO_DIR/package.json" ]; then
    log_error "package.json introuvable dans $REPO_DIR"
    exit 1
fi

log_info "✅ Dépôt trouvé"

# Vérifier Node.js
NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)
log_info "✅ Node.js $NODE_VERSION"
log_info "✅ npm $NPM_VERSION"

################################################################################
# 2. Nettoyer les builds précédents
################################################################################

log_info "🧹 Nettoyage des builds précédents..."

cd "$REPO_DIR"

if [ -d "node_modules" ]; then
    log_warn "Suppression de node_modules existant..."
    sudo -u "$DEPLOY_USER" rm -rf node_modules
fi

if [ -d "$BUILD_DIR" ]; then
    log_warn "Suppression du build précédent..."
    sudo -u "$DEPLOY_USER" rm -rf "$BUILD_DIR"
fi

log_info "✅ Nettoyage terminé"

################################################################################
# 3. Charger les variables d'environnement
################################################################################

if [ -f "$ENV_FILE" ]; then
    log_info "🔐 Chargement des variables d'environnement..."
    set -a
    source "$ENV_FILE"
    set +a
    log_info "✅ Variables chargées"
else
    log_warn "⚠️  Fichier .env introuvable, build sans variables d'environnement"
fi

################################################################################
# 4. Installation des dépendances
################################################################################

log_info "📦 Installation des dépendances..."

START_INSTALL=$(date +%s)

sudo -u "$DEPLOY_USER" bash -c "
    cd '$REPO_DIR'
    npm ci --production=false 2>&1 | tee -a '$LOG_FILE'
" || {
    log_error "❌ Échec de npm install"
    log_error "Consultez le log: $LOG_FILE"
    exit 1
}

END_INSTALL=$(date +%s)
INSTALL_TIME=$((END_INSTALL - START_INSTALL))

log_info "✅ Dépendances installées en ${INSTALL_TIME}s"

################################################################################
# 5. Build du projet
################################################################################

log_info "🏗️  Build du projet..."

# Détecter le script de build
BUILD_SCRIPT="build"

if jq -e '.scripts.build' "$REPO_DIR/package.json" > /dev/null 2>&1; then
    log_info "Script de build trouvé: npm run build"
else
    log_error "Aucun script 'build' trouvé dans package.json"
    exit 1
fi

START_BUILD=$(date +%s)

sudo -u "$DEPLOY_USER" bash -c "
    cd '$REPO_DIR'
    
    # Charger les variables d'environnement
    if [ -f '$ENV_FILE' ]; then
        set -a
        source '$ENV_FILE'
        set +a
    fi
    
    # Lancer le build
    npm run $BUILD_SCRIPT 2>&1 | tee -a '$LOG_FILE'
" || {
    log_error "❌ Échec du build"
    log_error "Consultez le log: $LOG_FILE"
    exit 1
}

END_BUILD=$(date +%s)
BUILD_TIME=$((END_BUILD - START_BUILD))

log_info "✅ Build terminé en ${BUILD_TIME}s"

################################################################################
# 6. Vérifier le résultat du build
################################################################################

log_info "🔍 Vérification du build..."

if [ ! -d "$REPO_DIR/$BUILD_DIR" ]; then
    log_error "Répertoire de build introuvable: $REPO_DIR/$BUILD_DIR"
    log_error "Le script de build a peut-être échoué ou utilise un autre répertoire"
    exit 1
fi

# Compter les fichiers
FILE_COUNT=$(find "$REPO_DIR/$BUILD_DIR" -type f | wc -l)
BUILD_SIZE=$(du -sh "$REPO_DIR/$BUILD_DIR" | cut -f1)

log_info "✅ Build vérifié:"
log_info "  • Répertoire: $BUILD_DIR"
log_info "  • Fichiers: $FILE_COUNT"
log_info "  • Taille: $BUILD_SIZE"

# Lister les fichiers principaux
log_info "📄 Fichiers principaux:"
find "$REPO_DIR/$BUILD_DIR" -maxdepth 1 -type f -exec basename {} \; | head -10 | while read -r file; do
    log_info "  • $file"
done

################################################################################
# 7. Créer un manifeste de build
################################################################################

MANIFEST_FILE="$REPO_DIR/$BUILD_DIR/build-manifest.json"

log_info "📝 Création du manifeste de build..."

COMMIT_HASH=$(cd "$REPO_DIR" && git rev-parse HEAD)
COMMIT_MSG=$(cd "$REPO_DIR" && git log -1 --pretty=format:"%s")

cat > "$MANIFEST_FILE" <<EOF
{
  "project_slug": "$PROJECT_SLUG",
  "build_date": "$(date -Iseconds)",
  "build_duration_seconds": $((INSTALL_TIME + BUILD_TIME)),
  "install_duration_seconds": $INSTALL_TIME,
  "compile_duration_seconds": $BUILD_TIME,
  "node_version": "$NODE_VERSION",
  "npm_version": "$NPM_VERSION",
  "commit_hash": "$COMMIT_HASH",
  "commit_message": "$COMMIT_MSG",
  "build_directory": "$BUILD_DIR",
  "file_count": $FILE_COUNT,
  "build_size": "$BUILD_SIZE"
}
EOF

chown "$DEPLOY_USER:www-data" "$MANIFEST_FILE"

log_info "✅ Manifeste créé: $MANIFEST_FILE"

################################################################################
# Résumé
################################################################################

log_info ""
log_info "╔════════════════════════════════════════════════════════╗"
log_info "║  ✅ Build terminé avec succès !                       ║"
log_info "╚════════════════════════════════════════════════════════╝"
log_info ""
log_info "📊 Statistiques:"
log_info "  • Installation: ${INSTALL_TIME}s"
log_info "  • Compilation: ${BUILD_TIME}s"
log_info "  • Total: $((INSTALL_TIME + BUILD_TIME))s"
log_info "  • Fichiers: $FILE_COUNT"
log_info "  • Taille: $BUILD_SIZE"
log_info ""
log_info "📁 Résultat: $REPO_DIR/$BUILD_DIR"
log_info "📋 Log: $LOG_FILE"
log_info ""
log_info "🎯 Prochaine étape: Créer une release"
log_info "   ./04-create-release.sh $PROJECT_SLUG"

exit 0
