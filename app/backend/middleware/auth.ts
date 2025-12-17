import { getUserFromToken } from '~/backend/services/auth'

/**
 * Middleware pour protéger les routes authentifiées
 */
export default defineEventHandler(async (event) => {
  // Liste des routes publiques (pas d'auth requise)
  const publicRoutes = [
    '/api/auth/login',
    '/api/auth/register',
    '/api/auth/refresh'
  ]

  const path = event.path

  // Si la route est publique, passer
  if (publicRoutes.some(route => path.startsWith(route))) {
    return
  }

  // Si ce n'est pas une route API, passer
  if (!path.startsWith('/api/')) {
    return
  }

  // Récupérer le token depuis le header Authorization
  const authHeader = getHeader(event, 'authorization')

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    throw createError({
      statusCode: 401,
      statusMessage: 'Token manquant ou invalide'
    })
  }

  const token = authHeader.substring(7) // Enlever "Bearer "

  // Vérifier le token et récupérer l'utilisateur
  const user = await getUserFromToken(token)

  if (!user) {
    throw createError({
      statusCode: 401,
      statusMessage: 'Token invalide ou expiré'
    })
  }

  // Attacher l'utilisateur au contexte de l'événement
  event.context.user = user
})