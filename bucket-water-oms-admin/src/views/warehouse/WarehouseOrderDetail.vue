<template>
  <div class="order-detail-container">
    <div v-if="loading" class="loading-container">
      <el-icon class="is-loading loading-icon"><Loading /></el-icon>
      <p>加载中...</p>
    </div>

    <div v-else-if="order.orderNo">
      <div class="detail-header">
        <div class="header-left">
          <el-button text @click="goBack" class="back-btn">
            <el-icon><ArrowLeft /></el-icon>
            <span>返回订单列表</span>
          </el-button>
          <h1 class="page-title">订单详情</h1>
          <div class="order-no">
            <span class="label">订单编号</span>
            <span class="value">{{ order.orderNo }}</span>
          </div>
        </div>
        <div class="header-right">
          <el-tag :type="getStatusType(order.status)" size="large" class="status-tag">
            {{ order.statusText }}
          </el-tag>
        </div>
      </div>

      <div class="main-content">
        <div class="left-panel">
          <el-card shadow="never" class="main-card">
            <div class="station-section">
              <div class="section-header">
                <el-icon class="section-icon"><Shop /></el-icon>
                <div class="section-title">
                  <h2>{{ order.stationName }}</h2>
                  <p class="address">{{ order.stationAddress }}</p>
                </div>
                <el-button type="success" circle @click="makePhoneCall" class="call-btn">
                  <el-icon><Phone /></el-icon>
                </el-button>
              </div>
            </div>

            <el-divider />

            <div class="info-grid">
              <div class="info-item">
                <span class="info-label">下单时间</span>
                <span class="info-value">{{ order.createTime }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">预约配送</span>
                <span class="info-value highlight">{{ order.reviewedAt || '未设置' }}</span>
              </div>
            </div>
          </el-card>

          <el-card shadow="never" class="main-card">
            <template #header>
              <div class="card-header">
                <span class="card-title">商品明细</span>
                <span class="item-count">共 {{ order.items.length }} 种商品</span>
              </div>
            </template>
            <el-table :data="order.items" border stripe>
              <el-table-column prop="productName" label="商品名称" min-width="150" />
              <el-table-column label="单价" width="120" align="right">
                <template #default="{ row }">
                  <span class="price">¥ {{ row.price }}</span>
                </template>
              </el-table-column>
              <el-table-column label="数量" width="120" align="center">
                <template #default="{ row }">
                  <span class="quantity">{{ row.quantity }} 桶</span>
                </template>
              </el-table-column>
              <el-table-column label="金额" width="120" align="right">
                <template #default="{ row }">
                  <span class="amount">¥ {{ row.amount }}</span>
                </template>
              </el-table-column>
            </el-table>
            <div class="total-row">
              <div class="total-info">
                <span class="total-label">合计</span>
                <span class="total-items">{{ order.totalBuckets || 0 }} 桶</span>
              </div>
              <div class="total-amount">
                <span class="currency">¥</span>
                <span class="amount-value">{{ order.totalAmount?.toLocaleString() }}</span>
              </div>
            </div>
          </el-card>

          <div class="additional-cards">
            <el-card v-if="order.remark" shadow="never" class="info-card remark">
              <template #header>
                <span class="card-title">订单备注</span>
              </template>
              <p class="remark-text">{{ order.remark }}</p>
            </el-card>

            <el-card v-if="order.rejectReason" shadow="never" class="info-card reject">
              <template #header>
                <span class="card-title danger">拒单原因</span>
              </template>
              <p class="reject-text">{{ order.rejectReason }}</p>
            </el-card>

            <el-card v-if="order.driverName" shadow="never" class="info-card driver">
              <template #header>
                <span class="card-title">配送司机</span>
              </template>
              <div class="driver-info">
                <el-avatar :size="48" class="driver-avatar">
                  <el-icon><Van /></el-icon>
                </el-avatar>
                <div class="driver-details">
                  <p class="driver-name">{{ order.driverName }}</p>
                  <p class="driver-role">配送司机</p>
                </div>
                <el-button type="success" circle @click="makePhoneCall" class="call-btn-small">
                  <el-icon><Phone /></el-icon>
                </el-button>
              </div>
            </el-card>
          </div>
        </div>

        <div class="right-panel">
          <el-card shadow="never" class="stats-card">
            <template #header>
              <span class="card-title">订单统计</span>
            </template>
            <div class="stat-items">
              <div class="stat-item">
                <div class="stat-icon buckets">
                  <el-icon><Goods /></el-icon>
                </div>
                <div class="stat-info">
                  <span class="stat-value">{{ order.totalBuckets || 0 }}</span>
                  <span class="stat-label">商品桶数</span>
                </div>
              </div>
              <div class="stat-divider"></div>
              <div class="stat-item">
                <div class="stat-icon amount">
                  <el-icon><Money /></el-icon>
                </div>
                <div class="stat-info">
                  <span class="stat-value primary">¥{{ order.totalAmount?.toLocaleString() }}</span>
                  <span class="stat-label">订单金额</span>
                </div>
              </div>
            </div>
          </el-card>

          <el-card shadow="never" class="actions-card">
            <template #header>
              <span class="card-title">快捷操作</span>
            </template>
            <div class="action-list">
              <el-button
                v-if="order.status === 'pending_review'"
                type="success"
                size="large"
                @click="handleAccept"
                class="action-btn primary-action"
              >
                <el-icon><Check /></el-icon>
                确认接单
              </el-button>
              <el-button
                v-if="order.status === 'pending_review'"
                type="danger"
                size="large"
                @click="showRejectDialog = true"
                class="action-btn danger-action"
              >
                <el-icon><Close /></el-icon>
                拒单
              </el-button>
              <el-button
                v-if="order.status === 'reviewed'"
                type="primary"
                size="large"
                @click="handleDispatch"
                class="action-btn primary-action"
              >
                <el-icon><Van /></el-icon>
                派单给司机
              </el-button>
              <el-button
                size="large"
                @click="handlePrint"
                class="action-btn"
              >
                <el-icon><Printer /></el-icon>
                打印备货单
              </el-button>
            </div>
          </el-card>

          <el-card shadow="never" class="help-card">
            <div class="help-content">
              <el-icon class="help-icon"><QuestionFilled /></el-icon>
              <div class="help-text">
                <p class="help-title">需要帮助？</p>
                <p class="help-desc">联系技术支持获取帮助</p>
              </div>
            </div>
          </el-card>
        </div>
      </div>
    </div>

    <el-dialog v-model="showRejectDialog" title="拒单原因" width="500px" align-center>
      <el-radio-group v-model="rejectReason" class="reject-reason-group">
        <el-radio value="stock_insufficient" class="reason-option">库存不足</el-radio>
        <el-radio value="driver_unavailable" class="reason-option">配送人员不足</el-radio>
        <el-radio value="address_error" class="reason-option">地址信息错误</el-radio>
        <el-radio value="other" class="reason-option">其他原因</el-radio>
      </el-radio-group>
      <el-input
        v-if="rejectReason === 'other'"
        v-model="rejectRemark"
        type="textarea"
        :rows="3"
        placeholder="请输入拒单原因..."
        class="mt-4"
      />
      <template #footer>
        <el-button @click="showRejectDialog = false">取消</el-button>
        <el-button type="danger" @click="confirmReject">确认拒单</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Loading, Shop, Phone, Printer, Van, ArrowLeft, Check, Close, Goods, Money, QuestionFilled } from '@element-plus/icons-vue'
