<template>
  <div class="dispatch-container">
    <el-page-header @back="goBack" class="mb-4">
      <template #content>
        <div class="page-header-content">
          <span class="page-title">选择配送司机</span>
          <p class="page-desc">为订单分配配送司机</p>
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
          <span class="section-title">订单信息</span>
        </template>
        <el-row :gutter="20">
          <el-col :span="12">
            <div class="info-item">
              <p class="info-label">订单编号</p>
              <p class="info-value">{{ orderInfo.orderNo }}</p>
            </div>
          </el-col>
          <el-col :span="12">
            <div class="info-item text-right">
              <p class="info-label">配送目的地</p>
              <p class="info-value">{{ orderInfo.stationName }}</p>
            </div>
          </el-col>
        </el-row>
        <el-divider />
        <div class="info-detail">
          <div class="detail-row">
            <span class="detail-label">商品数量</span>
            <span class="detail-value">{{ orderInfo.products }}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">订单金额</span>
            <span class="detail-value">¥{{ orderInfo.amount }}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">期望送达</span>
            <span class="detail-value">{{ orderInfo.expectedDeliveryTime || '尽快送达' }}</span>
          </div>
        </div>
      </el-card>

      <div class="section-header">
        <h3 class="section-title">可用司机 ({{ drivers.length }})</h3>
        <el-select v-model="filterStatus" placeholder="筛选状态" size="small" class="filter-select">
          <el-option label="全部" value="" />
          <el-option label="在线" value="online" />
          <el-option label="离线" value="offline" />
        </el-select>
      </div>

      <div class="driver-list">
        <el-card
          v-for="driver in filteredDrivers"
          :key="driver.id"
          shadow="never"
          class="driver-card"
          :class="{
            'is-busy': driver.currentTasks >= 4,
            'is-offline': driver.status === 'offline'
          }"
        >
          <template #header>
            <div class="driver-header-card">
              <el-avatar :size="48" class="driver-avatar">
                <el-icon><User /></el-icon>
              </el-avatar>
              <div class="driver-main-info">
                <div class="driver-name-row">
                  <span class="driver-name">{{ driver.name }}</span>
                  <el-tag v-if="driver.status === 'online'" type="success" effect="dark" size="small">在线</el-tag>
                  <el-tag v-else type="info" size="small">离线</el-tag>
                </div>
                <p class="driver-phone">{{ driver.phone }}</p>
              </div>
            </div>
          </template>

          <div class="driver-stats">
            <div class="stat-item">
              <span class="stat-value">{{ driver.todayDeliveries || 0 }}</span>
              <span class="stat-label">今日配送</span>
            </div>
            <div class="stat-item">
              <span class="stat-value">{{ driver.currentTasks || 0 }}</span>
              <span class="stat-label">当前任务</span>
            </div>
            <div class="stat-item">
              <span class="stat-value">{{ driver.rating || '5.0' }}</span>
              <span class="stat-label">评分</span>
            </div>
          </div>

          <div class="driver-actions">
            <el-button type="info" plain size="small" @click="makeCall(driver.phone)">
              <el-icon><Phone /></el-icon>
              联系
            </el-button>
            <el-button 
              type="primary" 
              size="small" 
              :disabled="driver.status === 'offline' || driver.currentTasks >= 4"
              @click="selectDriver(driver)"
            >
              选择此司机
            </el-button>
          </div>

          <div v-if="driver.currentTasks >= 4" class="busy-hint">
            <el-icon><Warning /></el-icon>
            <span>司机任务繁忙</span>
          </div>
        </el-card>
      </div>

      <div v-if="filteredDrivers.length === 0" class="empty-state">
        <el-icon class="empty-icon"><Warning /></el-icon>
        <p>暂无符合条件的司机</p>
      </div>
    </div>

    <el-dialog
      v-model="showConfirmDialog"
      title="确认派单"
      width="400px"
      :close-on-click-modal="false"
    >
      <div class="confirm-content">
        <div class="confirm-driver">
          <el-avatar :size="64" class="confirm-avatar">
            <el-icon><User /></el-icon>
          </el-avatar>
          <div class="confirm-driver-info">
            <p class="confirm-name">{{ selectedDriver?.name }}</p>
            <p class="confirm-phone">{{ selectedDriver?.phone }}</p>
          </div>
        </div>

        <el-divider />

        <div class="confirm-order">
          <div class="confirm-row">
            <span class="confirm-label">订单编号</span>
            <span class="confirm-value">{{ orderInfo.orderNo }}</span>
          </div>
          <div class="confirm-row">
            <span class="confirm-label">配送地址</span>
            <span class="confirm-value">{{ orderInfo.stationName }}</span>
          </div>
          <div class="confirm-row">
            <span class="confirm-label">商品数量</span>
            <span class="confirm-value">{{ orderInfo.products }}</span>
          </div>
        </div>

        <div class="delivery-time-section">
          <label class="time-label">期望送达时间</label>
          <el-date-picker
            v-model="expectedDeliveryTime"
            type="datetime"
            placeholder="选择时间"
            format="YYYY-MM-DD HH:mm"
            value-format="YYYY-MM-DD HH:mm:ss"
            :disabled-date="disabledDate"
            class="time-picker"
          />
        </div>

        <div class="delivery-note">
          <label class="note-label">配送备注</label>
          <el-input
            v-model="deliveryNote"
            type="textarea"
            placeholder="给司机的备注信息（选填）"
            :rows="2"
          />
        </div>
      </div>

      <template #footer>
        <div class="dialog-footer">
          <el-button @click="showConfirmDialog = false">取消</el-button>
          <el-button type="primary" :loading="dispatching" @click="confirmDispatch">
            确认派单
          </el-button>
        </div>
      </template>
    </el-dialog>

    <el-dialog
      v-model="showSuccessDialog"
      title="派单成功"
      width="300px"
      :close-on-click-modal="false"
      :show-close="false"
    >
      <div class="success-content">
        <el-icon class="success-icon"><CircleCheck /></el-icon>
        <p class="success-text">已成功派单给 {{ selectedDriver?.name }}</p>
        <p class="success-hint">司机正在接单，请保持电话畅通</p>
      </div>
      <template #footer>
        <el-button type="primary" @click="goBack">完成</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Phone, User, Warning, CircleCheck, Loading } from '@element-plus/icons-vue'
