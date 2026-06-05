<template>
  <div class="operation-logs">
    <el-card>
      <template #header>
        <span>操作日志</span>
      </template>

      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="操作模块">
          <el-select v-model="searchForm.module" placeholder="请选择模块" clearable>
            <el-option label="水厂管理" value="factory" />
            <el-option label="水站管理" value="station" />
            <el-option label="仓库管理" value="warehouse" />
            <el-option label="司机管理" value="driver" />
            <el-option label="系统配置" value="system" />
          </el-select>
        </el-form-item>
        <el-form-item label="操作类型">
          <el-select v-model="searchForm.action" placeholder="请选择操作" clearable>
            <el-option label="新增" value="CREATE" />
            <el-option label="修改" value="UPDATE" />
            <el-option label="删除" value="DELETE" />
            <el-option label="登录" value="LOGIN" />
            <el-option label="登出" value="LOGOUT" />
          </el-select>
        </el-form-item>
        <el-form-item label="操作人">
          <el-input v-model="searchForm.operator" placeholder="请输入操作人" clearable />
        </el-form-item>
        <el-form-item label="时间范围">
          <el-date-picker
            v-model="searchForm.dateRange"
            type="datetimerange"
            range-separator="至"
            start-placeholder="开始时间"
            end-placeholder="结束时间"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="tableData" v-loading="loading" stripe>
        <el-table-column prop="createTime" label="操作时间" width="180" />
        <el-table-column prop="userName" label="操作人" width="120" />
        <el-table-column prop="module" label="模块" width="120">
          <template #default="{ row }">
            <el-tag size="small">{{ getModuleName(row.module) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="action" label="操作类型" width="100">
          <template #default="{ row }">
            <el-tag :type="getActionType(row.action)" size="small">
              {{ getActionName(row.action) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="targetType" label="操作对象" width="120" />
        <el-table-column prop="targetName" label="对象名称" show-overflow-tooltip />
        <el-table-column prop="description" label="操作详情" show-overflow-tooltip />
        <el-table-column prop="ipAddress" label="IP地址" width="140" />
      </el-table>

      <el-pagination
        v-model:current-page="pagination.page"
        v-model:page-size="pagination.size"
        :total="pagination.total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        style="margin-top: 20px; justify-content: flex-end"
      />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { platformApi } from '../../api/platform'

const loading = ref(false)

const searchForm = reactive({
  module: '',
  action: '',
  operator: '',
  dateRange: [] as string[]
})

const pagination = reactive({
  page: 1,
  size: 20,
  total: 0
})

const tableData = ref([])

const moduleMap: Record<string, string> = {
  factory: '水厂管理',
  station: '水站管理',
  warehouse: '仓库管理',
  driver: '司机管理',
  system: '系统配置',
  product: '产品管理',
  order: '订单管理'
}

const actionMap: Record<string, string> = {
  CREATE: '新增',
  UPDATE: '修改',
  DELETE: '删除',
  ENABLE: '启用',
  DISABLE: '停用',
  LOGIN: '登录',
  LOGOUT: '登出',
  EXPORT: '导出',
  IMPORT: '导入'
}

const getModuleName = (module: string) => moduleMap[module] || module
const getActionName = (action: string) => actionMap[action] || action

const getActionType = (action: string) => {
  const typeMap: Record<string, string> = {
    CREATE: 'success',
    UPDATE: 'warning',
    DELETE: 'danger',
    ENABLE: 'success',
    DISABLE: 'warning'
  }
  return typeMap[action] || 'info'
}

const tableData = ref<any[]>([])

const moduleMap: Record<string, string> = {
  factory: '水厂管理',
  station: '水站管理',
  warehouse: '仓库管理',
  driver: '司机管理',
  system: '系统配置',
  product: '产品管理',
  order: '订单管理'
}

const actionMap: Record<string, string> = {
  CREATE: '新增',
  UPDATE: '修改',
  DELETE: '删除',
  ENABLE: '启用',
  DISABLE: '停用',
  LOGIN: '登录',
  LOGOUT: '登出',
  EXPORT: '导出',
  IMPORT: '导入'
}

const getModuleName = (module: string) => moduleMap[module] || module
const getActionName = (action: string) => actionMap[action] || action

const getActionType = (action: string) => {
  const typeMap: Record<string, string> = {
    CREATE: 'success',
    UPDATE: 'warning',
    DELETE: 'danger',
    ENABLE: 'success',
    DISABLE: 'warning'
  }
  return typeMap[action] || 'info'
}

const formatDateTime = (val: any) => {
  if (!val) return '-'
  if (Array.isArray(val)) {
    const [d, t] = val
    return `${d} ${t || ''}`
  }
  return val
}

const loadData = async () => {
  loading.value = true
  try {
    const response: any = await platformApi.getLogs({
      page: pagination.page,
      size: pagination.size,
      module: searchForm.module || undefined,
      action: searchForm.action || undefined,
      userName: searchForm.operator || undefined,
      startTime: Array.isArray(searchForm.dateRange) && searchForm.dateRange[0] ? String(searchForm.dateRange[0]) : undefined,
      endTime: Array.isArray(searchForm.dateRange) && searchForm.dateRange[1] ? String(searchForm.dateRange[1]) : undefined
    })
    if (response.success) {
      tableData.value = (response.data?.records || []).map((row: any) => ({
        ...row,
        createTime: formatDateTime(row.createTime)
      }))
      pagination.total = response.data?.total || 0
    }
  } catch (error) {
    ElMessage.error('加载数据失败')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pagination.page = 1
  loadData()
}

const handleReset = () => {
  Object.assign(searchForm, {
    module: '',
    action: '',
    operator: '',
    dateRange: []
  })
  handleSearch()
}

const handleSizeChange = () => {
  pagination.page = 1
  loadData()
}

const handleCurrentChange = () => {
  loadData()
}

onMounted(() => {
  loadData()
})
</script>

<style scoped>
.operation-logs {
  padding: 20px;
}

.search-form {
  margin-bottom: 20px;
}
</style>
