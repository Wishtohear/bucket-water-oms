<template>
  <div class="warehouse-inbound">
    <el-card shadow="never" class="mb-4">
      <template #header>
        <div class="header">
          <div>
            <h2 class="page-title">库存变动管理</h2>
            <p class="page-desc">管理每个产品的出入库记录和库存盘点</p>
          </div>
          <div class="header-actions">
            <el-button @click="goToCreate" type="primary">
              <el-icon><Plus /></el-icon>
              新增入库
            </el-button>
          </div>
        </div>
      </template>
      <el-radio-group v-model="activeTab" @change="handleTabChange">
        <el-radio-button value="all">全部记录</el-radio-button>
        <el-radio-button value="inbound">入库记录</el-radio-button>
        <el-radio-button value="outbound">出库记录</el-radio-button>
        <el-radio-button value="check">盘点记录</el-radio-button>
      </el-radio-group>
    </el-card>

    <el-card shadow="never" class="mb-4" v-if="activeTab !== 'check'">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="产品">
          <el-select v-model="searchForm.productId" placeholder="选择产品" clearable filterable style="width: 200px">
            <el-option v-for="p in products" :key="p.id" :label="p.name" :value="p.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="日期范围">
          <el-date-picker
            v-model="searchForm.dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            value-format="YYYY-MM-DD"
            style="width: 240px"
          />
        </el-form-item>
        <el-form-item label="订单号">
          <el-input v-model="searchForm.relatedOrderNo" placeholder="输入订单号" clearable style="width: 160px" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">
            <el-icon><Search /></el-icon>
            查询
          </el-button>
          <el-button @click="handleReset">
            <el-icon><Refresh /></el-icon>
            重置
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never" v-loading="loading">
      <template #header>
        <div class="table-header">
          <span>{{ tabTitle }}</span>
          <span class="total-count">共 {{ tableData.length }} 条记录</span>
        </div>
      </template>

      <el-table :data="tableData" stripe style="width: 100%" @row-click="handleRowClick">
        <el-table-column prop="transactionNo" label="单号" width="180">
          <template #default="{ row }">
            <span class="mono">{{ row.transactionNo || row.checkNo || row.taskNo }}</span>
          </template>
        </el-table-column>
        <el-table-column label="类型" width="100">
          <template #default="{ row }">
            <el-tag :type="getTransactionTypeColor(row)" size="small">
              {{ row.transactionTypeText || row.detailTypeText || row.statusText || '-' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="productName" label="产品" min-width="150" />
        <el-table-column label="数量" width="100" align="center">
          <template #default="{ row }">
            <span :class="getQuantityClass(row)">
              {{ getQuantityDisplay(row) }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="库存变化" width="120" align="center">
          <template #default="{ row }">
            <span v-if="row.balanceBefore !== undefined">
              {{ row.balanceBefore }} → {{ row.balanceAfter }}
            </span>
            <span v-else-if="row.systemQuantity !== undefined">
              {{ row.systemQuantity }} → {{ row.actualQuantity }}
            </span>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column label="差异" width="80" align="center">
          <template #default="{ row }">
            <span v-if="row.discrepancy !== undefined" :class="getDiscrepancyClass(row.discrepancy)">
              {{ row.discrepancy > 0 ? '+' : '' }}{{ row.discrepancy }}
            </span>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column prop="operator" label="操作人" width="100" align="center" />
        <el-table-column prop="createTime" label="时间" width="160">
          <template #default="{ row }">
            {{ formatTime(row.createTime || row.checkTime || row.startTime) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120" align="center">
          <template #default="{ row }">
            <el-button link type="primary" @click.stop="viewDetail(row)">详情</el-button>
          </template>
        </el-table-column>
        <template #empty>
          <el-empty :description="emptyText" :image-size="80" />
        </template>
      </el-table>

      <div class="pagination-wrapper" v-if="total > 0">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :total="total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handlePageChange"
        />
      </div>
    </el-card>

    <el-dialog v-model="showDetailDialog" :title="detailTitle" width="700px">
      <div v-if="selectedRecord" class="detail-content">
        <el-card shadow="never" class="info-card">
          <el-descriptions :column="2" border>
            <el-descriptions-item label="单号">
              <span class="mono">{{ selectedRecord.transactionNo || selectedRecord.checkNo || selectedRecord.taskNo }}</span>
            </el-descriptions-item>
            <el-descriptions-item label="类型">
              <el-tag :type="getTransactionTypeColor(selectedRecord)" size="small">
                {{ selectedRecord.transactionTypeText || selectedRecord.detailTypeText || selectedRecord.statusText }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="产品">{{ selectedRecord.productName || '-' }}</el-descriptions-item>
            <el-descriptions-item label="分类">{{ selectedRecord.productCategory || '-' }}</el-descriptions-item>
            <el-descriptions-item label="数量">
              <span :class="getQuantityClass(selectedRecord)">{{ getQuantityDisplay(selectedRecord) }}</span>
            </el-descriptions-item>
            <el-descriptions-item label="库存变化" v-if="selectedRecord.balanceBefore !== undefined">
              {{ selectedRecord.balanceBefore }} → {{ selectedRecord.balanceAfter }}
            </el-descriptions-item>
            <el-descriptions-item label="差异" v-if="selectedRecord.discrepancy !== undefined">
              <span :class="getDiscrepancyClass(selectedRecord.discrepancy)">
                {{ selectedRecord.discrepancy > 0 ? '+' : '' }}{{ selectedRecord.discrepancy }}
              </span>
            </el-descriptions-item>
            <el-descriptions-item label="单价" v-if="selectedRecord.unitPrice">
              ¥{{ selectedRecord.unitPrice?.toFixed(2) }}
            </el-descriptions-item>
            <el-descriptions-item label="总金额" v-if="selectedRecord.totalAmount">
              ¥{{ selectedRecord.totalAmount?.toFixed(2) }}
            </el-descriptions-item>
            <el-descriptions-item label="来源/目的地" v-if="selectedRecord.source || selectedRecord.destination">
              {{ selectedRecord.source || selectedRecord.destination }}
            </el-descriptions-item>
            <el-descriptions-item label="关联订单" v-if="selectedRecord.relatedOrderNo">
              {{ selectedRecord.relatedOrderNo }}
            </el-descriptions-item>
            <el-descriptions-item label="操作人">{{ selectedRecord.operator || selectedRecord.creator || selectedRecord.checker }}</el-descriptions-item>
            <el-descriptions-item label="时间">
              {{ formatTime(selectedRecord.createTime || selectedRecord.checkTime) }}
            </el-descriptions-item>
          </el-descriptions>
        </el-card>

        <el-card shadow="never" class="info-card" v-if="selectedRecord.remark">
          <template #header>
            <span>备注</span>
          </template>
          <p>{{ selectedRecord.remark }}</p>
        </el-card>

        <el-card shadow="never" class="info-card" v-if="selectedRecord.items && selectedRecord.items.length > 0">
          <template #header>
            <span>盘点明细 ({{ selectedRecord.items.length }} 项)</span>
          </template>
          <el-table :data="selectedRecord.items" stripe size="small">
            <el-table-column prop="productName" label="产品" />
            <el-table-column prop="productCategory" label="分类" width="100" />
            <el-table-column label="系统库存" width="100" align="center">
              <template #default="{ row }">{{ row.systemQuantity }}</template>
            </el-table-column>
            <el-table-column label="实际库存" width="100" align="center">
              <template #default="{ row }">{{ row.actualQuantity }}</template>
            </el-table-column>
            <el-table-column label="差异" width="80" align="center">
              <template #default="{ row }">
                <span :class="getDiscrepancyClass(row.discrepancy)">
                  {{ row.discrepancy > 0 ? '+' : '' }}{{ row.discrepancy }}
                </span>
              </template>
            </el-table-column>
          </el-table>
        </el-card>

        <div class="detail-stats" v-if="selectedRecord.totalProducts !== undefined">
          <div class="stat-item">
            <span class="stat-label">总产品数</span>
            <span class="stat-value">{{ selectedRecord.totalProducts }}</span>
          </div>
          <div class="stat-item">
            <span class="stat-label">已盘点</span>
            <span class="stat-value">{{ selectedRecord.checkedProducts }}</span>
          </div>
          <div class="stat-item success">
            <span class="stat-label">无差异</span>
            <span class="stat-value">{{ selectedRecord.matchedCount }}</span>
          </div>
          <div class="stat-item warning">
            <span class="stat-label">盘盈</span>
            <span class="stat-value">{{ selectedRecord.surplusCount }}</span>
          </div>
          <div class="stat-item danger">
            <span class="stat-label">盘亏</span>
            <span class="stat-value">{{ selectedRecord.lossCount }}</span>
          </div>
        </div>
      </div>
      <template #footer>
        <el-button @click="showDetailDialog = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { inventoryApi, productsApi } from '@/api'
import { Plus, Search, Refresh } from '@element-plus/icons-vue'

const router = useRouter()

interface Product {
  id: number
  name: string
  category?: string
}

const activeTab = ref('all')
const loading = ref(false)
const showDetailDialog = ref(false)
const selectedRecord = ref<any>(null)

const tableData = ref<any[]>([])
const products = ref<Product[]>([])
const total = ref(0)
const currentPage = ref(1)
const pageSize = ref(20)

const searchForm = ref({
  productId: undefined as number | undefined,
  dateRange: [] as string[],
  relatedOrderNo: ''
})

const goToCreate = () => {
  router.push('/warehouse/inbound/create')
}

const tabTitle = computed(() => {
  switch (activeTab.value) {
    case 'inbound': return '入库记录'
    case 'outbound': return '出库记录'
    case 'check': return '盘点记录'
    default: return '全部记录'
  }
})

const emptyText = computed(() => {
  switch (activeTab.value) {
    case 'inbound': return '暂无入库记录'
    case 'outbound': return '暂无出库记录'
    case 'check': return '暂无盘点记录'
    default: return '暂无记录'
  }
})

const detailTitle = computed(() => {
  if (!selectedRecord.value) return '详情'
  if (selectedRecord.value.transactionNo) return '出入库详情'
  if (selectedRecord.value.checkNo) return '盘点记录详情'
  if (selectedRecord.value.taskNo) return '盘点任务详情'
  return '详情'
})

const getTransactionTypeColor = (row: any) => {
  if (row.transactionType === 'INBOUND') return 'success'
  if (row.transactionType === 'OUTBOUND') return 'warning'
  if (row.status === 'completed') return 'success'
  if (row.status === 'in_progress') return 'primary'
  if (row.discrepancyType === 'surplus') return 'success'
  if (row.discrepancyType === 'loss') return 'danger'
  return 'info'
}

const getQuantityClass = (row: any) => {
  if (row.quantity) {
    return row.transactionType === 'INBOUND' ? 'text-success' : 'text-warning'
  }
  return ''
}

const getQuantityDisplay = (row: any) => {
  if (row.quantity) return `+${row.quantity}` + (row.transactionType === 'INBOUND' ? ' 入' : ' 出')
  if (row.discrepancy !== undefined) {
    return row.discrepancy > 0 ? `+${row.discrepancy}` : row.discrepancy
  }
  return '-'
}

const getDiscrepancyClass = (discrepancy: number) => {
  if (discrepancy > 0) return 'text-success'
  if (discrepancy < 0) return 'text-danger'
  return 'text-muted'
}

const formatTime = (time: string) => {
  if (!time) return '-'
  return time.replace('T', ' ').substring(0, 19)
}

const fetchProducts = async () => {
  try {
    const res: any = await productsApi.getAll()
    const productData = res.data || res
    if (Array.isArray(productData)) {
      products.value = productData.map((p: any) => ({
        id: parseInt(p.id),
        name: p.name,
        category: p.category
      }))
    } else {
      products.value = []
    }
  } catch (error) {
    console.error('获取产品列表失败:', error)
    products.value = []
  }
}

const fetchTransactions = async () => {
  loading.value = true
  try {
    const params: any = {
      page: currentPage.value,
      size: pageSize.value
    }

    if (searchForm.value.productId) {
      params.productId = searchForm.value.productId
    }
    if (searchForm.value.dateRange && searchForm.value.dateRange.length === 2) {
      params.startDate = searchForm.value.dateRange[0]
      params.endDate = searchForm.value.dateRange[1]
    }
    if (searchForm.value.relatedOrderNo) {
      params.relatedOrderNo = searchForm.value.relatedOrderNo
    }

    if (activeTab.value === 'inbound') {
      params.transactionType = 'INBOUND'
    } else if (activeTab.value === 'outbound') {
      params.transactionType = 'OUTBOUND'
    }

    const res: any = await inventoryApi.getInventoryTransactions(params)
    const transactionData = res.data || res
    if (transactionData && transactionData.records) {
      tableData.value = transactionData.records
      total.value = transactionData.total || 0
    } else {
      tableData.value = Array.isArray(transactionData) ? transactionData : []
      total.value = Array.isArray(transactionData) ? transactionData.length : 0
    }
  } catch (error: any) {
    console.error('获取出入库记录失败:', error)
    tableData.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

const fetchCheckRecords = async () => {
  loading.value = true
  try {
    const params: any = {
      page: currentPage.value,
      size: pageSize.value
    }

    if (searchForm.value.productId) {
      params.productId = searchForm.value.productId
    }
    if (searchForm.value.dateRange && searchForm.value.dateRange.length === 2) {
      params.startDate = searchForm.value.dateRange[0]
      params.endDate = searchForm.value.dateRange[1]
    }

    const res: any = await inventoryApi.getInventoryCheckRecords(params)
    const checkData = res.data || res
    if (checkData && checkData.records) {
      tableData.value = checkData.records
      total.value = checkData.total || 0
    } else {
      tableData.value = Array.isArray(checkData) ? checkData : []
      total.value = Array.isArray(checkData) ? checkData.length : 0
    }
  } catch (error: any) {
    console.error('获取盘点记录失败:', error)
    tableData.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

const handleTabChange = () => {
  currentPage.value = 1
  if (activeTab.value === 'check') {
    fetchCheckRecords()
  } else {
    fetchTransactions()
  }
}

const handleSearch = () => {
  currentPage.value = 1
  if (activeTab.value === 'check') {
    fetchCheckRecords()
  } else {
    fetchTransactions()
  }
}

const handleReset = () => {
  searchForm.value = {
    productId: undefined,
    dateRange: [],
    relatedOrderNo: ''
  }
  handleSearch()
}

const handlePageChange = (page: number) => {
  currentPage.value = page
  if (activeTab.value === 'check') {
    fetchCheckRecords()
  } else {
    fetchTransactions()
  }
}

const handleSizeChange = (size: number) => {
  pageSize.value = size
  currentPage.value = 1
  if (activeTab.value === 'check') {
    fetchCheckRecords()
  } else {
    fetchTransactions()
  }
}

const handleRowClick = (row: any) => {
  viewDetail(row)
}

const viewDetail = async (row: any) => {
  selectedRecord.value = { ...row }
  if (row.id) {
    if (row.transactionNo) {
      try {
        const res = await inventoryApi.getTransactionById(row.id)
        selectedRecord.value = { ...row, ...res }
      } catch (error) {
        console.error('获取详情失败:', error)
      }
    } else if (row.taskNo) {
      try {
        const res = await inventoryApi.getCheckTaskById(row.id)
        selectedRecord.value = { ...row, ...res }
      } catch (error) {
        console.error('获取详情失败:', error)
      }
    }
  }
  showDetailDialog.value = true
}

onMounted(() => {
  fetchProducts()
  fetchTransactions()
})
</script>

<style scoped>
.warehouse-inbound {
  padding: 20px;
}

.mb-4 {
  margin-bottom: 16px;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-actions {
  display: flex;
  gap: 12px;
}

.page-title {
  margin: 0;
  font-size: 18px;
  font-weight: bold;
  color: #303133;
}

.page-desc {
  margin: 4px 0 0;
  font-size: 12px;
  color: #909399;
}

.search-form {
  margin-bottom: 0;
}

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.total-count {
  font-size: 12px;
  color: #909399;
}

.mono {
  font-family: 'Monaco', 'Menlo', monospace;
}

.text-success {
  color: #67c23a;
  font-weight: 500;
}

.text-warning {
  color: #e6a23c;
  font-weight: 500;
}

.text-danger {
  color: #f56c6c;
  font-weight: 500;
}

.text-muted {
  color: #909399;
}

.pagination-wrapper {
  display: flex;
  justify-content: flex-end;
  margin-top: 16px;
}

.inbound-item {
  padding: 12px;
  background: #f5f7fa;
  border-radius: 8px;
  margin-bottom: 12px;
}

.detail-content {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.info-card {
  margin-bottom: 0;
}

.detail-stats {
  display: flex;
  gap: 24px;
  padding: 16px;
  background: #f5f7fa;
  border-radius: 8px;
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}

.stat-label {
  font-size: 12px;
  color: #909399;
}

.stat-value {
  font-size: 24px;
  font-weight: bold;
  color: #303133;
}

.stat-item.success .stat-value {
  color: #67c23a;
}

.stat-item.warning .stat-value {
  color: #e6a23c;
}

.stat-item.danger .stat-value {
  color: #f56c6c;
}
</style>