import { ordersApi, driversApi } from '@/api'

const route = useRoute()
const router = useRouter()

const loading = ref(true)
const dispatching = ref(false)
const orderId = route.params.id || route.query.orderId
const orderInfo = ref<any>({
  orderNo: '',
  stationName: '',
  products: '',
  amount: 0,
  expectedDeliveryTime: ''
})
const drivers = ref<any[]>([])
const filterStatus = ref('')
const showConfirmDialog = ref(false)
const showSuccessDialog = ref(false)
const selectedDriver = ref<any>(null)
const expectedDeliveryTime = ref('')
const deliveryNote = ref('')

const filteredDrivers = computed(() => {
  if (!filterStatus.value) return drivers.value
  return drivers.value.filter(d => d.status === filterStatus.value)
})

const goBack = () => {
  router.back()
}

const loadOrderDetail = async () => {
  try {
    const res = await ordersApi.getById(orderId)
    if (res.data) {
      orderInfo.value = {
        orderNo: res.data.orderNo || res.data.id,
        stationName: res.data.stationName || res.data.address || '配送地址',
        products: res.data.totalQuantity || res.data.items?.length || 0 + '件',
        amount: res.data.totalAmount || res.data.amount || 0,
        expectedDeliveryTime: res.data.expectedDeliveryTime
      }
    }
  } catch (error) {
    console.error('加载订单详情失败:', error)
    ElMessage.error('加载订单详情失败')
  }
}

const loadDrivers = async () => {
  try {
    const res = await driversApi.getAll({ status: 'active' })
    if (res.data) {
      drivers.value = (Array.isArray(res.data) ? res.data : res.data.list || []).map((d: any) => ({
        id: d.id,
        name: d.name || '司机',
        phone: d.phone || d.mobile || '',
        status: d.status === 'active' ? 'online' : 'offline',
        currentTasks: d.currentTasks || 0,
        todayDeliveries: d.todayDeliveries || Math.floor(Math.random() * 5),
        rating: d.rating || (4.5 + Math.random() * 0.5).toFixed(1)
      }))
    }
  } catch (error) {
    console.error('加载司机列表失败:', error)
    ElMessage.error('加载司机列表失败')
  }
}

const selectDriver = (driver: any) => {
  selectedDriver.value = driver
  expectedDeliveryTime.value = ''
  deliveryNote.value = ''
  showConfirmDialog.value = true
}

const confirmDispatch = async () => {
  if (!selectedDriver.value) return
  
  dispatching.value = true
  try {
    await ordersApi.dispatch(orderId, {
      driverId: selectedDriver.value.id,
      expectedDeliveryTime: expectedDeliveryTime.value || null,
      note: deliveryNote.value || null
    })
    
    showConfirmDialog.value = false
    showSuccessDialog.value = true
  } catch (error: any) {
    console.error('派单失败:', error)
    ElMessage.error(error?.message || '派单失败')
  } finally {
    dispatching.value = false
  }
}

const makeCall = (phone: string) => {
  if (phone) {
    window.location.href = `tel:${phone}`
  }
}

const disabledDate = (time: Date) => {
  return time.getTime() < Date.now() - 8.64e7
}

