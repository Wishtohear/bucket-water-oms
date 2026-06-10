import { defineStore } from 'pinia'
import { ref } from 'vue'
import { regionApi, type RegionVO, type Region } from '@/api/region'

export const useRegionStore = defineStore('region', () => {
  const regions = ref<RegionVO[]>([])
  const regionTree = ref<RegionVO[]>([])
  const loading = ref(false)
  const total = ref(0)

  const fetchRegions = async (params?: { status?: string; level?: number }) => {
    loading.value = true
    try {
      const res = await regionApi.getAll(params)
      // 正确处理 API 响应：后端返回 { success, data, message, code }
      const response = res as any
      regions.value = Array.isArray(response?.data) ? response.data : []
      total.value = typeof response?.total === 'number' ? response.total : 0
      return response?.data || []
    } catch (error) {
      console.error('获取地域列表失败:', error)
      regions.value = []
      total.value = 0
      throw error
    } finally {
      loading.value = false
    }
  }

  const fetchRegionTree = async () => {
    loading.value = true
    try {
      const res = await regionApi.getTree()
      // 正确处理 API 响应：后端返回 { success, data, message, code }
      const response = res as any
      regionTree.value = Array.isArray(response?.data) ? response.data : []
      return response?.data || []
    } catch (error) {
      console.error('获取地域树失败:', error)
      regionTree.value = []
      throw error
    } finally {
      loading.value = false
    }
  }

  const createRegion = async (data: Region) => {
    const res = await regionApi.create(data)
    await fetchRegions()
    await fetchRegionTree() // 同时刷新树形结构，确保上级区域列表更新
    return res
  }

  const updateRegion = async (id: string, data: Region) => {
    const res = await regionApi.update(id, data)
    await fetchRegions()
    await fetchRegionTree()
    return res
  }

  const deleteRegion = async (id: string) => {
    try {
      await regionApi.delete(id)
      await fetchRegions()
      await fetchRegionTree()
    } catch (error) {
      console.error('删除地域失败:', error)
      throw error // 重新抛出错误，让调用方处理
    }
  }

  const enableRegion = async (id: string) => {
    await regionApi.enable(id)
    await fetchRegions()
  }

  const disableRegion = async (id: string) => {
    await regionApi.disable(id)
    await fetchRegions()
  }

  const getProvinces = async (): Promise<RegionVO[]> => {
    try {
      const res = await regionApi.getProvinces()
      // 正确处理 API 响应：后端返回 { success, data, message, code }
      const response = res as any
      return Array.isArray(response?.data) ? response.data : []
    } catch (error) {
      console.error('获取省份列表失败:', error)
      return []
    }
  }

  const getCities = async (provinceCode: string): Promise<RegionVO[]> => {
    try {
      const res = await regionApi.getCities(provinceCode)
      // 正确处理 API 响应：后端返回 { success, data, message, code }
      const response = res as any
      return Array.isArray(response?.data) ? response.data : []
    } catch (error) {
      console.error('获取城市列表失败:', error)
      return []
    }
  }

  const getDistricts = async (cityCode: string): Promise<RegionVO[]> => {
    try {
      const res = await regionApi.getDistricts(cityCode)
      // 正确处理 API 响应：后端返回 { success, data, message, code }
      const response = res as any
      return Array.isArray(response?.data) ? response.data : []
    } catch (error) {
      console.error('获取区县列表失败:', error)
      return []
    }
  }

  const getRegionName = (code: string): string => {
    const findRegion = (list: RegionVO[]): RegionVO | null => {
      if (!list || !Array.isArray(list)) return null
      for (const region of list) {
        if (region.code === code) {
          return region
        }
        if (region.children && Array.isArray(region.children)) {
          const found = findRegion(region.children)
          if (found) return found
        }
      }
      return null
    }
    const region = findRegion(regionTree.value || [])
    return region?.name || code
  }

  const getRegionOptions = (): { label: string; value: string }[] => {
    const options: { label: string; value: string }[] = []

    const flattenRegions = (list: RegionVO[] | undefined, prefix: string = '') => {
      if (!list || !Array.isArray(list)) return
      for (const region of list) {
        options.push({
          label: prefix + (region.name || ''),
          value: region.code || ''
        })
        if (region.children && Array.isArray(region.children) && region.children.length > 0) {
          flattenRegions(region.children, prefix + (region.name || '') + ' / ')
        }
      }
    }

    flattenRegions(regionTree.value)
    return options
  }

  return {
    regions,
    regionTree,
    loading,
    total,
    fetchRegions,
    fetchRegionTree,
    createRegion,
    updateRegion,
    deleteRegion,
    enableRegion,
    disableRegion,
    getProvinces,
    getCities,
    getDistricts,
    getRegionName,
    getRegionOptions
  }
})
