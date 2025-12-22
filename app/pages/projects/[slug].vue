<template>
  <div class="min-h-screen bg-gradient-to-b from-slate-950 via-slate-900 to-slate-950">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div v-if="pending" class="text-center py-12">
        <div
          class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-emerald-500"
        ></div>
        <p class="mt-4 text-slate-400">Chargement du projet...</p>
      </div>

      <div
        v-else-if="error"
        class="bg-red-500/10 border border-red-500/20 rounded-xl p-6"
      >
        <h2 class="text-xl font-bold text-red-400 mb-2">Erreur</h2>
        <p class="text-red-300">{{ error }}</p>
        <NuxtLink
          to="/projects"
          class="mt-4 inline-block text-emerald-400 hover:text-emerald-300"
        >
          ← Retour aux projets
        </NuxtLink>
      </div>

      <ServerProjectDetail v-else-if="project" :project="project" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { useRoute } from "vue-router";
import { useApiClient } from "~/frontend/apiClient";

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

const route = useRoute();
const slug = route.params.slug as string;

const api = useApiClient();
const project = ref<Project | null>(null);
const pending = ref(true);
const error = ref<string | null>(null);

onMounted(async () => {
  try {
    const data = await api.get<Project>(`/projects/${slug}`);

    project.value = data;
  } catch (e: any) {
    error.value = e.message || "Une erreur est survenue";
  } finally {
    pending.value = false;
  }
});

// SEO
useHead({
  title: project.value ? `${project.value.name} - Projets` : "Projet",
  meta: [
    {
      name: "description",
      content: project.value?.description || "Détails du projet",
    },
  ],
});
</script>
