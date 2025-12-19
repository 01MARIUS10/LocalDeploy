#!/bin/bash
################################################################################
# Script: 05-deploy-release.sh
# Description: Déploie une release en production (déploiement atomique)
# Usage: ./05-deploy-release.sh <project_slug> <release_id>
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

if [ $# -lt 2 ]; then
    log_error "Usage: $0 <project_slug> <release_id>"
    log_error "Exemple: $0 monprojetreact 20240115-143022"
    exit 1
fi

PROJECT_SLUG="$1"
RELEASE_ID="$2"

# Configuration
DEPLOY_USER="${DEPLOY_USER:-deployuser}"
PROJECT_BASE="${PROJECT_BASE:-/var/projects/LocalDeploy}"
PROJECT_DIR="$PROJECT_BASE/$PROJECT_SLUG"
RELEASES_DIR="$PROJECT_DIR/releases"
RELEASE_DIR="$RELEASES_DIR/$RELEASE_ID"
CURRENT_LINK="$PROJECT_DIR/current"
PREVIOUS_LINK="$PROJECT_DIR/previous"

log_info "🚀 Déploiement de la release"
log_info "Projet: $PROJECT_SLUG"
log_info "Release: $RELEASE_ID"

################################################################################
# 1. Vérifications
################################################################################

log_info "🔍 Vérifications préalables..."

if [ ! -d "$RELEASE_DIR" ]; then
    log_error "Release introuvable: $RELEASE_DIR"
    log_error "Releases disponibles:"
    ls -1 "$RELEASES_DIR" 2>/dev/null || log_error "Aucune release trouvée"
    exit 1
fi

log_info "✅ Release trouvée: $RELEASE_DIR"

# Vérifier qu'il y a des fichiers dans la release
FILE_COUNT=$(find "$RELEASE_DIR" -type f | wc -l)
if [ "$FILE_COUNT" -eq 0 ]; then
    log_error "Release vide, aucun fichier trouvé"
    exit 1
fi

log_info "✅ $FILE_COUNT fichiers dans la release"

################################################################################
# 2. Sauvegarder le lien précédent
################################################################################

if [ -L "$CURRENT_LINK" ]; then
    CURRENT_TARGET=$(readlink -f "$CURRENT_LINK")
    CURRENT_RELEASE=$(basename "$CURRENT_TARGET")
    
    log_info "📌 Sauvegarde de la release actuelle: $CURRENT_RELEASE"
    
    # Créer ou mettre à jour le lien "previous"
    sudo -u "$DEPLOY_USER" ln -sfn "$CURRENT_TARGET" "$PREVIOUS_LINK"
    
    log_info "✅ Lien 'previous' créé pour rollback éventuel"
else
    log_warn "Aucune release précédente (premier déploiement)"
fi

################################################################################
# 3. Déploiement atomique avec symlink
################################################################################

log_info "🔄 Déploiement atomique..."

# Créer le symlink temporaire
TEMP_LINK="$PROJECT_DIR/.current.tmp.$$"

sudo -u "$DEPLOY_USER" ln -sfn "$RELEASE_DIR" "$TEMP_LINK"

# Remplacer atomiquement le symlink (opération atomique sur Linux)
sudo -u "$DEPLOY_USER" mv -fT "$TEMP_LINK" "$CURRENT_LINK"

log_info "✅ Déploiement atomique effectué"

################################################################################
# 4. Mettre à jour les métadonnées
################################################################################

METADATA_FILE="$RELEASE_DIR/.release-metadata.json"

if [ -f "$METADATA_FILE" ]; then
    log_info "📝 Mise à jour des métadonnées..."
    
    # Ajouter la date de déploiement
    jq '. + {deployed: true, deployed_at: "'$(date -Iseconds)'"}' "$METADATA_FILE" > "${METADATA_FILE}.tmp"
    mv "${METADATA_FILE}.tmp" "$METADATA_FILE"
    chown "$DEPLOY_USER:www-data" "$METADATA_FILE"
    
    log_info "✅ Métadonnées mises à jour"
fi

################################################################################
# 5. Vérifications post-déploiement
################################################################################

log_info "🔍 Vérifications post-déploiement..."

# Vérifier que le symlink pointe vers la bonne release
DEPLOYED_TARGET=$(readlink -f "$CURRENT_LINK")
DEPLOYED_RELEASE=$(basename "$DEPLOYED_TARGET")

if [ "$DEPLOYED_RELEASE" = "$RELEASE_ID" ]; then
    log_info "✅ Symlink 'current' pointe vers $RELEASE_ID"
else
    log_error "❌ Erreur: Symlink pointe vers $DEPLOYED_RELEASE au lieu de $RELEASE_ID"
    exit 1
fi

# Vérifier l'accès aux fichiers
if [ -r "$CURRENT_LINK/index.html" ]; then
    log_info "✅ Fichier index.html accessible"
elif [ -r "$CURRENT_LINK/200.html" ]; then
    log_info "✅ Fichier 200.html accessible (SPA)"
else
    log_warn "⚠️  Aucun fichier index.html ou 200.html trouvé"
fi

################################################################################
# 6. Créer un historique de déploiement
################################################################################

DEPLOY_LOG="$PROJECT_DIR/logs/deploy-history.log"

log_info "📋 Enregistrement dans l'historique..."

COMMIT_HASH="N/A"
if [ -f "$METADATA_FILE" ]; then
    COMMIT_HASH=$(jq -r '.commit.hash // "N/A"' "$METADATA_FILE")
fi

echo "[$(date -Iseconds)] DEPLOY $PROJECT_SLUG $RELEASE_ID (commit: $COMMIT_HASH)" >> "$DEPLOY_LOG"

log_info "✅ Historique mis à jour"

################################################################################
# 7. Résumé des releases
################################################################################

log_info "📊 État des releases:"

# Release actuelle
log_info "  ✓ CURRENT  → $DEPLOYED_RELEASE"

# Release précédente (pour rollback)
if [ -L "$PREVIOUS_LINK" ]; then
    PREVIOUS_TARGET=$(readlink -f "$PREVIOUS_LINK")
    PREVIOUS_RELEASE=$(basename "$PREVIOUS_TARGET")
    log_info "  ↶ PREVIOUS → $PREVIOUS_RELEASE"
fi

# Lister toutes les releases
log_info ""
log_info "📋 Toutes les releases:"
ls -1td "$RELEASES_DIR"/*/ 2>/dev/null | while read -r release_path; do
    RELEASE_NAME=$(basename "$release_path")
    RELEASE_SIZE=$(du -sh "$release_path" | cut -f1)
    
    if [ "$RELEASE_NAME" = "$DEPLOYED_RELEASE" ]; then
        log_info "  ✓ $RELEASE_NAME ($RELEASE_SIZE) [ACTIVE]"
    else
        log_info "    $RELEASE_NAME ($RELEASE_SIZE)"
    fi
done

################################################################################
# Résumé
################################################################################

log_info ""
log_info "╔════════════════════════════════════════════════════════╗"
log_info "║  ✅ Déploiement terminé avec succès !                 ║"
log_info "╚════════════════════════════════════════════════════════╝"
log_info ""
log_info "📊 Informations:"
log_info "  • Projet: $PROJECT_SLUG"
log_info "  • Release: $RELEASE_ID"
log_info "  • Répertoire: $CURRENT_LINK → $RELEASE_DIR"
log_info "  • Commit: $COMMIT_HASH"
log_info ""
log_info "🎯 Prochaine étape: Configurer Nginx"
log_info "   ./06-setup-nginx.sh $PROJECT_SLUG monprojet.local"
log_info ""
log_info "⚠️  En cas de problème, vous pouvez revenir en arrière:"
log_info "   ./08-rollback.sh $PROJECT_SLUG"

exit 0
