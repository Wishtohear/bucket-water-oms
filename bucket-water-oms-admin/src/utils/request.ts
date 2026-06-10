import axios from 'axios'
import type { AxiosInstance, AxiosRequestConfig, AxiosResponse, AxiosError } from 'axios'
import { toast } from '@/composables/useToast'

const baseURL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080/api'

const DEBUG_MODE = true

const instance: AxiosInstance = axios.create({
  baseURL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json'
  }
})

let isRefreshing = false
let refreshSubscribers: Array<(token: string) => void> = []

const subscribeTokenRefresh = (callback: (token: string) => void) => {
  refreshSubscribers.push(callback)
}

const onTokenRefreshed = (token: string) => {
  refreshSubscribers.forEach(callback => callback(token))
  refreshSubscribers = []
}

const getRefreshToken = (): string | null => {
  return localStorage.getItem('refreshToken')
}

const saveToken = (accessToken: string, refreshToken: string) => {
  localStorage.setItem('token', accessToken)
  localStorage.setItem('refreshToken', refreshToken)
}

const clearToken = () => {
  localStorage.removeItem('token')
  localStorage.removeItem('refreshToken')
}

const refreshToken = async (): Promise<string> => {
  const refreshToken = getRefreshToken()
  if (!refreshToken) {
    throw new Error('No refresh token')
  }

  const response = await axios.post(`${baseURL}/auth/refresh`, null, {
    headers: {
      Authorization: `Bearer ${refreshToken}`
    }
  })

  if (response.data?.success && response.data?.data) {
    const { token, refreshToken: newRefreshToken } = response.data.data
    saveToken(token, newRefreshToken)
    return token
  }

  throw new Error('Token refresh failed')
}

