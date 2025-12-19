<template>
  <div class="bg-white rounded-lg shadow-2xl p-8 max-w-3xl mx-auto">
    <h2 class="text-2xl font-bold text-gray-800 mb-6 text-center">
      Nouveau projet
    </h2>

    <form @submit.prevent="handleSubmit" class="space-y-4">
      <div>
        <label for="name" class="block text-sm font-medium text-gray-700 mb-2">
          Nom du projet <span class="text-red-500">*</span>
        </label>
        <input
          id="name"
          v-model="form.name"
          type="text"
          required
          placeholder="Mon super projet"
          class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all"
        />
      </div>

      <div>
        <label
          for="description"
          class="block text-sm font-medium text-gray-700 mb-2"
        >
          Description
        </label>
        <textarea
          id="description"
          v-model="form.description"
          rows="3"
          placeholder="Une brève description pour ton projet"
          class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all"
        ></textarea>
      </div>

      <div>
        <label
          for="domain"
          class="block text-sm font-medium text-gray-700 mb-2"
        >
          Domaine / URL
        </label>
        <input
          id="domain"
          v-model="form.domain"
          type="text"
          placeholder="monsite.com"
          class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all"
        />
      </div>

      <div>
        <label
          for="technologies"
          class="block text-sm font-medium text-gray-700 mb-2"
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
          class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all"
        />
        <div class="mt-3 flex flex-wrap gap-2">
          <span
            v-for="(tech, index) in form.technologies"
            :key="index"
            class="inline-flex items-center px-3 py-1 bg-purple-100 text-purple-800 rounded-full text-sm"
          >
            {{ tech }}
            <button
              type="button"
              @click="form.technologies.splice(index, 1)"
              class="ml-1 text-purple-600 hover:text-purple-800"
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
        <label class="block text-sm font-medium text-gray-700 mb-2">
          Statut
        </label>
        <div class="flex gap-4">
          <label class="flex items-center gap-2 cursor-pointer">
            <input
              type="radio"
              v-model="form.status"
              value="development"
              class="text-purple-600 focus:ring-purple-500"
            />
            <span class="text-gray-600">En développement</span>
          </label>
          <label class="flex items-center gap-2 cursor-pointer">
            <input
              type="radio"
              v-model="form.status"
              value="production"
              class="text-purple-600 focus:ring-purple-500"
            />
            <span class="text-gray-600">En production</span>
          </label>
        </div>
      </div>

      <button
        type="submit"
        :disabled="isLoading"
        class="w-full py-3 bg-gradient-to-r from-purple-600 to-indigo-600 text-white rounded-lg font-semibold hover:from-purple-700 hover:to-indigo-700 transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed shadow-lg hover:shadow-xl"
      >
        {{ isLoading ? "Création..." : "Créer le projet" }}
      </button>
    </form>

    <div class="mt-6 text-center text-sm text-gray-600">
      <NuxtLink
        to="/projects"
        class="text-purple-600 hover:text-purple-700 font-semibold"
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
    ? "bg-green-50 text-green-800 border border-green-200"
    : "bg-red-50 text-red-800 border border-red-200";
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
