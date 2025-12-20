# Système de Déploiement avec Logs en Temps Réel

Ce système permet d'exécuter le script `build-project.sh` et d'afficher les logs en temps réel dans l'interface web.

## 🏗️ Architecture

### Backend

1. **Script Shell avec Try-Catch** (`app/backend/commands/scripts/build-project.sh`)
   - Utilise `set -euo pipefail` pour activer le mode strict
   - Utilise `trap` pour capturer les erreurs
   - Format des logs: `[TYPE] message`
     - `[ERROR]` : Erreurs critiques
     - `[SUCCESS]` : Succès
     - `[WARN]` : Avertissements
     - `[INFO]` : Informations

2. **API Stream SSE** (`server/api/projects/deploy-stream.get.ts`)
   - Utilise Server-Sent Events pour streamer les logs
   - Exécute le script bash en arrière-plan
   - Capture stdout et stderr en temps réel
   - Enregistre le déploiement dans la base de données

3. **API POST Alternative** (`server/api/projects/deploy.post.ts`)
   - Version sans streaming (retour à la fin)
   - Peut être utilisée pour les déploiements non-interactifs

### Frontend

1. **Composant Detail.vue**
   - Affiche un bouton "Déployer" avec état de chargement
   - Console de logs avec coloration syntaxique
   - Auto-scroll vers le bas
   - Bouton pour effacer les logs

## 🚀 Utilisation

### 1. Configuration du Projet

Assurez-vous que le chemin du projet est correct dans `deploy-stream.get.ts`:

```typescript
const projectPath = `/var/www/projects/${slug}`;
```

### 2. Permissions du Script

Rendez le script exécutable:

```bash
chmod +x app/backend/commands/scripts/build-project.sh
```

### 3. Lancer un Déploiement

1. Allez sur la page de détail d'un projet
2. Cliquez sur le bouton **"Déployer"**
3. Les logs s'affichent en temps réel dans la console

## 📋 Format des Logs

Le script utilise un format standardisé pour faciliter le parsing:

```bash
[ERROR] Message d'erreur     # Rouge
[SUCCESS] Message de succès  # Vert
[WARN] Message d'avertissement # Jaune
[INFO] Message d'information # Bleu
```

### Exemple de Sortie

```
🚀 Démarrage du déploiement du projet: valentine
⏰ 20/12/2025 16:30:00
────────────────────────────────────────────────────────────────────────────────
[INFO] Démarrage du build...
[SUCCESS] Entré dans le projet : /var/www/projects/valentine
[INFO] Lancement du build de production (npm run build)...
[INFO] Cela peut prendre quelques minutes selon la taille du projet.

> valentine@1.0.0 build
> nuxt build

ℹ Building Nuxt...
✔ Build completed in 45.2s
[SUCCESS] Build terminé avec succès ! 🎉

[INFO] Le build est disponible dans :
[INFO]   /var/www/projects/valentine/.output   (pour Nuxt 3 Nitro)
────────────────────────────────────────────────────────────────────────────────
[SUCCESS] Build terminé avec succès
✅ Code de sortie: 0
────────────────────────────────────────────────────────────────────────────────
🏁 Déploiement terminé à 20/12/2025 16:32:15
```

## 🔧 Gestion des Erreurs

### Dans le Script Bash

Le script capture toutes les erreurs grâce à:

```bash
set -euo pipefail  # Mode strict

trap 'catch_error $? $LINENO' ERR

catch_error() {
  local exit_code=$1
  local line_number=$2
  echo "[ERROR] Une erreur s'est produite à la ligne $line_number avec le code de sortie $exit_code"
  exit $exit_code
}
```

### Dans l'API

L'API capture les erreurs et les envoie via SSE:

```typescript
buildProcess.on("error", (error) => {
  sendEvent({
    type: "error",
    message: "Erreur lors de l'exécution du script",
    error: error.message,
  });
  stream.end();
});
```

### Dans le Frontend

Le composant affiche les erreurs en rouge et arrête le déploiement:

```typescript
eventSource.onerror = (error) => {
  console.error("Erreur EventSource:", error);
  deploymentLogs.value.push("[ERROR] Connexion au stream perdue");
  eventSource.close();
  isDeploying.value = false;
};
```

## 📊 Enregistrement en Base de Données

Chaque déploiement est enregistré dans la table `Deployment`:

```typescript
await prisma.deployment.create({
  data: {
    projectId: project.id,
    status: code === 0 ? "success" : "failed",
    logs: logs.join("\n"),
    deployedAt: new Date(),
  },
});
```

## 🎨 Coloration des Logs

Les logs sont colorés automatiquement selon leur type:

- 🔴 **Rouge** : `[ERROR]` ou `STDERR`
- 🟢 **Vert** : `[SUCCESS]`
- 🟡 **Jaune** : `[WARN]`
- 🔵 **Bleu** : `[INFO]`
- ⚪ **Gris** : Autre

## 🔄 Auto-Scroll

Les logs scrollent automatiquement vers le bas lors de l'ajout de nouvelles lignes:

```typescript
function scrollToBottom() {
  nextTick(() => {
    if (logsContainer.value) {
      logsContainer.value.scrollTop = logsContainer.value.scrollHeight;
    }
  });
}
```

## 🛡️ Sécurité

- ✅ Authentification requise (via `authUser`)
- ✅ Vérification du propriétaire du projet
- ✅ Validation du slug
- ✅ Limitation du buffer (10MB max)
- ✅ Gestion de la fermeture de connexion
- ✅ Kill du processus si le client se déconnecte

## 🧪 Test

### Test Manuel

1. Créez un projet de test
2. Assurez-vous qu'il a un `package.json` valide
3. Cliquez sur "Déployer"
4. Vérifiez que les logs s'affichent en temps réel

### Test d'Erreur

Pour tester la gestion d'erreur, modifiez temporairement le chemin du projet:

```typescript
const projectPath = `/var/www/projects/projet-inexistant`;
```

Le script devrait retourner:

```
[ERROR] Le dossier /var/www/projects/projet-inexistant n'existe pas.
```

## 📝 TODO

- [ ] Ajouter un historique des déploiements
- [ ] Permettre de télécharger les logs
- [ ] Ajouter des notifications (succès/erreur)
- [ ] Implémenter un système de queue pour les déploiements
- [ ] Ajouter des webhooks post-déploiement
- [ ] Permettre d'annuler un déploiement en cours

## 🆘 Troubleshooting

### Les logs ne s'affichent pas

1. Vérifiez que le script est exécutable: `chmod +x build-project.sh`
2. Vérifiez les permissions du répertoire projet
3. Consultez la console du navigateur pour les erreurs JavaScript
4. Vérifiez les logs serveur Nuxt

### Le déploiement reste bloqué

1. Vérifiez que le processus npm n'est pas en attente d'input
2. Augmentez le `maxBuffer` si le projet est volumineux
3. Vérifiez que le script se termine bien (exit 0 ou exit 1)

### Erreur 401 Unauthorized

Vérifiez que vous êtes bien authentifié et que le token JWT est valide.

## 📚 Ressources

- [Server-Sent Events (MDN)](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events)
- [Node.js child_process](https://nodejs.org/api/child_process.html)
- [Bash Error Handling](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html)
