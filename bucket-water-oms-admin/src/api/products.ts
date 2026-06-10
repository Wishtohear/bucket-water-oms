import request from '@/utils/request'

export interface Product {
  id?: string
  code?: string
  name: string
  category: string
  spec?: string
  factoryPrice: number
  guidePriceMin?: number
  guidePriceMax?: number
  unit: string
  minStock?: number
  description?: string
  status?: string
  remark?: string
}

export interface ProductVO {
  id: string
  code: string
  name: string
  category: string
  spec: string
  factoryPrice: number
  guidePriceMin: number
  guidePriceMax: number
  unit: string
  minStock: number
  stock: number
  image?: string
  description: string
  status: 'active' | 'inactive'
  createTime: string
  updateTime: string
  remark?: string
}

export interface ProductCategory {
  value: string
  label: string
  count: number
  stock: number
}

export interface ProductWarehouseInventory {
  warehouseId: number
  warehouseName: string
  warehouseType: string
  stock: number
  minStock: number
}

export interface RecentInventoryRecord {
  id: number
  warehouseName: string
  type: string
  quantity: number
  time: string
}

export const productsApi = {
  getAll(params?: { category?: string; status?: string; keyword?: string }) {
    return request.get<ProductVO[], { data: ProductVO[], total: number }>('/admin/products', { params })
  },

  getById(id: string) {
    return request.get<ProductVO>(`/admin/products/${id}`)
  },

  create(data: Product) {
    return request.post<ProductVO>(`/admin/products`, data)
  },

  update(id: string, data: Product) {
    return request.put<ProductVO>(`/admin/products/${id}`, data)
  },

  delete(id: string) {
    return request.delete<void>(`/admin/products/${id}`)
  },

  updateStatus(id: string, status: 'active' | 'inactive') {
    return request.patch<void>(`/admin/products/${id}/status`, { status })
  },

  getCategories() {
    return request.get<ProductCategory[]>('/admin/products/categories')
  },

  getStats() {
    return request.get<{
      bucketWater: { count: number; stock: number }
      bottleWater: { count: number; stock: number }
      equipment: { count: number; stock: number; warning: number }
      other: { count: number; stock: number }
    }>('/admin/products/stats')
  },

  getWarehouseInventory(id: string) {
    return request.get<ProductWarehouseInventory[], { data: ProductWarehouseInventory[] }>(`/admin/products/${id}/warehouse-inventory`)
  },

  batchUpdatePrice(ids: string[], price: number) {
    return request.patch<void>('/admin/products/batch-price', { ids, price })
  },

  exportProducts(params?: { category?: string; status?: string }) {
    return request.get<Blob>('/admin/products/export', {
      params,
      responseType: 'blob'
    })
  }
}
