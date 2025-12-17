import { z } from 'zod'
import { loginUser } from '~/backend/services/auth'

const loginSchema = z.object({
  email: z.string().email('Email invalide'),
  password: z.string().min(1, 'Mot de passe requis')
})

export default defineEventHandler(async (event) => {
  const body = await readBody(event)

  try {
    // Validation
    const data = loginSchema.parse(body)

    // Connexion
    const result = await loginUser(data.email, data.password)

    return {
      success: true,
      user: result.user,
      tokens: result.tokens
    }
  } catch (error: any) {
    if (error instanceof z.ZodError) {
      throw createError({
        statusCode: 400,
        statusMessage: 'Validation échouée',
        data: error.errors
      })
    }

    throw createError({
      statusCode: 401,
      statusMessage: error.message || 'Identifiants incorrects'
    })
  }
})