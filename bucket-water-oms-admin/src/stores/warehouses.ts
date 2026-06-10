import { defineStore } from 'pinia'
import { ref } from 'vue'
import { warehousesApi, type WarehouseVO, type WarehouseManagementDTO } from '@/api/warehouses'

export interface WarehouseFilters {
  search: string
  status: string
}

export const useWarehouseStore = defineStore('warehouse', () => {
  const warehouses = ref<WarehouseVO[]>([])
  const loading = ref(false)
  const total = ref(0)
  const currentPage = ref(1)
  const pageSize = ref(10)

  const fetchWarehouses = async (filters?: WarehouseFilters, page = 1) => {
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

      const res: any = await warehousesApi.getAll(params)
      console.log('仓库列表API响应:', res)

      if (res.data) {
        warehouses.value = res.data.records || res.data.list || res.data || []
        total.value = res.data.total || warehouses.value.length
      } else if (Array.isArray(res)) {
        warehouses.value = res
        total.value = res.length
      } else if (res.records) {
        warehouses.value = res.records
        total.value = res.total || res.records.length
      } else {
        warehouses.value = []
        total.value = 0
      }
      console.log('解析后的仓库数据:', warehouses.value, '总数:', total.value)
    } catch (error) {
      console.error('获取仓库列表失败:', error)
      warehouses.value = []
      total.value = 0
    } finally {
      loading.value = false
    }
  }

  const createWarehouse = async (data: WarehouseManagementDTO) => {
    loading.value = true
    try {
      await warehousesApi.create(data)
      await fetchWarehouses(undefined, currentPage.value)
      return { success: true }
    } catch (error) {
      console.error('创建仓库失败:', error)
      return { success: false, message: '创建仓库失败' }
    } finally {
      loading.value = false
    }
  }

  const updateWarehouse = async (id: string, data: WarehouseManagementDTO) => {
    loading.value = true
    try {
      await warehousesApi.update(id, data)
      await fetchWarehouses(undefined, currentPage.value)
      return { success: true }
    } catch (error) {
      console.error('更新仓库失败:', error)
      return { success: false, message: '更新仓库失败' }
    } finally {
      loading.value = false
    }
  }

  const deleteWarehouse = async (id: string) => {
    loading.value = true
    try {
      await warehousesApi.delete(id)
      await fetchWarehouses(undefined, currentPage.value)
      return { success: true }
    } catch (error) {
      console.error('删除仓库失败:', error)
      return { success: false, message: '删除仓库失败' }
    } finally {
      loading.value = false
    }
  }

  const getWarehouseInventory = async (warehouseId: string) => {
    try {
      const res: any = await warehousesApi.getInventory(warehouseId)
      return { success: true, data: res.data }
    } catch (error) {
      console.error('获取仓库库存失败:', error)
      return { success: false, message: '获取仓库库存失败' }
    }
  }

  return {
    warehouses,
    loading,
    total,
    currentPage,
    pageSize,
    fetchWarehouses,
    createWarehouse,
    updateWarehouse,
    deleteWarehouse,
    getWarehouseInventory
  }
})
