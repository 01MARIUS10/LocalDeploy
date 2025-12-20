#!/bin/bash

set -euo pipefail

# Configuration des logs
log_info() { echo "[INFO] $1"; }
log_success() { echo "[SUCCESS] $1"; }
log_warn() { echo "[WARN] $1"; }
log_error() { echo "[ERROR] $1"; }

BASE_PATH="/var/www/project"

# Validation des arguments
if [ $# -ne 1 ]; then
  log_error "Argument manquant"
  log_info "Usage: $0 <slug>"
  log_info "Example: $0 valentine"
  exit 1
fi

SLUG="$1"
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
  log_info "Nettoyage du répertoire existant..."
  
  # Supprimer tout le contenu du répertoire
  if rm -rf "$PROJECT_PATH"/* "$PROJECT_PATH"/.* 2>/dev/null; then
    log_success "Répertoire nettoyé"
  else
    log_warn "Certains fichiers n'ont pas pu être supprimés"
  fi
else
  log_info "Création du répertoire projet..."
  
  if mkdir -p "$PROJECT_PATH" 2>/dev/null; then
    log_success "Répertoire créé: $PROJECT_PATH"
  else
    log_error "Échec de la création du répertoire"
    exit 1
  fi
fi

# Configuration du fichier .env
ENV_FILE="$PROJECT_PATH/.env"

if [ -f "$ENV_FILE" ]; then
  log_info "Fichier .env existant détecté"
  log_warn "Conservation de la configuration existante"
else
  log_info "Génération du fichier .env..."
  
  # Générer une clé secrète sécurisée
  SECRET_KEY=$(openssl rand -hex 32 2>/dev/null || head -c32 /dev/urandom | xxd -p -c 64)
  
  cat > "$ENV_FILE" << EOL
# Environment Configuration
# Project: $SLUG
# Generated: $(date -Iseconds)

NODE_ENV=production

# Database
DATABASE_URL="postgresql://user:password@localhost:5432/$SLUG?schema=public"

# Security
SECRET_KEY="$SECRET_KEY"

# Server
PORT=3000

# API Configuration (optional)
# NUXT_PUBLIC_API_URL=https://api.example.com
# NUXT_PUBLIC_SITE_URL=https://$SLUG.example.com

EOL

  log_success "Fichier .env généré"
  log_info "Clé secrète: ${SECRET_KEY:0:16}..."
fi

# Configuration du .gitignore
GITIGNORE_FILE="$PROJECT_PATH/.gitignore"

if [ ! -f "$GITIGNORE_FILE" ]; then
  log_info "Création du fichier .gitignore..."
  
  cat > "$GITIGNORE_FILE" << EOL
# Environment
.env
.env.*
!.env.example

# Dependencies
node_modules/

# Build
.nuxt/
.output/
dist/

# Logs
*.log

# OS
.DS_Store
Thumbs.db
EOL

  log_success "Fichier .gitignore créé"
elif ! grep -q "^\.env$" "$GITIGNORE_FILE" 2>/dev/null; then
  echo ".env" >> "$GITIGNORE_FILE"
  log_info "Ajout de .env au .gitignore"
fi

# Résumé
log_success "Projet initialisé: $SLUG"
log_info "Emplacement: $PROJECT_PATH"
log_info "Configuration: $ENV_FILE"
log_info "Status: Prêt pour le clonage"
