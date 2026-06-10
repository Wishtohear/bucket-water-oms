import request from '@/utils/request'

export interface LoginRequest {
  phone: string
  password: string
  role?: string
}

export interface LoginResponse {
  token: string
  refreshToken: string
  userId: string
  username: string
  userType: string
}

export const authApi = {
  login(data: LoginRequest) {
    return request.post<any, any>('/auth/login', data)
  },

  refreshToken(authorization: string) {
    return request.post<any, any>('/auth/refresh', null, {
      headers: {
        Authorization: authorization
      }
    })
  },

  sendSmsCode(phone: string) {
    return request.post<any, any>('/auth/sms-code', { phone })
  },

  loginBySmsCode(phone: string, code: string, role?: string) {
    return request.post<any, any>('/auth/login-by-sms', null, {
      params: { phone, code, role: role || 'admin' }
    })
  },

  resetPassword(phone: string, code: string, newPassword: string) {
    return request.post<any, any>('/auth/reset-password', null, {
      params: { phone, code, newPassword }
    })
  },

  sendResetCode(phone: string) {
    return request.post<any, any>('/auth/sms-code', { phone, type: 'reset' })
  }
}
