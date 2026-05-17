// 订单相关类型定义
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

export interface CartItem {
  id: string
  stationId: string
  stationName: string
  productId: string
  productName: string
  price: number
  quantity: number
  image: string
}

export interface OrderItem {
  id: string
  productId: string
  productName: string
  price: number
  quantity: number
  subtotal: number
  image?: string
}

export enum OrderStatus {
  PENDING_PAY = 'pending_pay',
  PAID = 'paid',
  PROCESSING = 'processing',
  DELIVERING = 'delivering',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled',
  REFUNDED = 'refunded'
}

export interface Order {
  id: string
  orderNo: string
  stationId: string
  stationName: string
  userId: string
  status: OrderStatus
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
