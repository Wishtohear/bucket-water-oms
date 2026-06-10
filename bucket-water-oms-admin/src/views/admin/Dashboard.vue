<template>
  <div class="dashboard-page">
    <el-row :gutter="20" class="mb-4">
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon bg-blue-light">
              <el-icon :size="28" color="#409eff"><Money /></el-icon>
            </div>
            <div class="stat-info">
              <p class="stat-label">今日销售额</p>
              <p class="stat-value">¥ {{ dashboardStore.stats.todaySales.toLocaleString() }}</p>
              <el-tag :type="getGrowthType(dashboardStore.stats.salesGrowth)" size="small" effect="dark">
                {{ formatGrowth(dashboardStore.stats.salesGrowth) }}
              </el-tag>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon bg-purple-light">
              <el-icon :size="28" color="#722ed1"><ShoppingCart /></el-icon>
            </div>
            <div class="stat-info">
              <p class="stat-label">今日订单数</p>
              <p class="stat-value">{{ dashboardStore.stats.todayOrders }} 单</p>
              <el-tag :type="getGrowthType(dashboardStore.stats.ordersGrowth)" size="small" effect="dark">
                {{ formatGrowth(dashboardStore.stats.ordersGrowth) }}
              </el-tag>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon bg-orange-light">
              <el-icon :size="28" color="#fa8c16"><Shop /></el-icon>
            </div>
            <div class="stat-info">
              <p class="stat-label">活跃水站数</p>
              <p class="stat-value">{{ dashboardStore.stats.activeStations }} 家</p>
              <el-tag type="info" size="small" effect="dark">当前</el-tag>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon bg-red-light">
              <el-icon :size="28" color="#f5222d"><Warning /></el-icon>
            </div>
            <div class="stat-info">
              <p class="stat-label">库存预警</p>
              <p class="stat-value">{{ dashboardStore.stats.lowStockItems }} 品类</p>
              <el-tag type="danger" size="small" effect="dark">{{ dashboardStore.stats.alerts }} 警报</el-tag>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20">
      <el-col :xs="24" :lg="16">
        <el-card shadow="hover" class="chart-card">
          <template #header>
            <div class="card-header">
              <span class="card-title">销售趋势</span>
              <el-radio-group v-model="trendType" size="small">
                <el-radio-button label="week">按周</el-radio-button>
                <el-radio-button label="month">按月</el-radio-button>
              </el-radio-group>
            </div>
          </template>
          <div class="chart-container">
            <div class="chart-title">近7日订单及销售额统计</div>
            <div v-if="salesTrendData.length > 0" class="chart-content">
              <div
                v-for="(value, index) in salesTrendData"
                :key="index"
                class="chart-bar-wrapper"
              >
                <div
                  class="chart-bar"
                  :style="{ height: `${value}%` }"
                ></div>
                <span class="chart-label">{{ weekDays[index] }}</span>
              </div>
            </div>
            <el-empty v-else description="暂无销售数据" :image-size="80" />
          </div>
        </el-card>
      </el-col>

      <el-col :xs="24" :lg="8">
        <el-card shadow="hover" class="quick-card">
          <template #header>
            <span class="card-title">快捷操作</span>
          </template>
          <div class="quick-actions">
            <router-link to="/stations">
              <div class="quick-action-item bg-blue">
                <el-icon :size="24"><Plus /></el-icon>
                <span>新增水站</span>
              </div>
            </router-link>
            <router-link to="/inventory/inbound">
              <div class="quick-action-item bg-green">
                <el-icon :size="24"><Box /></el-icon>
                <span>入库登记</span>
              </div>
            </router-link>
            <router-link to="/inventory/check">
              <div class="quick-action-item bg-purple">
                <el-icon :size="24"><Box /></el-icon>
                <span>库存盘点</span>
              </div>
            </router-link>
          </div>
        </el-card>

        <el-card shadow="hover" class="notification-card">
          <template #header>
            <div class="card-header">
              <span class="card-title">重要通知</span>
              <el-button type="primary" link size="small">全部</el-button>
            </div>
          </template>
          <div v-if="dashboardStore.notifications.length > 0" class="notification-list">
            <div
              v-for="(notification, index) in dashboardStore.notifications"
              :key="index"
              class="notification-item"
            >
              <el-tag
                :type="getNotificationType(notification.type)"
                size="small"
                effect="dark"
                class="notification-tag"
              >
                {{ getNotificationLabel(notification.type) }}
              </el-tag>
              <div class="notification-content">
                <p class="notification-title">{{ notification.title }}</p>
                <p class="notification-time">{{ notification.time }}</p>
              </div>
            </div>
          </div>
          <el-empty v-else description="暂无通知" :image-size="60" />
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useDashboardStore } from '@/stores/dashboard'

