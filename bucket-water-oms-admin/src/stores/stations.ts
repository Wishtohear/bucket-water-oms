import { defineStore } from 'pinia'
import { ref } from 'vue'
import { stationsApi, type StationVO, type StationManagementDTO } from '@/api/stations'

export interface StationFilters {
  search: string
  status: string
  balance: string
}

export const useStationStore = defineStore('station', () => {
  const stations = ref<StationVO[]>([])
  const loading = ref(false)
  const total = ref(0)
  const currentPage = ref(1)
  const pageSize = ref(10)

  const fetchStations = async (filters?: StationFilters, page = 1) => {
    loading.value = true
    currentPage.value = page
    try {
      const params: any = {
        page,
        size: pageSize.value
      }
      if (filters?.status) {
        params.status = filters.status
      }
      if (filters?.search) {
        params.search = filters.search
      }

      const res: any = await stationsApi.getAll(params)
      console.log('水站列表API响应:', res)

      if (res.data) {
        stations.value = res.data.records || res.data.list || res.data || []
        total.value = res.data.total || stations.value.length
      } else if (Array.isArray(res)) {
        stations.value = res
        total.value = res.length
      } else if (res.records) {
        stations.value = res.records
        total.value = res.total || res.records.length
      } else {
        stations.value = []
        total.value = 0
      }
      console.log('解析后的水站数据:', stations.value, '总数:', total.value)
    } catch (error) {
      console.error('获取水站列表失败:', error)
      stations.value = []
      total.value = 0
    } finally {
      loading.value = false
    }
  }

  const createStation = async (data: StationManagementDTO) => {
    loading.value = true
    try {
      await stationsApi.create(data)
      await fetchStations(undefined, currentPage.value)
      return { success: true }
    } catch (error) {
      console.error('创建水站失败:', error)
      return { success: false, message: '创建水站失败' }
    } finally {
      loading.value = false
    }
  }

  const updateStation = async (id: string, data: StationManagementDTO) => {
    loading.value = true
    try {
      await stationsApi.update(id, data)
      await fetchStations(undefined, currentPage.value)
      return { success: true }
    } catch (error) {
      console.error('更新水站失败:', error)
      return { success: false, message: '更新水站失败' }
    } finally {
      loading.value = false
    }
  }

  const deleteStation = async (id: string) => {
    loading.value = true
    try {
      await stationsApi.delete(id)
      await fetchStations(undefined, currentPage.value)
      return { success: true }
    } catch (error) {
      console.error('删除水站失败:', error)
      return { success: false, message: '删除水站失败' }
    } finally {
      loading.value = false
    }
  }

  const assignPolicy = async (stationId: string, policyId: string) => {
    try {
      await stationsApi.assignPolicy(stationId, policyId)
      return { success: true }
    } catch (error) {
      console.error('分配政策失败:', error)
      return { success: false, message: '分配政策失败' }
    }
  }

  return {
    stations,
    loading,
    total,
    currentPage,
    pageSize,
    fetchStations,
    createStation,
    updateStation,
    deleteStation,
    assignPolicy
  }
})
