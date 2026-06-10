<template>
  <div class="warehouse-drivers">
    <el-card shadow="never" class="mb-4">
      <template #header>
        <div>
          <h2 class="page-title">司机管理</h2>
          <p class="page-desc">管理仓库配送司机</p>
        </div>
      </template>
    </el-card>

    <el-row :gutter="20" class="mb-4">
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-icon-wrapper green">
            <el-icon class="stat-icon"><User /></el-icon>
          </div>
          <div class="stat-content">
            <p class="stat-label">在线司机</p>
            <h3 class="stat-value">{{ stats.online }} <span class="stat-unit">人</span></h3>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-icon-wrapper gray">
            <el-icon class="stat-icon"><UserFilled /></el-icon>
          </div>
          <div class="stat-content">
            <p class="stat-label">离线司机</p>
            <h3 class="stat-value">{{ stats.offline }} <span class="stat-unit">人</span></h3>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-icon-wrapper purple">
            <el-icon class="stat-icon"><Van /></el-icon>
          </div>
          <div class="stat-content">
            <p class="stat-label">配送中</p>
            <h3 class="stat-value">{{ stats.delivering }} <span class="stat-unit">人</span></h3>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-icon-wrapper orange">
            <el-icon class="stat-icon"><Clock /></el-icon>
          </div>
          <div class="stat-content">
            <p class="stat-label">休息中</p>
            <h3 class="stat-value">{{ stats.break }} <span class="stat-unit">人</span></h3>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-card shadow="never" v-loading="loading">
      <template #header>
        <span class="section-title">司机列表</span>
      </template>
      <el-table :data="drivers" stripe style="width: 100%">
        <el-table-column label="司机信息" min-width="200">
          <template #default="{ row }">
            <div class="driver-info">
              <el-avatar :size="40" :icon="UserFilled" />
              <div class="driver-details">
                <p class="driver-name">{{ row.name }}</p>
                <p class="driver-code">工号: {{ row.code || '-' }}</p>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="phone" label="联系电话" width="150">
          <template #default="{ row }">
            {{ row.phone || '-' }}
          </template>
        </el-table-column>
        <el-table-column label="今日任务" width="120" align="center">
          <template #default="{ row }">
            <span class="bold">{{ row.currentTasks || 0 }}</span> 单
          </template>
        </el-table-column>
        <el-table-column label="在线状态" width="120" align="center">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.onlineStatus)" size="small">
              {{ row.onlineStatusText || getStatusText(row.onlineStatus) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="当前位置" width="150">
          <template #default="{ row }">
            {{ row.currentLocation || '-' }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" align="center">
          <template #default>
            <el-button link type="success" size="small">联系</el-button>
            <el-button link type="primary" size="small">位置</el-button>
          </template>
        </el-table-column>
        <template #empty>
          <el-empty description="暂无司机数据" :image-size="80" />
        </template>
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { warehouseApi } from '@/api'
import { toast } from '@/composables/useToast'
import { User, UserFilled, Van, Clock } from '@element-plus/icons-vue'
import type { DriverVO } from '@/api/warehouse'

const loading = ref(false)

const stats = ref({
  online: 0,
  offline: 0,
  delivering: 0,
  break: 0
})

const drivers = ref<DriverVO[]>([])

const getStatusText = (status: string) => {
  const map: Record<string, string> = {
    online: '在线',
    offline: '离线',
    delivering: '配送中',
    break: '休息中'
  }
  return map[status] || status
}

const getStatusType = (status: string) => {
  const typeMap: Record<string, string> = {
    online: 'success',
    offline: 'info',
    delivering: 'primary',
    break: 'warning'
  }
  return typeMap[status] || 'info'
}

const fetchDrivers = async () => {
  loading.value = true
  try {
    const res: any = await warehouseApi.getAvailableDrivers()
    const driverData = res.data || res || []
    drivers.value = Array.isArray(driverData) ? driverData : []

    stats.value = {
      online: drivers.value.filter(d => d.onlineStatus === 'online').length,
      offline: drivers.value.filter(d => d.onlineStatus === 'offline').length,
      delivering: drivers.value.filter(d => d.onlineStatus === 'delivering').length,
      break: drivers.value.filter(d => d.onlineStatus === 'break').length
    }
  } catch (error: any) {
    console.error('获取司机列表失败:', error)
    toast.error('获取司机列表失败')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchDrivers()
})
</script>

<style scoped>
.warehouse-drivers {
  padding: 20px;
}

.mb-4 {
  margin-bottom: 16px;
}

.page-title {
  margin: 0;
  font-size: 18px;
  font-weight: bold;
  color: #303133;
}

.page-desc {
  margin: 4px 0 0;
  font-size: 12px;
  color: #909399;
}

.stat-card {
  margin-bottom: 20px;
}

.stat-card :deep(.el-card__body) {
  display: flex;
  align-items: center;
  gap: 16px;
}

.stat-icon-wrapper {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.stat-icon-wrapper.green {
  background: #f0f9eb;
  color: #67c23a;
}

.stat-icon-wrapper.gray {
  background: #f5f7fa;
  color: #909399;
}

.stat-icon-wrapper.purple {
  background: #faf5ff;
  color: #a855f7;
}

.stat-icon-wrapper.orange {
  background: #fdf6ec;
  color: #e6a23c;
}

.stat-icon {
  font-size: 24px;
}

.stat-content {
  flex: 1;
}

.stat-label {
  color: #909399;
  font-size: 14px;
  margin: 0 0 4px;
}

.stat-value {
  font-size: 24px;
  font-weight: bold;
  color: #303133;
  margin: 0;
}

.stat-unit {
  font-size: 14px;
  font-weight: normal;
  color: #909399;
}

.section-title {
  font-weight: bold;
  color: #303133;
}

.driver-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.driver-details {
  flex: 1;
}

.driver-name {
  font-size: 14px;
  font-weight: 500;
  color: #303133;
  margin: 0;
}

.driver-code {
  font-size: 12px;
  color: #909399;
  margin: 4px 0 0;
}

.bold {
  font-weight: 500;
}
</style>
