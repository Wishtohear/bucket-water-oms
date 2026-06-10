<template>
  <div class="warehouse-dashboard">
    <div class="warehouse-info-card" v-if="warehouseName">
      <div class="warehouse-info">
        <el-icon class="warehouse-icon"><OfficeBuilding /></el-icon>
        <div class="warehouse-details">
          <span class="warehouse-name">{{ warehouseName }}</span>
          <span class="warehouse-label">当前仓库</span>
        </div>
      </div>
    </div>

    <el-row :gutter="20" class="mb-4">
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-header">
            <el-icon class="stat-icon blue"><Histogram /></el-icon>
            <el-tag size="small" type="info">今日</el-tag>
          </div>
          <div class="stat-content">
            <p class="stat-label">今日订单数</p>
            <h3 class="stat-value">{{ stats.todayInbound }} <span class="stat-unit">单</span></h3>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-header">
            <el-icon class="stat-icon green"><CircleCheck /></el-icon>
            <el-tag size="small" type="success">已完成</el-tag>
          </div>
          <div class="stat-content">
            <p class="stat-label">今日完成数</p>
            <h3 class="stat-value">{{ stats.todayCompleted }} <span class="stat-unit">单</span></h3>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-header">
            <el-icon class="stat-icon orange"><Clock /></el-icon>
            <el-tag size="small" type="danger">待处理</el-tag>
          </div>
          <div class="stat-content">
            <p class="stat-label">待接单数</p>
            <h3 class="stat-value">{{ pendingOrders }} <span class="stat-unit">单</span></h3>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-header">
            <el-icon class="stat-icon purple"><Van /></el-icon>
            <el-tag size="small" type="info">待核对</el-tag>
          </div>
          <div class="stat-content">
            <p class="stat-label">待核对回仓</p>
            <h3 class="stat-value">{{ pendingReturns }} <span class="stat-unit">单</span></h3>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20">
      <el-col :span="16">
        <el-card shadow="hover" class="mb-4">
          <template #header>
            <div class="card-header">
              <div>
                <h4 class="card-title">库存预警</h4>
                <p class="card-desc">低于安全库存的商品</p>
              </div>
              <el-link type="primary" :underline="false" @click="$router.push('/warehouse/inventory')">
                查看全部
              </el-link>
            </div>
          </template>
          <div v-if="inventoryWarnings.length > 0">
            <div v-for="item in inventoryWarnings" :key="item.productId" class="warning-item">
              <div class="warning-info">
                <el-icon class="warning-icon"><Shop /></el-icon>
                <div>
                  <p class="warning-name">{{ item.productName }}</p>
                  <p class="warning-safe">安全库存: {{ item.safeStock }}</p>
                </div>
              </div>
              <div class="warning-stock">
                <p class="stock-value danger">{{ item.currentStock }}</p>
                <el-tag size="small" type="danger">库存不足</el-tag>
              </div>
            </div>
          </div>
          <el-empty v-else description="暂无库存预警" :image-size="80" />
        </el-card>
      </el-col>

      <el-col :span="8">
        <el-card shadow="hover" class="mb-4">
          <template #header>
            <h4 class="card-title">快捷操作</h4>
          </template>
          <el-row :gutter="12">
            <el-col :span="12">
              <div class="quick-action" @click="$router.push('/warehouse/orders')">
                <el-icon class="quick-icon orange"><List /></el-icon>
                <span>订单管理</span>
              </div>
            </el-col>
            <el-col :span="12">
              <div class="quick-action" @click="$router.push('/warehouse/return-check')">
                <el-icon class="quick-icon purple"><Van /></el-icon>
                <span>回仓核对</span>
              </div>
            </el-col>
            <el-col :span="12" class="mt-3">
              <div class="quick-action" @click="$router.push('/warehouse/inbound')">
                <el-icon class="quick-icon blue"><Bottom /></el-icon>
                <span>入库登记</span>
              </div>
            </el-col>
            <el-col :span="12" class="mt-3">
              <div class="quick-action" @click="$router.push('/warehouse/inventory')">
                <el-icon class="quick-icon green"><Box /></el-icon>
                <span>库存盘点</span>
              </div>
            </el-col>
          </el-row>
        </el-card>

        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <h4 class="card-title">待处理事项</h4>
            </div>
          </template>
          <div class="todo-item">
            <el-badge is-dot class="item-dot danger">
              <span class="todo-text">待接单</span>
            </el-badge>
            <span class="todo-count">{{ pendingOrders }} 个订单等待处理</span>
            <el-link type="primary" :underline="false" @click="$router.push('/warehouse/orders')">
              处理
            </el-link>
          </div>
          <el-divider />
          <div class="todo-item">
            <el-badge is-dot class="item-dot warning">
              <span class="todo-text">待核对</span>
            </el-badge>
            <span class="todo-count">{{ pendingReturns }} 个回仓申请</span>
            <el-link type="primary" :underline="false" @click="$router.push('/warehouse/return-check')">
              处理
            </el-link>
          </div>
          <el-divider />
          <div class="todo-item">
            <el-badge is-dot class="item-dot purple">
              <span class="todo-text">待处理售后</span>
            </el-badge>
            <span class="todo-count">{{ stats.pendingAfterSales }} 个售后申请</span>
            <el-link type="primary" :underline="false" @click="$router.push('/warehouse/after-sales')">
              处理
            </el-link>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-card shadow="hover" class="mt-4">
      <template #header>
        <div class="card-header">
          <div>
            <h4 class="card-title">最近任务</h4>
            <p class="card-desc">最近的入库出库和回仓记录</p>
          </div>
        </div>
      </template>
      <el-table :data="recentTasks" stripe style="width: 100%" v-loading="loading">
        <el-table-column label="任务类型" width="150">
          <template #default="{ row }">
            <div class="task-type">
              <el-icon :class="getTaskTypeClass(row.type)"><component :is="getTaskTypeIcon(row.type)" /></el-icon>
              <span>{{ row.typeText }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="taskNo" label="单号" width="180">
          <template #default="{ row }">
            <span class="mono">{{ row.taskNo }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="customerName" label="关联水站" min-width="150">
          <template #default="{ row }">
            {{ row.customerName || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="quantity" label="数量" width="100" align="center">
          <template #default="{ row }">
            {{ row.quantity }} 桶
          </template>
        </el-table-column>
        <el-table-column label="状态" width="120" align="center">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)" size="small">
              {{ row.statusText }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="时间" width="180" />
        <template #empty>
          <el-empty description="暂无任务记录" :image-size="80" />
        </template>
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { warehouseApi } from '@/api'
import { toast } from '@/composables/useToast'
import {
  Histogram,
  CircleCheck,
  Clock,
  Van,
  Shop,
  List,
  Bottom,
  Box,
  Download,
  Upload,
  RefreshRight,
  OfficeBuilding
} from '@element-plus/icons-vue'

interface Stats {
  todayInbound: number
  todayOutbound: number
  todayCompleted: number
  totalInventory: number
  lowStockWarnings: number
  pendingAfterSales: number
  [key: string]: any
}

interface InventoryWarning {
  productId: string
  productName: string
  currentStock: number
  safeStock: number
  warehouseName: string
}

interface Task {
  taskId: string
  taskNo: string
  type: string
  typeText: string
  status: string
  statusText: string
  customerName: string
  quantity: number
  createdAt: string
}

const loading = ref(false)
const warehouseName = ref('')
const stats = ref<Stats>({
  todayInbound: 0,
  todayOutbound: 0,
  todayCompleted: 0,
  totalInventory: 0,
  lowStockWarnings: 0,
  pendingAfterSales: 0
})

const inventoryWarnings = ref<InventoryWarning[]>([])
const recentTasks = ref<Task[]>([])
const pendingOrders = ref(0)
const pendingReturns = ref(0)

const getTaskTypeIcon = (type: string) => {
  const icons: Record<string, any> = {
    inbound: Download,
    outbound: Upload,
    return: RefreshRight,
    order: List
  }
  return icons[type] || List
}

const getTaskTypeClass = (type: string) => {
  const classes: Record<string, string> = {
    inbound: 'blue',
    outbound: 'green',
    return: 'purple',
    order: 'orange'
  }
  return classes[type] || 'gray'
}

const getStatusType = (status: string) => {
  const types: Record<string, string> = {
    pending_review: 'warning',
    reviewed: 'primary',
    dispatched: 'info',
    delivering: 'primary',
    completed: 'success',
    cancelled: 'info',
    rejected: 'danger'
  }
  return types[status] || 'info'
}

const fetchDashboardData = async () => {
  loading.value = true
  try {
    const dashboard = await warehouseApi.getDashboard()
    warehouseName.value = dashboard.warehouseName || ''
    stats.value = {
      todayInbound: dashboard.todayInbound || 0,
      todayOutbound: dashboard.todayOutbound || 0,
      todayCompleted: dashboard.todayOutbound || 0,
      totalInventory: dashboard.totalInventory || 0,
      lowStockWarnings: dashboard.lowStockWarnings || 0,
      pendingAfterSales: 0
    }
    inventoryWarnings.value = dashboard.inventoryWarnings || []
    recentTasks.value = dashboard.recentTasks || []

    const pendingOrdersRes = await warehouseApi.getPendingOrders()
    pendingOrders.value = pendingOrdersRes.length || 0

    const pendingReturnsRes = await warehouseApi.getPendingReturns()
    pendingReturns.value = pendingReturnsRes.length || 0
  } catch (error: any) {
    console.error('获取Dashboard数据失败:', error)
    toast.error('获取数据失败: ' + (error.message || '未知错误'))
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchDashboardData()
})
</script>

<style scoped>
.warehouse-dashboard {
  padding: 0;
}

.warehouse-info-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
  padding: 16px 20px;
  margin-bottom: 20px;
  color: #fff;
}

.warehouse-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.warehouse-icon {
  font-size: 32px;
  background: rgba(255, 255, 255, 0.2);
  padding: 8px;
  border-radius: 8px;
}

.warehouse-details {
  display: flex;
  flex-direction: column;
}

.warehouse-name {
  font-size: 20px;
  font-weight: bold;
}

.warehouse-label {
  font-size: 12px;
  opacity: 0.8;
}

.mb-4 {
  margin-bottom: 20px;
}

.mt-4 {
  margin-top: 20px;
}

.mt-3 {
  margin-top: 12px;
}

.stat-card {
  margin-bottom: 20px;
}

.stat-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.stat-icon {
  font-size: 24px;
  padding: 8px;
  border-radius: 8px;
}

.stat-icon.blue {
  color: #409eff;
  background: #ecf5ff;
}

.stat-icon.green {
  color: #67c23a;
  background: #f0f9eb;
}

.stat-icon.orange {
  color: #e6a23c;
  background: #fdf6ec;
}

.stat-icon.purple {
  color: #a855f7;
  background: #faf5ff;
}

.stat-content {
  margin-top: 8px;
}

.stat-label {
  color: #909399;
  font-size: 14px;
  margin-bottom: 4px;
}

.stat-value {
  font-size: 28px;
  font-weight: bold;
  color: #303133;
  margin: 0;
}

.stat-unit {
  font-size: 14px;
  font-weight: normal;
  color: #909399;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-title {
  margin: 0;
  font-size: 16px;
  font-weight: bold;
  color: #303133;
}

.card-desc {
  margin: 4px 0 0;
  font-size: 12px;
  color: #909399;
}

.warning-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px;
  margin-bottom: 12px;
  background: #fef0f0;
  border-radius: 8px;
  border: 1px solid #fde2e2;
}

.warning-item:last-child {
  margin-bottom: 0;
}

.warning-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.warning-icon {
  font-size: 20px;
  color: #409eff;
  background: #fff;
  padding: 8px;
  border-radius: 8px;
}

.warning-name {
  font-size: 14px;
  font-weight: 500;
  color: #303133;
  margin: 0;
}

.warning-safe {
  font-size: 12px;
  color: #909399;
  margin: 4px 0 0;
}

.warning-stock {
  text-align: right;
}

.stock-value {
  font-size: 20px;
  font-weight: bold;
  margin: 0 0 4px;
}

.stock-value.danger {
  color: #f56c6c;
}

.quick-action {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 16px;
  background: #f5f7fa;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s;
}

.quick-action:hover {
  background: #ecf5ff;
}

.quick-icon {
  font-size: 24px;
  margin-bottom: 8px;
}

.quick-icon.orange {
  color: #e6a23c;
}

.quick-icon.purple {
  color: #a855f7;
}

.quick-icon.blue {
  color: #409eff;
}

.quick-icon.green {
  color: #67c23a;
}

.quick-action span {
  font-size: 12px;
  font-weight: 500;
  color: #606266;
}

.todo-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 8px 0;
}

.item-dot {
  padding: 4px;
}

.item-dot.danger :deep(.el-badge__content) {
  background-color: #f56c6c;
}

.item-dot.warning :deep(.el-badge__content) {
  background-color: #e6a23c;
}

.item-dot.purple :deep(.el-badge__content) {
  background-color: #a855f7;
}

.todo-text {
  font-size: 14px;
  font-weight: 500;
  color: #303133;
}

.todo-count {
  flex: 1;
  font-size: 12px;
  color: #909399;
}

.task-type {
  display: flex;
  align-items: center;
  gap: 8px;
}

.task-type .el-icon {
  font-size: 18px;
}

.task-type .blue {
  color: #409eff;
}

.task-type .green {
  color: #67c23a;
}

.task-type .orange {
  color: #e6a23c;
}

.task-type .purple {
  color: #a855f7;
}

.task-type .gray {
  color: #909399;
}

.mono {
  font-family: 'Monaco', 'Menlo', monospace;
}
</style>
