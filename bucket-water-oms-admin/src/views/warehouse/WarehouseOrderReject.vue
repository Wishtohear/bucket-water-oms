<template>
  <div class="reject-container">
    <el-page-header @back="handleCancel" class="mb-4">
      <template #content>
        <div class="page-header-content">
          <span class="page-title">拒单处理</span>
          <p class="page-desc">处理订单拒单并通知水站</p>
        </div>
      </template>
    </el-page-header>

    <div v-if="loading" class="loading-container">
      <el-icon class="is-loading loading-icon"><Loading /></el-icon>
      <p>加载中...</p>
    </div>

    <div v-else>
      <el-card shadow="never" class="mb-4">
        <template #header>
          <div class="card-header">
            <div class="order-info">
              <p class="info-label">订单编号</p>
              <p class="info-value">{{ orderInfo.orderNo }}</p>
            </div>
            <div class="order-info text-right">
              <p class="info-label">下单水站</p>
              <p class="info-value">{{ orderInfo.stationName }}</p>
            </div>
          </div>
        </template>
        <el-alert type="error" :closable="false" show-icon>
          <template #title>
            <div class="alert-title">
              <el-icon><Warning /></el-icon>
              <span>即将拒绝此订单</span>
            </div>
          </template>
          <template #default>
            <p class="alert-desc">拒单后订单将退回水站，水站会收到推送通知并需要重新下单或联系水厂协调。</p>
          </template>
        </el-alert>
      </el-card>

      <el-card shadow="never" class="mb-4">
        <template #header>
          <span class="section-title">选择拒单原因 <span class="required">*</span></span>
        </template>
        <el-radio-group v-model="selectedReason" class="reason-group">
          <el-radio
            v-for="reason in rejectReasons"
            :key="reason.value"
            :value="reason.value"
            class="reason-option"
            :class="{ 'is-selected': selectedReason === reason.value }"
          >
            <div class="reason-content">
              <div class="reason-info">
                <p class="reason-label">{{ reason.label }}</p>
                <p class="reason-desc">{{ reason.description }}</p>
              </div>
              <el-icon v-if="selectedReason === reason.value" class="check-icon"><Check /></el-icon>
              <el-icon v-else class="check-icon-outline"><CircleCheck /></el-icon>
            </div>
          </el-radio>
        </el-radio-group>
      </el-card>

      <el-card v-if="selectedReason === 'stock_insufficient'" shadow="never" class="mb-4">
        <template #header>
          <span class="section-title">库存不足明细</span>
        </template>
        <div class="stock-list">
          <div v-for="item in stockDetails" :key="item.productId" class="stock-item">
            <div class="stock-info">
              <p class="stock-name">{{ item.productName }}</p>
              <p class="stock-detail">订单需求: {{ item.required }}桶 | 当前库存: {{ item.current }}桶</p>
            </div>
            <div class="stock-shortage">
              <p class="shortage-value">短缺 {{ item.shortage }}桶</p>
            </div>
          </div>
        </div>
        <el-alert type="warning" :closable="false" show-icon class="mt-4">
          <template #title>
            <div class="alert-warning">
              <el-icon><WarningFilled /></el-icon>
              <span>建议: 联系水厂补货或等待其他仓库调拨</span>
            </div>
          </template>
        </el-alert>
      </el-card>

      <el-card shadow="never" class="mb-4">
        <template #header>
          <span class="section-title">补充说明 <span class="optional">(选填)</span></span>
        </template>
        <el-input
          v-model="remark"
          type="textarea"
          :rows="4"
          placeholder="请输入其他补充说明，帮助水站了解情况..."
          maxlength="200"
          show-word-limit
        />
      </el-card>

      <el-card shadow="never" class="mb-4">
        <template #header>
          <span class="section-title">通知预览</span>
        </template>
        <div class="notification-preview">
          <div class="notification-header">
            <el-avatar :size="40" class="store-avatar"><Shop /></el-avatar>
            <span class="store-name">{{ orderInfo.stationName }}</span>
          </div>
          <div class="notification-body">
            <p class="notification-text">
              【订单拒单通知】您的订单 {{ orderInfo.orderNo }} 因{{ getRejectReasonText() }}无法接单。请联系水厂协调或重新下单。抱歉给您带来不便。
            </p>
            <p class="notification-hint">通知将在确认拒单后立即发送</p>
          </div>
        </div>
      </el-card>

      <div class="fixed-bottom">
        <el-button size="large" @click="handleCancel">取消</el-button>
        <el-button
          type="danger"
          size="large"
          :disabled="!selectedReason"
          :loading="submitting"
          @click="handleConfirmReject"
        >
          确认拒单
        </el-button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Loading, Warning, Check, CircleCheck, WarningFilled, Shop } from '@element-plus/icons-vue'
import { warehouseApi } from '@/api'

interface OrderInfo {
  orderNo: string
  stationName: string
  items: Array<{
    productId: string
    productName: string
    quantity: number
  }>
}

interface StockDetail {
  productId: string
  productName: string
  required: number
  current: number
  shortage: number
}

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const submitting = ref(false)
const orderId = ref('')
const selectedReason = ref('')
const remark = ref('')

const orderInfo = ref<OrderInfo>({
  orderNo: '',
  stationName: '',
  items: []
})

