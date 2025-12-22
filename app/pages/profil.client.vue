<template>
  <ClientOnly>
    <div class="min-h-screen bg-gradient-to-b from-slate-950 via-slate-900 to-slate-950 py-12">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <!-- Message d'erreur (token expiré) -->
        <div
          v-if="error"
          class="mb-8 bg-red-500/10 border-2 border-red-500/20 rounded-xl p-6 text-center"
        >
          <svg
            class="w-16 h-16 text-red-400 mx-auto mb-4"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
            />
          </svg>
          <h3 class="text-xl font-bold text-red-400 mb-2">{{ error }}</h3>
          <p class="text-red-300 text-sm">Redirection en cours...</p>
        </div>

        <!-- État de chargement -->
        <div v-else-if="isLoading" class="space-y-8">
          <div
            class="bg-slate-900 rounded-2xl border border-slate-700/50 overflow-hidden animate-pulse"
          >
            <div class="h-32 bg-gradient-to-r from-emerald-600 to-cyan-600"></div>
            <div class="px-8 pb-8">
              <div class="flex items-end -mt-16 mb-6">
                <div class="w-32 h-32 rounded-full bg-slate-700"></div>
                <div class="ml-6 flex-1">
                  <div class="h-8 bg-slate-700 rounded w-1/3 mb-2"></div>
                  <div class="h-4 bg-slate-800 rounded w-1/4"></div>
                </div>
              </div>
              <div class="grid grid-cols-3 gap-4">
                <div class="h-24 bg-slate-800 rounded-xl"></div>
                <div class="h-24 bg-slate-800 rounded-xl"></div>
                <div class="h-24 bg-slate-800 rounded-xl"></div>
              </div>
            </div>
          </div>
          <div class="bg-slate-900 rounded-2xl border border-slate-700/50 p-8">
            <div class="h-8 bg-slate-700 rounded w-1/4 mb-6"></div>
            <div class="grid grid-cols-3 gap-6">
              <div class="h-64 bg-slate-800 rounded-xl"></div>
              <div class="h-64 bg-slate-800 rounded-xl"></div>
              <div class="h-64 bg-slate-800 rounded-xl"></div>
            </div>
          </div>
        </div>

        <!-- Contenu du profil -->
        <template v-else>
          <!-- Header du profil -->
          <div class="bg-slate-900 rounded-2xl border border-slate-700/50 overflow-hidden mb-8">
            <div
              class="h-32 bg-gradient-to-r from-emerald-600 via-cyan-600 to-emerald-600"
            ></div>
            <div class="px-8 pb-8">
              <div
                class="flex flex-col sm:flex-row items-start sm:items-end -mt-16 mb-6"
              >
                <!-- Avatar -->
                <div class="relative">
                  <div class="w-32 h-32 rounded-full bg-slate-900 p-2 shadow-xl border border-slate-700">
                    <div
                      class="w-full h-full rounded-full bg-gradient-to-br from-emerald-400 to-cyan-500 flex items-center justify-center text-slate-900 text-4xl font-bold"
                    >
                      {{ userInitials }}
                    </div>
                  </div>
                  <button
                    class="absolute bottom-2 right-2 w-8 h-8 bg-slate-800 rounded-full shadow-lg flex items-center justify-center hover:bg-slate-700 transition border border-slate-600"
                  >
                    <svg
                      class="w-4 h-4 text-slate-300"
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
                      <h1 class="text-3xl font-bold text-white">
                        {{ user?.name || "Chargement..." }}
                      </h1>
                      <p class="text-slate-400 mt-1 flex items-center">
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
                        {{ user?.email || "-" }}
                      </p>
                      <p class="text-sm text-slate-500 mt-2">
                        Membre depuis
                        {{
                          user?.createdAt ? formatDate(user?.createdAt) : "-"
                        }}
                      </p>
                    </div>
                    <NuxtLink
                      to="/EditProfil"
                      class="mt-4 sm:mt-0 px-6 py-2 bg-emerald-500 hover:bg-emerald-400 text-slate-900 font-bold rounded-lg transition shadow-lg shadow-emerald-500/25"
                    >
                      Modifier le profil
                    </NuxtLink>
                  </div>
                </div>
              </div>

              <!-- Statistiques -->
              <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mt-6">
                <div
                  class="bg-emerald-500/10 rounded-xl p-6 border border-emerald-500/20"
                >
                  <div class="flex items-center justify-between">
                    <div>
                      <p class="text-sm font-medium text-emerald-400">Projets</p>
                      <p class="text-3xl font-bold text-white mt-1">
                        {{ stats.totalProjects }}
                      </p>
                    </div>
                    <div
                      class="w-12 h-12 bg-emerald-500 rounded-lg flex items-center justify-center"
                    >
                      <svg
                        class="w-6 h-6 text-slate-900"
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
                  class="bg-cyan-500/10 rounded-xl p-6 border border-cyan-500/20"
                >
                  <div class="flex items-center justify-between">
                    <div>
                      <p class="text-sm font-medium text-cyan-400">
                        Déploiements
                      </p>
                      <p class="text-3xl font-bold text-white mt-1">
                        {{ stats.totalDeployments }}
                      </p>
                    </div>
                    <div
                      class="w-12 h-12 bg-cyan-500 rounded-lg flex items-center justify-center"
                    >
                      <svg
                        class="w-6 h-6 text-slate-900"
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
                  class="bg-yellow-500/10 rounded-xl p-6 border border-yellow-500/20"
                >
                  <div class="flex items-center justify-between">
                    <div>
                      <p class="text-sm font-medium text-yellow-400">Actifs</p>
                      <p class="text-3xl font-bold text-white mt-1">
                        {{ stats.activeProjects }}
                      </p>
                    </div>
                    <div
                      class="w-12 h-12 bg-yellow-500 rounded-lg flex items-center justify-center"
                    >
                      <svg
                        class="w-6 h-6 text-slate-900"
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
          <div class="bg-slate-900 rounded-2xl border border-slate-700/50 p-8">
            <div class="flex items-center justify-between mb-6">
              <h2 class="text-2xl font-bold text-white">Mes Projets</h2>
              <NuxtLink
                to="/projects/new"
                class="px-4 py-2 bg-emerald-500 hover:bg-emerald-400 text-slate-900 font-bold rounded-lg transition shadow-lg shadow-emerald-500/25 flex items-center gap-2"
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
                    ? 'bg-emerald-500 text-slate-900 shadow-lg shadow-emerald-500/25'
                    : 'bg-slate-800 text-slate-300 hover:bg-slate-700 border border-slate-700',
                ]"
              >
                {{ filter.label }}
              </button>
            </div>

            <!-- Liste des projets -->
            <div v-if="filteredProjects.length === 0" class="text-center py-12">
              <div class="text-slate-500 mb-4">
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
              <p class="text-slate-300 text-lg mb-2">
                Aucun projet pour le moment
              </p>
              <p class="text-slate-500 text-sm">
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
                class="group bg-slate-800 rounded-xl p-6 border border-slate-700 hover:border-emerald-500/50 hover:shadow-lg hover:shadow-emerald-500/10 transition-all duration-300"
              >
                <!-- Status badge -->
                <div class="flex items-center justify-between mb-4">
                  <span
                    :class="[
                      'px-3 py-1 rounded-full text-xs font-semibold',
                      project.status === 'active'
                        ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20'
                        : project.status === 'building'
                        ? 'bg-yellow-500/10 text-yellow-400 border border-yellow-500/20'
                        : 'bg-slate-700 text-slate-400 border border-slate-600',
                    ]"
                  >
                    {{ getStatusLabel(project.status) }}
                  </span>
                  <svg
                    class="w-5 h-5 text-slate-500 group-hover:text-emerald-400 transition"
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
                  class="text-xl font-bold text-white mb-2 group-hover:text-emerald-400 transition"
                >
                  {{ project.name }}
                </h3>
                <p class="text-slate-400 text-sm mb-4 line-clamp-2">
                  {{ project.description }}
                </p>

                <!-- Domaine -->
                <div class="flex items-center text-sm text-slate-500 mb-4">
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
                    class="px-2 py-1 bg-emerald-500/10 text-emerald-400 text-xs rounded-md border border-emerald-500/20"
                  >
                    {{ tech }}
                  </span>
                  <span
                    v-if="project.technologies.length > 3"
                    class="px-2 py-1 bg-slate-700 text-slate-400 text-xs rounded-md"
                  >
                    +{{ project.technologies.length - 3 }}
                  </span>
                </div>

                <!-- Stats -->
                <div
                  class="flex items-center justify-between text-sm text-slate-500 pt-4 border-t border-slate-700"
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
        </template>
        <!-- Fin du contenu du profil -->
      </div>
    </div>

    <!-- Fallback pour le SSR (ne devrait jamais être affiché) -->
    <template #fallback>
      <div
        class="min-h-screen bg-gradient-to-b from-slate-950 via-slate-900 to-slate-950 py-12 flex items-center justify-center"
      >
        <div class="text-center">
          <div
            class="animate-spin rounded-full h-16 w-16 border-b-2 border-emerald-500 mx-auto mb-4"
          ></div>
          <p class="text-slate-400">Chargement de votre profil...</p>
        </div>
      </div>
    </template>
  </ClientOnly>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from "vue";
