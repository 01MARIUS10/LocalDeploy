export default defineEventHandler((event) => {
  const slug = getRouterParam(event, 'slug')

  // Base de données simulée (à remplacer par une vraie DB)
  const projects: Record<string, any> = {
    'my-blog': {
      id: 1,
      slug: 'my-blog',
      name: 'Mon Blog Personnel',
      description: 'Un blog moderne développé avec Nuxt 3 et TailwindCSS',
      status: 'production',
      domain: 'blog.example.com',
      repository: {
        url: 'https://github.com/username/my-blog',
        branch: 'main',
        lastCommit: '2025-12-03T08:00:00Z'
      },
      deployment: {
        platform: 'Netlify',
        buildCommand: 'npm run build',
        outputDirectory: '.output/public',
        environmentVariables: [
          { key: 'NUXT_PUBLIC_API_BASE', value: 'https://api.example.com' },
          { key: 'DATABASE_URL', value: '***hidden***', secret: true }
        ],
        lastDeployment: '2025-12-03T09:30:00Z',
        deploymentUrl: 'https://blog.example.com'
      },
      database: {
        type: 'PostgreSQL',
        host: 'db.example.com',
        port: 5432,
        name: 'blog_production',
        user: 'blog_user',
        ssl: true,
        backupSchedule: 'Daily at 3:00 AM UTC'
      },
      technologies: ['Nuxt 3', 'Vue 3', 'TailwindCSS', 'PostgreSQL', 'Prisma'],
      createdAt: '2025-11-01T10:00:00Z',
      updatedAt: '2025-12-03T09:30:00Z'
    },
    'ecommerce-app': {
      id: 2,
      slug: 'ecommerce-app',
      name: 'E-Commerce Platform',
      description: 'Plateforme e-commerce complète avec paiements Stripe',
      status: 'staging',
      domain: 'shop-staging.example.com',
      repository: {
        url: 'https://github.com/username/ecommerce-app',
        branch: 'develop',
        lastCommit: '2025-12-02T16:45:00Z'
      },
      deployment: {
        platform: 'Vercel',
        buildCommand: 'pnpm build',
        outputDirectory: 'dist',
        environmentVariables: [
          { key: 'STRIPE_PUBLIC_KEY', value: 'pk_test_***' },
          { key: 'STRIPE_SECRET_KEY', value: '***hidden***', secret: true },
          { key: 'DATABASE_URL', value: '***hidden***', secret: true }
        ],
        lastDeployment: '2025-12-02T17:00:00Z',
        deploymentUrl: 'https://shop-staging.example.com'
      },
      database: {
        type: 'MongoDB',
        host: 'cluster0.mongodb.net',
        port: 27017,
        name: 'ecommerce_staging',
        user: 'shop_admin',
        ssl: true,
        backupSchedule: 'Every 6 hours'
      },
      technologies: ['Nuxt 3', 'Vue 3', 'MongoDB', 'Stripe', 'Docker'],
      createdAt: '2025-10-15T14:30:00Z',
      updatedAt: '2025-12-02T17:00:00Z'
    },
    'portfolio': {
      id: 3,
      slug: 'portfolio',
      name: 'Portfolio Personnel',
      description: 'Site portfolio vitrine avec animations GSAP',
      status: 'production',
      domain: 'www.monportfolio.dev',
      repository: {
        url: 'https://github.com/username/portfolio',
        branch: 'main',
        lastCommit: '2025-11-28T12:20:00Z'
      },
      deployment: {
        platform: 'Netlify',
        buildCommand: 'npm run generate',
        outputDirectory: 'dist',
        environmentVariables: [
          { key: 'NUXT_PUBLIC_SITE_URL', value: 'https://www.monportfolio.dev' }
        ],
        lastDeployment: '2025-11-28T12:30:00Z',
        deploymentUrl: 'https://www.monportfolio.dev'
      },
      database: {
        type: 'None',
        host: '-',
        port: null,
        name: 'Static site (no database)',
        user: '-',
        ssl: false,
        backupSchedule: '-'
      },
      technologies: ['Nuxt 3', 'Vue 3', 'TailwindCSS', 'GSAP', 'Vite'],
      createdAt: '2025-09-10T08:00:00Z',
      updatedAt: '2025-11-28T12:30:00Z'
    }
  }

  const project = projects[slug as string]

  if (!project) {
    throw createError({
      statusCode: 404,
      statusMessage: 'Projet non trouvé'
    })
  }

  return project
})