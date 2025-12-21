import prisma from "../../utils/prisma";
import { toProjectDTO } from "~/backend/dto/project.dto";
import type { ProjectDTO } from "~/backend/dto/project.dto";

export default defineEventHandler(async (event) => {
  const slug = getRouterParam(event, "slug");

  const project = await prisma.project.findUnique({
    where: { slug },
    include: {
      user: {
        select: { id: true, name: true, email: true },
      },
      envVars: {
        orderBy: { key: "asc" },
      },
      deployments: {
        orderBy: { deployedAt: "desc" },
        take: 10,
      },
    },
  });

  if (!project) {
    throw createError({
      statusCode: 404,
      statusMessage: "Projet non trouvé",
    });
  }

  // Utiliser le DTO pour formater les données
  return toProjectDTO(project);
});
