import { useAuth } from '~/frontend/auth'

export default defineNuxtRouteMiddleware((to, from) => {
  // Vérifier uniquement côté client
  if (process.server) return

  const { isAuthenticated, checkAuth } = useAuth()

  // Vérifier l'authentification
  const isAuth = checkAuth()

  // Si l'utilisateur n'est pas authentifié et essaie d'accéder à une route protégée
  if (!isAuth && !isAuthenticated.value) {
    // Sauvegarder l'URL de destination pour rediriger après connexion
    const redirectTo = to.fullPath
    
    return navigateTo({
      path: '/auth/login',
      query: { redirect: redirectTo }
    })
  }
})
