import request from '@/utils/request'

export interface Driver {
  id?: string
  code?: string
  name: string
  phone: string
  idCard?: string
  area: string
  vehicleInfo?: string
  warehouseId?: string
  warehouseIds?: number[]
  password?: string
  status?: string
  remark?: string
  emergencyContact?: string
  licensePlate?: string
  vehicleType?: string
}

export interface DriverVO {
  id: string
  code: string
  name: string
  phone: string
  idCard?: string
  area: string
  vehicleInfo?: string
  warehouseId?: string
  warehouseIds?: number[]
  warehouseNames?: string[]
  avatar?: string
  status: 'online' | 'offline' | 'delivering'
  currentTasks: number
  todayDeliveries: number
  todayBuckets: number
  createTime: string
  lastLogin?: string
  remark?: string
}

export interface DriverStats {
  online: number
  offline: number
  delivering: number
  completedToday: number
  totalOrders: number
  totalBuckets: number
}

export interface DriverDeliveryReport {
  driverId: string
  driverName: string
  driverCode: string
  area: string
  orders: number
  buckets: number
  mileage: number
  amount: number
  onTimeRate: number
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

export const driversApi = {
  getAll(params?: { status?: string; warehouseId?: string; area?: string; keyword?: string }) {
    return request.get<DriverVO[], { data: DriverVO[], total: number }>('/admin/drivers', { params })
  },

  getById(id: string) {
    return request.get<DriverVO>(`/admin/drivers/${id}`)
  },

  create(data: Driver) {
    return request.post<DriverVO>(`/admin/drivers`, data)
  },

  update(id: string, data: Driver) {
    return request.put<DriverVO>(`/admin/drivers/${id}`, data)
  },

  delete(id: string) {
    return request.delete<void>(`/admin/drivers/${id}`)
  },

  enable(id: string) {
    return request.patch<void>(`/admin/drivers/${id}/enable`)
  },

  disable(id: string) {
    return request.patch<void>(`/admin/drivers/${id}/disable`)
  },

  resetPassword(id: string) {
    return request.post<{ newPassword: string }>(`/admin/drivers/${id}/reset-password`)
  },

  updateStatus(id: string, status: string) {
    return request.patch<void>(`/admin/drivers/${id}/status`, { status })
  },

  getStats() {
    return request.get<DriverStats>('/admin/drivers/stats')
  },

  getDeliveryReport(params?: { startDate?: string; endDate?: string; driverId?: string }) {
    return request.get<DriverDeliveryReport[]>('/admin/drivers/delivery-report', { params })
  },

  getInTransitBuckets() {
    return request.get<InTransitBucket[]>('/admin/drivers/in-transit-buckets')
  },

  exportDrivers(params?: { status?: string; warehouseId?: string }) {
    return request.get<Blob>('/admin/drivers/export', {
      params,
      responseType: 'blob'
    })
  },

  exportDeliveryReport(params?: { startDate?: string; endDate?: string }) {
    return request.get<Blob>('/admin/drivers/delivery-report/export', {
      params,
      responseType: 'blob'
    })
  },

  getStatements(driverId: string, params?: { startDate?: string; endDate?: string }) {
    return request.get<any>(`/drivers/statements`, {
      params: { driverId, ...params }
    })
  },

  generateStatement(driverId: string) {
    return request.post<any>(`/drivers/statements/generate`, null, {
      params: { driverId }
    })
  }
}
