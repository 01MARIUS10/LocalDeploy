// server/api/projects/[slug].put.ts

import { updateProject } from "~/backend/services/project";
import { toProjectDTO } from "~/backend/dto/project.dto";

export default defineEventHandler(async (event) => {
  const user = event.context.user; // à adapter selon ton auth
  //   if (!user) {
  //     throw createError({
  //       statusCode: 401,
  //       statusMessage: "Authentification requise",
  //     });
  //   }
  const tempUserId = 1;

  const slug = getRouterParam(event, "slug");
  if (!slug) {
    throw createError({
      statusCode: 400,
      statusMessage: "Le paramètre 'slug' est requis dans l'URL",
    });
  }
  const body = await readBody(event);

  const data: any = {};

  // Champs simples
  if (body.name !== undefined) data.name = body.name.trim();
  if (body.description !== undefined)
    data.description = body.description?.trim() || null;
  if (body.status !== undefined) data.status = body.status;
  if (body.domain !== undefined) data.domain = body.domain.trim();

  // Repository
  if (body.repository?.url) {
    data.repositoryUrl = body.repository.url.trim();
  }

  // Technologies
  if (Array.isArray(body.technologies)) {
    data.technologies = JSON.stringify(body.technologies);
  }

  try {
    const updated = await updateProject(slug, data, tempUserId);
    return toProjectDTO(updated);
  } catch (e: any) {
    throw e;
  }
});
