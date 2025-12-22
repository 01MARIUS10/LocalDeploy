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
        <h2
          class="text-xl font-bold text-white flex items-center gap-2 headSection"
        >
          <svg
            class="w-6 h-6 text-white"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
            />
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
                  phase.isOpen ? 'rotate-90' : '',
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
                phase.status === 'success'
                  ? 'bg-green-500/20 text-green-400'
                  : phase.status === 'running'
                  ? 'bg-yellow-500/20 text-yellow-400'
                  : phase.status === 'error'
                  ? 'bg-red-500/20 text-red-400'
                  : 'bg-gray-500/20 text-gray-400',
              ]"
            >
              {{ getStatusLabel(phase.status) }}
            </span>
          </button>

          <!-- Contenu des logs -->
          <div v-show="phase.isOpen" class="border-t border-gray-700">
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
              <div v-if="phase.logs.length === 0" class="text-gray-500 italic">
                Aucun log disponible
              </div>
            </div>
          </div>
        </div>

        <!-- Indicateur de déploiement en cours -->
        <div v-if="isDeploying" class="text-center py-4">
          <div
            class="text-yellow-400 animate-pulse flex items-center justify-center gap-2"
          >
            <svg
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
            <span>Déploiement en cours...</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Domaine et URL -->
    <div class="bg-white rounded-xl shadow-md p-6 border border-gray-200">
      <h2
        class="text-2xl font-bold text-gray-800 mb-4 flex items-center gap-2 headSection"
      >
        <svg
          class="w-6 h-6 text-gray-800"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9"
          />
        </svg>
        Domaine & URL
      </h2>
      <div class="space-y-3">
        <div class="flex items-center justify-between">
          <span class="text-gray-600 font-medium">Domaine:</span>
          <a
            href="#"
            class="text-indigo-600 hover:text-indigo-800 font-mono"
          >
            {{ props.project.domain }} 
          </a>
        </div>
        <div class="flex items-center justify-between">
          <span class="text-gray-600 font-medium">Port:</span>
          <a
            href="#"
            class="text-indigo-600 hover:text-indigo-800 font-mono"
          >
            {{ props.project.port }} 
          </a>
        </div>
        <div class="flex items-center justify-between">
          <span class="text-gray-600 font-medium">URL de déploiement:</span>
          <a
            :href="`http://${props.project.domain}:${props.project.port}`"
            target="_blank"
            class="text-indigo-600 hover:text-indigo-800 font-mono text-sm"
          >
            {{ `http://${props.project.domain}:${props.project.port}` }} ↗
          </a>
        </div>
      </div>
    </div>

    <!-- Repository -->
    <div class="bg-white rounded-xl shadow-md p-6 border border-gray-200">
      <h2
        class="text-2xl font-bold text-gray-800 mb-4 flex items-center gap-2 headSection"
      >
        <svg
          class="w-6 h-6 text-gray-800"
          fill="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"
          />
        </svg>
        Repository GitHub
      </h2>

      <!-- Informations du repository -->
      <div class="space-y-4">
        <!-- Owner info -->
        <div
          v-if="props.project.github"
          class="flex items-center gap-4 pb-4 border-b border-gray-200"
        >
          <img
            :src="props.project.github.owner.avatar_url"
            :alt="props.project.github.owner.name"
            class="w-16 h-16 rounded-full border-2 border-gray-300"
          />
          <div>
            <div class="flex items-center gap-2">
              <a
                :href="props.project.github.owner.github_url"
                target="_blank"
                class="text-lg font-semibold text-gray-800 hover:text-indigo-600 flex items-center gap-1"
              >
                {{ props.project.github.owner.name }}
                <svg
                  class="w-4 h-4"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"
                  />
                </svg>
              </a>
            </div>
            <a
              :href="props.project.github.repo.html_url"
              target="_blank"
              class="text-sm text-gray-600 hover:text-indigo-600 font-mono"
            >
              {{ props.project.github.repo.full_name }}
            </a>
          </div>
        </div>

        <!-- Repository details -->
        <div class="space-y-3">
          <div class="flex items-center justify-between">
            <span class="text-gray-600 font-medium">URL:</span>
            <a
              :href="props.project.repository.url"
              target="_blank"
              class="text-indigo-600 hover:text-indigo-800 font-mono text-sm flex items-center gap-1"
            >
              {{ props.project.repository.url }}
              <svg
                class="w-4 h-4"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"
                />
              </svg>
            </a>
          </div>

          <div class="flex items-center justify-between">
            <span class="text-gray-600 font-medium">Branche:</span>
            <code class="bg-gray-100 px-3 py-1 rounded text-sm">{{
              props.project.repository.branch
            }}</code>
          </div>

          <!-- GitHub Stats -->
          <div
            v-if="props.project.github"
            class="flex items-center justify-between"
          >
            <span class="text-gray-600 font-medium">Langage:</span>
            <span
              class="bg-blue-100 text-blue-800 px-3 py-1 rounded text-sm font-semibold"
            >
              {{ props.project.github.repo.language || "N/A" }}
            </span>
          </div>

          <div
            v-if="props.project.github"
            class="flex items-center justify-between"
          >
            <span class="text-gray-600 font-medium">Visibilité:</span>
            <span
              :class="[
                'px-3 py-1 rounded text-sm font-semibold',
                props.project.github.repo.private
                  ? 'bg-red-100 text-red-800'
                  : 'bg-green-100 text-green-800',
              ]"
            >
              {{
                props.project.github.repo.private ? "🔒 Privé" : "🌐 Public"
              }}
            </span>
          </div>

          <div
            v-if="
              props.project.github &&
              (props.project.github.repo.stars > 0 ||
                props.project.github.repo.forks > 0)
            "
            class="flex items-center justify-between"
          >
            <span class="text-gray-600 font-medium">Popularité:</span>
            <div class="flex items-center gap-4 text-sm">
              <span class="flex items-center gap-1">
                <svg
                  class="w-4 h-4 text-yellow-500"
                  fill="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"
                  />
                </svg>
                {{ props.project.github.repo.stars }}
              </span>
              <span class="flex items-center gap-1">
                <svg
                  class="w-4 h-4 text-gray-500"
                  fill="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    d="M12 2C6.477 2 2 6.477 2 12c0 4.42 2.865 8.17 6.839 9.49.5.092.682-.217.682-.482 0-.237-.008-.866-.013-1.7-2.782.603-3.369-1.34-3.369-1.34-.454-1.156-1.11-1.463-1.11-1.463-.908-.62.069-.608.069-.608 1.003.07 1.531 1.03 1.531 1.03.892 1.529 2.341 1.087 2.91.831.092-.646.35-1.086.636-1.336-2.22-.253-4.555-1.11-4.555-4.943 0-1.091.39-1.984 1.029-2.683-.103-.253-.446-1.27.098-2.647 0 0 .84-.269 2.75 1.025A9.578 9.578 0 0112 6.836c.85.004 1.705.114 2.504.336 1.909-1.294 2.747-1.025 2.747-1.025.546 1.377.203 2.394.1 2.647.64.699 1.028 1.592 1.028 2.683 0 3.842-2.339 4.687-4.566 4.935.359.309.678.919.678 1.852 0 1.336-.012 2.415-.012 2.743 0 .267.18.578.688.48C19.138 20.167 22 16.418 22 12c0-5.523-4.477-10-10-10z"
                  />
                </svg>
                {{ props.project.github.repo.forks }}
              </span>
            </div>
          </div>
        </div>

        <!-- Last Commit -->
        <div
          v-if="props.project.github"
          class="mt-4 pt-4 border-t border-gray-200"
        >
          <h3 class="text-sm font-semibold text-gray-700 mb-3 flex items-center gap-2">
            <svg
              class="w-4 h-4"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M7 20l4-16m2 16l4-16M6 9h14M4 15h14"
              />
            </svg>
            Dernier commit
          </h3>
          <div class="bg-gray-50 rounded-lg p-4 space-y-2">
            <div class="flex items-start justify-between">
              <div class="flex-1">
                <p class="text-sm text-gray-800 font-medium">
                  {{ props.project.github.last_commit.message }}
                </p>
                <div class="flex items-center gap-3 mt-2 text-xs text-gray-600">
                  <span class="flex items-center gap-1">
                    <svg
                      class="w-3 h-3"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
                      />
                    </svg>
                    {{ props.project.github.last_commit.author }}
                  </span>
                  <span class="flex items-center gap-1">
                    <svg
                      class="w-3 h-3"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
                      />
                    </svg>
                    {{ formatDate(props.project.github.last_commit.date) }}
                  </span>
                </div>
              </div>
              <code
                class="bg-gray-800 text-green-400 px-2 py-1 rounded text-xs font-mono ml-3"
              >
                {{ props.project.github.last_commit.short_sha }}
              </code>
            </div>
          </div>
        </div>

        <!-- Fallback si pas de données GitHub -->
        <div v-else class="mt-4 pt-4 border-t border-gray-200">
          <div class="flex items-center justify-between">
            <span class="text-gray-600 font-medium">Dernier commit:</span>
            <span class="text-gray-700 text-sm">{{
              formatDate(props.project.repository.lastCommit)
            }}</span>
          </div>
        </div>
      </div>
    </div>



    <!-- Déploiement -->
    <div class="bg-white rounded-xl shadow-md p-6 border border-gray-200">
      <h2
        class="text-2xl font-bold text-gray-800 mb-4 flex items-center gap-2 headSection"
      >
        <svg
          class="w-6 h-6 text-gray-800"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M13 10V3L4 14h7v7l9-11h-7z"
          />
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
            {{ props.project.buildCommand }}
          </code>
        </div>
        <div class="flex items-center justify-between">
          <span class="text-gray-600 font-medium">Commande de démarrage:</span>
          <code
            class="bg-gray-900 text-green-400 px-3 py-1 rounded text-sm font-mono"
          >
            {{ props.project.startCommand }}
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
      <h2
        class="text-2xl font-bold text-gray-800 mb-4 flex items-center gap-2 headSection"
      >
        <svg
          class="w-6 h-6 text-gray-800"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4m0 5c0 2.21-3.582 4-8 4s-8-1.79-8-4"
          />
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
console.log(props.project.deployment);

