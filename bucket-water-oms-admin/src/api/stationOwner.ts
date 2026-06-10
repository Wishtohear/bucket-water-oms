import axios from '@/utils/request'

export interface DashboardData {
  stationId?: string
  stationName?: string
  contact?: string
  contactPhone?: string
  address?: string
  accountBalance: string
  creditLimit: string
  usedCredit: string
  availableCredit: string
  owedBucketNum: number
  owedThreshold: number
  overThreshold: boolean
  totalBuckets?: number
  billingCycle?: number
  recentOrders: RecentOrder[]
  notifications: Notification[]
}

export interface RecentOrder {
  orderId: string
  orderNo: string
  status: string
  statusText: string
  totalAmount: string
  totalQuantity: number
  createdAt: string
}

export interface Notification {
  id: string
  title: string
  content: string
  type: string
  createdAt: string
}

export interface OrderVO {
  id: string
  orderNo: string
  stationId: string
  stationName: string
  warehouseId: string
  warehouseName: string
  driverId?: string
  driverName?: string
  status: string
  statusText: string
  totalAmount: string
  totalBuckets: number
  actualBuckets?: number
  paymentType: string
  paymentTypeText: string
  createTime: string
  reviewedAt?: string
  dispatchedAt?: string
  deliveredAt?: string
  rejectReason?: string
  signType?: string
  signPhotos?: string[]
  contactName?: string
  contactPhone?: string
  deliveryAddress?: string
  remark?: string
  items: OrderItem[]
}

export interface OrderItem {
  productId: string
  productName: string
  price: number
  quantity: number
  actualQty?: number
  amount: number
}

export interface CustomerVO {
  id: string
  name: string
  phone: string
  avatar?: string
  type: string
  typeText: string
  balance: number
  tickets: number
  owedBuckets: number
  owedAmount: number
  address: string
  backupPhone?: string
  wechat?: string
  addressType?: string
  note?: string
  totalOrders: number
}

export interface BucketTransaction {
  id: string
  type: string
  typeText: string
  description: string
  amount: string
  date: string
  driver: string
  orderId?: string
  orderNo?: string
}

export interface BucketSummary {
  depositBucketNum: number
  owedBucketNum: number
  owedDepositAmount: number
  bucketDepositPerUnit: number
  owedThreshold: number
  overThreshold: boolean
  monthReturn: number
  monthOwe: number
  monthNet: number
  totalReturn: number
  totalOwe: number
}

export interface StatementVO {
  id: string
  yearMonth: string
  startDate: string
  endDate: string
  openingBalance: string
  totalAmount: string
  paymentReceived: string
  closingBalance: string
  status: string
  statusText: string
  generateDate: string
  confirmDate?: string
}

export interface PurchaseRecord {
  id: string
  orderId: string
  orderNo: string
  product: string
  date: string
  amount: string
  paymentType: string
  icon: string
  iconBg: string
  iconColor: string
}

export interface PaymentRecord {
  id: string
  type: string
  date: string
  amount: string
}

export interface ProductItem {
  productId: string
  name: string
  category: string
  specification: string
  price: number
  status: string
}

export interface ProductListResponse {
  products: ProductItem[]
}

export interface TierPriceInfo {
  price: number
  minQuantity: number
}

export interface ProductPriceResponse {
  productId: number
  productName: string
  unitPrice: number
  minOrderQuantity: number
  tierPrice: TierPriceInfo | null
}

export interface WarehouseInventory {
  warehouseId: string
  warehouseName: string
  distanceKm: number
  products: WarehouseProductInventory[]
}

export interface WarehouseProductInventory {
  productId: string
  productName: string
  availableQty: number
  unitPrice: number
}

export interface InventoryResponse {
  warehouses: WarehouseInventory[]
}

export interface ProductVO {
  id: string
  name: string
  category: string
  spec: string
  image?: string
  price: string
  stock: number
  stockStatus: string
  tierPrice: boolean
  warehouseStock: { [warehouseId: string]: number }
}

export interface AfterSalesVO {
  id: string
  afterSalesNo: string
  orderId: string
  orderNo: string
  type: string
  typeText: string
  productId: string
  productName: string
  productImage?: string
  quantity: number
  reason: string
  images: string[]
  status: string
  statusText: string
  createdAt: string
  handledAt?: string
  result?: string
}

export interface AfterSalesListResponse {
  list: AfterSalesVO[]
  totalPages: number
  total: number
}

