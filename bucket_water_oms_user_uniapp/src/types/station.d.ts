// 水站相关类型定义
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
