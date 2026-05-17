// 水站配送订单相关类型定义
export enum StationOrderStatus {
  PENDING_PAY = 'pending_pay',
  PAID = 'paid',
  PENDING_DISPATCH = 'pending_dispatch',
  PENDING_ACCEPT = 'pending_accept',
  DELIVERING = 'delivering',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled',
  REFUNDED = 'refunded'
}

export interface DeliveryPerson {
  id: string
  stationId: string
  name: string
  phone: string
  idCard?: string
  avatar?: string
  status: 'active' | 'inactive'
  totalOrders: number
  todayOrders: number
  rating: number
  createdAt: string
}

export interface StationOrderItem {
  id: string
  productId: string
  productName: string
  price: number
  quantity: number
  subtotal: number
}

export interface StationOrder {
  id: string
  orderNo: string
  stationId: string
  stationName: string
  userId: string
  deliveryPersonId?: string
  deliveryPerson?: DeliveryPerson
  status: StationOrderStatus
  totalAmount: number
  payAmount: number
  freight: number
  payMethod: string
  addressId: string
  address: Address
  items: StationOrderItem[]
  remark?: string
  dispatchTime?: string
  acceptTime?: string
  startTime?: string
  completeTime?: string
  createdAt: string
  updatedAt: string
  deliveryLat?: number
  deliveryLng?: number
}

export interface DeliveryTrack {
  orderId: string
  status: StationOrderStatus
  deliveryPerson?: {
    id: string
    name: string
    phone: string
    avatar?: string
    currentLocation?: {
      latitude: number
      longitude: number
    }
  }
  estimatedTime?: string
  timeline: DeliveryTrackItem[]
}

export interface DeliveryTrackItem {
  time: string
  status: string
  description: string
}
