<template>
  <Teleport to="body">
    <Transition name="toast">
      <div
        v-if="visible"
        class="fixed top-4 right-4 z-9999 flex items-start gap-3 bg-white rounded-xl shadow-lg border border-gray-100 p-4 min-w-[320px] max-w-[420px]"
        :class="toastClass"
      >
        <Icon
          :icon="iconName"
          class="w-5 h-5 flex-shrink-0 mt-0.5"
          :class="iconClass"
        />
        <div class="flex-1 min-w-0">
          <div class="font-medium text-gray-900 mb-1">
            {{ title }}
          </div>
          <div class="text-sm text-gray-600 break-words">
            {{ message }}
          </div>
          <div
            v-if="showDetails && details"
            class="mt-2 p-2 bg-gray-50 rounded-lg text-xs font-mono text-gray-700 max-h-32 overflow-auto"
          >
            {{ details }}
          </div>
        </div>
        <button
          @click="close"
          class="flex-shrink-0 text-gray-400 hover:text-gray-600 transition-colors"
        >
          <Icon icon="mdi:close" class="w-4 h-4" />
        </button>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
import { Icon } from '@iconify/vue'
import { ref, watch, onMounted, onUnmounted } from 'vue'

interface ToastProps {
  type?: 'success' | 'error' | 'warning' | 'info'
  title?: string
  message: string
  details?: string
  duration?: number
  showDetails?: boolean
}

const props = withDefaults(defineProps<ToastProps>(), {
  type: 'info',
  title: '',
  message: '',
  details: '',
  duration: 5000,
  showDetails: false
})

const emit = defineEmits<{
  close: []
}>()

const visible = ref(true)
let timeoutId: number | null = null

const iconName = ref('')
const toastClass = ref('')
const iconClass = ref('')

const updateStyles = () => {
  switch (props.type) {
    case 'success':
      iconName.value = 'mdi:check-circle'
      toastClass.value = 'border-l-4 border-l-green-500'
      iconClass.value = 'text-green-500'
      if (!props.title) {
        toastClass.value += ' text-green-700'
      }
      break
    case 'error':
      iconName.value = 'mdi:alert-circle'
      toastClass.value = 'border-l-4 border-l-red-500'
      iconClass.value = 'text-red-500'
      if (!props.title) {
        toastClass.value += ' text-red-700'
      }
      break
    case 'warning':
      iconName.value = 'mdi:alert'
      toastClass.value = 'border-l-4 border-l-yellow-500'
      iconClass.value = 'text-yellow-500'
      if (!props.title) {
        toastClass.value += ' text-yellow-700'
      }
      break
    case 'info':
    default:
      iconName.value = 'mdi:information'
      toastClass.value = 'border-l-4 border-l-blue-500'
      iconClass.value = 'text-blue-500'
      if (!props.title) {
        toastClass.value += ' text-blue-700'
      }
      break
  }
}

const close = () => {
  visible.value = false
  emit('close')
}

watch(() => props.type, updateStyles, { immediate: true })

onMounted(() => {
  if (props.duration > 0) {
    timeoutId = window.setTimeout(() => {
      close()
    }, props.duration)
  }
})

onUnmounted(() => {
  if (timeoutId) {
    clearTimeout(timeoutId)
  }
})
</script>

<style scoped>
.toast-enter-active,
.toast-leave-active {
  transition: all 0.3s ease;
}

.toast-enter-from {
  opacity: 0;
  transform: translateX(100%);
}

.toast-leave-to {
  opacity: 0;
  transform: translateX(100%);
}
</style>
