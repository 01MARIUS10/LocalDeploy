<template>
  <div class="bg-gray-50 p-6 rounded-lg border border-gray-200 shadow-sm">
    <h2 class="text-xl font-semibold text-gray-800 mb-4">📊 Données du serveur</h2>
    
    <div v-if="pending" class="text-gray-500 italic">
      Chargement des données...
    </div>
    
    <div v-else-if="error" class="text-red-600 p-4 bg-red-50 rounded">
      ❌ Erreur: {{ error.message }}
    </div>
    
    <div v-else-if="data" class="space-y-4">
      <p class="text-green-600 font-medium">✅ {{ data.message }}</p>
      
      <div>
        <h3 class="text-lg font-semibold text-emerald-600 mb-3">Utilisateurs</h3>
        <ul class="space-y-2">
          <li 
            v-for="user in data.data.users" 
            :key="user.id"
            class="p-3 bg-white rounded border-l-4 border-emerald-500"
          >
            <strong class="text-gray-800">{{ user.name }}</strong> 
            <span class="text-gray-600"> - {{ user.role }}</span>
          </li>
        </ul>
      </div>

      <div>
        <h3 class="text-lg font-semibold text-emerald-600 mb-3">Statistiques</h3>
        <div class="space-y-3">
          <div class="bg-white p-4 rounded flex justify-between items-center">
            <span class="text-gray-600">Total utilisateurs:</span>
            <span class="text-2xl font-bold text-emerald-600">{{ data.data.stats.totalUsers }}</span>
          </div>
          <div class="bg-white p-4 rounded flex justify-between items-center">
            <span class="text-gray-600">Projets actifs:</span>
            <span class="text-2xl font-bold text-emerald-600">{{ data.data.stats.activeProjects }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// Composant server-only : ce fetch est exécuté côté serveur
const { data, pending, error } = await useFetch('/api/data')
</script>
