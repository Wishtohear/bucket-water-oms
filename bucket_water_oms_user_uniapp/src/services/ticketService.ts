// 水票服务
import { get, post } from '@/utils/request'

export interface UserTicket {
  id: string
  stationId: string
  stationName: string
  productId: string
  productName: string
  ticketName: string
  bucketCount: number
  usedBucketCount: number
  remainingBucketCount: number
  purchaseDate: string
  expireDate: string
  status: 'available' | 'used' | 'expired'
}

export interface WaterTicket {
  id: string
  stationId: string
  stationName: string
  productId: string
  productName: string
  productSpec?: string
  ticketName: string
  faceValue: number
  bucketCount: number
  remainingBucketCount: number
  price: number
  originalPrice: number
  discount: number
  validityDays: number
  stock: number
  purchaseDate: string
  expireDate: string
  status: 'active' | 'inactive' | 'sold_out' | 'available' | 'used' | 'expired'
}

export interface TicketUsageRecord {
  id: string
  orderId: string
  stationId: string
  stationName: string
  productName: string
  usedBucketCount: number
  usedAt: string
  orderNo: string
}

export interface PageResult<T> {
  list: T[]
  total: number
  page: number
  pageSize: number
}

export interface TicketPackage {
  id: string
  stationId: string
  stationName: string
  productId: string
  productName: string
  productSpec?: string
  ticketName: string
  bucketCount: number
  faceValue: number
  price: number
  originalPrice: number
  discount: number
  validityDays: number
  stock: number
  status: 'active' | 'inactive' | 'sold_out'
}

export interface BuyTicketRequest {
  ticketPackageId: string
  count: number
  amount: number
  expireDate: string
}

export const ticketService = {
  async getTickets(params?: { status?: string; page?: number; pageSize?: number }) {
    return get<WaterTicket[] | PageResult<WaterTicket>>('/tickets', params)
  },

  async getTicketStats() {
    return get<{ total: number; used: number; remaining: number; expired: number }>('/tickets/stats')
  },

  async getMyTickets(params?: { status?: string; page?: number; pageSize?: number }) {
    return get<PageResult<UserTicket> | UserTicket[]>('/tickets/holdings', params)
  },

  async getValidTickets() {
    return get<WaterTicket[]>('/tickets/valid')
  },

  async getUsageRecords(params?: { page?: number; pageSize?: number }) {
    return get<TicketUsageRecord[] | PageResult<TicketUsageRecord>>('/tickets/transactions', params)
  },

  async buyTicket(data: BuyTicketRequest) {
    return post<WaterTicket>('/tickets/purchase', data, {
      loading: true,
      loadingText: '购买中...',
      header: { 'Content-Type': 'application/x-www-form-urlencoded' }
    })
  },

  async getRemainingTickets() {
    return get<number>('/tickets/remaining')
  }
}
