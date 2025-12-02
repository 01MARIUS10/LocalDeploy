<template>
  <div class="bg-white p-8 rounded-lg border-2 border-emerald-500 my-8 shadow-md">
    <h2 class="text-2xl font-semibold text-gray-800 mb-2">📝 Formulaire de contact</h2>
    <p class="text-sm text-gray-500 mb-6">Formulaire interactif côté client</p>

    <form @submit.prevent="handleSubmit" class="flex flex-col gap-4">
      <div class="flex flex-col gap-2">
        <label for="name" class="text-sm font-semibold text-gray-800">Nom</label>
        <input
          id="name"
          v-model="formData.name"
          type="text"
          required
          placeholder="Votre nom"
          class="px-3 py-2 border border-gray-300 rounded focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-100 transition-colors"
        />
      </div>

      <div class="flex flex-col gap-2">
        <label for="email" class="text-sm font-semibold text-gray-800">Email</label>
        <input
          id="email"
          v-model="formData.email"
          type="email"
          required
          placeholder="votre@email.com"
          class="px-3 py-2 border border-gray-300 rounded focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-100 transition-colors"
        />
      </div>

      <div class="flex flex-col gap-2">
        <label for="message" class="text-sm font-semibold text-gray-800">Message</label>
        <textarea
          id="message"
          v-model="formData.message"
          required
          rows="4"
          placeholder="Votre message..."
          class="px-3 py-2 border border-gray-300 rounded resize-y focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-100 transition-colors"
        ></textarea>
      </div>

      <button 
        type="submit" 
        :disabled="isSubmitting"
        class="px-6 py-3 bg-emerald-500 text-white rounded font-semibold transition-colors hover:bg-emerald-600 disabled:bg-gray-400 disabled:cursor-not-allowed disabled:opacity-60"
      >
        {{ isSubmitting ? 'Envoi...' : 'Envoyer' }}
      </button>
    </form>

    <div 
      v-if="submitMessage" 
      class="mt-4 p-4 rounded font-medium bg-green-50 text-green-800 border border-green-200"
    >
      {{ submitMessage }}
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'

const formData = reactive({
  name: '',
  email: '',
  message: ''
})

const isSubmitting = ref(false)
const submitMessage = ref('')
const messageType = ref('')

const handleSubmit = async () => {
  isSubmitting.value = true
  submitMessage.value = ''

  // Simulation d'un envoi (client-side)
  await new Promise(resolve => setTimeout(resolve, 1000))

  // Afficher un message de succès
  submitMessage.value = `Merci ${formData.name}! Votre message a été reçu.`
  messageType.value = 'success'

  // Réinitialiser le formulaire
  formData.name = ''
  formData.email = ''
  formData.message = ''

  isSubmitting.value = false

  // Effacer le message après 5 secondes
  setTimeout(() => {
    submitMessage.value = ''
  }, 5000)
}
</script>
