<template>
  <div class="order-detail-page">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <el-button @click="goBack" text>
            <el-icon><ArrowLeft /></el-icon>
            返回订单列表
          </el-button>
          <div class="header-actions">
            <el-button type="primary" @click="handlePrint">
              <el-icon><Printer /></el-icon>
              打印订单
            </el-button>
          </div>
        </div>
      </template>

      <div v-loading="loading">
        <div v-if="orderDetail" class="detail-content">
          <el-row :gutter="20">
            <el-col :span="16">
              <el-card shadow="never" class="mb-4">
                <template #header>
                  <div class="section-header">
                    <span class="section-title">基本信息</span>
                    <el-tag :type="getStatusType(orderDetail.status)" effect="dark">
                      {{ getStatusText(orderDetail.status) }}
                    </el-tag>
                  </div>
                </template>
                <el-descriptions :column="2" border>
                  <el-descriptions-item label="订单号">
                    <span class="order-no">{{ orderDetail.orderNo }}</span>
                  </el-descriptions-item>
                  <el-descriptions-item label="订单类型">
                    {{ orderDetail.paymentType || '月结' }}
                  </el-descriptions-item>
                  <el-descriptions-item label="水站名称">
                    {{ orderDetail.stationName || '-' }}
                  </el-descriptions-item>
                  <el-descriptions-item label="所属仓库">
                    {{ orderDetail.warehouseName || '-' }}
                  </el-descriptions-item>
                  <el-descriptions-item label="下单时间">
                    {{ formatDateTime(orderDetail.createTime) }}
                  </el-descriptions-item>
                  <el-descriptions-item label="支付方式">
                    {{ orderDetail.paymentType || '月结' }}
                  </el-descriptions-item>
                  <el-descriptions-item label="订单金额">
                    <span class="amount-text">¥ {{ orderDetail.totalAmount?.toLocaleString() }}</span>
                  </el-descriptions-item>
                  <el-descriptions-item label="总桶数">
                    {{ orderDetail.totalBuckets || orderDetail.totalQuantity || 0 }} 桶
                  </el-descriptions-item>
                </el-descriptions>
              </el-card>

              <el-card shadow="never" class="mb-4">
                <template #header>
                  <span class="section-title">商品明细</span>
                </template>
                <el-table :data="orderDetail.items || []" stripe>
                  <el-table-column prop="productName" label="商品名称" min-width="150" />
                  <el-table-column prop="productSpec" label="规格" width="120" />
                  <el-table-column prop="quantity" label="数量" width="100" align="center">
                    <template #default="{ row }">
                      <span>{{ row.quantity }} 桶</span>
                    </template>
                  </el-table-column>
                  <el-table-column prop="price" label="单价" width="120" align="right">
                    <template #default="{ row }">
                      <span>¥ {{ row.price }}</span>
                    </template>
                  </el-table-column>
                  <el-table-column prop="subtotal" label="小计" width="120" align="right">
                    <template #default="{ row }">
                      <span class="amount-text">¥ {{ (row.subtotal || (row.quantity * row.price))?.toLocaleString() }}</span>
                    </template>
                  </el-table-column>
                </el-table>
                <div class="amount-summary">
                  <el-row :gutter="20">
                    <el-col :span="12">
                      <div class="summary-item">
                        <span class="label">商品总数：</span>
                        <span class="value">{{ getTotalQuantity() }} 桶</span>
                      </div>
                    </el-col>
                    <el-col :span="12">
                      <div class="summary-item">
                        <span class="label">订单总额：</span>
                        <span class="value total-amount">¥ {{ orderDetail.totalAmount?.toLocaleString() }}</span>
                      </div>
                    </el-col>
                  </el-row>
                </div>
              </el-card>

              <el-card v-if="orderDetail.driver" shadow="never" class="mb-4">
                <template #header>
                  <span class="section-title">配送信息</span>
                </template>
                <el-descriptions :column="2" border>
                  <el-descriptions-item label="配送司机">
                    {{ orderDetail.driver.name || '-' }}
                  </el-descriptions-item>
                  <el-descriptions-item label="司机电话">
                    {{ orderDetail.driver.phone || '-' }}
                  </el-descriptions-item>
                  <el-descriptions-item label="车牌号">
                    {{ orderDetail.driver.vehiclePlate || '-' }}
                  </el-descriptions-item>
                  <el-descriptions-item label="配送状态">
                    <el-tag v-if="orderDetail.deliveryStatus" :type="getDeliveryStatusType(orderDetail.deliveryStatus)" size="small">
                      {{ getDeliveryStatusText(orderDetail.deliveryStatus) }}
                    </el-tag>
                    <span v-else>-</span>
                  </el-descriptions-item>
                  <el-descriptions-item label="派单时间">
                    {{ formatDateTime(orderDetail.dispatchTime) }}
                  </el-descriptions-item>
                  <el-descriptions-item label="送达时间">
                    {{ formatDateTime(orderDetail.deliveryTime) }}
                  </el-descriptions-item>
                </el-descriptions>
              </el-card>

              <el-card v-if="orderDetail.address" shadow="never" class="mb-4">
                <template #header>
                  <span class="section-title">收货地址</span>
                </template>
                <div class="address-info">
                  <el-icon><Location /></el-icon>
                  <span>{{ orderDetail.address }}</span>
                </div>
              </el-card>

              <el-card v-if="orderDetail.remark" shadow="never" class="mb-4">
                <template #header>
                  <span class="section-title">订单备注</span>
                </template>
                <div class="remark-content">
                  {{ orderDetail.remark }}
                </div>
              </el-card>
            </el-col>

            <el-col :span="8">
              <el-card shadow="never" class="status-timeline">
                <template #header>
                  <span class="section-title">订单进度</span>
                </template>
                <el-timeline>
                  <el-timeline-item
                    v-for="(item, index) in orderTimeline"
                    :key="index"
                    :type="item.type"
                    :hollow="item.hollow"
                    :timestamp="item.time"
                    placement="top"
                  >
                    <div class="timeline-content">
                      <span class="timeline-title">{{ item.title }}</span>
                      <span v-if="item.description" class="timeline-desc">{{ item.description }}</span>
                    </div>
                  </el-timeline-item>
                </el-timeline>
              </el-card>

              <el-card shadow="never" class="mb-4">
                <template #header>
                  <span class="section-title">操作记录</span>
                </template>
                <el-table :data="orderLogs" size="small">
                  <el-table-column prop="actionTime" label="操作时间" width="160">
                    <template #default="{ row }">
                      {{ formatDateTime(row.actionTime) }}
                    </template>
                  </el-table-column>
                  <el-table-column prop="operator" label="操作人" />
                  <el-table-column prop="action" label="操作内容" />
                </el-table>
              </el-card>
            </el-col>
          </el-row>
        </div>

        <el-empty v-else-if="!loading" description="暂无订单详情" />
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ordersApi } from '@/api/orders'

