import { defineStore } from 'pinia'
import { ref } from 'vue'
import { financeApi, type StatementVO, type AccountDetailVO, type FinanceSummaryVO } from '@/api/finance'

export interface FinanceFilters {
  stationId?: string
  status?: string
  startDate?: string
  endDate?: string
}

export const useFinanceStore = defineStore('finance', () => {
  const statements = ref<StatementVO[]>([])
  const receivables = ref<any[]>([])
  const predeposits = ref<AccountDetailVO[]>([])
  const summary = ref<FinanceSummaryVO>({
    totalReceivable: 0,
    totalPaid: 0,
    totalUnpaid: 0,
    periodStart: '',
    periodEnd: ''
  })
  const loading = ref(false)

  const fetchStatements = async (filters?: FinanceFilters) => {
    loading.value = true
    try {
      const res: any = await financeApi.getStatements(filters)
      console.log('对账单API响应:', res)
      if (res.data) {
        statements.value = res.data.records || res.data.list || res.data || []
      } else if (Array.isArray(res)) {
        statements.value = res
      } else if (res.records) {
        statements.value = res.records
      } else {
        statements.value = []
      }
      console.log('解析后的对账单数据:', statements.value)
    } catch (error) {
      console.error('获取对账单列表失败:', error)
      statements.value = []
    } finally {
      loading.value = false
    }
  }

  const fetchReceivables = async (filters?: FinanceFilters) => {
    loading.value = true
    try {
      const res: any = await financeApi.getReceivables(filters)
      console.log('应收款API响应:', res)
      if (res.data) {
        receivables.value = res.data.records || res.data.list || res.data || []
      } else if (Array.isArray(res)) {
        receivables.value = res
      } else if (res.records) {
        receivables.value = res.records
      } else {
        receivables.value = []
      }
      console.log('解析后的应收款数据:', receivables.value)
    } catch (error) {
      console.error('获取应收款明细失败:', error)
      receivables.value = []
    } finally {
      loading.value = false
    }
  }

  const fetchPredeposits = async (stationId?: string) => {
    loading.value = true
    try {
      const res: any = await financeApi.getPredeposits({ stationId })
      console.log('预存金API响应:', res)
      if (res.data) {
        predeposits.value = res.data.records || res.data.list || res.data || []
      } else if (Array.isArray(res)) {
        predeposits.value = res
      } else if (res.records) {
        predeposits.value = res.records
      } else {
        predeposits.value = []
      }
      console.log('解析后的预存金数据:', predeposits.value)
    } catch (error) {
      console.error('获取预存金明细失败:', error)
      predeposits.value = []
    } finally {
      loading.value = false
    }
  }

  const fetchSummary = async () => {
    try {
      const res: any = await financeApi.getSummary()
      if (res.data) {
        summary.value = res.data
      }
    } catch (error) {
      console.error('获取财务汇总失败:', error)
    }
  }

  const confirmStatement = async (id: string) => {
    try {
      await financeApi.confirmStatement(id)
      return { success: true }
    } catch (error) {
      console.error('确认对账单失败:', error)
      return { success: false, message: '确认对账单失败' }
    }
  }

  const handleDispute = async (id: string, resolution: string) => {
    try {
      await financeApi.handleDispute(id, resolution)
      return { success: true }
    } catch (error) {
      console.error('处理对账争议失败:', error)
      return { success: false, message: '处理对账争议失败' }
    }
  }

  return {
    statements,
    receivables,
    predeposits,
    summary,
    loading,
    fetchStatements,
    fetchReceivables,
    fetchPredeposits,
    fetchSummary,
    confirmStatement,
    handleDispute
  }
})
