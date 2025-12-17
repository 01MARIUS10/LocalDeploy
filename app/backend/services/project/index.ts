import prisma from "../../../../server/utils/prisma";

// Types utiles (optionnel, tu peux les importer depuis prisma si tu génères des types)
export type CreateProjectInput = {
  name: string;
  description?: string | null;
  repositoryUrl?: string | null;
  userId: string;
};

export type UpdateProjectInput = {
  name?: string;
  description?: string | null;
  repositoryUrl?: string | null;
};

// Récupérer un projet par slug (avec relations)
export async function getProjectBySlug(slug: string) {
  return await prisma.project.findUnique({
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
}

// Créer un nouveau projet
export async function createProject(data: {
  name: string;
  description: string | null;
  domain: string;
  repositoryUrl: string | null;
  technologies: string[];
  status: "development" | "production";
  slug: string;
  userId: string;
}) {
  return await prisma.project.create({
    data: {
      name: data.name,
      description: data.description,
      domain: data.domain,
      repositoryUrl: data.domain,
      technologies: JSON.stringify(data.technologies),
      status: data.status,
      slug: data.slug,
      user: {
        connect: { id: Number(data.userId) },
      },
    },
    include: {
      user: { select: { id: true, name: true, email: true } },
      envVars: { orderBy: { key: "asc" } },
      deployments: { orderBy: { deployedAt: "desc" }, take: 10 },
    },
  });
}

// Mettre à jour un projet
// export async function updateProject(
//   slug: string,
//   data: UpdateProjectInput,
//   userId: string
// ) {
//   return await prisma.project.update({
//     where: { slug },
//     data,
//     include: {
//       user: { select: { id: true, name: true, email: true } },
//       envVars: { orderBy: { key: "asc" } },
//       deployments: { orderBy: { deployedAt: "desc" }, take: 10 },
//     },
//   });
// }

export async function updateProject(slug: string, data: any, userId: number) {
  const project = await prisma.project.findUnique({ where: { slug } });

  if (!project) throw new Error("Projet non trouvé");
  if (project.userId !== userId) throw new Error("Accès refusé");

  return prisma.project.update({
    where: { slug },
    data,
    include: {
      user: { select: { id: true, name: true, email: true } },
      envVars: { orderBy: { key: "asc" } },
      deployments: { orderBy: { deployedAt: "desc" }, take: 10 },
    },
  });
}
export async function deleteProject(slug: string, userId: string) {
  // Vérifier que le projet existe et appartient à l'utilisateur
  const project = await prisma.project.findUnique({
    where: { slug },
    select: {
      id: true,
      userId: true,
      envVars: { select: { id: true } },
      deployments: { select: { id: true } },
    },
  });

  if (!project) {
    throw new Error("Projet non trouvé");
  }

  if (project.userId.toString() !== userId) {
    throw new Error("Accès refusé : ce projet ne vous appartient pas");
  }

  // Supprimer avec deleteMany pour gérer les relations
  // Utiliser une transaction pour garantir la cohérence
  const result = await prisma.$transaction(async (tx) => {
    // Supprimer les variables d'environnement associées
    await tx.envVar.deleteMany({
      where: { projectId: project.id },
    });

    // Supprimer les déploiements associés
    await tx.deployment.deleteMany({
      where: { projectId: project.id },
    });

    // Supprimer le projet
    const deleteResult = await tx.project.deleteMany({
      where: {
        id: project.id,
        userId: parseInt(userId),
      },
    });

    return deleteResult;
  });

  if (result.count === 0) {
    throw new Error("Échec de la suppression du projet");
  }

  return { success: true, deletedCount: result.count };
}

// Fonction utilitaire pour générer un slug propre
function slugify(text: string): string {
  return text
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "") // enlève accents
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}