export const stationOwnerApi = {
  getDashboard(): Promise<DashboardData> {
    return axios.get('/stations/dashboard')
  },

  getInventory(): Promise<InventoryResponse> {
    return axios.get('/stations/inventory')
  },

  getProductPrices(): Promise<any> {
    return axios.get('/stations/product-prices')
  },

  recharge(data: { amount: number; paymentMethod: string }): Promise<any> {
    return axios.post('/stations/recharge', data)
  },

  payBucketDeposit(bucketNum: number): Promise<any> {
    return axios.post('/stations/bucket-deposit/pay', null, { params: { bucketNum } })
  },

  getOrders(params: {
    status?: string
    keyword?: string
    page?: number
    size?: number
  }): Promise<OrderVO[]> {
    return axios.get('/orders', { params })
  },

  getOrderById(orderId: string): Promise<OrderVO> {
    return axios.get(`/orders/${orderId}`)
  },

  cancelOrder(orderId: string, reason?: string): Promise<any> {
    return axios.post(`/orders/${orderId}/cancel`, null, { params: { reason } })
  },

  createOrder(data: {
    warehouseId: string
    items: { productId: string; quantity: number }[]
    deliveryAddress: string
    contactName: string
    contactPhone: string
    paymentType?: string
    remark?: string
  }): Promise<OrderVO> {
    return axios.post('/orders', data)
  },

  updateOrder(orderId: string, data: {
    warehouseId?: string
    items?: { productId: string; quantity: number }[]
    remark?: string
  }): Promise<OrderVO> {
    return axios.put(`/orders/${orderId}`, data)
  },

  getCustomers(params?: {
    keyword?: string
    page?: number
    size?: number
  }): Promise<CustomerVO[]> {
    return axios.get('/customers', { params })
  },

  getCustomerById(customerId: string): Promise<CustomerVO> {
    return axios.get(`/customers/${customerId}`)
  },

  createCustomer(data: {
    name: string
    phone: string
    address?: string
    contact?: string
  }): Promise<CustomerVO> {
    return axios.post('/customers', data)
  },

  updateCustomer(customerId: string, data: {
    name?: string
    phone?: string
    address?: string
    contact?: string
  }): Promise<CustomerVO> {
    return axios.put(`/customers/${customerId}`, data)
  },

  deleteCustomer(customerId: string): Promise<any> {
    return axios.delete(`/customers/${customerId}`)
  },

  getBucketTransactions(params?: {
    startDate?: string
    endDate?: string
  }): Promise<BucketTransaction[]> {
    return axios.get('/stations/bucket-transactions', { params })
  },

  getBucketSummary(): Promise<BucketSummary> {
    return axios.get('/stations/bucket-summary')
  },

  getStatements(params?: {
    yearMonth?: string
  }): Promise<StatementVO[]> {
    return axios.get('/statements', { params })
  },

  getStatementById(statementId: string): Promise<StatementVO> {
    return axios.get(`/statements/${statementId}`)
  },

  confirmStatement(statementId: string): Promise<any> {
    return axios.post(`/statements/${statementId}/confirm`)
  },

  disputeStatement(statementId: string, reason: string): Promise<any> {
    return axios.post(`/statements/${statementId}/dispute`, null, { params: { disputeReason: reason } })
  },

  getProducts(): Promise<ProductListResponse> {
    return axios.get('/products')
  },

  getNotifications(): Promise<Notification[]> {
    return axios.get('/notifications')
  },

  markNotificationRead(notificationId: string): Promise<any> {
    return axios.post(`/notifications/${notificationId}/read`)
  },

  getUserProfile(): Promise<any> {
    return axios.get('/auth/profile')
  },

  updateProfile(data: {
    name?: string
    phone?: string
  }): Promise<any> {
    return axios.put('/auth/profile', data)
  },

  changePassword(data: {
    currentPassword: string
    newPassword: string
  }): Promise<any> {
    return axios.post('/auth/change-password', data)
  },

  // 售后相关接口
  getAfterSalesList(params?: {
    status?: string
    page?: number
    size?: number
  }): Promise<AfterSalesListResponse | AfterSalesVO[]> {
    return axios.get('/after-sales', { params })
  },

  getAfterSalesById(id: string): Promise<AfterSalesVO> {
    return axios.get(`/after-sales/${id}`)
  },

  createAfterSales(data: {
    orderId: string
    type: string
    productId: string
    quantity: number
    reason: string
    images?: string[]
  }): Promise<AfterSalesVO> {
    return axios.post('/after-sales', data)
  },

  cancelAfterSales(id: string): Promise<any> {
    return axios.post(`/after-sales/${id}/cancel`)
  },

  // 收货确认相关接口
  verifyOrderCode(orderId: string, verifyCode: string): Promise<any> {
    return axios.post(`/orders/${orderId}/verify-code`, { verifyCode })
  },

  confirmOrder(orderId: string, confirmCode: string): Promise<any> {
    return axios.post(`/orders/${orderId}/confirm`, { confirmCode })
  },

  // 水票相关接口
  getTicketStats(): Promise<{ totalTickets: number; availableTickets: number; usedTickets: number }> {
    return axios.get('/tickets/stats')
  },

  getTicketHoldings(): Promise<any[]> {
    return axios.get('/tickets/holdings')
  },

  getTicketTransactions(params?: {
    filter?: string
    dateRange?: string
    page?: number
    size?: number
  }): Promise<any[]> {
    return axios.get('/tickets/transactions', { params })
  },

  purchaseTicket(data: {
    ticketId: string
    quantity: number
    paymentMethod: string
  }): Promise<any> {
    return axios.post('/tickets/purchase', data)
  }
}