interface OrderDetail {
  id?: number
  orderId?: number
  orderNo: string
  stationName: string
  warehouseName: string
  totalAmount: number
  totalBuckets: number
  totalQuantity: number
  status: string
  paymentType: string
  createTime: string
  reviewTime?: string
  dispatchTime?: string
  deliveryTime?: string
  completeTime?: string
  cancelTime?: string
  cancelReason?: string
  rejectTime?: string
  rejectReason?: string
  address?: string
  remark?: string
  items: Array<{
    productName: string
    productSpec?: string
    quantity: number
    price: number
    subtotal?: number
  }>
  driver?: {
    name: string
    phone: string
    vehiclePlate?: string
  }
  deliveryStatus?: string
  logs?: Array<{
    actionTime: string
    operator: string
    action: string
  }>
}

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const orderDetail = ref<OrderDetail | null>(null)

const orderTimeline = computed(() => {
  if (!orderDetail.value) return []
  
  const status = orderDetail.value.status
  const timeline = [
    {
      title: '创建订单',
      time: formatDateTime(orderDetail.value.createTime),
      type: 'primary',
      hollow: false,
      description: '水站提交订单'
    }
  ]

  if (['REVIEWED', 'DISPATCHED', 'DELIVERING', 'COMPLETED'].includes(status)) {
    timeline.push({
      title: '仓库接单',
      time: formatDateTime(orderDetail.value.reviewTime),
      type: 'primary',
      hollow: false,
      description: '仓库已审核订单'
    })
  }

  if (['DISPATCHED', 'DELIVERING', 'COMPLETED'].includes(status)) {
    timeline.push({
      title: '已派单',
      time: formatDateTime(orderDetail.value.dispatchTime),
      type: 'primary',
      hollow: false,
      description: orderDetail.value.driver ? `分配给司机 ${orderDetail.value.driver.name}` : ''
    })
  }

  if (['DELIVERING', 'COMPLETED'].includes(status)) {
    timeline.push({
      title: '配送中',
      time: formatDateTime(orderDetail.value.deliveryTime),
      type: 'warning',
      hollow: false,
      description: '司机正在配送'
    })
  }

  if (status === 'COMPLETED') {
    timeline.push({
      title: '已完成',
      time: formatDateTime(orderDetail.value.completeTime),
      type: 'success',
      hollow: false,
      description: '订单已完成配送'
    })
  }

  if (status === 'CANCELLED') {
    timeline.push({
      title: '已取消',
      time: formatDateTime(orderDetail.value.cancelTime),
      type: 'info',
      hollow: false,
      description: orderDetail.value.cancelReason || '用户取消订单'
    })
  }

  if (status === 'REJECTED') {
    timeline.push({
      title: '已拒单',
      time: formatDateTime(orderDetail.value.rejectTime),
      type: 'danger',
      hollow: false,
      description: orderDetail.value.rejectReason || '仓库拒绝接单'
    })
  }

  return timeline
})

