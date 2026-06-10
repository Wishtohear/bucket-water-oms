import request from '@/utils/request'

export interface Admin {
  id?: string
  name: string
  username: string
  phone: string
  role: 'super_admin' | 'finance_admin' | 'warehouse_admin' | 'operations_admin'
  permissions?: string[]
  status?: 'active' | 'inactive'
  remark?: string
  password?: string
}

export interface AdminVO {
  id: string
  name: string
  username: string
  phone: string
  role: string
  roleName: string
  permissions: string
  avatar?: string
  status: 'active' | 'inactive'
  lastLogin?: string
  createTime?: string
  remark?: string
}

export interface AuditLog {
  id: string
  time: string
  operator: string
  operatorId: string
  avatar?: string
  actionType: 'create' | 'update' | 'delete' | 'login' | 'export' | 'approve' | 'reject'
  content: string
  ip: string
  userAgent?: string
  details?: Record<string, any>
}

export interface SystemConfig {
  key: string
  value: any
  description?: string
  category: string
}

export const systemApi = {
  getAdmins(params?: { role?: string; status?: string }) {
    return request.get<AdminVO[], { data: AdminVO[], total: number }>('/admin/system/admins', { params })
  },

  getAdminById(id: string) {
    return request.get<AdminVO>(`/admin/system/admins/${id}`)
  },

  createAdmin(data: Admin) {
    return request.post<AdminVO>(`/admin/system/admins`, data)
  },

  updateAdmin(id: string, data: Admin) {
    return request.put<AdminVO>(`/admin/system/admins/${id}`, data)
  },

  deleteAdmin(id: string) {
    return request.delete<void>(`/admin/system/admins/${id}`)
  },

  enableAdmin(id: string) {
    return request.patch<void>(`/admin/system/admins/${id}/enable`)
  },

  disableAdmin(id: string) {
    return request.patch<void>(`/admin/system/admins/${id}/disable`)
  },

  resetAdminPassword(id: string) {
    return request.post<{ newPassword: string }>(`/admin/system/admins/${id}/reset-password`)
  },

  updateAdminRole(id: string, role: string, permissions?: string[]) {
    return request.patch<AdminVO>(`/admin/system/admins/${id}/role`, { role, permissions })
  },

  getAuditLogs(params?: {
    actionType?: string
    startDate?: string
    endDate?: string
    operatorId?: string
    keyword?: string
    page?: number
    pageSize?: number
  }) {
    return request.get<AuditLog[], { data: AuditLog[], total: number }>('/admin/system/audit-logs', { params })
  },

  getAuditLogById(id: string) {
    return request.get<AuditLog>(`/admin/system/audit-logs/${id}`)
  },

  exportAuditLogs(params?: {
    actionType?: string
    startDate?: string
    endDate?: string
    operatorId?: string
  }) {
    return request.get<Blob>('/admin/system/audit-logs/export', {
      params,
      responseType: 'blob'
    })
  },

  getConfigs() {
    return request.get<SystemConfig[]>('/admin/system/configs')
  },

  getConfigByCategory(category: string) {
    return request.get<SystemConfig[]>(`/admin/system/configs/${category}`)
  },

  updateConfig(key: string, value: any) {
    return request.patch<void>(`/admin/system/configs/${key}`, { value })
  },

  updateConfigs(configs: { key: string; value: any }[]) {
    return request.patch<void>('/admin/system/configs/batch', { configs })
  },

  getStatementSettings() {
    return request.get<{
      statementDay: number
      notifyMethods: string[]
      notifyBeforeDays: number
    }>('/admin/system/configs/statement')
  },

  updateStatementSettings(data: {
    statementDay: number
    notifyMethods: string[]
    notifyBeforeDays?: number
  }) {
    return request.patch<void>('/admin/system/configs/statement', data)
  },

  getNotificationSettings() {
    return request.get<{
      orderStatusNotify: boolean
      stockWarningNotify: boolean
      bucketOwedNotify: boolean
      statementGeneratedNotify: boolean
    }>('/admin/system/configs/notifications')
  },

  updateNotificationSettings(data: {
    orderStatusNotify?: boolean
    stockWarningNotify?: boolean
    bucketOwedNotify?: boolean
    statementGeneratedNotify?: boolean
  }) {
    return request.patch<void>('/admin/system/configs/notifications', data)
  },

  getBasicSettings() {
    return request.get<{
      systemName: string
      contactPhone: string
      contactEmail: string
      logo?: string
    }>('/admin/system/configs/basic')
  },

  updateBasicSettings(data: {
    systemName?: string
    contactPhone?: string
    contactEmail?: string
    logo?: string
  }) {
    return request.patch<void>('/admin/system/configs/basic', data)
  },

  getInventorySettings() {
    return request.get<{
      stockWarningThreshold: number
      autoReorder: boolean
    }>('/admin/system/configs/inventory')
  },

  updateInventorySettings(data: {
    stockWarningThreshold?: number
    autoReorder?: boolean
  }) {
    return request.patch<void>('/admin/system/configs/inventory', data)
  },

  getAllSettings() {
    return request.get<any>('/admin/system/settings/all')
  }
}
