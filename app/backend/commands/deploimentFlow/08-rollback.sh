#!/bin/bash
################################################################################
# Script: 08-rollback.sh
# Description: Rollback vers la release précédente
# Usage: ./08-rollback.sh <project_slug>
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
    log_error "Usage: $0 <project_slug> [release_id]"
    log_error "Exemple: $0 monprojetreact"
    log_error "         $0 monprojetreact 20240115-143022  # rollback vers une release spécifique"
    exit 1
fi

PROJECT_SLUG="$1"
TARGET_RELEASE="${2:-}"

# Configuration
DEPLOY_USER="${DEPLOY_USER:-deployuser}"
PROJECT_BASE="${PROJECT_BASE:-/var/projects/LocalDeploy}"
PROJECT_DIR="$PROJECT_BASE/$PROJECT_SLUG"
RELEASES_DIR="$PROJECT_DIR/releases"
CURRENT_LINK="$PROJECT_DIR/current"
PREVIOUS_LINK="$PROJECT_DIR/previous"

log_warn "⚠️  ROLLBACK - Retour à la version précédente"
log_info "Projet: $PROJECT_SLUG"

################################################################################
# 1. Vérifications
################################################################################

log_info "🔍 Vérifications préalables..."

if [ ! -L "$CURRENT_LINK" ]; then
    log_error "Aucune release déployée trouvée"
    exit 1
fi

CURRENT_TARGET=$(readlink -f "$CURRENT_LINK")
CURRENT_RELEASE=$(basename "$CURRENT_TARGET")

log_info "Release actuelle: $CURRENT_RELEASE"

################################################################################
# 2. Déterminer la release cible
################################################################################

if [ -n "$TARGET_RELEASE" ]; then
    # Rollback vers une release spécifique
    TARGET_PATH="$RELEASES_DIR/$TARGET_RELEASE"
    
    if [ ! -d "$TARGET_PATH" ]; then
        log_error "Release spécifiée introuvable: $TARGET_RELEASE"
        log_error "Releases disponibles:"
        ls -1 "$RELEASES_DIR" 2>/dev/null || log_error "Aucune"
        exit 1
    fi
    
    log_info "Rollback vers la release: $TARGET_RELEASE"
    
else
    # Rollback vers la release précédente (lien 'previous')
    if [ ! -L "$PREVIOUS_LINK" ]; then
        log_error "Aucune release précédente trouvée (lien 'previous' absent)"
        log_error "Vous pouvez spécifier une release manuellement:"
        log_error "  $0 $PROJECT_SLUG <release_id>"
        log_error ""
        log_error "Releases disponibles:"
        ls -1 "$RELEASES_DIR" 2>/dev/null | grep -v "^$CURRENT_RELEASE$" || log_error "Aucune"
        exit 1
    fi
    
    TARGET_PATH=$(readlink -f "$PREVIOUS_LINK")
    TARGET_RELEASE=$(basename "$TARGET_PATH")
    
    log_info "Rollback vers la release précédente: $TARGET_RELEASE"
fi

################################################################################
# 3. Confirmation
################################################################################

log_warn ""
log_warn "╔════════════════════════════════════════════════════════╗"
log_warn "║  ⚠️  ATTENTION: Rollback imminent                     ║"
log_warn "╚════════════════════════════════════════════════════════╝"
log_warn ""
log_warn "  Release actuelle: $CURRENT_RELEASE"
log_warn "  → Rollback vers:  $TARGET_RELEASE"
log_warn ""

read -p "Êtes-vous sûr de vouloir effectuer le rollback? (yes/no) " -r
echo

if [[ ! $REPLY =~ ^[Yy](es)?$ ]]; then
    log_info "❌ Rollback annulé"
    exit 0
fi

################################################################################
# 4. Effectuer le rollback
################################################################################

log_info "🔄 Rollback en cours..."

# Sauvegarder l'ancien lien 'previous'
OLD_PREVIOUS="$PROJECT_DIR/.previous.backup"

if [ -L "$PREVIOUS_LINK" ]; then
    cp -P "$PREVIOUS_LINK" "$OLD_PREVIOUS" 2>/dev/null || true
fi

