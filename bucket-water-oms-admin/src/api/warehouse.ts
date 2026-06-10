import request from '@/utils/request'

export interface WarehouseDashboardDTO {
  todayInbound: number
  todayOutbound: number
  totalInventory: number
  lowStockWarnings: number
  inventoryWarnings: InventoryWarning[]
  recentTasks: Task[]
  notifications: Notification[]
  warehouseName?: string
  warehouseId?: string | number
}

export interface InventoryWarning {
  productId: string
  productName: string
  currentStock: number
  safeStock: number
  warehouseName: string
}

export interface Task {
  taskId: string
  taskNo: string
  type: string
  typeText: string
  status: string
  statusText: string
  customerName: string
  quantity: number
  createdAt: string
}

export interface Notification {
  id: string
  title: string
  content: string
  type: string
  createdAt: string
}

export interface WarehouseOrderVO {
  orderId: string
  id?: string
  orderNo: string
  status: string
  statusText: string
  warehouseId: string
  warehouseName: string
  stationId: string
  stationName: string
  stationAddress: string
  driverId: string
  driverName: string
  totalAmount: number
  paymentType: string
  paymentTypeText: string
  totalBuckets: number
  actualBuckets: number
  createTime: string
  reviewedAt: string
  dispatchedAt: string
  deliveredAt: string
  rejectReason: string
  signType: string
  signPhotos: string
  contactName: string
  contactPhone: string
  deliveryAddress: string
  remark: string
  items: OrderItem[]
  canReview: boolean
  canDispatch: boolean
}

export interface OrderItem {
  productId: string
  productName: string
  price: number
  quantity: number
  actualQty: number
  amount: number
}

export interface WarehouseInventoryVO {
  id: string
  productId: string
  productName: string
  warehouseId: string
  warehouseName: string
  quantity: number
  safeStock: number
  location: string
  category: string
  unit: string
  updatedAt: string
}

export interface WarehouseInboundDTO {
  id: string
  inboundNo: string
  warehouseId: string
  warehouseName: string
  type: string
  typeText: string
  status: string
  statusText: string
  totalAmount: number
  totalQuantity: number
  remark: string
  creator: string
  createTime: string
  checker: string
  checkTime: string
  items: WarehouseInboundItem[]
}

export interface WarehouseInboundItem {
  id: string
  inboundId: string
  productId: string
  productName: string
  quantity: number
  price: number
  amount: number
}

export interface CreateInboundRequest {
  type: string
  items: { productId: string; quantity: number; price: number }[]
  remark: string
}

export interface CheckInboundRequest {
  approved: boolean
  actualQuantity?: number
  checker?: string
  reason?: string
  remark?: string
}

export interface WarehouseOutboundDTO {
  id: string
  outboundNo: string
  warehouseId: string
  warehouseName: string
  orderId: string
  orderNo: string
  type: string
  typeText: string
  status: string
  statusText: string
  totalAmount: number
  totalQuantity: number
  stationId: string
  stationName: string
  remark: string
  creator: string
  createTime: string
  confirmer: string
  confirmTime: string
  items: WarehouseOutboundItem[]
}

export interface WarehouseOutboundItem {
  id: string
  outboundId: string
  productId: string
  productName: string
  quantity: number
  price: number
  amount: number
}

export interface DriverReturnDTO {
  id: string
  returnNo: string
  driverId: string
  driverName: string
  driverCode: string
  warehouseId: string
  warehouseName: string
  orderId: string
  orderNo: string
  bucketReturned: number
  actualBucketQty: number
  difference: number
  differenceReason: string
  status: string
  statusText: string
  remark: string
  createdAt: string
  checkedAt: string
}

export interface CheckReturnRequest {
  actualBucketQty: number
  differenceReason?: string
}

export interface AfterSalesDTO {
  id: string
  ticketNo: string
  orderId: string
  orderNo: string
  stationId: string
  stationName: string
  stationAddress: string
  warehouseId: string
  warehouseName: string
  type: string
  typeText: string
  status: string
  statusText: string
  reason: string
  images: string[]
  items: AfterSalesItem[]
  createdAt: string
  handledAt: string
  handleResult: string
}

