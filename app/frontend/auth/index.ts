import { ref, computed } from 'vue'

interface User {
  id: number
  email: string
  name: string
}

interface AuthTokens {
  accessToken: string
  refreshToken: string
}

interface LoginResponse {
  success: boolean
  user: User
  tokens: AuthTokens
}

// État global de l'authentification
const user = ref<User | null>(null)
const accessToken = ref<string | null>(null)
const refreshToken = ref<string | null>(null)
const isAuthenticated = computed(() => !!user.value && !!accessToken.value)

export const useAuth = () => {
  // Charger les tokens depuis le localStorage
  const loadTokens = () => {
    if (process.client) {
      accessToken.value = localStorage.getItem('accessToken')
      refreshToken.value = localStorage.getItem('refreshToken')
      
      const userStr = localStorage.getItem('user')
      if (userStr) {
        try {
          user.value = JSON.parse(userStr)
        } catch (error) {
          console.error('Erreur lors du parsing de l\'utilisateur:', error)
          clearTokens()
        }
      }
    }
  }

  // Sauvegarder les tokens et l'utilisateur
  const saveAuth = (authUser: User, tokens: AuthTokens) => {
    user.value = authUser
    accessToken.value = tokens.accessToken
    refreshToken.value = tokens.refreshToken

    if (process.client) {
      localStorage.setItem('accessToken', tokens.accessToken)
      localStorage.setItem('refreshToken', tokens.refreshToken)
      localStorage.setItem('user', JSON.stringify(authUser))
    }
  }

  // Supprimer les tokens et l'utilisateur
  const clearTokens = () => {
    user.value = null
    accessToken.value = null
    refreshToken.value = null

    if (process.client) {
      localStorage.removeItem('accessToken')
      localStorage.removeItem('refreshToken')
      localStorage.removeItem('user')
    }
  }

  // Inscription
  const register = async (email: string, password: string, name: string) => {
    try {
      const response = await $fetch<LoginResponse>('/api/auth/signin', {
        method: 'POST',
        body: { email, password, name }
      })

      if (response.success && response.user && response.tokens) {
        saveAuth(response.user, response.tokens)
        return { success: true, user: response.user }
      }

      throw new Error('Réponse invalide du serveur')
    } catch (error: any) {
      const errorMessage = error.data?.statusMessage || error.message || 'Erreur lors de l\'inscription'
      return { success: false, error: errorMessage }
    }
  }

  // Connexion
  const login = async (email: string, password: string) => {
    try {
      const response = await $fetch<LoginResponse>('/api/auth/login', {
        method: 'POST',
        body: { email, password }
      })

      if (response.success && response.user && response.tokens) {
        saveAuth(response.user, response.tokens)
        return { success: true, user: response.user }
      }

      throw new Error('Réponse invalide du serveur')
    } catch (error: any) {
      const errorMessage = error.data?.statusMessage || error.message || 'Identifiants incorrects'
      return { success: false, error: errorMessage }
    }
  }

  // Déconnexion
  const logout = async () => {
    try {
      if (accessToken.value) {
        await $fetch('/api/auth/logout', {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${accessToken.value}`
          }
        })
      }
    } catch (error) {
      console.error('Erreur lors de la déconnexion:', error)
    } finally {
      clearTokens()
      await navigateTo('/auth/login')
    }
  }

  // Récupérer l'utilisateur connecté
  const fetchUser = async () => {
    loadTokens()

    if (!accessToken.value) {
      return { success: false, error: 'Non authentifié' }
    }

    try {
      const response = await $fetch<{ success: boolean; user: User }>('/api/auth/me', {
        headers: {
          Authorization: `Bearer ${accessToken.value}`
        }
      })

      if (response.success && response.user) {
        user.value = response.user
        if (process.client) {
          localStorage.setItem('user', JSON.stringify(response.user))
        }
        return { success: true, user: response.user }
      }

      throw new Error('Utilisateur non trouvé')
    } catch (error: any) {
      // Token invalide, tenter de rafraîchir
      const refreshResult = await refreshTokens()
      if (!refreshResult.success) {
        clearTokens()
        return { success: false, error: 'Session expirée' }
      }
      return { success: true, user: user.value }
    }
  }

  // Rafraîchir les tokens
  const refreshTokens = async () => {
    if (!refreshToken.value) {
      clearTokens()
      return { success: false, error: 'Aucun refresh token disponible' }
    }

    try {
      const response = await $fetch<{ success: boolean; tokens: AuthTokens }>('/api/auth/refresh', {
        method: 'POST',
        body: { refreshToken: refreshToken.value }
      })

      if (response.success && response.tokens) {
        accessToken.value = response.tokens.accessToken
        refreshToken.value = response.tokens.refreshToken
        
        if (process.client) {
          localStorage.setItem('accessToken', response.tokens.accessToken)
          localStorage.setItem('refreshToken', response.tokens.refreshToken)
        }

        return { success: true, tokens: response.tokens }
      }

      throw new Error('Refresh token invalide')
    } catch (error: any) {
      clearTokens()
      return { success: false, error: 'Session expirée' }
    }
  }

  // Vérifier si l'utilisateur est authentifié
  const checkAuth = () => {
    loadTokens()
    return isAuthenticated.value
  }

  // Initialiser l'authentification au chargement
  if (process.client) {
    loadTokens()
  }

  return {
    user: computed(() => user.value),
    isAuthenticated,
    accessToken: computed(() => accessToken.value),
    register,
    login,
    logout,
    fetchUser,
    refreshTokens,
    checkAuth
  }
}