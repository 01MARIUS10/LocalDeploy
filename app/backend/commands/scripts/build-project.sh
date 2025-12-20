#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ $# -ne 1 ]; then
  echo -e "${RED}Erreur : Un argument requis (chemin du projet).${NC}"
  echo "Usage: $0 <chemin-du-projet>"
  echo "Exemple: $0 /var/www/project/valentine"
  exit 1
fi

PROJECT_DIR="$1"

if [ ! -d "$PROJECT_DIR" ]; then
  echo -e "${RED}Erreur : Le dossier $PROJECT_DIR n'existe pas.${NC}"
  exit 1
fi

if [ ! -f "$PROJECT_DIR/package.json" ]; then
  echo -e "${RED}Erreur : Aucun package.json dans $PROJECT_DIR.${NC}"
  echo "Ce n'est pas un projet npm valide."
  exit 1
fi

cd "$PROJECT_DIR" || exit 1
echo -e "${GREEN}Entré dans le projet : $PROJECT_DIR${NC}"

# Vérification du script "build" dans package.json
if ! grep -q '"build"' package.json; then
  echo -e "${RED}Attention : Aucun script \"build\" trouvé dans package.json.${NC}"
  echo "Le projet ne semble pas configuré pour un build (ex: Nuxt, Next, Vite...)."
  exit 1
fi

echo -e "${YELLOW}Lancement du build de production (npm run build)...${NC}"
echo -e "${BLUE}Cela peut prendre quelques minutes selon la taille du projet.${NC}"

npm run build

if [ $? -eq 0 ]; then
  echo -e "${GREEN}Build terminé avec succès ! 🎉${NC}"
  echo ""
  echo -e "${GREEN}Le build est disponible dans :${NC}"
  echo "  $PROJECT_DIR/.output   (pour Nuxt 3 Nitro)"
  echo "  ou $PROJECT_DIR/dist   (pour certains configs)"
  echo ""
  echo -e "${YELLOW}Pour tester le build localement :${NC}"
  echo "  npm run preview"
  echo ""
  echo -e "${YELLOW}Pour déployer (ex: Netlify) :${NC}"
  echo "  Copie le dossier .output sur ton serveur ou connecte le repo à Netlify."
else
  echo -e "${RED}Erreur lors du build. Vérifie les messages ci-dessus.${NC}"
  exit 1
fi
