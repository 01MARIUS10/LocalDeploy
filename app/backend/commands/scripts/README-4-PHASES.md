# Système de Déploiement en 4 Phases avec Logs en Temps Réel

Ce système orchestre le déploiement complet d'un projet en 4 phases séquentielles avec affichage des logs en temps réel.

## 🎯 Architecture

### Les 4 Phases de Déploiement

```
┌─────────────────────────────────────────────────────────────┐
│                  DÉPLOIEMENT EN 4 PHASES                    │
└─────────────────────────────────────────────────────────────┘

   PHASE 1                 PHASE 2                 PHASE 3               PHASE 4
┌──────────┐           ┌──────────┐           ┌──────────┐         ┌──────────┐
│ CREATE   │    →      │  CLONE   │    →      │  BUILD   │    →    │   DEV    │
│ PROJECT  │           │  & INSTALL│           │ PROJECT  │         │ SERVER   │
└──────────┘           └──────────┘           └──────────┘         └──────────┘
     ↓                      ↓                      ↓                     ↓
 Crée le             Clone Git +            npm run build          npm run dev
 dossier            npm install                                    sur port X
```

### Scripts Shell

#### 1. **deploy-orchestrator.sh** (Maître)
Orchestre l'exécution séquentielle des 4 phases.

**Usage:**
```bash
./deploy-orchestrator.sh <slug> <repo_url> <port>
```

**Exemple:**
```bash
./deploy-orchestrator.sh valentine https://github.com/user/project.git 3000
```

#### 2. **create-project.sh** (Phase 1)
Crée le dossier du projet dans `/var/www/project/`.

**Usage:**
```bash
./create-project.sh <slug>
```

#### 3. **clone-and-install.sh** (Phase 2)
Clone le dépôt Git et installe les dépendances npm.

**Usage:**
```bash
./clone-and-install.sh <target_dir> <repo_url>
```

#### 4. **build-project.sh** (Phase 3)
Build le projet pour la production.

**Usage:**
```bash
./build-project.sh <project_dir>
```

#### 5. **dev-project.sh** (Phase 4)
Démarre le serveur de développement avec PM2.

**Usage:**
```bash
./dev-project.sh <project_dir> <port>
```

## 📡 API de Streaming

### Endpoint

```
GET /api/projects/deploy-stream?slug=<project_slug>
```

### Authentification

Headers requis:
```
Authorization: Bearer <jwt_token>
```

### Format des Événements SSE

L'API envoie des événements Server-Sent Events au format JSON:

```typescript
interface SSEEvent {
  type: 'start' | 'phase' | 'info' | 'log' | 'warn' | 'error' | 'success' | 'complete' | 'end'
  message?: string
  code?: number
  error?: string
}
```

### Types d'Événements

| Type | Description | Couleur UI |
|------|-------------|------------|
| `start` | Démarrage du déploiement | Bleu |
| `phase` | Début d'une nouvelle phase | Violet (gras) |
| `info` | Information générale | Bleu |
| `log` | Log brut (npm, git, etc.) | Gris |
| `warn` | Avertissement | Jaune |
| `error` | Erreur | Rouge |
| `success` | Succès d'une étape | Vert |
| `complete` | Déploiement terminé | Vert (gras) |
| `end` | Fin du stream | Cyan |

### Exemple de Stream

```
data: {"type":"start","message":"Démarrage du déploiement en 4 phases..."}

data: {"type":"phase","message":"1/4 - Création du dossier projet"}

data: {"type":"info","message":"Projet: valentine"}

data: {"type":"success","message":"Phase 1 terminée : Dossier créé"}

data: {"type":"phase","message":"2/4 - Clone du dépôt et installation"}

data: {"type":"log","message":"Cloning into '/var/www/project/valentine'..."}

data: {"type":"success","message":"Phase 2 terminée : Code cloné"}

data: {"type":"phase","message":"3/4 - Build de production"}

data: {"type":"log","message":"> nuxt build"}

data: {"type":"success","message":"Phase 3 terminée : Build réussi"}

data: {"type":"phase","message":"4/4 - Démarrage du serveur"}

data: {"type":"success","message":"Phase 4 terminée : Serveur démarré"}

data: {"type":"complete","message":"✅ DÉPLOIEMENT TERMINÉ AVEC SUCCÈS !","code":0}

data: {"type":"end"}
```

## 🎨 Interface Utilisateur

### Composant Detail.vue

Le composant affiche:
1. **Bouton "Déployer"** avec état de chargement
2. **Console de logs** en temps réel (style terminal)
3. **Coloration syntaxique** selon le type de log
4. **Auto-scroll** vers le bas
5. **Bouton "Effacer"** pour nettoyer les logs

### Coloration des Logs

```typescript
[PHASE] → Violet gras (grande phase)
[ERROR] → Rouge gras
[SUCCESS] → Vert gras
[WARN] → Jaune
[INFO] → Bleu
═══════ → Gris (séparateurs)
🚀 🏁 → Cyan gras (début/fin)
logs bruts → Gris clair
```

### Exemple Visuel

