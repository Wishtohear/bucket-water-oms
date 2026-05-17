// 存储工具类
const PREFIX = 'bucket_water_'

export const storage = {
  set(key: string, value: any): void {
    try {
      const data = JSON.stringify(value)
      uni.setStorageSync(PREFIX + key, data)
    } catch (e) {
      console.error('Storage set error:', e)
    }
  },

  get<T = any>(key: string, defaultValue?: T): T | null {
    try {
      const data = uni.getStorageSync(PREFIX + key)
      if (data) {
        return JSON.parse(data) as T
      }
      return defaultValue ?? null
    } catch (e) {
      console.error('Storage get error:', e)
      return defaultValue ?? null
    }
  },

  remove(key: string): void {
    try {
      uni.removeStorageSync(PREFIX + key)
    } catch (e) {
      console.error('Storage remove error:', e)
    }
  },

  clear(): void {
    try {
      uni.clearStorageSync()
    } catch (e) {
      console.error('Storage clear error:', e)
    }
  },

  setToken(token: string): void {
    this.set('token', token)
  },

  getToken(): string | null {
    return this.get<string>('token')
  },

  removeToken(): void {
    this.remove('token')
  },

  setUserInfo(userInfo: any): void {
    this.set('userInfo', userInfo)
  },

  getUserInfo<T = any>(): T | null {
    return this.get<T>('userInfo')
  },

  removeUserInfo(): void {
    this.remove('userInfo')
  },

  setRefreshToken(refreshToken: string): void {
    this.set('refreshToken', refreshToken)
  },

  getRefreshToken(): string | null {
    return this.get<string>('refreshToken')
  },

  removeRefreshToken(): void {
    this.remove('refreshToken')
  }
}
