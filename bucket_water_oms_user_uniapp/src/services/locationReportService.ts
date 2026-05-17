// 位置上报服务
import { getCurrentLocation } from '@/utils/location'
import { deliveryPersonService } from './deliveryPersonService'

export interface LocationReportOptions {
  interval?: number // 上报间隔（毫秒），默认 30 秒
  onSuccess?: (latitude: number, longitude: number) => void
  onError?: (error: any) => void
}

class LocationReportService {
  private timerId: ReturnType<typeof setInterval> | null = null
  private isReporting = false
  private options: LocationReportOptions = {}

  start(options: LocationReportOptions = {}) {
    if (this.isReporting) {
      console.log('位置上报已在运行中')
      return
    }

    this.options = {
      interval: 30000, // 30 秒
      ...options
    }

    this.isReporting = true
    console.log('开始位置上报服务')

    // 立即上报一次
    this.report()

    // 设置定时上报
    this.timerId = setInterval(() => {
      this.report()
    }, this.options.interval)
  }

  stop() {
    if (this.timerId) {
      clearInterval(this.timerId)
      this.timerId = null
    }
    this.isReporting = false
    console.log('停止位置上报服务')
  }

  async report() {
    try {
      const location = await getCurrentLocation()
      await deliveryPersonService.reportLocation(
        location.latitude,
        location.longitude
      )
      
      console.log('位置上报成功:', location.latitude, location.longitude)
      
      if (this.options.onSuccess) {
        this.options.onSuccess(location.latitude, location.longitude)
      }
    } catch (error) {
      console.error('位置上报失败:', error)
      
      if (this.options.onError) {
        this.options.onError(error)
      }
    }
  }

  async getCurrentPosition() {
    try {
      const location = await getCurrentLocation()
      return {
        latitude: location.latitude,
        longitude: location.longitude,
        success: true
      }
    } catch (error) {
      console.error('获取当前位置失败:', error)
      return {
        latitude: 0,
        longitude: 0,
        success: false,
        error
      }
    }
  }

  getStatus() {
    return {
      isReporting: this.isReporting,
      interval: this.options.interval
    }
  }
}

export const locationReportService = new LocationReportService()
