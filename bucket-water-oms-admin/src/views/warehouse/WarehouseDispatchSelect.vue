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
            <span class="detail-label">配送距离</span>
            <span class="detail-value">{{ orderInfo.distance }}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">预计配送时长</span>
            <span class="detail-value">{{ orderInfo.estimatedDuration }}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">商品数量</span>
            <span class="detail-value">{{ orderInfo.products }}</span>
          </div>
        </div>
      </el-card>

      <div class="section-header">
        <h3 class="section-title">可用司机 ({{ drivers.length }})</h3>
      </div>

      <div class="driver-list">
        <el-card
          v-for="driver in drivers"
          :key="driver.id"
          shadow="never"
          class="driver-card"
          :class="{
            'is-recommended': driver.isRecommended,
            'is-busy': driver.currentTasks >= 4,
            'is-cross-warehouse': !driver.boundToCurrentWarehouse
          }"
        >
          <template #header>
            <div class="driver-badges">
              <el-tag v-if="driver.boundToCurrentWarehouse" type="success" effect="dark" size="small">本仓库</el-tag>
              <el-tag v-else type="warning" effect="dark" size="small">跨仓库</el-tag>
              <el-tag v-if="driver.isRecommended && driver.boundToCurrentWarehouse" type="primary" effect="dark" size="small">推荐</el-tag>
            </div>
            <div v-if="!driver.boundToCurrentWarehouse && driver.warehouseName" class="cross-warehouse-hint">
              来自: {{ driver.warehouseName }}
            </div>
          </template>

          <div class="driver-main">
            <el-avatar :size="56" class="driver-avatar" :class="getAvatarBorderClass(driver)">
              <el-icon><User /></el-icon>
            </el-avatar>

            <div class="driver-info">
              <div class="driver-header">
                <div>
                  <p class="driver-name">{{ driver.name }}</p>
                  <p class="driver-code">工号: {{ driver.code }}</p>
                </div>
                <el-button
                  type="success"
                  circle
                  @click="makePhoneCall(driver.phone)"
                >
                  <el-icon><Phone /></el-icon>
                </el-button>
              </div>

              <div class="driver-rating">
                <el-icon class="star-icon"><Star /></el-icon>
                <span>{{ driver.rating }}分</span>
                <span class="divider">|</span>
                <span>{{ driver.totalOrders }}单</span>
              </div>
            </div>
          </div>

          <el-row :gutter="12" class="driver-stats">
            <el-col :span="8">
              <div class="stat-card" :class="getLocationBgClass(driver)">
                <p class="stat-label">当前位置</p>
                <p class="stat-value" :class="getLocationTextClass(driver)">
                  {{ driver.currentLocation }}
                </p>
              </div>
            </el-col>
            <el-col :span="8">
              <div class="stat-card bg-blue">
                <p class="stat-label">当前任务</p>
                <p class="stat-value" :class="driver.currentTasks > 0 ? 'text-orange' : 'text-blue'">
                  {{ driver.currentTasks }} 单
                </p>
              </div>
            </el-col>
            <el-col :span="8">
              <div class="stat-card bg-purple">
                <p class="stat-label">今日已完成</p>
                <p class="stat-value">{{ driver.todayCompleted }} 单</p>
              </div>
            </el-col>
          </el-row>

          <div class="driver-action">
            <el-button
              v-if="driver.currentTasks < 4"
              :type="driver.isRecommended ? 'primary' : 'default'"
              size="large"
              @click="handleDispatch(driver)"
              class="dispatch-btn"
            >
              {{ driver.isRecommended ? '确认派单' : '选择此司机' }}
            </el-button>
            <el-tag v-else type="info">当前任务已满 (4单)，暂不可派单</el-tag>
          </div>
        </el-card>

        <el-empty v-if="drivers.length === 0" description="暂无可用司机" />
      </div>
    </div>

    <el-dialog v-model="showConfirmDialog" title="确认派单" width="450px" align-center>
      <div class="confirm-content">
        <div class="confirm-driver">
          <el-avatar :size="48" class="confirm-avatar"><User /></el-avatar>
          <div class="confirm-info">
            <p class="confirm-name">{{ selectedDriver?.name }}</p>
            <p class="confirm-code">工号: {{ selectedDriver?.code }}</p>
          </div>
        </div>

        <el-alert
          v-if="selectedDriver && !selectedDriver.boundToCurrentWarehouse"
          type="warning"
          :closable="false"
          show-icon
          class="mb-4"
        >
          <template #title>
            <span>跨仓库派单警告</span>
          </template>
          <template #default>
            <div class="cross-warehouse-warning">
              <p>该司机来自仓库【{{ selectedDriver?.warehouseName }}】，跨仓库派单可能导致配送效率降低。</p>
              <p class="mt-2">建议优先选择<span style="color: #67c23a; font-weight: bold;">本仓库</span>的司机进行派单。</p>
            </div>
          </template>
        </el-alert>

        <p class="confirm-text">确认将此订单派给 {{ selectedDriver?.name }} 吗？</p>
      </div>
      <template #footer>
        <el-button @click="showConfirmDialog = false">取消</el-button>
        <el-button
          :type="selectedDriver && !selectedDriver.boundToCurrentWarehouse ? 'warning' : 'primary'"
          @click="confirmDispatch"
        >
          {{ selectedDriver && !selectedDriver.boundToCurrentWarehouse ? '确认跨仓库派单' : '确认派单' }}
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Loading, User, Phone, Star } from '@element-plus/icons-vue'
import { warehouseApi } from '@/api'

