// server/api/profile.put.ts

import { defineEventHandler, readBody, createError } from "h3";
import { updateProfile } from "~/backend/services/user";

export default defineEventHandler(async (event) => {
  const userId = 6;

  if (!userId || isNaN(Number(userId))) {
    throw createError({
      statusCode: 401,
      statusMessage: "Vous devez être connecté pour modifier votre profil.",
    });
  }

  // 2. Lire les données envoyées par le frontend
  const body = await readBody(event);

  const { name, email } = body;

  // Validation minimale côté serveur
  if (!name && !email) {
    throw createError({
      statusCode: 400,
      statusMessage: "Au moins un champ (nom ou email) doit être fourni.",
    });
  }

  try {
    // 3. Utiliser le service pour mettre à jour le profil
    const result = await updateProfile(Number(userId), {
      name: name as string | undefined,
      email: email as string | undefined,
    });

    // 4. Retourner les données mises à jour au frontend
    // (format identique à getProfileData pour cohérence)
    return {
      success: true,
      user: result.user,
      projects: result.projects,
      stats: result.stats,
    };
  } catch (error: any) {
    // Gestion des erreurs renvoyées par le service
    const message =
      error.message ||
      "Une erreur est survenue lors de la mise à jour du profil.";

    throw createError({
      statusCode: error.message.includes("email") ? 409 : 400,
      statusMessage: message,
    });
  }
});
