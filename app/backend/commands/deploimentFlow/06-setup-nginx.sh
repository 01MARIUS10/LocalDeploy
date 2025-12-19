#!/bin/bash
################################################################################
# Script: 06-setup-nginx.sh
# Description: Configure Nginx pour servir le projet déployé
# Usage: ./06-setup-nginx.sh <project_slug> <domain> [port]
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
    log_error "Usage: $0 <project_slug> <domain> [port]"
    log_error "Exemple: $0 monprojetreact monprojet.local"
    log_error "         $0 monprojetreact monprojet.local 8080"
    exit 1
fi

PROJECT_SLUG="$1"
DOMAIN="$2"
PORT="${3:-80}"

# Configuration
PROJECT_BASE="${PROJECT_BASE:-/var/projects/LocalDeploy}"
PROJECT_DIR="$PROJECT_BASE/$PROJECT_SLUG"
CURRENT_LINK="$PROJECT_DIR/current"
NGINX_AVAILABLE="/etc/nginx/sites-available/$PROJECT_SLUG"
NGINX_ENABLED="/etc/nginx/sites-enabled/$PROJECT_SLUG"

log_info "🌐 Configuration de Nginx"
log_info "Projet: $PROJECT_SLUG"
log_info "Domaine: $DOMAIN"
log_info "Port: $PORT"

################################################################################
# 1. Vérifications
################################################################################

log_info "🔍 Vérifications préalables..."

if [ ! -L "$CURRENT_LINK" ]; then
    log_error "Aucune release déployée trouvée: $CURRENT_LINK"
    log_error "Lancez d'abord: ./05-deploy-release.sh"
    exit 1
fi

DEPLOYED_PATH=$(readlink -f "$CURRENT_LINK")
log_info "✅ Release déployée: $DEPLOYED_PATH"

if ! command -v nginx &> /dev/null; then
    log_error "Nginx n'est pas installé"
    log_error "Installez-le avec: sudo apt install nginx"
    exit 1
fi

log_info "✅ Nginx installé: $(nginx -v 2>&1)"

################################################################################
# 2. Créer la configuration Nginx
################################################################################

log_info "📝 Création de la configuration Nginx..."

cat > "$NGINX_AVAILABLE" <<EOF
################################################################################
# Nginx configuration for $PROJECT_SLUG
# Domain: $DOMAIN
# Generated: $(date -Iseconds)
################################################################################

server {
    listen $PORT;
    listen [::]:$PORT;
    
    server_name $DOMAIN;
    
    # Document root pointe vers le symlink 'current'
    root $CURRENT_LINK;
    index index.html index.htm 200.html;
    
    # Logs
    access_log /var/log/nginx/${PROJECT_SLUG}_access.log;
    error_log /var/log/nginx/${PROJECT_SLUG}_error.log warn;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 256;
    gzip_types
        application/javascript
        application/json
        application/xml
        text/css
        text/javascript
        text/plain
        text/xml;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Cache static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }
    
    # SPA fallback (pour React Router, Vue Router, etc.)
    location / {
        try_files \$uri \$uri/ /index.html =404;
    }
    
    # Healthcheck endpoint
    location /health {
        access_log off;
        return 200 "OK\n";
        add_header Content-Type text/plain;
    }
    
    # Deny access to hidden files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }
}
EOF

log_info "✅ Configuration créée: $NGINX_AVAILABLE"

################################################################################
# 3. Activer le site
################################################################################

log_info "🔗 Activation du site..."

if [ -L "$NGINX_ENABLED" ]; then
    log_warn "Site déjà activé, recréation du symlink..."
    rm "$NGINX_ENABLED"
fi

ln -s "$NGINX_AVAILABLE" "$NGINX_ENABLED"

log_info "✅ Site activé"

################################################################################
# 4. Tester la configuration
################################################################################

log_info "🧪 Test de la configuration Nginx..."

if nginx -t 2>&1 | grep -q "syntax is ok"; then
    log_info "✅ Configuration valide"
else
    log_error "❌ Configuration invalide"
    nginx -t
    exit 1
fi

################################################################################
# 5. Recharger Nginx
################################################################################

log_info "🔄 Rechargement de Nginx..."

systemctl reload nginx

if systemctl is-active --quiet nginx; then
    log_info "✅ Nginx rechargé avec succès"
else
    log_error "❌ Échec du rechargement de Nginx"
    systemctl status nginx
    exit 1
fi

################################################################################
# 6. Configurer /etc/hosts pour le domaine local
################################################################################

if ! grep -q "$DOMAIN" /etc/hosts; then
    log_info "📝 Ajout de $DOMAIN dans /etc/hosts..."
    
    echo "127.0.0.1    $DOMAIN" >> /etc/hosts
    
    log_info "✅ Domaine ajouté à /etc/hosts"
else
    log_info "✅ Domaine déjà dans /etc/hosts"
fi

################################################################################
# 7. Tests post-configuration
################################################################################

log_info "🔍 Tests post-configuration..."

# Test 1: Vérifier que Nginx écoute sur le port
if netstat -tlnp 2>/dev/null | grep -q ":$PORT.*nginx" || ss -tlnp 2>/dev/null | grep -q ":$PORT.*nginx"; then
    log_info "✅ Nginx écoute sur le port $PORT"
else
    log_warn "⚠️  Impossible de vérifier si Nginx écoute sur le port $PORT"
fi

# Test 2: Tester avec curl
sleep 1  # Laisser le temps à Nginx de recharger

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://$DOMAIN:$PORT" || echo "000")

if [ "$HTTP_CODE" = "200" ]; then
    log_info "✅ Site accessible (HTTP $HTTP_CODE)"
elif [ "$HTTP_CODE" = "000" ]; then
    log_warn "⚠️  Impossible de tester avec curl (curl non installé?)"
else
    log_warn "⚠️  Site retourne HTTP $HTTP_CODE"
fi

# Test 3: Healthcheck
HEALTH_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://$DOMAIN:$PORT/health" || echo "000")

if [ "$HEALTH_CODE" = "200" ]; then
    log_info "✅ Healthcheck OK (HTTP $HEALTH_CODE)"
else
    log_warn "⚠️  Healthcheck retourne HTTP $HEALTH_CODE"
fi

################################################################################
# Résumé
################################################################################

log_info ""
log_info "╔════════════════════════════════════════════════════════╗"
log_info "║  ✅ Configuration Nginx terminée !                    ║"
log_info "╚════════════════════════════════════════════════════════╝"
log_info ""
log_info "📊 Informations:"
log_info "  • Projet: $PROJECT_SLUG"
log_info "  • Domaine: $DOMAIN"
log_info "  • Port: $PORT"
log_info "  • Document root: $CURRENT_LINK"
log_info "  • Config: $NGINX_AVAILABLE"
log_info ""
log_info "🌐 URLs:"
log_info "  • Site: http://$DOMAIN:$PORT"
log_info "  • Healthcheck: http://$DOMAIN:$PORT/health"
log_info ""
log_info "📋 Logs Nginx:"
log_info "  • Access: /var/log/nginx/${PROJECT_SLUG}_access.log"
log_info "  • Error: /var/log/nginx/${PROJECT_SLUG}_error.log"
log_info ""
log_info "💡 Commandes utiles:"
log_info "  • Recharger Nginx: sudo systemctl reload nginx"
log_info "  • Voir les logs: sudo tail -f /var/log/nginx/${PROJECT_SLUG}_access.log"
log_info "  • Tester la config: sudo nginx -t"

exit 0
