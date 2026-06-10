<template>
  <div class="action-container">
    <el-page-header @back="goBack" class="mb-4">
      <template #content>
        <div class="page-header-content">
          <span class="page-title">订单操作</span>
          <el-breadcrumb separator="/">
            <el-breadcrumb-item :to="{ path: '/warehouse/orders' }">订单管理</el-breadcrumb-item>
            <el-breadcrumb-item>订单操作</el-breadcrumb-item>
          </el-breadcrumb>
        </div>
      </template>
    </el-page-header>

    <el-card v-if="orderData.id" shadow="never" class="action-card">
      <template #header>
        <div class="card-header">
          <div class="header-info">
            <el-icon class="header-icon"><component :is="getActionTypeIcon()" /></el-icon>
            <div>
              <h3 class="header-title">{{ getActionTitle() }}</h3>
              <p class="header-desc">{{ orderData.orderNo }}</p>
            </div>
          </div>
          <el-tag :type="getStatusType(orderData.status)" size="large">{{ orderData.statusText }}</el-tag>
        </div>
      </template>

      <el-descriptions :column="2" border class="order-summary">
        <el-descriptions-item label="订单号">{{ orderData.orderNo }}</el-descriptions-item>
        <el-descriptions-item label="下单时间">{{ orderData.createTime }}</el-descriptions-item>
        <el-descriptions-item label="水站名称">{{ orderData.stationName }}</el-descriptions-item>
        <el-descriptions-item label="配送地址">{{ orderData.deliveryAddress }}</el-descriptions-item>
        <el-descriptions-item label="总桶数">
          <span class="font-bold">{{ orderData.totalBuckets || 0 }} 桶</span>
        </el-descriptions-item>
        <el-descriptions-item label="订单金额">
          <span class="font-bold text-lg">¥ {{ orderData.totalAmount?.toLocaleString() || '0.00' }}</span>
        </el-descriptions-item>
      </el-descriptions>

      <el-divider />

      <div v-if="actionType === 'accept'" class="action-content">
        <el-alert type="success" :closable="false" show-icon>
          <template #title>
            <div class="alert-title">
              <el-icon><CircleCheckFilled /></el-icon>
              <span>确认接单</span>
            </div>
          </template>
          <template #default>
            <p>确认接收此订单后将进入备货流程</p>
          </template>
        </el-alert>

        <div class="action-buttons">
          <el-button size="large" @click="goBack">取消</el-button>
          <el-button type="success" size="large" :loading="submitting" @click="handleAccept">
            <el-icon><Check /></el-icon>
            确认接单
          </el-button>
        </div>
      </div>

      <div v-else-if="actionType === 'reject'" class="action-content">
        <el-form :model="rejectForm" label-width="100px">
          <el-form-item label="拒单原因" required>
            <el-input
              v-model="rejectForm.reason"
              type="textarea"
              :rows="4"
              placeholder="请输入拒单原因..."
              maxlength="200"
              show-word-limit
            />
          </el-form-item>
        </el-form>

        <div class="action-buttons">
          <el-button size="large" @click="goBack">取消</el-button>
          <el-button type="danger" size="large" :loading="submitting" @click="handleReject">
            <el-icon><Close /></el-icon>
            确认拒单
          </el-button>
        </div>
      </div>

      <div v-else-if="actionType === 'dispatch'" class="action-content">
        <h4 class="section-title">选择配送司机</h4>

        <div class="driver-list">
          <div
            v-for="driver in drivers"
            :key="driver.id"
            :class="['driver-item', { selected: selectedDriverId === driver.id }]"
            @click="handleDriverSelect(driver.id)"
          >
            <el-avatar :size="48" class="driver-avatar"><User /></el-avatar>
            <div class="driver-info">
              <p class="driver-name">{{ driver.name }}</p>
              <p class="driver-phone">{{ driver.phone }}</p>
            </div>
            <el-icon v-if="selectedDriverId === driver.id" class="check-icon"><Check /></el-icon>
          </div>
        </div>

        <div class="action-buttons">
          <el-button size="large" @click="goBack">取消</el-button>
          <el-button
            type="primary"
            size="large"
            :loading="submitting"
            :disabled="!selectedDriverId"
            @click="handleDispatch"
          >
            确认派单
          </el-button>
        </div>
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Check, Close, CircleCheckFilled, User, Van, Box } from '@element-plus/icons-vue'
import { warehouseApi } from '@/api'

