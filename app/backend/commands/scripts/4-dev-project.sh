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

if [ $# -lt 2 ] || [ $# -gt 3 ]; then
  log_error "2 ou 3 arguments requis"
  log_info "Usage: $0 <chemin-du-projet> <port> [start_command]"
  log_info "Exemple: $0 /var/www/project/valentine 3000"
  log_info "         $0 /var/www/project/valentine 3000 'npm run start'"
  exit 1
fi

PROJECT_DIR="$1"
PORT="$2"
START_COMMAND="${3:-npm run dev}"
PID_FILE="$PROJECT_DIR/.dev-server.pid"

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

################################################################################
# Fonction pour arrêter l'ancienne instance du projet
################################################################################
stop_existing_instance() {
  log_info "Vérification des instances existantes..."
  
  local old_pid=""
  local killed=false
  
  # Méthode 1: Vérifier le fichier PID
  if [ -f "$PID_FILE" ]; then
    old_pid=$(cat "$PID_FILE" 2>/dev/null || echo "")
    if [ -n "$old_pid" ] && kill -0 "$old_pid" 2>/dev/null; then
      log_warn "Instance existante trouvée (PID: $old_pid)"
      log_info "Arrêt de l'ancienne instance..."
      
      # Arrêt gracieux d'abord
      kill "$old_pid" 2>/dev/null || true
      sleep 2
      
      # Forcer l'arrêt si toujours actif
      if kill -0 "$old_pid" 2>/dev/null; then
        kill -9 "$old_pid" 2>/dev/null || true
        sleep 1
      fi
      
      killed=true
      log_success "Ancienne instance arrêtée"
    fi
    rm -f "$PID_FILE"
  fi
  
  # Méthode 2: Vérifier si quelque chose écoute sur le port
  local port_pid=""
  port_pid=$(lsof -ti :$PORT 2>/dev/null || echo "")
  
  if [ -n "$port_pid" ]; then
    log_warn "Processus détecté sur le port $PORT (PID: $port_pid)"
    
    # Vérifier si c'est un processus node lié à ce projet
    local proc_cwd=""
    proc_cwd=$(readlink -f /proc/$port_pid/cwd 2>/dev/null || echo "")
    
    if [ "$proc_cwd" = "$PROJECT_DIR" ] || [ "$killed" = false ]; then
      log_info "Arrêt du processus sur le port $PORT..."
      kill "$port_pid" 2>/dev/null || true
      sleep 2
      
      # Forcer si nécessaire
      if lsof -ti :$PORT >/dev/null 2>&1; then
        kill -9 $(lsof -ti :$PORT) 2>/dev/null || true
        sleep 1
      fi
      
      log_success "Port $PORT libéré"
    fi
  fi
  
  # Méthode 3: Utiliser pkill pour les processus node dans ce répertoire
  # Trouver et tuer les processus node qui ont ce répertoire comme cwd
  for pid in $(pgrep -f "node.*$PROJECT_DIR" 2>/dev/null || echo ""); do
    if [ -n "$pid" ] && [ "$pid" != "$$" ]; then
      log_info "Arrêt du processus node associé (PID: $pid)..."
      kill "$pid" 2>/dev/null || true
    fi
  done
  
  # Attendre que le port soit vraiment libre
  local wait_count=0
  while lsof -ti :$PORT >/dev/null 2>&1 && [ $wait_count -lt 10 ]; do
    sleep 1
    wait_count=$((wait_count + 1))
  done
  
  if lsof -ti :$PORT >/dev/null 2>&1; then
    log_error "Impossible de libérer le port $PORT"
    log_info "Processus utilisant le port:"
    lsof -i :$PORT 2>/dev/null || true
    exit 1
  fi
  
  log_success "Aucune instance en conflit"
}

################################################################################
# Obtenir l'IP locale de la machine
################################################################################
get_local_ip() {
  local ip=""
  
  # Méthode 1: hostname -I (Linux)
  ip=$(hostname -I 2>/dev/null | awk '{print $1}')
  
  # Méthode 2: ip route (Linux)
  if [ -z "$ip" ]; then
    ip=$(ip route get 1 2>/dev/null | awk '{print $7; exit}')
  fi
  
  # Méthode 3: ifconfig (fallback)
  if [ -z "$ip" ]; then
    ip=$(ifconfig 2>/dev/null | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -1)
  fi
  
  # Fallback à localhost si rien ne fonctionne
  if [ -z "$ip" ]; then
    ip="localhost"
  fi
  
  echo "$ip"
}

################################################################################
# Arrêter les anciennes instances avant de démarrer
################################################################################
stop_existing_instance

LOCAL_IP=$(get_local_ip)
DEPLOYMENT_URL="http://$LOCAL_IP:$PORT"

log_info "Lancement du projet en mode développement"
log_info "Projet : $PROJECT_DIR"
log_info "Port   : $PORT"
log_info "IP     : $LOCAL_IP"
log_info "Commande: $START_COMMAND"
log_info "URL    : $DEPLOYMENT_URL"

# Sauvegarder l'URL de déploiement dans un fichier
echo "$DEPLOYMENT_URL" > "$PROJECT_DIR/.deployment-url"

# Lancement avec le port personnalisé en arrière-plan
# --host 0.0.0.0 permet d'écouter sur toutes les interfaces réseau (accessible sur le LAN)
nohup $START_COMMAND -- --host 0.0.0.0 --port "$PORT" > "$PROJECT_DIR/dev-server.log" 2>&1 &
DEV_PID=$!

# Sauvegarder le PID pour pouvoir arrêter le serveur plus tard
echo "$DEV_PID" > "$PID_FILE"
log_success "Serveur lancé en arrière-plan (PID: $DEV_PID)"
log_info "PID sauvegardé dans: $PID_FILE"

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