// 认证状态管理
import { defineStore } from 'pinia'
import { storage } from '@/utils/storage'
import { authService } from '@/services/authService'

interface UserInfo {
  id: string
  phone: string
  nickname?: string
  avatar?: string
}

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: '' as string,
    refreshToken: '' as string,
    userInfo: null as UserInfo | null,
    isLoggedIn: false
  }),

  getters: {
    hasLogin: (state) => !!state.token,
    getUserInfo: (state) => state.userInfo,
    getPhone: (state) => state.userInfo?.phone || ''
  },

  actions: {
    // 检查登录状态
    checkLoginStatus() {
      const token = storage.getToken()
      const userInfo = storage.getUserInfo<UserInfo>()
      const refreshToken = storage.getRefreshToken()

      if (token) {
        this.token = token
        this.refreshToken = refreshToken || ''
        this.userInfo = userInfo
        this.isLoggedIn = true
      } else {
        this.clearAuth()
      }
    },

    // 设置认证信息
    setAuth(token: string, refreshToken: string, userInfo: UserInfo) {
      this.token = token
      this.refreshToken = refreshToken
      this.userInfo = userInfo
      this.isLoggedIn = true

      storage.setToken(token)
      storage.setRefreshToken(refreshToken)
      storage.setUserInfo(userInfo)
    },

    // 更新用户信息
    updateUserInfo(userInfo: Partial<UserInfo>) {
      if (this.userInfo) {
        this.userInfo = { ...this.userInfo, ...userInfo }
        storage.setUserInfo(this.userInfo)
      }
    },

    // 清除认证信息
    clearAuth() {
      this.token = ''
      this.refreshToken = ''
      this.userInfo = null
      this.isLoggedIn = false

      storage.removeToken()
      storage.removeRefreshToken()
      storage.removeUserInfo()
    },

    // 登录
    async login(phone: string, password: string) {
      const result = await authService.login({ phone, password })
      if (result) {
        this.setAuth(result.token, result.refreshToken, result.userInfo)
        return true
      }
      return false
    },

    // 验证码登录
    async loginBySmsCode(phone: string, smsCode: string) {
      const result = await authService.loginBySmsCode(phone, smsCode)
      if (result) {
        this.setAuth(result.token, result.refreshToken, result.userInfo)
        return true
      }
      return false
    },

    // 注册
    async register(phone: string, password: string, smsCode: string) {
      const result = await authService.register({ phone, password, smsCode })
      if (result) {
        this.setAuth(result.token, result.refreshToken, result.userInfo)
        return true
      }
      return false
    },

    // 退出登录
    logout() {
      this.clearAuth()
      authService.logout()
    }
  }
})