export interface AfterSalesItem {
  productId: string
  productName: string
  quantity: number
  actualQuantity: number
}

export interface ProcessAfterSalesRequest {
  action: string
  remark?: string
  approved?: boolean
  type?: string
  reason?: string
  newOrderId?: string
}

export interface DriverVO {
  id: string
  name: string
  phone: string
  code: string
  warehouseId: string
  warehouseName: string
  area: string
  onlineStatus: string
  onlineStatusText: string
  currentTasks: number
  todayDeliveries: number
  currentLat: number
  currentLng: number
  lastLocationTime: string
  status: string
  statusText: string
}

export interface DispatchDriverVO {
  driverId: string
  code: string
  name: string
  phone: string
  currentLat: number
  currentLng: number
  onlineStatus: string
  onlineStatusText: string
  currentTaskCount: number
  todayCompletedCount: number
  rating: number
  totalDeliveries: number
  recommendReason: string
  recommendReasonText: string
  recommendScore: number
  distanceToWarehouse: number
  boundToCurrentWarehouse: boolean
  warehouseName: string
}

export interface DispatchOrderResponse {
  order: WarehouseOrderVO
  warnings: string[]
  success: boolean
}

export interface ReviewOrderRequest {
  action: 'accept' | 'reject'
  reason?: string
}

export interface DispatchOrderRequest {
  driverId: string
}

export interface PreparingOrderVO {
  orderId: string
  id?: string
  orderNo: string
  status: string
  statusText: string
  stationId: string
  stationName: string
  stationAddress: string
  deliveryAddress?: string
  driverId: string
  driverName: string
  totalAmount: number
  totalBuckets: number
  paymentType: string
  paymentTypeText: string
  createTime: string
  reviewedAt: string
  dispatchedAt: string
  items: OrderItem[]
  preparedCount: number
  totalCount: number
  preparingProgress: number
  waitMinutes: number
  canOperate: boolean
}

export interface NotificationSettingsDTO {
  newOrder: boolean
  lowStock: boolean
  driverReturn: boolean
}

