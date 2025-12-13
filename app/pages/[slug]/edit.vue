<template>
  <div class="min-h-screen bg-gray-50 py-8">
    <div class="max-w-4xl mx-auto px-4">
      <div class="bg-white rounded-xl shadow-lg p-8">
        <div class="flex items-center justify-between mb-8">
          <h1 class="text-3xl font-bold text-gray-800">Modifier le projet</h1>
          <NuxtLink
            to="/projects"
            class="text-indigo-600 hover:text-indigo-800"
          >
            ← Retour
          </NuxtLink>
        </div>

        <div v-if="!project" class="text-center py-10">
          <p>Chargement du projet...</p>
        </div>

        <form v-else @submit.prevent="saveProject" class="space-y-6">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2"
                >Nom du projet</label
              >
              <input
                v-model="edited.name"
                required
                class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2"
                >Description</label
              >
              <input
                v-model="edited.description"
                class="w-full px-4 py-3 border border-gray-300 rounded-lg"
              />
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2"
              >Statut</label
            >
            <select
              v-model="edited.status"
              class="w-full px-4 py-3 border border-gray-300 rounded-lg"
            >
              <option value="staging">Staging</option>
              <option value="production">Production</option>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2"
              >Technologies (virgule ou Entrée)</label
            >
            <input
              v-model="techInput"
              @keyup.enter="addTech"
              placeholder="Vue, Nuxt, Tailwind..."
              class="w-full px-4 py-3 border border-gray-300 rounded-lg"
            />
            <div class="flex flex-wrap gap-2 mt-3">
              <span
                v-for="(tech, i) in edited.technologies"
                :key="i"
                class="bg-indigo-100 text-indigo-800 px-4 py-2 rounded-full text-sm flex items-center gap-2"
              >
                {{ tech }}
                <button
                  type="button"
                  @click="edited.technologies.splice(i, 1)"
                  class="text-indigo-600 hover:text-indigo-900"
                >
                  ×
                </button>
              </span>
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2"
              >Domaine</label
            >
            <input
              v-model="edited.domain"
              class="w-full px-4 py-3 border border-gray-300 rounded-lg"
            />
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2"
                >URL de déploiement</label
              >
              <input
                v-model="edited.deployment.deploymentUrl"
                class="w-full px-4 py-3 border border-gray-300 rounded-lg"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2"
                >Plateforme</label
              >
              <input
                v-model="edited.deployment.platform"
                class="w-full px-4 py-3 border border-gray-300 rounded-lg"
              />
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2"
                >URL Repository</label
              >
              <input
                v-model="edited.repository.url"
                class="w-full px-4 py-3 border border-gray-300 rounded-lg"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2"
                >Branche</label
              >
              <input
                v-model="edited.repository.branch"
                class="w-full px-4 py-3 border border-gray-300 rounded-lg"
              />
            </div>
          </div>

          <div class="flex justify-end gap-4 pt-8 border-t border-gray-200">
            <NuxtLink
              :to="`/projects/${route.params.slug}`"
              class="px-6 py-3 border border-gray-300 rounded-lg hover:bg-gray-50"
            >
              Annuler
            </NuxtLink>
            <button
              type="submit"
              class="px-8 py-3 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 font-medium"
            >
              Enregistrer
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const route = useRoute();
const router = useRouter();

const { data: project, pending } = await useAsyncData("project", () =>
  $fetch(`/api/projects/${route.params.slug}`)
);

// Si le projet n'est pas chargé depuis l'API, on le récupère depuis la page parent (détail)
if (!project.value) {
  const parentData = useNuxtData(`project-${route.params.slug}`);
  if (parentData?.data?.value) {
    project.value = parentData.data.value;
  }
}

const edited = ref<any>({});
watch(
  project,
  (newVal) => {
    if (newVal) {
      edited.value = JSON.parse(JSON.stringify(newVal));
    }
  },
  { immediate: true }
);

const techInput = ref("");

const addTech = () => {
  const techs = techInput.value
    .split(",")
    .map((t) => t.trim())
    .filter(Boolean);
  edited.value.technologies.push(...techs);
  techInput.value = "";
};

async function saveProject() {
  if (!edited.value?.slug) return;

  try {
    await $fetch(`/api/projects/${edited.value.slug}`, {
      method: "POST",
      body: edited.value,
    });
  } catch (e) {}

  await router.push(`/projects/${edited.value.slug}`);
}
</script>