const orderLogs = computed(() => {
  return orderDetail.value?.logs || []
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

const getDeliveryStatusType = (status: string) => {
  const typeMap: Record<string, string> = {
    PENDING: 'warning',
    PICKED_UP: 'primary',
    DELIVERING: 'warning',
    COMPLETED: 'success',
    FAILED: 'danger'
  }
  return typeMap[status] || 'info'
}

const getDeliveryStatusText = (status: string) => {
  const textMap: Record<string, string> = {
    PENDING: '待取货',
    PICKED_UP: '已取货',
    DELIVERING: '配送中',
    COMPLETED: '已完成',
    FAILED: '配送失败'
  }
  return textMap[status] || status
}

const formatDateTime = (dateStr: string | undefined) => {
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

const getTotalQuantity = () => {
  if (!orderDetail.value?.items) return 0
  return orderDetail.value.items.reduce((sum, item) => sum + (item.quantity || 0), 0)
}

const fetchOrderDetail = async () => {
  const orderId = route.params.id
  if (!orderId) {
    ElMessage.error('订单ID不能为空')
    return
  }

  loading.value = true
  try {
    const res: any = await ordersApi.getById(String(orderId))
    console.log('订单详情API响应:', res)

    let data = res
    if (res && res.data !== undefined) {
      data = res.data
    }

    if (data) {
      orderDetail.value = {
        ...data,
        orderId: data.orderId || data.id,
        totalBuckets: data.totalBuckets || data.totalQuantity || 0,
        items: data.items || []
      }
    } else {
      orderDetail.value = null
      ElMessage.warning('未找到订单详情')
    }
  } catch (error) {
    console.error('获取订单详情失败:', error)
    ElMessage.error('获取订单详情失败')
    orderDetail.value = null
  } finally {
    loading.value = false
  }
}

const goBack = () => {
  router.push('/orders')
}

const handlePrint = () => {
  ElMessage.info('正在准备打印订单...')
}

onMounted(() => {
  fetchOrderDetail()
})
</script>

<style scoped>
.order-detail-page {
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

.header-actions {
  display: flex;
  gap: 12px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.section-title {
  font-weight: 600;
  font-size: 16px;
  color: #303133;
}

.order-no {
  font-family: monospace;
  font-weight: 600;
  color: #409eff;
}

.amount-text {
  font-weight: 600;
  color: #303133;
}

.amount-summary {
  margin-top: 20px;
  padding: 16px;
  background: #f5f7fa;
  border-radius: 8px;
}

.summary-item {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  padding: 8px 0;
}

.summary-item .label {
  color: #606266;
  margin-right: 8px;
}

.summary-item .value {
  font-weight: 600;
  color: #303133;
}

.total-amount {
  font-size: 18px;
  color: #f56c6c;
}

.address-info {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  color: #606266;
}

.address-info .el-icon {
  color: #409eff;
  font-size: 18px;
  margin-top: 2px;
}

.remark-content {
  color: #606266;
  line-height: 1.6;
}

.status-timeline {
  margin-bottom: 20px;
}

.timeline-content {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.timeline-title {
  font-weight: 500;
  color: #303133;
}

.timeline-desc {
  font-size: 13px;
  color: #909399;
}
</style>
