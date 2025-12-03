# LocalDeploy - Projet Nuxt

Architecture Nuxt bien structurée avec séparation claire des composants serveur/client.

## 📁 Structure du projet

```
mon-netlify-local/
├── app/                        # Dossier principal de l'application
│   ├── app.vue                # Point d'entrée (utilise NuxtLayout + NuxtPage)
│   ├── layouts/               # Layouts réutilisables
│   │   ├── default.vue        # Layout par défaut (header + footer + slot)
│   │   └── clean.vue          # Layout minimal (sans header/footer)
│   ├── pages/                 # Routes de l'application
│   │   ├── index.vue          # Page d'accueil
│   │   ├── about.vue          # Page à propos
│   │   ├── contact.vue        # Page contact
│   │   └── admin.vue          # Exemple avec layout "clean"
│   ├── components/
│   │   ├── server/            # Composants côté serveur (.server.vue)
│   │   │   └── ServerDataDisplay.server.vue
│   │   └── client/            # Composants côté client (.client.vue)
│   │       ├── ClientCounter.client.vue
│   │       └── ClientContactForm.client.vue
│   └── features/              # Organisation par fonctionnalités (optionnel)
├── server/
│   └── api/                   # Endpoints API
│       └── data.ts            # API retournant des données figées
└── public/                    # Fichiers statiques
```

## 🎯 Fonctionnalités

- **Système de Layouts** : Layout réutilisable avec slot pour toutes les pages
  - `default.vue` : Header + Navigation + Footer
  - `clean.vue` : Layout minimal sans navigation
- **3+ pages par défaut** : Accueil, À propos, Contact, Admin
- **API avec données figées** : `/api/data` retourne un JSON statique avec utilisateurs et statistiques
- **Composants serveur** : Rendu côté serveur pour optimiser les performances
- **Composants client** : Interactivité côté client (compteur, formulaire)
- **Navigation** : Liens entre les pages avec NuxtLink
- **Tailwind CSS** : Tous les styles utilisent des classes utilitaires Tailwind

## 🚀 Pages disponibles

- `/` - Page d'accueil avec composants serveur et client (layout: default)
- `/about` - Présentation du projet (layout: default)
- `/contact` - Informations de contact avec formulaire interactif (layout: default)
- `/admin` - Page exemple avec layout minimal (layout: clean)

## 📐 Utiliser les Layouts

### Layout par défaut
Toutes les pages utilisent automatiquement `layouts/default.vue` qui contient :
- Header avec navigation
- `<slot />` pour le contenu de la page
- Footer

### Layout personnalisé
Pour utiliser un layout différent sur une page :

```vue
<script setup lang="ts">
definePageMeta({
  layout: 'clean'  // Utilise layouts/clean.vue
})
</script>
```

### Créer un nouveau layout
Créez un fichier dans `app/layouts/mon-layout.vue` :

```vue
<template>
  <div>
    <!-- Votre structure -->
    <slot />  <!-- Contenu de la page -->
  </div>
</template>
```

## 🔌 API Endpoint

**GET** `/api/data` - Retourne des données figées :
```json
{
  "status": "success",
  "message": "Données figées depuis l'API",
  "data": {
    "users": [...],
    "stats": {...}
  }
}
```

Look at the [Nuxt documentation](https://nuxt.com/docs/getting-started/introduction) to learn more.

## Setup

Make sure to install dependencies:

```bash
# npm
npm install

# pnpm
pnpm install

# yarn
yarn install

# bun
bun install
```

## Development Server

Start the development server on `http://localhost:3000`:

```bash
# npm
npm run dev

# pnpm
pnpm dev

# yarn
yarn dev

# bun
bun run dev
```

## Production

Build the application for production:

```bash
# npm
npm run build

# pnpm
pnpm build

# yarn
yarn build

# bun
bun run build
```

Locally preview production build:

```bash
# npm
npm run preview

# pnpm
pnpm preview

# yarn
yarn preview

# bun
bun run preview
```

Check out the [deployment documentation](https://nuxt.com/docs/getting-started/deployment) for more information.
