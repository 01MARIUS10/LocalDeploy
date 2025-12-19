#!/bin/bash
################################################################################
# Script: 07-health-check.sh
# Description: Vérifie la santé du déploiement
# Usage: ./07-health-check.sh <project_slug> <domain> [port]
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
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_fail() { echo -e "${RED}[✗]${NC} $1"; }

################################################################################
# Configuration
################################################################################

PROJECT_SLUG="${1:-}"
DOMAIN="${2:-localhost}"
PORT="${3:-80}"

if [ -z "$PROJECT_SLUG" ]; then
    log_error "Usage: $0 <project_slug> [domain] [port]"
    log_error "Exemple: $0 monprojetreact monprojet.local 80"
    exit 1
fi

PROJECT_BASE="${PROJECT_BASE:-/var/projects/LocalDeploy}"
PROJECT_DIR="$PROJECT_BASE/$PROJECT_SLUG"
CURRENT_LINK="$PROJECT_DIR/current"

BASE_URL="http://$DOMAIN:$PORT"

log_info "🏥 Health Check du déploiement"
log_info "Projet: $PROJECT_SLUG"
log_info "URL: $BASE_URL"
log_info ""

################################################################################
# Compteurs
################################################################################

TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

check_start() {
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    echo -n "  [$TOTAL_CHECKS] $1... "
}

check_pass() {
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
    echo -e "${GREEN}✓${NC}"
}

check_fail() {
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
    echo -e "${RED}✗${NC}"
    if [ -n "${1:-}" ]; then
        echo "      Erreur: $1"
    fi
}

################################################################################
# 1. Vérifications système
################################################################################

log_info "🖥️  Vérifications système"

check_start "Répertoire projet existe"
if [ -d "$PROJECT_DIR" ]; then
    check_pass
else
    check_fail "$PROJECT_DIR introuvable"
fi

check_start "Release déployée existe"
if [ -L "$CURRENT_LINK" ] && [ -d "$CURRENT_LINK" ]; then
    DEPLOYED_RELEASE=$(basename "$(readlink -f "$CURRENT_LINK")")
    check_pass
    echo "      → Release: $DEPLOYED_RELEASE"
else
    check_fail "Lien 'current' introuvable"
fi

check_start "Fichiers de release présents"
if [ -L "$CURRENT_LINK" ]; then
    FILE_COUNT=$(find "$CURRENT_LINK" -type f 2>/dev/null | wc -l)
    if [ "$FILE_COUNT" -gt 0 ]; then
        check_pass
        echo "      → $FILE_COUNT fichiers"
    else
        check_fail "Aucun fichier dans la release"
    fi
else
    check_fail
fi

################################################################################
# 2. Vérifications Nginx
################################################################################

log_info ""
log_info "🌐 Vérifications Nginx"

check_start "Nginx installé et actif"
if systemctl is-active --quiet nginx; then
    check_pass
else
    check_fail "Nginx n'est pas actif"
fi

check_start "Configuration Nginx existe"
NGINX_CONFIG="/etc/nginx/sites-enabled/$PROJECT_SLUG"
if [ -f "$NGINX_CONFIG" ]; then
    check_pass
else
    check_fail "$NGINX_CONFIG introuvable"
fi

check_start "Configuration Nginx valide"
if nginx -t 2>&1 | grep -q "syntax is ok"; then
    check_pass
else
    check_fail "Configuration invalide"
fi

check_start "Nginx écoute sur port $PORT"
if netstat -tlnp 2>/dev/null | grep -q ":$PORT.*nginx" || ss -tlnp 2>/dev/null | grep -q ":$PORT.*nginx"; then
    check_pass
else
    check_fail "Nginx n'écoute pas sur le port $PORT"
fi

################################################################################
# 3. Tests HTTP
################################################################################

log_info ""
log_info "🌍 Tests HTTP"

check_start "Connexion au site"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$BASE_URL" 2>/dev/null || echo "000")

if [ "$HTTP_CODE" = "200" ]; then
    check_pass
elif [ "$HTTP_CODE" = "000" ]; then
    check_fail "Impossible de se connecter (timeout ou erreur réseau)"
else
    check_fail "HTTP $HTTP_CODE"
fi

check_start "Temps de réponse acceptable"
RESPONSE_TIME=$(curl -s -o /dev/null -w "%{time_total}" --max-time 5 "$BASE_URL" 2>/dev/null || echo "999")
RESPONSE_MS=$(echo "$RESPONSE_TIME * 1000" | bc | cut -d'.' -f1)

if [ "$RESPONSE_MS" -lt 1000 ]; then
    check_pass
    echo "      → ${RESPONSE_MS}ms"
elif [ "$RESPONSE_MS" -lt 3000 ]; then
    check_pass
    echo "      → ${RESPONSE_MS}ms (un peu lent)"
else
    check_fail "${RESPONSE_MS}ms (trop lent)"
fi

check_start "Endpoint /health disponible"
HEALTH_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$BASE_URL/health" 2>/dev/null || echo "000")

if [ "$HEALTH_CODE" = "200" ]; then
    check_pass
else
    check_fail "HTTP $HEALTH_CODE"
fi

check_start "Contenu HTML valide"
CONTENT=$(curl -s --max-time 5 "$BASE_URL" 2>/dev/null || echo "")

