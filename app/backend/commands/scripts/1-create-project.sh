#!/bin/bash

set -euo pipefail

# Configuration des logs
log_info() { echo " $1"; }
log_success() { echo " $1"; }
log_warn() { echo "[WARN] $1"; }
log_error() { echo "[ERROR] $1"; }

BASE_PATH="/var/www/project"

# Validation des arguments
if [ $# -lt 1 ] || [ $# -gt 3 ]; then
  log_error "Arguments invalides"
  log_info "Usage: $0 <slug> [repo-url] [env-vars-json]"
  log_info "Exemple: $0 valentine"
  log_info "Exemple: $0 valentine https://github.com/user/app.git"
  log_info "Exemple: $0 valentine https://github.com/user/app.git '{\"NODE_ENV\":\"prod\"}'"
  exit 1
fi

SLUG="$1"
REPO_URL="${2:-}"
ENV_VARS_BASE64="${3:-}"
PROJECT_PATH="$BASE_PATH/$SLUG"

log_info "Initialisation du projet: $SLUG"
log_info "Destination: $PROJECT_PATH"

# Créer le répertoire de base si nécessaire
if [ ! -d "$BASE_PATH" ]; then
  log_warn "Le répertoire $BASE_PATH n'existe pas"
  log_info "Création du répertoire de base..."
  
  if sudo mkdir -p "$BASE_PATH" 2>/dev/null; then
    log_success "Répertoire de base créé: $BASE_PATH"
    sudo chown -R $USER:$USER "$BASE_PATH"
    log_info "Permissions configurées"
  else
    log_error "Impossible de créer $BASE_PATH"
    log_error "Exécutez: sudo mkdir -p $BASE_PATH && sudo chown -R \$USER:\$USER $BASE_PATH"
    exit 1
  fi
fi

# Vérifier les permissions d'écriture
if [ ! -w "$BASE_PATH" ]; then
  log_warn "Permissions insuffisantes sur $BASE_PATH"
  log_info "Correction des permissions..."
  sudo chown -R $USER:$USER "$BASE_PATH"
  
  if [ ! -w "$BASE_PATH" ]; then
    log_error "Impossible d'obtenir les permissions d'écriture"
    exit 1
  fi
  
  log_success "Permissions corrigées"
fi

# Gérer le répertoire du projet
if [ -d "$PROJECT_PATH" ]; then
  log_warn "Le projet existe déjà: $PROJECT_PATH"
  log_info "Suppression complète du répertoire existant..."
  
  # Supprimer complètement le répertoire
  if rm -rf "$PROJECT_PATH"; then
    log_success "Répertoire supprimé"
  else
    log_error "Impossible de supprimer le répertoire"
    exit 1
  fi
fi

# Créer le répertoire projet
log_info "Création du répertoire projet..."
if mkdir -p "$PROJECT_PATH" 2>/dev/null; then
  log_success "Répertoire créé: $PROJECT_PATH"
else
  log_error "Échec de la création du répertoire"
  exit 1
fi

# Si une URL de repository est fournie, cloner le projet
if [ -n "$REPO_URL" ]; then
  log_info "Clonage du dépôt: $REPO_URL"
  
  cd "$PROJECT_PATH" || exit 1
  
  if git clone --depth 1 "$REPO_URL" . 2>&1; then
    log_success "Clonage terminé"
  else
    log_error "Échec du git clone"
    log_error "Vérifiez l'URL ou vos accès au dépôt"
    rm -rf "$PROJECT_PATH"
    exit 1
  fi
  
  # Vérifier package.json après le clone
  if [ ! -f "$PROJECT_PATH/package.json" ]; then
    log_error "Aucun package.json trouvé dans le dépôt"
    log_error "Ce n'est pas un projet Node.js valide"
    rm -rf "$PROJECT_PATH"
    exit 1
  fi
  
  log_info "package.json détecté"
fi

# Générer le fichier .env via le script dédié
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$SCRIPT_DIR/generate-env.sh" ]; then
  log_info "Appel du script de génération .env..."
  # Passer le base64 directement, sans décoder
  bash "$SCRIPT_DIR/generate-env.sh" "$PROJECT_PATH" "$SLUG" "$ENV_VARS_BASE64" 2>&1
  
  if [ $? -eq 0 ]; then
    log_success "Configuration .env générée"
  else
    log_warn "Échec de la génération du .env"
  fi
else
  log_warn "Script generate-env.sh introuvable"
  log_info "Le fichier .env devra être créé manuellement"
fi

# Résumé
log_success "----------------------------"
log_success "Projet initialisé: $SLUG"
log_info "Emplacement: $PROJECT_PATH"
