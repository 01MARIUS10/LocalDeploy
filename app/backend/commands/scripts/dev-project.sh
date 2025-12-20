#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ $# -ne 2 ]; then
  echo -e "${RED}Erreur : Deux arguments requis.${NC}"
  echo "Usage: $0 <chemin-du-projet> <port>"
  echo "Exemple: $0 /var/www/project/valentine 3000"
  echo "         $0 /var/www/project/valentine 5000"
  exit 1
fi

PROJECT_DIR="$1"
PORT="$2"

# Vérification du dossier
if [ ! -d "$PROJECT_DIR" ]; then
  echo -e "${RED}Erreur : Le dossier $PROJECT_DIR n'existe pas.${NC}"
  exit 1
fi

# Vérification package.json
if [ ! -f "$PROJECT_DIR/package.json" ]; then
  echo -e "${RED}Erreur : Aucun package.json trouvé dans $PROJECT_DIR.${NC}"
  exit 1
fi

cd "$PROJECT_DIR" || exit 1

echo -e "${GREEN}Lancement du projet en développement${NC}"
echo -e "${BLUE}Projet : $PROJECT_DIR${NC}"
echo -e "${BLUE}Port   : $PORT${NC}"
echo -e "${BLUE}URL    : http://localhost:$PORT${NC}"
echo -e "${YELLOW}Appuie sur Ctrl+C pour arrêter le serveur.${NC}"
echo ""

# Lancement avec le port personnalisé
# La syntaxe -- --port passe l'argument à Vite (npm run dev -- --port 3000)
npm run dev -- --port "$PORT"
