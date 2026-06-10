<template>
  <div class="check-container">
    <el-page-header @back="goBack" class="mb-4">
      <template #content>
        <div class="page-header-content">
          <span class="page-title">回仓核对</span>
          <el-breadcrumb separator="/">
            <el-breadcrumb-item :to="{ path: '/warehouse/return-check' }">回仓核对</el-breadcrumb-item>
            <el-breadcrumb-item>核对详情</el-breadcrumb-item>
          </el-breadcrumb>
        </div>
      </template>
    </el-page-header>

    <el-card v-if="returnData.id" shadow="never" class="check-card">
      <template #header>
        <div class="card-header">
          <div class="header-left">
            <el-icon class="header-icon"><SuccessFilled /></el-icon>
            <div class="header-text">
              <h3 class="header-title">空桶核对</h3>
              <p class="header-desc">{{ returnData.returnNo }}</p>
            </div>
          </div>
          <el-tag :type="getStatusType(returnData.status)" size="large">
            {{ returnData.statusText || getStatusText(returnData.status) }}
          </el-tag>
        </div>
      </template>

      <div class="driver-section">
        <h4 class="section-title">司机信息</h4>
        <el-descriptions :column="2" border>
          <el-descriptions-item label="司机姓名">{{ returnData.driverName }}</el-descriptions-item>
          <el-descriptions-item label="工号">{{ returnData.driverCode || '-' }}</el-descriptions-item>
          <el-descriptions-item label="联系电话">
            <span class="phone-link">{{ returnData.driverPhone || '-' }}</span>
          </el-descriptions-item>
          <el-descriptions-item label="关联订单">{{ returnData.orderNo || '-' }}</el-descriptions-item>
        </el-descriptions>
      </div>

      <el-divider />

      <div class="quantity-section">
        <h4 class="section-title">回仓信息</h4>

        <el-row :gutter="20">
          <el-col :span="12">
            <div class="quantity-card">
              <div class="quantity-icon blue">
                <el-icon><Box /></el-icon>
              </div>
              <div class="quantity-content">
                <p class="quantity-label">司机上报回收</p>
                <p class="quantity-value blue">{{ returnData.bucketReturned || 0 }} 个</p>
              </div>
            </div>
          </el-col>
          <el-col v-if="returnData.status !== 'pending'" :span="12">
            <div class="quantity-card">
              <div class="quantity-icon green">
                <el-icon><CircleCheck /></el-icon>
              </div>
              <div class="quantity-content">
                <p class="quantity-label">仓库实收</p>
                <p class="quantity-value green">{{ returnData.actualBucketQty || 0 }} 个</p>
              </div>
            </div>
          </el-col>
        </el-row>

        <div v-if="returnData.status !== 'pending'" class="difference-section">
          <el-alert
            :title="getDifferenceAlert()"
            :type="getDifferenceType()"
            :closable="false"
            show-icon
          />
        </div>
      </div>

      <el-divider />

      <div v-if="returnData.status === 'pending'" class="check-form">
        <h4 class="section-title">核对信息</h4>

        <el-form :model="checkForm" label-width="120px">
          <el-form-item label="仓库实收数量" required>
            <el-input-number
              v-model="checkForm.actualBucketQty"
              :min="0"
              style="width: 100%"
            />
          </el-form-item>

          <el-form-item label="差异">
            <span :class="['difference-value', getDifferenceClass()]">
              {{ difference }} 个
            </span>
          </el-form-item>

          <el-form-item label="备注">
            <el-input
              v-model="checkForm.remark"
              type="textarea"
              :rows="3"
              placeholder="请输入备注（可选）"
            />
          </el-form-item>
        </el-form>

        <div class="action-buttons">
          <el-button size="large" @click="goBack">取消</el-button>
          <el-button type="primary" size="large" :loading="submitting" @click="handleCheck">
            <el-icon><Check /></el-icon>
            确认核对
          </el-button>
        </div>
      </div>

      <div v-else class="info-section">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="核对时间">
            {{ returnData.checkedAt || returnData.createTime }}
          </el-descriptions-item>
          <el-descriptions-item v-if="returnData.remark" label="备注">
            {{ returnData.remark }}
          </el-descriptions-item>
        </el-descriptions>

        <div class="action-buttons">
          <el-button size="large" @click="goBack">返回列表</el-button>
          <el-button type="default" size="large">
            <el-icon><Printer /></el-icon>
            打印回仓单
          </el-button>
        </div>
      </div>
    </el-card>

    <div v-else class="loading-container">
      <el-icon class="is-loading loading-icon"><Loading /></el-icon>
      <p class="loading-text">加载回仓信息...</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Loading, SuccessFilled, Box, CircleCheck, Check, Printer } from '@element-plus/icons-vue'
