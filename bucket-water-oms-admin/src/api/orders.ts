import axios from '@/utils/request'

export interface OrderItem {
  productId: string
  productName: string
  price: number
  quantity: number
  actualQty?: number
  amount: number
}

export interface Order {
  id: string
  orderNo: string
  stationId: string
  stationName: string
  stationAddress: string
  warehouseId: string
  warehouseName: string
  driverId: string
  driverName: string
  status: string
  statusText: string
  totalAmount: number
  paymentType: string
  paymentTypeText: string
  totalBuckets: number
  actualBuckets?: number
  createTime: string
  reviewedAt?: string
  dispatchedAt?: string
  deliveredAt?: string
  rejectReason?: string
  signType?: string
  signPhotos?: string
  contactName?: string
  contactPhone?: string
  deliveryAddress?: string
  remark?: string
  items: OrderItem[]
}

export interface OrderQueryParams {
  keyword?: string
  status?: string
  warehouseId?: string
  stationId?: string
  startDate?: string
  endDate?: string
  page?: number
  size?: number
}

export interface OrderPageResult {
  records: Order[]
  total: number
  page: number
  size: number
  totalPages: number
}

export interface OrderStats {
  todayOrderCount: number
  pendingReviewCount: number
  todayCompletedCount: number
  deliveringCount: number
}

export const ordersApi = {
  getPage(params: OrderQueryParams): Promise<any> {
    return axios.get('/admin/orders/page', { params })
  },

  getById(id: string): Promise<any> {
    return axios.get(`/admin/orders/${id}`)
  },

  cancel(id: string, reason?: string): Promise<any> {
    return axios.post(`/admin/orders/${id}/cancel`, null, { params: { reason } })
  },

  dispatch(id: string, data: {
    driverId: string
    expectedDeliveryTime?: string
    note?: string
  }): Promise<any> {
    return axios.post(`/admin/orders/${id}/dispatch`, data)
  },

  getStats(): Promise<any> {
    return axios.get('/admin/orders/stats')
  }
}
