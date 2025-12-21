import { useAuth } from '~/frontend/auth'

export interface DeploymentLogEvent {
  type: 'start' | 'phase' | 'info' | 'log' | 'warn' | 'error' | 'success' | 'complete' | 'end'
  message?: string
  code?: number
  error?: string
}

export interface DeploymentStreamOptions {
  slug: string
  onLog: (event: DeploymentLogEvent) => void
  onError?: (error: Error) => void
  onComplete?: () => void
}

/**
 * Créer un stream de déploiement avec authentification
 */
export async function createDeploymentStream(options: DeploymentStreamOptions): Promise<() => void> {
  const { slug, onLog, onError, onComplete } = options
  const { accessToken } = useAuth()

  if (!accessToken.value) {
    throw new Error('Non authentifié')
  }

  let aborted = false

  try {
    const response = await fetch(`/api/projects/deploy-stream?slug=${slug}`, {
      method: 'GET',
      headers: {
        Authorization: `Bearer ${accessToken.value}`,
        Accept: 'text/event-stream',
      },
    })

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`)
    }

    if (!response.body) {
      throw new Error('Response body is null')
    }

    const reader = response.body.getReader()
    const decoder = new TextDecoder()

    let buffer = ''

    // Fonction pour lire le stream
    const readStream = async () => {
      while (!aborted) {
        const { done, value } = await reader.read()

        if (done) {
          onComplete?.()
          break
        }

        // Décoder le chunk
        buffer += decoder.decode(value, { stream: true })

        // Traiter les événements SSE
        const events = buffer.split('\n\n')
        buffer = events.pop() || ''

        for (const event of events) {
          if (!event.trim() || aborted) continue

          // Parser l'événement SSE
          const lines = event.split('\n')
          let data = ''

          for (const line of lines) {
            if (line.startsWith('data: ')) {
              data = line.substring(6)
              break
            }
          }

          if (!data) continue

          try {
            const parsed: DeploymentLogEvent = JSON.parse(data)
            onLog(parsed)

            if (parsed.type === 'end') {
              aborted = true
              break
            }
          } catch (error) {
            console.error('Erreur lors du parsing du log:', error)
          }
        }
      }
    }

    // Démarrer la lecture
    readStream().catch((error) => {
      if (!aborted) {
        onError?.(error)
      }
    })

    // Retourner une fonction pour annuler le stream
    return () => {
      aborted = true
      reader.cancel()
    }
  } catch (error) {
    onError?.(error as Error)
    throw error
  }
}

/**
 * Composable pour gérer le déploiement avec streaming
 */
export function useDeploymentStream() {
  const isDeploying = ref(false)
  const logs = ref<string[]>([])
  let cancelStream: (() => void) | null = null

  const startDeployment = async (slug: string) => {
    if (isDeploying.value) return

    isDeploying.value = true
    logs.value = []
    logs.value.push(`Démarrage du déploiement du projet: ${slug}`)
    logs.value.push(`${new Date().toLocaleString('fr-FR')}`)
    logs.value.push('─'.repeat(80))

    try {
      cancelStream = await createDeploymentStream({
        slug,
        onLog: (event) => {
          switch (event.type) {
            case 'start':
              logs.value.push(`[INFO] ${event.message}`)
              break
            case 'phase':
              logs.value.push('')
              logs.value.push('═'.repeat(80))
              logs.value.push(`[PHASE] ${event.message}`)
              logs.value.push('═'.repeat(80))
              break
            case 'info':
              logs.value.push(`[INFO] ${event.message}`)
              break
            case 'log':
              logs.value.push(event.message || '')
              break
            case 'warn':
              logs.value.push(`[WARN] ${event.message}`)
              break
            case 'error':
              logs.value.push(`[ERROR] ${event.message}`)
              break
            case 'success':
              logs.value.push(`[SUCCESS] ${event.message}`)
              break
            case 'complete':
              logs.value.push('')
              logs.value.push('═'.repeat(80))
              logs.value.push(`${event.message}`)
              logs.value.push('═'.repeat(80))
              break
            case 'end':
              logs.value.push(`Déploiement terminé à ${new Date().toLocaleString('fr-FR')}`)
              isDeploying.value = false
              break
          }
        },
        onError: (error) => {
          logs.value.push(`[ERROR] ${error.message}`)
          isDeploying.value = false
        },
        onComplete: () => {
          isDeploying.value = false
        },
      })
    } catch (error) {
      logs.value.push(`[ERROR] ${(error as Error).message}`)
      isDeploying.value = false
    }
  }

  const cancelDeployment = () => {
    if (cancelStream) {
      cancelStream()
      logs.value.push('[WARN] Déploiement annulé par l\'utilisateur')
      isDeploying.value = false
    }
  }

  const clearLogs = () => {
    logs.value = []
  }

  return {
    isDeploying: readonly(isDeploying),
    logs: readonly(logs),
    startDeployment,
    cancelDeployment,
    clearLogs,
  }
}
