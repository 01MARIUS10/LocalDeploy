<template>
  <div class="min-h-screen bg-gradient-to-b from-slate-950 via-slate-900 to-slate-950 py-8">
    <div class="max-w-4xl mx-auto px-4">
      <div class="bg-slate-900 rounded-xl border border-slate-700/50 shadow-2xl shadow-black/50 p-8">
        <!-- Header -->
        <div class="flex items-center justify-between mb-8">
          <h1 class="text-3xl font-bold text-white">Nouveau projet</h1>
          <NuxtLink
            to="/projects"
            class="text-emerald-400 hover:text-emerald-300"
          >
            ← Retour
          </NuxtLink>
        </div>

        <!-- Formulaire -->
        <form @submit.prevent="saveProject" class="space-y-8">
          <!-- Nom + Description -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label class="block text-sm font-medium text-slate-300 mb-2">
                Nom du projet <span class="text-red-400">*</span>
              </label>
              <input
                v-model="form.name"
                required
                placeholder="Mon super projet"
                class="w-full px-4 py-3 bg-slate-800 border border-slate-600 rounded-lg text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-300 mb-2">
                Description
              </label>
              <input
                v-model="form.description"
                placeholder="Une brève description..."
                class="w-full px-4 py-3 bg-slate-800 border border-slate-600 rounded-lg text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
              />
            </div>
          </div>

          <!-- Domaine local + Statut -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label class="block text-sm font-medium text-slate-300 mb-2">
                Domaine local (ex: monprojet.local)
              </label>
              <input
                v-model="form.domain"
                placeholder="monprojet.local"
                class="w-full px-4 py-3 bg-slate-800 border border-slate-600 rounded-lg text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-300 mb-2">
                Statut
              </label>
              <select
                v-model="form.status"
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
              <label class="block text-sm font-medium text-slate-300 mb-2">
                URL du repository Git <span class="text-red-400">*</span>
              </label>
              <input
                v-model="form.repositoryUrl"
                required
                placeholder="https://github.com/user/repo.git"
                class="w-full px-4 py-3 bg-slate-800 border border-slate-600 rounded-lg text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-300 mb-2">
                Branche
              </label>
              <input
                v-model="form.branch"
                placeholder="main"
                class="w-full px-4 py-3 bg-slate-800 border border-slate-600 rounded-lg text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
              />
            </div>
          </div>

          <!-- Commandes de build/start/output -->
          <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
              <label class="block text-sm font-medium text-slate-300 mb-2">
                Commande de build
              </label>
              <input
                v-model="form.buildCommand"
                placeholder="npm run build"
                class="w-full px-4 py-3 bg-slate-800 border border-slate-600 rounded-lg text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-300 mb-2">
                Commande de démarrage
              </label>
              <input
                v-model="form.startCommand"
                placeholder="npm start"
                class="w-full px-4 py-3 bg-slate-800 border border-slate-600 rounded-lg text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-300 mb-2">
                Dossier de sortie
              </label>
              <input
                v-model="form.outputDir"
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
                v-for="(tech, i) in form.technologies"
                :key="i"
                class="bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 px-4 py-2 rounded-full text-sm flex items-center gap-2"
              >
                {{ tech }}
                <button
                  type="button"
                  @click="form.technologies.splice(i, 1)"
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
              to="/projects"
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
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  viewBox="0 0 640 640"
                  class="h-5 w-5"
                >
                  <path
                    fill="currentColor"
                    d="M272 112C272 85.5 293.5 64 320 64C346.5 64 368 85.5 368 112C368 138.5 346.5 160 320 160C293.5 160 272 138.5 272 112zM272 528C272 501.5 293.5 480 320 480C346.5 480 368 501.5 368 528C368 554.5 346.5 576 320 576C293.5 576 272 554.5 272 528zM112 272C138.5 272 160 293.5 160 320C160 346.5 138.5 368 112 368C85.5 368 64 346.5 64 320C64 293.5 85.5 272 112 272zM480 320C480 293.5 501.5 272 528 272C554.5 272 576 293.5 576 320C576 346.5 554.5 368 528 368C501.5 368 480 346.5 480 320zM139 433.1C157.8 414.3 188.1 414.3 206.9 433.1C225.7 451.9 225.7 482.2 206.9 501C188.1 519.8 157.8 519.8 139 501C120.2 482.2 120.2 451.9 139 433.1zM139 139C157.8 120.2 188.1 120.2 206.9 139C225.7 157.8 225.7 188.1 206.9 206.9C188.1 225.7 157.8 225.7 139 206.9C120.2 188.1 120.2 157.8 139 139zM501 433.1C519.8 451.9 519.8 482.2 501 501C482.2 519.8 451.9 519.8 433.1 501C414.3 482.2 414.3 451.9 433.1 433.1C451.9 414.3 482.2 414.3 501 433.1z"
                  />
                </svg>
              </span>
              {{ saving ? "Création..." : "Créer le projet" }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useApiClient } from "~/frontend/apiClient";
import { useRouter } from "vue-router";
import { ref } from "vue";

const router = useRouter();
const api = useApiClient();

const saving = ref(false);

const form = ref({
  name: "",
  description: "" as string | null,
  domain: "" as string | null,
  status: "" as "staging" | "production",
  repositoryUrl: "",
  branch: "",
  buildCommand: "",
  startCommand: "",
  outputDir: "",
  technologies: [] as string[],
});

const techInput = ref("");

const addTech = () => {
  const techs = techInput.value
    .split(",")
    .map((t) => t.trim())
    .filter((t) => t.length > 0);

  if (techs.length > 0) {
    form.value.technologies.push(...techs);
    techInput.value = "";
  }
};

async function saveProject() {
  if (!form.value.name.trim() || !form.value.repositoryUrl.trim()) {
    alert("Le nom et l'URL du repository sont obligatoires.");
    return;
  }

  saving.value = true;

  try {
    await api.post("/projects", {
      name: form.value.name.trim(),
      description: form.value.description?.trim() || null,
      domain: form.value.domain?.trim() || null,
      status: form.value.status,
      repositoryUrl: form.value.repositoryUrl.trim(),
      branch: form.value.branch.trim() || "main",
      buildCommand: form.value.buildCommand.trim(),
      startCommand: form.value.startCommand.trim(),
      outputDir: form.value.outputDir.trim(),
      technologies: form.value.technologies,
    });

    await router.push("/projects");
  } catch (e: any) {
    console.error("Erreur création projet :", e);
    alert("Erreur : " + (e.message || "Impossible de créer le projet"));
  } finally {
    saving.value = false;
  }
}
</script>
