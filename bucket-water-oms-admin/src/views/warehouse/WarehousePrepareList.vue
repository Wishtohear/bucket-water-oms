<template>
  <div class="prepare-list-container">
    <el-page-header class="mb-4">
      <template #content>
        <div class="page-header">
          <h2 class="page-title">备货中</h2>
          <p class="page-desc">管理备货中、待派单、已派单的订单</p>
        </div>
      </template>
    </el-page-header>

    <el-card shadow="never" class="mb-4">
      <div class="flex justify-between items-center">
        <el-radio-group v-model="activeTab" @change="fetchOrders">
          <el-radio-button v-for="tab in tabs" :key="tab.key" :value="tab.key">
            {{ tab.label }}
            <el-badge v-if="tab.badge !== null" :value="tab.badge" :max="99" class="ml-1" />
          </el-radio-button>
        </el-radio-group>
        <el-button type="primary" text @click="fetchOrders" :loading="loading">
          <el-icon><Refresh /></el-icon>
          刷新
        </el-button>
      </div>
    </el-card>

    <el-card shadow="never" class="mb-4">
      <el-tag
        v-for="filter in filterTabs"
        :key="filter.key"
        :type="activeFilter === filter.key ? 'primary' : 'info'"
        class="filter-tag"
        @click="activeFilter = filter.key; fetchOrders()"
      >
        {{ filter.label }}
      </el-tag>
    </el-card>

    <div v-if="loading" class="loading-container">
      <el-icon class="is-loading" size="32"><Loading /></el-icon>
      <p>加载中...</p>
    </div>

    <div v-else class="order-list">
      <el-card
        v-for="order in preparingOrders"
        :key="order.orderId"
        shadow="never"
        class="order-card"
      >
        <template #header>
          <div class="card-header">
            <div class="order-header">
              <span class="status-dot" :class="getStatusDotClass(order.prepareStatus)"></span>
              <span class="order-no">{{ order.orderNo }}</span>
            </div>
            <div class="order-actions">
              <el-tag :type="getPrepareStatusType(order.prepareStatus)" size="small">
                {{ getPrepareStatusText(order.prepareStatus) }}
              </el-tag>
              <el-tag v-if="order.prepareStatus === 'preparing'" type="info" size="small">
                已等待 {{ order.waitMinutes || 0 }}分钟
              </el-tag>
            </div>
          </div>
        </template>

        <div class="order-content">
          <div class="station-info">
            <el-icon class="station-icon"><Shop /></el-icon>
            <div class="station-details">
              <p class="station-name">{{ order.stationName }}</p>
              <p class="station-address">{{ order.stationAddress || order.deliveryAddress }}</p>
            </div>
          </div>

          <div class="items-section">
            <div v-for="item in order.items" :key="item.productId" class="item-row">
              <span class="item-name">{{ item.productName }}</span>
              <span class="item-qty">× {{ item.quantity }} 桶</span>
            </div>
          </div>

          <div class="progress-section">
            <el-progress :percentage="getPrepareProgress(order)" :stroke-width="8" />
            <span class="progress-text">{{ order.preparedCount || 0 }}/{{ order.totalCount || 0 }} 已备货</span>
          </div>

          <div class="action-buttons">
            <el-button type="primary" size="small" @click="handlePrint(order)">
              <el-icon><Printer /></el-icon>
              打印备货单
            </el-button>
            <el-button
              v-if="order.prepareStatus !== 'dispatched'"
              type="success"
              size="small"
              @click="handleDispatch(order)"
            >
              选择司机派单
            </el-button>
            <el-tag v-if="order.prepareStatus === 'dispatched' && order.driverName" type="success" size="small">
              司机: {{ order.driverName }}
            </el-tag>
          </div>
        </div>
      </el-card>

      <el-empty v-if="preparingOrders.length === 0" description="暂无订单" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Shop, Printer, Refresh, Loading } from '@element-plus/icons-vue'
import { warehouseApi, type PreparingOrderVO } from '@/api/warehouse'

const router = useRouter()
const route = useRoute()
const activeTab = ref('preparing')
const activeFilter = ref('all')
const loading = ref(false)

interface DisplayOrder {
  orderId: string
  orderNo: string
  stationName: string
  stationAddress: string
  deliveryAddress?: string
  prepareStatus: string
  waitMinutes: number
  preparedCount: number
  totalCount: number
  items: { productId: string; productName: string; quantity: number }[]
  status: string
  driverName: string
}

const tabs = [
  { key: 'all', label: '全部', badge: null },
  { key: 'preparing', label: '备货中', badge: null },
  { key: 'pending_dispatch', label: '待派单', badge: null },
  { key: 'dispatched', label: '已派单', badge: null }
]

const filterTabs = [
  { key: 'all', label: '全部' },
  { key: 'preparing', label: '备货中' },
  { key: 'pending_dispatch', label: '待派单' },
  { key: 'dispatched', label: '已派单' }
]

const preparingOrders = ref<DisplayOrder[]>([])