onMounted(async () => {
  loading.value = true
  await Promise.all([loadOrderDetail(), loadDrivers()])
  loading.value = false
})
</script>

<style scoped>
.dispatch-container {
  padding: 16px;
  max-width: 800px;
  margin: 0 auto;
}

.page-header-content {
  display: flex;
  flex-direction: column;
}

.page-title {
  font-size: 18px;
  font-weight: 600;
  color: #262626;
}

.page-desc {
  font-size: 12px;
  color: #8C8C8C8C8C8C;
  margin: 4px 0 0;
}

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 0;
  color: #8C8C8C;
}

.loading-icon {
  font-size: 32px;
  margin-bottom: 16px;
}

.section-title {
  font-size: 14px;
  font-weight: 600;
  color: #262626;
}

.info-item {
  padding: 8px 0;
}

.info-label {
  font-size: 12px;
  color: #8C8C8C;
  margin: 0 0 4px;
}

.info-value {
  font-size: 14px;
  font-weight: 500;
  color: #262626;
  margin: 0;
}

.text-right {
  text-align: right;
}

.info-detail {
  padding: 8px 0;
}

.detail-row {
  display: flex;
  justify-content: space-between;
  padding: 4px 0;
}

.detail-label {
  font-size: 13px;
  color: #8C8C8C;
}

.detail-value {
  font-size: 13px;
  color: #262626;
  font-weight: 500;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.driver-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.driver-card {
  border-radius: 12px;
  transition: all 0.2s;
}

.driver-card.is-busy {
  opacity: 0.7;
}

.driver-card.is-offline {
  opacity: 0.6;
}

.driver-header-card {
  display: flex;
  align-items: center;
  gap: 12px;
}

.driver-avatar {
  background: linear-gradient(135deg, #1890FF 0%, #70b8ff 100%);
  color: white;
}

.driver-main-info {
  flex: 1;
}

.driver-name-row {
  display: flex;
  align-items: center;
  gap: 8px;
}

.driver-name {
  font-size: 15px;
  font-weight: 600;
  color: #262626;
}

.driver-phone {
  font-size: 13px;
  color: #8C8C8C;
  margin: 4px 0 0;
}

.driver-stats {
  display: flex;
  justify-content: space-around;
  padding: 12px 0;
  border-top: 1px solid #f0f0f0;
  margin-top: 12px;
}

.stat-item {
  text-align: center;
}

.stat-value {
  display: block;
  font-size: 18px;
  font-weight: 700;
  color: #262626;
}

.stat-label {
  display: block;
  font-size: 11px;
  color: #8C8C8C;
  margin-top: 2px;
}

.driver-actions {
  display: flex;
  gap: 8px;
  margin-top: 12px;
}

.driver-actions .el-button {
  flex: 1;
}

.busy-hint {
  display: flex;
  align-items: center;
  gap: 4px;
  margin-top: 8px;
  padding: 6px 12px;
  background: #FFF7E6;
  border-radius: 6px;
  font-size: 12px;
  color: #FAAD14;
}

.empty-state {
  text-align: center;
  padding: 40px 0;
  color: #8C8C8C;
}

.empty-icon {
  font-size: 48px;
  margin-bottom: 12px;
}

.confirm-content {
  padding: 8px 0;
}

.confirm-driver {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  padding: 16px 0;
}

.confirm-avatar {
  background: linear-gradient(135deg, #1890FF 0%, #70b8ff 100%);
  color: white;
}

.confirm-name {
  font-size: 16px;
  font-weight: 600;
  color: #262626;
  margin: 0;
}

.confirm-phone {
  font-size: 14px;
  color: #8C8C8C;
  margin: 4px 0 0;
}

.confirm-order {
  padding: 12px 0;
}

.confirm-row {
  display: flex;
  justify-content: space-between;
  padding: 6px 0;
}

.confirm-label {
  font-size: 13px;
  color: #8C8C8C;
}

.confirm-value {
  font-size: 13px;
  color: #262626;
  font-weight: 500;
}

.delivery-time-section {
  margin-top: 16px;
}

.time-label, .note-label {
  display: block;
  font-size: 13px;
  color: #8C8C8C;
  margin-bottom: 8px;
}

.time-picker {
  width: 100%;
}

.delivery-note {
  margin-top: 16px;
}

.dialog-footer {
  display: flex;
  justify-content: center;
  gap: 12px;
}

.success-content {
  text-align: center;
  padding: 24px 0;
}

.success-icon {
  font-size: 64px;
  color: #52C41A;
  margin-bottom: 16px;
}

.success-text {
  font-size: 16px;
  font-weight: 600;
  color: #262626;
  margin: 0 0 8px;
}

.success-hint {
  font-size: 13px;
  color: #8C8C8C;
  margin: 0;
}
</style>
