<template>
  <div class="warehouse-return-check">
    <el-card shadow="never" class="mb-4">
      <template #header>
        <div>
          <h2 class="page-title">回仓核对</h2>
          <p class="page-desc">处理司机回仓申请，核对空桶数量</p>
        </div>
      </template>
      <el-radio-group v-model="activeTab" @change="handleTabChange">
        <el-radio-button value="pending">
          待核对
          <el-badge :value="tabs[0].badge" :hidden="tabs[0].badge === 0" />
        </el-radio-button>
        <el-radio-button value="confirmed">已核对</el-radio-button>
        <el-radio-button value="diff">差异记录</el-radio-button>
      </el-radio-group>
    </el-card>

    <div v-loading="loading">
      <el-card v-for="item in returnList" :key="item.id" shadow="never" class="return-card" :class="{ pending: item.status === 'pending' }">
        <template #header>
          <div class="card-header">
            <div class="card-title">
              <el-badge is-dot :hidden="item.status !== 'pending'" />
              <span class="return-no">{{ item.returnNo }}</span>
            </div>
            <div class="card-actions">
              <el-tag :type="getStatusType(item.status)" size="small">
                {{ item.statusText || getStatusText(item.status) }}
              </el-tag>
              <el-tag size="small" type="info">{{ formatTime(item.createdAt) }}</el-tag>
            </div>
          </div>
        </template>

        <div class="driver-section">
          <div class="driver-info">
            <el-avatar :size="48" :icon="UserFilled" />
            <div class="driver-details">
              <p class="driver-name">{{ item.driverName }}</p>
              <p class="driver-code">工号: {{ item.driverCode || '-' }}</p>
            </div>
          </div>
          <el-button circle type="success">
            <el-icon><Phone /></el-icon>
          </el-button>
        </div>

        <el-row :gutter="16" class="info-row">
          <el-col :span="12">
            <div class="info-card">
              <p class="info-label">关联订单</p>
              <p class="info-value">{{ item.orderNo || '-' }}</p>
            </div>
          </el-col>
          <el-col :span="12">
            <div class="info-card">
              <p class="info-label">送达时间</p>
              <p class="info-value">{{ formatTime(item.checkedAt) }}</p>
            </div>
          </el-col>
        </el-row>

        <div class="quantity-section">
          <div class="quantity-item">
            <el-icon class="quantity-icon"><Box /></el-icon>
            <span class="quantity-label">司机上报回收空桶</span>
            <span class="quantity-value blue">{{ item.bucketReturned || 0 }} 个</span>
          </div>
          <div v-if="item.difference !== 0" class="quantity-item">
            <el-icon class="quantity-icon warning"><WarningFilled /></el-icon>
            <span class="quantity-label">差异</span>
            <span class="quantity-value orange">{{ item.difference }} 个</span>
          </div>
        </div>

        <div class="action-buttons">
          <el-button v-if="item.status === 'pending'" type="primary" @click="showCheckDialog(item)">
            核对空桶
          </el-button>
          <el-button>
            <el-icon><Printer /></el-icon>
          </el-button>
        </div>
      </el-card>

      <el-empty v-if="returnList.length === 0" description="暂无回仓记录" :image-size="100" />
    </div>

    <el-dialog v-model="checkDialogVisible" title="空桶核对" width="500px">
      <div class="check-dialog-content">
        <div class="check-summary">
          <p class="summary-label">司机上报回收</p>
          <p class="summary-value blue">{{ selectedReturn?.bucketReturned || 0 }} 个</p>
        </div>
        <el-form :model="checkForm" label-width="120px">
          <el-form-item label="仓库实收数量">
            <el-input-number v-model="checkForm.actualBucketQty" :min="0" />
          </el-form-item>
          <el-form-item label="差异">
            <span :class="['difference-value', { positive: difference > 0, negative: difference < 0 }]">
              {{ difference }} 个
            </span>
          </el-form-item>
          <el-form-item label="备注">
            <el-input v-model="checkForm.remark" type="textarea" :rows="3" placeholder="请输入备注（可选）" />
          </el-form-item>
        </el-form>
      </div>
      <template #footer>
        <el-button @click="checkDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleCheck">确认</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { warehouseApi } from '@/api'
import { toast } from '@/composables/useToast'
import { UserFilled, Phone, Box, Printer, WarningFilled } from '@element-plus/icons-vue'
import type { DriverReturnDTO } from '@/api/warehouse'

const activeTab = ref('pending')
const loading = ref(false)

const tabs = [
  { key: 'pending', label: '待核对', badge: 0 },
  { key: 'confirmed', label: '已核对', badge: null as number | null },
  { key: 'diff', label: '差异记录', badge: null }
]

