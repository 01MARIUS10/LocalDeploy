<template>
  <div class="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 py-12">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <!-- Header du profil -->
      <div class="bg-white rounded-2xl shadow-lg overflow-hidden mb-8">
        <div
          class="h-32 bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500"
        ></div>
        <div class="px-8 pb-8">
          <div
            class="flex flex-col sm:flex-row items-start sm:items-end -mt-16 mb-6"
          >
            <!-- Avatar -->
            <div class="relative">
              <div class="w-32 h-32 rounded-full bg-white p-2 shadow-xl">
                <div
                  class="w-full h-full rounded-full bg-gradient-to-br from-blue-400 to-purple-600 flex items-center justify-center text-white text-4xl font-bold"
                >
                  {{ userInitials }}
                </div>
              </div>
              <button
                class="absolute bottom-2 right-2 w-8 h-8 bg-white rounded-full shadow-lg flex items-center justify-center hover:bg-gray-100 transition"
              >
                <svg
                  class="w-4 h-4 text-gray-600"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"
                  />
                </svg>
              </button>
            </div>

            <!-- Infos utilisateur -->
            <div class="mt-4 sm:mt-0 sm:ml-6 flex-1">
              <div
                class="flex flex-col sm:flex-row sm:items-center sm:justify-between"
              >
                <div>
                  <h1 class="text-3xl font-bold text-gray-900">
                    {{ user.name }}
                  </h1>
                  <p class="text-gray-600 mt-1 flex items-center">
                    <svg
                      class="w-5 h-5 mr-2"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
                      />
                    </svg>
                    {{ user.email }}
                  </p>
                  <p class="text-sm text-gray-500 mt-2">
                    Membre depuis {{ formatDate(user.createdAt) }}
                  </p>
                </div>
                <button
                  class="mt-4 sm:mt-0 px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition shadow-md"
                >
                  Modifier le profil
                </button>
              </div>
            </div>
          </div>

          <!-- Statistiques -->
          <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mt-6">
            <div
              class="bg-gradient-to-br from-blue-50 to-blue-100 rounded-xl p-6 border border-blue-200"
            >
              <div class="flex items-center justify-between">
                <div>
                  <p class="text-sm font-medium text-blue-600">Projets</p>
                  <p class="text-3xl font-bold text-blue-900 mt-1">
                    {{ stats.totalProjects }}
                  </p>
                </div>
                <div
                  class="w-12 h-12 bg-blue-500 rounded-lg flex items-center justify-center"
                >
                  <svg
                    class="w-6 h-6 text-white"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"
                    />
                  </svg>
                </div>
              </div>
            </div>

            <div
              class="bg-gradient-to-br from-green-50 to-green-100 rounded-xl p-6 border border-green-200"
            >
              <div class="flex items-center justify-between">
                <div>
                  <p class="text-sm font-medium text-green-600">Déploiements</p>
                  <p class="text-3xl font-bold text-green-900 mt-1">
                    {{ stats.totalDeployments }}
                  </p>
                </div>
                <div
                  class="w-12 h-12 bg-green-500 rounded-lg flex items-center justify-center"
                >
                  <svg
                    class="w-6 h-6 text-white"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M5 12h14M5 12a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v4a2 2 0 01-2 2M5 12a2 2 0 00-2 2v4a2 2 0 002 2h14a2 2 0 002-2v-4a2 2 0 00-2-2m-2-4h.01M17 16h.01"
                    />
                  </svg>
                </div>
              </div>
            </div>

            <div
              class="bg-gradient-to-br from-purple-50 to-purple-100 rounded-xl p-6 border border-purple-200"
            >
              <div class="flex items-center justify-between">
                <div>
                  <p class="text-sm font-medium text-purple-600">Actifs</p>
                  <p class="text-3xl font-bold text-purple-900 mt-1">
                    {{ stats.activeProjects }}
                  </p>
                </div>
                <div
                  class="w-12 h-12 bg-purple-500 rounded-lg flex items-center justify-center"
                >
                  <svg
                    class="w-6 h-6 text-white"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
                    />
                  </svg>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Section des projets -->
      <div class="bg-white rounded-2xl shadow-lg p-8">
        <div class="flex items-center justify-between mb-6">
          <h2 class="text-2xl font-bold text-gray-900">Mes Projets</h2>
          <NuxtLink
            to="/projects/new"
            class="px-4 py-2 bg-gradient-to-r from-blue-600 to-purple-600 text-white rounded-lg hover:from-blue-700 hover:to-purple-700 transition shadow-md flex items-center gap-2"
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
            Nouveau projet
          </NuxtLink>
        </div>

        <!-- Filtres -->
        <div class="flex flex-wrap gap-2 mb-6">
          <button
            v-for="filter in filters"
            :key="filter.value"
            @click="activeFilter = filter.value"
            :class="[
              'px-4 py-2 rounded-lg font-medium transition',
              activeFilter === filter.value
                ? 'bg-blue-600 text-white shadow-md'
                : 'bg-gray-100 text-gray-700 hover:bg-gray-200',
            ]"
          >
            {{ filter.label }}
          </button>
        </div>

        <!-- Liste des projets -->
        <div
          v-if="pending"
          class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
        >
          <div v-for="i in 6" :key="i" class="animate-pulse">
            <div class="bg-gray-200 h-48 rounded-xl"></div>
          </div>
        </div>

        <div v-else-if="error" class="text-center py-12">
          <div class="text-red-500 mb-4">
            <svg
              class="w-16 h-16 mx-auto"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
              />
            </svg>
          </div>
          <p class="text-gray-600">Erreur lors du chargement des projets</p>
        </div>

        <div
          v-else-if="filteredProjects.length === 0"
          class="text-center py-12"
        >
          <div class="text-gray-400 mb-4">
            <svg
              class="w-16 h-16 mx-auto"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"
              />
            </svg>
          </div>
          <p class="text-gray-600 text-lg mb-2">Aucun projet pour le moment</p>
          <p class="text-gray-500 text-sm">
            Commencez par créer votre premier projet !
          </p>
        </div>

        <div
          v-else
          class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
        >
          <NuxtLink
            v-for="project in filteredProjects"
            :key="project.id"
            :to="`/projects/${project.slug}`"
            class="group bg-gradient-to-br from-gray-50 to-gray-100 rounded-xl p-6 border-2 border-gray-200 hover:border-blue-500 hover:shadow-xl transition-all duration-300"
          >
            <!-- Status badge -->
            <div class="flex items-center justify-between mb-4">
              <span
                :class="[
                  'px-3 py-1 rounded-full text-xs font-semibold',
                  project.status === 'active'
                    ? 'bg-green-100 text-green-800'
                    : project.status === 'building'
                    ? 'bg-yellow-100 text-yellow-800'
                    : 'bg-gray-100 text-gray-800',
                ]"
              >
                {{ getStatusLabel(project.status) }}
              </span>
              <svg
                class="w-5 h-5 text-gray-400 group-hover:text-blue-600 transition"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M9 5l7 7-7 7"
                />
              </svg>
            </div>

            <!-- Nom et description -->
            <h3
              class="text-xl font-bold text-gray-900 mb-2 group-hover:text-blue-600 transition"
            >
              {{ project.name }}
            </h3>
            <p class="text-gray-600 text-sm mb-4 line-clamp-2">
              {{ project.description }}
            </p>

            <!-- Domaine -->
            <div class="flex items-center text-sm text-gray-500 mb-4">
              <svg
                class="w-4 h-4 mr-2"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9"
                />
              </svg>
              {{ project.domain }}
            </div>

            <!-- Technologies -->
            <div class="flex flex-wrap gap-2 mb-4">
              <span
                v-for="tech in project.technologies.slice(0, 3)"
                :key="tech"
                class="px-2 py-1 bg-white text-gray-700 text-xs rounded-md border border-gray-300"
              >
                {{ tech }}
              </span>
              <span
                v-if="project.technologies.length > 3"
                class="px-2 py-1 bg-gray-200 text-gray-600 text-xs rounded-md"
              >
                +{{ project.technologies.length - 3 }}
              </span>
            </div>

            <!-- Stats -->
            <div
              class="flex items-center justify-between text-sm text-gray-500 pt-4 border-t border-gray-300"
            >
              <div class="flex items-center gap-4">
                <span class="flex items-center gap-1">
                  <svg
                    class="w-4 h-4"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M5 12h14M5 12a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v4a2 2 0 01-2 2M5 12a2 2 0 00-2 2v4a2 2 0 002 2h14a2 2 0 002-2v-4a2 2 0 00-2-2m-2-4h.01M17 16h.01"
                    />
                  </svg>
                  {{ project._count.deployments }}
                </span>
                <span class="flex items-center gap-1">
                  <svg
                    class="w-4 h-4"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"
                    />
                  </svg>
                  {{ project._count.envVars }}
                </span>
              </div>
              <span class="text-xs">
                {{ formatRelativeDate(project.updatedAt) }}
              </span>
            </div>
          </NuxtLink>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">

