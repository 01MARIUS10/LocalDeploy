import { z } from 'zod'
import { refreshAccessToken } from '~/backend/services/auth'

const refreshSchema = z.object({
  refreshToken: z.string()
})

export default defineEventHandler(async (event) => {
  const body = await readBody(event)

  try {
    const data = refreshSchema.parse(body)

    const tokens = await refreshAccessToken(data.refreshToken)

    return {
      success: true,
      tokens
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
      statusMessage: error.message || 'Token invalide'
    })
  }
})
