// 水站配送订单服务
import { get, post, put } from '@/utils/request'

export interface StationOrder {
  id: string
  orderNo: string
  stationId: string
  stationName: string
  status: string
  totalAmount: number
  payAmount: number
  freight: number
  payMethod: string
  items: OrderItem[]
  address: Address
  remark?: string
  createdAt: string
  payTime?: string
  dispatchTime?: string
  acceptTime?: string
  startTime?: string
  completeTime?: string
  deliveryPerson?: DeliveryPerson
}

export interface OrderItem {
  id: string
  productId: string
  productName: string
  price: number
  quantity: number
  subtotal: number
}

export interface Address {
  id: string
  contactName: string
  contactPhone: string
  province: string
  city: string
  district: string
  detail: string
  latitude?: number
  longitude?: number
  isDefault: boolean
  label?: string
}

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

export interface PageResult<T> {
  list: T[]
  total: number
  page: number
  pageSize: number
}

export const stationOrderService = {
  // 获取水站订单列表（包含所有状态）
  async getStationOrders(params: {
    status?: string
    page?: number
    pageSize?: number
  }) {
    return get<PageResult<StationOrder>>('/station/orders', params)
  },

  // 获取水站待派单订单列表
  async getPendingDispatchOrders() {
    return get<StationOrder[]>('/station/orders/pending-dispatch')
  },

  // 获取用户订单列表
  async getOrders(params: {
    status?: string
    page?: number
    pageSize?: number
  }) {
    return get<PageResult<StationOrder>>('/station-orders', params)
  },

  // 获取订单详情
  async getOrderDetail(orderId: string) {
    return get<StationOrder>(`/station-orders/${orderId}`)
  },

  // 确认收货
  async confirmReceive(orderId: string) {
    return put(`/station-orders/${orderId}/complete`)
  },

  // 获取配送进度
  async getDeliveryTrack(orderId: string) {
    return get<any>(`/station-orders/${orderId}/track`)
  },

  // 派单
  async dispatch(orderId: string, deliveryPersonId: string) {
    return put(`/station/orders/${orderId}/dispatch`, { deliveryPersonId })
  },

  // 获取配送员列表
  async getDeliveryPersons(params?: { status?: string }) {
    return get<DeliveryPerson[]>(`/station/delivery-persons`, params)
  },

  // 创建配送员
  async createDeliveryPerson(data: {
    name: string
    phone: string
    idCard?: string
  }) {
    return post<DeliveryPerson>('/station/delivery-persons', data)
  },

  // 更新配送员
  async updateDeliveryPerson(id: string, data: {
    name?: string
    phone?: string
    idCard?: string
    status?: string
  }) {
    return put<DeliveryPerson>(`/station/delivery-persons/${id}`, data)
  },

  // 删除配送员
  async deleteDeliveryPerson(id: string) {
    return put(`/station/delivery-persons/${id}/delete`)
  }
}
