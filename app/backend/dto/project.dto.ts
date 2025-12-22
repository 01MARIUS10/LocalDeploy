import type { Project, User, EnvVar, Deployment } from "@prisma/client";

// Type pour le projet avec ses relations
export type ProjectWithRelations = Project & {
  user: Pick<User, "id" | "name" | "email">;
  envVars: EnvVar[];
  deployments: Deployment[];
};

// DTO pour la réponse API d'un projet
export interface ProjectDTO {
  id: number;
  slug: string;
  name: string;
  description: string;
  status: string;
  domain: string;
  buildCommand: string;
  startCommand: string;
  repository: {
    url: string;
    branch: string;
    lastCommit: string | null;
  };
  deployment: {
    platform: string;
    buildCommand: string;
    outputDirectory: string;
    environmentVariables: Array<{
      key: string;
      value: string;
      secret: boolean;
    }>;
    lastDeployment: string | null;
    deploymentUrl: string;
  };
  database: {
    type: string;
    host: string;
    port: string | null;
    name: string;
    user: string;
    ssl: boolean;
    backupSchedule: string;
  };
  technologies: string[];
  createdAt: string;
  updatedAt: string;
  user: Pick<User, "id" | "name" | "email">;
  deployments: Deployment[];
}

export interface userInfo {
  id: number;
  name: string;
  email: string;
}

// DTO pour la liste des projets (version simplifiée)
export interface ProjectListItemDTO {
  id: number;
  slug: string;
  name: string;
  description: string;
  status: string;
  domain: string;
  technologies: string[];
  createdAt: string;
  updatedAt: string;
  user: userInfo;
  _count: {
    envVars: number;
    deployments: number;
  };
}

/**
 * Transforme un projet Prisma en DTO pour la réponse API détaillée
 */
export function toProjectDTO(project: ProjectWithRelations): ProjectDTO {
  const response = {
    id: project.id,
    slug: project.slug,
    name: project.name,
    description: project.description ?? "",
    status: project.status,
    domain: project.domain ?? "",
    buildCommand: project.buildCommand,
    startCommand: project.startCommand,
    repository: {
      url: project.repositoryUrl,
      branch: project.branch,
      lastCommit: project.lastCommit,
    },
    deployment: {
      platform: "Auto-Deploy Local",
      buildCommand: project.buildCommand,
      outputDirectory: project.outputDir,
      environmentVariables: project.envVars.map((env) => ({
        key: env.key,
        value: env.secret ? "***hidden***" : env.value,
        secret: env.secret,
      })),
      lastDeployment: project.lastDeployAt?.toISOString() || null,
      deploymentUrl: `https://${project.domain}`,
    },
    database: {
      type: project.databaseType || "None",
      host: project.databaseUrl ? new URL(project.databaseUrl).hostname : "-",
      port: project.databaseUrl
        ? new URL(project.databaseUrl).port || null
        : null,
      name: project.databaseType
        ? project.slug + "_db"
        : "Static site (no database)",
      user: "-",
      ssl: project.databaseUrl?.includes("ssl=true") || false,
      backupSchedule: project.databaseType ? "Daily at 3:00 AM UTC" : "-",
    },
    technologies: JSON.parse(project.technologies),
    createdAt: project.createdAt.toISOString(),
    updatedAt: project.updatedAt.toISOString(),
    user: {
      id: project.user.id,
      name: project.user.name,
      email: project.user.email,
    },
    deployments: project.deployments,
  };

  // console.log("Projet chargé pour édition :", response);

  return response;
}

/**
 * Transforme un projet Prisma en DTO pour la liste (version simplifiée)
 */
export function toProjectListItemDTO(project: any): ProjectListItemDTO {
  return {
    id: project.id,
    slug: project.slug,
    name: project.name,
    description: project.description,
    status: project.status,
    domain: project.domain,
    technologies: JSON.parse(project.technologies),
    createdAt: project.createdAt.toISOString(),
    updatedAt: project.updatedAt.toISOString(),
    user: {
      id: project.user.id,
      name: project.user.name,
      email: project.user.email,
    },
    _count: project._count,
  };
}
