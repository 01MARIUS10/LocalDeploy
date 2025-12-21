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
        <h2 class="text-xl font-bold text-white flex items-center gap-2 headSection">
          <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
          </svg>
          Logs de Déploiement
        </h2>
        <button
          @click="clearLogs"
          class="text-gray-400 hover:text-white text-sm px-3 py-1 rounded hover:bg-gray-800"
        >
          Effacer
        </button>
      </div>

      <!-- Phases accordéon -->
      <div class="space-y-3">
        <div
          v-for="phase in deploymentPhases"
          :key="phase.id"
          class="bg-gray-800 rounded-lg border border-gray-700 overflow-hidden"
        >
          <!-- En-tête de phase -->
          <button
            @click="togglePhase(phase.id)"
            class="w-full px-4 py-3 flex items-center justify-between hover:bg-gray-750 transition-colors"
          >
            <div class="flex items-center gap-3">
              <!-- Chevron -->
              <svg
                :class="[
                  'w-5 h-5 transition-transform text-gray-400',
                  phase.isOpen ? 'rotate-90' : ''
                ]"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M9 5l7 7-7 7"
                />
              </svg>

              <!-- Status icon -->
              <span class="text-xl">
                <span v-if="phase.status === 'running'" class="animate-spin"></span>
                <span v-else-if="phase.status === 'success'"></span>
                <span v-else-if="phase.status === 'error'"></span>
                <span v-else>⚪</span>
              </span>

              <!-- Titre -->
              <span class="text-white font-semibold">{{ phase.title }}</span>
            </div>

            <!-- Badge de statut -->
            <span
              :class="[
                'px-3 py-1 rounded-full text-xs font-medium',
                phase.status === 'success' ? 'bg-green-500/20 text-green-400' :
                phase.status === 'running' ? 'bg-yellow-500/20 text-yellow-400' :
                phase.status === 'error' ? 'bg-red-500/20 text-red-400' :
                'bg-gray-500/20 text-gray-400'
              ]"
            >
              {{ getStatusLabel(phase.status) }}
            </span>
          </button>

          <!-- Contenu des logs -->
          <div
            v-show="phase.isOpen"
            class="border-t border-gray-700"
          >
            <div
              class="bg-black p-4 max-h-64 overflow-y-auto font-mono text-sm space-y-1"
            >
              <div
                v-for="(log, index) in phase.logs"
                :key="index"
                :class="getLogClass(log)"
                class="whitespace-pre-wrap break-words"
              >
                {{ log }}
              </div>
              <div
                v-if="phase.logs.length === 0"
                class="text-gray-500 italic"
              >
                Aucun log disponible
              </div>
            </div>
          </div>
        </div>

        <!-- Indicateur de déploiement en cours -->
        <div
          v-if="isDeploying"
          class="text-center py-4"
        >
          <div class="text-yellow-400 animate-pulse flex items-center justify-center gap-2">
            <svg class="animate-spin h-5 w-5" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            <span>Déploiement en cours...</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Domaine et URL -->
    <div class="bg-white rounded-xl shadow-md p-6 border border-gray-200">
      <h2 class="text-2xl font-bold text-gray-800 mb-4 flex items-center gap-2 headSection">
        <svg class="w-6 h-6 text-gray-800" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9"/>
        </svg>
        Domaine & URL
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
      <h2 class="text-2xl font-bold text-gray-800 mb-4 flex items-center gap-2 headSection">
        <svg class="w-6 h-6 text-gray-800" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"/>
        </svg>
        Repository
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
      <h2 class="text-2xl font-bold text-gray-800 mb-4 flex items-center gap-2 headSection">
        <svg class="w-6 h-6 text-gray-800" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/>
        </svg>
        Déploiement
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
      <h2 class="text-2xl font-bold text-gray-800 mb-4 flex items-center gap-2 headSection">
        <svg class="w-6 h-6 text-gray-800" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4m0 5c0 2.21-3.582 4-8 4s-8-1.79-8-4"/>
        </svg>
        Base de données
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

// Phases de déploiement
interface DeploymentPhase {
  id: number;
  title: string;
  status: 'pending' | 'running' | 'success' | 'error';
  isOpen: boolean;
  logs: string[];
}

