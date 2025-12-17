import { useAuth } from '~/frontend/auth'

export interface ApiError {
  statusCode: number
  statusMessage: string
  message: string
  data?: any
}

export class ApiClient {
  private baseUrl: string

  constructor(baseUrl = '/api') {
    this.baseUrl = baseUrl
  }

  /**
   * Récupérer le token d'authentification
   */
  private getAuthToken(): string | null {
    const { accessToken } = useAuth()
    return accessToken.value
  }

  /**
   * Créer les headers avec authentification
   */
  private createHeaders(customHeaders: Record<string, string> = {}): Record<string, string> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      ...customHeaders
    }

    const token = this.getAuthToken()
    if (token) {
      headers['Authorization'] = `Bearer ${token}`
    }

    return headers
  }

  /**
   * Gérer les erreurs d'API
   */
  private handleError(error: any): never {
    // Si erreur 401 (non authentifié), déconnecter et rediriger
    if (error.statusCode === 401) {
      const { logout } = useAuth()
      logout()
    }

    throw {
      statusCode: error.statusCode || 500,
      statusMessage: error.statusMessage || 'Erreur serveur',
      message: error.message || error.statusMessage || 'Une erreur est survenue',
      data: error.data
    } as ApiError
  }

  /**
   * Requête GET
   */
  async get<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
    try {
      const response = await $fetch<T>(`${this.baseUrl}${endpoint}`, {
        method: 'GET',
        headers: this.createHeaders(options.headers as Record<string, string>),
        ...options
      })
      return response
    } catch (error: any) {
      return this.handleError(error)
    }
  }

  /**
   * Requête POST
   */
  async post<T>(endpoint: string, body?: any, options: RequestInit = {}): Promise<T> {
    try {
      const response = await $fetch<T>(`${this.baseUrl}${endpoint}`, {
        method: 'POST',
        headers: this.createHeaders(options.headers as Record<string, string>),
        body,
        ...options
      })
      return response
    } catch (error: any) {
      return this.handleError(error)
    }
  }

  /**
   * Requête PUT
   */
  async put<T>(endpoint: string, body?: any, options: RequestInit = {}): Promise<T> {
    try {
      const response = await $fetch<T>(`${this.baseUrl}${endpoint}`, {
        method: 'PUT',
        headers: this.createHeaders(options.headers as Record<string, string>),
        body,
        ...options
      })
      return response
    } catch (error: any) {
      return this.handleError(error)
    }
  }

  /**
   * Requête PATCH
   */
  async patch<T>(endpoint: string, body?: any, options: RequestInit = {}): Promise<T> {
    try {
      const response = await $fetch<T>(`${this.baseUrl}${endpoint}`, {
        method: 'PATCH',
        headers: this.createHeaders(options.headers as Record<string, string>),
        body,
        ...options
      })
      return response
    } catch (error: any) {
      return this.handleError(error)
    }
  }

  /**
   * Requête DELETE
   */
  async delete<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
    try {
      const response = await $fetch<T>(`${this.baseUrl}${endpoint}`, {
        method: 'DELETE',
        headers: this.createHeaders(options.headers as Record<string, string>),
        ...options
      })
      return response
    } catch (error: any) {
      return this.handleError(error)
    }
  }
}

// Instance singleton du client API
export const apiClient = new ApiClient()

// Composable pour utiliser le client API dans les composants
export const useApiClient = () => {
  return apiClient
}
