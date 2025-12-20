#!/bin/bash

set -euo pipefail

# Configuration des logs
log_info() { echo " $1"; }
log_success() { echo " $1"; }
log_warn() { echo "[WARN] $1"; }
log_error() { echo "[ERROR] $1"; }

if [ $# -ne 2 ]; then
  log_error "Deux arguments requis"
  log_info "Usage: $0 <chemin-du-dossier-cible> <url-du-repo-git>"
  log_info "Exemple: $0 /var/www/project/mon-projet https://github.com/user/app.git"
  exit 1
fi

TARGET_DIR="$1"
GIT_URL="$2"

# Si le dossier existe déjà et n'est pas vide, on le nettoie automatiquement
if [ -d "$TARGET_DIR" ] && [ "$(ls -A "$TARGET_DIR" 2>/dev/null)" ]; then
  log_warn "Le dossier $TARGET_DIR existe déjà et n'est pas vide"
  log_info "Nettoyage automatique du contenu..."
  rm -rf "$TARGET_DIR"/* "$TARGET_DIR"/.* 2>/dev/null || true
  log_success "Dossier nettoyé"
fi

# Création du dossier si nécessaire
if [ ! -d "$TARGET_DIR" ]; then
  mkdir -p "$TARGET_DIR"
  log_success "Dossier créé: $TARGET_DIR"
fi

cd "$TARGET_DIR" || exit 1

# Git clone
log_info "Clonage du dépôt: $GIT_URL"
git clone --depth 1 "$GIT_URL" .

if [ $? -ne 0 ]; then
  log_error "Échec du git clone"
  log_error "Vérifiez l'URL ou vos accès au dépôt"
  rm -rf "$TARGET_DIR"
  exit 1
fi

log_success "Clonage terminé"

# Vérification package.json
if [ ! -f "package.json" ]; then
  log_error "Aucun package.json trouvé dans le dépôt"
  log_error "npm install ne peut pas fonctionner sans package.json"
  exit 1
fi

log_info "package.json détecté"

# npm install
log_info "Installation des dépendances (npm install)..."
npm install

if [ $? -eq 0 ]; then
  log_success "npm install terminé avec succès"
else
  log_error "Échec de npm install"
  exit 1
fi

log_success "Projet prêt dans $TARGET_DIR"
