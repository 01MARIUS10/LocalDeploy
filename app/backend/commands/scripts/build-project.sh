#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ $# -ne 1 ]; then
  echo "[ERROR] Un argument requis (chemin du projet)."
  echo "[INFO] Usage: $0 <chemin-du-projet>"
  echo "[INFO] Exemple: $0 /var/www/project/valentine"
  exit 1
fi

PROJECT_DIR="$1"

# Validation du répertoire
if [ ! -d "$PROJECT_DIR" ]; then
  echo "[ERROR] Le dossier $PROJECT_DIR n'existe pas."
  exit 1
fi

# Validation du package.json
if [ ! -f "$PROJECT_DIR/package.json" ]; then
  echo "[ERROR] Aucun package.json dans $PROJECT_DIR."
  echo "[ERROR] Ce n'est pas un projet npm valide."
  exit 1
fi

# Try-catch avec trap pour capturer les erreurs
set -euo pipefail

trap 'catch_error $? $LINENO' ERR

catch_error() {
  local exit_code=$1
  local line_number=$2
  echo "[ERROR] Une erreur s'est produite à la ligne $line_number avec le code de sortie $exit_code"
  exit $exit_code
}

# Changement de répertoire
cd "$PROJECT_DIR" || {
  echo "[ERROR] Impossible d'accéder au répertoire $PROJECT_DIR"
  exit 1
}

echo "[SUCCESS] Entré dans le projet : $PROJECT_DIR"

# Vérification du script "build" dans package.json
if ! grep -q '"build"' package.json; then
  echo "[WARN] Aucun script \"build\" trouvé dans package.json."
  echo "[ERROR] Le projet ne semble pas configuré pour un build (ex: Nuxt, Next, Vite...)."
  exit 1
fi

echo "[INFO] Lancement du build de production (npm run build)..."
echo "[INFO] Cela peut prendre quelques minutes selon la taille du projet."

# Exécution du build avec gestion d'erreur
if npm run build 2>&1; then
  echo "[SUCCESS] Build terminé avec succès ! 🎉"
  echo ""
  echo "[INFO] Le build est disponible dans :"
  echo "[INFO]   $PROJECT_DIR/.output   (pour Nuxt 3 Nitro)"
  echo "[INFO]   ou $PROJECT_DIR/dist   (pour certains configs)"
  echo ""
  echo "[INFO] Pour tester le build localement :"
  echo "[INFO]   npm run preview"
  echo ""
  echo "[INFO] Pour déployer (ex: Netlify) :"
  echo "[INFO]   Copie le dossier .output sur ton serveur ou connecte le repo à Netlify."
else
  echo "[ERROR] Erreur lors du build. Vérifie les messages ci-dessus."
  exit 1
fi
