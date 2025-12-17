<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <h1 class="text-4xl font-bold text-gray-800 mb-2">Mes Projets</h1>
    <p class="text-gray-600 mb-8">Liste de tous mes projets déployés</p>

    <NuxtLink
      to="/projects/new"
      class="mt-4 sm:mt-0 mb-5 inline-flex items-center gap-2 bg-indigo-600 hover:bg-indigo-700 text-white font-medium px-5 py-3 rounded-lg shadow-md hover:shadow-lg transition-all duration-200"
    >
      <svg
        class="w-5 h-5"
        fill="none"
        stroke="currentColor"
        viewBox="0 0 24 24"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M12 4v16m8-8H4"
        />
      </svg>
      Ajouter un projet
    </NuxtLink>

    <div v-if="pending" class="text-center py-12">
      <div
        class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"
      ></div>
      <p class="mt-4 text-gray-600">Chargement des projets...</p>
    </div>

    <div
      v-else-if="data"
      class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
    >
      <NuxtLink
        v-for="project in data.projects"
        :key="project.id"
        :to="`/projects/${project.slug}`"
        class="bg-white rounded-xl shadow-md hover:shadow-xl transition-shadow duration-300 border border-gray-200 overflow-hidden group"
      >
        <div class="p-6">
          <div class="flex items-start justify-between mb-3">
            <h2
              class="text-xl font-bold text-gray-800 group-hover:text-indigo-600 transition-colors"
            >
              {{ project.name }}
            </h2>
            <span
              :class="[
                'px-2 py-1 rounded-full text-xs font-semibold',
                project.status === 'production'
                  ? 'bg-green-100 text-green-800'
                  : 'bg-yellow-100 text-yellow-800',
              ]"
            >
              {{ project.status === "production" ? "🟢" : "🟡" }}
            </span>
          </div>

          <p class="text-gray-600 text-sm mb-4 line-clamp-2">
            {{ project.description }}
          </p>

          <div class="flex items-center gap-2 text-xs text-gray-500 mb-4">
            <span>🌐 {{ project.domain }}</span>
          </div>

          <div class="flex flex-wrap gap-1 mb-4">
            <span
              v-for="tech in project.technologies.slice(0, 3)"
              :key="tech"
              class="px-2 py-1 bg-indigo-50 text-indigo-700 rounded text-xs"
            >
              {{ tech }}
            </span>
            <span
              v-if="project.technologies.length > 3"
              class="px-2 py-1 bg-gray-100 text-gray-600 rounded text-xs"
            >
              +{{ project.technologies.length - 3 }}
            </span>
          </div>

          <div class="text-xs text-gray-400">
            Déployé {{ formatRelativeTime(project.lastDeployment) }}
          </div>
        </div>

        <div
          class="bg-gradient-to-r from-indigo-500 to-purple-600 h-1 group-hover:h-2 transition-all duration-300"
        ></div>
      </NuxtLink>
    </div>

    <div v-if="data?.projects.length === 0" class="text-center py-12">
      <p class="text-gray-500">Aucun projet pour le moment</p>
    </div>
  </div>
</template>

<script setup lang="ts">
interface Project {
  id: string;
  slug: string;
  name: string;
  description: string;
  status: "production" | "staging";
  domain: string;
  technologies: string[];
  lastDeployment: string;
}

interface ProjectsResponse {
  projects: Project[];
}
const { data, pending } = await useFetch<ProjectsResponse>("/api/projects");

//const { data, pending } = await useFetch("/api/projects");

function formatRelativeTime(dateString: string) {
  const date = new Date(dateString);
  const now = new Date();
  const diffInSeconds = Math.floor((now.getTime() - date.getTime()) / 1000);

  if (diffInSeconds < 60) return "il y a quelques secondes";
  if (diffInSeconds < 3600)
    return `il y a ${Math.floor(diffInSeconds / 60)} min`;
  if (diffInSeconds < 86400)
    return `il y a ${Math.floor(diffInSeconds / 3600)}h`;
  return `il y a ${Math.floor(diffInSeconds / 86400)} jours`;
}

useHead({
  title: "Mes Projets",
  meta: [
    { name: "description", content: "Liste de tous mes projets déployés" },
  ],
});
</script>
