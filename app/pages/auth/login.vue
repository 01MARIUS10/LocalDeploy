<template>
  <div class="bg-slate-900 rounded-xl border border-slate-700/50 shadow-2xl shadow-black/50 p-8">
    <h2 class="text-2xl font-bold text-white mb-6 text-center">Connexion</h2>
    
    <form @submit.prevent="handleLogin" class="space-y-4">
      <div>
        <label for="email" class="block text-sm font-medium text-slate-300 mb-2">
          Email
        </label>
        <input
          id="email"
          v-model="loginData.email"
          type="email"
          required
          placeholder="votre@email.com"
          class="w-full px-4 py-3 bg-slate-800 border border-slate-600 rounded-lg text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent transition-all"
        />
      </div>

      <div>
        <label for="password" class="block text-sm font-medium text-slate-300 mb-2">
          Mot de passe
        </label>
        <input
          id="password"
          v-model="loginData.password"
          type="password"
          required
          placeholder="••••••••"
          class="w-full px-4 py-3 bg-slate-800 border border-slate-600 rounded-lg text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent transition-all"
        />
      </div>

      <div class="flex items-center justify-between text-sm">
        <label class="flex items-center gap-2 text-slate-400 cursor-pointer">
          <input type="checkbox" class="rounded bg-slate-700 border-slate-600 text-emerald-500 focus:ring-emerald-500" />
          <span>Se souvenir de moi</span>
        </label>
        <a href="#" class="text-emerald-400 hover:text-emerald-300 font-medium">
          Mot de passe oublié ?
        </a>
      </div>

      <button
        type="submit"
        :disabled="isLoading"
        class="w-full py-3 bg-emerald-500 hover:bg-emerald-400 text-slate-900 rounded-lg font-bold transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed shadow-lg shadow-emerald-500/25 hover:shadow-emerald-400/40"
      >
        {{ isLoading ? 'Connexion...' : 'Se connecter' }}
      </button>
    </form>

    <div class="mt-6 text-center text-sm text-slate-400">
      Pas encore de compte ?
      <NuxtLink 
        to="/auth/signup" 
        class="text-emerald-400 hover:text-emerald-300 font-semibold ml-1"
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
    ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20'
    : 'bg-red-500/10 text-red-400 border border-red-500/20'
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
