export default defineEventHandler(() => {
  return {
    projects: [
      {
        id: 1,
        slug: 'my-blog',
        name: 'Mon Blog Personnel',
        description: 'Un blog moderne développé avec Nuxt 3 et TailwindCSS',
        status: 'production',
        domain: 'blog.example.com',
        technologies: ['Nuxt 3', 'Vue 3', 'TailwindCSS', 'PostgreSQL'],
        lastDeployment: '2025-12-03T09:30:00Z'
      },
      {
        id: 2,
        slug: 'ecommerce-app',
        name: 'E-Commerce Platform',
        description: 'Plateforme e-commerce complète avec paiements Stripe',
        status: 'staging',
        domain: 'shop-staging.example.com',
        technologies: ['Nuxt 3', 'Vue 3', 'MongoDB', 'Stripe'],
        lastDeployment: '2025-12-02T17:00:00Z'
      },
      {
        id: 3,
        slug: 'portfolio',
        name: 'Portfolio Personnel',
        description: 'Site portfolio vitrine avec animations GSAP',
        status: 'production',
        domain: 'www.monportfolio.dev',
        technologies: ['Nuxt 3', 'Vue 3', 'TailwindCSS', 'GSAP'],
        lastDeployment: '2025-11-28T12:30:00Z'
      }
    ],
    total: 3
  }
})