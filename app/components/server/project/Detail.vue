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

const props = defineProps<{
  project: any;
}>();

function formatDate(dateString: string) {
  return new Date(dateString).toLocaleString("fr-FR", {
    year: "numeric",
    month: "long",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}
</script>
