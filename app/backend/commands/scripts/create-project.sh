#!/bin/bash

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BASE_PATH="/var/www/project"

if [ $# -ne 1 ]; then
  echo -e "${RED}Erreur : Un argument est requis (le slug du projet).${NC}"
  echo "Usage: $0 <slug-du-projet>"
  echo "Exemple: $0 mon-nuxt-app"
  exit 1
fi

SLUG="$1"
PROJECT_PATH="$BASE_PATH/$SLUG"

echo -e "${YELLOW}=== Création du projet : $SLUG ===${NC}"

# Vérifier que le dossier parent existe et est accessible
if [ ! -d "$BASE_PATH" ]; then
  echo -e "${RED}Erreur : $BASE_PATH n'existe pas.${NC}"
  exit 1
fi

if [ ! -w "$BASE_PATH" ]; then
  echo -e "${RED}Erreur : Pas de droits d'écriture dans $BASE_PATH${NC}"
  exit 1
fi

# Créer le dossier du projet
if mkdir "$PROJECT_PATH" 2>/dev/null; then
  echo -e "${GREEN}Dossier créé : $PROJECT_PATH${NC}"
elif [ -d "$PROJECT_PATH" ]; then
  echo -e "${RED}Erreur : Le dossier $PROJECT_PATH existe déjà.${NC}"
  exit 1
else
  echo -e "${RED}Erreur inattendue lors de la création du dossier.${NC}"
  exit 1
fi

# Générer une clé secrète aléatoire sécurisée
SECRET_KEY=$(openssl rand -hex 32 2>/dev/null || head -c32 /dev/urandom | xxd -p -c 64)

# Créer le fichier .env
cat > "$PROJECT_PATH/.env" << EOL
# ===================================
# Variables d'environnement du projet
# ===================================

NODE_ENV=production

DATABASE_URL="postgresql://user:password@localhost:5432/$SLUG?schema=public"

SECRET_KEY="$SECRET_KEY"

PORT=3000

# NUXT_PUBLIC_API_URL=https://api.example.com
# NUXT_PUBLIC_SITE_URL=https://$SLUG.votredomaine.com

EOL

echo -e "${GREEN}Fichier .env créé avec une clé secrète aléatoire.${NC}"
echo -e "${BLUE}Contenu du .env :${NC}"
cat "$PROJECT_PATH/.env" | sed 's/^/  /'

echo ""
echo -e "${GREEN}Projet '$SLUG' créé avec succès dans $PROJECT_PATH${NC}"
echo -e "${YELLOW}N'oublie pas : echo '.env' >> $PROJECT_PATH/.gitignore${NC}"
