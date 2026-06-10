import request from '@/utils/request'

export interface AuditLog {
  id: number
  userId: number
  username: string
  userRole: string
  action: string
  module: string
  entityType: string
  entityId: string
  entityName: string
  method: string
  requestUrl: string
  requestMethod: string
  ipAddress: string
  requestParams: string
  responseStatus: number
  errorMessage: string
  createTime: string
}

export interface AuditLogQuery {
  userId?: number
  username?: string
  action?: string
  module?: string
  entityType?: string
  entityId?: string
  startTime?: string
  endTime?: string
  page?: number
  pageSize?: number
}

export interface PageResult<T> {
  records: T[]
  total: number
  size: number
  current: number
  pages: number
}

export interface ApiResponse<T> {
  success: boolean
  code: string
  message: string
  data: T
}

export const auditLogsApi = {
  query: (params?: AuditLogQuery) => {
    return request.get('/admin/audit-logs', { params }).then((res: any) => {
      return res.data as PageResult<AuditLog>
    })
  },

  getRecent: (limit?: number) => {
    return request.get('/admin/audit-logs/recent', { params: { limit } }).then((res: any) => {
      return res.data as AuditLog[]
    })
  },

  getById: (id: number) => {
    return request.get(`/admin/audit-logs/${id}`).then((res: any) => {
      return res.data as AuditLog | null
    })
  },

  getDebugCount: () => {
    return request.get('/admin/audit-logs/debug/count').then((res: any) => {
      return res.data
    })
  },

  deleteAll: () => {
    return request.delete('/admin/audit-logs').then((res: any) => {
      return res.data
    })
  }
}
