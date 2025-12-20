#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ $# -ne 2 ]; then
  echo -e "${RED}Erreur : Deux arguments requis.${NC}"
  echo "Usage: $0 <chemin-du-dossier-cible> <url-du-repo-git>"
  echo "Exemple : $0 /var/www/project/mon-projet https://github.com/ton-user/mon-nuxt-app.git"
  exit 1
fi

TARGET_DIR="$1"
GIT_URL="$2"

# Si le dossier existe déjà et n'est pas vide → on arrête pour éviter d'écraser par accident
if [ -d "$TARGET_DIR" ] && [ "$(ls -A "$TARGET_DIR" 2>/dev/null)" ]; then
  echo -e "${RED}Erreur : $TARGET_DIR existe déjà et n'est pas vide.${NC}"
  echo "Supprime-le ou vide-le manuellement avant."
  exit 1
fi

# On repart de zéro proprement
rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR" || exit 1

echo -e "${GREEN}Dossier créé : $TARGET_DIR${NC}"

# Git clone
echo -e "${YELLOW}Clonage du dépôt : $GIT_URL${NC}"
git clone --depth 1 "$GIT_URL" .

if [ $? -ne 0 ]; then
  echo -e "${RED}Échec du git clone. Vérifie l'URL ou tes accès.${NC}"
  rm -rf "$TARGET_DIR"
  exit 1
fi

echo -e "${GREEN}Clone terminé${NC}"

# Vérification package.json
if [ ! -f "package.json" ]; then
  echo -e "${RED}Erreur : Aucun package.json trouvé dans le dépôt !${NC}"
  echo "npm install ne peut pas fonctionner sans ça."
  exit 1
fi

# npm install
echo -e "${YELLOW}Lancement de npm install...${NC}"
npm install

if [ $? -eq 0 ]; then
  echo -e "${GREEN}npm install terminé avec succès !${NC}"
else
  echo -e "${RED}Erreur lors de npm install${NC}"
  exit 1
fi

echo ""
echo -e "${GREEN}Projet prêt dans $TARGET_DIR 🚀${NC}"
echo -e "${YELLOW}Commandes suivantes :${NC}"
echo "  cd $TARGET_DIR"
echo "  npm run dev     # développement"
echo "  npm run build   # production (Netlify, etc.)"
