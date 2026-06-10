<template>
  <div class="dispute-container">
    <el-page-header @back="goBack" class="mb-4">
      <template #content>
        <div class="page-header-content">
          <span class="page-title">提交异议</span>
          <el-breadcrumb separator="/">
            <el-breadcrumb-item :to="{ path: '/station/statements' }">对账单</el-breadcrumb-item>
            <el-breadcrumb-item>提交异议</el-breadcrumb-item>
          </el-breadcrumb>
        </div>
      </template>
    </el-page-header>

    <el-card shadow="never" class="dispute-card">
      <template #header>
        <div class="card-header">
          <el-icon class="header-icon"><Warning /></el-icon>
          <div class="header-text">
            <h3 class="header-title">对账单异议</h3>
            <p class="header-desc">如对账单有疑问，请在此提交异议</p>
          </div>
        </div>
      </template>

      <el-form :model="disputeForm" label-width="100px" class="dispute-form">
        <el-form-item label="对账月份">
          <span class="month-label">{{ currentYear }}年{{ currentMonth }}月</span>
        </el-form-item>

        <el-form-item label="异议原因" required>
          <el-input
            v-model="disputeForm.reason"
            type="textarea"
            :rows="6"
            placeholder="请详细描述您对对账单的异议，包括具体的订单号、金额等信息..."
            maxlength="500"
            show-word-limit
          />
        </el-form-item>

        <el-form-item label="联系电话">
          <el-input
            v-model="disputeForm.contactPhone"
            placeholder="请输入联系电话（选填）"
          />
        </el-form-item>

        <el-divider />

        <div class="info-box">
          <el-icon class="info-icon"><InfoFilled /></el-icon>
          <div class="info-content">
            <p class="info-title">温馨提示</p>
            <ul class="info-list">
              <li>1. 请详细描述异议内容，以便水厂快速核实</li>
              <li>2. 提交后，水厂将在3个工作日内处理</li>
              <li>3. 如有相关凭证，请准备好以便核实</li>
            </ul>
          </div>
        </div>

        <div class="form-actions">
          <el-button @click="goBack">取消</el-button>
          <el-button type="primary" :loading="submitting" @click="handleSubmit">
            <el-icon v-if="!submitting"><Check /></el-icon>
            提交异议
          </el-button>
        </div>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Warning, InfoFilled, Check } from '@element-plus/icons-vue'
import { stationOwnerApi } from '@/api'

const router = useRouter()

const submitting = ref(false)

const now = new Date()
const currentYear = now.getFullYear()
const currentMonth = now.getMonth() + 1

const disputeForm = reactive({
  reason: '',
  contactPhone: ''
})

const goBack = () => {
  router.push('/station/statements')
}

const handleSubmit = async () => {
  if (!disputeForm.reason || disputeForm.reason.trim().length === 0) {
    ElMessage.warning('请输入异议原因')
    return
  }

  if (disputeForm.reason.length < 10) {
    ElMessage.warning('异议原因描述太简单，请详细说明')
    return
  }

  submitting.value = true

  try {
    const month = `${currentYear}-${String(currentMonth).padStart(2, '0')}`
    await stationOwnerApi.disputeStatement(month, disputeForm.reason)

    ElMessage.success('异议提交成功，水厂将在3个工作日内处理')
    router.push('/station/statements')
  } catch (error) {
    console.error('提交异议失败:', error)
    ElMessage.error('提交异议失败，请重试')
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped>
.dispute-container {
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

.dispute-card {
  max-width: 700px;
}

.card-header {
  display: flex;
  align-items: center;
  gap: 12px;
}

.header-icon {
  font-size: 32px;
  color: #e6a23c;
  background: #fdf6ec;
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

.dispute-form {
  padding: 0 20px;
}

.month-label {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
}

.info-box {
  display: flex;
  gap: 16px;
  padding: 16px;
  background: #ecf5ff;
  border-radius: 12px;
}

.info-icon {
  color: #409eff;
  font-size: 20px;
}

.info-content {
  flex: 1;
}

.info-title {
  font-weight: 600;
  color: #303133;
  margin: 0 0 8px 0;
}

.info-list {
  margin: 0;
  padding-left: 20px;
  color: #606266;
  font-size: 14px;
  line-height: 1.8;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 16px;
  padding-top: 24px;
}
</style>
