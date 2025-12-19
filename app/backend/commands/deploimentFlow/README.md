# LocalDeploy - Scripts de Déploiement Automatisé

Ce dossier contient tous les scripts shell nécessaires pour automatiser le déploiement de projets React/Vue/Node.js sur un serveur local.

## 📁 Structure des Scripts

```
deploimentFlow/
├── 00-setup-environment.sh    # Configuration initiale du serveur
├── 01-clone-repo.sh            # Clonage du dépôt Git
├── 02-setup-env.sh             # Configuration des variables d'environnement
├── 03-build-project.sh         # Build du projet (npm install && build)
├── 04-create-release.sh        # Création d'une release avec versioning
├── 05-deploy-release.sh        # Déploiement atomique de la release
├── 06-setup-nginx.sh           # Configuration de Nginx
├── 07-health-check.sh          # Vérification de santé du déploiement
├── 08-rollback.sh              # Rollback vers une version précédente
├── deploy-full.sh              # Script maître (exécute toutes les étapes)
└── README.md                   # Ce fichier
```

## 🚀 Utilisation Rapide

### Déploiement Complet Automatisé

```bash
# Donner les permissions d'exécution
chmod +x deploimentFlow/*.sh

# Lancer le déploiement complet
sudo ./deploimentFlow/deploy-full.sh \
  monprojetreact \
  https://github.com/user/MonProjetReact.git \
  main \
  monprojet.local \
  80
```

**Paramètres:**
- `monprojetreact` : Slug du projet (identifiant unique)
- `https://github.com/user/MonProjetReact.git` : URL du dépôt Git
- `main` : Branche à déployer
- `monprojet.local` : Nom de domaine local
- `80` : Port HTTP (optionnel, défaut: 80)

## 📋 Scripts Individuels

### 0️⃣ Configuration de l'environnement

**Premier déploiement uniquement** - Configure le serveur avec Node.js, Nginx, utilisateurs, etc.

```bash
sudo ./00-setup-environment.sh
```

**Ce script installe:**
- Node.js (version 22 par défaut)
- npm
- Nginx
- Git et outils essentiels
- Crée l'utilisateur `deployuser`
- Configure les répertoires `/var/projects/LocalDeploy`

### 1️⃣ Cloner le dépôt

```bash
sudo ./01-clone-repo.sh <project_slug> <repo_url> <branch>

# Exemple
sudo ./01-clone-repo.sh monprojetreact https://github.com/user/repo.git main
```

**Ce script:**
- Clone le dépôt Git (ou le met à jour si existant)
- Crée la structure de répertoires (repo, releases, shared, logs)
- Sauvegarde les informations du commit

### 2️⃣ Configurer les variables d'environnement

```bash
sudo ./02-setup-env.sh <project_slug> [template_file]

# Exemple avec template par défaut
sudo ./02-setup-env.sh monprojetreact

# Exemple avec template personnalisé
sudo ./02-setup-env.sh monprojetreact /path/to/.env.production
```

**Ce script:**
- Crée un fichier `.env` dans `shared/`
- Configure les permissions (600 pour la sécurité)
- Génère un script d'injection de variables

**⚠️ Important:** Éditez ensuite `/var/projects/LocalDeploy/monprojetreact/shared/.env` pour ajouter vos vraies valeurs.

### 3️⃣ Build du projet

```bash
sudo ./03-build-project.sh <project_slug>

# Exemple
sudo ./03-build-project.sh monprojetreact
```

**Ce script:**
- Exécute `npm ci` (installation propre)
- Exécute `npm run build`
- Charge les variables d'environnement
- Génère un manifeste de build avec métadonnées
- Logs sauvegardés dans `logs/build-*.log`

**Personnalisation:**
- Variable `BUILD_DIR` pour changer le répertoire de sortie (défaut: `dist`)

### 4️⃣ Créer une release

```bash
sudo ./04-create-release.sh <project_slug>

# Exemple
sudo ./04-create-release.sh monprojetreact
```

**Ce script:**
- Copie le build dans `releases/<timestamp>/`
- Crée des métadonnées de release (commit, date, taille)
- Nettoie les anciennes releases (garde les 5 plus récentes)

**Format de release:** `YYYYMMDD-HHMMSS` (ex: `20240115-143022`)

### 5️⃣ Déployer la release

```bash
sudo ./05-deploy-release.sh <project_slug> <release_id>

# Exemple
sudo ./05-deploy-release.sh monprojetreact 20240115-143022
```

**Ce script:**
- Déploiement **atomique** via symlink
- Sauvegarde la release précédente pour rollback
- Met à jour le lien `current` → nouvelle release
- Enregistre dans l'historique de déploiement

