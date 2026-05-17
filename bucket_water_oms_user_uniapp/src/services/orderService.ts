// 订单服务
import { get, post, put } from '@/utils/request'
import type { Address, OrderItem } from '@/types/order'

export interface CreateOrderParams {
  stationId: string
  addressId: string
  items: {
    productId: string
    quantity: number
  }[]
  remark?: string
  payMethod: 'wechat' | 'balance' | 'cod'
}

export interface Order {
  id: string
  orderNo: string
  stationId: string
  stationName: string
  userId: string
  status: string
  totalAmount: number
  payAmount: number
  freight: number
  addressId: string
  address: Address
  items: OrderItem[]
  remark?: string
  createdAt: string
  payTime?: string
  deliverTime?: string
  completeTime?: string
}

export interface PageResult<T> {
  list: T[]
  total: number
  page: number
  pageSize: number
}

export const orderService = {
  // 创建订单
  async createOrder(params: CreateOrderParams) {
    return post<{ orderId: string; orderNo: string; totalAmount: number }>('/orders', params)
  },

  // 获取订单列表
  async getOrders(params: {
    status?: string
    page?: number
    pageSize?: number
  }) {
    return get<PageResult<Order>>('/orders', params)
  },

  // 获取订单详情
  async getOrderDetail(orderId: string) {
    return get<Order>(`/orders/${orderId}`)
  },

  // 取消订单
  async cancelOrder(orderId: string) {
    return put(`/orders/${orderId}/cancel`)
  },

  // 确认收货
  async confirmOrder(orderId: string) {
    return put(`/orders/${orderId}/confirm`)
  },

  // 评价订单
  async evaluateOrder(orderId: string, data: {
    rating: number
    content?: string
    tags?: string[]
  }) {
    return post(`/orders/${orderId}/evaluate`, data)
  },

  // 催单
  async remindOrder(orderId: string) {
    return post(`/orders/${orderId}/remind`)
  },

  // 申请退款
  async refundOrder(orderId: string, reason: string) {
    return post(`/orders/${orderId}/refund`, { reason })
  }
}