import { useAuth } from "~/frontend/auth";
import { useApiClient, type ApiError } from "~/frontend/apiClient";

// Protéger la page avec le middleware d'authentification
definePageMeta({
  middleware: "auth",
  ssr: false, // Désactiver le SSR pour cette page car elle nécessite l'authentification côté client
});

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

const { isAuthenticated, logout } = useAuth();
const apiClient = useApiClient();

// États
const profileData = ref<ProfileResponse | null>(null);
const isLoading = ref(true);
const error = ref<string | null>(null);

// Fetcher les données du profil côté client
const fetchProfile = async () => {
  if (!isAuthenticated.value) {
    await navigateTo("/auth/login");
    return;
  }

  isLoading.value = true;
  error.value = null;

  try {
    const response = await apiClient.get<ProfileResponse>("/profil");
    profileData.value = response;
    console.log(profileData.value, "Données du profil chargées");
  } catch (err: any) {
    console.error("Erreur lors de la récupération du profil:", err);

    const apiError = err as ApiError;

    // Si erreur 401 (token invalide), le client API gère déjà la déconnexion
    if (apiError.statusCode === 401) {
      error.value = "Session expirée. Redirection en cours...";
    } else {
      error.value = apiError.message || "Erreur lors du chargement du profil";
    }
  } finally {
    isLoading.value = false;
  }
};

// Charger les données au montage du composant (côté client)
onMounted(() => {
  fetchProfile();
});

// Computed properties
const user = computed(() => profileData.value?.user || null);
const projects = computed(() => profileData.value?.projects || []);
const stats = computed(
  () =>
    profileData.value?.stats || {
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