import { warehouseApi } from '@/api'

const router = useRouter()
const route = useRoute()
const loading = ref(false)
const showRejectDialog = ref(false)
const rejectReason = ref('')
const rejectRemark = ref('')

const order = ref<any>({
  orderNo: '',
  statusText: '',
  stationName: '',
  stationAddress: '',
  createTime: '',
  reviewedAt: '',
  totalBuckets: 0,
  totalAmount: 0,
  items: [],
  remark: '',
  rejectReason: '',
  driverName: ''
})

const goBack = () => {
  router.push('/warehouse/orders')
}

const getStatusType = (status: string) => {
  const typeMap: Record<string, string> = {
    pending_review: 'warning',
    reviewed: 'success',
    preparing: 'primary',
    dispatched: 'info',
    delivering: 'primary',
    completed: 'success',
    rejected: 'danger',
    cancelled: 'info'
  }
  return typeMap[status] || 'info'
}

const makePhoneCall = () => {
  ElMessage.info('拨打功能开发中')
}

const handleAccept = async () => {
  if (!order.value.orderId) {
    ElMessage.error('订单ID无效')
    return
  }
  try {
    await warehouseApi.reviewOrder(order.value.orderId, { action: 'accept' })
    ElMessage.success('接单成功')
    loadOrder()
  } catch (error) {
    console.error('接单失败:', error)
    ElMessage.error('接单失败')
  }
}

