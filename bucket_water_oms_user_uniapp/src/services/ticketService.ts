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
  price: number
  originalPrice: number
  discount: number
  validityDays: number
  stock: number
  status: 'active' | 'inactive' | 'sold_out'
}

export interface BuyTicketRequest {
  ticketPackageId: string
  quantity: number
  payMethod: 'wechat' | 'balance'
}

export const ticketService = {
  async getTicketPackages(stationId: string) {
    return get<TicketPackage[]>(`/stations/${stationId}/ticket-packages`)
  },

  async getTicketPackageDetail(packageId: string) {
    return get<TicketPackage>(`/ticket-packages/${packageId}`)
  },

  async buyTicket(data: BuyTicketRequest) {
    return post<{ orderId: string; needPay: boolean }>('/users/tickets/buy', data)
  },

  async getMyTickets(params?: { status?: string; page?: number; pageSize?: number }) {
    return get<PageResult<UserTicket>>('/users/tickets', params)
  },

  async getUsageRecords(params?: { page?: number; pageSize?: number }) {
    return get<PageResult<TicketUsageRecord>>('/users/tickets/usage-history', params)
  }
}
