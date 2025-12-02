# LocalDeploy - Projet Nuxt

Architecture Nuxt bien structurée avec séparation claire des composants serveur/client.

## 📁 Structure du projet

```
mon-netlify-local/
├── pages/                      # Routes de l'application
│   ├── index.vue              # Page d'accueil
│   ├── about.vue              # Page à propos
│   └── contact.vue            # Page contact
├── components/
│   ├── server/                # Composants côté serveur (.server.vue)
│   │   └── ServerDataDisplay.server.vue
│   └── client/                # Composants côté client (.client.vue)
│       ├── ClientCounter.client.vue
│       └── ClientContactForm.client.vue
├── server/
│   └── api/                   # Endpoints API
│       └── data.ts            # API retournant des données figées
├── app/
│   └── app.vue                # Composant racine
└── public/                    # Fichiers statiques
```

## 🎯 Fonctionnalités

- **3 pages par défaut** : Accueil, À propos, Contact
- **API avec données figées** : `/api/data` retourne un JSON statique avec utilisateurs et statistiques
- **Composants serveur** : Rendu côté serveur pour optimiser les performances
- **Composants client** : Interactivité côté client (compteur, formulaire)
- **Navigation** : Liens entre les pages avec NuxtLink

## 🚀 Pages disponibles

- `/` - Page d'accueil avec composants serveur et client
- `/about` - Présentation du projet
- `/contact` - Informations de contact avec formulaire interactif

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