export const warehouseApi = {
  getDashboard() {
    return request.get<any, WarehouseDashboardDTO>('/warehouses/dashboard')
  },

  getPreparingOrders(params?: { status?: string; page?: number; size?: number }) {
    return request.get<any, PreparingOrderVO[]>('/warehouses/orders/preparing', { params })
  },

  getPendingOrders(params?: { sortBy?: string }) {
    return request.get<any, WarehouseOrderVO[]>('/warehouses/orders', { params })
  },

  getAllOrders(params?: { status?: string; page?: number; size?: number }) {
    return request.get<any, WarehouseOrderVO[]>('/warehouses/orders/all', { params })
  },

  getOrderById(orderId: string) {
    return request.get<any, WarehouseOrderVO>(`/orders/${orderId}`)
  },

  reviewOrder(orderId: string, data: ReviewOrderRequest) {
    return request.post<any, WarehouseOrderVO>(`/orders/${orderId}/review`, data)
  },

  dispatchOrder(orderId: string, data: DispatchOrderRequest) {
    return request.post<any, DispatchOrderResponse>(`/orders/${orderId}/dispatch`, data)
  },

  getInventory() {
    return request.get<any, WarehouseInventoryVO[]>('/warehouses/inventory')
  },

  calibrateInventory(inventoryId: number, data: { quantity: number; reason?: string }) {
    return request.put<any, void>(`/warehouses/inventory/${inventoryId}/calibrate`, data)
  },

  getInboundList(params?: { status?: string }) {
    return request.get<any, WarehouseInboundDTO[]>('/warehouses/bucket-inbound', { params })
  },

  getInboundDetail(id: string) {
    return request.get<any, WarehouseInboundDTO>(`/warehouses/bucket-inbound/${id}`)
  },

  createInbound(data: CreateInboundRequest) {
    return request.post<any, WarehouseInboundDTO>('/warehouses/bucket-inbound', data)
  },

  checkInbound(id: string, data: CheckInboundRequest) {
    if (data.approved) {
      return request.post<any, WarehouseInboundDTO>(`/warehouses/bucket-inbound/${id}/confirm`, {
        actualQuantity: data.actualQuantity || 0,
        checker: data.checker,
        remark: data.remark
      })
    } else {
      return request.post<any, WarehouseInboundDTO>(`/warehouses/bucket-inbound/${id}/reject`, {
        reason: data.reason || '审核拒绝',
        operator: data.checker
      })
    }
  },

  getOutboundList(params?: { status?: string }) {
    return request.get<any, WarehouseOutboundDTO[]>('/warehouses/bucket-outbound', { params })
  },

  getOutboundDetail(id: string) {
    return request.get<any, WarehouseOutboundDTO>(`/warehouses/bucket-outbound/${id}`)
  },

  createOutboundForOrder(orderId: string) {
    return request.post<any, WarehouseOutboundDTO>(`/warehouses/bucket-outbound/order/${orderId}`)
  },

  confirmOutbound(id: string) {
    return request.post<any, WarehouseOutboundDTO>(`/warehouses/bucket-outbound/${id}/confirm`)
  },

  getPendingReturns() {
    return request.get<any, DriverReturnDTO[]>('/warehouses/returns')
  },

  getReturnCheckDetail(returnId: string) {
    return request.get<any, DriverReturnDTO>(`/warehouses/returns/${returnId}`)
  },

  checkReturn(returnId: string, data: CheckReturnRequest) {
    return request.post<any, DriverReturnDTO>(`/warehouses/returns/${returnId}/check`, data)
  },

  confirmReturnCheck(returnId: string, data: { actualBuckets: number; remark?: string }) {
    return request.post<any, DriverReturnDTO>(`/warehouses/returns/${returnId}/confirm`, data)
  },

  recordDiscrepancy(returnId: string, data: { actualBuckets: number; remark?: string }) {
    return request.post<any, DriverReturnDTO>(`/warehouses/returns/${returnId}/discrepancy`, data)
  },

  getAfterSalesList(params?: { status?: string }) {
    return request.get<any, AfterSalesDTO[]>('/after-sales/warehouse', { params })
  },

  getAfterSalesDetail(id: string) {
    return request.get<any, AfterSalesDTO>(`/after-sales/${id}`)
  },

  processAfterSales(id: string, data: ProcessAfterSalesRequest) {
    return request.post<any, AfterSalesDTO>(`/after-sales/${id}/process`, data)
  },

  getAvailableDrivers() {
    return request.get<any, DriverVO[]>('/warehouses/drivers')
  },

  getRecommendedDrivers(orderId?: string) {
    return request.get<any, DriverVO[]>('/warehouses/drivers/recommend', {
      params: { orderId }
    })
  },

  getRecommendedDriversWithDetails(orderId?: string) {
    return request.get<any, DispatchDriverVO[]>('/warehouses/drivers/recommend/details', {
      params: { orderId }
    })
  },

  getAllAvailableDrivers() {
    return request.get<any, DispatchDriverVO[]>('/warehouses/drivers/all')
  },

  getWarehouseInfo() {
    return request.get<any, any>('/warehouses/info')
  },

  updateWarehouseInfo(data: { name?: string; address?: string }) {
    return request.put<any, any>('/warehouses/info', data)
  },

  getNotificationSettings() {
    return request.get<any, NotificationSettingsDTO>('/warehouses/notification-settings')
  },

  updateNotificationSettings(data: NotificationSettingsDTO) {
    return request.put<any, any>('/warehouses/notification-settings', data)
  },

  updateProfile(data: { name?: string; phone?: string }) {
    return request.put<any, any>('/warehouses/profile', data)
  },

  changePassword(data: { oldPassword: string; newPassword: string }) {
    return request.post<any, any>('/warehouses/change-password', data)
  },

  getProfile() {
    return request.get<any, any>('/warehouses/profile')
  }
}
