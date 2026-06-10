<template>
  <div class="orders-page">
    <el-card shadow="never" class="mb-4">
      <template #header>
        <div class="card-header">
          <div class="header-left">
            <span class="header-title">订单管理</span>
            <span class="header-desc">管理所有订单，支持查看、筛选和导出</span>
          </div>
          <el-button type="primary" @click="exportOrders">
            <el-icon><Download /></el-icon>
            导出订单
          </el-button>
        </div>
      </template>

      <el-form :inline="true" :model="filters">
        <el-form-item label="订单号/水站">
          <el-input v-model="filters.keyword" placeholder="搜索订单号、水站名称..." clearable style="width: 200px" />
        </el-form-item>
        <el-form-item label="订单状态">
          <el-select v-model="filters.status" placeholder="全部状态" clearable style="width: 150px">
            <el-option label="待审查" value="PENDING_REVIEW" />
            <el-option label="已接单" value="REVIEWED" />
            <el-option label="已派单" value="DISPATCHED" />
            <el-option label="配送中" value="DELIVERING" />
            <el-option label="已完成" value="COMPLETED" />
            <el-option label="已取消" value="CANCELLED" />
            <el-option label="已拒单" value="REJECTED" />
          </el-select>
        </el-form-item>
        <el-form-item label="仓库">
          <el-select v-model="filters.warehouseId" placeholder="全部仓库" clearable style="width: 150px">
            <el-option v-for="w in warehouses" :key="w.id" :label="w.name" :value="w.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="日期范围">
          <el-select v-model="filters.dateRange" style="width: 150px">
            <el-option label="全部时间" value="" />
            <el-option label="今日" value="today" />
            <el-option label="本周" value="week" />
            <el-option label="本月" value="month" />
            <el-option label="上月" value="lastMonth" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button @click="resetFilters">重置</el-button>
          <el-button type="primary" @click="handleSearch">查询</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <div class="header-left">
            <span class="card-title">订单列表</span>
            <el-tag class="ml-2" type="info">共 {{ totalOrders }} 个订单</el-tag>
          </div>
          <el-button type="success" plain @click="exportOrders">
            <el-icon><Download /></el-icon>
            导出
          </el-button>
        </div>
      </template>

      <el-table :data="orders" stripe v-loading="loading">
        <el-table-column label="订单信息" min-width="180">
          <template #default="{ row }">
            <div>
              <p class="order-no">{{ row.orderNo }}</p>
              <p class="order-type">{{ row.paymentType }}</p>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="水站" min-width="150">
          <template #default="{ row }">
            <div class="station-cell">
              <el-icon color="#409eff"><Shop /></el-icon>
              <span>{{ row.stationName }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="仓库" min-width="120">
          <template #default="{ row }">
            <span>{{ row.warehouseName }}</span>
          </template>
        </el-table-column>
        <el-table-column label="订单金额" min-width="120" align="right">
          <template #default="{ row }">
            <span class="amount-text">¥ {{ row.totalAmount?.toLocaleString() }}</span>
          </template>
        </el-table-column>
        <el-table-column label="桶数" min-width="80" align="right">
          <template #default="{ row }">
            <span>{{ row.totalBuckets }} 桶</span>
          </template>
        </el-table-column>
        <el-table-column label="状态" min-width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)" effect="dark" size="small">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="下单时间" min-width="160">
          <template #default="{ row }">
            <span class="time-text">{{ formatDateTime(row.createTime) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" min-width="120" align="center" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="viewOrderDetail(row)">详情</el-button>
            <el-dropdown trigger="click" @command="(cmd: string) => handleOrderAction(cmd, row)">
              <el-button link type="primary">
                <el-icon><MoreFilled /></el-icon>
              </el-button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="print">打印订单</el-dropdown-item>
                  <el-dropdown-item command="cancel" divided>取消订单</el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-container">
        <span class="total-info">显示 {{ orders.length }} 条，共 {{ totalOrders }} 条</span>
        <el-pagination
          v-model:current-page="currentPage"
          :page-size="pageSize"
          :total="totalOrders"
          layout="prev, pager, next, total"
          @current-change="handlePageChange"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { ordersApi } from '@/api/orders'
import { warehousesApi } from '@/api/warehouses'

interface Order {
  id: number
  orderNo: string
  stationName: string
  warehouseName: string
  totalAmount: number
  totalBuckets: number
  status: string
  paymentType: string
  createTime: string
  items?: Array<{
    productName: string
    quantity: number
    price: number
    subtotal: number
  }>
}

const normalizeOrder = (raw: any): Order => {
  const order: Order = {
    id: raw.orderId || raw.id || 0,
    orderNo: raw.orderNo || '',
    stationName: raw.stationName || '',
    warehouseName: raw.warehouse?.name || '',
    totalAmount: raw.totalAmount || 0,
    totalBuckets: raw.totalBuckets || raw.totalQuantity || 0,
    status: raw.status || '',
    paymentType: raw.paymentType || '',
    createTime: raw.createdAt || raw.createTime || '',
    items: raw.items || []
  }
  
  if (order.totalBuckets === 0 && order.items && order.items.length > 0) {
    order.totalBuckets = order.items.reduce((sum, item) => sum + (item.quantity || 0), 0)
  }
  
  return order
}

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const orders = ref<Order[]>([])
const warehouses = ref<Array<{id: string; name: string}>>([])
const currentPage = ref(1)
const pageSize = ref(10)
const totalOrders = ref(0)

const filters = reactive({
  keyword: '',
  status: '',
  warehouseId: '',
  dateRange: ''
})

const getStatusType = (status: string) => {
  const typeMap: Record<string, string> = {
    PENDING_REVIEW: 'warning',
    REVIEWED: 'primary',
    DISPATCHED: 'primary',
    DELIVERING: 'warning',
    COMPLETED: 'success',
    CANCELLED: 'info',
    REJECTED: 'danger'
  }
  return typeMap[status] || 'info'
}

const getStatusText = (status: string) => {
  const textMap: Record<string, string> = {
    PENDING_REVIEW: '待审查',
    REVIEWED: '已接单',
    DISPATCHED: '已派单',
    DELIVERING: '配送中',
    COMPLETED: '已完成',
    CANCELLED: '已取消',
    REJECTED: '已拒单'
  }
  return textMap[status] || status
}

const formatDateTime = (dateStr: string) => {
  if (!dateStr) return '-'
  const date = new Date(dateStr)
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const fetchWarehouses = async () => {
  try {
    const res: any = await warehousesApi.getAll({ status: 'active' })
    const warehouseList = res.data || res
    if (Array.isArray(warehouseList)) {
      warehouses.value = warehouseList.map((w: any) => ({
        id: String(w.id),
        name: w.name
      }))
    }
  } catch (error) {
    console.error('获取仓库列表失败:', error)
  }
}

const fetchOrders = async () => {
  loading.value = true
  try {
    const params: any = {
      page: currentPage.value,
      size: pageSize.value
    }
    
    if (filters.keyword) {
      params.keyword = filters.keyword
    }
    if (filters.status) {
      params.status = filters.status
    }
    if (filters.warehouseId) {
      params.warehouseId = filters.warehouseId
    }
    
    const res: any = await ordersApi.getPage(params)
    console.log('订单列表API响应:', res)
    
    // 处理后端返回的 Result<T> 结构
    // 后端返回: { success: true, data: { records: [...], total: ... }, message: "...", code: "0000" }
    let data = res
    if (res && res.data !== undefined) {
      data = res.data
    }
    
    if (Array.isArray(data)) {
      orders.value = data.map(normalizeOrder)
      totalOrders.value = data.length
    } else if (data && data.records) {
      orders.value = Array.isArray(data.records) ? data.records.map(normalizeOrder) : []
      totalOrders.value = data.total || orders.value.length
    } else if (data && data.data) {
      // 双重嵌套处理
      const innerData = data.data
      orders.value = Array.isArray(innerData) ? innerData.map(normalizeOrder) : (innerData.records || []).map(normalizeOrder)
      totalOrders.value = innerData.total || orders.value.length
    } else {
      orders.value = []
      totalOrders.value = 0
    }
  } catch (error) {
    console.error('获取订单列表失败:', error)
    orders.value = []
    totalOrders.value = 0
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  currentPage.value = 1
  fetchOrders()
}

const resetFilters = () => {
  filters.keyword = ''
  filters.status = ''
  filters.warehouseId = ''
  filters.dateRange = ''
  currentPage.value = 1
  fetchOrders()
}

const handlePageChange = (page: number) => {
  currentPage.value = page
  fetchOrders()
}

const viewOrderDetail = (order: Order) => {
  router.push(`/orders/${order.id}`)
}

const handleOrderAction = async (command: string, order: Order) => {
  switch (command) {
    case 'print':
      ElMessage.info(`正在打印订单 ${order.orderNo}`)
      break
    case 'cancel':
      try {
        await ElMessageBox.confirm('确定要取消该订单吗？', '取消订单', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        })
        await ordersApi.cancel(String(order.id))
        ElMessage.success('订单已取消')
        fetchOrders()
      } catch {
        // 用户取消操作
      }
      break
  }
}

const exportOrders = async () => {
  try {
    ElMessage.info('正在导出订单...')
    // TODO: 实现导出功能
  } catch (error) {
    console.error('导出失败:', error)
  }
}

watch(() => route.query.stationId, (newStationId) => {
  if (newStationId) {
    filters.warehouseId = String(newStationId)
    fetchOrders()
  }
}, { immediate: true })

onMounted(async () => {
  await fetchWarehouses()
  await fetchOrders()
})
</script>

<style scoped>
.orders-page {
  padding: 0;
}

.mb-4 {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-left {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.header-title {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
  margin: 0;
}

.header-desc {
  font-size: 14px;
  color: #909399;
  margin: 0;
}

.card-title {
  font-weight: 600;
  font-size: 16px;
}

.order-no {
  font-family: monospace;
  font-weight: 500;
  color: #303133;
  margin: 0;
}

.order-type {
  font-size: 12px;
  color: #909399;
  margin: 4px 0 0 0;
}

.station-cell {
  display: flex;
  align-items: center;
  gap: 8px;
}

.amount-text {
  font-weight: 600;
  color: #303133;
}

.time-text {
  color: #909399;
  font-size: 13px;
}

.pagination-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 20px;
}


</style>