const deploymentPhases = ref<DeploymentPhase[]>([
  { id: 1, title: 'Création du projet', status: 'pending', isOpen: true, logs: [] },
  { id: 2, title: 'Engine et installation de dependances', status: 'pending', isOpen: false, logs: [] },
  { id: 3, title: 'Build du projet', status: 'pending', isOpen: false, logs: [] },
  { id: 4, title: 'Démarrage du serveur', status: 'pending', isOpen: false, logs: [] },
]);

let currentPhase = 0;

// Watcher pour organiser les logs par phase
watch(deploymentLogs, (newLogs) => {
  // Réinitialiser les phases si nouveau déploiement
  if (newLogs.length === 1 && newLogs[0].includes("Démarrage du déploiement")) {
    deploymentPhases.value.forEach(phase => {
      phase.status = 'pending';
      phase.logs = [];
      phase.isOpen = phase.id === 1;
    });
    currentPhase = 0;
  }

  // Parcourir tous les logs
  for (const log of newLogs) {
    // Détecter le changement de phase
    if (log.includes("[PHASE]") || log.includes("1/4") || log.includes("2/4") || log.includes("3/4") || log.includes("4/4")) {
      if (log.includes("1/4")) {
        currentPhase = 0;
        deploymentPhases.value[0].status = 'running';
        deploymentPhases.value[0].isOpen = true;
      } else if (log.includes("2/4")) {
        if (currentPhase === 0) deploymentPhases.value[0].status = 'success';
        currentPhase = 1;
        deploymentPhases.value[1].status = 'running';
        deploymentPhases.value[1].isOpen = true;
      } else if (log.includes("3/4")) {
        if (currentPhase === 1) deploymentPhases.value[1].status = 'success';
        currentPhase = 2;
        deploymentPhases.value[2].status = 'running';
        deploymentPhases.value[2].isOpen = true;
      } else if (log.includes("4/4")) {
        if (currentPhase === 2) deploymentPhases.value[2].status = 'success';
        currentPhase = 3;
        deploymentPhases.value[3].status = 'running';
        deploymentPhases.value[3].isOpen = true;
      }
    }

    // Détecter les erreurs
    if (log.includes("[ERROR]") || log.includes("❌")) {
      if (currentPhase >= 0 && currentPhase < deploymentPhases.value.length) {
        deploymentPhases.value[currentPhase].status = 'error';
      }
    }

    // Détecter la complétion
    if (log.includes("Déploiement terminé")) {
      if (currentPhase >= 0 && currentPhase < deploymentPhases.value.length) {
        deploymentPhases.value[currentPhase].status = 'success';
      }
    }

    // Ajouter le log à la phase courante (sans les logs de séparation)
    if (currentPhase >= 0 && currentPhase < deploymentPhases.value.length) {
      if (!log.includes("═══") && !log.includes("────") && log.trim()) {
        // Éviter les doublons
        const phase = deploymentPhases.value[currentPhase];
        if (!phase.logs.includes(log)) {
          phase.logs.push(log);
        }
      }
    }
  }
}, { deep: true });

// Fonctions
function togglePhase(phaseId: number) {
  const phase = deploymentPhases.value.find(p => p.id === phaseId);
  if (phase) {
    phase.isOpen = !phase.isOpen;
  }
}

function getStatusLabel(status: string): string {
  switch (status) {
    case 'success': return 'Complete';
    case 'running': return 'En cours';
    case 'error': return 'Erreur';
    default: return 'En attente';
  }
}

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
  console.log("Log:", log);
  if (log.includes("[ERROR]") || log.includes("STDERR")) {
    return "text-red-400 font-semibold";
  } else if (log.includes("[SUCCESS]")) {
    return "text-cyan-400 font-semibold";
    return "text-green-400 font-semibold";
    
  } else if (log.includes("[PHASE]")) {
    return "text-purple-400 font-bold text-lg";
  } else if (log.includes("[WARN]")) {
    return "text-yellow-400";
  } else if (log.includes("[INFO]")) {
    return "text-cyan-400";
    return "text-blue-400";
  } else if (log.includes("═══")) {
    return "text-gray-600";
  } 
  return "text-gray-300";
}

// Fonction de déploiement simplifiée
async function handleDeploy() {
  await startDeployment(props.project.slug);
}
</script>
