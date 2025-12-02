<template>
  <div class="bg-gradient-to-br from-indigo-500 via-purple-600 to-purple-700 text-white p-6 rounded-lg text-center shadow-lg">
    <h2 class="text-xl font-semibold mb-2">🔢 Compteur interactif</h2>
    <p class="text-sm opacity-90 mb-6">Ce composant est exécuté uniquement côté client</p>
    
    <div class="flex items-center justify-center gap-4 my-6">
      <button 
        @click="decrement" 
        class="px-6 py-3 text-xl bg-red-500 hover:bg-red-600 rounded-lg font-bold transition-all duration-200 hover:scale-105 active:scale-95"
      >
        -
      </button>
      <span class="text-5xl font-bold min-w-[4rem] text-center">{{ count }}</span>
      <button 
        @click="increment" 
        class="px-6 py-3 text-xl bg-green-500 hover:bg-green-600 rounded-lg font-bold transition-all duration-200 hover:scale-105 active:scale-95"
      >
        +
      </button>
    </div>

    <div class="mt-4">
      <button 
        @click="reset" 
        class="px-4 py-2 text-sm bg-white/20 hover:bg-white/30 rounded-lg transition-colors duration-200"
      >
        Réinitialiser
      </button>
    </div>

    <p class="mt-4 text-sm opacity-80">Clics totaux: {{ totalClicks }}</p>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

// État réactif côté client uniquement
const count = ref(0)
const clicks = ref(0)

const increment = () => {
  count.value++
  clicks.value++
}

const decrement = () => {
  count.value--
  clicks.value++
}

const reset = () => {
  count.value = 0
}

const totalClicks = computed(() => clicks.value)
</script>
