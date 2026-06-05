import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export interface PlatformAdmin {
  id: string | number
  username?: string
  name: string
  phone?: string
  email?: string
  role: string
  status?: string
}

const STORAGE_KEY = 'platform_token'
const ADMIN_KEY = 'platform_admin'

export const useAuthStore = defineStore('auth', () => {
  const token = ref<string>(localStorage.getItem(STORAGE_KEY) || '')
  const admin = ref<PlatformAdmin | null>(
    (() => {
      try {
        const raw = localStorage.getItem(ADMIN_KEY)
        return raw ? JSON.parse(raw) : null
      } catch {
        return null
      }
    })()
  )

  const isLoggedIn = computed(() => !!token.value)

  const setToken = (newToken: string) => {
    token.value = newToken
    localStorage.setItem(STORAGE_KEY, newToken)
  }

  const setAdmin = (adminInfo: PlatformAdmin | null) => {
    admin.value = adminInfo
    if (adminInfo) {
      localStorage.setItem(ADMIN_KEY, JSON.stringify(adminInfo))
    } else {
      localStorage.removeItem(ADMIN_KEY)
    }
  }

  const logout = () => {
    token.value = ''
    admin.value = null
    localStorage.removeItem(STORAGE_KEY)
    localStorage.removeItem(ADMIN_KEY)
  }

  return {
    token,
    admin,
    isLoggedIn,
    setToken,
    setAdmin,
    logout
  }
})
