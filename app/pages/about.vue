<template>
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
    <h1 class="text-4xl font-bold text-gray-800 mb-4">À propos</h1>
    <p class="text-lg text-gray-600 mb-8">Cette page présente notre projet et notre équipe.</p>
    
    <section class="my-8 space-y-6">
      <div>
        <h2 class="text-2xl font-semibold text-emerald-600 mb-3">Notre Mission</h2>
        <p class="text-gray-700 leading-relaxed">
          Créer des applications web modernes et performantes avec Nuxt 3.
          Cette architecture démontre la séparation claire entre composants
          serveur et client pour une meilleure optimisation.
        </p>
      </div>

      <div>
        <h2 class="text-2xl font-semibold text-emerald-600 mb-3">Technologies</h2>
        <ul class="space-y-3">
          <li class="flex items-start">
            <span class="text-emerald-600 font-bold mr-3">✓</span>
            <span class="text-gray-700">Nuxt 3 - Framework Vue.js</span>
          </li>
          <li class="flex items-start">
            <span class="text-emerald-600 font-bold mr-3">✓</span>
            <span class="text-gray-700">TypeScript - Typage statique</span>
          </li>
          <li class="flex items-start">
            <span class="text-emerald-600 font-bold mr-3">✓</span>
            <span class="text-gray-700">Server Components - Rendu côté serveur</span>
          </li>
          <li class="flex items-start">
            <span class="text-emerald-600 font-bold mr-3">✓</span>
            <span class="text-gray-700">Client Components - Interactivité côté client</span>
          </li>
        </ul>
      </div>
    </section>

    <nav class="flex gap-4 mt-8">
      <NuxtLink 
        to="/"
        class="px-6 py-3 bg-emerald-500 text-white rounded-lg hover:bg-emerald-600 transition-colors duration-300 font-medium"
      >
        Retour à l'accueil
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
</script>
