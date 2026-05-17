// 水站状态管理
import { defineStore } from 'pinia'
import { stationService, Station, StationDetail } from '@/services/stationService'

export const useStationStore = defineStore('station', {
  state: () => ({
    nearbyStations: [] as Station[],
    currentStation: null as StationDetail | null,
    favoriteStations: [] as Station[],
    loading: false,
    page: 1,
    pageSize: 10,
    hasMore: true,
    searchKeyword: '',
    selectedLocation: null as { latitude: number; longitude: number } | null
  }),

  getters: {
    stationCount: (state) => state.nearbyStations.length,
    favoriteCount: (state) => state.favoriteStations.length,
    isFavorite: (state) => (stationId: string) => {
      return state.favoriteStations.some(s => s.id === stationId)
    }
  },

  actions: {
    // 获取附近水站
    async fetchNearbyStations(params?: {
      latitude?: number
      longitude?: number
      sortBy?: 'distance' | 'rating' | 'sales'
      reset?: boolean
    }) {
      this.loading = true

      try {
        if (params?.reset) {
          this.page = 1
          this.hasMore = true
        }

        const result = await stationService.getNearbyStations({
          latitude: params?.latitude ?? this.selectedLocation?.latitude,
          longitude: params?.longitude ?? this.selectedLocation?.longitude,
          sortBy: params?.sortBy ?? 'distance',
          page: this.page,
          pageSize: this.pageSize
        })

        if (result) {
          if (params?.reset) {
            this.nearbyStations = result.list
          } else {
            this.nearbyStations = [...this.nearbyStations, ...result.list]
          }

          this.hasMore = result.list.length >= this.pageSize
        }
      } catch (error) {
        console.error('获取附近水站失败:', error)
      } finally {
        this.loading = false
      }
    },

    // 加载更多
    async loadMore() {
      if (!this.hasMore || this.loading) return
      this.page++
      await this.fetchNearbyStations()
    },

    // 刷新
    async refresh(params?: {
      latitude?: number
      longitude?: number
      sortBy?: 'distance' | 'rating' | 'sales'
    }) {
      this.page = 1
      this.hasMore = true
      await this.fetchNearbyStations({ ...params, reset: true })
    },

    // 获取水站详情
    async fetchStationDetail(stationId: string) {
      this.loading = true

      try {
        const result = await stationService.getStationDetail(stationId)
        if (result) {
          this.currentStation = result
        }
        return result
      } catch (error) {
        console.error('获取水站详情失败:', error)
        return null
      } finally {
        this.loading = false
      }
    },

    // 搜索水站
    async searchStations(keyword: string) {
      this.loading = true
      this.searchKeyword = keyword

      try {
        const result = await stationService.searchStations({
          keyword,
          latitude: this.selectedLocation?.latitude,
          longitude: this.selectedLocation?.longitude,
          page: 1,
          pageSize: this.pageSize * 3
        })

        if (result) {
          return result.list
        }
        return []
      } catch (error) {
        console.error('搜索水站失败:', error)
        return []
      } finally {
        this.loading = false
      }
    },

    // 获取收藏列表
    async fetchFavorites() {
      try {
        const result = await stationService.getFavoriteStations()
        if (result) {
          this.favoriteStations = result
        }
      } catch (error) {
        console.error('获取收藏列表失败:', error)
      }
    },

    // 添加收藏
    async addFavorite(stationId: string) {
      try {
        await stationService.addFavorite(stationId)
        await this.fetchFavorites()
        return true
      } catch (error) {
        console.error('添加收藏失败:', error)
        return false
      }
    },

    // 取消收藏
    async removeFavorite(stationId: string) {
      try {
        await stationService.removeFavorite(stationId)
        await this.fetchFavorites()
        return true
      } catch (error) {
        console.error('取消收藏失败:', error)
        return false
      }
    },

    // 切换收藏状态
    async toggleFavorite(stationId: string) {
      const isFav = this.isFavorite(stationId)
      if (isFav) {
        return await this.removeFavorite(stationId)
      } else {
        return await this.addFavorite(stationId)
      }
    },

    // 设置位置
    setLocation(latitude: number, longitude: number) {
      this.selectedLocation = { latitude, longitude }
    },

    // 清除水站详情
    clearCurrentStation() {
      this.currentStation = null
    }
  }
})
