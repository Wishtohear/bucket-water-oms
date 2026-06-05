// 认证服务
import { get, post, put } from '@/utils/request'
import { storage } from '@/utils/storage'

export interface LoginParams {
  phone: string
  password: string
}

export interface RegisterParams {
  phone: string
  password: string
  smsCode: string
}

export interface LoginResult {
  userId: string
  token: string
  refreshToken: string
  userInfo: {
    id: string
    phone: string
    nickname?: string
    avatar?: string
  }
}

export const authService = {
  // 手机号密码登录
  async login(params: LoginParams) {
    const result = await post<LoginResult>('/auth/login', params)
    if (result) {
      storage.setToken(result.token)
      storage.setRefreshToken(result.refreshToken)
      storage.setUserInfo(result.userInfo)
    }
    return result
  },

  // 验证码登录
  async loginBySmsCode(phone: string, smsCode: string) {
    const result = await post<LoginResult>('/auth/loginBySmsCode', { phone, smsCode })
    if (result) {
      storage.setToken(result.token)
      storage.setRefreshToken(result.refreshToken)
      storage.setUserInfo(result.userInfo)
    }
    return result
  },

  // 注册
  async register(params: RegisterParams) {
    const result = await post<LoginResult>('/auth/register', params)
    if (result) {
      storage.setToken(result.token)
      storage.setRefreshToken(result.refreshToken)
      storage.setUserInfo(result.userInfo)
    }
    return result
  },

  // 发送验证码
  async sendSmsCode(phone: string, type: 'login' | 'register' | 'reset') {
    return post('/auth/sms/send', { phone, type })
  },

  // 刷新 Token
  async refreshToken(refreshToken: string) {
    return post<{ token: string }>('/auth/refresh', { refreshToken })
  },

  // 忘记密码
  async resetPassword(phone: string, smsCode: string, newPassword: string) {
    return post('/auth/resetPassword', { phone, smsCode, newPassword })
  },

  // 获取当前用户信息
  async getUserInfo() {
    return get('/users/info')
  },

  // 更新用户信息
  async updateUserInfo(data: { nickname?: string; avatar?: string }) {
    return put('/users/info', data)
  },

  // 退出登录
  logout() {
    storage.removeToken()
    storage.removeRefreshToken()
    storage.removeUserInfo()
  },

  // 微信小程序登录（用 code 换 token）
  async wechatLogin(code: string) {
    const result = await post<LoginResult>('/auth/wechat-login', { code })
    if (result) {
      storage.setToken(result.token)
      storage.setRefreshToken(result.refreshToken)
      storage.setUserInfo(result.userInfo)
    }
    return result
  }
}