export interface ProfileResponse {
  user: {
    id: number;
    name: string;
    email: string;
    createdAt: string;
    updatedAt: string;
  };
  projects: {
    id: number;
    slug: string;
    name: string;
    description?: string;
    status: string;
    domain: string;
    technologies: string[];
    updatedAt: string;
    _count: {
      deployments: number;
      envVars: number;
    };
  }[];
  stats: {
    totalProjects: number;
    totalDeployments: number;
    activeProjects: number;
  };
}
const { data, pending, error } = await useFetch<ProfileResponse>("/api/profil");
import { useAuth } from '~/frontend/auth'

const { user, isAuthenticated, fetchUser, logout } = useAuth()

// Vérifier l'authentification et récupérer l'utilisateur
const { data: authResult } = await useAsyncData('auth-check', async () => {
  const result = await fetchUser()
  if (!result.success || !isAuthenticated.value) {
    await navigateTo('/auth/login')
    return null
  }
  return result
})
const projects = computed(() => data.value?.projects || []);
const stats = computed(
  () =>
    data.value?.stats || {
      totalProjects: 0,
      totalDeployments: 0,
      activeProjects: 0,
    }
);

const filters = [
  { label: "Tous", value: "all" },
  { label: "Actifs", value: "running" },
  { label: "En construction", value: "building" },
  { label: "En attente", value: "pending" },
  { label: "Erreur", value: "error" },
];

