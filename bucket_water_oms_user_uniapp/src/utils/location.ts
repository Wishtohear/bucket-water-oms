// 位置工具函数

export interface LocationResult {
  latitude: number
  longitude: number
  address?: string
  name?: string
}

// 获取当前位置
export const getCurrentLocation = (): Promise<UniApp.GetLocationSuccess> => {
  return new Promise((resolve, reject) => {
    uni.getLocation({
      type: 'gcj02',
      success: (res) => resolve(res),
      fail: (err) => reject(err)
    })
  })
}

// 计算两点之间的距离（公里）
export const calculateDistance = (
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number
): number => {
  const R = 6371
  const dLat = (lat2 - lat1) * Math.PI / 180
  const dLon = (lon2 - lon1) * Math.PI / 180
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2)
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  return Number((R * c).toFixed(2))
}

// 检查是否在配送范围内
export const isInDeliveryRange = (
  userLat: number,
  userLon: number,
  stationLat: number,
  stationLon: number,
  deliveryRange: number
): boolean => {
  const distance = calculateDistance(userLat, userLon, stationLat, stationLon)
  return distance <= deliveryRange
}

// 打开位置
export const openLocation = (
  latitude: number,
  longitude: number,
  name: string = '',
  address: string = ''
) => {
  uni.openLocation({
    latitude,
    longitude,
    name,
    address,
    scale: 18
  })
}

// 格式化距离
export const formatDistance = (distance: number): string => {
  if (distance < 1) {
    return `${Math.round(distance * 1000)}m`
  } else {
    return `${distance.toFixed(1)}km`
  }
}