instance.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token')
    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`
    }
    
    const warehouseId = localStorage.getItem('warehouseId')
    if (warehouseId && config.headers) {
      config.headers['X-Warehouse-Id'] = warehouseId
    }
    
    const stationId = localStorage.getItem('stationId')
    if (stationId && config.headers) {
      config.headers['X-Station-Id'] = stationId
    }
    
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

instance.interceptors.response.use(
  (response: AxiosResponse) => {
    const requestUrl = response.config.url || 'unknown'
    const method = response.config.method?.toUpperCase() || 'GET'

    if (response.config.responseType === 'blob') {
      return response
    }

    const res = response.data

    const isBusinessSuccess = res && typeof res === 'object' && (
      res.success === true ||
      res.success === false ||
      res.code === 200 ||
      res.code === 0
    )

    if (isBusinessSuccess) {
      if (res.success === true) {
        if (DEBUG_MODE) {
          const successMsg = `${method} ${requestUrl} 成功`
          let details = ''

          if (res.code !== undefined) {
            details += `响应码: ${res.code}\n`
          }
          if (res.message) {
            details += `消息: ${res.message}\n`
          }
          if (res.data !== undefined) {
            const dataPreview = JSON.stringify(res.data, null, 2)
            details += `数据预览: ${dataPreview.substring(0, 500)}${dataPreview.length > 500 ? '...' : ''}`
          }

          toast.show({
            type: 'success',
            title: successMsg,
            message: res?.message || '请求成功',
            details: details,
            duration: 3000,
            showDetails: true
          })

          console.log(`✅ ${successMsg}`, res)
        }
        return res
      } else if (res.success === false) {
        const failMsg = `${method} ${requestUrl} 失败`
        const errorMsg = res?.message || '操作失败'
        let details = ''

        if (res.code !== undefined) {
          details += `错误码: ${res.code}\n`
        }
        if (res.message) {
          details += `消息: ${res.message}\n`
        }

        toast.show({
          type: 'error',
          title: `❌ ${failMsg}`,
          message: errorMsg,
          details: details,
          duration: 8000,
          showDetails: true
        })

        console.error(`❌ ${failMsg}`, res)
        return Promise.reject(new Error(errorMsg))
      } else {
        if (DEBUG_MODE) {
          const successMsg = `${method} ${requestUrl} 成功`
          toast.show({
            type: 'success',
            title: successMsg,
            message: res?.message || '请求成功',
            details: `响应码: ${res.code}`,
            duration: 3000,
            showDetails: false
          })
          console.log(`✅ ${successMsg}`, res)
        }
        return res
      }
    }

    return res
  },
  (error: AxiosError) => {
    const originalRequest = error.config as AxiosRequestConfig & { retryCount?: number }
    const requestUrl = error.config?.url || error.request?.responseURL || 'unknown'
    const method = error.config?.method?.toUpperCase() || 'GET'
    let errorMsg = '请求失败'
    let errorDetails = ''

    if (error.response) {
      const status = error.response.status
      switch (status) {
        case 400:
          errorMsg = '请求参数错误'
          break
        case 401:
          errorMsg = '登录已过期'
          if (!isRefreshing && originalRequest) {
            if (!originalRequest._retry) {
              originalRequest._retry = true
              if (!isRefreshing) {
                isRefreshing = true
                return refreshToken()
                  .then(token => {
                    isRefreshing = false
                    onTokenRefreshed(token)
                    if (originalRequest.headers) {
                      originalRequest.headers.Authorization = `Bearer ${token}`
                    }
                    return instance(originalRequest)
                  })
                  .catch(() => {
                    isRefreshing = false
                    clearToken()
                    window.location.href = '/login'
                    return Promise.reject(error)
                  })
              }
              return new Promise(resolve => {
                subscribeTokenRefresh((token: string) => {
                  if (originalRequest.headers) {
                    originalRequest.headers.Authorization = `Bearer ${token}`
                  }
                  resolve(instance(originalRequest))
                })
              })
            }
          }
          clearToken()
          window.location.href = '/login'
          break
        case 403:
          errorMsg = '没有权限访问'
          break
        case 404:
          errorMsg = '请求资源不存在'
          break
        case 500:
          errorMsg = '服务器错误'
          break
        default:
          errorMsg = `请求失败 (HTTP ${status})`
      }

      if (error.response.data) {
        const responseData = error.response.data
        if (typeof responseData === 'object') {
          if (responseData.message) {
            errorMsg = responseData.message
          }
          if (responseData.error) {
            errorDetails = responseData.error
          }
          if (responseData.details) {
            errorDetails = responseData.details
          }
          if (DEBUG_MODE) {
            errorDetails += `\n\n完整响应: ${JSON.stringify(responseData, null, 2)}`
          }
        } else if (typeof responseData === 'string') {
          errorDetails = responseData
        }
      }

      errorDetails += `\n\n状态码: ${status}\n请求方法: ${method}\n请求地址: ${requestUrl}`
    } else if (error.code === 'ECONNABORTED') {
      errorMsg = '请求超时'
      errorDetails = `请求 ${method} ${requestUrl} 超时（超过30秒）`
    } else if (error.request) {
      errorMsg = '网络连接失败'
      errorDetails = `无法连接到服务器\n\n请求地址: ${requestUrl}\n请检查网络连接或服务器是否运行`
    } else {
      errorMsg = '请求配置错误'
      errorDetails = error.message || '未知错误'
    }

    if (DEBUG_MODE) {
      toast.show({
        type: 'error',
        title: `❌ ${method} ${requestUrl}`,
        message: errorMsg,
        details: errorDetails.trim(),
        duration: 8000,
        showDetails: true
      })

      console.error(`❌ ${method} ${requestUrl} 失败:`, {
        message: errorMsg,
        details: errorDetails,
        response: error.response?.data,
        status: error.response?.status
      })
    } else {
      toast.error(errorMsg)
    }

    return Promise.reject(error)
  }
)

export default instance

export const createApi = <T = any>(config: AxiosRequestConfig): Promise<T> => {
  return instance(config)
}

export { refreshToken, saveToken, clearToken, getRefreshToken }
