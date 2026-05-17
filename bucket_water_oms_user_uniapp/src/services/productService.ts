// 商品服务
import { get } from '@/utils/request'

export interface Product {
  id: string
  stationId: string
  name: string
  category: string
  price: number
  originalPrice?: number
  stock: number
  unit: string
  image: string
  description: string
  specifications?: string
  isHot?: boolean
  isNew?: boolean
}

export interface PageResult<T> {
  list: T[]
  total: number
  page: number
  pageSize: number
}

export const productService = {
  // 获取商品列表
  async getProducts(params: {
    stationId: string
    category?: string
    keyword?: string
    page?: number
    pageSize?: number
  }) {
    return get<PageResult<Product>>('/products', params)
  },

  // 获取商品详情
  async getProductDetail(productId: string) {
    return get<Product>(`/products/${productId}`)
  },

  // 获取商品分类
  async getCategories() {
    return get<string[]>('/products/categories')
  },

  // 搜索商品
  async searchProducts(params: {
    keyword: string
    stationId?: string
    page?: number
    pageSize?: number
  }) {
    return get<PageResult<Product>>('/products/search', params)
  }
}
