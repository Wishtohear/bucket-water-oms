import { defineStore } from 'pinia'
import { ref } from 'vue'
import { reportsApi, type SalesTrend } from '@/api/reports'

export interface DashboardStats {
  todaySales: number
  todayOrders: number
  activeStations: number
  lowStockItems: number
  alerts: number
  salesGrowth: number
  ordersGrowth: number
}

export interface RecentOrder {
  id: string
  stationName: string
  amount: number
  time: string
  status: string
}

export interface Notification {
  type: 'error' | 'info' | 'warning'
  title: string
  time: string
}

export const useDashboardStore = defineStore('dashboard', () => {
  const stats = ref<DashboardStats>({
    todaySales: 0,
    todayOrders: 0,
    activeStations: 0,
    lowStockItems: 0,
    alerts: 0,
    salesGrowth: 0,
    ordersGrowth: 0
  })

  const salesTrend = ref<SalesTrend[]>([])
  const recentOrders = ref<RecentOrder[]>([])
  const notifications = ref<Notification[]>([])
  const loading = ref(false)

  const fetchDashboardStats = async () => {
    loading.value = true
    try {
      const res: any = await reportsApi.getDashboardStats()
      if (res.data) {
        stats.value = {
          todaySales: res.data.totalSales || 0,
          todayOrders: res.data.totalOrders || 0,
          activeStations: res.data.activeStations || 0,
          lowStockItems: res.data.inventoryAlerts || 0,
          alerts: res.data.alertCount || 0,
          salesGrowth: res.data.salesGrowth || 0,
          ordersGrowth: res.data.ordersGrowth || 0
        }
        salesTrend.value = res.data.salesTrend || []
        recentOrders.value = res.data.recentOrders || []
      }
    } catch (error) {
      console.error('获取仪表盘数据失败:', error)
    } finally {
      loading.value = false
    }
  }

  const fetchNotifications = async () => {
    try {
      const res: any = await reportsApi.getDailySales()
      if (res.data && res.data.notifications) {
        notifications.value = res.data.notifications
      }
    } catch (error) {
      console.error('获取通知失败:', error)
    }
  }

  return {
    stats,
    salesTrend,
    recentOrders,
    notifications,
    loading,
    fetchDashboardStats,
    fetchNotifications
  }
})
