import prisma from "../../../../server/utils/prisma";

export async function getProfileData(userId: number) {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      id: true,
      name: true,
      email: true,
      createdAt: true,
      updatedAt: true,
    },
  });

  if (!user) return null;

  const projects = await prisma.project.findMany({
    where: { userId },
    orderBy: { updatedAt: "desc" },
    include: {
      deployments: { select: { id: true } },
      envVars: { select: { id: true } },
    },
  });

  const formattedProjects = projects.map((p) => ({
    ...p,
    technologies: JSON.parse(p.technologies),
    _count: {
      deployments: p.deployments.length,
      envVars: p.envVars.length,
    },
  }));

  const stats = {
    totalProjects: projects.length,
    activeProjects: projects.filter((p) => p.status === "running").length,
    totalDeployments: projects.reduce(
      (acc, p) => acc + p.deployments.length,
      0
    ),
  };

  return {
    user,
    projects: formattedProjects,
    stats,
  };
}
