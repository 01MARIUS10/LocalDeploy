#!/bin/bash

set -euo pipefail

# Configuration des logs
log_info() { echo " $1"; }
log_success() { echo " $1"; }
log_warn() { echo "[WARN] $1"; }
log_error() { echo "[ERROR] $1"; }

if [ $# -ne 1 ]; then
  log_error "Un argument requis (chemin du projet)"
  log_info "Usage: $0 <chemin-du-projet>"
  log_info "Exemple: $0 /var/www/project/valentine"
  exit 1
fi

PROJECT_DIR="$1"

# Validation du répertoire
if [ ! -d "$PROJECT_DIR" ]; then
  log_error "Le dossier $PROJECT_DIR n'existe pas"
  exit 1
fi

# Validation du package.json
if [ ! -f "$PROJECT_DIR/package.json" ]; then
  log_error "Aucun package.json dans $PROJECT_DIR"
  log_error "Ce n'est pas un projet npm valide"
  exit 1
fi

# Try-catch avec trap pour capturer les erreurs
trap 'catch_error $? $LINENO' ERR

catch_error() {
  local exit_code=$1
  local line_number=$2
  log_error "Une erreur s'est produite à la ligne $line_number avec le code de sortie $exit_code"
  exit $exit_code
}

# Changement de répertoire
cd "$PROJECT_DIR" || {
  log_error "Impossible d'accéder au répertoire $PROJECT_DIR"
  exit 1
}

log_success "Entré dans le projet : $PROJECT_DIR"

# Vérification du script "build" dans package.json
if ! grep -q '"build"' package.json; then
  log_warn "Aucun script \"build\" trouvé dans package.json"
  log_error "Le projet ne semble pas configuré pour un build (ex: Nuxt, Next, Vite...)"
  exit 1
fi

log_info "Lancement du build de production (npm run build)..."
log_info "Cela peut prendre quelques minutes selon la taille du projet"

# Exécution du build avec gestion d'erreur
if npm run build 2>&1; then
  log_success "Build terminé avec succès ! "
else
  log_error "Erreur lors du build. Vérifie les messages ci-dessus"
  exit 1
fi
