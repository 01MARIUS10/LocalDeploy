<template>
  <div class="bg-white rounded-lg shadow-2xl p-8">
    <h2 class="text-2xl font-bold text-gray-800 mb-6 text-center">Connexion</h2>
    
    <form @submit.prevent="handleLogin" class="space-y-4">
      <div>
        <label for="email" class="block text-sm font-medium text-gray-700 mb-2">
          Email
        </label>
        <input
          id="email"
          v-model="loginData.email"
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
          v-model="loginData.password"
          type="password"
          required
          placeholder="••••••••"
          class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all"
        />
      </div>

      <div class="flex items-center justify-between text-sm">
        <label class="flex items-center gap-2 text-gray-600 cursor-pointer">
          <input type="checkbox" class="rounded" />
          <span>Se souvenir de moi</span>
        </label>
        <a href="#" class="text-purple-600 hover:text-purple-700 font-medium">
          Mot de passe oublié ?
        </a>
      </div>

      <button
        type="submit"
        :disabled="isLoading"
        class="w-full py-3 bg-gradient-to-r from-purple-600 to-indigo-600 text-white rounded-lg font-semibold hover:from-purple-700 hover:to-indigo-700 transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed shadow-lg hover:shadow-xl"
      >
        {{ isLoading ? 'Connexion...' : 'Se connecter' }}
      </button>
    </form>

    <div class="mt-6 text-center text-sm text-gray-600">
      Pas encore de compte ?
      <NuxtLink 
        to="/auth/signup" 
        class="text-purple-600 hover:text-purple-700 font-semibold ml-1"
      >
        S'inscrire
      </NuxtLink>
    </div>

    <div v-if="message" class="mt-4 p-3 rounded-lg text-sm text-center" :class="messageClass">
      {{ message }}
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue'
import { useAuth } from '~/frontend/auth'
import { useRoute, useRouter } from 'vue-router'

// Définir le layout auth pour cette page
definePageMeta({
  layout: 'auth'
})

const { login, isAuthenticated } = useAuth()
const route = useRoute()
const router = useRouter()

// Récupérer l'URL de redirection depuis la query
const redirectTo = (route.query.redirect as string) || '/profil'

// Rediriger si déjà authentifié
if (isAuthenticated.value) {
  navigateTo(redirectTo)
}

const loginData = reactive({
  email: '',
  password: ''
})

const isLoading = ref(false)
const message = ref('')
const messageType = ref('')

const messageClass = computed(() => {
  return messageType.value === 'success' 
    ? 'bg-green-50 text-green-800 border border-green-200'
    : 'bg-red-50 text-red-800 border border-red-200'
})

const handleLogin = async () => {
  isLoading.value = true
  message.value = ''

  try {
    const result = await login(loginData.email, loginData.password)

    if (result.success) {
      message.value = `Bienvenue ${result.user?.name || loginData.email} !`
      messageType.value = 'success'

      // Redirection après connexion réussie vers l'URL de destination
      setTimeout(() => {
        navigateTo(redirectTo)
      }, 1000)
    } else {
      message.value = result.error || 'Identifiants incorrects'
      messageType.value = 'error'
    }
  } catch (error: any) {
    message.value = error.message || 'Une erreur est survenue'
    messageType.value = 'error'
  } finally {
    isLoading.value = false
  }
}
</script>