const dashboardStore = useDashboardStore()
const trendType = ref('month')

onMounted(async () => {
  await dashboardStore.fetchDashboardStats()
  await dashboardStore.fetchNotifications()
})

const salesTrendData = computed(() => {
  if (dashboardStore.salesTrend && dashboardStore.salesTrend.length > 0) {
    const maxAmount = Math.max(...dashboardStore.salesTrend.map(item => item.amount || 0))
    if (maxAmount > 0) {
      return dashboardStore.salesTrend.map(item => Math.round(((item.amount || 0) / maxAmount) * 100))
    }
  }
  return []
})

const weekDays = computed(() => {
  if (dashboardStore.salesTrend && dashboardStore.salesTrend.length > 0) {
    return dashboardStore.salesTrend.map(item => item.date || '')
  }
  const today = new Date()
  const days = []
  for (let i = 6; i >= 0; i--) {
    const date = new Date(today)
    date.setDate(date.getDate() - i)
    days.push(`${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`)
  }
  return days
})

const getGrowthType = (growth: number) => {
  if (growth > 0) return 'success'
  if (growth < 0) return 'danger'
  return 'info'
}

const formatGrowth = (growth: number) => {
  if (growth > 0) return `+${growth.toFixed(1)}%`
  if (growth < 0) return `${growth.toFixed(1)}%`
  return '持平'
}

const getNotificationType = (type: string) => {
  const typeMap: Record<string, string> = {
    error: 'danger',
    info: 'primary',
    warning: 'warning'
  }
  return typeMap[type] || 'info'
}

const getNotificationLabel = (type: string) => {
  const labelMap: Record<string, string> = {
    error: '紧急',
    info: '通知',
    warning: '提醒'
  }
  return labelMap[type] || '通知'
}
</script>

<style scoped>
.dashboard-page {
  padding: 0;
}

.mb-4 {
  margin-bottom: 20px;
}

.stat-card :deep(.el-card__body) {
  padding: 20px;
}

.stat-content {
  display: flex;
  align-items: center;
  gap: 16px;
}

.stat-icon {
  width: 56px;
  height: 56px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.bg-blue-light {
  background: #e6f7ff;
}

.bg-purple-light {
  background: #f9f0ff;
}

.bg-orange-light {
  background: #fff7e6;
}

.bg-red-light {
  background: #fff1f0;
}

.stat-info {
  flex: 1;
  min-width: 0;
}

.stat-label {
  color: #909399;
  font-size: 14px;
  margin: 0 0 4px 0;
}

.stat-value {
  color: #303133;
  font-size: 24px;
  font-weight: 600;
  margin: 0 0 8px 0;
  line-height: 1.2;
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

.chart-card {
  margin-bottom: 20px;
}

.chart-card :deep(.el-card__body) {
  padding: 16px 20px;
}

.chart-container {
  height: 260px;
}

.chart-title {
  color: #909399;
  font-size: 14px;
  margin-bottom: 20px;
}

.chart-content {
  display: flex;
  justify-content: space-around;
  align-items: flex-end;
  height: 200px;
  padding-top: 20px;
}

.chart-bar-wrapper {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  flex: 1;
}

.chart-bar {
  width: 40px;
  background: linear-gradient(180deg, #409eff 0%, #66b1ff 100%);
  border-radius: 4px 4px 0 0;
  transition: all 0.3s;
  min-height: 10px;
}

.chart-bar:hover {
  background: linear-gradient(180deg, #66b1ff 0%, #409eff 100%);
}

.chart-label {
  font-size: 12px;
  color: #909399;
}

.quick-card {
  margin-bottom: 20px;
}

.quick-actions {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
}

.quick-action-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 20px 16px;
  border-radius: 12px;
  color: #fff;
  cursor: pointer;
  transition: all 0.3s;
  text-decoration: none;
}

.quick-action-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.bg-blue {
  background: linear-gradient(135deg, #1890ff 0%, #409eff 100%);
}

.bg-green {
  background: linear-gradient(135deg, #52c41a 0%, #73d13d 100%);
}

.quick-action-item span {
  font-size: 14px;
  font-weight: 500;
}

.notification-card :deep(.el-card__body) {
  padding: 12px;
}

.notification-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.notification-item {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding-bottom: 12px;
  border-bottom: 1px solid #f0f0f0;
}

.notification-item:last-child {
  border-bottom: none;
  padding-bottom: 0;
}

.notification-tag {
  flex-shrink: 0;
}

.notification-content {
  flex: 1;
  min-width: 0;
}

.notification-title {
  color: #303133;
  font-size: 14px;
  margin: 0 0 4px 0;
  line-height: 1.4;
}

.notification-time {
  color: #909399;
  font-size: 12px;
  margin: 0;
}
</style>
