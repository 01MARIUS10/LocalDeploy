export default defineEventHandler(() => {
  return {
    projects: [
      {
        id: 1,
        userId: 1,
        slug: "my-blog",
        name: "Mon Blog Personnel",
        description:
          "Blog moderne pour partager mes articles sur le développement web, Nuxt et la vie de dev freelance.",
        status: "production",
        domain: "blog.johndoe.dev",
        technologies: [
          "Nuxt 3",
          "Vue 3",
          "TailwindCSS",
          "PostgreSQL",
          "Markdown",
        ],
        lastDeployment: "2025-12-03T09:30:00Z",
      },
      {
        id: 2,
        userId: 1,
        slug: "portfolio-v2",
        name: "Portfolio Personnel V2",
        description:
          "Portfolio responsive avec animations fluides, mode sombre et section projets interactive.",
        status: "production",
        domain: "www.johndoe.dev",
        technologies: ["Nuxt 3", "Vue 3", "TailwindCSS", "GSAP", "Three.js"],
        lastDeployment: "2025-11-28T12:30:00Z",
      },
      {
        id: 3,
        userId: 1,
        slug: "task-manager",
        name: "TaskFlow",
        description:
          "Gestionnaire de tâches personnel avec drag & drop, synchronisation en temps réel et notifications.",
        status: "development",
        domain: "task-manager.johndoe.dev",
        technologies: ["Nuxt 3", "Vue 3", "Pinia", "Supabase", "Socket.io"],
        lastDeployment: "2025-10-15T08:00:00Z",
      },
      {
        id: 4,
        userId: 1,
        slug: "invoice-app",
        name: "Facturation Freelance",
        description:
          "Application de gestion de factures pour freelances avec génération PDF et suivi des paiements.",
        status: "staging",
        domain: "invoice-staging.johndoe.dev",
        technologies: [
          "Nuxt 3",
          "Vue 3",
          "TailwindCSS",
          "Prisma",
          "PostgreSQL",
        ],
        lastDeployment: "2025-12-12T15:45:00Z",
      },

      {
        id: 5,
        userId: 2,
        slug: "ecommerce-app",
        name: "GreenShop",
        description:
          "Boutique en ligne éco-responsable avec catalogue produits, panier et paiement Stripe sécurisé.",
        status: "staging",
        domain: "shop-staging.greenshop.fr",
        technologies: ["Nuxt 3", "Vue 3", "MongoDB", "Stripe", "TailwindCSS"],
        lastDeployment: "2025-12-02T17:00:00Z",
      },
      {
        id: 6,
        userId: 2,
        slug: "dashboard-saas",
        name: "Analytics Pro",
        description:
          "Tableau de bord SaaS avec graphiques en temps réel et export de données.",
        status: "production",
        domain: "dashboard.analytics-pro.com",
        technologies: ["Nuxt 3", "Vue 3", "Chart.js", "Prisma", "PostgreSQL"],
        lastDeployment: "2025-12-10T20:15:00Z",
      },
      {
        id: 7,
        userId: 2,
        slug: "landing-crm",
        name: "Landing Page CRM",
        description:
          "Landing page performante pour un outil CRM avec formulaire de capture leads.",
        status: "production",
        domain: "crm-landing.example.com",
        technologies: ["Nuxt 3", "Vue 3", "TailwindCSS", "Formspark"],
        lastDeployment: "2025-12-08T10:20:00Z",
      },

      {
        id: 8,
        userId: 3,
        slug: "booking-system",
        name: "BookRoom Enterprise",
        description:
          "Système de réservation de salles de réunion avec calendrier partagé et notifications email.",
        status: "production",
        domain: "booking.entreprise.xyz",
        technologies: [
          "Nuxt 3",
          "Vue 3",
          "TailwindCSS",
          "Laravel API",
          "MySQL",
        ],
        lastDeployment: "2025-12-14T14:20:00Z",
      },
      {
        id: 9,
        userId: 3,
        slug: "weather-app",
        name: "Météo Live",
        description:
          "Application météo avec prévisions heure par heure, cartes interactives et alertes.",
        status: "development",
        domain: "weather.liveapp.io",
        technologies: [
          "Nuxt 3",
          "Vue 3",
          "OpenWeatherMap API",
          "Leaflet",
          "Pinia",
        ],
        lastDeployment: "2025-07-05T18:00:00Z",
      },

      {
        id: 10,
        userId: 4,
        slug: "recipe-book",
        name: "Mes Recettes",
        description:
          "Application de gestion de recettes personnelles avec recherche par ingrédients et photos.",
        status: "production",
        domain: "recettes.mafamille.fr",
        technologies: [
          "Nuxt 3",
          "Vue 3",
          "TailwindCSS",
          "Supabase",
          "Cloudinary",
        ],
        lastDeployment: "2025-12-05T18:00:00Z",
      },
      {
        id: 11,
        userId: 4,
        slug: "fitness-tracker",
        name: "FitTrack",
        description:
          "Suivi d'entraînements sportifs avec statistiques et progression visuelle.",
        status: "staging",
        domain: "app-staging.fittrack.dev",
        technologies: ["Nuxt 3", "Vue 3", "Chart.js", "Pinia", "Firebase"],
        lastDeployment: "2025-12-13T11:30:00Z",
      },
      {
        id: 12,
        userId: 4,
        slug: "note-app",
        name: "QuickNotes",
        description:
          "Application de notes rapide avec synchronisation multi-appareils et tags.",
        status: "production",
        domain: "notes.quickapps.io",
        technologies: [
          "Nuxt 3",
          "Vue 3",
          "TailwindCSS",
          "Dexie.js",
          "Sync API",
        ],
        lastDeployment: "2025-11-20T09:15:00Z",
      },
    ],
    total: 12,
  };
});

const connectedUserId = 1;

if (!connectedUserId) {
  throw createError({
    statusCode: 401,
    statusMessage: "Non authentifié",
  });
}
