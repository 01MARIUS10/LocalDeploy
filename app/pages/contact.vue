<template>
  <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
    <h1 class="text-4xl font-bold text-gray-800 mb-4">Contact</h1>
    <p class="text-lg text-gray-600 mb-8">Vous pouvez nous contacter via les informations ci-dessous.</p>
    
    <section class="grid grid-cols-1 md:grid-cols-3 gap-6 my-8">
      <div class="bg-gray-50 p-6 rounded-lg border-l-4 border-emerald-500">
        <h3 class="text-lg font-semibold text-gray-800 mb-2">📧 Email</h3>
        <p class="text-gray-600">contact@example.com</p>
      </div>

      <div class="bg-gray-50 p-6 rounded-lg border-l-4 border-emerald-500">
        <h3 class="text-lg font-semibold text-gray-800 mb-2">📱 Téléphone</h3>
        <p class="text-gray-600">+33 1 23 45 67 89</p>
      </div>

      <div class="bg-gray-50 p-6 rounded-lg border-l-4 border-emerald-500">
        <h3 class="text-lg font-semibold text-gray-800 mb-2">📍 Adresse</h3>
        <p class="text-gray-600">123 Rue de la Tech<br>75001 Paris, France</p>
      </div>
    </section>

    <ClientContactForm />

    <nav class="flex gap-4 mt-8">
      <NuxtLink 
        to="/"
        class="px-6 py-3 bg-emerald-500 text-white rounded-lg hover:bg-emerald-600 transition-colors duration-300 font-medium"
      >
        Retour à l'accueil
      </NuxtLink>
      <NuxtLink 
        to="/about"
        class="px-6 py-3 bg-emerald-500 text-white rounded-lg hover:bg-emerald-600 transition-colors duration-300 font-medium"
      >
        À propos
      </NuxtLink>
    </nav>
  </div>
</template>

<script setup lang="ts">
</script>
