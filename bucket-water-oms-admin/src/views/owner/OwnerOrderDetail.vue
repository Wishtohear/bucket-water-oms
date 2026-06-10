<template>
  <div class="order-detail-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <el-button @click="goBack" :icon="ArrowLeft">返回</el-button>
          <div class="header-info">
            <span class="header-title">订单详情</span>
            <span class="header-subtitle">订单号: {{ order.orderNo }}</span>
          </div>
        </div>
      </template>

      <div v-if="loading" class="loading-container">
        <el-icon class="is-loading"><Loading /></el-icon>
        <span>加载中...</span>
      </div>

      <template v-else>
        <el-row :gutter="20">
          <el-col :span="16">
            <el-card shadow="never" class="mb-4">
              <template #header>
                <div class="section-header">
                  <el-icon><Clock /></el-icon>
                  <span>订单状态</span>
                </div>
              </template>
              <div class="status-header">
                <div class="status-info">
                  <el-tag :type="getStatusTagType(order.status)" size="large">
                    {{ order.statusText }}
                  </el-tag>
                  <p class="status-desc">{{ order.statusDescription }}</p>
                </div>
              </div>

              <el-divider v-if="order.status === 'delivering'" />

              <div v-if="order.status === 'delivering'" class="driver-section">
                <el-row :gutter="20" align="middle">
                  <el-col :span="16">
                    <div class="driver-info">
                      <el-avatar :size="48" :icon="UserFilled" />
                      <div class="driver-detail">
                        <p class="driver-name">{{ order.driverName }}</p>
                        <p class="driver-label">正在送往水站</p>
                      </div>
                    </div>
                  </el-col>
                  <el-col :span="8" class="text-right">
                    <el-button circle type="primary" @click="handleCallDriver">
                      <el-icon><Phone /></el-icon>
                    </el-button>
                    <el-button circle type="success">
                      <el-icon><Message /></el-icon>
                    </el-button>
                  </el-col>
                </el-row>
              </div>
            </el-card>

            <el-card v-if="order.progressSteps && order.progressSteps.length > 0" shadow="never" class="mb-4">
              <template #header>
                <div class="section-header">
                  <el-icon><Guide /></el-icon>
                  <span>配送进度</span>
                </div>
              </template>
              <el-steps :active="getActiveStep(order.status)" align-center finish-status="success">
                <el-step
                  v-for="(step, index) in order.progressSteps"
                  :key="index"
                  :title="step.title"
                  :description="step.time"
                />
              </el-steps>
            </el-card>

            <el-card shadow="never" class="mb-4">
              <template #header>
                <div class="section-header">
                  <el-icon><Document /></el-icon>
                  <span>订单信息</span>
                </div>
              </template>
              <el-descriptions :column="2" border>
                <el-descriptions-item label="订单编号">{{ order.orderNo }}</el-descriptions-item>
                <el-descriptions-item label="下单时间">{{ order.createTime }}</el-descriptions-item>
                <el-descriptions-item label="配送仓库">{{ order.warehouseName }}</el-descriptions-item>
                <el-descriptions-item label="支付方式">{{ order.paymentTypeText }}</el-descriptions-item>
                <el-descriptions-item label="订单金额" :span="2">
                  <span class="order-amount">¥{{ order.totalAmount }}</span>
                </el-descriptions-item>
              </el-descriptions>
            </el-card>

            <el-card shadow="never" class="mb-4">
              <template #header>
                <div class="section-header">
                  <el-icon><Location /></el-icon>
                  <span>收货地址</span>
                </div>
              </template>
              <el-descriptions :column="2" border>
                <el-descriptions-item label="水站名称">{{ order.stationName }}</el-descriptions-item>
                <el-descriptions-item label="联系人">{{ order.contactName }}</el-descriptions-item>
                <el-descriptions-item label="联系电话">{{ order.contactPhone }}</el-descriptions-item>
                <el-descriptions-item label="收货地址" :span="2">{{ order.deliveryAddress }}</el-descriptions-item>
              </el-descriptions>
            </el-card>

            <el-card shadow="never">
              <template #header>
                <div class="section-header">
                  <el-icon><Goods /></el-icon>
                  <span>商品明细</span>
                </div>
              </template>
              <el-table :data="order.items" border stripe>
                <el-table-column label="商品信息" min-width="200">
                  <template #default="{ row }">
                    <div class="product-cell">
                      <el-image :src="row.image || defaultProductImage" class="product-image" fit="cover" />
                      <div class="product-info">
                        <p class="product-name">{{ row.productName }}</p>
                        <p class="product-spec">{{ row.spec }}</p>
                      </div>
                    </div>
                  </template>
                </el-table-column>
                <el-table-column label="单价" width="100" align="center">
                  <template #default="{ row }">
                    <span>¥{{ row.price }}</span>
                  </template>
                </el-table-column>
                <el-table-column label="数量" width="80" align="center">
                  <template #default="{ row }">
                    <span>x{{ row.quantity }}</span>
                  </template>
                </el-table-column>
                <el-table-column label="小计" width="100" align="center">
                  <template #default="{ row }">
                    <span class="subtotal">¥{{ (Number(row.price) * Number(row.quantity)).toFixed(2) }}</span>
                  </template>
                </el-table-column>
              </el-table>
              <div class="total-section">
                <span class="total-label">合计</span>
                <span class="total-price">¥{{ order.totalAmount }}</span>
              </div>
            </el-card>
          </el-col>

          <el-col :span="8">
            <el-card shadow="never">
              <template #header>
                <div class="section-header">
                  <el-icon><Operation /></el-icon>
                  <span>操作</span>
                </div>
              </template>
              <div class="action-list">
                <el-button v-if="order.status === 'pending_dispatch'" type="warning" class="action-btn" @click="goToDispatch">
                  <el-icon><Van /></el-icon>
                  去派单
                </el-button>
                <el-button v-if="order.sourceType === 'station' && order.driverName && order.driverPhone" type="primary" class="action-btn" @click="handleCallDriver">
                  <el-icon><Phone /></el-icon>
                  联系配送员
                </el-button>
                <el-button class="action-btn" @click="handlePrint">
                  <el-icon><Printer /></el-icon>
                  打印订单
                </el-button>
                <el-button v-if="order.status === 'completed'" type="primary" class="action-btn" @click="handleReorder">
                  <el-icon><RefreshRight /></el-icon>
                  再来一单
                </el-button>
              </div>
            </el-card>
          </el-col>
        </el-row>
      </template>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import {
  ArrowLeft, Loading, Clock, UserFilled, Phone, Message,
  Guide, Document, Location, Goods, Operation, Printer,
  RefreshRight, Van
} from '@element-plus/icons-vue'
import { stationOwnerApi } from '@/api'
import { toast } from '@/composables/useToast'