// Utiliser le composable de déploiement
const {
  isDeploying,
  logs: deploymentLogs,
  startDeployment,
  clearLogs,
} = useDeploymentStream();

// Phases de déploiement
interface DeploymentPhase {
  id: number;
  title: string;
  status: "pending" | "running" | "success" | "error";
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
watch(
  deploymentLogs,
  (newLogs) => {
    // Réinitialiser les phases si nouveau déploiement
    if (
      newLogs.length === 1 &&
      newLogs[0].includes("Démarrage du déploiement")
    ) {
      deploymentPhases.value.forEach((phase) => {
        phase.status = "pending";
        phase.logs = [];
        phase.isOpen = phase.id === 1;
      });
      currentPhase = 0;
    }

    // Parcourir tous les logs
    for (const log of newLogs) {
      // Détecter le changement de phase
      if (
        log.includes("[PHASE]") ||
        log.includes("1/4") ||
        log.includes("2/4") ||
        log.includes("3/4") ||
        log.includes("4/4")
      ) {
        if (log.includes("1/4")) {
          currentPhase = 0;
          deploymentPhases.value[0].status = "running";
          deploymentPhases.value[0].isOpen = true;
        } else if (log.includes("2/4")) {
          if (currentPhase === 0) deploymentPhases.value[0].status = "success";
          currentPhase = 1;
          deploymentPhases.value[1].status = "running";
          deploymentPhases.value[1].isOpen = true;
        } else if (log.includes("3/4")) {
          if (currentPhase === 1) deploymentPhases.value[1].status = "success";
          currentPhase = 2;
          deploymentPhases.value[2].status = "running";
          deploymentPhases.value[2].isOpen = true;
        } else if (log.includes("4/4")) {
          if (currentPhase === 2) deploymentPhases.value[2].status = "success";
          currentPhase = 3;
          deploymentPhases.value[3].status = "running";
          deploymentPhases.value[3].isOpen = true;
        }
      }

      // Détecter les erreurs
      if (log.includes("[ERROR]") || log.includes("❌")) {
        if (currentPhase >= 0 && currentPhase < deploymentPhases.value.length) {
          deploymentPhases.value[currentPhase].status = "error";
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
  },
  { deep: true }
);

// Fonctions
function togglePhase(phaseId: number) {
  const phase = deploymentPhases.value.find((p) => p.id === phaseId);
  if (phase) {
    phase.isOpen = !phase.isOpen;
  }
}

function getStatusLabel(status: string): string {
  switch (status) {
    case "success":
      return "Complete";
    case "running":
      return "En cours";
    case "error":
      return "Erreur";
    default:
      return "En attente";
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