interface Driver {
  id: string
  name: string
  code: string
  phone: string
  rating: number
  totalOrders: number
  currentTasks: number
  todayCompleted: number
  currentLocation: string
  isRecommended: boolean
  onlineStatus: string
  boundToCurrentWarehouse: boolean
  warehouseName: string
}

interface OrderInfo {
  orderNo: string
  stationName: string
  distance: string
  estimatedDuration: string
  products: string
}

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const drivers = ref<Driver[]>([])
const selectedDriver = ref<Driver | null>(null)
const showConfirmDialog = ref(false)

const orderInfo = ref<OrderInfo>({
  orderNo: '',
  stationName: '',
  distance: '-',
  estimatedDuration: '-',
  products: '-'
})

const goBack = () => {
  router.push('/warehouse/prepare-list')
}

const getAvatarBorderClass = (driver: Driver) => {
  if (driver.currentTasks === 0) return 'border-green'
  if (driver.currentTasks <= 2) return 'border-blue'
  return 'border-orange'
}

const getLocationBgClass = (driver: Driver) => {
  if (driver.currentLocation === '仓库内') return 'bg-green'
  return 'bg-blue'
}

const getLocationTextClass = (driver: Driver) => {
  if (driver.currentLocation === '仓库内') return 'text-green'
  return 'text-default'
}

const makePhoneCall = (phone: string) => {
  if (phone) {
    window.location.href = `tel:${phone}`
  }
}

const fetchOrderInfo = async () => {
  try {
    const orderId = route.params.id as string
    const res: any = await warehouseApi.getOrderById(orderId)
    const orderData = res.data || res
    orderInfo.value = {
      orderNo: orderData.orderNo || '',
      stationName: orderData.stationName || '',
      distance: '-',
      estimatedDuration: '约 25分钟',
      products: orderData.items?.map((i: any) => `${i.productName}×${i.quantity}`).join(' + ') || '-'
    }
  } catch (error: any) {
    console.error('获取订单信息失败:', error)
    ElMessage.error('获取订单信息失败')
  }
}

const fetchDrivers = async () => {
  loading.value = true
  try {
    const orderId = route.params.id as string
    // 使用新的API获取所有可用司机（包括绑定和非绑定的）
    console.log('开始获取司机列表, orderId:', orderId)
    const res: any = await warehouseApi.getRecommendedDriversWithDetails(orderId)
    console.log('获取司机列表响应:', res)
    const driverData = res.data || res || []
    console.log('司机数据:', driverData, '长度:', Array.isArray(driverData) ? driverData.length : '非数组')
    drivers.value = (Array.isArray(driverData) ? driverData : []).map((d: any, _index: number) => ({
      id: d.driverId || d.id || '',
      name: d.name || '',
      code: d.code || '',
      phone: d.phone || '',
      rating: d.rating ? d.rating / 20 : (d.onlineStatus === 'online' ? 4.8 : 4.5),
      totalOrders: d.totalDeliveries || d.totalOrders || d.todayDeliveries ? d.todayDeliveries * 30 : 100,
      currentTasks: d.currentTaskCount || d.currentTasks || 0,
      todayCompleted: d.todayCompletedCount || d.todayCompleted || 0,
      currentLocation: d.currentLat && d.currentLng ? '配送中' : (d.onlineStatus === 'online' ? '仓库内' : '离线'),
      isRecommended: d.recommendReason === 'bound' || d.recommendReason === 'distance',
      onlineStatus: d.onlineStatus || 'offline',
      boundToCurrentWarehouse: d.boundToCurrentWarehouse === true,
      warehouseName: d.warehouseName || ''
    }))
    console.log('处理后司机列表:', drivers.value)
  } catch (error: any) {
    console.error('获取司机列表失败:', error)
    ElMessage.error('获取司机列表失败: ' + (error.message || ''))
  } finally {
    loading.value = false
  }
}

const handleDispatch = (driver: Driver) => {
  selectedDriver.value = driver
  showConfirmDialog.value = true
}

