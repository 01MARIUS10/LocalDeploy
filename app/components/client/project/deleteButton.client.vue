<script setup lang="ts">
import { useApiClient } from "~/frontend/apiClient";

import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";

const props = defineProps<{ slug: string }>();
const pending = ref(false);
const error = ref<string | null>(null);
const router = useRouter();
const api = useApiClient();

onMounted(() => {
  console.log("DeleteButton mounted with slug:", props.slug);
});
async function handleDelete() {
  if (!confirm("Voulez-vous vraiment supprimer ce projet ?")) return;

  pending.value = true;
  try {
    await api.delete(`/projects/${props.slug}`);
    alert("Projet supprimé !");
    router.push("/projects"); // retour à la liste
  } catch (e: any) {
    error.value = e.message || "Erreur inconnue";
    console.error(e);
  } finally {
    pending.value = false;
  }
}
</script>

<template>
  <ClientOnly>
    <button
      @click="handleDelete"
      :disabled="pending"
      class="bg-red-500 hover:bg-red-600 text-white px-4 py-2 rounded flex gap-2 items-center"
    >
      <svg
        xmlns="http://www.w3.org/2000/svg"
        class="h-5 w-5"
        fill="none"
        viewBox="0 0 24 24"
        stroke="currentColor"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3m-4 0h14"
        />
      </svg>
      <p>Supprimer</p>
    </button>
    <!-- <p v-if="error" class="text-red-600 text-sm mt-1">{{ error }}</p> -->
  </ClientOnly>
</template>
