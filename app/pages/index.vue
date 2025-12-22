<template>
  <div class="min-h-screen bg-gradient-to-b from-slate-950 via-slate-900 to-slate-950">
    <!-- Hero Section -->
    <section class="relative overflow-hidden">
      <!-- Background grid pattern -->
      <div class="absolute inset-0 bg-[linear-gradient(rgba(34,197,94,0.03)_1px,transparent_1px),linear-gradient(90deg,rgba(34,197,94,0.03)_1px,transparent_1px)] bg-[size:50px_50px]"></div>
      
      <!-- Glowing orbs -->
      <div class="absolute top-20 left-10 w-72 h-72 bg-emerald-500/20 rounded-full blur-[120px] animate-pulse"></div>
      <div class="absolute bottom-20 right-10 w-96 h-96 bg-cyan-500/10 rounded-full blur-[150px] animate-pulse delay-1000"></div>
      
      <div class="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-20 pb-32">
        <!-- Badge -->
        <div class="flex justify-center mb-8">
          <span class="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-sm font-mono">
            <span class="w-2 h-2 bg-emerald-400 rounded-full animate-pulse"></span>
            v1.0.0 — Production Ready
          </span>
        </div>

        <!-- Main Title -->
        <h1 class="text-center text-5xl md:text-7xl font-bold mb-6">
          <span class="text-white">Local</span><span class="text-emerald-400">Deploy</span>
        </h1>
        
        <p class="text-center text-xl md:text-2xl text-slate-400 max-w-3xl mx-auto mb-8">
          Votre plateforme de déploiement automatique 
          <span class="text-emerald-400 font-semibold">auto-hébergée</span>. 
          Déployez vos applications Node.js en quelques clics.
        </p>

        <!-- CTA Buttons -->
        <div class="flex flex-col sm:flex-row justify-center gap-4 mb-16">
          <NuxtLink 
            to="/server/projects"
            class="group px-8 py-4 bg-emerald-500 hover:bg-emerald-400 text-slate-900 font-bold rounded-lg transition-all duration-300 flex items-center justify-center gap-2 shadow-lg shadow-emerald-500/25 hover:shadow-emerald-400/40"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/>
            </svg>
            Commencer le déploiement
            <svg class="w-4 h-4 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
            </svg>
          </NuxtLink>
          <a 
            href="https://github.com/01MARIUS10/LocalDeploy"
            target="_blank"
            class="px-8 py-4 bg-slate-800 hover:bg-slate-700 text-white font-semibold rounded-lg transition-all duration-300 flex items-center justify-center gap-2 border border-slate-700 hover:border-slate-600"
          >
            <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
              <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
            </svg>
            Voir sur GitHub
          </a>
        </div>

        <!-- Terminal Preview -->
        <div class="max-w-4xl mx-auto">
          <div class="bg-slate-900 rounded-xl border border-slate-700/50 shadow-2xl shadow-black/50 overflow-hidden">
            <!-- Terminal Header -->
            <div class="flex items-center gap-2 px-4 py-3 bg-slate-800/80 border-b border-slate-700/50">
              <div class="flex gap-2">
                <span class="w-3 h-3 rounded-full bg-red-500"></span>
                <span class="w-3 h-3 rounded-full bg-yellow-500"></span>
                <span class="w-3 h-3 rounded-full bg-green-500"></span>
              </div>
              <span class="flex-1 text-center text-sm text-slate-400 font-mono">deploy@localdeploy:~</span>
            </div>
            <!-- Terminal Content -->
            <div class="p-6 font-mono text-sm leading-relaxed overflow-x-auto">
              <div class="space-y-2">
                <p><span class="text-emerald-400">$</span> <span class="text-slate-300">localdeploy init my-nuxt-app</span></p>
                <p class="text-slate-500">→ Initializing project structure...</p>
                <p class="text-slate-500">→ Connecting to GitHub repository...</p>
                <p class="text-emerald-400">✓ Project initialized successfully</p>
                <p class="mt-4"><span class="text-emerald-400">$</span> <span class="text-slate-300">localdeploy deploy --prod</span></p>
                <p class="text-cyan-400">[PHASE 1/4] 📁 Création du projet</p>
                <p class="text-slate-500">  → Cloning repository from GitHub...</p>
                <p class="text-emerald-400">  ✓ Repository cloned</p>
                <p class="text-cyan-400">[PHASE 2/4] 📦 Installation des dépendances</p>
                <p class="text-slate-500">  → Running npm install...</p>
                <p class="text-slate-500">  → Using Node.js v22 via NVM</p>
                <p class="text-emerald-400">  ✓ Dependencies installed</p>
                <p class="text-cyan-400">[PHASE 3/4] ⚡ Build du projet</p>
                <p class="text-slate-500">  → Executing: npm run build</p>
                <p class="text-emerald-400">  ✓ Build completed</p>
                <p class="text-cyan-400">[PHASE 4/4] 🚀 Lancement du serveur</p>
                <p class="text-slate-500">  → Starting server on port 3001...</p>
                <p class="text-slate-500">  → Configuring PM2 process manager...</p>
                <p class="text-slate-500">  → Setting up Nginx reverse proxy...</p>
                <p class="text-emerald-400">  ✓ Server running at http://my-nuxt-app.local</p>
                <p class="mt-4 text-emerald-400 font-bold">✅ Deployment successful in 42s</p>
                <p class="text-slate-400 animate-pulse">█</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- What is LocalDeploy Section -->
    <section class="py-24 relative">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-16">
          <h2 class="text-3xl md:text-4xl font-bold text-white mb-4">
            Qu'est-ce que <span class="text-emerald-400">LocalDeploy</span> ?
          </h2>
          <p class="text-lg text-slate-400 max-w-3xl mx-auto">
            LocalDeploy est une plateforme de déploiement automatique auto-hébergée, 
            inspirée de Netlify et Vercel, mais conçue pour tourner sur votre propre serveur.
          </p>
        </div>

        <div class="grid md:grid-cols-2 gap-12 items-center">
          <div class="space-y-6">
            <div class="flex items-start gap-4">
              <div class="w-12 h-12 rounded-lg bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center flex-shrink-0">
                <svg class="w-6 h-6 text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 12h14M12 5l7 7-7 7"/>
                </svg>
              </div>
              <div>
                <h3 class="text-xl font-semibold text-white mb-2">Déploiement en un clic</h3>
                <p class="text-slate-400">Connectez votre repository GitHub et déployez automatiquement à chaque push. Plus besoin de SSH manuel.</p>
              </div>
            </div>
            
            <div class="flex items-start gap-4">
              <div class="w-12 h-12 rounded-lg bg-cyan-500/10 border border-cyan-500/20 flex items-center justify-center flex-shrink-0">
                <svg class="w-6 h-6 text-cyan-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/>
                </svg>
              </div>
              <div>
                <h3 class="text-xl font-semibold text-white mb-2">Contrôle total</h3>
                <p class="text-slate-400">Vos données, votre serveur, vos règles. Aucune dépendance à des services tiers payants.</p>
              </div>
            </div>

            <div class="flex items-start gap-4">
              <div class="w-12 h-12 rounded-lg bg-purple-500/10 border border-purple-500/20 flex items-center justify-center flex-shrink-0">
                <svg class="w-6 h-6 text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/>
                </svg>
              </div>
              <div>
                <h3 class="text-xl font-semibold text-white mb-2">Logs en temps réel</h3>
                <p class="text-slate-400">Suivez chaque étape du déploiement avec des logs en streaming directement dans votre navigateur.</p>
              </div>
            </div>
          </div>

          <!-- Architecture Diagram -->
          <div class="bg-slate-900/50 rounded-xl border border-slate-700/50 p-6">
            <div class="text-center text-slate-400 text-sm font-mono mb-6">Architecture du système</div>
            <div class="space-y-4">
              <div class="flex items-center justify-center gap-4">
                <div class="px-4 py-2 bg-slate-800 rounded-lg border border-slate-600 text-white font-mono text-sm">
                  GitHub
                </div>
                <svg class="w-8 h-8 text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 8l4 4m0 0l-4 4m4-4H3"/>
                </svg>
                <div class="px-4 py-2 bg-emerald-500/20 rounded-lg border border-emerald-500/40 text-emerald-400 font-mono text-sm">
                  LocalDeploy
                </div>
              </div>
              
              <div class="flex justify-center">
                <svg class="w-8 h-8 text-slate-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 14l-7 7m0 0l-7-7m7 7V3"/>
                </svg>
              </div>

              <div class="grid grid-cols-3 gap-3">
                <div class="px-3 py-2 bg-slate-800/80 rounded-lg border border-slate-700 text-center">
                  <div class="text-cyan-400 font-mono text-xs">NVM</div>
                  <div class="text-slate-500 text-xs mt-1">Node.js</div>
                </div>
                <div class="px-3 py-2 bg-slate-800/80 rounded-lg border border-slate-700 text-center">
                  <div class="text-purple-400 font-mono text-xs">PM2</div>
                  <div class="text-slate-500 text-xs mt-1">Process</div>
                </div>
                <div class="px-3 py-2 bg-slate-800/80 rounded-lg border border-slate-700 text-center">
                  <div class="text-green-400 font-mono text-xs">Nginx</div>
                  <div class="text-slate-500 text-xs mt-1">Proxy</div>
                </div>
              </div>

              <div class="flex justify-center">
                <svg class="w-8 h-8 text-slate-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 14l-7 7m0 0l-7-7m7 7V3"/>
                </svg>
              </div>

              <div class="px-4 py-3 bg-gradient-to-r from-emerald-500/20 to-cyan-500/20 rounded-lg border border-emerald-500/30 text-center">
                <div class="text-white font-mono text-sm">🌐 votre-app.votredomaine.com</div>
                <div class="text-slate-400 text-xs mt-1">Production Ready</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Tech Stack Section -->
    <section class="py-24 bg-slate-900/50">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-16">
          <h2 class="text-3xl md:text-4xl font-bold text-white mb-4">
            Stack <span class="text-emerald-400">Technologique</span>
          </h2>
          <p class="text-lg text-slate-400">
            Des outils éprouvés et robustes pour des déploiements fiables
          </p>
        </div>

        <div class="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-6">
          <!-- GitHub -->
          <div class="group p-6 bg-slate-800/50 rounded-xl border border-slate-700/50 hover:border-slate-600 transition-all duration-300 hover:scale-105">
            <div class="flex flex-col items-center text-center">
              <svg class="w-12 h-12 text-slate-400 group-hover:text-white transition-colors mb-3" fill="currentColor" viewBox="0 0 24 24">
                <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
              </svg>
              <span class="text-white font-semibold">GitHub</span>
              <span class="text-slate-500 text-xs mt-1">Version Control</span>
            </div>
          </div>

          <!-- Node.js -->
          <div class="group p-6 bg-slate-800/50 rounded-xl border border-slate-700/50 hover:border-green-500/50 transition-all duration-300 hover:scale-105">
            <div class="flex flex-col items-center text-center">
              <svg class="w-12 h-12 text-green-500 mb-3" viewBox="0 0 24 24" fill="currentColor">
                <path d="M11.998 24c-.321 0-.641-.084-.922-.247l-2.936-1.737c-.438-.245-.224-.332-.08-.383.585-.203.703-.25 1.328-.604.065-.037.151-.023.218.017l2.256 1.339c.082.045.198.045.275 0l8.795-5.076c.082-.047.134-.141.134-.238V6.921c0-.099-.053-.193-.137-.242l-8.791-5.072c-.081-.047-.189-.047-.271 0L3.075 6.68c-.085.049-.139.143-.139.242v10.15c0 .097.054.189.139.235l2.409 1.392c1.307.654 2.108-.116 2.108-.891V7.787c0-.142.114-.253.256-.253h1.115c.139 0 .255.111.255.253v10.021c0 1.745-.95 2.745-2.604 2.745-.508 0-.909 0-2.026-.551L2.28 18.675c-.57-.329-.922-.943-.922-1.604V6.921c0-.659.352-1.274.922-1.603L11.076.242c.558-.318 1.303-.318 1.856 0l8.795 5.076c.57.329.924.944.924 1.603v10.15c0 .659-.354 1.273-.924 1.604l-8.795 5.078c-.28.163-.601.247-.923.247z"/>
              </svg>
              <span class="text-white font-semibold">Node.js</span>
              <span class="text-slate-500 text-xs mt-1">Runtime</span>
            </div>
          </div>

          <!-- NVM -->
          <div class="group p-6 bg-slate-800/50 rounded-xl border border-slate-700/50 hover:border-yellow-500/50 transition-all duration-300 hover:scale-105">
            <div class="flex flex-col items-center text-center">
              <div class="w-12 h-12 rounded-lg bg-yellow-500/20 flex items-center justify-center mb-3">
                <span class="text-yellow-400 font-bold text-lg">nvm</span>
              </div>
              <span class="text-white font-semibold">NVM</span>
              <span class="text-slate-500 text-xs mt-1">Node Version Manager</span>
            </div>
          </div>

          <!-- PM2 -->
          <div class="group p-6 bg-slate-800/50 rounded-xl border border-slate-700/50 hover:border-purple-500/50 transition-all duration-300 hover:scale-105">
            <div class="flex flex-col items-center text-center">
              <div class="w-12 h-12 rounded-lg bg-purple-500/20 flex items-center justify-center mb-3">
                <span class="text-purple-400 font-bold text-lg">PM2</span>
              </div>
              <span class="text-white font-semibold">PM2</span>
              <span class="text-slate-500 text-xs mt-1">Process Manager</span>
            </div>
          </div>

          <!-- Nginx -->
          <div class="group p-6 bg-slate-800/50 rounded-xl border border-slate-700/50 hover:border-green-500/50 transition-all duration-300 hover:scale-105">
            <div class="flex flex-col items-center text-center">
              <div class="w-12 h-12 rounded-lg bg-green-600/20 flex items-center justify-center mb-3">
                <span class="text-green-500 font-bold text-sm">NGINX</span>
              </div>
              <span class="text-white font-semibold">Nginx</span>
              <span class="text-slate-500 text-xs mt-1">Reverse Proxy</span>
            </div>
          </div>

          <!-- SQLite -->
          <div class="group p-6 bg-slate-800/50 rounded-xl border border-slate-700/50 hover:border-blue-500/50 transition-all duration-300 hover:scale-105">
            <div class="flex flex-col items-center text-center">
              <div class="w-12 h-12 rounded-lg bg-blue-500/20 flex items-center justify-center mb-3">
                <svg class="w-7 h-7 text-blue-400" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 17.93c-3.95-.49-7-3.85-7-7.93 0-.62.08-1.21.21-1.79L9 15v1c0 1.1.9 2 2 2v1.93zm6.9-2.54c-.26-.81-1-1.39-1.9-1.39h-1v-3c0-.55-.45-1-1-1H8v-2h2c.55 0 1-.45 1-1V7h2c1.1 0 2-.9 2-2v-.41c2.93 1.19 5 4.06 5 7.41 0 2.08-.8 3.97-2.1 5.39z"/>
                </svg>
              </div>
              <span class="text-white font-semibold">Prisma</span>
              <span class="text-slate-500 text-xs mt-1">Database ORM</span>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- How it Works Section -->
    <section class="py-24">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-16">
          <h2 class="text-3xl md:text-4xl font-bold text-white mb-4">
            Comment <span class="text-emerald-400">ça marche</span> ?
          </h2>
          <p class="text-lg text-slate-400">
            4 étapes simples pour déployer votre application
          </p>
        </div>

        <div class="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
          <!-- Step 1 -->
          <div class="relative">
            <div class="absolute -top-4 -left-4 w-12 h-12 bg-emerald-500 rounded-full flex items-center justify-center text-slate-900 font-bold text-xl shadow-lg shadow-emerald-500/30">
              1
            </div>
            <div class="pt-8 p-6 bg-slate-800/50 rounded-xl border border-slate-700/50 h-full">
              <div class="w-16 h-16 mx-auto mb-4 rounded-xl bg-slate-700/50 flex items-center justify-center">
                <svg class="w-8 h-8 text-emerald-400" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
                </svg>
              </div>
              <h3 class="text-xl font-semibold text-white text-center mb-2">Connectez GitHub</h3>
              <p class="text-slate-400 text-center text-sm">Ajoutez l'URL de votre repository GitHub public ou privé</p>
            </div>
          </div>

          <!-- Step 2 -->
          <div class="relative">
            <div class="absolute -top-4 -left-4 w-12 h-12 bg-cyan-500 rounded-full flex items-center justify-center text-slate-900 font-bold text-xl shadow-lg shadow-cyan-500/30">
              2
            </div>
            <div class="pt-8 p-6 bg-slate-800/50 rounded-xl border border-slate-700/50 h-full">
              <div class="w-16 h-16 mx-auto mb-4 rounded-xl bg-slate-700/50 flex items-center justify-center">
                <svg class="w-8 h-8 text-cyan-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/>
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                </svg>
              </div>
              <h3 class="text-xl font-semibold text-white text-center mb-2">Configurez</h3>
              <p class="text-slate-400 text-center text-sm">Définissez les variables d'environnement, la commande de build et la version Node</p>
            </div>
          </div>

          <!-- Step 3 -->
          <div class="relative">
            <div class="absolute -top-4 -left-4 w-12 h-12 bg-purple-500 rounded-full flex items-center justify-center text-slate-900 font-bold text-xl shadow-lg shadow-purple-500/30">
              3
            </div>
            <div class="pt-8 p-6 bg-slate-800/50 rounded-xl border border-slate-700/50 h-full">
              <div class="w-16 h-16 mx-auto mb-4 rounded-xl bg-slate-700/50 flex items-center justify-center">
                <svg class="w-8 h-8 text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/>
                </svg>
              </div>
              <h3 class="text-xl font-semibold text-white text-center mb-2">Déployez</h3>
              <p class="text-slate-400 text-center text-sm">Cliquez sur "Déployer" et suivez les logs en temps réel</p>
            </div>
          </div>

          <!-- Step 4 -->
          <div class="relative">
            <div class="absolute -top-4 -left-4 w-12 h-12 bg-pink-500 rounded-full flex items-center justify-center text-slate-900 font-bold text-xl shadow-lg shadow-pink-500/30">
              4
            </div>
            <div class="pt-8 p-6 bg-slate-800/50 rounded-xl border border-slate-700/50 h-full">
              <div class="w-16 h-16 mx-auto mb-4 rounded-xl bg-slate-700/50 flex items-center justify-center">
                <svg class="w-8 h-8 text-pink-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9"/>
                </svg>
              </div>
              <h3 class="text-xl font-semibold text-white text-center mb-2">C'est en ligne !</h3>
              <p class="text-slate-400 text-center text-sm">Votre application est accessible via votre domaine personnalisé</p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Features Section -->
    <section class="py-24 bg-slate-900/50">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-16">
          <h2 class="text-3xl md:text-4xl font-bold text-white mb-4">
            Fonctionnalités <span class="text-emerald-400">Avancées</span>
          </h2>
        </div>

        <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          <!-- Feature 1 -->
          <div class="p-6 bg-slate-800/30 rounded-xl border border-slate-700/30 hover:border-emerald-500/30 transition-colors">
            <div class="w-12 h-12 rounded-lg bg-emerald-500/10 flex items-center justify-center mb-4">
              <svg class="w-6 h-6 text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
              </svg>
            </div>
            <h3 class="text-xl font-semibold text-white mb-2">Variables d'environnement</h3>
            <p class="text-slate-400">Gérez vos secrets et configurations de manière sécurisée via l'interface web</p>
          </div>

          <!-- Feature 2 -->
          <div class="p-6 bg-slate-800/30 rounded-xl border border-slate-700/30 hover:border-cyan-500/30 transition-colors">
            <div class="w-12 h-12 rounded-lg bg-cyan-500/10 flex items-center justify-center mb-4">
              <svg class="w-6 h-6 text-cyan-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
              </svg>
            </div>
            <h3 class="text-xl font-semibold text-white mb-2">Redéploiement automatique</h3>
            <p class="text-slate-400">Configurez des webhooks GitHub pour déployer automatiquement à chaque push</p>
          </div>

          <!-- Feature 3 -->
          <div class="p-6 bg-slate-800/30 rounded-xl border border-slate-700/30 hover:border-purple-500/30 transition-colors">
            <div class="w-12 h-12 rounded-lg bg-purple-500/10 flex items-center justify-center mb-4">
              <svg class="w-6 h-6 text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
              </svg>
            </div>
            <h3 class="text-xl font-semibold text-white mb-2">Historique des déploiements</h3>
            <p class="text-slate-400">Consultez l'historique complet avec les logs de chaque déploiement</p>
          </div>

          <!-- Feature 4 -->
          <div class="p-6 bg-slate-800/30 rounded-xl border border-slate-700/30 hover:border-yellow-500/30 transition-colors">
            <div class="w-12 h-12 rounded-lg bg-yellow-500/10 flex items-center justify-center mb-4">
              <svg class="w-6 h-6 text-yellow-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4"/>
              </svg>
            </div>
            <h3 class="text-xl font-semibold text-white mb-2">Multi-versions Node.js</h3>
            <p class="text-slate-400">Choisissez la version Node.js pour chaque projet grâce à NVM</p>
          </div>

          <!-- Feature 5 -->
          <div class="p-6 bg-slate-800/30 rounded-xl border border-slate-700/30 hover:border-pink-500/30 transition-colors">
            <div class="w-12 h-12 rounded-lg bg-pink-500/10 flex items-center justify-center mb-4">
              <svg class="w-6 h-6 text-pink-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
              </svg>
            </div>
            <h3 class="text-xl font-semibold text-white mb-2">Authentification sécurisée</h3>
            <p class="text-slate-400">JWT et sessions sécurisées pour protéger votre plateforme</p>
          </div>

          <!-- Feature 6 -->
          <div class="p-6 bg-slate-800/30 rounded-xl border border-slate-700/30 hover:border-green-500/30 transition-colors">
            <div class="w-12 h-12 rounded-lg bg-green-500/10 flex items-center justify-center mb-4">
              <svg class="w-6 h-6 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
              </svg>
            </div>
            <h3 class="text-xl font-semibold text-white mb-2">Monitoring intégré</h3>
            <p class="text-slate-400">Surveillez l'état de vos applications et le statut des processus PM2</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Terminal Demo Section -->
    <section class="py-24">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-16">
          <h2 class="text-3xl md:text-4xl font-bold text-white mb-4">
            Commandes <span class="text-emerald-400">PM2</span> intégrées
          </h2>
          <p class="text-lg text-slate-400">
            Gérez vos processus directement depuis l'interface
          </p>
        </div>

        <div class="grid md:grid-cols-2 gap-8">
          <!-- PM2 Status -->
          <div class="bg-slate-900 rounded-xl border border-slate-700/50 overflow-hidden">
            <div class="flex items-center gap-2 px-4 py-3 bg-slate-800/80 border-b border-slate-700/50">
              <div class="flex gap-2">
                <span class="w-3 h-3 rounded-full bg-red-500"></span>
                <span class="w-3 h-3 rounded-full bg-yellow-500"></span>
                <span class="w-3 h-3 rounded-full bg-green-500"></span>
              </div>
              <span class="flex-1 text-center text-sm text-slate-400 font-mono">pm2 status</span>
            </div>
            <div class="p-4 font-mono text-xs overflow-x-auto">
              <table class="w-full text-left">
                <thead>
                  <tr class="text-slate-500 border-b border-slate-700">
                    <th class="pb-2">id</th>
                    <th class="pb-2">name</th>
                    <th class="pb-2">mode</th>
                    <th class="pb-2">status</th>
                    <th class="pb-2">cpu</th>
                    <th class="pb-2">memory</th>
                  </tr>
                </thead>
                <tbody class="text-slate-300">
                  <tr class="border-b border-slate-800">
                    <td class="py-2 text-cyan-400">0</td>
                    <td class="py-2">my-nuxt-app</td>
                    <td class="py-2 text-purple-400">fork</td>
                    <td class="py-2"><span class="text-emerald-400">● online</span></td>
                    <td class="py-2">0.1%</td>
                    <td class="py-2">98.2mb</td>
                  </tr>
                  <tr class="border-b border-slate-800">
                    <td class="py-2 text-cyan-400">1</td>
                    <td class="py-2">api-backend</td>
                    <td class="py-2 text-purple-400">cluster</td>
                    <td class="py-2"><span class="text-emerald-400">● online</span></td>
                    <td class="py-2">0.3%</td>
                    <td class="py-2">156.4mb</td>
                  </tr>
                  <tr>
                    <td class="py-2 text-cyan-400">2</td>
                    <td class="py-2">portfolio</td>
                    <td class="py-2 text-purple-400">fork</td>
                    <td class="py-2"><span class="text-red-400">● stopped</span></td>
                    <td class="py-2">0%</td>
                    <td class="py-2">0b</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- Nginx Config -->
          <div class="bg-slate-900 rounded-xl border border-slate-700/50 overflow-hidden">
            <div class="flex items-center gap-2 px-4 py-3 bg-slate-800/80 border-b border-slate-700/50">
              <div class="flex gap-2">
                <span class="w-3 h-3 rounded-full bg-red-500"></span>
                <span class="w-3 h-3 rounded-full bg-yellow-500"></span>
                <span class="w-3 h-3 rounded-full bg-green-500"></span>
              </div>
              <span class="flex-1 text-center text-sm text-slate-400 font-mono">/etc/nginx/sites-available/my-nuxt-app</span>
            </div>
            <div class="p-4 font-mono text-xs overflow-x-auto">
              <pre class="text-slate-300"><span class="text-purple-400">server</span> {
    <span class="text-cyan-400">listen</span> <span class="text-yellow-400">80</span>;
    <span class="text-cyan-400">server_name</span> <span class="text-emerald-400">my-nuxt-app.example.com</span>;

    <span class="text-purple-400">location</span> / {
        <span class="text-cyan-400">proxy_pass</span> <span class="text-emerald-400">http://localhost:3001</span>;
        <span class="text-cyan-400">proxy_http_version</span> <span class="text-yellow-400">1.1</span>;
        <span class="text-cyan-400">proxy_set_header</span> Upgrade <span class="text-emerald-400">$http_upgrade</span>;
        <span class="text-cyan-400">proxy_set_header</span> Connection <span class="text-emerald-400">'upgrade'</span>;
        <span class="text-cyan-400">proxy_set_header</span> Host <span class="text-emerald-400">$host</span>;
        <span class="text-cyan-400">proxy_cache_bypass</span> <span class="text-emerald-400">$http_upgrade</span>;
    }
}</pre>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- CTA Section -->
    <section class="py-24">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="bg-gradient-to-r from-emerald-500/10 to-cyan-500/10 rounded-2xl border border-emerald-500/20 p-12 text-center">
          <h2 class="text-3xl md:text-4xl font-bold text-white mb-4">
            Prêt à déployer ?
          </h2>
          <p class="text-lg text-slate-400 mb-8">
            Commencez à déployer vos applications Node.js en quelques minutes
          </p>
          <div class="flex flex-col sm:flex-row justify-center gap-4">
            <NuxtLink 
              to="/register"
              class="px-8 py-4 bg-emerald-500 hover:bg-emerald-400 text-slate-900 font-bold rounded-lg transition-all duration-300 shadow-lg shadow-emerald-500/25"
            >
              Créer un compte gratuit
            </NuxtLink>
            <NuxtLink 
              to="/login"
              class="px-8 py-4 bg-slate-800 hover:bg-slate-700 text-white font-semibold rounded-lg transition-all duration-300 border border-slate-700"
            >
              Se connecter
            </NuxtLink>
          </div>
        </div>
      </div>
    </section>

    <!-- Footer -->
    <footer class="py-12 border-t border-slate-800">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex flex-col md:flex-row justify-between items-center gap-6">
          <div class="flex items-center gap-2">
            <span class="text-2xl font-bold text-white">Local</span>
            <span class="text-2xl font-bold text-emerald-400">Deploy</span>
          </div>
          <div class="flex items-center gap-6 text-slate-400">
            <a href="https://github.com/01MARIUS10/LocalDeploy" target="_blank" class="hover:text-white transition-colors">
              GitHub
            </a>
            <NuxtLink to="/docs" class="hover:text-white transition-colors">
              Documentation
            </NuxtLink>
            <NuxtLink to="/about" class="hover:text-white transition-colors">
              À propos
            </NuxtLink>
          </div>
          <div class="text-slate-500 text-sm">
            © {{ new Date().getFullYear() }} LocalDeploy. Open Source.
          </div>
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
// Configuration SEO de la page
useHead({
  title: 'LocalDeploy - Plateforme de déploiement automatique auto-hébergée',
  meta: [
    { name: 'description', content: 'LocalDeploy est une plateforme de déploiement automatique auto-hébergée pour vos applications Node.js. Déployez vos projets GitHub avec PM2, Nginx et NVM.' },
    { name: 'keywords', content: 'deploy, node.js, nuxt, pm2, nginx, nvm, github, auto-hébergé, déploiement automatique' },
    { property: 'og:title', content: 'LocalDeploy - Plateforme de déploiement automatique' },
    { property: 'og:description', content: 'Déployez vos applications Node.js en quelques clics sur votre propre serveur.' },
    { property: 'og:type', content: 'website' },
  ]
})
</script>
