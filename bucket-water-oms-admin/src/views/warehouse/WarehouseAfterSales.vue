<template>
  <div class="warehouse-after-sales">
    <el-card shadow="never" class="mb-4">
      <template #header>
        <div>
          <h2 class="page-title">售后处理</h2>
          <p class="page-desc">处理水站提交的售后申请</p>
        </div>
      </template>
      <el-radio-group v-model="activeTab" @change="handleTabChange">
        <el-radio-button value="pending">
          待处理
          <el-badge :value="tabs[0].badge" :hidden="tabs[0].badge === 0" />
        </el-radio-button>
        <el-radio-button value="processing">
          处理中
          <el-badge :value="tabs[1].badge" :hidden="tabs[1].badge === 0" />
        </el-radio-button>
        <el-radio-button value="completed">已完成</el-radio-button>
      </el-radio-group>
    </el-card>

    <div v-loading="loading">
      <el-card v-for="item in afterSalesList" :key="item.id" shadow="never" class="after-sales-card">
        <template #header>
          <div class="card-header">
            <div class="card-title">
              <el-badge is-dot :hidden="item.status !== 'pending'" />
              <span class="ticket-no">{{ item.ticketNo }}</span>
            </div>
            <div class="card-actions">
              <el-tag :type="getTypeTagType(item.type)" size="small">
                {{ item.typeText || getTypeText(item.type) }}
              </el-tag>
              <el-tag :type="getStatusType(item.status)" size="small">
                {{ item.statusText || getStatusText(item.status) }}
              </el-tag>
            </div>
          </div>
        </template>

        <div class="station-section">
          <div class="station-info">
            <el-avatar :size="40" :icon="Shop" />
            <div class="station-details">
              <p class="station-name">{{ item.stationName }}</p>
              <p class="station-address">{{ item.stationAddress }}</p>
            </div>
          </div>
        </div>

        <div class="order-section">
          <p class="section-label">关联订单: {{ item.orderNo }}</p>
          <el-table :data="item.items" size="small">
            <el-table-column prop="productName" label="商品名称" />
            <el-table-column prop="quantity" label="数量" align="right">
              <template #default="{ row }">
                {{ row.quantity }} 件
              </template>
            </el-table-column>
          </el-table>
        </div>

        <div class="reason-section">
          <el-icon class="reason-icon"><WarningFilled /></el-icon>
          <span class="reason-text">原因: {{ item.reason }}</span>
        </div>

        <div class="action-buttons">
          <el-button v-if="item.status === 'pending'" type="success" @click="showProcessDialog(item)">
            处理申请
          </el-button>
          <el-button circle>
            <el-icon><Phone /></el-icon>
          </el-button>
        </div>
      </el-card>

      <el-empty v-if="afterSalesList.length === 0" description="暂无售后记录" :image-size="100" />
    </div>

    <el-dialog v-model="processDialogVisible" title="处理售后申请" width="500px">
      <el-form :model="processForm" label-width="100px">
        <el-form-item label="处理方式">
          <el-radio-group v-model="processForm.action">
            <el-radio value="approve">同意售后</el-radio>
            <el-radio value="reject">拒绝售后</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="处理说明">
          <el-input v-model="processForm.remark" type="textarea" :rows="4" placeholder="请输入处理说明" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="processDialogVisible = false">取消</el-button>
        <el-button type="success" @click="handleProcess">确认</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { warehouseApi } from '@/api'
import { toast } from '@/composables/useToast'
import { Shop, Phone, WarningFilled } from '@element-plus/icons-vue'
import type { AfterSalesDTO } from '@/api/warehouse'

const activeTab = ref('pending')
const loading = ref(false)

const tabs = [
  { key: 'pending', label: '待处理', badge: 0 },
  { key: 'processing', label: '处理中', badge: 0 },
  { key: 'completed', label: '已完成', badge: null as number | null }
]

