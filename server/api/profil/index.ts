import { getProfileData } from "~/backend/services/user";
import { getUserFromToken } from "~/backend/services/auth";

export default defineEventHandler(async (event) => {
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

  // Récupérer les données du profil avec l'ID de l'utilisateur authentifié
  const profile = await getProfileData(user.id);

  if (!profile) {
    throw createError({
      statusCode: 404,
      statusMessage: "Profil introuvable",
    });
  }

  return profile;
});
