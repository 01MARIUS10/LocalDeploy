import { createProject } from "~/backend/services/project";
import { toProjectDTO } from "~/backend/dto/project.dto";
import { authUser } from "~/backend/requests";

export default defineEventHandler(async (event) => {
  const user = await authUser(event);

  if (!user) {
    throw createError({
      statusCode: 401,
      statusMessage: "Authentification requise",
    });
  }

  const body = await readBody(event);

  const {
    name,
    description,
    repositoryUrl,
    domain,
    technologies = [],
    status = "development",
    slug,
  } = body;

  if (!name || typeof name !== "string" || name.trim().length === 0) {
    throw createError({
      statusCode: 400,
      statusMessage: "Le nom du projet est obligatoire",
    });
  }
  const finalSlug =
    slug && typeof slug === "string" && slug.trim() !== ""
      ? slug.trim()
      : name
          .toLowerCase()
          .normalize("NFD")
          .replace(/[\u0300-\u036f]/g, "")
          .replace(/[^a-z0-9]+/g, "-")
          .replace(/(^-|-$)/g, "");

  // Vérification que le slug est assez long
  if (finalSlug.length < 3) {
    throw createError({
      statusCode: 400,
      statusMessage:
        "Le nom doit permettre de générer un slug valide (minimum 3 caractères alphanumériques)",
    });
  }

  // Sécurité sur les technologies
  const techArray = Array.isArray(technologies) ? technologies : [];

  const project = await createProject({
    name: name.trim(),
    description: description?.trim() || null,
    domain: domain?.trim() || null,
    repositoryUrl: repositoryUrl?.trim() || null,
    technologies: techArray,
    status: status === "production" ? "production" : "development",
    slug: finalSlug,
    userId: user.id.toString(),
  });

  return toProjectDTO(project);
});