const router = useRouter()
const route = useRoute()
const submitting = ref(false)
const actionType = ref('accept')
const selectedDriverId = ref('')

const orderData = ref<any>({
  id: '',
  orderNo: '',
  statusText: '',
  stationName: '',
  deliveryAddress: '',
  createTime: '',
  totalBuckets: 0,
  totalAmount: 0
})

const rejectForm = ref({
  reason: ''
})

const drivers = ref([
  { id: '1', name: '张三', phone: '13800138001' },
  { id: '2', name: '李四', phone: '13800138002' }
])

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
    completed: 'success'
  }
  return typeMap[status] || 'info'
}

const getActionTitle = () => {
  const titles: Record<string, string> = {
    accept: '确认接单',
    reject: '拒单',
    dispatch: '派单'
  }
  return titles[actionType.value] || '订单操作'
}

const getActionTypeIcon = () => {
  const icons: Record<string, any> = {
    accept: CircleCheckFilled,
    reject: Close,
    dispatch: Van
  }
  return icons[actionType.value] || Box
}

const handleAccept = async () => {
  submitting.value = true
  const orderId = orderData.value.orderId || orderData.value.id
  try {
    await warehouseApi.reviewOrder(orderId, { action: 'accept' })
    ElMessage.success('接单成功')
    goBack()
  } catch (error) {
    console.error('接单失败:', error)
    ElMessage.error('接单失败')
  } finally {
    submitting.value = false
  }
}

const handleReject = async () => {
  if (!rejectForm.value.reason) {
    ElMessage.warning('请输入拒单原因')
    return
  }

  submitting.value = true
  const orderId = orderData.value.orderId || orderData.value.id
  try {
    await warehouseApi.reviewOrder(orderId, { action: 'reject', reason: rejectForm.value.reason })
    ElMessage.success('拒单成功')
    goBack()
  } catch (error) {
    console.error('拒单失败:', error)
    ElMessage.error('拒单失败')
  } finally {
    submitting.value = false
  }
}

const handleDriverSelect = (driverId: string) => {
  selectedDriverId.value = driverId
}

const handleDispatch = async () => {
  if (!selectedDriverId.value) {
    ElMessage.warning('请选择司机')
    return
  }

  submitting.value = true
  const orderId = orderData.value.orderId || orderData.value.id
  try {
    await warehouseApi.dispatchOrder(orderId, { driverId: selectedDriverId.value })
    ElMessage.success('派单成功')
    goBack()
  } catch (error) {
    console.error('派单失败:', error)
    ElMessage.error('派单失败')
  } finally {
    submitting.value = false
  }
}

const loadOrder = async () => {
  try {
    const orderId = route.params.id as string
    const res: any = await warehouseApi.getOrderById(orderId)
    orderData.value = res.data || res
  } catch (error) {
    console.error('获取订单失败:', error)
    ElMessage.error('获取订单失败')
  }
}

onMounted(() => {
  actionType.value = (route.query.action as string) || 'accept'
  loadOrder()
})
</script>

<style scoped>
.action-container {
  padding: 20px;
}

.mb-4 {
  margin-bottom: 16px;
}

.page-header-content {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.page-title {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
}

.action-card {
  max-width: 800px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.header-icon {
  font-size: 32px;
  color: #409eff;
  background: #ecf5ff;
  padding: 12px;
  border-radius: 12px;
}

.header-title {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
  margin: 0 0 4px 0;
}

.header-desc {
  font-size: 12px;
  color: #909399;
  margin: 0;
}

.order-summary {
  margin-top: 16px;
}

.action-content {
  margin-top: 24px;
}

.alert-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
}

.action-buttons {
  display: flex;
  justify-content: flex-end;
  gap: 16px;
  margin-top: 24px;
}

.section-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  margin: 0 0 16px 0;
}

.driver-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.driver-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px;
  border: 1px solid #ebeef5;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s;
}

.driver-item:hover {
  border-color: #409eff;
  background: #ecf5ff;
}

.driver-item.selected {
  border-color: #409eff;
  background: #ecf5ff;
}

.driver-avatar {
  background: #409eff;
}

.driver-info {
  flex: 1;
}

.driver-name {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  margin: 0 0 4px 0;
}

.driver-phone {
  font-size: 14px;
  color: #909399;
  margin: 0;
}

.check-icon {
  color: #409eff;
  font-size: 20px;
}
</style>
