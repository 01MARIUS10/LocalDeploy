<template>
  <div class="min-h-screen bg-gradient-to-b from-slate-950 via-slate-900 to-slate-950 py-8">
    <div class="max-w-4xl mx-auto px-4">
      <div class="bg-slate-900 rounded-xl border border-slate-700/50 shadow-2xl shadow-black/50 p-8">
        <!-- Header -->
        <div class="flex items-center justify-between mb-8">
          <h1 class="text-3xl font-bold text-white">Modifier le projet</h1>
          <NuxtLink
            to="/projects"
            class="text-emerald-400 hover:text-emerald-300"
          >
            ← Retour
          </NuxtLink>
        </div>

        <!-- Chargement -->
        <div v-if="pending" class="text-center py-20">
          <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-emerald-500 mb-4"></div>
          <p class="text-slate-400">Chargement du projet...</p>
        </div>

        <!-- Erreur -->
        <div v-else-if="error" class="text-center py-20">
          <p class="text-red-400 text-lg">{{ error }}</p>
          <NuxtLink
            to="/projects"
            class="mt-6 inline-block px-6 py-3 bg-emerald-500 hover:bg-emerald-400 text-slate-900 font-bold rounded-lg"
          >
            Retour à la liste
          </NuxtLink>
        </div>

        <!-- Formulaire -->
        <form v-else @submit.prevent="saveProject" class="space-y-8">
          <!-- Nom + Description -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label class="block text-sm font-medium text-slate-300 mb-2"
                >Nom du projet</label
              >
              <input
                v-model="edited.name"
                required
                class="w-full px-4 py-3 bg-slate-800 border border-slate-600 rounded-lg text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-300 mb-2"
                >Description</label
              >
              <input
                v-model="edited.description"
                class="w-full px-4 py-3 bg-slate-800 border border-slate-600 rounded-lg text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
              />
            </div>
          </div>

          <!-- Domaine + Statut -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label class="block text-sm font-medium text-slate-300 mb-2"
                >Domaine local (ex: monprojet.local)</label
              >
              <input
                v-model="edited.domain"
                placeholder="monprojet.local"
                class="w-full px-4 py-3 bg-slate-800 border border-slate-600 rounded-lg text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-300 mb-2"
                >Statut</label
              >
              <select
                v-model="edited.status"
                class="w-full px-4 py-3 bg-slate-800 border border-slate-600 rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
              >
                <option value="staging">Staging</option>
                <option value="production">Production</option>
              </select>
            </div>
          </div>

          <!-- Git -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label class="block text-sm font-medium text-slate-300 mb-2"
                >URL du repository Git</label
              >
              <input
                v-model="edited.repositoryUrl"
                required
                placeholder="https://github.com/user/repo.git"
                class="w-full px-4 py-3 bg-slate-800 border border-slate-600 rounded-lg text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-300 mb-2"
                >Branche</label
              >
              <input
                v-model="edited.branch"
                class="w-full px-4 py-3 bg-slate-800 border border-slate-600 rounded-lg text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
              />
            </div>
          </div>

          <!-- Commandes -->
          <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
              <label class="block text-sm font-medium text-slate-300 mb-2"
                >Commande de build</label
              >
              <input
                v-model="edited.buildCommand"
                placeholder="npm run build"
                class="w-full px-4 py-3 bg-slate-800 border border-slate-600 rounded-lg text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-300 mb-2"
                >Commande de démarrage</label
              >
              <input
                v-model="edited.startCommand"
                placeholder="npm start"
                class="w-full px-4 py-3 bg-slate-800 border border-slate-600 rounded-lg text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-300 mb-2"
                >Dossier de sortie</label
              >
              <input
                v-model="edited.outputDir"
                placeholder="dist"
                class="w-full px-4 py-3 bg-slate-800 border border-slate-600 rounded-lg text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
              />
            </div>
          </div>

          <!-- Technologies -->
          <div>
            <label class="block text-sm font-medium text-slate-300 mb-2">
              Technologies (virgule ou Entrée)
            </label>
            <input
              v-model="techInput"
              @keyup.enter="addTech"
              placeholder="Nuxt, Vue, TailwindCSS..."
              class="w-full px-4 py-3 bg-slate-800 border border-slate-600 rounded-lg text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
            />
            <div class="flex flex-wrap gap-2 mt-3">
              <span
                v-for="(tech, i) in edited.technologies"
                :key="i"
                class="bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 px-4 py-2 rounded-full text-sm flex items-center gap-2"
              >
                {{ tech }}
                <button
                  type="button"
                  @click="edited.technologies.splice(i, 1)"
                  class="text-emerald-400 hover:text-emerald-300"
                >
                  ×
                </button>
              </span>
            </div>
          </div>

          <!-- Boutons -->
          <div class="flex justify-end gap-4 pt-8 border-t border-slate-700">
            <NuxtLink
              :to="`/projects/${edited.slug}`"
              class="px-6 py-3 border border-slate-600 text-slate-300 rounded-lg hover:bg-slate-800"
            >
              Annuler
            </NuxtLink>
            <button
              type="submit"
              :disabled="saving"
              class="px-8 py-3 bg-emerald-500 hover:bg-emerald-400 text-slate-900 rounded-lg font-bold disabled:opacity-70 flex items-center gap-2 shadow-lg shadow-emerald-500/25"
            >
              <span v-if="saving" class="animate-spin">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640" class="w-5 h-5">
                  <path
                    fill="currentColor"
                    d="M272 112C272 85.5 293.5 64 320 64C346.5 64 368 85.5 368 112C368 138.5 346.5 160 320 160C293.5 160 272 138.5 272 112zM272 528C272 501.5 293.5 480 320 480C346.5 480 368 501.5 368 528C368 554.5 346.5 576 320 576C293.5 576 272 554.5 272 528zM112 272C138.5 272 160 293.5 160 320C160 346.5 138.5 368 112 368C85.5 368 64 346.5 64 320C64 293.5 85.5 272 112 272zM480 320C480 293.5 501.5 272 528 272C554.5 272 576 293.5 576 320C576 346.5 554.5 368 528 368C501.5 368 480 346.5 480 320zM139 433.1C157.8 414.3 188.1 414.3 206.9 433.1C225.7 451.9 225.7 482.2 206.9 501C188.1 519.8 157.8 519.8 139 501C120.2 482.2 120.2 451.9 139 433.1zM139 139C157.8 120.2 188.1 120.2 206.9 139C225.7 157.8 225.7 188.1 206.9 206.9C188.1 225.7 157.8 225.7 139 206.9C120.2 188.1 120.2 157.8 139 139zM501 433.1C519.8 451.9 519.8 482.2 501 501C482.2 519.8 451.9 519.8 433.1 501C414.3 482.2 414.3 451.9 433.1 433.1C451.9 414.3 482.2 414.3 501 433.1z"
                  />
                </svg>
              </span>
              {{ saving ? "Enregistrement..." : "Enregistrer" }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useApiClient } from "~/frontend/apiClient";
