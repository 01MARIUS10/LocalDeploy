// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  modules: ['@nuxtjs/tailwindcss'],
  
  // Configuration pour utiliser le dossier app/
  srcDir: 'app/',
  
  // Désactiver le service worker warning
  nitro: {
    routeRules: {
      '/service-worker.js': { 
        headers: { 
          'cache-control': 'public, max-age=0, must-revalidate' 
        } 
      },
      '/profil': { ssr: false } // Désactiver le SSR pour la page profil
    }
  }
})
