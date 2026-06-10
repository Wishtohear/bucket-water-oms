<template>
  <div>
    <div class="mb-4 flex justify-end gap-3">
      <el-button type="success" @click="goToInbound">
        <el-icon><Plus /></el-icon>
        新增入库
      </el-button>
    </div>

    <div class="flex justify-between items-center mb-4">
      <el-radio-group v-model="selectedWarehouse" @change="handleWarehouseChange">
        <el-radio-button value="">全部仓库</el-radio-button>
        <el-radio-button
          v-for="warehouse in warehouses"
          :key="warehouse.id"
          :value="warehouse.id"
        >
          {{ warehouse.name }}
        </el-radio-button>
      </el-radio-group>
    </div>

    <el-card shadow="never" class="mb-4">
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
          <el-select v-model="searchForm.productId" placeholder="选择产品" clearable filterable style="width: 180px">
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
          <el-input v-model="searchForm.relatedOrderNo" placeholder="输入订单号" clearable style="width: 150px" />
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
        <div class="flex justify-between items-center">
          <span class="font-bold">{{ tabTitle }}</span>
          <span class="text-sm text-gray-500">共 {{ tableData.length }} 条记录</span>
        </div>
      </template>

      <el-table :data="tableData" stripe @row-click="handleRowClick">
        <el-table-column label="单号" width="180">
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
        <el-table-column label="产品" min-width="150">
          <template #default="{ row }">
            <span class="font-bold">{{ row.productName || '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column label="仓库" width="120">
          <template #default="{ row }">
            {{ row.warehouseName || '-' }}
          </template>
        </el-table-column>
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
        <el-table-column label="操作人" width="100" align="center">
          <template #default="{ row }">
            {{ row.operator || row.creator || row.checker || '-' }}
          </template>
        </el-table-column>
        <el-table-column label="时间" width="160">
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

      <div class="flex justify-end mt-4" v-if="total > 0">
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

    <el-dialog v-model="showCreateDialog" title="新增入库" width="600px" @close="resetForm">
      <el-form :model="newInbound" label-width="100px">
        <el-form-item label="仓库" required>
          <el-select v-model="newInbound.warehouseId" placeholder="选择仓库" style="width: 100%">
            <el-option v-for="w in warehouses" :key="w.id" :label="w.name" :value="w.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="入库类型" required>
          <el-select v-model="newInbound.inboundType" placeholder="请选择入库类型" style="width: 100%">
            <el-option label="生产入库" value="production" />
            <el-option label="采购入库" value="purchase" />
            <el-option label="调拨入库" value="transfer_in" />
            <el-option label="退货入库" value="return" />
          </el-select>
        </el-form-item>
        <el-form-item label="来源">
          <el-input v-model="newInbound.source" placeholder="如：一号车间、XX供应商" />
        </el-form-item>
        <el-form-item label="关联订单">
          <el-input v-model="newInbound.relatedOrderNo" placeholder="关联订单号（可选）" />
        </el-form-item>
        <el-divider content-position="left">入库产品</el-divider>
        <div v-for="(item, index) in newInbound.items" :key="index" class="inbound-item">
          <el-row :gutter="12">
            <el-col :span="10">
              <el-form-item label="产品" required label-width="60px">
                <el-select v-model="item.productId" placeholder="选择产品" style="width: 100%" filterable>
                  <el-option v-for="p in products" :key="p.id" :label="p.name" :value="p.id" />
                </el-select>
              </el-form-item>
            </el-col>
            <el-col :span="6">
              <el-form-item label="数量" required label-width="60px">
                <el-input-number v-model="item.quantity" :min="1" style="width: 100%" />
              </el-form-item>
            </el-col>
            <el-col :span="6">
              <el-form-item label="单价" label-width="60px">
                <el-input-number v-model="item.unitPrice" :min="0" :precision="2" style="width: 100%" />
              </el-form-item>
            </el-col>
            <el-col :span="2">
              <el-button type="danger" circle @click="removeInboundItem(index)" :disabled="newInbound.items.length <= 1">
                <el-icon><Delete /></el-icon>
              </el-button>
            </el-col>
          </el-row>
        </div>
        <el-button type="primary" plain @click="addInboundItem" style="margin-left: 60px; margin-bottom: 16px;">
          <el-icon><Plus /></el-icon>
          添加产品
        </el-button>
        <el-form-item label="备注">
          <el-input v-model="newInbound.remark" type="textarea" :rows="3" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showCreateDialog = false">取消</el-button>
        <el-button type="primary" @click="handleCreate" :loading="submitting">确认入库</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="showDetailDialog" :title="detailTitle" width="700px">
      <div v-if="selectedRecord" class="space-y-4">
        <el-card shadow="never">
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
            <el-descriptions-item label="仓库">{{ selectedRecord.warehouseName || '-' }}</el-descriptions-item>
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
            <el-descriptions-item label="操作人">
              {{ selectedRecord.operator || selectedRecord.creator || selectedRecord.checker || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="时间">
              {{ formatTime(selectedRecord.createTime || selectedRecord.checkTime) }}
            </el-descriptions-item>
          </el-descriptions>
        </el-card>

        <el-card shadow="never" v-if="selectedRecord.remark">
          <template #header><span>备注</span></template>
          <p>{{ selectedRecord.remark }}</p>
        </el-card>

        <el-card shadow="never" v-if="selectedRecord.items && selectedRecord.items.length > 0">
          <template #header><span>盘点明细 ({{ selectedRecord.items.length }} 项)</span></template>
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

        <div class="flex gap-6 p-4 bg-gray-50 rounded-lg" v-if="selectedRecord.totalProducts !== undefined">
          <div class="flex flex-col items-center">
            <span class="text-xs text-gray-500">总产品数</span>
            <span class="text-2xl font-bold">{{ selectedRecord.totalProducts }}</span>
          </div>
          <div class="flex flex-col items-center">
            <span class="text-xs text-gray-500">已盘点</span>
            <span class="text-2xl font-bold">{{ selectedRecord.checkedProducts }}</span>
          </div>
          <div class="flex flex-col items-center">
            <span class="text-xs text-green-600">无差异</span>
            <span class="text-2xl font-bold text-green-600">{{ selectedRecord.matchedCount }}</span>
          </div>
          <div class="flex flex-col items-center">
            <span class="text-xs text-orange-500">盘盈</span>
            <span class="text-2xl font-bold text-orange-500">{{ selectedRecord.surplusCount }}</span>
          </div>
          <div class="flex flex-col items-center">
            <span class="text-xs text-red-500">盘亏</span>
            <span class="text-2xl font-bold text-red-500">{{ selectedRecord.lossCount }}</span>
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
import {
  Plus, Search, Refresh, Delete
} from '@element-plus/icons-vue'
import { inventoryApi, warehousesApi, productsApi } from '@/api'
import { ElMessage } from 'element-plus'

const router = useRouter()

const goToInbound = () => {
  router.push('/inventory/inbound')
}

interface Warehouse {
  id: number
  name: string
}

interface Product {
  id: number
  name: string
  category?: string
}

const activeTab = ref('all')
const loading = ref(false)
const submitting = ref(false)
const showCreateDialog = ref(false)
const showDetailDialog = ref(false)
const selectedRecord = ref<any>(null)

const tableData = ref<any[]>([])
const warehouses = ref<Warehouse[]>([])
const products = ref<Product[]>([])
const selectedWarehouse = ref<string>('')
const total = ref(0)
const currentPage = ref(1)
const pageSize = ref(20)

const searchForm = ref({
  productId: undefined as number | undefined,
  dateRange: [] as string[],
  relatedOrderNo: ''
})

const newInbound = ref({
  warehouseId: undefined as number | undefined,
  inboundType: 'production',
  source: '',
  relatedOrderNo: '',
  remark: '',
  items: [
    { productId: undefined as number | undefined, quantity: 1, unitPrice: 0, remark: '' }
  ]
})

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
    return row.transactionType === 'INBOUND' ? 'text-green-600' : 'text-orange-500'
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
  if (discrepancy > 0) return 'text-green-600'
  if (discrepancy < 0) return 'text-red-500'
  return 'text-gray-500'
}

const formatTime = (time: string) => {
  if (!time) return '-'
  return time.replace('T', ' ').substring(0, 19)
}

const fetchWarehouses = async () => {
  try {
    const res: any = await warehousesApi.getAll({ status: 'active' })
    if (Array.isArray(res)) {
      warehouses.value = res.map((w: any) => ({
        id: parseInt(w.id),
        name: w.name
      }))
    }
  } catch (error) {
    console.error('获取仓库列表失败:', error)
  }
}

const fetchProducts = async () => {
  try {
    const res: any = await productsApi.getAll()
    if (Array.isArray(res)) {
      products.value = res.map((p: any) => ({
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

    if (selectedWarehouse.value) {
      params.warehouseId = parseInt(selectedWarehouse.value)
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
    if (res && res.data && res.data.records) {
      tableData.value = res.data.records
      total.value = res.data.total || 0
    } else {
      tableData.value = []
      total.value = 0
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

    if (selectedWarehouse.value) {
      params.warehouseId = parseInt(selectedWarehouse.value)
    }
    if (searchForm.value.productId) {
      params.productId = searchForm.value.productId
    }
    if (searchForm.value.dateRange && searchForm.value.dateRange.length === 2) {
      params.startDate = searchForm.value.dateRange[0]
      params.endDate = searchForm.value.dateRange[1]
    }

    const res: any = await inventoryApi.getInventoryCheckRecords(params)
    if (res && res.data && res.data.records) {
      tableData.value = res.data.records
      total.value = res.data.total || 0
    } else {
      tableData.value = []
      total.value = 0
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

const handleWarehouseChange = () => {
  handleSearch()
}

const handleRowClick = (row: any) => {
  viewDetail(row)
}

const viewDetail = async (row: any) => {
  selectedRecord.value = { ...row }
  if (row.id) {
    if (row.transactionNo) {
      try {
        const res: any = await inventoryApi.getTransactionById(row.id)
        selectedRecord.value = { ...row, ...res }
      } catch (error) {
        console.error('获取详情失败:', error)
      }
    } else if (row.taskNo) {
      try {
        const res: any = await inventoryApi.getCheckTaskById(row.id)
        selectedRecord.value = { ...row, ...res }
      } catch (error) {
        console.error('获取详情失败:', error)
      }
    }
  }
  showDetailDialog.value = true
}

const addInboundItem = () => {
  newInbound.value.items.push({ productId: undefined, quantity: 1, unitPrice: 0, remark: '' })
}

const removeInboundItem = (index: number) => {
  newInbound.value.items.splice(index, 1)
}

const resetForm = () => {
  newInbound.value = {
    warehouseId: undefined,
    inboundType: 'production',
    source: '',
    relatedOrderNo: '',
    remark: '',
    items: [{ productId: undefined, quantity: 1, unitPrice: 0, remark: '' }]
  }
}

const handleCreate = async () => {
  if (!newInbound.value.warehouseId) {
    ElMessage.warning('请选择仓库')
    return
  }
  if (!newInbound.value.inboundType) {
    ElMessage.warning('请选择入库类型')
    return
  }
  const validItems = newInbound.value.items.filter(i => i.productId && i.quantity > 0)
  if (validItems.length === 0) {
    ElMessage.warning('请至少添加一个产品')
    return
  }

  submitting.value = true
  try {
    await inventoryApi.createInboundTransaction({
      inboundType: newInbound.value.inboundType,
      source: newInbound.value.source,
      relatedOrderNo: newInbound.value.relatedOrderNo,
      remark: newInbound.value.remark,
      items: validItems.map(i => ({
        productId: i.productId!,
        quantity: i.quantity,
        unitPrice: i.unitPrice || 0
      }))
    })
    ElMessage.success('入库成功')
    showCreateDialog.value = false
    resetForm()
    handleSearch()
  } catch (error: any) {
    ElMessage.error('入库失败: ' + (error.message || ''))
  } finally {
    submitting.value = false
  }
}

onMounted(async () => {
  await Promise.all([
    fetchWarehouses(),
    fetchProducts()
  ])
  fetchTransactions()
})
</script>

<style scoped>
.mono {
  font-family: 'Monaco', 'Menlo', monospace;
}
.inbound-item {
  padding: 12px;
  background: #f5f7fa;
  border-radius: 8px;
  margin-bottom: 12px;
}
</style>
