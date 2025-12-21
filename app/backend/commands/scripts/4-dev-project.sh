#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

set -euo pipefail

# Configuration des logs
log_info() { echo " $1"; }
log_success() { echo " $1"; }
log_warn() { echo "[WARN] $1"; }
log_error() { echo "[ERROR] $1"; }

if [ $# -ne 2 ];then
  log_error "Deux arguments requis"
  log_info "Usage: $0 <chemin-du-projet> <port>"
  log_info "Exemple: $0 /var/www/project/valentine 3000"
  echo "         $0 /var/www/project/valentine 5000"
  exit 1
fi

PROJECT_DIR="$1"
PORT="$2"

# Vérification du dossier
if [ ! -d "$PROJECT_DIR" ]; then
  log_error "Le dossier $PROJECT_DIR n'existe pas"
  exit 1
fi

# Vérification package.json
if [ ! -f "$PROJECT_DIR/package.json" ]; then
  log_error "Aucun package.json trouvé dans $PROJECT_DIR"
  exit 1
fi

cd "$PROJECT_DIR" || exit 1

log_info "Lancement du projet en mode développement"
log_info "Projet : $PROJECT_DIR"
log_info "Port   : $PORT"
log_info "URL    : http://localhost:$PORT"

# Lancement avec le port personnalisé en arrière-plan
nohup npm run dev -- --port "$PORT" > "$PROJECT_DIR/dev-server.log" 2>&1 &
DEV_PID=$!
log_success "Serveur lancé en arrière-plan (PID: $DEV_PID)"

# Attendre que le serveur démarre (max 30 secondes)
log_info "Attente du démarrage du serveur..."
TIMEOUT=30
ELAPSED=0

while [ $ELAPSED -lt $TIMEOUT ]; do
  # Vérifier si le processus est toujours actif
  if ! kill -0 $DEV_PID 2>/dev/null; then
    log_error "Le serveur s'est arrêté de manière inattendue"
    log_info "Consultez le fichier $PROJECT_DIR/dev-server.log pour plus de détails"
    exit 1
  fi
  
  # Vérifier si le serveur répond sur le port (ou un port proche)
  if netstat -tuln 2>/dev/null | grep -q ":$PORT " || \
     ss -tuln 2>/dev/null | grep -q ":$PORT " || \
     lsof -i :$PORT 2>/dev/null | grep -q LISTEN; then
    log_success "Serveur démarré avec succès"
    log_info "Logs disponibles dans: $PROJECT_DIR/dev-server.log"
    exit 0
  fi
  
  sleep 2
  ELAPSED=$((ELAPSED + 2))
done

log_warn "Timeout: Le serveur prend plus de temps que prévu à démarrer"
log_info "Le serveur continue en arrière-plan (PID: $DEV_PID)"
log_info "Logs: $PROJECT_DIR/dev-server.log"

exit 0