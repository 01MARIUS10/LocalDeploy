import { getUserFromToken } from '~/backend/services/auth'

export default defineEventHandler(async (event) => {
  const authHeader = getHeader(event, 'authorization')

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    throw createError({
      statusCode: 401,
      statusMessage: 'Token manquant'
    })
  }

  const token = authHeader.substring(7)
  const user = await getUserFromToken(token)

  if (!user) {
    throw createError({
      statusCode: 401,
      statusMessage: 'Token invalide'
    })
  }

  return {
    success: true,
    user
  }
})
