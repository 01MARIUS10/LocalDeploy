/**
 * Utilitaires pour l'API GitHub
 */

export interface GitHubBranchInfo {
  user_avatar: string;
  user_name: string;
  user_github_link: string;
  last_commit_sha: string;
  last_commit_message: string;
  last_commit_date: string;
  last_commit_author: string;
  branch: string;
  repo_name: string;
  repo_full_name: string;
}

export interface GitHubRepoInfo {
  owner: string;
  repo: string;
  branch: string;
}

/**
 * Parse une URL GitHub pour extraire owner et repo
 * @example parseGitHubUrl("https://github.com/Narindra1/Valentine.git")
 * // => { owner: "Narindra1", repo: "Valentine" }
 */
export function parseGitHubUrl(url: string): { owner: string; repo: string } | null {
  if (!url) return null;

  // Patterns supportés:
  // - https://github.com/owner/repo.git
  // - https://github.com/owner/repo
  // - git@github.com:owner/repo.git
  // - git@github.com:owner/repo

  const patterns = [
    // HTTPS avec ou sans .git
    /(?:https?:\/\/)?github\.com\/([^\/]+)\/([^\/\.]+)(?:\.git)?/,
    // SSH
    /git@github\.com:([^\/]+)\/([^\/\.]+)(?:\.git)?/,
  ];

  for (const pattern of patterns) {
    const match = url.match(pattern);
    if (match) {
      return {
        owner: match[1],
        repo: match[2].replace(/\.git$/, ''),
      };
    }
  }

  return null;
}

/**
 * Construit l'URL de l'API GitHub pour une branche
 * @example buildGitHubApiUrl("https://github.com/Narindra1/Valentine.git", "main")
 * // => "https://api.github.com/repos/Narindra1/Valentine/branches/main"
 */
export function buildGitHubApiUrl(repoUrl: string, branch: string = 'main'): string | null {
  const parsed = parseGitHubUrl(repoUrl);
  if (!parsed) return null;

  return `https://api.github.com/repos/${parsed.owner}/${parsed.repo}/branches/${branch}`;
}

/**
 * Récupère les informations d'une branche GitHub
 */
export async function fetchGitHubBranchInfo(
  repoUrl: string,
  branch: string = 'main',
  token?: string
): Promise<GitHubBranchInfo | null> {
  const parsed = parseGitHubUrl(repoUrl);
  if (!parsed) {
    console.error('Invalid GitHub URL:', repoUrl);
    return null;
  }

  const apiUrl = `https://api.github.com/repos/${parsed.owner}/${parsed.repo}/branches/${branch}`;

  try {
    const headers: Record<string, string> = {
      'Accept': 'application/vnd.github.v3+json',
      'User-Agent': 'LocalDeploy-App',
    };

    // Ajouter le token si disponible (pour les repos privés ou éviter le rate limit)
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    const response = await fetch(apiUrl, { headers });

    if (!response.ok) {
      console.error(`GitHub API error: ${response.status} ${response.statusText}`);
      return null;
    }

    const data = await response.json();

    // Extraire les informations
    const commit = data.commit;
    const author = commit?.commit?.author;
    const committer = commit?.author || commit?.committer;

    return {
      user_avatar: committer?.avatar_url || '',
      user_name: committer?.login || author?.name || 'Unknown',
      user_github_link: committer?.html_url || `https://github.com/${parsed.owner}`,
      last_commit_sha: commit?.sha || '',
      last_commit_message: commit?.commit?.message || '',
      last_commit_date: author?.date || '',
      last_commit_author: author?.name || committer?.login || 'Unknown',
      branch: data.name || branch,
      repo_name: parsed.repo,
      repo_full_name: `${parsed.owner}/${parsed.repo}`,
    };
  } catch (error) {
    console.error('Error fetching GitHub branch info:', error);
    return null;
  }
}

/**
 * Récupère les informations de base d'un repository GitHub
 */
export async function fetchGitHubRepoInfo(
  repoUrl: string,
  token?: string
): Promise<{
  name: string;
  full_name: string;
  description: string;
  default_branch: string;
  private: boolean;
  html_url: string;
  owner_avatar: string;
  owner_name: string;
  owner_url: string;
  stars: number;
  forks: number;
  language: string;
  updated_at: string;
} | null> {
  const parsed = parseGitHubUrl(repoUrl);
  if (!parsed) return null;

  const apiUrl = `https://api.github.com/repos/${parsed.owner}/${parsed.repo}`;

  try {
    const headers: Record<string, string> = {
      'Accept': 'application/vnd.github.v3+json',
      'User-Agent': 'LocalDeploy-App',
    };

    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    const response = await fetch(apiUrl, { headers });

    if (!response.ok) {
      console.error(`GitHub API error: ${response.status}`);
      return null;
    }

    const data = await response.json();

    return {
      name: data.name,
      full_name: data.full_name,
      description: data.description || '',
      default_branch: data.default_branch,
      private: data.private,
      html_url: data.html_url,
      owner_avatar: data.owner?.avatar_url || '',
      owner_name: data.owner?.login || '',
      owner_url: data.owner?.html_url || '',
      stars: data.stargazers_count || 0,
      forks: data.forks_count || 0,
      language: data.language || '',
      updated_at: data.updated_at || '',
    };
  } catch (error) {
    console.error('Error fetching GitHub repo info:', error);
    return null;
  }
}
