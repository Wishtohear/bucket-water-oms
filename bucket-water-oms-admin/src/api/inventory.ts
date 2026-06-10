import request from '@/utils/request'

export interface InboundRecordDTO {
  warehouseId: string
  productId: string
  quantity: number
  type: string
  operator?: string
  remark?: string
  price?: number
}

export interface OutboundRecordDTO {
  warehouseId: string
  productId: string
  quantity: number
  type: string
  operator?: string
  remark?: string
}

export interface InventoryRecordVO {
  id: string
  operateTime: string
  businessType: string
  businessTypeText: string
  productName: string
  quantityChange: number
  relatedObject: string
  operator: string
}

export interface InventorySummaryVO {
  totalStock: number
  totalIn: number
  totalOut: number
  lowStockCount: number
  damagedCount: number
  damageRate: string
}

export interface InventoryCheckItemVO {
  id: string
  productId: string
  productName: string
  category: string
  systemQuantity: number
  actualQuantity: number
  discrepancy: number
  remark?: string
}

export interface InventoryCheckVO {
  id: string
  warehouseId: string
  warehouseName: string
  checkDate: string
  checker: string
  status: string
  statusText: string
  summary?: string
  totalProducts: number
  matchedProducts: number
  discrepancyProducts: number
  createTime: string
  items?: InventoryCheckItemVO[]
}

export interface CreateInventoryCheckRequest {
  warehouseId: string
  checker?: string
  summary?: string
  items: Array<{
    productId: string
    productName: string
    category: string
    systemQuantity: number
    actualQuantity: number
    remark?: string
  }>
}

export interface PageResponse<T> {
  total: number
  page: number
  size: number
  totalPages: number
  records: T[]
}

export interface InventoryTransactionDTO {
  id: number
  transactionNo: string
  warehouseId: number
  warehouseName: string
  productId: number
  productName: string
  productCategory: string
  transactionType: string
  transactionTypeText: string
  detailType: string
  detailTypeText: string
  quantity: number
  unitPrice: number
  totalAmount: number
  balanceBefore: number
  balanceAfter: number
  relatedOrderNo: string
  relatedBusinessNo: string
  source: string
  destination: string
  remark: string
  operator: string
  createTime: string
  updateTime: string
}

export interface CreateInboundTransactionRequest {
  inboundType: string
  items: Array<{
    productId: number
    quantity: number
    unitPrice?: number
    remark?: string
  }>
  source?: string
  relatedOrderNo?: string
  remark?: string
}

export interface InventoryCheckTaskDTO {
  id: number
  taskNo: string
  warehouseId: number
  warehouseName: string
  status: string
  statusText: string
  totalProducts: number
  checkedProducts: number
  surplusCount: number
  lossCount: number
  matchedCount: number
  summary: string
  creator: string
  checker: string
  startTime: string
  endTime: string
  createTime: string
  items?: InventoryCheckTaskItemDTO[]
}

export interface InventoryCheckTaskItemDTO {
  id: number
  taskId: number
  productId: number
  productName: string
  productCategory: string
  systemQuantity: number
  actualQuantity: number
  discrepancy: number
  discrepancyType: string
  discrepancyTypeText: string
  remark: string
  createTime: string
}

export interface ProductInventoryCheckDTO {
  id: number
  checkNo: string
  warehouseId: number
  warehouseName: string
  productId: number
  productName: string
  productCategory: string
  systemQuantity: number
  actualQuantity: number
  discrepancy: number
  discrepancyType: string
  discrepancyTypeText: string
  status: string
  statusText: string
  checker: string
  checkTime: string
  remark: string
  createTime: string
}

export const inventoryApi = {
  recordInbound(data: InboundRecordDTO) {
    return request.post<any, any>('/admin/inventory/inbound', data)
  },

  recordOutbound(data: OutboundRecordDTO) {
    return request.post<any, any>('/admin/inventory/outbound', data)
  },

  getInventoryRecords(params: {
    warehouseId?: string
    productId?: string
    businessType?: string
    dateRange?: 'today' | 'week' | 'month'
  }) {
    return request.get<any, any>('/admin/inventory/records', { params })
  },

  getInventoryOverview(warehouseId?: string) {
    return request.get<any, any>('/admin/inventory/overview', {
      params: { warehouseId }
    })
  },

  getInventoryStats() {
    return request.get<any, any>('/admin/inventory/stats')
  },

  getInventoryChecks(warehouseId?: string) {
    return request.get<any, any>('/admin/inventory/checks', {
      params: { warehouseId }
    })
  },

  getInventoryCheckById(checkId: string) {
    return request.get<any, any>(`/admin/inventory/checks/${checkId}`)
  },

  createInventoryCheck(data: CreateInventoryCheckRequest) {
    return request.post<any, any>('/admin/inventory/checks', data)
  },

  confirmInventoryCheck(checkId: string) {
    return request.post<any, any>(`/admin/inventory/checks/${checkId}/confirm`)
  },

  getInventoryTransactions(params: {
    warehouseId?: number
    productId?: number
    transactionType?: string
    detailType?: string
    startDate?: string
    endDate?: string
    relatedOrderNo?: string
    page?: number
    size?: number
  }) {
    return request.get<any, PageResponse<InventoryTransactionDTO>>('/warehouses/inventory/transactions', { params })
  },

  getTransactionById(id: number) {
    return request.get<any, InventoryTransactionDTO>(`/warehouses/inventory/transactions/${id}`)
  },

  getTransactionsByProduct(productId: number) {
    return request.get<any, InventoryTransactionDTO[]>(`/warehouses/inventory/transactions/product/${productId}`)
  },

  getTransactionsByOrder(orderNo: string) {
    return request.get<any, InventoryTransactionDTO[]>(`/warehouses/inventory/transactions/order/${orderNo}`)
  },

  getCurrentStock(productId: number) {
    return request.get<any, number>(`/warehouses/inventory/transactions/stock/${productId}`)
  },

  createInboundTransaction(data: CreateInboundTransactionRequest) {
    return request.post<any, InventoryTransactionDTO[]>('/warehouses/inventory/transactions/inbound', data)
  },

  getInventoryCheckTasks(params: {
    warehouseId?: number
    status?: string
    startDate?: string
    endDate?: string
    page?: number
    size?: number
  }) {
    return request.get<any, PageResponse<InventoryCheckTaskDTO>>('/warehouses/inventory/check/tasks', { params })
  },

  getCheckTaskById(taskId: number) {
    return request.get<any, InventoryCheckTaskDTO>(`/warehouses/inventory/check/tasks/${taskId}`)
  },

  getInventoryCheckRecords(params: {
    warehouseId?: number
    productId?: number
    status?: string
    startDate?: string
    endDate?: string
    page?: number
    size?: number
  }) {
    return request.get<any, PageResponse<ProductInventoryCheckDTO>>('/warehouses/inventory/check/records', { params })
  }
}