**Déploiement zéro-downtime:** Le changement de symlink est instantané.

### 6️⃣ Configurer Nginx

```bash
sudo ./06-setup-nginx.sh <project_slug> <domain> [port]

# Exemple
sudo ./06-setup-nginx.sh monprojetreact monprojet.local 80
```

**Ce script:**
- Crée la configuration Nginx dans `/etc/nginx/sites-available/`
- Active le site (symlink vers `sites-enabled/`)
- Configure le SPA fallback (pour React Router, etc.)
- Ajoute compression gzip
- Configure les logs dédiés
- Ajoute le domaine à `/etc/hosts`
- Recharge Nginx

**Fonctionnalités:**
- Endpoint `/health` pour healthcheck
- Cache des assets statiques (1 an)
- Headers de sécurité (X-Frame-Options, etc.)

### 7️⃣ Health Check

```bash
sudo ./07-health-check.sh <project_slug> [domain] [port]

# Exemple
sudo ./07-health-check.sh monprojetreact monprojet.local 80
```

**Ce script vérifie:**
- ✅ Répertoire projet et release déployée
- ✅ Configuration Nginx valide
- ✅ Nginx écoute sur le bon port
- ✅ Connexion HTTP (code 200)
- ✅ Temps de réponse < 1s
- ✅ Endpoint `/health` disponible
- ✅ Contenu HTML valide
- ✅ Assets présents (CSS, JS, images)
- ✅ Pas d'erreurs critiques dans les logs

**Codes de sortie:**
- `0` : Tous les tests passés ✅
- `1` : Quelques avertissements ⚠️
- `2` : Problèmes critiques ❌

### 8️⃣ Rollback

```bash
sudo ./08-rollback.sh <project_slug> [release_id]

# Rollback vers la version précédente (automatique)
sudo ./08-rollback.sh monprojetreact

# Rollback vers une release spécifique
sudo ./08-rollback.sh monprojetreact 20240115-143022
```

**Ce script:**
- Restaure la release précédente (ou spécifiée)
- Déploiement atomique via symlink
- Recharge Nginx automatiquement
- Sauvegarde l'historique de rollback

**Sécurité:** Demande confirmation avant d'effectuer le rollback.

## 🏗️ Architecture de Déploiement

```
/var/projects/LocalDeploy/
└── monprojetreact/
    ├── repo/                    # Clone Git
    │   ├── .git/
    │   ├── src/
    │   ├── package.json
    │   └── dist/               # Build non versionné
    ├── releases/               # Releases versionnées
    │   ├── 20240115-143022/   # Release 1
    │   ├── 20240115-150845/   # Release 2
    │   └── 20240115-163012/   # Release 3 (actuelle)
    ├── shared/                 # Fichiers partagés
    │   └── .env               # Variables d'environnement
    ├── logs/                   # Logs de déploiement
    │   ├── build-*.log
    │   ├── deploy-history.log
    │   └── clone-info.json
    ├── current → releases/20240115-163012/   # Symlink vers release active
    └── previous → releases/20240115-150845/  # Symlink pour rollback

/var/www/html/
└── (Nginx peut pointer ici, mais on préfère pointer vers current/)

/etc/nginx/sites-available/
└── monprojetreact              # Config Nginx

/etc/nginx/sites-enabled/
└── monprojetreact → ../sites-available/monprojetreact
```

## 🔧 Configuration

### Variables d'Environnement

Toutes les variables peuvent être surchargées:

```bash
# Utilisateur de déploiement
export DEPLOY_USER="myuser"

# Répertoire de base des projets
export PROJECT_BASE="/opt/projects"

# Document root Nginx
export WEB_ROOT="/var/www"

# Version Node.js
export NODE_VERSION="20"

# Répertoire de build
export BUILD_DIR="build"  # ou "public" pour Gatsby, etc.

# Nombre max de releases à garder
export MAX_RELEASES="10"
```

### Personnalisation du Build

Si votre projet utilise un répertoire de sortie différent:

```bash
export BUILD_DIR="build"  # Pour Create React App
export BUILD_DIR="public" # Pour Gatsby
export BUILD_DIR="out"    # Pour Next.js static export

sudo ./03-build-project.sh monprojetreact
```

## 📊 Monitoring et Logs

### Logs de Déploiement

```bash
# Historique complet des déploiements
cat /var/projects/LocalDeploy/monprojetreact/logs/deploy-history.log

# Dernier build
ls -t /var/projects/LocalDeploy/monprojetreact/logs/build-*.log | head -1 | xargs cat
```

### Logs Nginx

