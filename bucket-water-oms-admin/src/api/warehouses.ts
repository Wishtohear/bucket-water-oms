import request from '@/utils/request'

export interface WarehouseManagementDTO {
  id?: string
  name: string
  address: string
  contact: string
  phone: string
  type?: string
  status?: string
  remark?: string
  coverageArea?: string
  contactPhone?: string
}

export interface WarehouseVO {
  id: string
  name: string
  address: string
  contact: string
  phone: string
  type: string
  status: string
  createTime: string
  remark?: string
  coverageArea?: string
  stock?: number
  stationCount?: number
}

export interface WarehouseStaff {
  id: string
  name: string
  role: string
  onlineStatus: string
}

export const warehousesApi = {
  getAll(params?: { status?: string }) {
    return request.get<any, any>('/admin/warehouses', { params })
  },

  getById(id: string) {
    return request.get<any, any>(`/admin/warehouses/${id}`)
  },

  create(data: WarehouseManagementDTO) {
    return request.post<any, any>('/admin/warehouses', data)
  },

  update(id: string, data: WarehouseManagementDTO) {
    return request.put<any, any>(`/admin/warehouses/${id}`, data)
  },

  delete(id: string) {
    return request.delete<any, any>(`/admin/warehouses/${id}`)
  },

  updateStatus(id: string, status: string) {
    return request.put<any, any>(`/admin/warehouses/${id}/status`, null, {
      params: { status }
    })
  },

  getInventory(warehouseId: string) {
    return request.get<any, any>(`/warehouses/inventory`, {
      params: { warehouseId }
    })
  },

  getStaffs(warehouseId: string) {
    return request.get<WarehouseStaff[], { data: WarehouseStaff[] }>(`/admin/warehouses/${warehouseId}/staffs`)
  }
}
