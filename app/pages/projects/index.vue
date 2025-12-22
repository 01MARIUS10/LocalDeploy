<template>
  <div class="min-h-screen bg-gradient-to-b from-slate-950 via-slate-900 to-slate-950">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <h1 class="text-4xl font-bold text-white mb-2">Mes Projets</h1>
      <p class="text-slate-400 mb-8">Liste de tous mes projets déployés</p>

      <NuxtLink
        to="/projects/new"
        class="mt-4 sm:mt-0 mb-5 inline-flex items-center gap-2 bg-emerald-500 hover:bg-emerald-400 text-slate-900 font-bold px-5 py-3 rounded-lg shadow-lg shadow-emerald-500/25 hover:shadow-emerald-400/40 transition-all duration-200"
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
          class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-emerald-500"
        ></div>
        <p class="mt-4 text-slate-400">Chargement des projets...</p>
      </div>

      <div
        v-else-if="data"
        class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
      >
        <NuxtLink
          v-for="project in data.projects"
          :key="project.id"
          :to="`/projects/${project.slug}`"
          class="bg-slate-900 rounded-xl border border-slate-700/50 hover:border-emerald-500/50 shadow-lg hover:shadow-emerald-500/10 transition-all duration-300 overflow-hidden group"
        >
          <div class="p-6">
            <div class="flex items-start justify-between mb-3">
              <h2
                class="text-xl font-bold text-white group-hover:text-emerald-400 transition-colors"
              >
                {{ project.name }}
              </h2>
              <span
                :class="[
                  'px-2 py-1 rounded-full text-xs font-semibold',
                  project.status === 'production'
                    ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20'
                    : 'bg-yellow-500/10 text-yellow-400 border border-yellow-500/20',
                ]"
              >
                {{ project.status === "production" ? "🟢" : "🟡" }}
              </span>
            </div>

            <p class="text-slate-400 text-sm mb-4 line-clamp-2">
              {{ project.description }}
            </p>

            <div class="flex items-center gap-2 text-xs text-slate-500 mb-4">
              <span>🌐 {{ project.domain }}</span>
            </div>

            <div class="flex flex-wrap gap-1 mb-4">
              <span
                v-for="tech in project.technologies.slice(0, 3)"
                :key="tech"
                class="px-2 py-1 bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 rounded text-xs"
              >
                {{ tech }}
              </span>
              <span
                v-if="project.technologies.length > 3"
                class="px-2 py-1 bg-slate-800 text-slate-400 rounded text-xs"
              >
                +{{ project.technologies.length - 3 }}
              </span>
            </div>

            <div class="text-xs text-slate-500">
              Déployé {{ formatRelativeTime(project.lastDeployment) }}
            </div>
          </div>

          <div
            class="bg-gradient-to-r from-emerald-500 to-cyan-500 h-1 group-hover:h-2 transition-all duration-300"
          ></div>
        </NuxtLink>
      </div>

      <div v-if="data?.projects.length === 0" class="text-center py-12">
        <p class="text-slate-500">Aucun projet pour le moment</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";

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
  total: number;
}

const api = useApiClient();

const data = ref<ProjectsResponse | null>(null);
const pending = ref(true);
const error = ref<string | null>(null);

onMounted(async () => {
  try {
    data.value = await api.get<ProjectsResponse>("/projects");
  } catch (e: any) {
    error.value = e.message;
  } finally {
    pending.value = false;
  }
});

function formatRelativeTime(dateString: string) {
  const date = new Date(dateString);
  const now = new Date();
  const diff = Math.floor((now.getTime() - date.getTime()) / 1000);

  if (diff < 60) return "il y a quelques secondes";
  if (diff < 3600) return `il y a ${Math.floor(diff / 60)} min`;
  if (diff < 86400) return `il y a ${Math.floor(diff / 3600)}h`;
  return `il y a ${Math.floor(diff / 86400)} jours`;
}

useHead({
  title: "Mes Projets",
  meta: [
    { name: "description", content: "Liste de tous mes projets déployés" },
  ],
});
</script>
