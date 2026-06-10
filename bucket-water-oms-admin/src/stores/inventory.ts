import { defineStore } from 'pinia'
import { ref } from 'vue'
import { inventoryApi, type InboundRecordDTO, type OutboundRecordDTO } from '@/api/inventory'

export interface InventorySummary {
  totalStock: number
  totalIn: number
  totalOut: number
  lowStockCount: number
  damagedCount: number
  damageRate: string
}

export interface InventoryFilters {
  warehouseId?: string
  productId?: string
  businessType?: string
  dateRange?: 'today' | 'week' | 'month'
}

export interface InventoryRecord {
  id: string
  createTime: string
  type: string
  productName: string
  productId: string
  quantity: number
  warehouseName: string
  operator: string
}

export interface WarehouseOverview {
  warehouseId: string
  warehouseName: string
  status: string
  stocks: Array<{
    productId: string
    productName: string
    category: string
    quantity: number
    safeStock: number
    status: string
    statusText: string
  }>
}

export interface ProductOverview {
  productId: string
  productName: string
  category: string
  categoryText: string
  totalQuantity: number
  safeStock: number
  status: string
}

export const useInventoryStore = defineStore('inventory', () => {
  const inventoryRecords = ref<InventoryRecord[]>([])
  const summary = ref<InventorySummary>({
    totalStock: 0,
    totalIn: 0,
    totalOut: 0,
    lowStockCount: 0,
    damagedCount: 0,
    damageRate: '0.00'
  })
  const warehouseOverview = ref<WarehouseOverview[]>([])
  const productOverview = ref<ProductOverview[]>([])
  const lastUpdateTime = ref<string>('')
  const loading = ref(false)

  const fetchInventoryList = async (filters?: InventoryFilters) => {
    loading.value = true
    try {
      const res: any = await inventoryApi.getInventoryRecords({
        warehouseId: filters?.warehouseId,
        productId: filters?.productId,
        businessType: filters?.businessType,
        dateRange: filters?.dateRange || 'week'
      })
      console.log('库存记录API响应:', res)
      
      if (res.data && Array.isArray(res.data)) {
        inventoryRecords.value = res.data.map((record: any) => ({
          id: record.id || '',
          createTime: record.operateTime || '',
          type: record.businessType || '',
          productName: record.productName || '',
          productId: '',
          quantity: record.quantityChange || 0,
          warehouseName: record.relatedObject || '',
          operator: record.operator || ''
        }))
      } else if (Array.isArray(res)) {
        inventoryRecords.value = res.map((record: any) => ({
          id: record.id || '',
          createTime: record.operateTime || '',
          type: record.businessType || '',
          productName: record.productName || '',
          productId: '',
          quantity: record.quantityChange || 0,
          warehouseName: record.relatedObject || '',
          operator: record.operator || ''
        }))
      } else {
        inventoryRecords.value = []
      }
      console.log('解析后的库存数据:', inventoryRecords.value)
    } catch (error) {
      console.error('获取库存列表失败:', error)
      inventoryRecords.value = []
    } finally {
      loading.value = false
    }
  }

  const fetchInventorySummary = async (warehouseId?: string) => {
    try {
      const res: any = await inventoryApi.getInventoryOverview(warehouseId)
      console.log('库存概览API响应:', res)
      
      if (res.data) {
        lastUpdateTime.value = res.data.lastUpdateTime || new Date().toLocaleString()
        warehouseOverview.value = res.data.warehouses || []
        productOverview.value = res.data.products || []
        
        let totalStock = 0
        let lowStockCount = 0
        let totalIn = 0
        let totalOut = 0
        let damagedCount = 0
        
        for (const product of productOverview.value) {
          totalStock += product.totalQuantity || 0
          if (product.status === 'warning') {
            lowStockCount++
          }
        }
        
        for (const record of inventoryRecords.value) {
          if (record.type === 'sales_outbound' || record.type === 'outbound') {
            totalOut += Math.abs(record.quantity)
          } else if (record.type === 'production_inbound' || record.type === 'return' || record.type === 'inbound') {
            totalIn += record.quantity
          }
          if (record.type === 'damage') {
            damagedCount += Math.abs(record.quantity)
          }
        }
        
        const damageRate = totalStock > 0 ? ((damagedCount / totalStock) * 100).toFixed(2) : '0.00'
        
        summary.value = {
          totalStock,
          totalIn,
          totalOut,
          lowStockCount,
          damagedCount,
          damageRate
        }
      }
    } catch (error) {
      console.error('获取库存概览失败:', error)
    }
  }

  const fetchInventoryStats = async () => {
    try {
      const res: any = await inventoryApi.getInventoryStats()
      console.log('库存统计API响应:', res)
    } catch (error) {
      console.error('获取库存统计失败:', error)
    }
  }

  const recordInbound = async (data: InboundRecordDTO) => {
    loading.value = true
    try {
      await inventoryApi.recordInbound(data)
      return { success: true }
    } catch (error) {
      console.error('入库登记失败:', error)
      return { success: false, message: '入库登记失败' }
    } finally {
      loading.value = false
    }
  }

  const recordOutbound = async (data: OutboundRecordDTO) => {
    loading.value = true
    try {
      await inventoryApi.recordOutbound(data)
      return { success: true }
    } catch (error) {
      console.error('出库登记失败:', error)
      return { success: false, message: '出库登记失败' }
    } finally {
      loading.value = false
    }
  }

  return {
    inventoryRecords,
    summary,
    warehouseOverview,
    productOverview,
    lastUpdateTime,
    loading,
    fetchInventoryList,
    fetchInventorySummary,
    fetchInventoryStats,
    recordInbound,
    recordOutbound
  }
})