```
🚀 Démarrage du déploiement du projet: valentine
⏰ 20/12/2025 16:30:00
────────────────────────────────────────────────────────────

═══════════════════════════════════════════════════════════
[PHASE] 1/4 - Création du dossier projet
═══════════════════════════════════════════════════════════
[INFO] Projet: valentine
[SUCCESS] Phase 1 terminée : Dossier créé

═══════════════════════════════════════════════════════════
[PHASE] 2/4 - Clone du dépôt et installation
═══════════════════════════════════════════════════════════
[INFO] Clonage en cours...
Cloning into '/var/www/project/valentine'...
[INFO] Installation des dépendances...
added 1234 packages in 45s
[SUCCESS] Phase 2 terminée : Code cloné et dépendances installées

═══════════════════════════════════════════════════════════
[PHASE] 3/4 - Build de production
═══════════════════════════════════════════════════════════
[INFO] Lancement du build...
> nuxt build
ℹ Building Nuxt...
✔ Build completed in 52.3s
[SUCCESS] Phase 3 terminée : Build réussi

═══════════════════════════════════════════════════════════
[PHASE] 4/4 - Démarrage du serveur
═══════════════════════════════════════════════════════════
[INFO] Démarrage avec PM2...
[PM2] Starting app valentine
[PM2] Done
[SUCCESS] Phase 4 terminée : Serveur démarré sur le port 3000

═══════════════════════════════════════════════════════════
✅ DÉPLOIEMENT TERMINÉ AVEC SUCCÈS !
✅ Code de sortie: 0
═══════════════════════════════════════════════════════════
🏁 Déploiement terminé à 20/12/2025 16:35:12
```

## 🚀 Utilisation

### 1. Depuis l'interface web

1. Aller sur la page de détail d'un projet
2. Cliquer sur le bouton **"Déployer"**
3. Observer les logs en temps réel

### 2. Depuis l'API directement

```bash
# Avec curl (nécessite un token JWT)
curl -N \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  "http://localhost:3000/api/projects/deploy-stream?slug=valentine"
```

### 3. Depuis un script shell

```bash
#!/bin/bash
cd app/backend/commands/scripts
chmod +x *.sh
./deploy-orchestrator.sh valentine https://github.com/user/project.git 3000
```

## 🛡️ Gestion des Erreurs

### Dans les Scripts Shell

Tous les scripts utilisent:
```bash
set -euo pipefail  # Mode strict
trap 'catch_error $? $LINENO' ERR  # Capture les erreurs
```

### Dans l'API

- ✅ Authentification JWT requise
- ✅ Vérification du propriétaire du projet
- ✅ Validation des paramètres
- ✅ Enregistrement en base de données
- ✅ Kill du processus si déconnexion client
- ✅ Gestion des erreurs avec try-catch

### En Cas d'Échec

Si une phase échoue:
1. Le script s'arrête immédiatement
2. Un message d'erreur est envoyé
3. Le statut du projet devient "error"
4. Les logs sont sauvegardés en base de données

## 📊 Base de Données

### Table Deployment

Chaque déploiement est enregistré:

```prisma
model Deployment {
  id          Int      @id @default(autoincrement())
  status      String   // "success" ou "failed"
  logs        String?  // Tous les logs du déploiement
  commitHash  String?
  deployedAt  DateTime @default(now())
  duration    Int?
  
  projectId   Int
  project     Project  @relation(...)
}
```

### Statuts du Projet

Le statut du projet est mis à jour:
- **pending** → Avant déploiement
- **building** → En cours
- **running** → Succès ✅
- **error** → Échec ❌

## 🔧 Configuration

### Variables d'Environnement

```bash
# Dans les scripts
BASE_PATH="/var/www/project"  # Chemin de base des projets
```

### Permissions Requises

```bash
# Rendre les scripts exécutables
chmod +x app/backend/commands/scripts/*.sh

# Permissions sur le dossier de projets
sudo mkdir -p /var/www/project
sudo chown -R $USER:$USER /var/www/project
```

## 📝 TODO

- [ ] Ajouter un système de queue pour les déploiements
- [ ] Permettre l'annulation d'un déploiement en cours
- [ ] Ajouter des webhooks post-déploiement
- [ ] Implémenter le rollback automatique en cas d'erreur
- [ ] Ajouter des notifications (email, Slack)
- [ ] Historique des déploiements dans l'UI
- [ ] Téléchargement des logs
- [ ] Graphiques de performance

## 🆘 Troubleshooting

### Le déploiement reste bloqué

```bash
# Vérifier les processus PM2
pm2 list

# Vérifier les logs PM2
pm2 logs <slug>

# Tuer un processus bloqué
pm2 delete <slug>
```

### Erreur de permissions

```bash
# Vérifier les permissions
ls -la /var/www/project/

# Corriger les permissions
sudo chown -R $USER:$USER /var/www/project/
```

### Les logs ne s'affichent pas

1. Ouvrir la console du navigateur (F12)
2. Vérifier les erreurs JavaScript
3. Vérifier que le token JWT est valide
4. Vérifier les logs serveur Nuxt

## 📚 Ressources

- [Server-Sent Events](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events)
- [PM2 Documentation](https://pm2.keymetrics.io/docs/usage/quick-start/)
- [Bash Error Handling](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html)