if echo "$CONTENT" | grep -qi "<html\|<!DOCTYPE"; then
    check_pass
else
    check_fail "Pas de contenu HTML détecté"
fi

check_start "Titre de page présent"
if echo "$CONTENT" | grep -qi "<title>"; then
    TITLE=$(echo "$CONTENT" | grep -oP '<title>\K[^<]+' | head -1)
    check_pass
    echo "      → '$TITLE'"
else
    check_fail "Balise <title> absente"
fi

################################################################################
# 4. Vérifications assets
################################################################################

log_info ""
log_info "📦 Vérifications assets"

check_start "Fichiers CSS présents"
CSS_COUNT=$(find "$CURRENT_LINK" -name "*.css" -type f 2>/dev/null | wc -l)
if [ "$CSS_COUNT" -gt 0 ]; then
    check_pass
    echo "      → $CSS_COUNT fichiers CSS"
else
    check_warn "Aucun fichier CSS trouvé"
fi

check_start "Fichiers JS présents"
JS_COUNT=$(find "$CURRENT_LINK" -name "*.js" -type f 2>/dev/null | wc -l)
if [ "$JS_COUNT" -gt 0 ]; then
    check_pass
    echo "      → $JS_COUNT fichiers JS"
else
    check_fail "Aucun fichier JS trouvé"
fi

check_start "Images présentes"
IMG_COUNT=$(find "$CURRENT_LINK" \( -name "*.jpg" -o -name "*.png" -o -name "*.svg" -o -name "*.gif" \) -type f 2>/dev/null | wc -l)
if [ "$IMG_COUNT" -gt 0 ]; then
    check_pass
    echo "      → $IMG_COUNT images"
else
    check_warn "Aucune image trouvée"
fi

################################################################################
# 5. Vérifications logs
################################################################################

log_info ""
log_info "📋 Vérifications logs"

ACCESS_LOG="/var/log/nginx/${PROJECT_SLUG}_access.log"
ERROR_LOG="/var/log/nginx/${PROJECT_SLUG}_error.log"

check_start "Log d'accès existe"
if [ -f "$ACCESS_LOG" ]; then
    ACCESS_SIZE=$(du -h "$ACCESS_LOG" | cut -f1)
    check_pass
    echo "      → $ACCESS_SIZE"
else
    check_warn "Log d'accès introuvable"
fi

check_start "Log d'erreur existe"
if [ -f "$ERROR_LOG" ]; then
    ERROR_SIZE=$(du -h "$ERROR_LOG" | cut -f1)
    check_pass
    echo "      → $ERROR_SIZE"
else
    check_warn "Log d'erreur introuvable"
fi

check_start "Pas d'erreurs critiques récentes"
if [ -f "$ERROR_LOG" ]; then
    CRITICAL_COUNT=$(grep -c "\[crit\]\|\[alert\]\|\[emerg\]" "$ERROR_LOG" 2>/dev/null || echo "0")
    if [ "$CRITICAL_COUNT" -eq 0 ]; then
        check_pass
    else
        check_fail "$CRITICAL_COUNT erreurs critiques trouvées"
    fi
else
    check_warn "Log d'erreur introuvable"
fi

################################################################################
# 6. Informations de déploiement
################################################################################

log_info ""
log_info "ℹ️  Informations de déploiement"

METADATA_FILE="$CURRENT_LINK/.release-metadata.json"

if [ -f "$METADATA_FILE" ]; then
    echo "  • Release ID: $(jq -r '.release_id' "$METADATA_FILE")"
    echo "  • Déployé le: $(jq -r '.deployed_at' "$METADATA_FILE")"
    echo "  • Commit: $(jq -r '.commit.hash' "$METADATA_FILE" | cut -c1-8)"
    echo "  • Message: $(jq -r '.commit.message' "$METADATA_FILE")"
    echo "  • Fichiers: $(jq -r '.build.file_count' "$METADATA_FILE")"
    echo "  • Taille: $(jq -r '.build.size' "$METADATA_FILE")"
fi

################################################################################
# Résumé
################################################################################

log_info ""
log_info "════════════════════════════════════════════════════════"

PASS_PERCENT=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))

if [ "$FAILED_CHECKS" -eq 0 ]; then
    log_info "✅ Tous les tests sont passés ! ($PASSED_CHECKS/$TOTAL_CHECKS)"
    log_info ""
    log_info "🎉 Le déploiement est sain et fonctionnel !"
    EXIT_CODE=0
elif [ "$PASS_PERCENT" -ge 80 ]; then
    log_warn "⚠️  La plupart des tests sont passés ($PASSED_CHECKS/$TOTAL_CHECKS - ${PASS_PERCENT}%)"
    log_warn "   $FAILED_CHECKS test(s) échoué(s)"
    log_info ""
    log_warn "🔍 Le déploiement fonctionne mais nécessite une attention"
    EXIT_CODE=1
else
    log_error "❌ Plusieurs tests ont échoué ($PASSED_CHECKS/$TOTAL_CHECKS - ${PASS_PERCENT}%)"
    log_error "   $FAILED_CHECKS test(s) échoué(s)"
    log_info ""
    log_error "🚨 Le déploiement présente des problèmes critiques"
    EXIT_CODE=2
fi

log_info "════════════════════════════════════════════════════════"

exit $EXIT_CODE
