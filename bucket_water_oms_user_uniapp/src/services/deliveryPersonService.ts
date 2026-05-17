// 配送员服务
import { get, post, put } from '@/utils/request'

export interface DeliveryPerson {
  id: string
  stationId: string
  name: string
  phone: string
  avatar?: string
  status: string
  totalOrders: number
  todayOrders: number
  rating: number
}

export interface DeliveryStats {
  todayOrders: number
  monthOrders: number
  totalOrders: number
  totalIncome: number
}

export interface DeliveryTask {
  id: string
  orderNo: string
  stationId: string
  stationName: string
  status: string
  items: OrderItem[]
  address: Address
  remark?: string
  createdAt: string
  payTime?: string
  acceptTime?: string
  startTime?: string
  completeTime?: string
}

export interface OrderItem {
  id: string
  productId: string
  productName: string
  price: number
  quantity: number
  subtotal: number
  spec?: string
  image?: string
}

export interface Address {
  id: string
  contactName: string
  contactPhone: string
  province?: string
  city?: string
  district?: string
  detail: string
  latitude?: number
  longitude?: number
}

export const deliveryPersonService = {
  // 绑定配送员
  async bind(params: { phone: string; code?: string }) {
    return post<DeliveryPerson>('/station/delivery-persons/bind', params)
  },

  // 获取配送员信息
  async getInfo() {
    return get<DeliveryPerson>('/delivery-persons/info')
  },

  // 获取配送统计
  async getStats() {
    return get<DeliveryStats>('/delivery-persons/stats')
  },

  // 获取配送任务列表
  async getTasks(params?: { status?: string }) {
    return get('/delivery-persons/tasks', params)
  },

  // 获取配送任务详情
  async getTaskDetail(orderId: string) {
    return get<DeliveryTask>(`/delivery-persons/tasks/${orderId}`)
  },

  // 接单
  async acceptTask(orderId: string) {
    return put(`/delivery-persons/tasks/${orderId}/accept`)
  },

  // 开始配送
  async startDelivery(orderId: string) {
    return put(`/delivery-persons/tasks/${orderId}/start`)
  },

  // 完成配送
  async completeDelivery(orderId: string) {
    return put(`/delivery-persons/tasks/${orderId}/complete`)
  },

  // 上报位置
  async reportLocation(lat: number, lng: number) {
    return post('/delivery-persons/location', { latitude: lat, longitude: lng })
  }
}
