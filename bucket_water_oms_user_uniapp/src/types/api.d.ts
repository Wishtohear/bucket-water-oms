// API 响应类型定义
export interface ApiResponse<T = any> {
  success: boolean
  data?: T
  message?: string
  code?: number
}

export interface PageResult<T = any> {
  list: T[]
  total: number
  page: number
  pageSize: number
}

export interface RequestOptions {
  url: string
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE'
  data?: any
  header?: Record<string, string>
  loading?: boolean
}
