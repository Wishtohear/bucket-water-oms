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
            <el-option label="启用" value="ENABLE" />
            <el-option label="停用" value="DISABLE" />
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
        <el-table-column prop="operatorName" label="操作人" width="120" />
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
        <el-table-column prop="detail" label="操作详情" show-overflow-tooltip />
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
import { ref, reactive } from 'vue'
import { ElMessage } from 'element-plus'
import axios from 'axios'

const loading = ref(false)

const searchForm = reactive({
  module: '',
  action: '',
  operator: '',
  dateRange: []
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

const loadData = async () => {
  loading.value = true
  try {
    const response = await axios.get('/api/platform/logs', {
      params: {
        page: pagination.page,
        size: pagination.size,
        ...searchForm,
        startDate: searchForm.dateRange?.[0],
        endDate: searchForm.dateRange?.[1]
      }
    })
    if (response.data.success) {
      tableData.value = response.data.data.records
      pagination.total = response.data.data.total
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

loadData()
</script>

<style scoped>
.operation-logs {
  padding: 20px;
}

.search-form {
  margin-bottom: 20px;
}
</style>
