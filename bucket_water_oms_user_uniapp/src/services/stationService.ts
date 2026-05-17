// 水站服务
import { get, post, del } from '@/utils/request'

export interface Station {
  id: string
  name: string
  address: string
  phone: string
  latitude: number
  longitude: number
  deliveryRange: number
  rating: number
  logo?: string
  businessHours: string
  isOpen: boolean
  distance?: number
  salesCount?: number
}

export interface StationDetail extends Station {
  products: Product[]
  canDelivery: boolean
}

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

export const stationService = {
  // 获取附近水站
  async getNearbyStations(params: {
    latitude?: number
    longitude?: number
    radius?: number
    sortBy?: 'distance' | 'rating' | 'sales'
    page?: number
    pageSize?: number
  }) {
    return get<PageResult<Station>>('/stations/nearby', params)
  },

  // 获取水站详情
  async getStationDetail(stationId: string) {
    return get<StationDetail>(`/stations/${stationId}`)
  },

  // 搜索水站
  async searchStations(params: {
    keyword: string
    latitude?: number
    longitude?: number
    page?: number
    pageSize?: number
  }) {
    return get<PageResult<Station>>('/stations/search', params)
  },

  // 获取收藏的水站列表
  async getFavoriteStations() {
    return get<Station[]>('/users/favorites')
  },

  // 收藏水站
  async addFavorite(stationId: string) {
    return post(`/users/favorites/${stationId}`)
  },

  // 取消收藏水站
  async removeFavorite(stationId: string) {
    return del(`/users/favorites/${stationId}`)
  },

  // 检查是否已收藏
  async checkFavorite(stationId: string) {
    return get<boolean>(`/users/favorites/check/${stationId}`)
  }
}
