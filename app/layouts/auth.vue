<template>
  <div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-indigo-500 via-purple-600 to-purple-700 p-4">
    <!-- Contenu authentification (slot pour les pages login/signup) -->
    <div class="w-full max-w-md">
      <!-- Logo/Branding centré -->
      <div class="text-center mb-8">
        <NuxtLink to="/" class="inline-block">
          <h1 class="text-4xl font-bold text-white mb-2">🚀 LocalDeploy</h1>
          <p class="text-white/80 text-sm">Projet Nuxt avec architecture serveur/client</p>
        </NuxtLink>
      </div>

      <!-- Slot pour le contenu de la page (formulaire login/signup) -->
      <slot />

      <!-- Lien retour vers le site -->
      <div class="text-center mt-6">
        <NuxtLink 
          to="/" 
          class="text-white/80 hover:text-white text-sm transition-colors duration-300 inline-flex items-center gap-2"
        >
          ← Retour au site
        </NuxtLink>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// Layout minimaliste pour les pages d'authentification
</script>
