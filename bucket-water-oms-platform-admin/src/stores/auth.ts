import { defineStore } from 'pinia'
import { ref } from 'vue'

export interface PlatformAdmin {
  id: string
  username: string
  name: string
  phone: string
  email?: string
  role: string
  status: string
}

export const useAuthStore = defineStore('auth', () => {
  const token = ref(localStorage.getItem('platform_token') || '')
  const admin = ref<PlatformAdmin | null>(null)

  const setToken = (newToken: string) => {
    token.value = newToken
    localStorage.setItem('platform_token', newToken)
  }

  const setAdmin = (adminInfo: PlatformAdmin) => {
    admin.value = adminInfo
  }

  const logout = () => {
    token.value = ''
    admin.value = null
    localStorage.removeItem('platform_token')
  }

  const isLoggedIn = () => {
    return !!token.value
  }

  return {
    token,
    admin,
    setToken,
    setAdmin,
    logout,
    isLoggedIn
  }
})
