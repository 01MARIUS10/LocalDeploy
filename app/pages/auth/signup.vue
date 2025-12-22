<template>
  <div class="bg-slate-900 rounded-xl border border-slate-700/50 shadow-2xl shadow-black/50 p-8">
    <h2 class="text-2xl font-bold text-white mb-6 text-center">Créer un compte</h2>
    
    <form @submit.prevent="handleSignup" class="space-y-4">
      <div>
        <label for="name" class="block text-sm font-medium text-slate-300 mb-2">
          Nom complet
        </label>
        <input
          id="name"
          v-model="signupData.name"
          type="text"
          required
          placeholder="Jean Dupont"
          class="w-full px-4 py-3 bg-slate-800 border border-slate-600 rounded-lg text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent transition-all"
        />
      </div>

      <div>
        <label for="email" class="block text-sm font-medium text-slate-300 mb-2">
          Email
        </label>
        <input
          id="email"
          v-model="signupData.email"
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
          v-model="signupData.password"
          type="password"
          required
          placeholder="••••••••"
          minlength="8"
          class="w-full px-4 py-3 bg-slate-800 border border-slate-600 rounded-lg text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent transition-all"
        />
        <p class="text-xs text-slate-500 mt-1">Minimum 8 caractères</p>
      </div>

      <div>
        <label for="confirm-password" class="block text-sm font-medium text-slate-300 mb-2">
          Confirmer le mot de passe
        </label>
        <input
          id="confirm-password"
          v-model="signupData.confirmPassword"
          type="password"
          required
          placeholder="••••••••"
          class="w-full px-4 py-3 bg-slate-800 border border-slate-600 rounded-lg text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent transition-all"
        />
      </div>

      <div class="flex items-start gap-2">
        <input 
          id="terms" 
          v-model="signupData.acceptTerms"
          type="checkbox" 
          required
          class="mt-1 rounded bg-slate-700 border-slate-600 text-emerald-500 focus:ring-emerald-500" 
        />
        <label for="terms" class="text-sm text-slate-400 cursor-pointer">
          J'accepte les 
          <a href="#" class="text-emerald-400 hover:text-emerald-300 font-medium">
            conditions d'utilisation
          </a>
          et la
          <a href="#" class="text-emerald-400 hover:text-emerald-300 font-medium">
            politique de confidentialité
          </a>
        </label>
      </div>

      <button
        type="submit"
        :disabled="isLoading"
        class="w-full py-3 bg-emerald-500 hover:bg-emerald-400 text-slate-900 rounded-lg font-bold transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed shadow-lg shadow-emerald-500/25 hover:shadow-emerald-400/40"
      >
        {{ isLoading ? 'Création...' : 'Créer mon compte' }}
      </button>
    </form>

    <div class="mt-6 text-center text-sm text-slate-400">
      Vous avez déjà un compte ?
      <NuxtLink 
        to="/auth/login" 
        class="text-emerald-400 hover:text-emerald-300 font-semibold ml-1"
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
import { useAuth } from '~/frontend/auth'

// Définir le layout auth pour cette page
definePageMeta({
  layout: 'auth'
})

const { register, isAuthenticated } = useAuth()

// Rediriger si déjà authentifié
if (isAuthenticated.value) {
  navigateTo('/profil')
}

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
    ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20'
    : 'bg-red-500/10 text-red-400 border border-red-500/20'
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

  try {
    const result = await register(signupData.email, signupData.password, signupData.name)

    if (result.success) {
      message.value = `Compte créé avec succès ! Bienvenue ${signupData.name} !`
      messageType.value = 'success'

      // Redirection après inscription réussie
      setTimeout(() => {
        navigateTo('/profil')
      }, 1000)
    } else {
      message.value = result.error || 'Erreur lors de l\'inscription'
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
