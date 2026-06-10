<template>
  <div class="drivers-page">
    <el-card shadow="never" class="mb-4">
      <template #header>
        <div class="card-header">
          <div class="header-left">
            <span class="header-title">司机管理</span>
            <span class="header-desc">管理所有配送司机账号，支持新增、编辑和状态管理</span>
          </div>
          <el-button type="primary" @click="openAddDialog">
            <el-icon><Plus /></el-icon>
            新增司机
          </el-button>
        </div>
      </template>

      <el-form :inline="true" :model="filters" class="filter-form">
        <el-form-item label="司机姓名/电话">
          <el-input v-model="filters.search" placeholder="搜索司机姓名、电话..." clearable style="width: 200px" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="filters.status" placeholder="全部状态" clearable style="width: 150px">
            <el-option label="在线" value="online" />
            <el-option label="离线" value="offline" />
            <el-option label="配送中" value="delivering" />
          </el-select>
        </el-form-item>
        <el-form-item label="负责区域">
          <el-select v-model="filters.area" placeholder="全部区域" clearable style="width: 150px">
            <el-option
              v-for="region in regionStore.getRegionOptions()"
              :key="region.value"
              :label="region.label"
              :value="region.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button @click="resetFilters">重置</el-button>
          <el-button type="primary" @click="handleSearch">查询</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-row :gutter="16" class="mb-4">
      <el-col :xs="12" :sm="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon bg-green-light">
              <el-icon :size="28" color="#67c23a"><User /></el-icon>
            </div>
            <div class="stat-info">
              <p class="stat-label">在线司机</p>
              <p class="stat-value">{{ stats.online }} 人</p>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="12" :sm="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon bg-gray-light">
              <el-icon :size="28" color="#909399"><UserFilled /></el-icon>
            </div>
            <div class="stat-info">
              <p class="stat-label">离线司机</p>
              <p class="stat-value">{{ stats.offline }} 人</p>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="12" :sm="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon bg-orange-light">
              <el-icon :size="28" color="#e6a23c"><Location /></el-icon>
            </div>
            <div class="stat-info">
              <p class="stat-label">正在配送</p>
              <p class="stat-value">{{ stats.delivering }} 单</p>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="12" :sm="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon bg-blue-light">
              <el-icon :size="28" color="#409eff"><CircleCheck /></el-icon>
            </div>
            <div class="stat-info">
              <p class="stat-label">今日完成</p>
              <p class="stat-value">{{ stats.completedToday }} 单</p>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-card shadow="never">
      <el-table :data="paginatedDrivers" stripe v-loading="loading">
        <el-table-column label="司机信息" min-width="180">
          <template #default="{ row }">
            <div class="driver-info">
              <el-avatar :size="40" :src="row.avatar">
                {{ row.name?.charAt(0) || '司' }}
              </el-avatar>
              <div class="driver-detail">
                <p class="driver-name">{{ row.name }}</p>
                <p class="driver-code">工号: {{ row.code }}</p>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="联系方式" min-width="120">
          <template #default="{ row }">
            <span>{{ row.phone }}</span>
          </template>
        </el-table-column>
        <el-table-column label="负责区域" min-width="120">
          <template #default="{ row }">
            <el-tag size="small" type="primary">
              {{ regionStore.getRegionName(row.area) || row.area || '未分配' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="当前任务" min-width="80" align="center">
          <template #default="{ row }">
            <span :class="row.currentTasks > 0 ? 'text-orange-500' : ''">
              {{ row.currentTasks }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="今日配送" min-width="100">
          <template #default="{ row }">
            <div>
              <span class="font-bold">{{ row.todayDeliveries }}</span> 单
              <span class="text-gray-400"> · {{ row.todayBuckets }}桶</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="状态" min-width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)" effect="dark" size="small">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" min-width="120" align="center" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="openEditDialog(row)">编辑</el-button>
            <el-dropdown trigger="click" @command="(cmd: string) => handleDriverAction(cmd, row)">
              <el-button link type="primary">
                <el-icon><MoreFilled /></el-icon>
              </el-button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="view">查看详情</el-dropdown-item>
                  <el-dropdown-item command="reset">重置密码</el-dropdown-item>
                  <el-dropdown-item :command="row.status === 'active' ? 'disable' : 'enable'">
                    {{ row.status === 'active' ? '停用账号' : '启用账号' }}
                  </el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </template>
        </el-table-column>
        <template #empty>
          <el-empty description="暂无司机数据" />
        </template>
      </el-table>

      <div class="pagination-container">
        <span class="total-text">共 {{ totalDrivers }} 位司机</span>
        <el-pagination
          v-model:current-page="currentPage"
          :page-size="pageSize"
          :total="totalDrivers"
          layout="prev, pager, next, total"
          @current-change="handlePageChange"
        />
      </div>
    </el-card>

    <el-dialog
      v-model="showDialog"
      :title="dialogMode === 'add' ? '新增司机' : '编辑司机信息'"
      width="600px"
      :close-on-click-modal="false"
    >
      <el-form ref="formRef" :model="driverForm" :rules="rules" label-width="100px">
        <el-form-item label="司机姓名" prop="name">
          <el-input v-model="driverForm.name" placeholder="请输入司机姓名" />
        </el-form-item>
        <el-form-item label="工号">
          <el-input v-model="driverForm.code" placeholder="系统自动生成" disabled />
        </el-form-item>
        <el-form-item label="联系电话" prop="phone">
          <el-input v-model="driverForm.phone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="身份证号">
          <el-input v-model="driverForm.idCard" placeholder="请输入身份证号" />
        </el-form-item>
        <el-form-item label="紧急联系人">
          <el-input v-model="driverForm.emergencyContact" placeholder="请输入紧急联系人" />
        </el-form-item>
        <el-form-item label="紧急电话">
          <el-input v-model="driverForm.emergencyPhone" placeholder="请输入紧急联系电话" />
        </el-form-item>
        <el-form-item label="负责区域">
          <el-select v-model="driverForm.area" placeholder="请选择区域" style="width: 100%">
            <el-option
              v-for="region in regionStore.getRegionOptions()"
              :key="region.value"
              :label="region.label"
              :value="region.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="配送仓库">
          <el-select v-model="driverForm.warehouseIds" multiple placeholder="请选择仓库（可多选）" style="width: 100%">
            <el-option
              v-for="warehouse in warehouses"
              :key="warehouse.id"
              :label="warehouse.name"
              :value="String(warehouse.id)"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="driverForm.remark" type="textarea" :rows="3" placeholder="请输入备注..." />
        </el-form-item>
        <el-form-item :label="dialogMode === 'add' ? '登录密码' : '新密码'">
          <el-input
            v-model="driverForm.password"
            type="password"
            show-password
            :placeholder="dialogMode === 'add' ? '请输入登录密码(留空则使用默认密码)' : '请输入新密码(留空则不修改)'"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="closeDialog">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitting">
          {{ dialogMode === 'add' ? '确认添加' : '保存修改' }}
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, FormInstance, FormRules, ElMessageBox } from 'element-plus'
import { useRegionStore } from '@/stores/regions'
import { driversApi } from '@/api/drivers'
import { warehousesApi } from '@/api/warehouses'

interface Driver {
  id: number
  name: string
  code: string
  phone: string
  idCard?: string
  area?: string
  warehouseId?: number
  warehouseIds?: number[]
  warehouseNames?: string[]
  avatar?: string
  currentTasks: number
  todayDeliveries: number
  todayBuckets: number
  status: string
  remark?: string
}

interface DriverStats {
  online: number
  offline: number
  delivering: number
  completedToday: number
}

const router = useRouter()
const regionStore = useRegionStore()

const stats = ref<DriverStats>({
  online: 0,
  offline: 0,
  delivering: 0,
  completedToday: 0
})

const filters = reactive({
  search: '',
  status: '',
  area: ''
})

const showDialog = ref(false)
const dialogMode = ref<'add' | 'edit'>('add')
const submitting = ref(false)
const currentPage = ref(1)
const pageSize = 10
const formRef = ref<FormInstance>()
const selectedDriver = ref<Driver | null>(null)
const loading = ref(false)

const drivers = ref<Driver[]>([])
const warehouses = ref<{ id: number; name: string }[]>([])
const totalDrivers = computed(() => filteredDrivers.value.length)

const filteredDrivers = computed(() => {
  return drivers.value.filter(driver => {
    if (filters.search && !driver.name.includes(filters.search) && !driver.phone.includes(filters.search)) {
      return false
    }
    if (filters.status && driver.status !== filters.status) {
      return false
    }
    if (filters.area && driver.area !== filters.area) {
      return false
    }
    return true
  })
})

const paginatedDrivers = computed(() => {
  const start = (currentPage.value - 1) * pageSize
  return filteredDrivers.value.slice(start, start + pageSize)
})

const driverForm = reactive({
  name: '',
  code: '',
  phone: '',
  idCard: '',
  emergencyContact: '',
  emergencyPhone: '',
  area: '',
  warehouseId: '' as string,
  warehouseIds: [] as string[],
  remark: '',
  password: ''
})

const rules: FormRules = {
  name: [{ required: true, message: '请输入司机姓名', trigger: 'blur' }],
  phone: [
    { required: true, message: '请输入联系电话', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ]
}

const getStatusType = (status: string) => {
  const typeMap: Record<string, string> = {
    online: 'success',
    offline: 'info',
    delivering: 'warning',
    active: 'success',
    inactive: 'info'
  }
  return typeMap[status] || 'info'
}

const getStatusText = (status: string) => {
  const textMap: Record<string, string> = {
    online: '在线',
    offline: '离线',
    delivering: '配送中',
    active: '正常',
    inactive: '已停用'
  }
  return textMap[status] || status
}

const fetchDrivers = async () => {
  loading.value = true
  try {
    const params: any = {
      page: currentPage.value,
      size: pageSize
    }
    if (filters.search) {
      params.search = filters.search
    }
    if (filters.status) {
      params.status = filters.status
    }

    const res: any = await driversApi.getAll(params)
    console.log('司机列表API响应:', res)

    const driverList = res.data || res
    if (Array.isArray(driverList)) {
      drivers.value = driverList
    } else if (res && res.records) {
      drivers.value = Array.isArray(res.records) ? res.records : []
    } else {
      drivers.value = []
    }
  } catch (error) {
    console.error('获取司机列表失败:', error)
    drivers.value = []
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  currentPage.value = 1
  fetchDrivers()
}

const resetFilters = () => {
  filters.search = ''
  filters.status = ''
  filters.area = ''
  currentPage.value = 1
  fetchDrivers()
}

const openAddDialog = () => {
  dialogMode.value = 'add'
  Object.assign(driverForm, {
    name: '',
    code: '',
    phone: '',
    idCard: '',
    emergencyContact: '',
    emergencyPhone: '',
    area: '',
    warehouseId: '',
    warehouseIds: [],
    remark: '',
    password: ''
  })
  showDialog.value = true
}

const openEditDialog = (driver: Driver) => {
  dialogMode.value = 'edit'
  selectedDriver.value = driver
  Object.assign(driverForm, {
    name: driver.name,
    code: driver.code || '',
    phone: driver.phone,
    idCard: driver.idCard || '',
    emergencyContact: '',
    emergencyPhone: '',
    area: driver.area || '',
    warehouseId: driver.warehouseId?.toString() || '',
    warehouseIds: driver.warehouseIds?.map(String) || [],
    remark: driver.remark || '',
    password: ''
  })
  showDialog.value = true
}

const closeDialog = () => {
  showDialog.value = false
  selectedDriver.value = null
  formRef.value?.resetFields()
}

const handleSubmit = async () => {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    submitting.value = true
    try {
      if (dialogMode.value === 'add') {
        await driversApi.create({
          name: driverForm.name,
          phone: driverForm.phone,
          idCard: driverForm.idCard,
          area: driverForm.area,
          warehouseId: driverForm.warehouseId || undefined,
          warehouseIds: driverForm.warehouseIds.map(id => Number(id)),
          remark: driverForm.remark,
          password: driverForm.password || '123456'
        })
        ElMessage.success('添加成功')
      } else if (selectedDriver.value) {
        await driversApi.update(String(selectedDriver.value.id), {
          name: driverForm.name,
          phone: driverForm.phone,
          idCard: driverForm.idCard,
          area: driverForm.area,
          warehouseId: driverForm.warehouseId || undefined,
          warehouseIds: driverForm.warehouseIds.map(id => Number(id)),
          remark: driverForm.remark,
          password: driverForm.password || undefined
        })
        ElMessage.success('修改成功')
      }
      closeDialog()
      await fetchDrivers()
    } catch (error) {
      console.error('提交失败:', error)
      ElMessage.error('提交失败，请重试')
    } finally {
      submitting.value = false
    }
  })
}

const handleDriverAction = async (command: string, driver: Driver) => {
  switch (command) {
    case 'view':
      router.push(`/drivers/${driver.id}`)
      break
    case 'reset':
      try {
        await ElMessageBox.confirm(`确定要重置司机 ${driver.name} 的密码吗？`, '重置密码', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        })
        await driversApi.resetPassword(String(driver.id))
        ElMessage.success('密码已重置为 123456')
      } catch {
        // 用户取消操作
      }
      break
    case 'enable':
    case 'disable':
      try {
        await ElMessageBox.confirm(
          `确定要${command === 'enable' ? '启用' : '停用'}司机"${driver.name}"吗？`,
          '提示',
          { confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning' }
        )
        if (command === 'enable') {
          await driversApi.enable(String(driver.id))
        } else {
          await driversApi.disable(String(driver.id))
        }
        ElMessage.success(`司机账号已${command === 'enable' ? '启用' : '停用'}`)
        await fetchDrivers()
      } catch {
        // 用户取消操作
      }
      break
  }
}

const handlePageChange = (page: number) => {
  currentPage.value = page
  fetchDrivers()
}

const fetchWarehouses = async () => {
  try {
    const res: any = await warehousesApi.getAll()
    if (Array.isArray(res)) {
      warehouses.value = res.map((w: any) => ({
        id: typeof w.id === 'string' ? parseInt(w.id) : w.id,
        name: w.name || w.warehouseName || ''
      }))
    } else if (res && res.data) {
      warehouses.value = res.data.map((w: any) => ({
        id: typeof w.id === 'string' ? parseInt(w.id) : w.id,
        name: w.name || w.warehouseName || ''
      }))
    }
  } catch (error) {
    console.error('获取仓库列表失败:', error)
    warehouses.value = []
  }
}

onMounted(async () => {
  await regionStore.fetchRegionTree()
  await fetchDrivers()
  await fetchWarehouses()
})
</script>

<style scoped>
.drivers-page {
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

.stat-card :deep(.el-card__body) {
  padding: 16px;
}

.stat-content {
  display: flex;
  align-items: center;
  gap: 12px;
}

.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.bg-blue-light {
  background: #e6f7ff;
}

.bg-green-light {
  background: #f6ffed;
}

.bg-orange-light {
  background: #fff7e6;
}

.bg-gray-light {
  background: #f5f5f5;
}

.stat-info {
  flex: 1;
  min-width: 0;
}

.stat-label {
  color: #909399;
  font-size: 13px;
  margin: 0 0 4px 0;
}

.stat-value {
  color: #303133;
  font-size: 20px;
  font-weight: 600;
  margin: 0;
}

.driver-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.driver-detail {
  flex: 1;
}

.driver-name {
  font-weight: 500;
  color: #303133;
  margin: 0;
}

.driver-code {
  font-size: 12px;
  color: #909399;
  margin: 4px 0 0 0;
}

.text-orange-500 {
  color: #e6a23c;
  font-weight: 600;
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
</style>
