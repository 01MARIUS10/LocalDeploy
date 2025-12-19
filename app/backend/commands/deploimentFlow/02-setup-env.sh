#!/bin/bash
################################################################################
# Script: 02-setup-env.sh
# Description: Configure les variables d'environnement du projet
# Usage: ./02-setup-env.sh <project_slug> [env_file]
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
    log_error "Usage: $0 <project_slug> [env_file]"
    log_error "Exemple: $0 monprojetreact"
    log_error "         $0 monprojetreact /path/to/.env.template"
    exit 1
fi

PROJECT_SLUG="$1"
ENV_TEMPLATE="${2:-}"

# Configuration
DEPLOY_USER="${DEPLOY_USER:-deployuser}"
PROJECT_BASE="${PROJECT_BASE:-/var/projects/LocalDeploy}"
PROJECT_DIR="$PROJECT_BASE/$PROJECT_SLUG"
ENV_FILE="$PROJECT_DIR/shared/.env"
ENV_SCRIPT="$PROJECT_DIR/inject-env.sh"

log_info "🔐 Configuration des variables d'environnement"
log_info "Projet: $PROJECT_SLUG"
log_info "Fichier .env: $ENV_FILE"

################################################################################
# 1. Créer le répertoire shared si nécessaire
################################################################################

if [ ! -d "$PROJECT_DIR/shared" ]; then
    log_info "📁 Création du répertoire shared..."
    sudo -u "$DEPLOY_USER" mkdir -p "$PROJECT_DIR/shared"
fi

################################################################################
# 2. Créer ou mettre à jour le fichier .env
################################################################################

if [ -f "$ENV_FILE" ]; then
    log_warn "⚠️  Le fichier .env existe déjà"
    log_info "Création d'une sauvegarde..."
    
    BACKUP_FILE="$ENV_FILE.backup.$(date +%Y%m%d-%H%M%S)"
    cp "$ENV_FILE" "$BACKUP_FILE"
    chown "$DEPLOY_USER:www-data" "$BACKUP_FILE"
    
    log_info "✅ Sauvegarde créée: $BACKUP_FILE"
    
    read -p "Voulez-vous écraser le fichier existant? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "❌ Opération annulée"
        exit 0
    fi
fi

log_info "📝 Création du fichier .env..."

if [ -n "$ENV_TEMPLATE" ] && [ -f "$ENV_TEMPLATE" ]; then
    # Utiliser le template fourni
    log_info "Utilisation du template: $ENV_TEMPLATE"
    sudo -u "$DEPLOY_USER" cp "$ENV_TEMPLATE" "$ENV_FILE"
else
    # Créer un template par défaut
    log_info "Création d'un template par défaut..."
    
    sudo -u "$DEPLOY_USER" tee "$ENV_FILE" > /dev/null <<'EOF'
################################################################################
# Variables d'environnement - PRODUCTION
################################################################################

# Environnement
NODE_ENV=production

# API Keys (remplacer par les vraies valeurs)
API_KEY=your-api-key-here
API_SECRET=your-api-secret-here

# Application
APP_NAME=LocalDeploy
APP_URL=http://localhost
APP_PORT=3000

# Base de données (si nécessaire)
# DATABASE_URL=postgresql://user:password@localhost:5432/dbname
# DATABASE_URL=mysql://user:password@localhost:3306/dbname

# Redis (si nécessaire)
# REDIS_HOST=localhost
# REDIS_PORT=6379
# REDIS_PASSWORD=

# Logs
LOG_LEVEL=info

# Feature flags
# FEATURE_NEW_UI=true

################################################################################
# ⚠️  IMPORTANT: Ne jamais commiter ce fichier dans Git
################################################################################
EOF
fi

# Permissions strictes pour les secrets
chmod 600 "$ENV_FILE"
chown "$DEPLOY_USER:www-data" "$ENV_FILE"

log_info "✅ Fichier .env créé avec permissions 600"

################################################################################
# 3. Créer le script d'injection des variables
################################################################################

log_info "📜 Création du script d'injection des variables..."

sudo -u "$DEPLOY_USER" tee "$ENV_SCRIPT" > /dev/null <<EOF
#!/bin/bash
################################################################################
# Script d'injection des variables d'environnement
# Usage: source $ENV_SCRIPT
################################################################################

ENV_FILE="$ENV_FILE"

if [ ! -f "\$ENV_FILE" ]; then
    echo "❌ Fichier .env introuvable: \$ENV_FILE"
    exit 1
fi

# Charger les variables
set -a
source "\$ENV_FILE"
set +a

echo "✅ Variables d'environnement chargées depuis \$ENV_FILE"
EOF

chmod +x "$ENV_SCRIPT"
chown "$DEPLOY_USER:www-data" "$ENV_SCRIPT"

log_info "✅ Script d'injection créé: $ENV_SCRIPT"

################################################################################
# 4. Afficher les variables (masquer les secrets)
################################################################################

log_info "📋 Aperçu des variables d'environnement:"

while IFS= read -r line; do
    # Ignorer les commentaires et lignes vides
    if [[ "$line" =~ ^[[:space:]]*# ]] || [[ -z "$line" ]]; then
        continue
    fi
    
    # Extraire la clé
    KEY=$(echo "$line" | cut -d'=' -f1)
    
    # Masquer les valeurs sensibles
    if [[ "$KEY" =~ (KEY|SECRET|PASSWORD|TOKEN|PASS) ]]; then
        echo "  • $KEY=***hidden***"
    else
        echo "  • $line"
    fi
done < "$ENV_FILE"

################################################################################
# 5. Tester l'injection
################################################################################

log_info "🧪 Test de l'injection des variables..."

# Créer un sous-shell pour tester
TEST_OUTPUT=$(sudo -u "$DEPLOY_USER" bash -c "
    source '$ENV_SCRIPT' 2>/dev/null
    echo \"NODE_ENV=\$NODE_ENV\"
")

if echo "$TEST_OUTPUT" | grep -q "NODE_ENV="; then
    log_info "✅ Test réussi: $TEST_OUTPUT"
else
    log_error "❌ Échec du test d'injection"
    exit 1
fi

################################################################################
# Résumé
################################################################################

log_info ""
log_info "╔════════════════════════════════════════════════════════╗"
log_info "║  ✅ Configuration .env terminée !                     ║"
log_info "╚════════════════════════════════════════════════════════╝"
log_info ""
log_info "📊 Informations:"
log_info "  • Fichier .env: $ENV_FILE"
log_info "  • Script injection: $ENV_SCRIPT"
log_info "  • Permissions: 600 (lecture seule par le propriétaire)"
log_info ""
log_info "⚠️  IMPORTANT:"
log_info "  • Éditez $ENV_FILE pour ajouter vos vraies valeurs"
log_info "  • Ne jamais commiter ce fichier dans Git"
log_info "  • Utilisez des secrets managers en production"
log_info ""
log_info "🎯 Prochaine étape: Build du projet"
log_info "   ./03-build-project.sh $PROJECT_SLUG"

exit 0