const handleDispatch = () => {
  if (!order.value.orderId) {
    ElMessage.error('订单ID无效')
    return
  }
  router.push(`/warehouse/dispatch-select/${order.value.orderId}`)
}

const handlePrint = () => {
  ElMessage.info('打印功能开发中')
}

const confirmReject = async () => {
  if (!rejectReason.value) {
    ElMessage.warning('请选择拒单原因')
    return
  }
  if (!order.value.orderId) {
    ElMessage.error('订单ID无效')
    return
  }

  try {
    const reason = rejectReason.value === 'other'
      ? rejectRemark.value
      : rejectReason.value
    await warehouseApi.reviewOrder(order.value.orderId, { action: 'reject', reason })
    ElMessage.success('拒单成功')
    showRejectDialog.value = false
    loadOrder()
  } catch (error) {
    console.error('拒单失败:', error)
    ElMessage.error('拒单失败')
  }
}

const loadOrder = async () => {
  loading.value = true
  try {
    const orderId = route.params.id as string
    const res: any = await warehouseApi.getOrderById(orderId)
    const orderData = res.data || res
    if (orderData) {
      order.value = {
        ...orderData,
        items: orderData.items || [],
        totalBuckets: orderData.items?.reduce((sum: number, item: any) => sum + item.quantity, 0) || 0
      }
    }
  } catch (error) {
    console.error('获取订单详情失败:', error)
    ElMessage.error('获取订单详情失败')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadOrder()
})
</script>

