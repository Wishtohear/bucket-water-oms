import { ref } from 'vue'
import Toast from '@/components/Toast.vue'
import { h, render } from 'vue'

interface ToastOptions {
  type?: 'success' | 'error' | 'warning' | 'info'
  title?: string
  message: string
  details?: string
  duration?: number
  showDetails?: boolean
}

const toastContainer = ref<HTMLElement | null>(null)

const initContainer = () => {
  if (!toastContainer.value) {
    toastContainer.value = document.createElement('div')
    document.body.appendChild(toastContainer.value)
  }
}

const showToast = (options: ToastOptions) => {
  initContainer()

  if (!toastContainer.value) {
    console.error('Toast container not initialized')
    return
  }

  const {
    type = 'info',
    title = '',
    message,
    details = '',
    duration = 5000,
    showDetails = false
  } = options

  const vnode = h(Toast, {
    type,
    title,
    message,
    details,
    duration,
    showDetails,
    onClose: () => {
      if (vnode.el && vnode.el.parentNode) {
        vnode.el.parentNode.removeChild(vnode.el)
      }
    }
  })

  render(vnode, toastContainer.value)
}

export const toast = {
  success: (message: string, options?: Partial<ToastOptions>) => {
    showToast({ type: 'success', message, ...options })
  },
  error: (message: string, options?: Partial<ToastOptions>) => {
    showToast({ type: 'error', message, ...options })
  },
  warning: (message: string, options?: Partial<ToastOptions>) => {
    showToast({ type: 'warning', message, ...options })
  },
  info: (message: string, options?: Partial<ToastOptions>) => {
    showToast({ type: 'info', message, ...options })
  },
  show: (options: ToastOptions) => {
    showToast(options)
  }
}

export default toast
