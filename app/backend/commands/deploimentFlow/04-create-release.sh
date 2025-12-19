#!/bin/bash
################################################################################
# Script: 04-create-release.sh
# Description: Crée une nouvelle release avec le build actuel
# Usage: ./04-create-release.sh <project_slug>
################################################################################

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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
RELEASES_DIR="$PROJECT_DIR/releases"
BUILD_DIR="${BUILD_DIR:-dist}"
MAX_RELEASES="${MAX_RELEASES:-5}"

# Générer un timestamp unique pour la release
RELEASE_ID=$(date +%Y%m%d-%H%M%S)
RELEASE_DIR="$RELEASES_DIR/$RELEASE_ID"

log_info "📦 Création d'une nouvelle release"
log_info "Projet: $PROJECT_SLUG"
log_info "Release ID: $RELEASE_ID"
log_info "Destination: $RELEASE_DIR"

################################################################################
# 1. Vérifications
################################################################################

log_info "🔍 Vérifications préalables..."

if [ ! -d "$REPO_DIR/$BUILD_DIR" ]; then
    log_error "Build introuvable: $REPO_DIR/$BUILD_DIR"
    log_error "Lancez d'abord: ./03-build-project.sh"
    exit 1
fi

log_info "✅ Build trouvé"

################################################################################
# 2. Créer le répertoire de release
################################################################################

log_info "📁 Création du répertoire de release..."

sudo -u "$DEPLOY_USER" mkdir -p "$RELEASE_DIR"

log_info "✅ Répertoire créé: $RELEASE_DIR"

################################################################################
# 3. Copier le build dans la release
################################################################################

log_info "📋 Copie du build..."

START_COPY=$(date +%s)

sudo -u "$DEPLOY_USER" rsync -a \
    --info=progress2 \
    "$REPO_DIR/$BUILD_DIR/" \
    "$RELEASE_DIR/"

END_COPY=$(date +%s)
COPY_TIME=$((END_COPY - START_COPY))

FILE_COUNT=$(find "$RELEASE_DIR" -type f | wc -l)
RELEASE_SIZE=$(du -sh "$RELEASE_DIR" | cut -f1)

log_info "✅ Build copié en ${COPY_TIME}s"
log_info "  • Fichiers: $FILE_COUNT"
log_info "  • Taille: $RELEASE_SIZE"

################################################################################
# 4. Créer les métadonnées de la release
################################################################################

METADATA_FILE="$RELEASE_DIR/.release-metadata.json"

log_info "📝 Création des métadonnées..."

COMMIT_HASH=$(cd "$REPO_DIR" && git rev-parse HEAD)
COMMIT_MSG=$(cd "$REPO_DIR" && git log -1 --pretty=format:"%s")
COMMIT_AUTHOR=$(cd "$REPO_DIR" && git log -1 --pretty=format:"%an")

cat > "$METADATA_FILE" <<EOF
{
  "release_id": "$RELEASE_ID",
  "project_slug": "$PROJECT_SLUG",
  "created_at": "$(date -Iseconds)",
  "commit": {
    "hash": "$COMMIT_HASH",
    "message": "$COMMIT_MSG",
    "author": "$COMMIT_AUTHOR"
  },
  "build": {
    "directory": "$BUILD_DIR",
    "file_count": $FILE_COUNT,
    "size": "$RELEASE_SIZE",
    "copy_duration_seconds": $COPY_TIME
  },
  "deployed": false,
  "deployed_at": null
}
EOF

chown "$DEPLOY_USER:www-data" "$METADATA_FILE"

log_info "✅ Métadonnées créées"

################################################################################
# 5. Nettoyer les anciennes releases
################################################################################

log_info "🧹 Nettoyage des anciennes releases (garder les $MAX_RELEASES plus récentes)..."

RELEASE_COUNT=$(ls -1d "$RELEASES_DIR"/*/ 2>/dev/null | wc -l)

if [ "$RELEASE_COUNT" -gt "$MAX_RELEASES" ]; then
    TO_DELETE=$((RELEASE_COUNT - MAX_RELEASES))
    log_warn "Nombre de releases: $RELEASE_COUNT (> $MAX_RELEASES)"
    log_warn "Suppression des $TO_DELETE releases les plus anciennes..."
    
    ls -1td "$RELEASES_DIR"/*/ | tail -n "$TO_DELETE" | while read -r old_release; do
        RELEASE_NAME=$(basename "$old_release")
        
        # Ne pas supprimer la release actuellement déployée
        if [ -L "$PROJECT_DIR/current" ]; then
            CURRENT_RELEASE=$(readlink -f "$PROJECT_DIR/current")
            if [ "$old_release" = "$CURRENT_RELEASE/" ]; then
                log_warn "⚠️  Sauter la release active: $RELEASE_NAME"
                continue
            fi
        fi
        
        log_info "Suppression: $RELEASE_NAME"
        sudo -u "$DEPLOY_USER" rm -rf "$old_release"
    done
    
    log_info "✅ Nettoyage terminé"
else
    log_info "✅ Pas de nettoyage nécessaire ($RELEASE_COUNT/$MAX_RELEASES releases)"
fi

################################################################################
# 6. Lister toutes les releases
################################################################################

log_info "📋 Releases disponibles:"

ls -1td "$RELEASES_DIR"/*/ 2>/dev/null | while read -r release_path; do
    RELEASE_NAME=$(basename "$release_path")
    RELEASE_SIZE=$(du -sh "$release_path" | cut -f1)
    
    # Marquer la release actuelle
    if [ -L "$PROJECT_DIR/current" ]; then
        CURRENT_RELEASE=$(readlink -f "$PROJECT_DIR/current")
        if [ "$release_path" = "$CURRENT_RELEASE/" ]; then
            log_info "  ✓ $RELEASE_NAME ($RELEASE_SIZE) [ACTIVE]"
            continue
        fi
    fi
    
    # Marquer la nouvelle release
    if [ "$RELEASE_NAME" = "$RELEASE_ID" ]; then
        log_info "  → $RELEASE_NAME ($RELEASE_SIZE) [NEW]"
    else
        log_info "    $RELEASE_NAME ($RELEASE_SIZE)"
    fi
done

################################################################################
# Résumé
################################################################################

log_info ""
log_info "╔════════════════════════════════════════════════════════╗"
log_info "║  ✅ Release créée avec succès !                       ║"
log_info "╚════════════════════════════════════════════════════════╝"
log_info ""
log_info "📊 Informations:"
log_info "  • Release ID: $RELEASE_ID"
log_info "  • Répertoire: $RELEASE_DIR"
log_info "  • Fichiers: $FILE_COUNT"
log_info "  • Taille: $RELEASE_SIZE"
log_info "  • Commit: $COMMIT_HASH"
log_info ""
log_info "🎯 Prochaine étape: Déployer la release"
log_info "   ./05-deploy-release.sh $PROJECT_SLUG $RELEASE_ID"

exit 0
