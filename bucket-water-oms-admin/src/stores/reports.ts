import { defineStore } from 'pinia'
import { ref } from 'vue'
import { reportsApi, type SalesTrend, type ProductSales, type StationRanking, type BucketStatsSummary, type StationBucketReport, type WarehouseBucketReport, type InTransitBucket } from '@/api/reports'

export interface ReportFilters {
  startDate?: string
  endDate?: string
}

export const useReportStore = defineStore('report', () => {
  const salesTrend = ref<SalesTrend[]>([])
  const productSales = ref<ProductSales[]>([])
  const stationRanking = ref<StationRanking[]>([])
  const dailySales = ref<any[]>([])
  const bucketSummary = ref<BucketStatsSummary | null>(null)
  const stationBucketReport = ref<StationBucketReport[]>([])
  const warehouseBucketReport = ref<WarehouseBucketReport[]>([])
  const inTransitBuckets = ref<InTransitBucket[]>([])
  const driverStatsSummary = ref<any>(null)
  const loading = ref(false)

  const fetchSalesTrend = async (filters?: ReportFilters) => {
    loading.value = true
    try {
      const res: any = await reportsApi.getSalesTrend(filters)
      if (res.data) {
        salesTrend.value = res.data
      } else {
        salesTrend.value = []
      }
    } catch (error) {
      console.error('获取销售趋势失败:', error)
      salesTrend.value = []
    } finally {
      loading.value = false
    }
  }

  const fetchProductSales = async (filters?: ReportFilters) => {
    loading.value = true
    try {
      const res: any = await reportsApi.getProductSales(filters)
      if (res.data) {
        productSales.value = res.data
      } else {
        productSales.value = []
      }
    } catch (error) {
      console.error('获取产品销量失败:', error)
      productSales.value = []
    } finally {
      loading.value = false
    }
  }

  const fetchStationRanking = async (filters?: ReportFilters & { limit?: number }) => {
    loading.value = true
    try {
      const res: any = await reportsApi.getStationRanking(filters)
      if (res.data) {
        stationRanking.value = res.data
      } else {
        stationRanking.value = []
      }
    } catch (error) {
      console.error('获取水站排行失败:', error)
      stationRanking.value = []
    } finally {
      loading.value = false
    }
  }

  const fetchDailySales = async (date?: string) => {
    loading.value = true
    try {
      const res: any = await reportsApi.getDailySales({ startDate: date, endDate: date })
      console.log('日报表API响应:', res)
      if (res.data) {
        dailySales.value = res.data.records || res.data.list || res.data || []
      } else if (Array.isArray(res)) {
        dailySales.value = res
      } else if (res.records) {
        dailySales.value = res.records
      } else {
        dailySales.value = []
      }
      console.log('解析后的日报表数据:', dailySales.value)
    } catch (error) {
      console.error('获取日报表失败:', error)
      dailySales.value = []
    } finally {
      loading.value = false
    }
  }

  const fetchBucketStatsSummary = async () => {
    loading.value = true
    try {
      const res: any = await reportsApi.getBucketStatsSummary()
      if (res.data) {
        bucketSummary.value = res.data
      }
    } catch (error) {
      console.error('获取空桶统计汇总失败:', error)
      bucketSummary.value = null
    } finally {
      loading.value = false
    }
  }

  const fetchStationBucketReport = async () => {
    loading.value = true
    try {
      const res: any = await reportsApi.getStationBucketReport()
      if (res.data) {
        stationBucketReport.value = res.data
      } else {
        stationBucketReport.value = []
      }
    } catch (error) {
      console.error('获取水站欠桶报表失败:', error)
      stationBucketReport.value = []
    } finally {
      loading.value = false
    }
  }

  const fetchWarehouseBucketReport = async () => {
    loading.value = true
    try {
      const res: any = await reportsApi.getWarehouseBucketReport()
      if (res.data) {
        warehouseBucketReport.value = res.data
      } else {
        warehouseBucketReport.value = []
      }
    } catch (error) {
      console.error('获取仓库空桶报表失败:', error)
      warehouseBucketReport.value = []
    } finally {
      loading.value = false
    }
  }

  const fetchInTransitBuckets = async () => {
    loading.value = true
    try {
      const res: any = await reportsApi.getInTransitBuckets()
      if (res.data) {
        inTransitBuckets.value = res.data
      } else {
        inTransitBuckets.value = []
      }
    } catch (error) {
      console.error('获取在途空桶失败:', error)
      inTransitBuckets.value = []
    } finally {
      loading.value = false
    }
  }

  const fetchDriverStatsSummary = async (filters?: ReportFilters) => {
    loading.value = true
    try {
      const res: any = await reportsApi.getDriverStatsSummary(filters)
      if (res.data) {
        driverStatsSummary.value = res.data
      }
    } catch (error) {
      console.error('获取司机统计汇总失败:', error)
      driverStatsSummary.value = null
    } finally {
      loading.value = false
    }
  }

  return {
    salesTrend,
    productSales,
    stationRanking,
    dailySales,
    bucketSummary,
    stationBucketReport,
    warehouseBucketReport,
    inTransitBuckets,
    driverStatsSummary,
    loading,
    fetchSalesTrend,
    fetchProductSales,
    fetchStationRanking,
    fetchDailySales,
    fetchBucketStatsSummary,
    fetchStationBucketReport,
    fetchWarehouseBucketReport,
    fetchInTransitBuckets,
    fetchDriverStatsSummary
  }
})
