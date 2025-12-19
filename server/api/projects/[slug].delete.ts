// server/api/projects/[slug].delete.ts
import { is } from "zod/locales";
import { authUser } from "~/backend/requests";
import { deleteProject, isOwner } from "~/backend/services/project";

export default defineEventHandler(async (event) => {
  const user = await authUser(event);
  if (!user) {
    throw createError({
      statusCode: 401,
      statusMessage: "Non autorisé",
    });
  }

  const slug = getRouterParam(event, "slug");
  if (!slug) {
    throw createError({
      statusCode: 400,
      statusMessage: "Le paramètre 'slug' est requis dans l'URL",
    });
  }

  try {
    const isOwner_ = await isOwner(slug, user.id.toString());
    if (!isOwner_) {
      return {
        error: "Accès refusé",
      };
    }

    await deleteProject(slug, user.id.toString());

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
