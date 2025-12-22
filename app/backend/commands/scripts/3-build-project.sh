#!/bin/bash

set -euo pipefail

# Configuration des logs
log_info() { echo " $1"; }
log_success() { echo " $1"; }
log_warn() { echo "[WARN] $1"; }
log_error() { echo "[ERROR] $1"; }

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
  log_error "Arguments invalides"
  log_info "Usage: $0 <chemin-du-projet> [commande-build]"
  log_info "Exemple: $0 /var/www/project/valentine"
  log_info "Exemple: $0 /var/www/project/valentine \"npm run build\""
  exit 1
fi

PROJECT_DIR="$1"
BUILD_COMMAND="${2:-npm run build}"

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

# Extraire le script name de la commande (ex: "npm run build" -> "build")
SCRIPT_NAME=$(echo "$BUILD_COMMAND" | grep -oP 'run \K\w+' || echo "build")

# Vérification du script dans package.json
if ! grep -q "\"$SCRIPT_NAME\"" package.json; then
  log_warn "Aucun script \"$SCRIPT_NAME\" trouvé dans package.json"
  log_info "Scripts disponibles dans package.json:"
  grep -oP '"[^"]+"\s*:\s*"[^"]+"' package.json | grep -v "name\|version\|description" || log_info "  Aucun script trouvé"
fi

log_info "Lancement du build de production ($BUILD_COMMAND)..."
log_info "Cela peut prendre quelques minutes selon la taille du projet"

# Exécution du build avec gestion d'erreur
if eval "$BUILD_COMMAND" 2>&1; then
  log_success "Build terminé avec succès ! "
else
  log_error "Erreur lors du build. Vérifie les messages ci-dessus"
  exit 1
fi

