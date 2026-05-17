// 水票相关类型定义
export interface ProductTicket {
  id: string
  stationId: string
  productId: string
  productName: string
  name: string
  bucketCount: number
  price: number
  originalPrice: number
  discount: number
  validDays: number
  stock: number
  status: 'active' | 'inactive'
  sortOrder: number
  createdAt: string
  updatedAt: string
}

export interface UserTicket {
  id: string
  userId: string
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
  sourceOrderId: string
}

export interface TicketUsageRecord {
  id: string
  userTicketId: string
  orderId: string
  stationId: string
  stationName: string
  productId: string
  productName: string
  usedBucketCount: number
  usedAt: string
  orderNo: string
}
