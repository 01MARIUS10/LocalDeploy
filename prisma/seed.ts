import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function main() {
  console.log('🌱 Début du seed...\n')

  // Nettoyer les données existantes
  console.log('🧹 Nettoyage des données existantes...')
  await prisma.deployment.deleteMany()
  await prisma.envVar.deleteMany()
  await prisma.project.deleteMany()
  await prisma.user.deleteMany()

  // Créer des utilisateurs
  console.log('👤 Création des utilisateurs...')
  const admin = await prisma.user.create({
    data: {
      email: 'admin@example.com',
      name: 'Admin',
      password: '$2a$10$hashed_password_example' // Hash bcrypt fictif
    }
  })
  console.log(`   ✅ ${admin.name} (${admin.email})`)

  const alice = await prisma.user.create({
    data: {
      email: 'alice.dupont@example.com',
      name: 'Alice Dupont',
      password: '$2a$10$hashed_password_alice'
    }
  })
  console.log(`   ✅ ${alice.name} (${alice.email})`)

  // Créer le projet "Mon Blog Personnel"
  console.log('\n📦 Création des projets...')
  const blog = await prisma.project.create({
    data: {
      slug: 'my-blog',
      name: 'Mon Blog Personnel',
      description: 'Un blog moderne développé avec Nuxt 3 et TailwindCSS',
      repositoryUrl: 'https://github.com/username/my-blog',
      branch: 'main',
      clonedPath: '/var/projects/my-blog',
      lastCommit: 'abc123def456',
      domain: 'blog.example.com',
      status: 'running',
      port: 3000,
      buildCommand: 'npm run build',
      startCommand: 'npm start',
      outputDir: '.output/public',
      databaseType: 'PostgreSQL',
      databaseUrl: 'postgresql://blog_user:password@db.example.com:5432/blog_production',
      technologies: JSON.stringify(['Nuxt 3', 'Vue 3', 'TailwindCSS', 'PostgreSQL', 'Prisma']),
      userId: admin.id,
      lastDeployAt: new Date('2025-12-03T09:30:00Z'),
      createdAt: new Date('2025-11-01T10:00:00Z'),
      updatedAt: new Date('2025-12-03T09:30:00Z'),
      envVars: {
        create: [
          { 
            key: 'NUXT_PUBLIC_API_BASE', 
            value: 'https://api.example.com', 
            secret: false 
          },
          { 
            key: 'DATABASE_URL', 
            value: 'postgresql://blog_user:secret@db.example.com:5432/blog_production', 
            secret: true 
          }
        ]
      },
      deployments: {
        create: [
          {
            status: 'success',
            commitHash: 'abc123def456',
            duration: 120,
            logs: 'Build completed successfully\nDeployed to production',
            deployedAt: new Date('2025-12-03T09:30:00Z')
          },
          {
            status: 'success',
            commitHash: 'xyz789',
            duration: 115,
            logs: 'Build completed successfully',
            deployedAt: new Date('2025-12-02T14:20:00Z')
          }
        ]
      }
    }
  })
  console.log(`   ✅ ${blog.name} (${blog.domain})`)

  // Créer le projet "E-Commerce Platform"
  const ecommerce = await prisma.project.create({
    data: {
      slug: 'ecommerce-app',
      name: 'E-Commerce Platform',
      description: 'Plateforme e-commerce complète avec paiements Stripe',
      repositoryUrl: 'https://github.com/username/ecommerce-app',
      branch: 'develop',
      clonedPath: '/var/projects/ecommerce-app',
      lastCommit: 'ecom456xyz',
      domain: 'shop-staging.example.com',
      status: 'pending',
      port: 3001,
      buildCommand: 'pnpm build',
      startCommand: 'pnpm start',
      outputDir: 'dist',
      databaseType: 'MongoDB',
      databaseUrl: 'mongodb://shop_admin:password@cluster0.mongodb.net:27017/ecommerce_staging',
      technologies: JSON.stringify(['Nuxt 3', 'Vue 3', 'MongoDB', 'Stripe', 'Docker']),
      userId: admin.id,
      lastDeployAt: new Date('2025-12-02T17:00:00Z'),
      createdAt: new Date('2025-10-15T14:30:00Z'),
      updatedAt: new Date('2025-12-02T17:00:00Z'),
      envVars: {
        create: [
          { 
            key: 'STRIPE_PUBLIC_KEY', 
            value: 'pk_test_51abcdef123456', 
            secret: false 
          },
          { 
            key: 'STRIPE_SECRET_KEY', 
            value: 'sk_test_51secret_key_here', 
            secret: true 
          },
          { 
            key: 'DATABASE_URL', 
            value: 'mongodb://shop_admin:secret@cluster0.mongodb.net:27017/ecommerce_staging', 
            secret: true 
          }
        ]
      },
      deployments: {
        create: [
          {
            status: 'success',
            commitHash: 'ecom456xyz',
            duration: 95,
            logs: 'Build completed\nTests passed\nDeployed to staging',
            deployedAt: new Date('2025-12-02T17:00:00Z')
          }
        ]
      }
    }
  })
  console.log(`   ✅ ${ecommerce.name} (${ecommerce.domain})`)

  // Créer le projet "Portfolio Personnel"
  const portfolio = await prisma.project.create({
    data: {
      slug: 'portfolio',
      name: 'Portfolio Personnel',
      description: 'Site portfolio vitrine avec animations GSAP',
      repositoryUrl: 'https://github.com/username/portfolio',
      branch: 'main',
      clonedPath: '/var/projects/portfolio',
      lastCommit: 'port789abc',
      domain: 'www.monportfolio.dev',
      status: 'running',
      port: 3002,
      buildCommand: 'npm run generate',
      startCommand: 'npm start',
      outputDir: 'dist',
      databaseType: null,
      databaseUrl: null,
      technologies: JSON.stringify(['Nuxt 3', 'Vue 3', 'TailwindCSS', 'GSAP', 'Vite']),
      userId: alice.id,
      lastDeployAt: new Date('2025-11-28T12:30:00Z'),
      createdAt: new Date('2025-09-10T08:00:00Z'),
      updatedAt: new Date('2025-11-28T12:30:00Z'),
      envVars: {
        create: [
          { 
            key: 'NUXT_PUBLIC_SITE_URL', 
            value: 'https://www.monportfolio.dev', 
            secret: false 
          }
        ]
      },
      deployments: {
        create: [
          {
            status: 'success',
            commitHash: 'port789abc',
            duration: 60,
            logs: 'Static site generated\nDeployed successfully',
            deployedAt: new Date('2025-11-28T12:30:00Z')
          },
          {
            status: 'success',
            commitHash: 'prev123',
            duration: 58,
            logs: 'Build completed',
            deployedAt: new Date('2025-11-20T10:15:00Z')
          }
        ]
      }
    }
  })
  console.log(`   ✅ ${portfolio.name} (${portfolio.domain})`)

  // Statistiques finales
  console.log('\n📊 Statistiques:')
  const stats = {
    users: await prisma.user.count(),
    projects: await prisma.project.count(),
    envVars: await prisma.envVar.count(),
    deployments: await prisma.deployment.count()
  }

  console.log(`   👥 Utilisateurs: ${stats.users}`)
  console.log(`   📦 Projets: ${stats.projects}`)
  console.log(`   🔐 Variables d'environnement: ${stats.envVars}`)
  console.log(`   🚀 Déploiements: ${stats.deployments}`)

  console.log('\n✅ Seed terminé avec succès!\n')
}

main()
  .catch((e) => {
    console.error('\n❌ Erreur lors du seed:', e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
