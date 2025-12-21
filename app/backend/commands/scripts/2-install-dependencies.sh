#!/bin/bash

set -euo pipefail

# Configuration des logs
log_info() { echo " $1"; }
log_success() { echo " $1"; }
log_warn() { echo "[WARN] $1"; }
log_error() { echo "[ERROR] $1"; }

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
  log_error "Arguments invalides"
  log_info "Usage: $0 <chemin-du-projet> [node-version]"
  log_info "Exemple: $0 /var/www/project/valentine"
  log_info "Exemple: $0 /var/www/project/valentine 22"
  exit 1
fi

PROJECT_DIR="$1"
NODE_VERSION="${2:-22}"

# Validation du répertoire
if [ ! -d "$PROJECT_DIR" ]; then
  log_error "Le dossier $PROJECT_DIR n'existe pas"
  exit 1
fi

cd "$PROJECT_DIR" || exit 1

# Vérification package.json
if [ ! -f "package.json" ]; then
  log_error "Aucun package.json trouvé dans $PROJECT_DIR"
  log_error "npm install ne peut pas fonctionner sans package.json"
  exit 1
fi

log_info "package.json détecté"

# Charger nvm et utiliser la version Node.js spécifiée
log_info "Configuration de Node.js version $NODE_VERSION..."

# Charger nvm si disponible
if [ -s "$HOME/.nvm/nvm.sh" ]; then
  export NVM_DIR="$HOME/.nvm"
  source "$NVM_DIR/nvm.sh"
  
  # Utiliser la version spécifiée
  if nvm use "$NODE_VERSION" 2>&1; then
    log_success "Node.js $NODE_VERSION activé"
    log_info "Version: $(node -v)"
  else
    log_warn "Impossible d'activer Node.js $NODE_VERSION"
    log_info "Installation de Node.js $NODE_VERSION..."
    
    if nvm install "$NODE_VERSION" 2>&1; then
      nvm use "$NODE_VERSION" 2>&1
      log_success "Node.js $NODE_VERSION installé et activé"
    else
      log_error "Échec de l'installation de Node.js $NODE_VERSION"
      exit 1
    fi
  fi
else
  log_warn "nvm non trouvé - Utilisation de la version Node.js système"
  log_info "Version actuelle: $(node -v 2>/dev/null || echo 'Node.js non installé')"
fi

# npm install
log_info "Installation des dépendances (npm install)..."
npm install

if [ $? -eq 0 ]; then
  log_success "npm install terminé avec succès"
else
  log_error "Échec de npm install"
  exit 1
fi

log_success "Dépendances installées dans $PROJECT_DIR"
