export default defineEventHandler(async (event) => {
  // Avec JWT, le logout est géré côté client (suppression du token)
  // Optionnel : Blacklister le token côté serveur si nécessaire
  
  return {
    success: true,
    message: 'Déconnexion réussie'
  }
})
