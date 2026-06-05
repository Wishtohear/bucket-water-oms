import apiClient from './client'

export const authApi = {
  login(username: string, password: string) {
    return apiClient.post('/platform/auth/login', { username, password })
  },
  logout() {
    return apiClient.post('/platform/auth/logout')
  },
  refresh() {
    return apiClient.post('/platform/auth/refresh')
  }
}

export const platformApi = {
  getDashboardStats() {
    return apiClient.get('/platform/dashboard/stats')
  },
  getAllFactories(params?: { keyword?: string; status?: string; page?: number; size?: number }) {
    return apiClient.get('/platform/factories', { params })
  },
  getFactoryById(id: string | number) {
    return apiClient.get(`/platform/factories/${id}`)
  },
  createFactory(data: any) {
    return apiClient.post('/platform/factories', data)
  },
  updateFactory(id: string | number, data: any) {
    return apiClient.put(`/platform/factories/${id}`, data)
  },
  updateFactoryStatus(id: string | number, status: string) {
    return apiClient.put(`/platform/factories/${id}/status`, null, { params: { status } })
  },
  deleteFactory(id: string | number) {
    return apiClient.delete(`/platform/factories/${id}`)
  },
  getAdmins(params?: { keyword?: string; page?: number; size?: number }) {
    return apiClient.get('/platform/admins', { params })
  },
  createAdmin(data: any) {
    return apiClient.post('/platform/admins', data)
  },
  updateAdmin(id: string | number, data: any) {
    return apiClient.put(`/platform/admins/${id}`, data)
  },
  updateAdminStatus(id: string | number, status: string) {
    return apiClient.put(`/platform/admins/${id}/status`, null, { params: { status } })
  },
  resetAdminPassword(id: string | number, newPassword = '123456') {
    return apiClient.put(`/platform/admins/${id}/password`, null, { params: { newPassword } })
  },
  deleteAdmin(id: string | number) {
    return apiClient.delete(`/platform/admins/${id}`)
  },
  getConfig() {
    return apiClient.get('/platform/config')
  },
  saveConfig(data: any) {
    return apiClient.put('/platform/config', data)
  },
  getLogs(params?: { module?: string; action?: string; userName?: string; startTime?: string; endTime?: string; page?: number; size?: number }) {
    return apiClient.get('/platform/logs', { params })
  },
  getSalesReport(params: { startDate?: string; endDate?: string; factoryId?: number }) {
    return apiClient.get('/platform/reports/sales', { params })
  },
  getOrderReport(params: { startDate?: string; endDate?: string }) {
    return apiClient.get('/platform/reports/orders', { params })
  },
  getComparisonReport(params: { startDate?: string; endDate?: string }) {
    return apiClient.get('/platform/reports/comparison', { params })
  }
}
