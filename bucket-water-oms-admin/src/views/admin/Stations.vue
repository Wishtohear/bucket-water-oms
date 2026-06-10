<template>
  <div class="stations-page">
    <el-card shadow="never" class="mb-4">
      <template #header>
        <div class="card-header">
          <div class="header-left">
            <span class="header-title">水站管理</span>
            <span class="header-desc">管理所有水站账号，支持新增、编辑和状态管理</span>
          </div>
          <el-button type="primary" @click="openAddStationDialog">
            <el-icon><Plus /></el-icon>
            新增水站
          </el-button>
        </div>
      </template>

      <el-form :inline="true" :model="filters" class="filter-form">
        <el-form-item label="水站名称/联系人">
          <el-input v-model="filters.search" placeholder="搜索水站名称、姓名、电话..." clearable style="width: 220px" />
        </el-form-item>
        <el-form-item label="账户状态">
          <el-select v-model="filters.status" placeholder="全部状态" clearable style="width: 150px">
            <el-option label="正常运营" value="active" />
            <el-option label="欠费停供" value="suspended" />
            <el-option label="已注销" value="closed" />
          </el-select>
        </el-form-item>
        <el-form-item label="余额筛选">
          <el-select v-model="filters.balance" placeholder="全部" clearable style="width: 150px">
            <el-option label="余额充足" value="sufficient" />
            <el-option label="余额不足" value="insufficient" />
            <el-option label="账户欠费" value="overdue" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button @click="resetFilters">重置</el-button>
          <el-button type="primary" @click="searchStations">查询</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never">
      <el-table :data="paginatedStations" stripe v-loading="stationStore.loading">
        <el-table-column label="水站信息" min-width="200">
          <template #default="{ row }">
            <div class="station-info">
              <el-icon :size="24" color="#409eff"><Shop /></el-icon>
              <div class="station-detail">
                <p class="station-name">{{ row.name }}</p>
                <p class="station-address">{{ row.address }}</p>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="联系人" min-width="120">
          <template #default="{ row }">
            <div>
              <p class="contact-name">{{ row.contact }}</p>
              <p class="contact-phone">{{ row.phone }}</p>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="账户余额" min-width="120" align="right">
          <template #default="{ row }">
            <span :class="row.balance < 0 ? 'text-red-500 font-bold' : 'font-bold'">
              ¥ {{ Math.abs(row.balance || 0).toLocaleString() }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="欠桶数量" min-width="100" align="right">
          <template #default="{ row }">
            <span class="text-orange-500">{{ row.owedBuckets || 0 }} 个</span>
          </template>
        </el-table-column>
        <el-table-column label="状态" min-width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)" effect="dark">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" min-width="200" align="center" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="viewStationDetail(row)">详情</el-button>
            <el-button link type="primary" @click="viewOrders(row)">订单</el-button>
            <el-button link type="primary" @click="editStation(row)">编辑</el-button>
            <el-dropdown trigger="click" @command="(cmd: string) => handleActionCommand(cmd, row)">
              <el-button link type="primary">
                <el-icon><MoreFilled /></el-icon>
              </el-button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item :command="row.status === 'active' ? 'disable' : 'enable'">
                    {{ row.status === 'active' ? '停用' : '启用' }}
                  </el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </template>
        </el-table-column>
        <template #empty>
          <el-empty description="暂无水站数据" />
        </template>
      </el-table>

      <div class="pagination-container">
        <span class="total-text">共 {{ stationStore.total }} 家水站记录</span>
        <el-pagination
          v-model:current-page="currentPage"
          :page-size="stationStore.pageSize"
          :total="stationStore.total"
          layout="prev, pager, next, total"
          @current-change="handlePageChange"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useStationStore } from '@/stores/stations'
import { stationsApi } from '@/api/stations'
import type { StationVO } from '@/api/stations'

const router = useRouter()
const stationStore = useStationStore()

const currentPage = ref(1)

const filters = reactive({
  search: '',
  status: '',
  balance: ''
})

const paginatedStations = computed(() => {
  const start = (currentPage.value - 1) * stationStore.pageSize
  const end = start + stationStore.pageSize
  return stationStore.stations.slice(start, end)
})

const getStatusType = (status: string) => {
  const typeMap: Record<string, string> = {
    active: 'success',
    suspended: 'warning',
    closed: 'info'
  }
  return typeMap[status] || 'info'
}

const getStatusText = (status: string) => {
  const textMap: Record<string, string> = {
    active: '正常运营',
    suspended: '欠费停供',
    closed: '已注销'
  }
  return textMap[status] || status
}

const searchStations = async () => {
  currentPage.value = 1
  await stationStore.fetchStations(filters, 1)
}

const resetFilters = () => {
  filters.search = ''
  filters.status = ''
  filters.balance = ''
  searchStations()
}

const editStation = (station: StationVO) => {
  router.push(`/stations/${station.id}/edit`)
}

const openAddStationDialog = () => {
  router.push('/stations/create')
}

const handleActionCommand = async (command: string, station: StationVO) => {
  if (command === 'enable' || command === 'disable') {
    try {
      await ElMessageBox.confirm(
        `确定要${command === 'enable' ? '启用' : '停用'}水站"${station.name}"吗？`,
        '提示',
        { confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning' }
      )
      const newStatus = command === 'enable' ? 'active' : 'inactive'
      await stationsApi.updateStatus(station.id, newStatus)
      await stationStore.fetchStations(filters, currentPage.value)
      ElMessage.success(command === 'enable' ? '已启用' : '已停用')
    } catch {
      // 用户取消操作
    }
  }
}

const viewStationDetail = (station: StationVO) => {
  router.push(`/stations/${station.id}`)
}

const viewOrders = (station: StationVO) => {
  router.push({ path: '/orders', query: { stationId: String(station.id) } })
}

const handlePageChange = async (page: number) => {
  currentPage.value = page
  await stationStore.fetchStations(filters, page)
}

onMounted(async () => {
  await stationStore.fetchStations()
})
</script>

<style scoped>
.stations-page {
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

.header-left {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.header-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  margin: 0;
}

.header-desc {
  font-size: 14px;
  color: #909399;
  margin: 0;
}

.filter-form {
  margin-top: 16px;
}

.station-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.station-detail {
  flex: 1;
}

.station-name {
  font-weight: 500;
  color: #303133;
  margin: 0;
}

.station-address {
  font-size: 12px;
  color: #909399;
  margin: 4px 0 0 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.contact-name {
  font-weight: 500;
  color: #303133;
  margin: 0;
}

.contact-phone {
  font-size: 12px;
  color: #909399;
  margin: 4px 0 0 0;
}

.text-red-500 {
  color: #f56c6c;
}

.text-orange-500 {
  color: #e6a23c;
}

.pagination-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 20px;
}

.total-text {
  color: #909399;
  font-size: 14px;
}

.station-form :deep(.el-form-item__label) {
  font-weight: 500;
}
</style>
