<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <h1 class="text-4xl font-bold text-gray-800 mb-4">Accueil</h1>
    <p class="text-lg text-gray-600 mb-8">Bienvenue sur la page d'accueil de notre application Nuxt.</p>
    
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 my-8">
      <ServerDataDisplay />
      <ClientCounter />
    </div>

    <nav class="flex gap-4 mt-8">
      <NuxtLink 
        to="/about"
        class="px-6 py-3 bg-emerald-500 text-white rounded-lg hover:bg-emerald-600 transition-colors duration-300 font-medium"
      >
        À propos
      </NuxtLink>
      <NuxtLink 
        to="/contact"
        class="px-6 py-3 bg-emerald-500 text-white rounded-lg hover:bg-emerald-600 transition-colors duration-300 font-medium"
      >
        Contact
      </NuxtLink>
    </nav>
  </div>
</template>

<script setup lang="ts">
// Configuration SEO de la page
useHead({
  title: 'Accueil',
  meta: [
    { name: 'description', content: 'Page d\'accueil de l\'application' }
  ]
})
</script>