import { useRoute, useRouter } from "vue-router";
import { ref, onMounted } from "vue";

const route = useRoute();
const router = useRouter();
const api = useApiClient();

const pending = ref(true);
const saving = ref(false);
const error = ref<string | null>(null);

interface ProjectEdit {
  slug: string;
  name: string;
  description: string | null;
  domain: string | null;
  status: "staging" | "production";
  repositoryUrl: string;
  branch: string;
  buildCommand: string;
  startCommand: string;
  outputDir: string;
  technologies: string[];
}

const edited = ref<ProjectEdit>({
  slug: "",
  name: "",
  description: null,
  domain: null,
  status: "staging",
  repositoryUrl: "",
  branch: "main",
  buildCommand: "npm run build",
  startCommand: "npm start",
  outputDir: "dist",
  technologies: [],
});

const techInput = ref("");

onMounted(async () => {
  const slug = route.params.slug as string;
  if (!slug) {
    error.value = "Aucun projet spécifié dans l'URL";
    pending.value = false;
    return;
  }

  try {
    const data = await api.get<any>(`/projects/${slug}`);

    edited.value = {
      slug: data.slug,
      name: data.name,
      description: data.description ?? null,
      domain: data.domain ?? null,
      status: data.status === "production" ? "production" : "staging",
      repositoryUrl: data.repositoryUrl,
      branch: data.branch || "main",
      buildCommand: data.buildCommand || "npm run build",
      startCommand: data.startCommand || "npm start",
      outputDir: data.outputDir || "dist",
      technologies: Array.isArray(data.technologies) ? data.technologies : [],
    };
  } catch (e: any) {
    error.value =
      e.message || "Projet introuvable ou erreur d'authentification";
  } finally {
    pending.value = false;
  }
});

const addTech = () => {
  const techs = techInput.value
    .split(",")
    .map((t) => t.trim())
    .filter((t) => t.length > 0);

  if (techs.length > 0) {
    edited.value.technologies.push(...techs);
    techInput.value = "";
  }
};

async function saveProject() {
  saving.value = true;
  try {
    await api.put(`/projects/${edited.value.slug}`, {
      name: edited.value.name,
      description: edited.value.description,
      domain: edited.value.domain,
      status: edited.value.status,
      repositoryUrl: edited.value.repositoryUrl,
      branch: edited.value.branch,
      buildCommand: edited.value.buildCommand,
      startCommand: edited.value.startCommand,
      outputDir: edited.value.outputDir,
      technologies: edited.value.technologies,
    });

    await router.push(`/projects/${edited.value.slug}`);
  } catch (e: any) {
    console.error(e);
    alert("Erreur : " + (e.message || "Impossible d'enregistrer"));
  } finally {
    saving.value = false;
  }
}
</script>