const fetchOrders = async () => {
  loading.value = true
  try {
    const status = activeTab.value === 'all' ? undefined : activeTab.value
    const res: any = await warehouseApi.getPreparingOrders({ status, size: 50 })
    const orders: PreparingOrderVO[] = res.data || res || []
    
    console.log('获取到的订单数据:', orders)
    
    preparingOrders.value = orders.map((order: PreparingOrderVO) => {
      console.log('处理订单:', order.orderNo, '状态:', order.status, 'statusText:', order.statusText)
      
      let prepareStatus = 'preparing'
      if (order.status === 'dispatched') {
        prepareStatus = 'dispatched'
      } else if (order.status === 'reviewed') {
        prepareStatus = 'pending_dispatch'
      } else if (order.statusText === '已派单') {
        prepareStatus = 'dispatched'
      } else if (order.statusText === '待派单') {
        prepareStatus = 'pending_dispatch'
      }
      
      let waitMinutes = 0
      if (order.createTime) {
        const createTime = new Date(order.createTime).getTime()
        const now = Date.now()
        waitMinutes = Math.floor((now - createTime) / 60000)
      }
      
      console.log('映射后的prepareStatus:', prepareStatus)
      
      return {
        orderId: order.orderId || order.id || '',
        orderNo: order.orderNo || '',
        stationName: order.stationName || '',
        stationAddress: order.stationAddress || '',
        deliveryAddress: order.deliveryAddress || '',
        prepareStatus,
        waitMinutes: order.waitMinutes || waitMinutes,
        preparedCount: order.preparedCount || 0,
        totalCount: order.totalCount || order.totalBuckets || 0,
        items: (order.items || []).map((item: any) => ({
          productId: item.productId || '',
          productName: item.productName || '',
          quantity: item.quantity || 0
        })),
        status: order.status || '',
        statusText: order.statusText || '',
        driverName: order.driverName || ''
      }
    })
    
    console.log('处理后的订单列表:', preparingOrders.value)
  } catch (error: any) {
    console.error('获取备货订单列表失败:', error)
    ElMessage.error('获取订单列表失败')
    preparingOrders.value = []
  } finally {
    loading.value = false
  }
}

const getStatusDotClass = (status: string) => {
  const classes: Record<string, string> = {
    preparing: 'bg-blue',
    pending_dispatch: 'bg-orange',
    dispatched: 'bg-green'
  }
  return classes[status] || ''
}

const getPrepareStatusType = (status: string) => {
  const types: Record<string, string> = {
    preparing: 'primary',
    pending_dispatch: 'warning',
    dispatched: 'success'
  }
  return types[status] || 'info'
}

const getPrepareStatusText = (status: string) => {
  const texts: Record<string, string> = {
    preparing: '备货中',
    pending_dispatch: '待派单',
    dispatched: '已派单'
  }
  return texts[status] || status
}

const getPrepareProgress = (order: any) => {
  if (!order.totalCount) return 0
  return Math.round((order.preparedCount / order.totalCount) * 100)
}

const handlePrint = (_order: any) => {
  ElMessage.info('打印功能开发中')
}

const handleDispatch = (order: any) => {
  console.log('handleDispatch called, order:', order)
  console.log('order.orderId:', order.orderId)
  const orderId = order.orderId || order.id
  console.log('navigating to:', `/warehouse/dispatch-select/${orderId}`)
  if (!orderId) {
    console.error('orderId is null or undefined!')
    ElMessage.error('订单ID无效，无法跳转')
    return
  }
  router.push(`/warehouse/dispatch-select/${orderId}`).catch((err) => {
    console.error('Navigation error:', err)
    ElMessage.error('页面跳转失败')
  })
}

onMounted(() => {
  // 从 URL 参数读取 tab 值
  const tabParam = route.query.tab as string
  if (tabParam && ['all', 'preparing', 'pending_dispatch', 'dispatched'].includes(tabParam)) {
    activeTab.value = tabParam
  }
  fetchOrders()
})
</script>

<style scoped>
.prepare-list-container {
  padding: 20px;
}

.mb-4 {
  margin-bottom: 16px;
}

.page-header {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.page-title {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
  margin: 0;
}

.page-desc {
  font-size: 12px;
  color: #909399;
  margin: 0;
}

.filter-tag {
  margin-right: 8px;
  cursor: pointer;
}

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 80px 0;
  color: #909399;
}

.loading-container p {
  margin-top: 16px;
}

.order-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.order-card {
  border: 1px solid #e4e7ed;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.order-header {
  display: flex;
  align-items: center;
  gap: 8px;
}

.status-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
}

.status-dot.bg-blue {
  background: #409eff;
}

.status-dot.bg-orange {
  background: #e6a23c;
}

.status-dot.bg-green {
  background: #67c23a;
}

.order-no {
  font-weight: 600;
  color: #303133;
}

.order-actions {
  display: flex;
  gap: 8px;
}

.order-content {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.station-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.station-icon {
  font-size: 32px;
  color: #409eff;
  background: #ecf5ff;
  padding: 12px;
  border-radius: 12px;
}

.station-name {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
  margin: 0 0 4px 0;
}

.station-address {
  font-size: 12px;
  color: #909399;
  margin: 0;
}

.items-section {
  background: #f5f7fa;
  padding: 12px;
  border-radius: 8px;
}

.item-row {
  display: flex;
  justify-content: space-between;
  padding: 4px 0;
}

.item-name {
  color: #606266;
}

.item-qty {
  font-weight: 600;
  color: #303133;
}

.progress-section {
  display: flex;
  align-items: center;
  gap: 12px;
}

.progress-text {
  font-size: 12px;
  color: #909399;
}

.action-buttons {
  display: flex;
  gap: 8px;
}
</style>