const returnList = ref<DriverReturnDTO[]>([])
const checkDialogVisible = ref(false)
const selectedReturn = ref<DriverReturnDTO | null>(null)
const checkForm = ref({
  actualBucketQty: 0,
  remark: ''
})

const difference = computed(() => {
  return (selectedReturn.value?.bucketReturned || 0) - checkForm.value.actualBucketQty
})

const getStatusText = (status: string) => {
  const map: Record<string, string> = {
    pending: '待核对',
    confirmed: '已核对',
    disputed: '有差异'
  }
  return map[status] || status
}

const getStatusType = (status: string) => {
  const typeMap: Record<string, string> = {
    pending: 'danger',
    confirmed: 'success',
    disputed: 'warning'
  }
  return typeMap[status] || 'info'
}

const formatTime = (time: string) => {
  if (!time) return '-'
  const date = new Date(time)
  return date.toLocaleString('zh-CN')
}

const handleTabChange = () => {
  fetchReturnList()
}

const fetchReturnList = async () => {
  loading.value = true
  try {
    const res: any = await warehouseApi.getPendingReturns()
    const returnData = res.data || res || []
    let filteredList = Array.isArray(returnData) ? returnData : []
    if (activeTab.value !== 'all') {
      if (activeTab.value === 'diff') {
        filteredList = filteredList.filter((item: any) => item.status === 'disputed')
      } else {
        filteredList = filteredList.filter((item: any) => item.status === activeTab.value)
      }
    }
    returnList.value = filteredList
    tabs[0].badge = filteredList.filter((item: any) => item.status === 'pending').length
  } catch (error: any) {
    console.error('获取回仓列表失败:', error)
    toast.error('获取回仓列表失败')
  } finally {
    loading.value = false
  }
}

const showCheckDialog = (item: DriverReturnDTO) => {
  selectedReturn.value = item
  checkForm.value = {
    actualBucketQty: item.bucketReturned || 0,
    remark: ''
  }
  checkDialogVisible.value = true
}

const handleCheck = async () => {
  if (!selectedReturn.value) return
  try {
    await warehouseApi.checkReturn(selectedReturn.value.id, {
      actualBucketQty: checkForm.value.actualBucketQty,
      differenceReason: checkForm.value.remark
    })
    toast.success('核对成功')
    checkDialogVisible.value = false
    fetchReturnList()
  } catch (error: any) {
    toast.error('核对失败: ' + (error.message || ''))
  }
}

onMounted(() => {
  fetchReturnList()
})
</script>

<style scoped>
.warehouse-return-check {
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

.return-card {
  margin-bottom: 16px;
}

.return-card.pending {
  border-left: 3px solid #f56c6c;
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

.return-no {
  font-weight: bold;
  color: #303133;
}

.card-actions {
  display: flex;
  gap: 8px;
}

.driver-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 0;
  border-bottom: 1px solid #f5f7fa;
}

.driver-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.driver-name {
  font-size: 16px;
  font-weight: 500;
  color: #303133;
  margin: 0;
}

.driver-code {
  font-size: 12px;
  color: #909399;
  margin: 4px 0 0;
}

.info-row {
  margin: 16px 0;
}

.info-card {
  background: #f5f7fa;
  padding: 12px;
  border-radius: 8px;
  text-align: center;
}

.info-label {
  font-size: 12px;
  color: #909399;
  margin: 0 0 4px;
}

.info-value {
  font-size: 14px;
  font-weight: 500;
  color: #303133;
  margin: 0;
}

.quantity-section {
  margin-bottom: 16px;
}

.quantity-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: #ecf5ff;
  border-radius: 8px;
  margin-bottom: 8px;
}

.quantity-item:last-child {
  margin-bottom: 0;
  background: #fdf6ec;
}

.quantity-icon {
  font-size: 20px;
}

.quantity-icon.blue {
  color: #409eff;
}

.quantity-icon.warning {
  color: #e6a23c;
}

.quantity-label {
  flex: 1;
  font-size: 14px;
  color: #606266;
}

.quantity-value {
  font-size: 18px;
  font-weight: bold;
}

.quantity-value.blue {
  color: #409eff;
}

.quantity-value.orange {
  color: #e6a23c;
}

.action-buttons {
  display: flex;
  gap: 12px;
}

.check-dialog-content {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.check-summary {
  background: #ecf5ff;
  padding: 16px;
  border-radius: 8px;
  text-align: center;
}

.summary-label {
  font-size: 14px;
  color: #606266;
  margin: 0 0 4px;
}

.summary-value {
  font-size: 28px;
  font-weight: bold;
  margin: 0;
}

.summary-value.blue {
  color: #409eff;
}

.difference-value {
  font-size: 18px;
  font-weight: bold;
}

.difference-value.positive {
  color: #f56c6c;
}

.difference-value.negative {
  color: #67c23a;
}
</style>
