export default defineEventHandler(() => {
  return {
    status: 'success',
    message: 'Données figées depuis l\'API',
    data: {
      users: [
        { id: 1, name: 'Alice Dupont', role: 'Admin' },
        { id: 2, name: 'Bob Martin', role: 'Utilisateur' },
        { id: 3, name: 'Claire Bernard', role: 'Modérateur' }
      ],
      stats: {
        totalUsers: 3,
        activeProjects: 12,
        lastUpdate: '2025-12-02T10:00:00Z'
      }
    }
  }
})
