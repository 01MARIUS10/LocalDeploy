<template>
  <div class="min-h-screen flex flex-col bg-gray-50 text-gray-800">
    <!-- Header avec navigation -->
    <header class="bg-gradient-to-br from-indigo-500 via-purple-600 to-purple-700 text-white py-4 shadow-lg">
      <div class="max-w-7xl mx-auto px-4">
        <div class="flex justify-between items-center flex-wrap gap-4">
          <div class="logo">
            <h1 class="text-2xl font-bold">🚀 LocalDeploy</h1>
          </div>
          <nav class="flex gap-2 flex-wrap items-center">
            <NuxtLink 
              to="/" 
              class="px-4 py-2 rounded-lg font-medium transition-all duration-300 hover:bg-white/20"
              active-class="bg-white/30 font-semibold"
            >
              Accueil
            </NuxtLink>
            
            <!-- Menu utilisateur authentifié -->
            <template v-if="isAuthenticated">
              <NuxtLink 
                to="/projects" 
                class="px-4 py-2 rounded-lg font-medium transition-all duration-300 hover:bg-white/20"
                active-class="bg-white/30 font-semibold"
              >
                Projects
              </NuxtLink>
              <span class="text-white/40">|</span>
              <NuxtLink 
                to="/profil" 
                class="px-4 py-2 rounded-lg font-medium transition-all duration-300 hover:bg-white/20"
                active-class="bg-white/30 font-semibold"
              >
                👤 {{ user?.name || 'Profil' }}
              </NuxtLink>
              <button
                @click="handleLogout"
                class="px-4 py-2 rounded-lg font-medium transition-all duration-300 bg-red-500/20 hover:bg-red-500/30"
              >
                🚪 Déconnexion
              </button>
            </template>
            
            <!-- Menu non authentifié -->
            <template v-else>
              <NuxtLink 
                to="/auth/login" 
                class="px-4 py-2 rounded-lg font-medium transition-all duration-300 bg-white/10 hover:bg-white/20"
              >
                🔐 Connexion
              </NuxtLink>
            </template>
          </nav>
        </div>
      </div>
    </header>

    <!-- Contenu principal (slot pour les pages) -->
    <main class="flex-1 py-8">
      <slot />
    </main>

  </div>
</template>

<script setup lang="ts">
import { useAuth } from '~/frontend/auth'

// Configuration du layout par défaut
const { user, isAuthenticated, logout } = useAuth()

const handleLogout = async () => {
  await logout()
}
</script>
