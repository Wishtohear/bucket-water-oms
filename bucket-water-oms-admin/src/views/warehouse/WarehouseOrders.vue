<template>
  <div class="warehouse-orders">
    <el-card shadow="never" class="mb-4">
      <template #header>
        <div class="header">
          <div>
            <h2 class="page-title">订单管理</h2>
            <p class="page-desc">管理待接单、备货中、已派单订单</p>
          </div>
        </div>
      </template>
      <el-radio-group v-model="activeTab" @change="handleTabChange">
        <el-radio-button value="pending">
          待接单
          <el-badge :value="tabs[0].badge" :hidden="tabs[0].badge === 0" />
        </el-radio-button>
        <el-radio-button value="preparing">
          备货中
          <el-badge :value="tabs[1].badge" :hidden="tabs[1].badge === 0" />
        </el-radio-button>
        <el-radio-button value="dispatched">
          已派单
          <el-badge :value="tabs[2].badge" :hidden="tabs[2].badge === 0" />
        </el-radio-button>
        <el-radio-button value="all">全部</el-radio-button>
      </el-radio-group>
    </el-card>

    <el-card shadow="never" class="mb-4">
      <el-row :gutter="16">
        <el-col :span="8">
          <el-input
            v-model="filters.search"
            placeholder="订单号/水站名称..."
            clearable
            @clear="handleSearch"
          >
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
        </el-col>
        <el-col :span="8">
          <el-button type="primary" @click="handleSearch">查询</el-button>
        </el-col>
      </el-row>
    </el-card>

    <el-card shadow="never" v-loading="loading">
      <template #header>
        <div class="table-header">
          <span>订单列表</span>
          <span class="total-count">共 {{ totalOrders }} 个订单</span>
        </div>
      </template>
      <el-table :data="orders" stripe style="width: 100%">
        <el-table-column label="订单信息" min-width="180">
          <template #default="{ row }">
            <div class="order-info">
              <div class="order-no">
                <el-badge is-dot :hidden="row.status !== 'pending_review'" />
                <span class="mono">{{ row.orderNo }}</span>
              </div>
              <span class="create-time">{{ row.createTime }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="客户地址" min-width="200">
          <template #default="{ row }">
            <div class="customer-info">
              <p class="customer-address">
                <el-icon><Location /></el-icon>
                {{ row.deliveryAddress || '-' }}
              </p>
              <p class="customer-contact" v-if="row.contactName || row.contactPhone">
                <el-icon><User /></el-icon>
                {{ row.contactName || '' }}{{ row.contactPhone ? ' ' + row.contactPhone : '' }}
              </p>
              <p class="station-name" v-if="row.stationName">
                <el-icon><Shop /></el-icon>
                {{ row.stationName }}
              </p>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="商品数量" width="120" align="center">
          <template #default="{ row }">
            <span class="bold">{{ row.totalBuckets || 0 }} 桶</span>
          </template>
        </el-table-column>
        <el-table-column label="金额" width="120" align="right">
          <template #default="{ row }">
            <span class="amount">¥ {{ row.totalAmount?.toLocaleString() || '0' }}</span>
          </template>
        </el-table-column>
        <el-table-column label="距离" width="100" align="center">
          <template #default>
            -
          </template>
        </el-table-column>
        <el-table-column label="状态" width="120" align="center">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)" size="small">
              {{ row.statusText }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="下单时间" width="180">
          <template #default="{ row }">
            {{ row.createTime }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" align="center" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="goToDetail(row)">详情</el-button>
            <el-button
              v-if="row.canReview"
              link
              type="success"
              @click="showAcceptDialog(row)"
            >
              接单
            </el-button>
            <el-button
              v-if="row.canDispatch"
              link
              type="warning"
              @click="showDispatchDialog(row)"
            >
              派单
            </el-button>
          </template>
        </el-table-column>
        <template #empty>
          <el-empty description="暂无订单数据" :image-size="80" />
        </template>
      </el-table>
      <div class="pagination-wrapper" v-if="totalOrders > 0">
        <el-pagination
          v-model:current-page="currentPage"
          :page-size="pageSize"
          :total="totalOrders"
          layout="prev, pager, next, total"
          @current-change="handlePageChange"
        />
      </div>
    </el-card>

    <el-dialog v-model="acceptDialogVisible" title="接单确认" width="400px">
      <p>确认接收订单 {{ selectedOrder?.orderNo }}？</p>
      <template #footer>
        <el-button @click="acceptDialogVisible = false">取消</el-button>
        <el-button type="success" @click="handleAccept">确认接单</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="rejectDialogVisible" title="拒单确认" width="500px">
      <el-form>
        <el-form-item label="拒单原因">
          <el-input
            v-model="rejectReason"
            type="textarea"
            :rows="4"
            placeholder="请输入拒单原因"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="rejectDialogVisible = false">取消</el-button>
        <el-button type="danger" @click="handleReject">确认拒单</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="dispatchDialogVisible" title="选择司机" width="500px">
      <div class="driver-list">
        <div
          v-for="driver in drivers"
          :key="driver.id"
          :class="['driver-item', { selected: selectedDriverId === driver.id }]"
          @click="selectedDriverId = driver.id"
        >
          <el-avatar :icon="UserFilled" />
          <div class="driver-info">
            <p class="driver-name">{{ driver.name }}</p>
            <p class="driver-status">
              {{ driver.onlineStatus === 'online' ? '在线' : driver.onlineStatus === 'break' ? '休息中' : '离线' }}
            </p>
          </div>
        </div>
      </div>
      <template #footer>
        <el-button @click="dispatchDialogVisible = false">取消</el-button>
        <el-button
          type="warning"
          :disabled="!selectedDriverId"
          @click="handleDispatch"
        >
          确认派单
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { warehouseApi } from '@/api'
import { toast } from '@/composables/useToast'
import { Search, Shop, UserFilled, User, Location } from '@element-plus/icons-vue'
import type { WarehouseOrderVO } from '@/api/warehouse'
import type { DriverVO } from '@/api/warehouse'

const router = useRouter()

const activeTab = ref('pending')
const currentPage = ref(1)
const pageSize = 10
const totalOrders = ref(0)
const loading = ref(false)

const filters = ref({
  search: ''
})

const tabs = [
  { key: 'pending', label: '待接单', badge: 0 },
  { key: 'preparing', label: '备货中', badge: 0 },
  { key: 'dispatched', label: '已派单', badge: 0 },
  { key: 'all', label: '全部', badge: null as number | null }
]

const orders = ref<WarehouseOrderVO[]>([])
const drivers = ref<DriverVO[]>([])

const acceptDialogVisible = ref(false)
const rejectDialogVisible = ref(false)
const dispatchDialogVisible = ref(false)
const selectedOrder = ref<WarehouseOrderVO | null>(null)
const selectedDriverId = ref('')
const rejectReason = ref('')

const getStatusType = (status: string) => {
  const typeMap: Record<string, string> = {
    pending_review: 'warning',
    reviewed: 'primary',
    dispatched: 'info',
    delivering: 'primary',
    completed: 'success',
    cancelled: 'info',
    rejected: 'danger'
  }
  return typeMap[status] || 'info'
}

const fetchOrders = async () => {
  loading.value = true
  try {
    let params: any = { page: currentPage.value, size: pageSize }
    if (activeTab.value !== 'all') {
      params.status = activeTab.value
    }
    if (filters.value.search) {
      params.search = filters.value.search
    }
    const res: any = await warehouseApi.getAllOrders(params)
    console.log('API Response:', res)
    console.log('res.data:', res?.data)
    const orderList = res.data || res || []
    console.log('orderList:', orderList)
    console.log('Is Array:', Array.isArray(orderList))
    orders.value = Array.isArray(orderList) ? orderList : (orderList.records || [])
    console.log('orders.value:', orders.value)
    if (orders.value.length > 0) {
      console.log('First order:', orders.value[0])
      console.log('First order keys:', Object.keys(orders.value[0]))
    }
    totalOrders.value = orders.value.length

    if (tabs[0]) tabs[0].badge = 0
    if (tabs[1]) tabs[1].badge = 0
    if (tabs[2]) tabs[2].badge = 0

    const allRes: any = await warehouseApi.getAllOrders({})
    const allOrders = allRes.data || allRes || []
    const allOrderList = Array.isArray(allOrders) ? allOrders : (allOrders.records || [])
    allOrderList.forEach((o: any) => {
      if (o.status === 'pending_review' && tabs[0]) tabs[0].badge = (tabs[0]?.badge || 0) + 1
      else if (o.status === 'reviewed' && tabs[1]) tabs[1].badge = (tabs[1]?.badge || 0) + 1
      else if (o.status === 'dispatched' && tabs[2]) tabs[2].badge = (tabs[2]?.badge || 0) + 1
    })
  } catch (error: any) {
    console.error('获取订单列表失败:', error)
    toast.error('获取订单列表失败')
  } finally {
    loading.value = false
  }
}

const fetchDrivers = async () => {
  try {
    const res: any = await warehouseApi.getAvailableDrivers()
    drivers.value = res.data || res || []
  } catch (error: any) {
    console.error('获取司机列表失败:', error)
  }
}

const handleSearch = () => {
  currentPage.value = 1
  fetchOrders()
}

const handleTabChange = () => {
  currentPage.value = 1
  fetchOrders()
}

const handlePageChange = () => {
  fetchOrders()
}

const goToDetail = (order: WarehouseOrderVO) => {
  console.log('goToDetail called, order:', order)
  console.log('order.orderId:', order.orderId)
  console.log('order.id:', order.id)
  const orderId = order.orderId || order.id
  console.log('navigating to:', `/warehouse/orders/${orderId}`)
  if (!orderId) {
    console.error('orderId is null or undefined!')
    toast.error('订单ID无效，无法跳转')
    return
  }
  router.push(`/warehouse/orders/${orderId}`).catch((err) => {
    console.error('Navigation error:', err)
    toast.error('页面跳转失败')
  })
}

const showAcceptDialog = (order: WarehouseOrderVO) => {
  selectedOrder.value = order
  acceptDialogVisible.value = true
}

const showDispatchDialog = (order: WarehouseOrderVO) => {
  selectedOrder.value = order
  selectedDriverId.value = ''
  dispatchDialogVisible.value = true
  fetchDrivers()
}

const handleAccept = async () => {
  if (!selectedOrder.value) return
  const orderId = selectedOrder.value.orderId
  if (!orderId) {
    toast.error('订单ID无效')
    return
  }
  try {
    await warehouseApi.reviewOrder(orderId, { action: 'accept' })
    toast.success('接单成功')
    acceptDialogVisible.value = false
    fetchOrders()
  } catch (error: any) {
    toast.error('接单失败: ' + (error.message || ''))
  }
}

const handleReject = async () => {
  if (!selectedOrder.value) return
  const orderId = selectedOrder.value.orderId
  if (!orderId) {
    toast.error('订单ID无效')
    return
  }
  try {
    await warehouseApi.reviewOrder(orderId, {
      action: 'reject',
      reason: rejectReason.value
    })
    toast.success('拒单成功')
    rejectDialogVisible.value = false
    rejectReason.value = ''
    fetchOrders()
  } catch (error: any) {
    toast.error('拒单失败: ' + (error.message || ''))
  }
}

const handleDispatch = async () => {
  if (!selectedOrder.value || !selectedDriverId.value) return
  const orderId = selectedOrder.value.orderId
  if (!orderId) {
    toast.error('订单ID无效')
    return
  }
  try {
    await warehouseApi.dispatchOrder(orderId, {
      driverId: selectedDriverId.value
    })
    toast.success('派单成功')
    dispatchDialogVisible.value = false
    fetchOrders()
  } catch (error: any) {
    toast.error('派单失败: ' + (error.message || ''))
  }
}

onMounted(() => {
  fetchOrders()
})
</script>

<style scoped>
.warehouse-orders {
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

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.total-count {
  font-size: 12px;
  color: #909399;
}

.order-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.order-no {
  display: flex;
  align-items: center;
  gap: 8px;
}

.mono {
  font-family: 'Monaco', 'Menlo', monospace;
  font-size: 14px;
  font-weight: 500;
  color: #303133;
}

.create-time {
  font-size: 12px;
  color: #909399;
}

.customer-info {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.customer-address {
  font-size: 13px;
  color: #303133;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 6px;
}

.customer-address .el-icon {
  color: #409eff;
}

.customer-contact {
  font-size: 12px;
  color: #606266;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 6px;
}

.customer-contact .el-icon {
  color: #909399;
}

.station-name {
  font-size: 12px;
  color: #909399;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 6px;
}

.station-name .el-icon {
  color: #409eff;
}

.bold {
  font-size: 14px;
  font-weight: 500;
  color: #303133;
}

.amount {
  font-size: 14px;
  font-weight: 500;
  color: #409eff;
}

.pagination-wrapper {
  display: flex;
  justify-content: flex-end;
  margin-top: 16px;
}

.driver-list {
  max-height: 400px;
  overflow-y: auto;
}

.driver-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  margin-bottom: 8px;
  background: #f5f7fa;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s;
  border: 2px solid transparent;
}

.driver-item:hover {
  background: #ecf5ff;
}

.driver-item.selected {
  background: #ecf5ff;
  border-color: #409eff;
}

.driver-info {
  flex: 1;
}

.driver-name {
  font-size: 14px;
  font-weight: 500;
  color: #303133;
  margin: 0;
}

.driver-status {
  font-size: 12px;
  color: #909399;
  margin: 4px 0 0;
}
</style>
