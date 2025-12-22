import { fetchGitHubBranchInfo, fetchGitHubRepoInfo, parseGitHubUrl } from "~/../server/utils/github";

export default defineEventHandler(async (event) => {
  const query = getQuery(event);
  const repoUrl = query.url as string;
  const branch = (query.branch as string) || 'main';

  if (!repoUrl) {
    throw createError({
      statusCode: 400,
      message: "Le paramètre 'url' est requis",
    });
  }

  // Valider l'URL GitHub
  const parsed = parseGitHubUrl(repoUrl);
  if (!parsed) {
    throw createError({
      statusCode: 400,
      message: "URL GitHub invalide",
    });
  }

  try {
    // Récupérer les infos du repo et de la branche en parallèle
    const [repoInfo, branchInfo] = await Promise.all([
      fetchGitHubRepoInfo(repoUrl),
      fetchGitHubBranchInfo(repoUrl, branch),
    ]);

    if (!branchInfo) {
      throw createError({
        statusCode: 404,
        message: `Branche '${branch}' introuvable ou repository inaccessible`,
      });
    }

    return {
      success: true,
      data: {
        // Infos du repository
        repo: {
          name: repoInfo?.name || parsed.repo,
          full_name: repoInfo?.full_name || `${parsed.owner}/${parsed.repo}`,
          description: repoInfo?.description || '',
          default_branch: repoInfo?.default_branch || 'main',
          private: repoInfo?.private || false,
          html_url: repoInfo?.html_url || `https://github.com/${parsed.owner}/${parsed.repo}`,
          language: repoInfo?.language || '',
          stars: repoInfo?.stars || 0,
          forks: repoInfo?.forks || 0,
        },
        // Infos du propriétaire
        owner: {
          avatar_url: branchInfo.user_avatar || repoInfo?.owner_avatar || '',
          name: branchInfo.user_name || repoInfo?.owner_name || parsed.owner,
          github_url: branchInfo.user_github_link || repoInfo?.owner_url || `https://github.com/${parsed.owner}`,
        },
        // Infos du dernier commit
        last_commit: {
          sha: branchInfo.last_commit_sha,
          short_sha: branchInfo.last_commit_sha?.substring(0, 7) || '',
          message: branchInfo.last_commit_message,
          date: branchInfo.last_commit_date,
          author: branchInfo.last_commit_author,
        },
        // Branche actuelle
        branch: branchInfo.branch,
      },
    };
  } catch (error: any) {
    // Si c'est déjà une erreur HTTP, la propager
    if (error.statusCode) {
      throw error;
    }

    throw createError({
      statusCode: 500,
      message: "Erreur lors de la récupération des informations GitHub",
    });
  }
});
