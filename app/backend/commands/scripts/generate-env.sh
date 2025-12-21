#!/bin/bash

set -euo pipefail

# Configuration des logs
log_info() { echo " $1"; }
log_success() { echo " $1"; }
log_warn() { echo "[WARN] $1"; }
log_error() { echo "[ERROR] $1"; }

# Validation des arguments
if [ $# -lt 2 ]; then
  log_error "Arguments manquants"
  log_info "Usage: $0 <project-path> <slug> [env-vars-json]"
  log_info "Exemple: $0 /var/www/project/valentine valentine"
  log_info "Exemple: $0 /var/www/project/valentine valentine '{\"NODE_ENV\":\"production\"}'"
  exit 1
fi

PROJECT_PATH="$1"
SLUG="$2"
ENV_VARS_BASE64="${3:-}"

log_info "Génération du fichier .env..."

# Décoder le base64 uniquement ici, juste avant de parser avec jq
if [ -n "$ENV_VARS_BASE64" ] && [ "$ENV_VARS_BASE64" != "" ]; then
  log_info "Décodage des variables d'environnement (base64)..."
  ENV_VARS_JSON=$(echo "$ENV_VARS_BASE64" | base64 -d 2>/dev/null || echo "{}")
  
  if [ "$ENV_VARS_JSON" = "{}" ] || [ -z "$ENV_VARS_JSON" ]; then
    log_warn "Échec du décodage base64 ou JSON vide"
    ENV_VARS_JSON="{}"
  else
    log_success "Base64 décodé avec succès"
    log_info "JSON décodé: $ENV_VARS_JSON"
  fi
else
  log_info "Aucune variable base64 fournie"
  ENV_VARS_JSON="{}"
fi

ENV_FILE="$PROJECT_PATH/.env"

# Vérifier si le répertoire existe
if [ ! -d "$PROJECT_PATH" ]; then
  log_error "Le répertoire $PROJECT_PATH n'existe pas"
  exit 1
fi

# Vérifier si le fichier .env existe déjà
if [ -f "$ENV_FILE" ]; then
  log_info "Fichier .env existant détecté"
  log_warn "Conservation de la configuration existante"
  exit 0
fi

# Générer une clé secrète sécurisée
SECRET_KEY=$(openssl rand -hex 32 2>/dev/null || head -c32 /dev/urandom | xxd -p -c 64)

# Créer le fichier .env avec l'en-tête
cat > "$ENV_FILE" << EOL
# Environment Configuration
# Project: $SLUG
# Generated: $(date -Iseconds)

EOL

# Si des variables d'environnement JSON sont fournies, les ajouter
if [ "$ENV_VARS_JSON" != "{}" ] && [ -n "$ENV_VARS_JSON" ]; then
  log_info "Ajout des variables d'environnement depuis la base de données..."
  
  # Parser le JSON et ajouter les variables (nécessite jq)
  if command -v jq &> /dev/null; then
    # Valider le JSON avant de le parser
    if echo "$ENV_VARS_JSON" | jq empty 2>/dev/null; then
      VAR_COUNT=$(echo "$ENV_VARS_JSON" | jq 'length')
      echo "$ENV_VARS_JSON" | jq -r 'to_entries[] | "\(.key)=\(.value)"' >> "$ENV_FILE"
      log_success "$VAR_COUNT variables ajoutées"
    else
      log_error "JSON invalide reçu"
      log_info "JSON reçu: $ENV_VARS_JSON"
      log_warn "Création d'un .env minimal par défaut"
      
      # Fallback: créer un .env minimal
      cat >> "$ENV_FILE" << EOL

# Default Configuration (invalid JSON received)
NODE_ENV=production
SECRET_KEY="$SECRET_KEY"
PORT=3000

EOL
    fi
  else
    log_warn "jq non installé - Variables personnalisées ignorées"
    log_info "Installation: sudo apt install jq"
    
    # Fallback: créer un .env minimal
    cat >> "$ENV_FILE" << EOL

# Default Configuration (jq not available)
NODE_ENV=production
SECRET_KEY="$SECRET_KEY"
PORT=3000

EOL
  fi
else
  # Aucune variable fournie, créer un .env minimal
  log_info "Aucune variable d'environnement fournie"
  log_info "Création d'un fichier .env minimal..."
  
  cat >> "$ENV_FILE" << EOL

# Default Configuration
NODE_ENV=production
SECRET_KEY="$SECRET_KEY"
PORT=3000

EOL
fi

# Sécuriser le fichier .env
chmod 600 "$ENV_FILE"

log_success "Fichier .env généré: $ENV_FILE"
log_info "Clé secrète: ${SECRET_KEY:0:16}..."
log_info "Permissions: 600 (lecture/écriture propriétaire uniquement)"
