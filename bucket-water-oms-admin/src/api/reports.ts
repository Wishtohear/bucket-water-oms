import request from '@/utils/request'

export interface SalesTrend {
  date: string
  amount: number
  orders: number
}

export interface ProductSales {
  productId: string
  productName: string
  quantity: number
  amount: number
}

export interface StationRanking {
  stationId: string
  stationName: string
  totalAmount: number
  totalOrders: number
}

export interface DailySales {
  date: string
  buckets: number
  returned: number
  amount: number
  newStations: number
}

export interface StationPurchaseReport {
  stationId: string
  stationName: string
  stationCode: string
  area: string
  bucketWaterQty: number
  bucketWaterAmount: number
  bottleWaterQty: number
  bottleWaterAmount: number
  otherAmount: number
  totalAmount: number
}

export interface DriverDeliveryReport {
  driverId: string
  driverName: string
  driverCode: string
  avatar?: string
  area: string
  orders: number
  buckets: number
  mileage: number
  amount: number
  onTimeRate: number
}

export interface DriverStatsSummary {
  totalOrders: number
  totalBuckets: number
  totalMileage: number
  avgMileage: number
  onTimeRate: number
}

export interface StationBucketReport {
  stationId: string
  stationName: string
  stationCode: string
  depositBuckets: number
  owedBuckets: number
  threshold: number
}

export interface WarehouseBucketReport {
  warehouseId: string
  warehouseName: string
  warehouseType: string
  availableStock: number
  inTransit: number
}

export interface BucketStatsSummary {
  owedBucketsTotal: number
  owedStations: number
  warehouseStock: number
  inTransit: number
  transitDrivers: number
}

export interface InTransitBucket {
  driverId: string
  driverName: string
  driverCode: string
  phone: string
  area: string
  inTransitBuckets: number
  lastReturnTime: string
}

export const reportsApi = {
  getDashboardStats() {
    return request.get<{
      todaySales: number
      todayOrders: number
      activeStations: number
      stockWarnings: number
      salesGrowth: number
      ordersGrowth: number
    }>('/admin/reports/dashboard-stats')
  },

  getSalesTrend(params?: { startDate?: string; endDate?: string; type?: 'day' | 'week' | 'month' }) {
    return request.get<SalesTrend[]>('/admin/reports/sales-trend', { params })
  },

  getProductSales(params?: { startDate?: string; endDate?: string }) {
    return request.get<ProductSales[]>('/admin/reports/product-sales', { params })
  },

  getStationRanking(params?: { limit?: number; startDate?: string; endDate?: string }) {
    return request.get<StationRanking[]>('/admin/reports/station-ranking', { params })
  },

  getDailySales(params?: { startDate?: string; endDate?: string }) {
    return request.get<DailySales[]>('/admin/reports/daily-sales', { params })
  },

  getStationPurchaseReport(params?: {
    startDate?: string
    endDate?: string
    stationId?: string
    area?: string
  }) {
    return request.get<StationPurchaseReport[], { data: StationPurchaseReport[], total: number }>(
      '/admin/reports/station-purchase',
      { params }
    )
  },

  exportStationPurchaseReport(params?: {
    startDate?: string
    endDate?: string
    stationId?: string
    area?: string
  }) {
    return request.get<Blob>('/admin/reports/station-purchase/export', {
      params,
      responseType: 'blob'
    })
  },

  getDriverDeliveryReport(params?: {
    startDate?: string
    endDate?: string
    driverId?: string
  }) {
    return request.get<DriverDeliveryReport[], { data: DriverDeliveryReport[], total: number }>(
      '/admin/reports/driver-delivery',
      { params }
    )
  },

  getDriverStatsSummary(params?: { startDate?: string; endDate?: string }) {
    return request.get<DriverStatsSummary>('/admin/reports/driver-stats-summary', { params })
  },

  exportDriverDeliveryReport(params?: {
    startDate?: string
    endDate?: string
    driverId?: string
  }) {
    return request.get<Blob>('/admin/reports/driver-delivery/export', {
      params,
      responseType: 'blob'
    })
  },

  getBucketStatsSummary() {
    return request.get<BucketStatsSummary>('/admin/reports/bucket-stats-summary')
  },

  getStationBucketReport() {
    return request.get<StationBucketReport[]>('/admin/reports/station-bucket')
  },

  getWarehouseBucketReport() {
    return request.get<WarehouseBucketReport[]>('/admin/reports/warehouse-bucket')
  },

  getInTransitBuckets() {
    return request.get<InTransitBucket[]>('/admin/reports/in-transit-buckets')
  },

  exportInTransitBuckets() {
    return request.get<Blob>('/admin/reports/in-transit-buckets/export', {
      responseType: 'blob'
    })
  }
}
