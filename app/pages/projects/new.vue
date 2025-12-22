<template>
  <div class="min-h-screen bg-gradient-to-b from-slate-950 via-slate-900 to-slate-950 py-8">
    <div class="bg-slate-900 rounded-xl border border-slate-700/50 shadow-2xl shadow-black/50 p-8 max-w-3xl mx-auto">
      <h2 class="text-2xl font-bold text-white mb-6 text-center">
        Nouveau projet
      </h2>

      <form @submit.prevent="handleSubmit" class="space-y-4">
        <div>
          <label for="name" class="block text-sm font-medium text-slate-300 mb-2">
            Nom du projet <span class="text-red-400">*</span>
          </label>
          <input
            id="name"
            v-model="form.name"
            type="text"
            required
            placeholder="Mon super projet"
            class="w-full px-4 py-3 bg-slate-800 border border-slate-600 rounded-lg text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent transition-all"
          />
        </div>

        <div>
          <label
            for="description"
            class="block text-sm font-medium text-slate-300 mb-2"
          >
            Description
          </label>
          <textarea
            id="description"
            v-model="form.description"
            rows="3"
            placeholder="Une brève description pour ton projet"
            class="w-full px-4 py-3 bg-slate-800 border border-slate-600 rounded-lg text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent transition-all"
          ></textarea>
        </div>

        <div>
          <label
            for="domain"
            class="block text-sm font-medium text-slate-300 mb-2"
          >
            Domaine / URL
          </label>
          <input
            id="domain"
            v-model="form.domain"
            type="text"
            placeholder="monsite.com"
            class="w-full px-4 py-3 bg-slate-800 border border-slate-600 rounded-lg text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent transition-all"
          />
        </div>

        <div>
          <label
            for="technologies"
            class="block text-sm font-medium text-slate-300 mb-2"
          >
            Technologies
          </label>
          <input
            id="technologies"
            v-model="techInput"
            @keyup.enter="addTech"
            @blur="addTech"
            type="text"
            placeholder="Nuxt, Tailwind, Supabase..."
            class="w-full px-4 py-3 bg-slate-800 border border-slate-600 rounded-lg text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent transition-all"
          />
          <div class="mt-3 flex flex-wrap gap-2">
            <span
              v-for="(tech, index) in form.technologies"
              :key="index"
              class="inline-flex items-center px-3 py-1 bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 rounded-full text-sm"
            >
              {{ tech }}
              <button
                type="button"
                @click="form.technologies.splice(index, 1)"
                class="ml-1 text-emerald-400 hover:text-emerald-300"
              >
                <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                  <path
                    d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z"
                    clip-rule="evenodd"
                  ></path>
                </svg>
              </button>
            </span>
          </div>
        </div>

        <div>
          <label class="block text-sm font-medium text-slate-300 mb-2">
            Statut
          </label>
          <div class="flex gap-4">
            <label class="flex items-center gap-2 cursor-pointer">
              <input
                type="radio"
                v-model="form.status"
                value="development"
                class="text-emerald-500 bg-slate-700 border-slate-600 focus:ring-emerald-500"
              />
              <span class="text-slate-400">En développement</span>
            </label>
            <label class="flex items-center gap-2 cursor-pointer">
              <input
                type="radio"
                v-model="form.status"
                value="production"
                class="text-emerald-500 bg-slate-700 border-slate-600 focus:ring-emerald-500"
              />
              <span class="text-slate-400">En production</span>
            </label>
          </div>
        </div>

        <button
          type="submit"
          :disabled="isLoading"
          class="w-full py-3 bg-emerald-500 hover:bg-emerald-400 text-slate-900 rounded-lg font-bold transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed shadow-lg shadow-emerald-500/25 hover:shadow-emerald-400/40"
        >
          {{ isLoading ? "Création..." : "Créer le projet" }}
        </button>
      </form>

      <div class="mt-6 text-center text-sm text-slate-400">
        <NuxtLink
          to="/projects"
          class="text-emerald-400 hover:text-emerald-300 font-semibold"
        >
          ← Retour à la liste des projets
        </NuxtLink>
      </div>

      <div
        v-if="message"
        class="mt-4 p-3 rounded-lg text-sm text-center"
        :class="messageClass"
      >
        {{ message }}
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: "clean",
});

const form = reactive({
  name: "",
  description: "",
  domain: "", // ← tu l'utilises comme repositoryUrl pour l'instant
  technologies: [] as string[],
  status: "development" as "development" | "production",
});

const techInput = ref("");
const isLoading = ref(false);
const message = ref("");
const messageType = ref<"success" | "error" | "">("");

const messageClass = computed(() => {
  return messageType.value === "success"
    ? "bg-emerald-500/10 text-emerald-400 border border-emerald-500/20"
    : "bg-red-500/10 text-red-400 border border-red-500/20";
});

function addTech() {
  if (!techInput.value.trim()) return;

  const techs = techInput.value
    .split(",")
    .map((t) => t.trim())
    .filter(Boolean)
    .filter((t) => !form.technologies.includes(t)); // évite doublons

  form.technologies.push(...techs);
  techInput.value = "";
}

// ENVOI MINIMALISTE ET PARFAITEMENT COMPATIBLE AVEC TON ENDPOINT ACTUEL
const handleSubmit = async () => {
  isLoading.value = true;
  message.value = "";
  messageType.value = "";

  const api = useApiClient();

  try {
    await api.post("/projects", {
      name: form.name.trim(),
      description: form.description.trim() || null,
      domain: form.domain.trim(),
      technologies: form.technologies,
      status: form.status,
    });

    message.value = "Projet créé avec succès !";
    messageType.value = "success";

    setTimeout(() => {
      navigateTo("/projects");
    }, 1500);
  } catch (error: any) {
    console.error("Erreur création projet :", error);

    // Messages d'erreur plus clairs selon la réponse du backend
    if (error?.status === 401) {
      message.value = "Tu dois être connecté pour créer un projet";
    } else if (error?.data?.statusMessage) {
      message.value = error.data.statusMessage;
    } else {
      message.value =
        "Erreur lors de la création. Vérifie tes données et réessaie.";
    }
    messageType.value = "error";
  } finally {
    isLoading.value = false;
  }
};

useHead({
  title: "Nouveau projet",
});
</script>
