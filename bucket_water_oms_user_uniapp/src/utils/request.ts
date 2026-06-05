// API 配置 - 通过环境变量切换 baseURL
// 开发环境: http://localhost:8080/api
// 生产环境: 由运维配置 VITE_API_BASE_URL
declare const process: { env: Record<string, string | undefined> }

const detectBaseUrl = (): string => {
  try {
    if (typeof process !== 'undefined' && process.env && process.env.VITE_API_BASE_URL) {
      return process.env.VITE_API_BASE_URL as string
    }
  } catch (_) { /* ignore */ }
  try {
    // @ts-ignore uni global
    if (typeof uni !== 'undefined' && (uni as any).getStorageSync) {
      const custom = uni.getStorageSync('api_base_url')
      if (custom) return custom as string
    }
  } catch (_) { /* ignore */ }
  // #ifdef H5
  return (window as any).__API_BASE_URL__ || 'http://localhost:8080/api'
  // #endif
  // #ifndef H5
  return 'http://localhost:8080/api'
  // #endif
}

export const BASE_URL = detectBaseUrl()

const TIMEOUT = 10000

let isRefreshing = false
let refreshSubscribers: Array<(token: string) => void> = []

const subscribeTokenRefresh = (cb: (token: string) => void) => {
  refreshSubscribers.push(cb)
}

const onTokenRefreshed = (token: string) => {
  refreshSubscribers.forEach(cb => cb(token))
  refreshSubscribers = []
}

interface RequestOptions {
  url: string
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE'
  data?: any
  header?: Record<string, string>
  loading?: boolean
  loadingText?: string
}

interface RequestResult {
  statusCode: number
  data: any
  header: any
}

export const request = <T = any>(options: RequestOptions): Promise<T> => {
  return new Promise(async (resolve, reject) => {
    const { url, method = 'GET', data, header = {}, loading = true, loadingText = '加载中...' } = options

    if (loading) {
      uni.showLoading({ title: loadingText, mask: true })
    }

    const token = uni.getStorageSync('bucket_water_token')
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      ...header
    }

    if (token) {
      headers['Authorization'] = `Bearer ${token}`
    }

    try {
      const result: RequestResult = await uni.request({
        url: BASE_URL + url,
        method,
        data,
        header: headers,
        timeout: TIMEOUT
      })

      if (loading) {
        uni.hideLoading()
      }

      if (result.statusCode === 200) {
        const responseData = result.data as any

        if (responseData.success) {
          resolve(responseData.data as T)
        } else {
          uni.showToast({
            title: responseData.message || '请求失败',
            icon: 'none'
          })
          reject(responseData)
        }
      } else if (result.statusCode === 401) {
        if (!isRefreshing && !url.includes('/auth/')) {
          isRefreshing = true
          try {
            const refreshToken = uni.getStorageSync('bucket_water_refreshToken')
            if (refreshToken) {
              const refreshResult = await uni.request({
                url: BASE_URL + '/auth/refresh',
                method: 'POST',
                data: { refreshToken },
                header: { 'Content-Type': 'application/json' }
              })

              if (refreshResult.statusCode === 200) {
                const refreshData = refreshResult.data as any
                if (refreshData.success) {
                  const newToken = refreshData.data.token
                  uni.setStorageSync('bucket_water_token', newToken)
                  onTokenRefreshed(newToken)
                  isRefreshing = false

                  const retryResult = await uni.request({
                    url: BASE_URL + url,
                    method,
                    data,
                    header: { ...headers, 'Authorization': `Bearer ${newToken}` },
                    timeout: TIMEOUT
                  })

                  if (retryResult.statusCode === 200) {
                    resolve(retryResult.data as T)
                  } else {
                    handleAuthError()
                    reject(retryResult)
                  }
                } else {
                  handleAuthError()
                  reject(refreshData)
                }
              } else {
                handleAuthError()
                reject(refreshResult)
              }
            } else {
              handleAuthError()
              reject(new Error('No refresh token'))
            }
          } catch (error) {
            isRefreshing = false
            handleAuthError()
            reject(error)
          }
        } else {
          return new Promise((resolve) => {
            subscribeTokenRefresh(async (token) => {
              const retryResult = await uni.request({
                url: BASE_URL + url,
                method,
                data,
                header: { ...headers, 'Authorization': `Bearer ${token}` },
                timeout: TIMEOUT
              })
              resolve(retryResult.data)
            })
          }).then(resolve).catch(reject)
        }
      } else if (result.statusCode >= 500) {
        uni.showToast({
          title: '服务器错误，请稍后重试',
          icon: 'none'
        })
        reject(new Error('Server error'))
      } else {
        uni.showToast({
          title: result.data?.message || '请求失败',
          icon: 'none'
        })
        reject(result.data)
      }
    } catch (error: any) {
      if (loading) {
        uni.hideLoading()
      }

      if (error.errMsg?.includes('request:fail')) {
        uni.showToast({
          title: '网络连接失败，请检查网络',
          icon: 'none'
        })
      }

      reject(error)
    }
  })
}

const handleAuthError = () => {
  uni.removeStorageSync('bucket_water_token')
  uni.removeStorageSync('bucket_water_refreshToken')
  uni.removeStorageSync('bucket_water_userInfo')

  uni.showToast({
    title: '登录已过期，请重新登录',
    icon: 'none'
  })

  setTimeout(() => {
    uni.navigateTo({
      url: '/pages-auth/login'
    })
  }, 1500)
}

export const get = <T = any>(url: string, data?: any, options?: Partial<RequestOptions>): Promise<T> => {
  return request({
    url,
    method: 'GET',
    data,
    ...options
  })
}

export const post = <T = any>(url: string, data?: any, options?: Partial<RequestOptions>): Promise<T> => {
  return request({
    url,
    method: 'POST',
    data,
    ...options
  })
}

export const put = <T = any>(url: string, data?: any, options?: Partial<RequestOptions>): Promise<T> => {
  return request({
    url,
    method: 'PUT',
    data,
    ...options
  })
}

export const del = <T = any>(url: string, data?: any, options?: Partial<RequestOptions>): Promise<T> => {
  return request({
    url,
    method: 'DELETE',
    data,
    ...options
  })
}
