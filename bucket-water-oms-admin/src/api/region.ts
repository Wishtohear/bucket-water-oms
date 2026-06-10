import request from '@/utils/request'

// 后端 API 响应格式
export interface ApiResponse<T = any> {
  success: boolean
  data: T
  message: string
  code: string
}

// 地域视图对象
export interface RegionVO {
  id: string
  code: string
  name: string
  parentCode?: string | null
  level: number
  sort: number
  status: 'active' | 'inactive'
  remark?: string | null
  children?: RegionVO[]
}

// 创建/更新地域请求
export interface Region {
  code: string
  name: string
  parentCode?: string | null
  level?: number
  sort?: number
  status?: 'active' | 'inactive'
  remark?: string | null
}

// 地域列表响应
interface RegionListResponse {
  data: RegionVO[]
  total: number
}

export const regionApi = {
  /**
   * 获取所有地域列表
   */
  getAll(params?: { status?: string; level?: number }) {
    return request.get<ApiResponse<RegionListResponse>>('/admin/regions', { params })
  },

  /**
   * 获取地域树形结构
   */
  getTree() {
    return request.get<ApiResponse<RegionVO[]>>('/admin/regions/tree')
  },

  /**
   * 根据 ID 获取地域详情
   */
  getById(id: string) {
    return request.get<ApiResponse<RegionVO>>(`/admin/regions/${id}`)
  },

  /**
   * 根据编码获取地域详情
   */
  getByCode(code: string) {
    return request.get<ApiResponse<RegionVO>>(`/admin/regions/code/${code}`)
  },

  /**
   * 获取子地域列表
   */
  getChildren(parentCode: string) {
    return request.get<ApiResponse<RegionVO[]>>(`/admin/regions/children/${parentCode}`)
  },

  /**
   * 获取所有省份
   */
  getProvinces() {
    return request.get<ApiResponse<RegionVO[]>>('/admin/regions/provinces')
  },

  /**
   * 获取指定省份下的城市
   */
  getCities(provinceCode: string) {
    return request.get<ApiResponse<RegionVO[]>>(`/admin/regions/cities/${provinceCode}`)
  },

  /**
   * 获取指定城市下的区县
   */
  getDistricts(cityCode: string) {
    return request.get<ApiResponse<RegionVO[]>>(`/admin/regions/districts/${cityCode}`)
  },

  /**
   * 创建地域
   */
  create(data: Region) {
    return request.post<ApiResponse<RegionVO>>('/admin/regions', data)
  },

  /**
   * 更新地域
   */
  update(id: string, data: Region) {
    return request.put<ApiResponse<RegionVO>>(`/admin/regions/${id}`, data)
  },

  /**
   * 删除地域
   */
  delete(id: string) {
    return request.delete<ApiResponse<void>>(`/admin/regions/${id}`)
  },

  /**
   * 启用地域
   */
  enable(id: string) {
    return request.patch<ApiResponse<void>>(`/admin/regions/${id}/enable`)
  },

  /**
   * 停用地域
   */
  disable(id: string) {
    return request.patch<ApiResponse<void>>(`/admin/regions/${id}/disable`)
  },

  /**
   * 更新排序
   */
  updateSort(id: string, sort: number) {
    return request.patch<ApiResponse<void>>(`/admin/regions/${id}/sort`, { sort })
  },

  /**
   * 批量更新地域
   */
  batchUpdate(data: RegionVO[]) {
    return request.patch<ApiResponse<void>>('/admin/regions/batch', { regions: data })
  }
}
