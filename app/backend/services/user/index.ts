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

export async function updateProfile(
  userId: number,
  data: {
    name?: string;
    email?: string;
  }
) {
  const { name, email } = data;

  if (!name && !email) {
    throw new Error("Au moins un champ (name ou email) doit être fourni.");
  }

  if (email && !/^\S+@\S+\.\S+$/.test(email.trim())) {
    throw new Error("L'adresse email n'est pas valide.");
  }

  try {
    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: {
        name: name ? name.trim() : undefined,
        email: email ? email.trim().toLowerCase() : undefined,
      },
      select: {
        id: true,
        name: true,
        email: true,
        createdAt: true,
        updatedAt: true,
      },
    });

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
      technologies: JSON.parse(p.technologies as string), // Prisma retourne string
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
      user: updatedUser,
      projects: formattedProjects,
      stats,
    };
  } catch (error: any) {
    if (error.code === "P2002" && error.meta?.target?.includes("email")) {
      throw new Error("Cet email est déjà utilisé par un autre compte.");
    }

    console.error("Erreur lors de la mise à jour du profil :", error);
    throw new Error(
      "Impossible de mettre à jour le profil. Veuillez réessayer."
    );
  }
}