# Mettre à jour 'previous' pour pointer vers l'ancien 'current'
sudo -u "$DEPLOY_USER" ln -sfn "$CURRENT_TARGET" "$PREVIOUS_LINK"

# Déploiement atomique vers la nouvelle release
TEMP_LINK="$PROJECT_DIR/.current.tmp.$$"
sudo -u "$DEPLOY_USER" ln -sfn "$TARGET_PATH" "$TEMP_LINK"
sudo -u "$DEPLOY_USER" mv -fT "$TEMP_LINK" "$CURRENT_LINK"

log_info "✅ Rollback effectué"

################################################################################
# 5. Vérifications post-rollback
################################################################################

log_info "🔍 Vérifications post-rollback..."

NEW_CURRENT=$(readlink -f "$CURRENT_LINK")
NEW_RELEASE=$(basename "$NEW_CURRENT")

if [ "$NEW_RELEASE" = "$TARGET_RELEASE" ]; then
    log_info "✅ Symlink 'current' pointe maintenant vers $TARGET_RELEASE"
else
    log_error "❌ Erreur: Symlink pointe vers $NEW_RELEASE au lieu de $TARGET_RELEASE"
    exit 1
fi

# Vérifier l'accès aux fichiers
if [ -r "$CURRENT_LINK/index.html" ] || [ -r "$CURRENT_LINK/200.html" ]; then
    log_info "✅ Fichiers accessibles"
else
    log_warn "⚠️  Fichiers index.html/200.html non trouvés"
fi

################################################################################
# 6. Recharger Nginx
################################################################################

log_info "🔄 Rechargement de Nginx..."

if command -v nginx &> /dev/null; then
    if nginx -t 2>&1 | grep -q "syntax is ok"; then
        systemctl reload nginx
        log_info "✅ Nginx rechargé"
    else
        log_error "❌ Configuration Nginx invalide"
        nginx -t
    fi
else
    log_warn "⚠️  Nginx non trouvé, rechargement manuel nécessaire"
fi

################################################################################
# 7. Enregistrer dans l'historique
################################################################################

DEPLOY_LOG="$PROJECT_DIR/logs/deploy-history.log"

echo "[$(date -Iseconds)] ROLLBACK $PROJECT_SLUG $CURRENT_RELEASE → $TARGET_RELEASE" >> "$DEPLOY_LOG"

log_info "✅ Historique mis à jour"

################################################################################
# 8. Afficher l'état des releases
################################################################################

log_info ""
log_info "📊 État des releases:"

log_info "  ✓ CURRENT  → $NEW_RELEASE"

if [ -L "$PREVIOUS_LINK" ]; then
    PREV_TARGET=$(readlink -f "$PREVIOUS_LINK")
    PREV_RELEASE=$(basename "$PREV_TARGET")
    log_info "  ↶ PREVIOUS → $PREV_RELEASE"
fi

log_info ""
log_info "📋 Toutes les releases:"
ls -1td "$RELEASES_DIR"/*/ 2>/dev/null | while read -r release_path; do
    RELEASE_NAME=$(basename "$release_path")
    RELEASE_SIZE=$(du -sh "$release_path" | cut -f1)
    
    if [ "$RELEASE_NAME" = "$NEW_RELEASE" ]; then
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
log_info "║  ✅ Rollback terminé avec succès !                    ║"
log_info "╚════════════════════════════════════════════════════════╝"
log_info ""
log_info "📊 Informations:"
log_info "  • Projet: $PROJECT_SLUG"
log_info "  • Ancienne release: $CURRENT_RELEASE"
log_info "  • Nouvelle release: $TARGET_RELEASE"
log_info "  • Répertoire: $CURRENT_LINK → $TARGET_PATH"
log_info ""
log_info "🎯 Prochaines étapes:"
log_info "  1. Vérifiez le site: http://$(hostname):80"
log_info "  2. Lancez un health check: ./07-health-check.sh $PROJECT_SLUG"
log_info "  3. Consultez les logs: tail -f /var/log/nginx/${PROJECT_SLUG}_*.log"
log_info ""
log_warn "💡 Si le problème persiste, vous pouvez rollback à nouveau:"
log_warn "   ./08-rollback.sh $PROJECT_SLUG [autre_release_id]"

exit 0
