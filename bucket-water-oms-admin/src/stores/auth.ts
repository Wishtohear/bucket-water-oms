import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { authApi, type LoginRequest } from '@/api/auth'
import { analyzeResponse } from '@/utils/debug'

export type UserRole = 'FACTORY_ADMIN' | 'WAREHOUSE_ADMIN' | 'DRIVER' | 'STATION_OWNER' | 'STATION_CLERK'

function normalizeRole(role: string): string {
  const roleMap: Record<string, string> = {
    'admin': 'FACTORY_ADMIN',
    'factory_admin': 'FACTORY_ADMIN',
    'factoryadmin': 'FACTORY_ADMIN',
    'FACTORY_ADMIN': 'FACTORY_ADMIN',
    'warehouse_admin': 'WAREHOUSE_ADMIN',
    'warehouseadmin': 'WAREHOUSE_ADMIN',
    'WAREHOUSE_ADMIN': 'WAREHOUSE_ADMIN',
    'warehouse': 'WAREHOUSE_ADMIN',
    'driver': 'DRIVER',
    'DRIVER': 'DRIVER',
    'station_owner': 'STATION_OWNER',
    'stationowner': 'STATION_OWNER',
    'station': 'STATION_OWNER',
    'STATION_OWNER': 'STATION_OWNER',
    'station_clerk': 'STATION_CLERK',
    'stationclerk': 'STATION_CLERK',
    'STATION_CLERK': 'STATION_CLERK'
  }
  const normalized = roleMap[role.toLowerCase()]
  return normalized || role
}

export interface UserInfo {
  userId: string
  username: string
  userType: string
  name?: string
  role?: UserRole
  warehouseId?: string
  warehouseName?: string
}

export const useAuthStore = defineStore('auth', () => {
  const token = ref<string | null>(localStorage.getItem('token'))
  const userInfo = ref<UserInfo | null>(null)

  const isAuthenticated = computed(() => !!token.value)

  const login = async (data: LoginRequest): Promise<{ success: boolean; message?: string }> => {
    try {
      const response = await authApi.login(data)
      console.log('登录响应数据:', JSON.stringify(response, null, 2))

      const analysis = analyzeResponse(response)
      console.log('响应分析:', analysis)

      const isSuccess = response.code === 200 || response.code === 0 || response.success === true || response.status === 'success' || !!analysis.tokenValue

      if (isSuccess) {
        // 保存 token 到 localStorage
        const tokenValue = analysis.tokenValue

        if (!tokenValue) {
          console.error('Token获取失败，响应数据:', response)
          return { success: false, message: 'Token获取失败，请联系管理员' }
        }

        console.log('获取到的token:', tokenValue)
        token.value = tokenValue
        localStorage.setItem('token', tokenValue)

        // 获取用户信息（warehouseId 在 user 对象中）
        // 注意：后端返回的数据结构是 response.data.data.user
        const innerData = response.data?.data || response.data
        const userData = innerData?.user || innerData?.result?.user
        const warehouseId = innerData?.warehouseId || innerData?.user?.warehouseId || userData?.warehouseId
        const role = innerData?.role || innerData?.user?.role || userData?.role || data.role
        
        userInfo.value = {
          userId: innerData?.userId || innerData?.user?.id || userData?.id || innerData?.result?.userId,
          username: innerData?.username || innerData?.phone || userData?.phone || innerData?.result?.username || data.phone,
          userType: innerData?.userType || role,
          name: innerData?.name || userData?.name || innerData?.result?.name,
          role: role,
          warehouseId: warehouseId,
          warehouseName: innerData?.warehouseName || innerData?.warehouseName
        }
        // 保存 warehouseId 到 localStorage 供 API 请求使用
        if (warehouseId) {
          localStorage.setItem('warehouseId', String(warehouseId))
          console.log('仓库ID已保存:', warehouseId)
        } else {
          console.log('警告: 响应中没有仓库ID', response)
        }
        
        const stationId = innerData?.stationId || innerData?.user?.stationId || userData?.stationId
        if (stationId) {
          localStorage.setItem('stationId', String(stationId))
          console.log('水站ID已保存:', stationId)
        } else {
          console.log('警告: 响应中没有水站ID', response)
        }
        
        // 标准化角色信息并保存到 localStorage
        const rawRole = innerData?.role || innerData?.user?.role || userData?.role || innerData?.result?.role || data.role || 'admin'
        const userRole = normalizeRole(rawRole)
        localStorage.setItem('userRole', userRole)
        console.log('登录成功，isAuthenticated:', !!tokenValue, '，标准化角色:', userRole, '，仓库ID:', warehouseId)

        return { success: true }
      } else {
        return { success: false, message: response.message || response.msg || '登录失败' }
      }
    } catch (error: any) {
      console.error('登录错误:', error)
      return {
        success: false,
        message: error.response?.data?.message || error.message || '网络错误，请稍后重试'
      }
    }
  }

  const logout = () => {
    token.value = null
    userInfo.value = null
    localStorage.removeItem('token')
    localStorage.removeItem('userRole')
    localStorage.removeItem('stationId')
  }

  const setWarehouseId = (warehouseId: string) => {
    if (userInfo.value) {
      userInfo.value.warehouseId = warehouseId
    }
    localStorage.setItem('warehouseId', String(warehouseId))
  }

  const getUserRole = (): string => {
    const role = localStorage.getItem('userRole')
    return role ? normalizeRole(role) : 'FACTORY_ADMIN'
  }

  const isWarehouseAdmin = (): boolean => {
    return getUserRole() === 'WAREHOUSE_ADMIN'
  }

  const isFactoryAdmin = (): boolean => {
    return getUserRole() === 'FACTORY_ADMIN'
  }

  const getDefaultRoute = (): string => {
    const role = getUserRole()
    console.log('getDefaultRoute - 角色:', role)
    if (role === 'WAREHOUSE_ADMIN') {
      return '/warehouse/dashboard'
    } else if (role === 'STATION_OWNER') {
      return '/station/dashboard'
    }
    return '/dashboard'
  }

  const getLoginRoute = (): string => {
    const role = getUserRole()
    if (role === 'WAREHOUSE_ADMIN') {
      return '/login/warehouse'
    } else if (role === 'STATION_OWNER') {
      return '/login/station'
    }
    return '/login'
  }

  return {
    token,
    userInfo,
    isAuthenticated,
    login,
    logout,
    getUserRole,
    isWarehouseAdmin,
    isFactoryAdmin,
    getDefaultRoute,
    getLoginRoute,
    setWarehouseId
  }
})
