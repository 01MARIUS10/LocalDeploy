<template>
  <div class="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 py-12">
    <div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="bg-white rounded-2xl shadow-xl overflow-hidden">
        <!-- Header gradient -->
        <div
          class="h-32 bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500"
        ></div>

        <div class="px-8 pb-12 -mt-16">
          <!-- Avatar avec initiales -->
          <div class="relative inline-block mb-8">
            <div class="w-32 h-32 rounded-full bg-white p-3 shadow-2xl">
              <div
                class="w-full h-full rounded-full bg-gradient-to-br from-blue-400 to-purple-600 flex items-center justify-center text-white text-5xl font-bold"
              >
                {{ userInitials }}
              </div>
            </div>
            <button
              class="absolute bottom-2 right-2 w-10 h-10 bg-white rounded-full shadow-lg flex items-center justify-center hover:bg-gray-100 transition"
              title="Changer la photo de profil"
            >
              <svg
                class="w-5 h-5 text-gray-600"
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

          <h1 class="text-3xl font-bold text-gray-900 mb-2">
            Modifier mon profil
          </h1>
          <p class="text-gray-600 mb-8">
            Mettez à jour vos informations personnelles
          </p>

          <!-- Chargement -->
          <div v-if="pending" class="text-center py-16">
            <svg
              class="animate-spin h-12 w-12 text-blue-600 mx-auto"
              viewBox="0 0 24 24"
            >
              <circle
                class="opacity-25"
                cx="12"
                cy="12"
                r="10"
                stroke="currentColor"
                stroke-width="4"
              />
              <path
                class="opacity-75"
                fill="currentColor"
                d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
              />
            </svg>
            <p class="mt-4 text-gray-600">Chargement de votre profil...</p>
          </div>

          <!-- Formulaire -->
          <form v-else @submit.prevent="saveProfile" class="space-y-6">
            <div>
              <label
                for="name"
                class="block text-sm font-medium text-gray-700 mb-2"
              >
                Name
              </label>
              <input
                id="name"
                v-model="edited.name"
                type="text"
                required
                class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition"
              />
            </div>

            <div>
              <label
                for="email"
                class="block text-sm font-medium text-gray-700 mb-2"
              >
                Email
              </label>
              <input
                id="email"
                v-model="edited.email"
                type="email"
                required
                class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition"
              />
            </div>

            <transition name="fade">
              <div
                v-if="message"
                :class="[
                  'p-4 rounded-xl text-sm font-medium text-center',
                  message.type === 'success'
                    ? 'bg-green-100 text-green-800'
                    : 'bg-red-100 text-red-800',
                ]"
              >
                {{ message.text }}
              </div>
            </transition>

            <!-- Boutons -->
            <div class="flex justify-end gap-4 pt-6">
              <NuxtLink
                to="/profile"
                class="px-8 py-3 text-gray-700 bg-gray-300 rounded-xl hover:bg-gray-400 transition font-medium"
              >
                Annuler
              </NuxtLink>

              <button
                type="submit"
                :disabled="saving"
                class="px-8 py-3 bg-gradient-to-r from-blue-600 to-purple-600 text-white font-medium rounded-xl hover:from-blue-700 hover:to-purple-700 disabled:opacity-70 transition shadow-lg flex items-center gap-3"
              >
                <svg
                  v-if="saving"
                  class="animate-spin h-5 w-5"
                  viewBox="0 0 24 24"
                >
                  <circle
                    class="opacity-25"
                    cx="12"
                    cy="12"
                    r="10"
                    stroke="currentColor"
                    stroke-width="4"
                  />
                  <path
                    class="opacity-75"
                    fill="currentColor"
                    d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                  />
                </svg>
                <span>{{ saving ? "Enregistrement..." : "Enregistrer" }}</span>
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from "vue";

const router = useRouter();

const { data: profile, pending } = await useAsyncData("profileEdit", () =>
  $fetch("/api/profil", { method: "GET" })
);

const edited = ref({
  name: "",
  email: "",
});

watch(
  profile,
  (newVal) => {
    if (newVal?.user) {
      edited.value = JSON.parse(
        JSON.stringify({
          name: newVal.user.name ?? "",
          email: newVal.user.email ?? "",
        })
      );
    }
  },
  { immediate: true }
);

const userInitials = computed(() => {
  const name = edited.value.name?.trim();
  if (!name) return "??";

  const parts = name.split(/\s+/).filter((p) => p.length > 0);
  return parts
    .map((n) => n[0])
    .slice(0, 2)
    .join("")
    .toUpperCase();
});

const formatDate = (dateIso: string | undefined): string => {
  if (!dateIso) return "Inconnu";
  return new Date(dateIso).toLocaleDateString("fr-FR", {
    year: "numeric",
    month: "long",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
};

const saving = ref(false);
const message = ref<{ text: string; type: "success" | "error" } | null>(null);

const saveProfile = async () => {
  message.value = null;
  saving.value = true;

  try {
    await $fetch("/api/profil/put", {
      method: "PUT",
      body: {
        name: edited.value.name?.trim(),
        email: edited.value.email?.trim().toLowerCase(),
      },
    });

    message.value = {
      text: "Profil mis à jour avec succès ! Redirection...",
      type: "success",
    };

    setTimeout(() => {
      router.push("/profil");
    }, 1500);
  } catch (e: any) {
    message.value = {
      text: e.data?.statusMessage || "Erreur lors de l’enregistrement",
      type: "error",
    };
  } finally {
    saving.value = false;
  }
};
</script>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
