<template>
  <div class="min-h-screen flex flex-col bg-gray-50 text-gray-800">
    <NuxtRouteAnnouncer />
    
    <!-- Header avec navigation -->
    <header class="bg-gradient-to-br from-indigo-500 via-purple-600 to-purple-700 text-white py-4 shadow-lg">
      <div class="max-w-7xl mx-auto px-4">
        <div class="flex justify-between items-center flex-wrap gap-4">
          <div class="logo">
            <h1 class="text-2xl font-bold">🚀 LocalDeploy</h1>
          </div>
          <nav class="flex gap-2">
            <NuxtLink 
              to="/" 
              class="px-4 py-2 rounded-lg font-medium transition-all duration-300 hover:bg-white/20 active:bg-white/30"
              active-class="bg-white/30 font-semibold"
            >
              Accueil
            </NuxtLink>
            <NuxtLink 
              to="/about" 
              class="px-4 py-2 rounded-lg font-medium transition-all duration-300 hover:bg-white/20 active:bg-white/30"
              active-class="bg-white/30 font-semibold"
            >
              À propos
            </NuxtLink>
            <NuxtLink 
              to="/contact" 
              class="px-4 py-2 rounded-lg font-medium transition-all duration-300 hover:bg-white/20 active:bg-white/30"
              active-class="bg-white/30 font-semibold"
            >
              Contact
            </NuxtLink>
          </nav>
        </div>
      </div>
    </header>

    <!-- Contenu principal (pages) -->
    <main class="flex-1 py-8">
      <NuxtPage />
    </main>

    <!-- Footer -->
    <footer class="bg-gray-800 text-white py-8 mt-auto text-center">
      <div class="max-w-7xl mx-auto px-4">
        <p class="my-2">&copy; 2025 LocalDeploy - Projet Nuxt avec architecture serveur/client</p>
        <p class="my-2">
          <a 
            href="/api/data" 
            target="_blank" 
            class="text-emerald-400 hover:text-emerald-300 transition-colors duration-300 mx-4"
          >
            API Docs
          </a>
        </p>
      </div>
    </footer>
  </div>
</template>