const afterSalesList = ref<AfterSalesDTO[]>([])
const processDialogVisible = ref(false)
const selectedAfterSales = ref<AfterSalesDTO | null>(null)
const processForm = ref({
  action: 'approve',
  remark: ''
})

const getTypeText = (type: string) => {
  const map: Record<string, string> = {
    replenishment: '补货申请',
    refund: '退款申请',
    quality: '质量问题'
  }
  return map[type] || type
}

const getTypeTagType = (type: string) => {
  const typeMap: Record<string, string> = {
    replenishment: 'warning',
    refund: 'primary',
    quality: 'danger'
  }
  return typeMap[type] || 'info'
}

const getStatusText = (status: string) => {
  const map: Record<string, string> = {
    pending: '待处理',
    processing: '处理中',
    approved: '已同意',
    rejected: '已拒绝',
    completed: '已完成'
  }
  return map[status] || status
}

const getStatusType = (status: string) => {
  const typeMap: Record<string, string> = {
    pending: 'danger',
    processing: 'primary',
    approved: 'success',
    rejected: 'info',
    completed: 'success'
  }
  return typeMap[status] || 'info'
}

const handleTabChange = () => {
  fetchAfterSalesList()
}

const fetchAfterSalesList = async () => {
  loading.value = true
  try {
    const params: any = {}
    if (activeTab.value !== 'all') {
      params.status = activeTab.value
    }
    const res: any = await warehouseApi.getAfterSalesList(params)
    const salesData = res.data || res || []
    afterSalesList.value = Array.isArray(salesData) ? salesData : (salesData.records || [])

    const allRes: any = await warehouseApi.getAfterSalesList()
    const allData = allRes.data || allRes || []
    const allList = Array.isArray(allData) ? allData : (allData.records || [])
    tabs[0].badge = allList.filter((item: any) => item.status === 'pending').length
    tabs[1].badge = allList.filter((item: any) => item.status === 'processing').length
  } catch (error: any) {
    console.error('获取售后列表失败:', error)
    toast.error('获取售后列表失败')
  } finally {
    loading.value = false
  }
}

const showProcessDialog = (item: AfterSalesDTO) => {
  selectedAfterSales.value = item
  processForm.value = {
    action: 'approve',
    remark: ''
  }
  processDialogVisible.value = true
}

const handleProcess = async () => {
  if (!selectedAfterSales.value) return
  try {
    await warehouseApi.processAfterSales(selectedAfterSales.value.id, {
      action: processForm.value.action,
      approved: processForm.value.action === 'approve',
      remark: processForm.value.remark
    })
    toast.success(processForm.value.action === 'approve' ? '已同意售后' : '已拒绝售后')
    processDialogVisible.value = false
    fetchAfterSalesList()
  } catch (error: any) {
    toast.error('处理失败: ' + (error.message || ''))
  }
}

onMounted(() => {
  fetchAfterSalesList()
})
</script>

<style scoped>
.warehouse-after-sales {
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

.after-sales-card {
  margin-bottom: 16px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-title {
  display: flex;
  align-items: center;
  gap: 8px;
}

.ticket-no {
  font-weight: bold;
  color: #303133;
}

.card-actions {
  display: flex;
  gap: 8px;
}

.station-section {
  padding: 16px 0;
  border-bottom: 1px solid #f5f7fa;
}

.station-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.station-name {
  font-size: 14px;
  font-weight: 500;
  color: #303133;
  margin: 0;
}

.station-address {
  font-size: 12px;
  color: #909399;
  margin: 4px 0 0;
}

.order-section {
  padding: 16px 0;
  border-bottom: 1px solid #f5f7fa;
}

.section-label {
  font-size: 12px;
  color: #909399;
  margin: 0 0 12px;
}

.reason-section {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px;
  background: #fdf6ec;
  border-radius: 8px;
  margin: 16px 0;
}

.reason-icon {
  color: #e6a23c;
  font-size: 18px;
}

.reason-text {
  font-size: 12px;
  color: #e6a23c;
}

.action-buttons {
  display: flex;
  gap: 12px;
}
</style>
