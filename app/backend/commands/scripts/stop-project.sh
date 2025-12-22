#!/bin/bash
################################################################################
# Script: stop-project.sh
# Description: Arrête un projet déployé
# Usage: ./stop-project.sh <chemin-du-projet> [port]
################################################################################

set -euo pipefail

# Configuration des logs
log_info() { echo " $1"; }
log_success() { echo " $1"; }
log_warn() { echo "[WARN] $1"; }
log_error() { echo "[ERROR] $1"; }

if [ $# -lt 1 ]; then
  log_error "Argument manquant"
  log_info "Usage: $0 <chemin-du-projet> [port]"
  log_info "Exemple: $0 /var/www/project/valentine"
  log_info "Exemple: $0 /var/www/project/valentine 3000"
  exit 1
fi

PROJECT_DIR="$1"
PORT="${2:-}"
PID_FILE="$PROJECT_DIR/.dev-server.pid"

log_info "Arrêt du projet: $PROJECT_DIR"

stopped=false

# Méthode 1: Utiliser le fichier PID
if [ -f "$PID_FILE" ]; then
  old_pid=$(cat "$PID_FILE" 2>/dev/null || echo "")
  if [ -n "$old_pid" ]; then
    if kill -0 "$old_pid" 2>/dev/null; then
      log_info "Arrêt du processus (PID: $old_pid)..."
      kill "$old_pid" 2>/dev/null || true
      sleep 2
      
      # Forcer si toujours actif
      if kill -0 "$old_pid" 2>/dev/null; then
        log_warn "Arrêt forcé du processus..."
        kill -9 "$old_pid" 2>/dev/null || true
      fi
      
      stopped=true
      log_success "Processus arrêté"
    else
      log_info "Le processus $old_pid n'est plus actif"
    fi
    rm -f "$PID_FILE"
  fi
fi

# Méthode 2: Arrêter par port si spécifié
if [ -n "$PORT" ]; then
  port_pid=$(lsof -ti :$PORT 2>/dev/null || echo "")
  if [ -n "$port_pid" ]; then
    log_info "Arrêt du processus sur le port $PORT (PID: $port_pid)..."
    kill "$port_pid" 2>/dev/null || true
    sleep 2
    
    if lsof -ti :$PORT >/dev/null 2>&1; then
      kill -9 $(lsof -ti :$PORT) 2>/dev/null || true
    fi
    
    stopped=true
    log_success "Port $PORT libéré"
  fi
fi

# Méthode 3: Chercher les processus node liés au projet
for pid in $(pgrep -f "node.*$PROJECT_DIR" 2>/dev/null || echo ""); do
  if [ -n "$pid" ]; then
    log_info "Arrêt du processus node (PID: $pid)..."
    kill "$pid" 2>/dev/null || true
    stopped=true
  fi
done

# Nettoyer les fichiers temporaires
rm -f "$PROJECT_DIR/.dev-server.pid"
rm -f "$PROJECT_DIR/.deployment-url"

if [ "$stopped" = true ]; then
  log_success "Projet arrêté avec succès"
else
  log_info "Aucun processus actif trouvé pour ce projet"
fi

exit 0