const router = useRouter()
const route = useRoute()

const loading = ref(true)
const defaultProductImage = 'https://modao.cc/agent-py/media/generated_images/2026-04-19/a334311da7854958a4c575d1ed971989.jpg'

const order = ref<any>({
  id: '',
  orderNo: '',
  status: '',
  statusText: '',
  statusDescription: '',
  sourceType: 'warehouse',
  stationName: '',
  warehouseName: '',
  driverName: '',
  driverPhone: '',
  totalAmount: '0.00',
  createTime: '',
  paymentTypeText: '月结',
  contactName: '',
  contactPhone: '',
  deliveryAddress: '',
  progressSteps: [],
  items: []
})

const loadOrderDetail = async () => {
  try {
    loading.value = true
    const orderId = route.params.id as string
    const res = await stationOwnerApi.getOrderById(orderId)

    const data = (res as any).data
    if (data) {
      order.value = {
        id: data.orderId || data.id,
        orderNo: data.orderNo,
        status: data.status,
        statusText: getStatusText(data.status),
        statusDescription: getStatusDescription(data.status),
        sourceType: data.sourceType || 'warehouse',
        stationName: data.stationName || '',
        warehouseName: data.warehouseName || '未知仓库',
        driverName: data.driverName || '',
        driverPhone: data.driverPhone || data.driver?.phone || '',
        totalAmount: typeof data.totalAmount === 'number' ? Number(data.totalAmount).toFixed(2) : String(data.totalAmount || '0.00'),
        createTime: data.createTime ? new Date(data.createTime).toLocaleString('zh-CN') : '',
        paymentTypeText: data.paymentTypeText || getPaymentTypeText(data.paymentType),
        contactName: data.contactName || '',
        contactPhone: data.contactPhone || '',
        deliveryAddress: data.deliveryAddress || '',
        items: (data.items || []).map((item: any) => ({
          id: item.id || item.productId,
          productId: item.productId,
          productName: item.productName,
          spec: item.spec || '',
          price: item.unitPrice ?? item.price ?? 0,
          quantity: item.quantity ?? 0,
          actualQty: item.actualQty,
          amount: item.subtotal ?? item.amount ?? 0,
          image: defaultProductImage
        })),
        progressSteps: buildProgressSteps(data)
      }
    }
  } catch (error: any) {
    toast.error('加载订单详情失败：' + (error.message || '未知错误'))
  } finally {
    loading.value = false
  }
}

