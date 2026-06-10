<template>
  <div>
    <!-- 操作按钮 -->
    <div class="mb-4 flex justify-end">
      <el-button type="primary" @click="goToExport">
        <el-icon><Download /></el-icon>
        导出报表
      </el-button>
    </div>

    <!-- 财务统计卡片 -->
    <el-row :gutter="16" class="mb-6">
      <el-col :span="6">
        <el-card shadow="never">
          <div class="flex items-center gap-4">
            <div class="p-3 bg-blue-50 text-blue-500 rounded-xl">
              <el-icon size="24"><Wallet /></el-icon>
            </div>
            <div>
              <p class="text-xs text-gray-400 mb-1">预存金总额</p>
              <h3 class="text-2xl font-bold">¥ {{ financeStore.summary.totalReceivable.toLocaleString() }}</h3>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never">
          <div class="flex items-center gap-4">
            <div class="p-3 bg-orange-50 text-orange-500 rounded-xl">
              <el-icon size="24"><Coin /></el-icon>
            </div>
            <div>
              <p class="text-xs text-gray-400 mb-1">应收款项</p>
              <h3 class="text-2xl font-bold">¥ {{ financeStore.summary.totalReceivable.toLocaleString() }}</h3>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never">
          <div class="flex items-center gap-4">
            <div class="p-3 bg-red-50 text-red-500 rounded-xl">
              <el-icon size="24"><WarningFilled /></el-icon>
            </div>
            <div>
              <p class="text-xs text-gray-400 mb-1">逾期款项</p>
              <h3 class="text-2xl font-bold text-red-500">¥ {{ financeStore.summary.totalUnpaid.toLocaleString() }}</h3>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never">
          <div class="flex items-center gap-4">
            <div class="p-3 bg-green-50 text-green-500 rounded-xl">
              <el-icon size="24"><Money /></el-icon>
            </div>
            <div>
              <p class="text-xs text-gray-400 mb-1">本月回款</p>
              <h3 class="text-2xl font-bold">¥ {{ financeStore.summary.totalPaid.toLocaleString() }}</h3>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 明细表格 -->
    <el-row :gutter="16">
      <el-col :span="12">
        <el-card shadow="never">
          <template #header>
            <div class="flex justify-between items-center">
              <span class="font-bold">应收款明细</span>
              <el-button type="success" plain size="small">导出Excel</el-button>
            </div>
          </template>
          <el-table :data="financeStore.receivables" stripe>
            <el-table-column label="水站名称" min-width="150">
              <template #default="{ row }">
                <span class="font-bold">{{ row.stationName || '-' }}</span>
              </template>
            </el-table-column>
            <el-table-column label="账期类型" width="100">
              <template #default="{ row }">
                {{ row.paymentType || row.type || '-' }}
              </template>
            </el-table-column>
            <el-table-column label="应收金额" width="120" align="right">
              <template #default="{ row }">
                <span class="font-bold">¥ {{ (row.amount || 0).toLocaleString() }}</span>
              </template>
            </el-table-column>
            <el-table-column label="状态" width="100">
              <template #default="{ row }">
                <el-tag :type="getReceivableTagType(row.status)" size="small">
                  {{ getReceivableStatusText(row.status) }}
                </el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card shadow="never">
          <template #header>
            <div class="flex justify-between items-center">
              <span class="font-bold">预存金余额明细</span>
              <el-button type="success" plain size="small">导出Excel</el-button>
            </div>
          </template>
          <el-table :data="financeStore.predeposits" stripe>
            <el-table-column label="水站名称" min-width="150">
              <template #default="{ row }">
                <span class="font-bold">{{ row.stationName || '-' }}</span>
              </template>
            </el-table-column>
            <el-table-column label="余额" width="120" align="right">
              <template #default="{ row }">
                <span class="font-bold">¥ {{ (row.balance || 0).toLocaleString() }}</span>
              </template>
            </el-table-column>
            <el-table-column label="最近充值" width="120" align="right">
              <template #default="{ row }">
                {{ row.createTime ? formatDate(row.createTime) : '-' }}
              </template>
            </el-table-column>
            <el-table-column label="状态" width="100">
              <template #default="{ row }">
                <el-tag :type="getBalanceTagType(row.balance)" size="small">
                  {{ getBalanceStatusText(row.balance || 0) }}
                </el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import {
  Download, Wallet, Coin, Money, WarningFilled
} from '@element-plus/icons-vue'
import { useFinanceStore } from '@/stores/finance'
import { stationsApi } from '@/api/stations'

const router = useRouter()

interface Station {
  id: string
  name: string
}

const financeStore = useFinanceStore()
const stations = ref<Station[]>([])

const loadData = async () => {
  try {
    await Promise.all([
      financeStore.fetchSummary(),
      financeStore.fetchReceivables(),
      financeStore.fetchPredeposits(),
      fetchStations()
    ])
  } catch (error) {
    console.error('加载财务数据失败:', error)
  }
}

const fetchStations = async () => {
  try {
    const res: any = await stationsApi.getAll()
    if (Array.isArray(res)) {
      stations.value = res
    }
  } catch (error) {
    console.error('获取水站列表失败:', error)
    stations.value = []
  }
}

const goToExport = () => {
  router.push('/finance/export')
}

const getReceivableStatusText = (status: string) => {
  if (!status) return '-'
  const statusMap: Record<string, string> = {
    paid: '已结清',
    PAID: '已结清',
    pending: '待付款',
    PENDING: '待付款',
    overdue: '已逾期',
    OVERDUE: '已逾期'
  }
  return statusMap[status] || status
}

const getReceivableTagType = (status: string) => {
  if (!status) return 'info'
  const statusMap: Record<string, string> = {
    paid: 'success',
    PAID: 'success',
    pending: 'warning',
    PENDING: 'warning',
    overdue: 'danger',
    OVERDUE: 'danger'
  }
  return statusMap[status] || 'info'
}

const getBalanceStatusText = (balance: number) => {
  if (balance >= 1000) return '余额充足'
  if (balance >= 500) return '余额一般'
  return '余额不足'
}

const getBalanceTagType = (balance: number | undefined) => {
  const b = balance || 0
  if (b >= 1000) return 'success'
  if (b >= 500) return 'warning'
  return 'danger'
}

const formatDate = (dateStr: string) => {
  if (!dateStr) return '-'
  return dateStr.split('T')[0]
}

onMounted(() => {
  loadData()
})
</script>

<style scoped>
:deep(.el-card) {
  border-radius: 16px;
}
:deep(.el-table) {
  border-radius: 8px;
}
</style>
