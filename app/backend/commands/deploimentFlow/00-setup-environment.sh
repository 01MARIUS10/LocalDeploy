#!/bin/bash
################################################################################
# Script: 00-setup-environment.sh
# Description: Configure l'environnement serveur pour le déploiement
# Usage: sudo ./00-setup-environment.sh
################################################################################

set -euo pipefail  # Exit on error, undefined variables, and pipe failures

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction de logging
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

################################################################################
# Configuration
################################################################################

DEPLOY_USER="${DEPLOY_USER:-deployuser}"
WEB_GROUP="${WEB_GROUP:-www-data}"
PROJECT_BASE="${PROJECT_BASE:-/var/projects/LocalDeploy}"
WEB_ROOT="${WEB_ROOT:-/var/www/html}"
NODE_VERSION="${NODE_VERSION:-22}"

log_info "🚀 Configuration de l'environnement de déploiement"
log_info "Utilisateur: $DEPLOY_USER"
log_info "Groupe web: $WEB_GROUP"
log_info "Répertoire projets: $PROJECT_BASE"
log_info "Document root: $WEB_ROOT"
log_info "Version Node.js: $NODE_VERSION"

################################################################################
# 1. Créer l'utilisateur de déploiement
################################################################################

log_info "👤 Création de l'utilisateur $DEPLOY_USER..."

if id "$DEPLOY_USER" &>/dev/null; then
    log_warn "L'utilisateur $DEPLOY_USER existe déjà"
else
    useradd -m -s /bin/bash "$DEPLOY_USER"
    log_info "✅ Utilisateur $DEPLOY_USER créé"
fi

# Ajouter au groupe www-data
if groups "$DEPLOY_USER" | grep -q "$WEB_GROUP"; then
    log_info "L'utilisateur est déjà dans le groupe $WEB_GROUP"
else
    usermod -aG "$WEB_GROUP" "$DEPLOY_USER"
    log_info "✅ Utilisateur ajouté au groupe $WEB_GROUP"
fi

################################################################################
# 2. Créer les répertoires de base
################################################################################

log_info "📁 Création des répertoires..."

mkdir -p "$PROJECT_BASE"
mkdir -p "$WEB_ROOT"
mkdir -p /var/log/deployments
mkdir -p /var/lock/deployments

# Permissions
chown -R "$DEPLOY_USER:$WEB_GROUP" "$PROJECT_BASE"
chown -R "$DEPLOY_USER:$WEB_GROUP" "$WEB_ROOT"
chown -R "$DEPLOY_USER:$WEB_GROUP" /var/log/deployments
chown -R "$DEPLOY_USER:$WEB_GROUP" /var/lock/deployments

chmod 755 "$PROJECT_BASE"
chmod 755 "$WEB_ROOT"
chmod 775 /var/log/deployments
chmod 775 /var/lock/deployments

log_info "✅ Répertoires créés et permissions configurées"

################################################################################
# 3. Installer les dépendances système
################################################################################

log_info "📦 Installation des dépendances système..."

apt-get update -qq

# Paquets essentiels
PACKAGES=(
    git
    curl
    wget
    build-essential
    ca-certificates
    gnupg
    rsync
    jq
)

for package in "${PACKAGES[@]}"; do
    if dpkg -l | grep -q "^ii  $package"; then
        log_info "$package est déjà installé"
    else
        log_info "Installation de $package..."
        apt-get install -y "$package" > /dev/null 2>&1
        log_info "✅ $package installé"
    fi
done

################################################################################
# 4. Installer Node.js
################################################################################

log_info "📦 Installation de Node.js $NODE_VERSION..."

if command -v node &> /dev/null; then
    CURRENT_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$CURRENT_VERSION" = "$NODE_VERSION" ]; then
        log_info "Node.js $NODE_VERSION est déjà installé"
    else
        log_warn "Node.js $CURRENT_VERSION installé, mise à jour vers $NODE_VERSION..."
    fi
else
    log_info "Installation de Node.js via NodeSource..."
    
    # Installer NodeSource repository
    curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - > /dev/null 2>&1
    apt-get install -y nodejs > /dev/null 2>&1
    
    log_info "✅ Node.js $(node --version) installé"
    log_info "✅ npm $(npm --version) installé"
fi

################################################################################
# 5. Installer Nginx
################################################################################

log_info "🌐 Installation et configuration de Nginx..."

if command -v nginx &> /dev/null; then
    log_info "Nginx est déjà installé: $(nginx -v 2>&1)"
else
    apt-get install -y nginx > /dev/null 2>&1
    systemctl enable nginx
    systemctl start nginx
    log_info "✅ Nginx installé et démarré"
fi

# Créer le répertoire pour les configurations de sites
mkdir -p /etc/nginx/sites-available
mkdir -p /etc/nginx/sites-enabled

################################################################################
# 6. Configurer le firewall (optionnel)
################################################################################

if command -v ufw &> /dev/null; then
    log_info "🔥 Configuration du firewall UFW..."
    
    ufw allow 22/tcp comment "SSH" > /dev/null 2>&1
    ufw allow 80/tcp comment "HTTP" > /dev/null 2>&1
    ufw allow 443/tcp comment "HTTPS" > /dev/null 2>&1
    
    log_info "✅ Règles firewall configurées (SSH, HTTP, HTTPS)"
fi

################################################################################
# 7. Créer les scripts utilitaires
################################################################################

log_info "📝 Création des scripts utilitaires..."

# Script pour obtenir les variables d'environnement
cat > /usr/local/bin/deploy-env <<'EOF'
#!/bin/bash
# Afficher les variables d'environnement de déploiement
echo "DEPLOY_USER=${DEPLOY_USER:-deployuser}"
echo "PROJECT_BASE=${PROJECT_BASE:-/var/projects/LocalDeploy}"
echo "WEB_ROOT=${WEB_ROOT:-/var/www/html}"
echo "NODE_VERSION=${NODE_VERSION:-22}"
EOF

chmod +x /usr/local/bin/deploy-env

log_info "✅ Scripts utilitaires créés"

################################################################################
# Résumé
################################################################################

log_info ""
log_info "╔════════════════════════════════════════════════════════╗"
log_info "║  ✅ Configuration de l'environnement terminée !       ║"
log_info "╚════════════════════════════════════════════════════════╝"
log_info ""
log_info "📊 Résumé de la configuration:"
log_info "  • Utilisateur: $DEPLOY_USER"
log_info "  • Répertoire projets: $PROJECT_BASE"
log_info "  • Document root: $WEB_ROOT"
log_info "  • Node.js: $(node --version)"
log_info "  • npm: $(npm --version)"
log_info "  • Nginx: $(nginx -v 2>&1 | cut -d'/' -f2)"
log_info "  • Git: $(git --version | cut -d' ' -f3)"
log_info ""
log_info "🎯 Prochaine étape: Lancer le clone du dépôt"
log_info "   ./01-clone-repo.sh"

exit 0
