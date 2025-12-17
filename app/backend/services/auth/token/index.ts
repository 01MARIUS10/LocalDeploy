import jwt from 'jsonwebtoken'

// Configuration JWT
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-in-production'
const JWT_EXPIRES_IN = '7d' // 7 jours
const REFRESH_TOKEN_EXPIRES_IN = '30d' // 30 jours

export interface JWTPayload {
  userId: number
  email: string
  name: string
}

export interface AuthTokens {
  accessToken: string
  refreshToken: string
}

/**
 * Générer un access token JWT
 */
export function generateAccessToken(payload: JWTPayload): string {
  return jwt.sign(payload, JWT_SECRET, {
    expiresIn: JWT_EXPIRES_IN
  })
}

/**
 * Générer un refresh token JWT
 */
export function generateRefreshToken(payload: JWTPayload): string {
  return jwt.sign(payload, JWT_SECRET, {
    expiresIn: REFRESH_TOKEN_EXPIRES_IN
  })
}

/**
 * Générer les deux tokens (access + refresh)
 */
export function generateTokens(user: { id: number; email: string; name: string }): AuthTokens {
  const payload: JWTPayload = {
    userId: user.id,
    email: user.email,
    name: user.name
  }

  return {
    accessToken: generateAccessToken(payload),
    refreshToken: generateRefreshToken(payload)
  }
}

/**
 * Vérifier et décoder un token JWT
 */
export function verifyToken(token: string): JWTPayload | null {
  try {
    return jwt.verify(token, JWT_SECRET) as JWTPayload
  } catch (error) {
    return null
  }
}

/**
 * Décoder un token sans vérifier la signature (pour debug)
 */
export function decodeToken(token: string): JWTPayload | null {
  try {
    return jwt.decode(token) as JWTPayload
  } catch (error) {
    return null
  }
}

/**
 * Vérifier si un token est expiré
 */
export function isTokenExpired(token: string): boolean {
  const decoded = decodeToken(token)
  if (!decoded || !decoded.exp) {
    return true
  }

  const currentTime = Math.floor(Date.now() / 1000)
  return decoded.exp < currentTime
}

/**
 * Obtenir le temps restant avant expiration (en secondes)
 */
export function getTokenExpirationTime(token: string): number | null {
  const decoded = decodeToken(token)
  if (!decoded || !decoded.exp) {
    return null
  }

  const currentTime = Math.floor(Date.now() / 1000)
  return Math.max(0, decoded.exp - currentTime)
}