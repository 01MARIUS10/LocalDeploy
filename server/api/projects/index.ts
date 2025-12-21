import prisma from "../../utils/prisma";
import { toProjectListItemDTO } from "~/backend/dto/project.dto";
import { authUser } from "~/backend/requests";

export default defineEventHandler(async (event) => {
  try {
    const user = await authUser(event);
    if (!user) {
      return { error: "Unauthorized" };
    }

    const projects = await prisma.project.findMany({
      where: { userId: user.id },
      include: {
        user: {
          select: { id: true, name: true, email: true },
        },
        _count: {
          select: {
            deployments: true,
            envVars: true,
          },
        },
      },
      orderBy: { updatedAt: "desc" },
    });

    return {
      projects: projects.map((p) => toProjectListItemDTO(p)),
      total: projects.length,
    };
  } catch (error) {
    return {
      error: (error as any).message || "An unexpected error occurred.",
    };
  }
});