```bash
# Logs d'accès (temps réel)
tail -f /var/log/nginx/monprojetreact_access.log

# Logs d'erreur
tail -f /var/log/nginx/monprojetreact_error.log

# Statistiques d'accès
cat /var/log/nginx/monprojetreact_access.log | awk '{print $1}' | sort | uniq -c | sort -rn
```

### Métadonnées de Release

```bash
# Informations de la release active
cat /var/projects/LocalDeploy/monprojetreact/current/.release-metadata.json | jq .

# Exemple de sortie:
# {
#   "release_id": "20240115-163012",
#   "project_slug": "monprojetreact",
#   "created_at": "2024-01-15T16:30:12+00:00",
#   "commit": {
#     "hash": "a1b2c3d4e5f6...",
#     "message": "Add new feature",
#     "author": "John Doe"
#   },
#   "deployed": true,
#   "deployed_at": "2024-01-15T16:32:45+00:00"
# }
```

## 🛠️ Troubleshooting

### Le build échoue

```bash
# Vérifier les logs
tail -100 /var/projects/LocalDeploy/monprojetreact/logs/build-*.log

# Vérifier les dépendances
cd /var/projects/LocalDeploy/monprojetreact/repo
npm list

# Nettoyer et rebuilder
sudo rm -rf node_modules package-lock.json
sudo -u deployuser npm install
```

### Nginx retourne 403/404

```bash
# Vérifier les permissions
ls -la /var/projects/LocalDeploy/monprojetreact/current/

# Vérifier le symlink
readlink -f /var/projects/LocalDeploy/monprojetreact/current

# Vérifier la config Nginx
sudo nginx -t
sudo cat /etc/nginx/sites-available/monprojetreact
```

### Le site ne répond pas

```bash
# Vérifier que Nginx tourne
systemctl status nginx

# Vérifier qu'il écoute sur le bon port
netstat -tlnp | grep :80

# Tester la connexion
curl -I http://monprojet.local

# Faire un health check complet
sudo ./07-health-check.sh monprojetreact monprojet.local 80
```

### Rollback urgent

```bash
# Rollback immédiat vers la version précédente
sudo ./08-rollback.sh monprojetreact

# Ou vers une release spécifique
ls /var/projects/LocalDeploy/monprojetreact/releases/
sudo ./08-rollback.sh monprojetreact 20240115-143022
```

## 🔐 Sécurité

### Permissions

- Fichier `.env` : `600` (lecture seule par le propriétaire)
- Scripts de déploiement : `755` (exécution par tous)
- Releases : `755` (lecture par Nginx/www-data)

### Utilisateurs

- `deployuser` : Propriétaire des fichiers de projet
- `www-data` : Groupe pour accès Nginx

### Bonnes Pratiques

1. **Jamais commiter le `.env`** dans Git
2. **Utiliser HTTPS** en production (avec Let's Encrypt)
3. **Configurer un firewall** (UFW)
4. **Sauvegarder régulièrement** les releases
5. **Monitorer les logs** Nginx
6. **Tester le rollback** régulièrement

## 🚦 Workflow de Déploiement

### Déploiement Initial

```bash
# 1. Configuration du serveur (première fois seulement)
sudo ./00-setup-environment.sh

# 2. Déploiement complet
sudo ./deploy-full.sh monprojetreact https://github.com/user/repo.git main monprojet.local

# 3. Vérifier
curl http://monprojet.local
```

### Mise à Jour du Code

```bash
# Option 1: Redéploiement complet (recommandé)
sudo ./deploy-full.sh monprojetreact https://github.com/user/repo.git main monprojet.local

# Option 2: Étapes manuelles
sudo ./01-clone-repo.sh monprojetreact https://github.com/user/repo.git main
sudo ./03-build-project.sh monprojetreact
sudo ./04-create-release.sh monprojetreact
RELEASE=$(ls -t /var/projects/LocalDeploy/monprojetreact/releases | head -1)
sudo ./05-deploy-release.sh monprojetreact $RELEASE
sudo ./07-health-check.sh monprojetreact monprojet.local
```

### Rollback

```bash
# En cas de problème
sudo ./08-rollback.sh monprojetreact

# Vérifier
sudo ./07-health-check.sh monprojetreact monprojet.local
```

## 📚 Ressources

- [Nginx Documentation](https://nginx.org/en/docs/)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)
- [Deployment Strategies](https://martinfowler.com/bliki/BlueGreenDeployment.html)

## 📝 License

MIT License - Ces scripts sont fournis tels quels, sans garantie.

## 👥 Support

En cas de problème:
1. Consultez les logs
2. Lancez le health check
3. Vérifiez la configuration Nginx
4. Tentez un rollback si nécessaire

---

**🎉 Bon déploiement !**