const activeFilter = ref("all");

const filteredProjects = computed(() => {
  if (activeFilter.value === "all") {
    return projects.value;
  }

  return projects.value.filter((p) => p.status === activeFilter.value);
});

const userInitials = computed(() => {
  if (!user.value?.name) return "?";

  const names = user.value.name.trim().split(/\s+/);
  return names
    .map((n) => n[0])
    .slice(0, 2)
    .join("")
    .toUpperCase();
});

function getStatusLabel(status: string) {
  const labels: Record<string, string> = {
    running: "Actif",
    building: "En cours",
    pending: "En attente",
    error: "Erreur",
  };
  return labels[status] || status;
}

function formatDate(dateString: string) {
  return new Date(dateString).toLocaleDateString("fr-FR", {
    year: "numeric",
    month: "long",
  });
}

function formatRelativeDate(dateString: string) {
  const date = new Date(dateString);
  const now = new Date();
  const diffDays = Math.floor(
    (now.getTime() - date.getTime()) / (1000 * 60 * 60 * 24)
  );

  if (diffDays === 0) return "Aujourd'hui";
  if (diffDays === 1) return "Hier";
  if (diffDays < 7) return `Il y a ${diffDays}j`;
  if (diffDays < 30) return `Il y a ${Math.floor(diffDays / 7)} sem`;
  return `Il y a ${Math.floor(diffDays / 30)} mois`;
}

useHead({
  title: "Mon Profil - LocalDeploy",
  meta: [
    {
      name: "description",
      content: "Gérez votre profil et vos projets sur LocalDeploy",
    },
  ],
});
</script>