<style scoped>
.order-detail-container {
  padding: 24px;
  background: #f5f7fa;
  min-height: calc(100vh - 120px);
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

.detail-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 24px;
  background: white;
  padding: 24px;
  border-radius: 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

.header-left {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.back-btn {
  color: #606266;
  font-size: 14px;
  padding: 0;
  height: auto;
}

.back-btn:hover {
  color: #409eff;
}

.page-title {
  font-size: 24px;
  font-weight: 700;
  color: #303133;
  margin: 0;
}

.order-no {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.order-no .label {
  font-size: 12px;
  color: #909399;
}

.order-no .value {
  font-size: 16px;
  font-weight: 600;
  color: #606266;
  font-family: 'Courier New', monospace;
}

.header-right {
  display: flex;
  align-items: center;
}

.status-tag {
  padding: 8px 20px;
  font-size: 14px;
  font-weight: 600;
  border-radius: 20px;
}

.main-content {
  display: grid;
  grid-template-columns: 1fr 360px;
  gap: 24px;
  align-items: start;
}

.left-panel {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.right-panel {
  display: flex;
  flex-direction: column;
  gap: 20px;
  position: sticky;
  top: 24px;
}

.main-card {
  border-radius: 16px;
  overflow: hidden;
}

.main-card :deep(.el-card__header) {
  padding: 20px 24px;
  border-bottom: 1px solid #f0f0f0;
}

.main-card :deep(.el-card__body) {
  padding: 24px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.card-title.danger {
  color: #f56c6c;
}

.item-count {
  font-size: 13px;
  color: #909399;
}

.station-section {
  margin-bottom: 20px;
}

.section-header {
  display: flex;
  align-items: center;
  gap: 16px;
}

.section-icon {
  font-size: 48px;
  color: #409eff;
  background: linear-gradient(135deg, #ecf5ff 0%, #d4ecff 100%);
  padding: 16px;
  border-radius: 16px;
  flex-shrink: 0;
}

.section-title {
  flex: 1;
}

.section-title h2 {
  font-size: 20px;
  font-weight: 700;
  color: #303133;
  margin: 0 0 8px 0;
}

.address {
  font-size: 14px;
  color: #909399;
  margin: 0;
  line-height: 1.5;
}

.call-btn {
  width: 48px;
  height: 48px;
  font-size: 20px;
  flex-shrink: 0;
}

.call-btn-small {
  width: 36px;
  height: 36px;
  font-size: 16px;
}

.info-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.info-label {
  font-size: 13px;
  color: #909399;
}

.info-value {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.info-value.highlight {
  color: #409eff;
}

.additional-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 20px;
}

.info-card {
  border-radius: 16px;
  overflow: hidden;
}

.info-card.remark :deep(.el-card__body) {
  padding: 16px;
}

.info-card.reject {
  background: linear-gradient(135deg, #fef0f0 0%, #fff5f5 100%);
  border: 1px solid #fde2e2;
}

.info-card.driver :deep(.el-card__body) {
  padding: 16px;
}

.remark-text,
.reject-text {
  font-size: 14px;
  color: #606266;
  margin: 0;
  line-height: 1.6;
}

.reject-text {
  color: #f56c6c;
}

.driver-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.driver-avatar {
  background: linear-gradient(135deg, #8b5cf6 0%, #a78bfa 100%);
  flex-shrink: 0;
}

.driver-avatar .el-icon {
  font-size: 24px;
  color: white;
}

.driver-details {
  flex: 1;
}

.driver-name {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  margin: 0 0 4px 0;
}

.driver-role {
  font-size: 13px;
  color: #909399;
  margin: 0;
}

.stats-card {
  border-radius: 16px;
  overflow: hidden;
}

.stats-card :deep(.el-card__header) {
  padding: 20px 24px;
  border-bottom: 1px solid #f0f0f0;
}

.stats-card :deep(.el-card__body) {
  padding: 24px;
}

.stat-items {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 16px;
}

.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  flex-shrink: 0;
}

.stat-icon.buckets {
  background: linear-gradient(135deg, #52c41a 0%, #73d13d 100%);
  color: white;
}

.stat-icon.amount {
  background: linear-gradient(135deg, #1890ff 0%, #409eff 100%);
  color: white;
}

.stat-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.stat-info .stat-value {
  font-size: 24px;
  font-weight: 700;
  color: #303133;
  line-height: 1.2;
}

.stat-info .stat-value.primary {
  color: #1890ff;
}

.stat-info .stat-label {
  font-size: 13px;
  color: #909399;
}

.stat-divider {
  height: 1px;
  background: #f0f0f0;
  margin: 4px 0;
}

.actions-card {
  border-radius: 16px;
  overflow: hidden;
}

.actions-card :deep(.el-card__header) {
  padding: 20px 24px;
  border-bottom: 1px solid #f0f0f0;
}

.actions-card :deep(.el-card__body) {
  padding: 24px;
}

.action-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.action-btn {
  width: 100%;
  height: 48px;
  font-size: 15px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.action-btn.primary-action {
  background: linear-gradient(135deg, #52c41a 0%, #73d13d 100%);
  border: none;
  color: white;
}

.action-btn.primary-action:hover {
  background: linear-gradient(135deg, #73d13d 0%, #95de64 100%);
}

.action-btn.danger-action {
  background: linear-gradient(135deg, #ff4d4f 0%, #ff7875 100%);
  border: none;
  color: white;
}

.action-btn.danger-action:hover {
  background: linear-gradient(135deg, #ff7875 0%, #ffa39e 100%);
}

.help-card {
  border-radius: 16px;
  background: linear-gradient(135deg, #fafbfc 0%, #f5f7fa 100%);
  border: 1px dashed #d9d9d9;
}

.help-card :deep(.el-card__body) {
  padding: 20px;
}

.help-content {
  display: flex;
  align-items: center;
  gap: 12px;
}

.help-icon {
  font-size: 32px;
  color: #909399;
  flex-shrink: 0;
}

.help-text {
  flex: 1;
}

.help-title {
  font-size: 14px;
  font-weight: 600;
  color: #606266;
  margin: 0 0 4px 0;
}

.help-desc {
  font-size: 12px;
  color: #909399;
  margin: 0;
}

.price,
.amount {
  color: #606266;
}

.quantity {
  font-weight: 600;
  color: #303133;
}

.total-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 0 0 0;
  border-top: 1px solid #f0f0f0;
  margin-top: 20px;
}

.total-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.total-label {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
}

.total-items {
  font-size: 13px;
  color: #909399;
}

.total-amount {
  display: flex;
  align-items: baseline;
  gap: 4px;
}

.currency {
  font-size: 16px;
  font-weight: 600;
  color: #1890ff;
}

.amount-value {
  font-size: 28px;
  font-weight: 700;
  color: #1890ff;
}

.reject-reason-group {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.reason-option {
  margin-right: 0;
  padding: 12px 16px;
  border-radius: 8px;
  border: 1px solid #ebeef5;
}

.mt-4 {
  margin-top: 16px;
}

@media (max-width: 1200px) {
  .main-content {
    grid-template-columns: 1fr;
  }

  .right-panel {
    position: static;
  }
}

@media (max-width: 768px) {
  .order-detail-container {
    padding: 16px;
  }

  .detail-header {
    flex-direction: column;
    gap: 16px;
  }

  .info-grid {
    grid-template-columns: 1fr;
  }

  .additional-cards {
    grid-template-columns: 1fr;
  }
}
</style>
