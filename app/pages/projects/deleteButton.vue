<template>
  <button
    @click="deleteProjet"
    class="bg-red-500 hover:bg-red-600 px-5 py-2.5 rounded-lg flex items-center gap-2 transition font-medium text-white"
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
    Supprimer
  </button>
</template>

<script setup lang="ts">
import { useRouter } from "vue-router";

const props = defineProps<{ slug: string }>();
const router = useRouter();

async function deleteProjet() {
  const ok = confirm("Êtes-vous sûr(e) de vouloir supprimer ce projet ?");
  if (!ok) return;

  try {
    await $fetch(`/api/projects/${props.slug}`, { method: "DELETE" });
    alert("Projet supprimé avec succès !");
    router.push("/projects");
  } catch (err: any) {
    console.error(err);
    alert(err?.message || "Erreur lors de la suppression");
  }
}
</script>