import { warehouseApi } from '@/api'

const router = useRouter()
const route = useRoute()

const submitting = ref(false)
const loading = ref(false)

const returnData = ref<any>({})

const checkForm = ref({
  actualBucketQty: 0,
  remark: ''
})

const difference = computed(() => {
  return (returnData.value?.bucketReturned || 0) - checkForm.value.actualBucketQty
})

const goBack = () => {
  router.push('/warehouse/return-check')
}

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

const getDifferenceAlert = () => {
  if (difference.value === 0) {
    return '数量一致，无需处理'
  } else if (difference.value > 0) {
    return `仓库少收了 ${difference.value} 个空桶`
  } else {
    return `仓库多收了 ${Math.abs(difference.value)} 个空桶`
  }
}

const getDifferenceType = () => {
  if (difference.value === 0) return 'success'
  if (difference.value > 0) return 'warning'
  return 'info'
}

const getDifferenceClass = () => {
  if (difference.value === 0) return 'green'
  if (difference.value > 0) return 'orange'
  return 'blue'
}

const loadReturn = async () => {
  const returnId = route.params.id as string
  if (!returnId) {
    ElMessage.error('回仓ID不能为空')
    router.push('/warehouse/return-check')
    return
  }

  loading.value = true
  try {
    const res: any = await warehouseApi.getReturnCheckDetail(returnId)
    const detailData = res.data || res
    if (detailData) {
      returnData.value = detailData
      if (detailData.status === 'pending') {
        checkForm.value = {
          actualBucketQty: detailData.bucketReturned || 0,
          remark: ''
        }
      }
    }
  } catch (error) {
    console.error('获取回仓详情失败:', error)
    ElMessage.error('获取回仓详情失败')
  } finally {
    loading.value = false
  }
}

const handleCheck = async () => {
  submitting.value = true
  try {
    await warehouseApi.confirmReturnCheck(returnData.value.id, {
      actualBuckets: checkForm.value.actualBucketQty,
      remark: checkForm.value.remark
    })
    ElMessage.success('核对成功')
    router.push('/warehouse/return-check')
  } catch (error) {
    console.error('核对失败:', error)
    ElMessage.error('核对失败，请重试')
  } finally {
    submitting.value = false
  }
}

onMounted(() => {
  loadReturn()
})
</script>

<style scoped>
.check-container {
  padding: 20px;
}

.mb-4 {
  margin-bottom: 16px;
}

.page-header-content {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.page-title {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
}

.check-card {
  max-width: 800px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.header-icon {
  font-size: 32px;
  color: #409eff;
  background: #ecf5ff;
  padding: 12px;
  border-radius: 12px;
}

.header-title {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
  margin: 0 0 4px 0;
}

.header-desc {
  font-size: 12px;
  color: #909399;
  margin: 0;
}

.section-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  margin: 0 0 16px 0;
}

.driver-section {
  margin-bottom: 24px;
}

.phone-link {
  color: #409eff;
}

.quantity-section {
  margin-bottom: 24px;
}

.quantity-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px;
  background: #f5f7fa;
  border-radius: 12px;
}

.quantity-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
}

.quantity-icon.blue {
  background: #ecf5ff;
  color: #409eff;
}

.quantity-icon.green {
  background: #f0f9eb;
  color: #67c23a;
}

.quantity-label {
  font-size: 14px;
  color: #909399;
  margin: 0 0 4px 0;
}

.quantity-value {
  font-size: 24px;
  font-weight: 700;
  margin: 0;
}

.quantity-value.blue {
  color: #409eff;
}

.quantity-value.green {
  color: #67c23a;
}

.difference-section {
  margin-top: 16px;
}

.check-form {
  margin-bottom: 24px;
}

.difference-value {
  font-size: 20px;
  font-weight: 700;
}

.difference-value.green {
  color: #67c23a;
}

.difference-value.orange {
  color: #e6a23c;
}

.difference-value.blue {
  color: #409eff;
}

.action-buttons {
  display: flex;
  justify-content: flex-end;
  gap: 16px;
  margin-top: 24px;
}

.info-section {
  margin-bottom: 24px;
}

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 80px 0;
}

.loading-icon {
  font-size: 48px;
  color: #409eff;
}

.loading-text {
  margin-top: 16px;
  color: #909399;
}
</style>
