// 位置上报 Hook
import { ref, onMounted, onUnmounted } from 'vue'
import { getCurrentLocation } from '@/utils/location'
import { deliveryPersonService } from '@/services/deliveryPersonService'

export interface LocationReportState {
  isReporting: boolean
  lastLocation: { latitude: number; longitude: number } | null
  lastReportTime: string | null
  error: string | null
}

const REPORT_INTERVAL = 30000 // 30秒上报一次

export const useLocationReport = () => {
  const state = ref<LocationReportState>({
    isReporting: false,
    lastLocation: null,
    lastReportTime: null,
    error: null
  })

  let timerId: ReturnType<typeof setInterval> | null = null

  const reportLocation = async () => {
    try {
      const location = await getCurrentLocation()
      await deliveryPersonService.reportLocation(
        location.latitude,
        location.longitude
      )
      
      state.value.lastLocation = {
        latitude: location.latitude,
        longitude: location.longitude
      }
      state.value.lastReportTime = new Date().toISOString()
      state.value.error = null
      
      console.log('位置上报成功:', location.latitude, location.longitude)
    } catch (error) {
      console.error('位置上报失败:', error)
      state.value.error = '位置上报失败'
    }
  }

  const startReporting = () => {
    if (state.value.isReporting) return
    
    state.value.isReporting = true
    
    // 立即上报一次
    reportLocation()
    
    // 设置定时上报
    timerId = setInterval(() => {
      reportLocation()
    }, REPORT_INTERVAL)
    
    console.log('开始位置上报')
  }

  const stopReporting = () => {
    if (timerId) {
      clearInterval(timerId)
      timerId = null
    }
    state.value.isReporting = false
    console.log('停止位置上报')
  }

  const getCurrentPosition = async () => {
    try {
      const location = await getCurrentLocation()
      state.value.lastLocation = {
        latitude: location.latitude,
        longitude: location.longitude
      }
      return location
    } catch (error) {
      console.error('获取位置失败:', error)
      state.value.error = '获取位置失败'
      return null
    }
  }

  onUnmounted(() => {
    stopReporting()
  })

  return {
    state,
    startReporting,
    stopReporting,
    reportLocation,
    getCurrentPosition
  }
}
