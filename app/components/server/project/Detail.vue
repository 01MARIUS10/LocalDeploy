<template>
  <div class="space-y-8">
    <!-- Header du projet -->
    <div
      class="bg-gradient-to-br from-indigo-500 via-purple-600 to-purple-700 rounded-xl p-8 text-white"
    >
      <div class="flex items-start justify-between">
        <div>
          <NuxtLink
            to="/projects"
            class="text-indigo-200 hover:text-white mb-2 inline-block"
          >
            ← Retour aux projets
          </NuxtLink>

          <h1 class="text-4xl font-bold mb-2">{{ props.project.name }}</h1>
          <p class="text-indigo-100 text-lg">{{ props.project.description }}</p>
        </div>
        <span
          :class="[
            'px-4 py-2 rounded-full text-sm font-semibold',
            props.project.status === 'production'
              ? 'bg-green-500'
              : 'bg-yellow-500',
          ]"
        >
          {{
            props.project.status === "production"
              ? "🟢 Production"
              : "🟡 Staging"
          }}
        </span>
      </div>

      <div class="mt-6 flex flex-wrap gap-2">
        <span
          v-for="tech in props.project.technologies"
          :key="tech"
          class="px-3 py-1 bg-white/20 rounded-full text-sm backdrop-blur-sm"
        >
          {{ tech }}
        </span>
      </div>
      <div class="flex gap-5 justify-end">
        <button
          @click="handleDeploy"
          :disabled="isDeploying"
          :class="[
            'backdrop-blur-sm px-5 py-2.5 rounded-lg flex items-center gap-2 transition font-medium',
            isDeploying
              ? 'bg-gray-400 cursor-not-allowed'
              : 'bg-blue-700 hover:bg-blue-600',
          ]"
        >
          <svg
            v-if="!isDeploying"
            class="h-5 w-5"
            viewBox="0 0 24 24"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            stroke="currentColor"
          >
            <path
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              d="M23,1 C23,1 16.471872,0.541707069 14,3 C13.9767216,3.03685748 10,7 10,7 L5,8 L2,10 L10,14 L14,22 L16,19 L17,14 C17,14 20.9631426,10.0232786 21,10 C23.4582929,7.5281282 23,1 23,1 Z M17,8 C16.4475,8 16,7.5525 16,7 C16,6.4475 16.4475,6 17,6 C17.5525,6 18,6.4475 18,7 C18,7.5525 17.5525,8 17,8 Z M7,17 C6,16 4,16 3,17 C2,18 2,22 2,22 C2,22 6,22 7,21 C8,20 8,18 7,17 Z"
            />
          </svg>
          <svg
            v-else
            class="animate-spin h-5 w-5"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
          >
            <circle
              class="opacity-25"
              cx="12"
              cy="12"
              r="10"
              stroke="currentColor"
              stroke-width="4"
            ></circle>
            <path
              class="opacity-75"
              fill="currentColor"
              d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
            ></path>
          </svg>
          {{ isDeploying ? "Déploiement..." : "Déployer" }}
        </button>
        <NuxtLink
          :to="`/${props.project.slug}/edit`"
          class="bg-blue-500 hover:bg-blue-600 backdrop-blur-sm px-5 py-2.5 rounded-lg flex items-center gap-2 transition font-medium"
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
              d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"
            />
          </svg>
          Modifier
        </NuxtLink>
        <DeleteButton :slug="props.project.slug" />
      </div>
    </div>

    <!-- Logs de déploiement -->
    <div
      v-if="deploymentLogs.length > 0"
      class="bg-gray-900 rounded-xl shadow-md p-6 border border-gray-700"
    >
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-xl font-bold text-white flex items-center gap-2">
          📋 Logs de Déploiement
        </h2>
        <button
          @click="clearLogs"
          class="text-gray-400 hover:text-white text-sm"
        >
          Effacer
        </button>
      </div>
      <div
        ref="logsContainer"
        class="bg-black rounded-lg p-4 h-96 overflow-y-auto font-mono text-sm space-y-1"
      >
        <div
          v-for="(log, index) in deploymentLogs"
          :key="index"
          :class="getLogClass(log)"
          class="whitespace-pre-wrap break-words"
        >
          {{ log }}
        </div>
        <div v-if="isDeploying" class="text-yellow-400 animate-pulse">
          ⏳ Déploiement en cours...
        </div>
      </div>
    </div>

    <!-- Domaine et URL -->
    <div class="bg-white rounded-xl shadow-md p-6 border border-gray-200">
      <h2 class="text-2xl font-bold text-gray-800 mb-4 flex items-center gap-2">
        🌐 Domaine & URL
      </h2>
      <div class="space-y-3">
        <div class="flex items-center justify-between">
          <span class="text-gray-600 font-medium">Domaine:</span>
          <a
            :href="`https://${props.project.domain}`"
            target="_blank"
            class="text-indigo-600 hover:text-indigo-800 font-mono"
          >
            {{ props.project.domain }} ↗
          </a>
        </div>
        <div class="flex items-center justify-between">
          <span class="text-gray-600 font-medium">URL de déploiement:</span>
          <a
            :href="props.project.deployment.deploymentUrl"
            target="_blank"
            class="text-indigo-600 hover:text-indigo-800 font-mono text-sm"
          >
            {{ props.project.deployment.deploymentUrl }} ↗
          </a>
        </div>
      </div>
    </div>

    <!-- Repository -->
    <div class="bg-white rounded-xl shadow-md p-6 border border-gray-200">
      <h2 class="text-2xl font-bold text-gray-800 mb-4 flex items-center gap-2">
        📦 Repository
      </h2>
      <div class="space-y-3">
        <div class="flex items-center justify-between">
          <span class="text-gray-600 font-medium">URL:</span>
          <a
            :href="props.project.repository.url"
            target="_blank"
            class="text-indigo-600 hover:text-indigo-800 font-mono text-sm"
          >
            {{ props.project.repository.url }} ↗
          </a>
        </div>
        <div class="flex items-center justify-between">
          <span class="text-gray-600 font-medium">Branche:</span>
          <code class="bg-gray-100 px-3 py-1 rounded text-sm">{{
            props.project.repository.branch
          }}</code>
        </div>
        <div class="flex items-center justify-between">
          <span class="text-gray-600 font-medium">Dernier commit:</span>
          <span class="text-gray-700 text-sm">{{
            formatDate(props.project.repository.lastCommit)
          }}</span>
        </div>
      </div>
    </div>

    <!-- Déploiement -->
    <div class="bg-white rounded-xl shadow-md p-6 border border-gray-200">
      <h2 class="text-2xl font-bold text-gray-800 mb-4 flex items-center gap-2">
        🚀 Déploiement
      </h2>
      <div class="space-y-4">
        <div class="flex items-center justify-between">
          <span class="text-gray-600 font-medium">Plateforme:</span>
          <span
            class="bg-indigo-100 text-indigo-800 px-3 py-1 rounded font-semibold"
          >
            {{ props.project.deployment.platform }}
          </span>
        </div>
        <div class="flex items-center justify-between">
          <span class="text-gray-600 font-medium">Commande de build:</span>
          <code
            class="bg-gray-900 text-green-400 px-3 py-1 rounded text-sm font-mono"
          >
            {{ props.project.deployment.buildCommand }}
          </code>
        </div>
        <div class="flex items-center justify-between">
          <span class="text-gray-600 font-medium">Dossier de sortie:</span>
          <code class="bg-gray-100 px-3 py-1 rounded text-sm">{{
            props.project.deployment.outputDirectory
          }}</code>
        </div>
        <div class="flex items-center justify-between">
          <span class="text-gray-600 font-medium">Dernier déploiement:</span>
          <span class="text-gray-700 text-sm">{{
            formatDate(props.project.deployment.lastDeployment)
          }}</span>
        </div>

        <!-- Variables d'environnement -->
        <div class="mt-4 pt-4 border-t border-gray-200">
          <h3 class="text-lg font-semibold text-gray-800 mb-3">
            Variables d'environnement
          </h3>
          <div class="space-y-2">
            <div
              v-for="env in props.project.deployment.environmentVariables"
              :key="env.key"
              class="flex items-center justify-between bg-gray-50 p-3 rounded"
            >
              <code class="text-sm font-mono text-gray-700">{{ env.key }}</code>
              <span
                :class="[
                  'text-sm font-mono',
                  env.secret ? 'text-gray-400' : 'text-gray-700',
                ]"
              >
                {{ env.value }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Base de données -->
    <div class="bg-white rounded-xl shadow-md p-6 border border-gray-200">
      <h2 class="text-2xl font-bold text-gray-800 mb-4 flex items-center gap-2">
        🗄️ Base de données
      </h2>
      <div class="space-y-3">
        <div class="flex items-center justify-between">
          <span class="text-gray-600 font-medium">Type:</span>
          <span
            class="bg-blue-100 text-blue-800 px-3 py-1 rounded font-semibold"
          >
            {{ props.project.database.type }}
          </span>
        </div>
        <div
          v-if="props.project.database.host !== '-'"
          class="flex items-center justify-between"
        >
          <span class="text-gray-600 font-medium">Host:</span>
          <code class="bg-gray-100 px-3 py-1 rounded text-sm">{{
            props.project.database.host
          }}</code>
        </div>
        <div
          v-if="props.project.database.port"
          class="flex items-center justify-between"
        >
          <span class="text-gray-600 font-medium">Port:</span>
          <code class="bg-gray-100 px-3 py-1 rounded text-sm">{{
            props.project.database.port
          }}</code>
        </div>
        <div class="flex items-center justify-between">
          <span class="text-gray-600 font-medium">Database:</span>
          <code class="bg-gray-100 px-3 py-1 rounded text-sm">{{
            props.project.database.name
          }}</code>
        </div>
        <div
          v-if="props.project.database.user !== '-'"
          class="flex items-center justify-between"
        >
          <span class="text-gray-600 font-medium">User:</span>
          <code class="bg-gray-100 px-3 py-1 rounded text-sm">{{
            props.project.database.user
          }}</code>
        </div>
        <div class="flex items-center justify-between">
          <span class="text-gray-600 font-medium">SSL:</span>
          <span
            :class="
              props.project.database.ssl ? 'text-green-600' : 'text-red-600'
            "
          >
            {{ props.project.database.ssl ? "✓ Activé" : "✗ Désactivé" }}
          </span>
        </div>
        <div class="flex items-center justify-between">
          <span class="text-gray-600 font-medium">Backup:</span>
          <span class="text-gray-700 text-sm">{{
            props.project.database.backupSchedule
          }}</span>
        </div>
      </div>
    </div>

    <!-- Dates -->
    <div class="bg-gray-50 rounded-xl p-6 border border-gray-200">
      <div class="flex justify-between text-sm text-gray-600">
        <div>
          <span class="font-medium">Créé le:</span>
          <span class="ml-2">{{ formatDate(props.project.createdAt) }}</span>
        </div>
        <div>
          <span class="font-medium">Mis à jour le:</span>
          <span class="ml-2">{{ formatDate(props.project.updatedAt) }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import DeleteButton from "~/components/client/project/deleteButton.client.vue";
import { useDeploymentStream } from "~/frontend/deploymentStream";

const props = defineProps<{
  project: any;
}>();

// Utiliser le composable de déploiement
const { isDeploying, logs: deploymentLogs, startDeployment, clearLogs } = useDeploymentStream();

// Ref pour le scroll
const logsContainer = ref<HTMLElement | null>(null);

// Fonctions utilitaires
function formatDate(dateString: string) {
  return new Date(dateString).toLocaleString("fr-FR", {
    year: "numeric",
    month: "long",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

function getLogClass(log: string) {
  if (log.includes("[ERROR]") || log.includes("STDERR") || log.includes("❌")) {
    return "text-red-400 font-semibold";
  } else if (log.includes("[SUCCESS]") || log.includes("✅")) {
    return "text-green-400 font-semibold";
  } else if (log.includes("[PHASE]")) {
    return "text-purple-400 font-bold text-lg";
  } else if (log.includes("[WARN]")) {
    return "text-yellow-400";
  } else if (log.includes("[INFO]")) {
    return "text-blue-400";
  } else if (log.includes("═══")) {
    return "text-gray-600";
  } else if (log.includes("🚀") || log.includes("🏁")) {
    return "text-cyan-400 font-semibold";
  }
  return "text-gray-300";
}

function scrollToBottom() {
  nextTick(() => {
    if (logsContainer.value) {
      logsContainer.value.scrollTop = logsContainer.value.scrollHeight;
    }
  });
}

// Watch les logs pour auto-scroll
watch(deploymentLogs, () => {
  scrollToBottom();
}, { deep: true });

// Fonction de déploiement simplifiée
async function handleDeploy() {
  await startDeployment(props.project.slug);
}
</script>