const confirmDispatch = async () => {
  if (!selectedDriver.value) return

  const orderId = route.params.id as string
  if (!orderId || orderId === 'undefined') {
    ElMessage.error('订单ID无效')
    return
  }

  try {
    const res: any = await warehouseApi.dispatchOrder(orderId, {
      driverId: selectedDriver.value.id
    })

    const responseData = res.data || res

    // 检查是否有警告信息
    if (responseData.warnings && responseData.warnings.length > 0) {
      // 显示警告信息
      responseData.warnings.forEach((warning: string) => {
        ElMessage.warning(warning)
      })
    }

    // 从派单响应中获取仓库ID，确保列表页使用正确的仓库ID
    const warehouseIdFromResponse = responseData.order?.warehouseId
    if (warehouseIdFromResponse) {
      localStorage.setItem('warehouseId', String(warehouseIdFromResponse))
      console.log('派单成功后更新仓库ID:', warehouseIdFromResponse)
    }

    ElMessage.success('派单成功！')
    showConfirmDialog.value = false
    
    // 派单成功后跳转到列表页，并显示"已派单" Tab，添加时间戳参数强制刷新
    const timestamp = Date.now()
    router.push(`/warehouse/prepare-list?tab=dispatched&t=${timestamp}`)
  } catch (error: any) {
    console.error('派单失败:', error)
    ElMessage.error('派单失败: ' + (error.message || ''))
  }
}

onMounted(() => {
  fetchOrderInfo()
  fetchDrivers()
})
</script>

<style scoped>
.dispatch-container {
  padding: 20px;
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

.section-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  margin: 0;
}

.section-header {
  margin-bottom: 16px;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.text-right {
  text-align: right;
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

.info-detail {
  display: flex;
  flex-direction: column;
  gap: 8px;
  background: #f5f7fa;
  padding: 12px 16px;
  border-radius: 8px;
}

.detail-row {
  display: flex;
  justify-content: space-between;
}

.detail-label {
  font-size: 14px;
  color: #909399;
}

.detail-value {
  font-size: 14px;
  color: #606266;
  font-weight: 500;
}

.driver-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.driver-card {
  position: relative;
}

.driver-card.is-recommended {
  border: 2px solid #409eff;
}

.driver-card.is-busy {
  opacity: 0.6;
}

.driver-card.is-cross-warehouse {
  border: 2px dashed #e6a23c;
  background: #fdf6ec;
}

.driver-badges {
  display: flex;
  gap: 8px;
  align-items: center;
}

.cross-warehouse-hint {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
}

.mb-4 {
  margin-bottom: 16px;
}

.cross-warehouse-warning {
  font-size: 13px;
  line-height: 1.6;
}

.cross-warehouse-warning p {
  margin: 0;
}

.mt-2 {
  margin-top: 8px;
}

.driver-main {
  display: flex;
  gap: 16px;
  margin-bottom: 16px;
}

.driver-avatar {
  flex-shrink: 0;
  background: #f5f7fa;
}

.driver-avatar.border-green :deep(.el-avatar) {
  border: 2px solid #67c23a;
}

.driver-avatar.border-blue :deep(.el-avatar) {
  border: 2px solid #409eff;
}

.driver-avatar.border-orange :deep(.el-avatar) {
  border: 2px solid #e6a23c;
}

.driver-info {
  flex: 1;
}

.driver-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.driver-name {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  margin: 0 0 4px 0;
}

.driver-code {
  font-size: 12px;
  color: #909399;
  margin: 0;
}

.driver-rating {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 8px;
  font-size: 14px;
  color: #606266;
}

.star-icon {
  color: #f5c23c;
}

.divider {
  color: #dcdfe6;
}

.driver-stats {
  margin-bottom: 16px;
}

.stat-card {
  padding: 12px;
  border-radius: 8px;
  text-align: center;
}

.stat-card.bg-green {
  background: #f0f9eb;
}

.stat-card.bg-blue {
  background: #ecf5ff;
}

.stat-card.bg-purple {
  background: #f5f0ff;
}

.stat-label {
  font-size: 12px;
  color: #909399;
  margin: 0 0 4px 0;
}

.stat-value {
  font-size: 14px;
  font-weight: 600;
  margin: 0;
}

.text-green {
  color: #67c23a;
}

.text-blue {
  color: #409eff;
}

.text-orange {
  color: #e6a23c;
}

.text-default {
  color: #606266;
}

.driver-action {
  display: flex;
  justify-content: center;
}

.dispatch-btn {
  width: 100%;
}

.confirm-content {
  text-align: center;
}

.confirm-driver {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px;
  background: #f5f7fa;
  border-radius: 12px;
  margin-bottom: 16px;
}

.confirm-avatar {
  background: #409eff;
}

.confirm-name {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  margin: 0 0 4px 0;
}

.confirm-code {
  font-size: 12px;
  color: #909399;
  margin: 0;
}

.confirm-text {
  font-size: 14px;
  color: #606266;
  margin: 0;
}
</style>
