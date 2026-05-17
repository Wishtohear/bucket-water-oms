// 用户相关类型定义
export interface UserInfo {
  id: string
  phone: string
  nickname?: string
  avatar?: string
  gender?: string
}

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
  userInfo: UserInfo
}
