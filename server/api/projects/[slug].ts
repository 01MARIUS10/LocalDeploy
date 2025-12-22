import prisma from "../../utils/prisma";
import { toProjectDTO } from "~/backend/dto/project.dto";
import type { ProjectDTO, GitHubInfo } from "~/backend/dto/project.dto";
import { fetchGitHubBranchInfo, fetchGitHubRepoInfo, parseGitHubUrl } from "~/../server/utils/github";

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

  // Récupérer les infos GitHub si l'URL est valide
  let githubInfo: GitHubInfo | null = null;
  
  if (project.repositoryUrl && parseGitHubUrl(project.repositoryUrl)) {
    try {
      const [repoInfo, branchInfo] = await Promise.all([
        fetchGitHubRepoInfo(project.repositoryUrl),
        fetchGitHubBranchInfo(project.repositoryUrl, project.branch || 'main'),
      ]);

      if (branchInfo) {
        const parsed = parseGitHubUrl(project.repositoryUrl);
        githubInfo = {
          owner: {
            avatar_url: branchInfo.user_avatar || repoInfo?.owner_avatar || '',
            name: branchInfo.user_name || repoInfo?.owner_name || parsed?.owner || '',
            github_url: branchInfo.user_github_link || repoInfo?.owner_url || '',
          },
          last_commit: {
            sha: branchInfo.last_commit_sha,
            short_sha: branchInfo.last_commit_sha?.substring(0, 7) || '',
            message: branchInfo.last_commit_message,
            date: branchInfo.last_commit_date,
            author: branchInfo.last_commit_author,
          },
          repo: {
            name: repoInfo?.name || parsed?.repo || '',
            full_name: repoInfo?.full_name || `${parsed?.owner}/${parsed?.repo}`,
            description: repoInfo?.description || '',
            default_branch: repoInfo?.default_branch || 'main',
            private: repoInfo?.private || false,
            html_url: repoInfo?.html_url || `https://github.com/${parsed?.owner}/${parsed?.repo}`,
            language: repoInfo?.language || '',
            stars: repoInfo?.stars || 0,
            forks: repoInfo?.forks || 0,
          },
        };
      }
    } catch (error) {
      console.error('Erreur lors de la récupération des infos GitHub:', error);
      // On continue sans les infos GitHub en cas d'erreur
    }
  }

  // Utiliser le DTO pour formater les données avec les infos GitHub
  return toProjectDTO(project, githubInfo);
});
