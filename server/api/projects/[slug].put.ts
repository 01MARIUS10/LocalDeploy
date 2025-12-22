// server/api/projects/[slug].put.ts
import { updateProject } from "~/backend/services/project";
import { authUser } from "~/backend/requests";
import { toProjectDTO } from "~/backend/dto/project.dto";

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
      statusMessage: "Le paramètre 'slug' est requis",
    });
  }

  const body = await readBody(event);

  const data: any = {};

  // Champs autorisés à être modifiés
  if (body.name !== undefined) data.name = body.name.trim();
  if (body.description !== undefined)
    data.description = body.description?.trim() || null;
  if (body.domain !== undefined) data.domain = body.domain?.trim() || null;
  if (body.status !== undefined) data.status = body.status;
  if (body.branch !== undefined) data.branch = body.branch.trim();
  if (body.buildCommand !== undefined)
    data.buildCommand = body.buildCommand.trim();
  if (body.startCommand !== undefined)
    data.startCommand = body.startCommand.trim();
  if (body.outputDir !== undefined) data.outputDir = body.outputDir.trim();

  // Repository URL
  if (body.repositoryUrl !== undefined) {
    data.repositoryUrl = body.repositoryUrl?.trim() || null;
  }

  // Technologies (array → JSON string)
  if (Array.isArray(body.technologies)) {
    data.technologies = JSON.stringify(body.technologies);
  }

  try {
    const updated = await updateProject(slug, data, user.id);
    return toProjectDTO(updated);
  } catch (e: any) {
    throw createError({
      statusCode: e.message.includes("non trouvé")
        ? 404
        : e.message.includes("Accès refusé")
        ? 403
        : 500,
      statusMessage: e.message || "Erreur lors de la mise à jour",
    });
  }
});
