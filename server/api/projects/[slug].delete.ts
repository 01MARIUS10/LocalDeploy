// server/api/projects/[slug].delete.ts

import { deleteProject } from "~/backend/services/project";

export default defineEventHandler(async (event) => {
  const user = event.context.user;
  //   if (!user) {
  //     throw createError({
  //       statusCode: 401,
  //       statusMessage: "Authentification requise",
  //     });
  //   }
  const tempUserId = "1";

  const slug = getRouterParam(event, "slug");
  if (!slug) {
    throw createError({
      statusCode: 400,
      statusMessage: "Le paramètre 'slug' est requis dans l'URL",
    });
  }

  try {
    await deleteProject(slug, tempUserId);

    // Réponse standard pour une suppression réussie
    return { success: true, message: "Projet supprimé avec succès" };
  } catch (error: any) {
    if (error.message === "Projet non trouvé") {
      throw createError({
        statusCode: 404,
        statusMessage: "Projet non trouvé",
      });
    }
    if (error.message.includes("Accès refusé")) {
      throw createError({
        statusCode: 403,
        statusMessage: "Accès refusé",
      });
    }
    throw error;
  }
});
