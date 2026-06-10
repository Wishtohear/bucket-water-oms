import request from '@/utils/request'

export interface StationManagementDTO {
  id?: string
  name: string
  code?: string
  address: string
  contact: string
  phone: string
  area?: string
  stationType?: string
  initialBalance?: number
  depositBalance?: number
  creditLimit?: number
  remark?: string
  status?: string
  lat?: number
  lng?: number
  latDmm?: string
  lngDmm?: string
}

export interface StationVO {
  id: string
  name: string
  code: string
  address: string
  contact: string
  phone: string
  area: string
  stationType: string
  balance: number
  creditLimit: number
  status: string
  createTime: string
  remark?: string
  owedBuckets?: number
}

export const stationsApi = {
  getAll(params?: { status?: string }) {
    return request.get<any, any>('/admin/stations', { params })
  },

  getById(id: string) {
    return request.get<any, any>(`/admin/stations/${id}`)
  },

  getDetail(id: string) {
    return request.get<any, any>(`/admin/stations/${id}/detail`)
  },

  create(data: StationManagementDTO) {
    return request.post<any, any>('/admin/stations', data)
  },

  update(id: string, data: StationManagementDTO) {
    return request.put<any, any>(`/admin/stations/${id}`, data)
  },

  delete(id: string) {
    return request.delete<any, any>(`/admin/stations/${id}`)
  },

  getPolicies(stationId: string) {
    return request.get<any, any>(`/admin/stations/${stationId}/policy`)
  },

  assignPolicy(stationId: string, policyId: string) {
    return request.post<any, any>(`/admin/stations/${stationId}/policy`, null, {
      params: { policyId }
    })
  },

  updateStatus(stationId: string, status: string) {
    return request.put<any, any>(`/admin/stations/${stationId}/status`, null, {
      params: { status }
    })
  },

  updateLocation(stationId: string, latitude: number, longitude: number, address?: string) {
    return request.put<any, any>(`/admin/stations/${stationId}/location`, null, {
      params: { latitude, longitude, address }
    })
  },

  getStaffs(stationId: string) {
    return request.get<any, any>(`/admin/stations/${stationId}/staffs`)
  },

  createStaff(stationId: string, data: any) {
    return request.post<any, any>(`/admin/stations/${stationId}/staffs`, data)
  },

  updateStaff(stationId: string, staffId: string, data: any) {
    return request.put<any, any>(`/admin/stations/${stationId}/staffs/${staffId}`, data)
  },

  deleteStaff(stationId: string, staffId: string) {
    return request.delete<any, any>(`/admin/stations/${stationId}/staffs/${staffId}`)
  },

  resetStaffPassword(stationId: string, staffId: string) {
    return request.post<any, any>(`/admin/stations/${stationId}/staffs/${staffId}/reset-password`, null)
  },

  getOrders(stationId: string, limit: number = 10) {
    return request.get<any, any>(`/admin/stations/${stationId}/orders`, {
      params: { limit }
    })
  }
}
