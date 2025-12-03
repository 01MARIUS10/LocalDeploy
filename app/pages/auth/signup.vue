<template>
  <div class="bg-white rounded-lg shadow-2xl p-8">
    <h2 class="text-2xl font-bold text-gray-800 mb-6 text-center">Créer un compte</h2>
    
    <form @submit.prevent="handleSignup" class="space-y-4">
      <div>
        <label for="name" class="block text-sm font-medium text-gray-700 mb-2">
          Nom complet
        </label>
        <input
          id="name"
          v-model="signupData.name"
          type="text"
          required
          placeholder="Jean Dupont"
          class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all"
        />
      </div>

      <div>
        <label for="email" class="block text-sm font-medium text-gray-700 mb-2">
          Email
        </label>
        <input
          id="email"
          v-model="signupData.email"
          type="email"
          required
          placeholder="votre@email.com"
          class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all"
        />
      </div>

      <div>
        <label for="password" class="block text-sm font-medium text-gray-700 mb-2">
          Mot de passe
        </label>
        <input
          id="password"
          v-model="signupData.password"
          type="password"
          required
          placeholder="••••••••"
          minlength="8"
          class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all"
        />
        <p class="text-xs text-gray-500 mt-1">Minimum 8 caractères</p>
      </div>

      <div>
        <label for="confirm-password" class="block text-sm font-medium text-gray-700 mb-2">
          Confirmer le mot de passe
        </label>
        <input
          id="confirm-password"
          v-model="signupData.confirmPassword"
          type="password"
          required
          placeholder="••••••••"
          class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all"
        />
      </div>

      <div class="flex items-start gap-2">
        <input 
          id="terms" 
          v-model="signupData.acceptTerms"
          type="checkbox" 
          required
          class="mt-1 rounded" 
        />
        <label for="terms" class="text-sm text-gray-600 cursor-pointer">
          J'accepte les 
          <a href="#" class="text-purple-600 hover:text-purple-700 font-medium">
            conditions d'utilisation
          </a>
          et la
          <a href="#" class="text-purple-600 hover:text-purple-700 font-medium">
            politique de confidentialité
          </a>
        </label>
      </div>

      <button
        type="submit"
        :disabled="isLoading"
        class="w-full py-3 bg-gradient-to-r from-purple-600 to-indigo-600 text-white rounded-lg font-semibold hover:from-purple-700 hover:to-indigo-700 transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed shadow-lg hover:shadow-xl"
      >
        {{ isLoading ? 'Création...' : 'Créer mon compte' }}
      </button>
    </form>

    <div class="mt-6 text-center text-sm text-gray-600">
      Vous avez déjà un compte ?
      <NuxtLink 
        to="/auth/login" 
        class="text-purple-600 hover:text-purple-700 font-semibold ml-1"
      >
        Se connecter
      </NuxtLink>
    </div>

    <div v-if="message" class="mt-4 p-3 rounded-lg text-sm text-center" :class="messageClass">
      {{ message }}
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue'

// Définir le layout auth pour cette page
definePageMeta({
  layout: 'auth'
})

const signupData = reactive({
  name: '',
  email: '',
  password: '',
  confirmPassword: '',
  acceptTerms: false
})

const isLoading = ref(false)
const message = ref('')
const messageType = ref('')

const messageClass = computed(() => {
  return messageType.value === 'success' 
    ? 'bg-green-50 text-green-800 border border-green-200'
    : 'bg-red-50 text-red-800 border border-red-200'
})

const handleSignup = async () => {
  // Vérifier que les mots de passe correspondent
  if (signupData.password !== signupData.confirmPassword) {
    message.value = 'Les mots de passe ne correspondent pas'
    messageType.value = 'error'
    return
  }

  isLoading.value = true
  message.value = ''

  // Simulation d'une inscription
  await new Promise(resolve => setTimeout(resolve, 1500))

  // Simulation de succès
  message.value = `Compte créé avec succès ! Bienvenue ${signupData.name} !`
  messageType.value = 'success'

  isLoading.value = false

  // Redirection après inscription réussie
  setTimeout(() => {
    // navigateTo('/') // Décommentez pour rediriger vers l'accueil
  }, 1500)
}
</script>