const getStatusText = (status: string) => {
  const map: Record<string, string> = {
    pending_review: '待审查',
    pending_dispatch: '待派单',
    pending_accept: '待接单',
    reviewed: '已接单',
    dispatched: '已派单',
    delivering: '配送中',
    completed: '已完成',
    cancelled: '已取消',
    rejected: '已拒单'
  }
  return map[status] || status
}

const getStatusDescription = (status: string) => {
  const map: Record<string, string> = {
    pending_review: '等待仓库审查订单',
    pending_dispatch: '请选择配送员进行派单',
    pending_accept: '等待配送员接单',
    reviewed: '仓库已接单，正在备货',
    dispatched: '已分配司机，等待配送',
    delivering: '正在配送中',
    completed: '订单已完成',
    cancelled: '订单已取消',
    rejected: '订单已被拒绝'
  }
  return map[status] || ''
}

const getStatusTagType = (status: string) => {
  const map: Record<string, string> = {
    pending_review: 'warning',
    reviewed: 'primary',
    dispatched: 'primary',
    delivering: 'primary',
    completed: 'success',
    rejected: 'danger',
    cancelled: 'info'
  }
  return map[status] || ''
}

const getPaymentTypeText = (type: string) => {
  const map: Record<string, string> = {
    prepaid: '预存金',
    monthly: '月结',
    credit: '信用额度'
  }
  return map[type] || type
}

const getActiveStep = (status: string) => {
  const stepMap: Record<string, number> = {
    pending_review: 0,
    reviewed: 1,
    dispatched: 2,
    delivering: 3,
    completed: 4
  }
  return stepMap[status] ?? 0
}

const buildProgressSteps = (orderData: any) => {
  return [
    { title: '订单已提交', time: orderData.createTime || '' },
    { title: '仓库已确认', time: orderData.reviewedAt || '' },
    { title: '已出库', time: orderData.dispatchedAt || '' },
    { title: '配送中', time: '' },
    { title: '已签收', time: orderData.deliveredAt || '' }
  ]
}

const handleCallDriver = () => {
  if (order.value.driverPhone) {
    window.location.href = `tel:${order.value.driverPhone}`
  } else {
    toast.warning('暂无配送员联系方式')
  }
}

const goToDispatch = () => {
  router.push(`/station/dispatch/${order.value.id}`)
}

const handlePrint = () => {
  toast.info('打印功能开发中')
}

const goBack = () => {
  router.back()
}

const handleReorder = () => {
  router.push({
    path: '/station/create-order',
    query: { fromOrder: order.value.id }
  })
}

onMounted(() => {
  loadOrderDetail()
})
</script>

<style scoped>
.order-detail-container {
  padding: 0;
}

.card-header {
  display: flex;
  align-items: center;
  gap: 16px;
}

.header-info {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.header-title {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
}

.header-subtitle {
  font-size: 12px;
  color: #909399;
}

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 0;
  gap: 16px;
  color: #909399;
}

.section-header {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
}

.status-header {
  display: flex;
  align-items: center;
  gap: 16px;
}

.status-info {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.status-desc {
  font-size: 14px;
  color: #606266;
  margin: 0;
}

.driver-section {
  padding: 16px 0;
}

.driver-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.driver-detail .driver-name {
  font-weight: 600;
  color: #303133;
  margin: 0;
}

.driver-detail .driver-label {
  font-size: 12px;
  color: #909399;
  margin: 4px 0 0;
}

.product-cell {
  display: flex;
  align-items: center;
  gap: 12px;
}

.product-image {
  width: 50px;
  height: 50px;
  border-radius: 8px;
}

.product-info .product-name {
  font-weight: 500;
  color: #303133;
}

.product-info .product-spec {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
}

.subtotal {
  font-weight: 600;
  color: #409EFF;
}

.order-amount {
  font-size: 18px;
  font-weight: 600;
  color: #409EFF;
}

.total-section {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  gap: 16px;
  padding: 16px 0 0;
  border-top: 1px solid #ebeef5;
  margin-top: 16px;
}

.total-label {
  font-size: 14px;
  color: #606266;
}

.total-price {
  font-size: 24px;
  font-weight: 600;
  color: #409EFF;
}

.action-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.action-btn {
  width: 100%;
  justify-content: flex-start;
}

.mb-4 {
  margin-bottom: 16px;
}

.text-right {
  text-align: right;
}
</style>
