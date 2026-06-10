<template>
  <div>
    <div class="page-header">
      <div>
        <h2 class="page-title">审计日志</h2>
        <p class="page-desc">记录所有管理员的关键操作，支持查询和导出</p>
      </div>
      <div class="header-actions">
        <el-button type="danger" :loading="deleting" @click="handleDeleteAll">
          <el-icon><Delete /></el-icon>
          删除日志
        </el-button>
        <el-button type="success" :loading="exporting" @click="handleExport">
          <el-icon><Download /></el-icon>
          导出日志
        </el-button>
      </div>
    </div>

    <el-card shadow="never">
      <el-form :inline="true" :model="filters" class="filter-form">
        <el-form-item label="操作类型">
          <el-select v-model="filters.action" placeholder="全部操作" clearable style="width: 140px">
            <el-option value="CREATE" label="新增" />
            <el-option value="UPDATE" label="修改" />
            <el-option value="DELETE" label="删除" />
            <el-option value="QUERY" label="查询" />
            <el-option value="LOGIN" label="登录" />
            <el-option value="EXPORT" label="导出" />
            <el-option value="RESET" label="重置" />
          </el-select>
        </el-form-item>
        <el-form-item label="模块">
          <el-select v-model="filters.module" placeholder="全部模块" clearable style="width: 140px">
            <el-option value="station" label="水站" />
            <el-option value="driver" label="司机" />
            <el-option value="warehouse" label="仓库" />
            <el-option value="product" label="产品" />
            <el-option value="order" label="订单" />
            <el-option value="policy" label="政策" />
            <el-option value="region" label="地域" />
            <el-option value="finance" label="财务" />
            <el-option value="system" label="系统" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="resetFilters">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="auditLogs" stripe v-loading="loading">
        <el-table-column label="时间" width="180">
          <template #default="{ row }">
            <span class="log-time">{{ formatDateTime(row.createTime) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作员" width="180">
          <template #default="{ row }">
            <div class="operator-cell">
              <div class="operator-avatar">
                <el-icon size="18" color="#409eff"><User /></el-icon>
              </div>
              <div class="operator-info">
                <span class="operator-name">{{ row.username || '未知' }}</span>
                <span class="operator-role">{{ row.userRole || '未登录' }}</span>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="操作类型" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getActionTagType(row.action)" size="small">
              {{ getActionTypeText(row.action) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="模块" width="80" align="center">
          <template #default="{ row }">
            <el-tag type="info" size="small">{{ getModuleText(row.module) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作内容" min-width="200">
          <template #default="{ row }">
            <el-tooltip :content="getLogContent(row)" placement="top" :show-after="300">
              <span class="log-content">{{ getLogContent(row) }}</span>
            </el-tooltip>
          </template>
        </el-table-column>
        <el-table-column label="IP地址" width="140">
          <template #default="{ row }">
            <code class="ip-address">{{ row.ipAddress || '未知' }}</code>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="80" align="center">
          <template #default="{ row }">
            <el-button type="primary" link @click="viewLogDetail(row)">详情</el-button>
          </template>
        </el-table-column>
        <template #empty>
          <el-empty description="暂无审计日志" />
        </template>
      </el-table>

      <div class="pagination-container">
        <span class="total-text">共 {{ totalLogs }} 条记录</span>
        <el-pagination
          v-model:current-page="currentPage"
          :page-size="pageSize"
          :total="totalLogs"
          layout="prev, pager, next"
          @current-change="loadAuditLogs"
        />
      </div>
    </el-card>

    <el-dialog v-model="showDetailDialog" title="审计日志详情" width="700px">
      <div v-if="selectedLog" class="log-detail">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="操作时间">{{ formatDateTime(selectedLog.createTime) }}</el-descriptions-item>
          <el-descriptions-item label="操作用户">{{ selectedLog.username || '未知' }}</el-descriptions-item>
          <el-descriptions-item label="用户角色">{{ selectedLog.userRole || '未登录' }}</el-descriptions-item>
          <el-descriptions-item label="操作类型">
            <el-tag :type="getActionTagType(selectedLog.action)" size="small">
              {{ getActionTypeText(selectedLog.action) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="操作模块">
            <el-tag type="info" size="small">{{ getModuleText(selectedLog.module) }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="IP地址">{{ selectedLog.ipAddress || '未知' }}</el-descriptions-item>
        </el-descriptions>

        <div v-if="selectedLog.entityId" class="detail-section">
          <h4 class="section-title">操作对象</h4>
          <p class="section-content">
            {{ selectedLog.entityType || '未指定' }} - ID: {{ selectedLog.entityId }}
            <span v-if="selectedLog.entityName"> ({{ selectedLog.entityName }})</span>
          </p>
        </div>

        <div class="detail-section">
          <h4 class="section-title">请求信息</h4>
          <div class="request-info">
            <p><strong>方法:</strong> {{ selectedLog.method || '未知' }}</p>
            <p><strong>URL:</strong> {{ selectedLog.requestUrl || '未知' }}</p>
            <p><strong>HTTP方法:</strong> {{ selectedLog.requestMethod || '未知' }}</p>
            <div v-if="selectedLog.requestParams">
              <strong>请求参数:</strong>
              <pre class="params-json">{{ formatJson(selectedLog.requestParams) }}</pre>
            </div>
          </div>
        </div>

        <div v-if="selectedLog.errorMessage" class="detail-section">
          <h4 class="section-title error-title">错误信息</h4>
          <p class="error-content">{{ selectedLog.errorMessage }}</p>
        </div>
      </div>
      <template #footer>
        <el-button @click="showDetailDialog = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Download, User, Delete } from '@element-plus/icons-vue'
import { auditLogsApi, type AuditLog } from '@/api/auditLogs'
import { systemApi } from '@/api/system'

const loading = ref(false)
const exporting = ref(false)
const deleting = ref(false)
const currentPage = ref(1)
const pageSize = 20
const totalLogs = ref(0)

const filters = reactive({
  action: '',
  module: ''
})

const auditLogs = ref<AuditLog[]>([])

const showDetailDialog = ref(false)
const selectedLog = ref<AuditLog | null>(null)

const loadAuditLogs = async () => {
  loading.value = true
  try {
    const result = await auditLogsApi.query({
      action: filters.action || undefined,
      module: filters.module || undefined,
      page: currentPage.value,
      pageSize: pageSize
    })
    auditLogs.value = result.records || []
    totalLogs.value = result.total || 0
  } catch (error) {
    console.error('加载审计日志失败:', error)
    auditLogs.value = []
    totalLogs.value = 0
  } finally {
    loading.value = false
  }
}

watch([() => filters.action, () => filters.module], () => {
  currentPage.value = 1
  loadAuditLogs()
})

const handleSearch = () => {
  currentPage.value = 1
  loadAuditLogs()
}

const resetFilters = () => {
  filters.action = ''
  filters.module = ''
  currentPage.value = 1
  loadAuditLogs()
}

const getActionTypeText = (type: string) => {
  const typeMap: Record<string, string> = {
    CREATE: '新增',
    UPDATE: '修改',
    DELETE: '删除',
    QUERY: '查询',
    LOGIN: '登录',
    LOGOUT: '登出',
    EXPORT: '导出',
    IMPORT: '导入',
    RESET: '重置',
    OTHER: '其他'
  }
  return typeMap[type] || type || '未知'
}

const getActionTagType = (type: string) => {
  const typeMap: Record<string, string> = {
    CREATE: 'success',
    UPDATE: '',
    DELETE: 'danger',
    QUERY: 'info',
    LOGIN: 'warning',
    EXPORT: '',
    RESET: 'warning'
  }
  return typeMap[type] || 'info'
}

const getModuleText = (module: string) => {
  const moduleMap: Record<string, string> = {
    station: '水站',
    driver: '司机',
    warehouse: '仓库',
    product: '产品',
    order: '订单',
    policy: '政策',
    region: '地域',
    finance: '财务',
    report: '报表',
    inventory: '库存',
    system: '系统',
    audit: '审计'
  }
  return moduleMap[module] || module || '未知'
}

const getLogContent = (log: AuditLog) => {
  if (log.requestUrl) return `${log.requestMethod || 'GET'} ${log.requestUrl}`
  if (log.entityType && log.entityId) return `${log.entityType} ${log.entityId}`
  return log.method || '未知操作'
}

const formatDateTime = (dateTimeStr: string) => {
  if (!dateTimeStr) return '未知时间'
  const date = new Date(dateTimeStr)
  return date.toLocaleString('zh-CN')
}

const formatJson = (str: string) => {
  try {
    return JSON.stringify(JSON.parse(str), null, 2)
  } catch {
    return str
  }
}

const viewLogDetail = (log: AuditLog) => {
  selectedLog.value = log
  showDetailDialog.value = true
}

const handleExport = async () => {
  exporting.value = true
  try {
    const blob = await systemApi.exportAuditLogs({
      actionType: filters.action || undefined
    }) as unknown as Blob

    if (blob) {
      const url = window.URL.createObjectURL(blob)
      const link = document.createElement('a')
      link.href = url
      link.download = `审计日志_${new Date().toISOString().split('T')[0]}.xlsx`
      document.body.appendChild(link)
      link.click()
      document.body.removeChild(link)
      window.URL.revokeObjectURL(url)
      ElMessage.success('导出成功')
    }
  } catch (error) {
    console.error('导出审计日志失败:', error)
    ElMessage.error('导出失败，请重试')
  } finally {
      exporting.value = false
    }
  }

const handleDeleteAll = async () => {
  try {
    await ElMessageBox.confirm(
      '确定要删除所有审计日志吗？此操作不可恢复！',
      '危险操作确认',
      {
        confirmButtonText: '确定删除',
        cancelButtonText: '取消',
        type: 'warning',
        confirmButtonClass: 'el-button--danger'
      }
    )
  } catch {
    return
  }

  deleting.value = true
  try {
    const result = await auditLogsApi.deleteAll()
    if (result) {
      ElMessage.success(`成功删除 ${result.deletedCount || 0} 条日志`)
      loadAuditLogs()
    }
  } catch (error) {
    console.error('删除日志失败:', error)
    ElMessage.error('删除失败，请重试')
  } finally {
    deleting.value = false
  }
}

onMounted(() => {
  loadAuditLogs()
})
</script>

<style scoped>
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.header-actions {
  display: flex;
  gap: 12px;
}

.page-title {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
  margin: 0;
}

.page-desc {
  font-size: 14px;
  color: #909399;
  margin: 4px 0 0 0;
}

.filter-form {
  margin-bottom: 20px;
}

.log-time {
  font-size: 13px;
  color: #606266;
}

.operator-cell {
  display: flex;
  align-items: center;
  gap: 10px;
}

.operator-avatar {
  width: 36px;
  height: 36px;
  background: #ecf5ff;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.operator-info {
  display: flex;
  flex-direction: column;
}

.operator-name {
  font-weight: 500;
  color: #303133;
  font-size: 14px;
}

.operator-role {
  font-size: 12px;
  color: #909399;
}

.log-content {
  font-size: 13px;
  color: #606266;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  display: block;
  max-width: 300px;
}

.ip-address {
  font-family: monospace;
  font-size: 12px;
  background: #f5f5f5;
  padding: 2px 6px;
  border-radius: 4px;
  color: #909399;
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

.log-detail {
  padding: 10px 0;
}

.detail-section {
  margin-top: 20px;
}

.section-title {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
  margin: 0 0 12px 0;
}

.section-content {
  font-size: 14px;
  color: #606266;
  margin: 0;
}

.request-info {
  background: #f5f7fa;
  padding: 16px;
  border-radius: 8px;
  font-size: 13px;
  color: #606266;
}

.request-info p {
  margin: 0 0 8px 0;
}

.request-info p:last-child {
  margin-bottom: 0;
}

.params-json {
  background: #fff;
  padding: 12px;
  border-radius: 4px;
  margin-top: 8px;
  font-family: monospace;
  font-size: 12px;
  overflow-x: auto;
}

.error-title {
  color: #f56c6c;
}

.error-content {
  background: #fef0f0;
  color: #f56c6c;
  padding: 12px;
  border-radius: 8px;
  font-size: 13px;
  margin: 0;
}
</style>