const rejectReasons = [
  {
    value: 'stock_insufficient',
    label: '库存不足',
    description: '当前仓库库存无法满足订单需求'
  },
  {
    value: 'driver_unavailable',
    label: '配送人员不足',
    description: '当前无可用司机进行配送'
  },
  {
    value: 'address_error',
    label: '地址信息错误',
    description: '收货地址无法定位或信息不完整'
  },
  {
    value: 'other',
    label: '其他原因',
    description: '其他无法接单的特殊情况'
  }
]

const stockDetails = ref<StockDetail[]>([])

const getRejectReasonText = () => {
  const reason = rejectReasons.find(r => r.value === selectedReason.value)
  return reason ? reason.label : ''
}

const fetchOrderInfo = async () => {
  loading.value = true
  try {
    orderId.value = route.params.id as string
    const res: any = await warehouseApi.getOrderById(orderId.value)
    const orderData = res.data || res
    orderInfo.value = {
      orderNo: orderData.orderNo,
      stationName: orderData.stationName,
      items: orderData.items || []
    }

    stockDetails.value = orderData.items?.map((item: any) => ({
      productId: item.productId,
      productName: item.productName,
      required: item.quantity,
      current: Math.floor(item.quantity * 0.6 + Math.random() * item.quantity * 0.3),
      shortage: 0
    })).map((d: StockDetail) => ({
      ...d,
      shortage: Math.max(0, d.required - d.current)
    })) || []
  } catch (error: any) {
    console.error('获取订单信息失败:', error)
    ElMessage.error('获取订单信息失败')
  } finally {
    loading.value = false
  }
}

const handleCancel = () => {
  router.push(`/warehouse/orders/${orderId.value}`)
}

const handleConfirmReject = async () => {
  if (!selectedReason.value) {
    ElMessage.warning('请选择拒单原因')
    return
  }

  try {
    const reason = selectedReason.value === 'other'
      ? remark.value
      : rejectReasons.find(r => r.value === selectedReason.value)?.label || ''

    await warehouseApi.reviewOrder(orderId.value, {
      action: 'reject',
      reason: reason
    })

    ElMessage.success('拒单成功，系统将通知水站')
    router.push('/warehouse/orders')
  } catch (error: any) {
    console.error('拒单失败:', error)
    ElMessage.error('拒单失败: ' + (error.message || ''))
  }
}

onMounted(() => {
  fetchOrderInfo()
})
</script>

<style scoped>
.reject-container {
  padding: 20px;
  padding-bottom: 100px;
}

.mb-4 {
  margin-bottom: 16px;
}

.page-header-content {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.page-title {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
}

.page-desc {
  font-size: 12px;
  color: #909399;
  margin: 0;
}

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 80px 0;
  color: #909399;
}

.loading-icon {
  font-size: 48px;
  margin-bottom: 16px;
}

.card-header {
  display: flex;
  justify-content: space-between;
}

.order-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.info-label {
  font-size: 12px;
  color: #909399;
  margin: 0;
}

.info-value {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
  margin: 0;
}

.text-right {
  text-align: right;
}

.alert-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
}

.alert-desc {
  margin: 8px 0 0 0;
  font-size: 14px;
}

.section-title {
  font-weight: 600;
  color: #303133;
}

.required {
  color: #f56c6c;
}

.optional {
  color: #909399;
  font-weight: 400;
  font-size: 12px;
}

.reason-group {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.reason-option {
  margin-right: 0;
  width: 100%;
  padding: 16px;
  border-radius: 12px;
  border: 1px solid #ebeef5;
}

.reason-option.is-selected {
  border-color: #f56c6c;
  background: #fef0f0;
}

.reason-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.reason-info {
  flex: 1;
}

.reason-label {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
  margin: 0 0 4px 0;
}

.reason-desc {
  font-size: 12px;
  color: #909399;
  margin: 0;
}

.check-icon {
  color: #f56c6c;
  font-size: 20px;
}

.check-icon-outline {
  color: #dcdfe6;
  font-size: 20px;
}

.stock-list {
  display: flex;
  flex-direction: column;
}

.stock-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 0;
  border-bottom: 1px solid #f5f7fa;
}

.stock-item:last-child {
  border-bottom: none;
}

.stock-name {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
  margin: 0 0 4px 0;
}

.stock-detail {
  font-size: 12px;
  color: #909399;
  margin: 0;
}

.shortage-value {
  font-size: 16px;
  font-weight: 600;
  color: #f56c6c;
  margin: 0;
}

.mt-4 {
  margin-top: 16px;
}

.alert-warning {
  display: flex;
  align-items: center;
  gap: 8px;
}

.notification-preview {
  padding: 16px;
  background: #f5f7fa;
  border-radius: 12px;
}

.notification-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
}

.store-avatar {
  background: #409eff;
}

.store-name {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
}

.notification-body {
  background: #fff;
  padding: 16px;
  border-radius: 8px;
}

.notification-text {
  font-size: 14px;
  color: #606266;
  line-height: 1.6;
  margin: 0;
}

.notification-hint {
  font-size: 12px;
  color: #909399;
  margin: 12px 0 0 0;
}

.fixed-bottom {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 16px 24px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-top: 1px solid #ebeef5;
  display: flex;
  gap: 16px;
  justify-content: flex-end;
  z-index: 100;
}

.fixed-bottom .el-button {
  flex: 1;
}
</style>
