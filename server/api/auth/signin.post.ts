import { z } from 'zod'
import { registerUser } from '~/backend/services/auth'

const registerSchema = z.object({
  email: z.string().email('Email invalide'),
  password: z.string().min(8, 'Le mot de passe doit contenir au moins 8 caractères'),
  name: z.string().min(2, 'Le nom doit contenir au moins 2 caractères')
})

export default defineEventHandler(async (event) => {
  const body = await readBody(event)

  try {
    // Validation
    const data = registerSchema.parse(body)

    // Enregistrer l'utilisateur
    const result = await registerUser(data.email, data.password, data.name)

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
      statusCode: 400,
      statusMessage: error.message || 'Erreur lors de l\'inscription'
    })
  }
})