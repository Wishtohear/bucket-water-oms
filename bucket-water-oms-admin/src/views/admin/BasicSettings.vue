<template>
  <div>
    <div class="page-header">
      <div>
        <h2 class="page-title">基本设置</h2>
        <p class="page-desc">配置系统基本信息和功能参数</p>
      </div>
    </div>

    <div class="settings-container">
      <el-card shadow="never" class="mb-4">
        <template #header>
          <span class="card-title">基本信息</span>
        </template>
        <el-form :model="basicSettings" label-width="120px" class="max-w-2xl">
          <el-form-item label="系统名称">
            <el-input v-model="basicSettings.systemName" placeholder="请输入系统名称" />
          </el-form-item>
          <el-form-item label="系统Logo">
            <div class="flex items-center gap-4">
              <div class="logo-preview">
                <el-icon size="40" class="text-blue-500"><Watermelon /></el-icon>
              </div>
              <el-button>更换Logo</el-button>
            </div>
          </el-form-item>
          <el-form-item label="联系电话">
            <el-input v-model="basicSettings.contactPhone" placeholder="请输入联系电话" />
          </el-form-item>
          <el-form-item label="联系邮箱">
            <el-input v-model="basicSettings.contactEmail" placeholder="请输入联系邮箱" />
          </el-form-item>
          <el-form-item>
            <el-button @click="resetBasicSettings">重置</el-button>
            <el-button type="primary" @click="saveBasicSettings" :loading="saving">保存设置</el-button>
          </el-form-item>
        </el-form>
      </el-card>

      <el-card shadow="never" class="mb-4">
        <template #header>
          <span class="card-title">对账设置</span>
        </template>
        <el-form :model="statementSettings" label-width="120px" class="max-w-2xl">
          <el-form-item label="固定对账日">
            <el-select v-model="statementSettings.statementDay" style="width: 200px">
              <el-option v-for="day in 28" :key="day" :value="day" :label="`每月${day}日`" />
            </el-select>
            <div class="form-help-text">每月固定日期自动生成上月对账单</div>
          </el-form-item>
          <el-form-item label="对账通知方式">
            <el-checkbox-group v-model="statementSettings.notifyMethods">
              <el-checkbox value="sms">短信通知</el-checkbox>
              <el-checkbox value="wechat">微信通知</el-checkbox>
            </el-checkbox-group>
          </el-form-item>
          <el-form-item>
            <el-button @click="resetStatementSettings">重置</el-button>
            <el-button type="primary" @click="saveStatementSettings" :loading="saving">保存设置</el-button>
          </el-form-item>
        </el-form>
      </el-card>

      <el-card shadow="never" class="mb-4">
        <template #header>
          <span class="card-title">库存设置</span>
        </template>
        <el-form :model="inventorySettings" label-width="120px" class="max-w-2xl">
          <el-form-item label="库存预警阈值">
            <el-input-number v-model="inventorySettings.stockWarningThreshold" :min="0" style="width: 200px" />
            <div class="form-help-text">当库存低于此值时发送预警通知</div>
          </el-form-item>
          <el-form-item label="自动补货提醒">
            <el-switch v-model="inventorySettings.autoReorder" />
            <span class="ml-3 text-gray-600">启用自动补货提醒</span>
          </el-form-item>
          <el-form-item>
            <el-button @click="resetInventorySettings">重置</el-button>
            <el-button type="primary" @click="saveInventorySettings" :loading="saving">保存设置</el-button>
          </el-form-item>
        </el-form>
      </el-card>

      <el-card shadow="never">
        <template #header>
          <span class="card-title">通知设置</span>
        </template>
        <div class="notification-list max-w-2xl">
          <div class="notification-item">
            <div class="notification-info">
              <p class="notification-title">订单状态变更通知</p>
              <p class="notification-desc">当订单状态变更时发送通知</p>
            </div>
            <el-switch v-model="notificationSettings.notifyOrderStatus" />
          </div>
          <div class="notification-item">
            <div class="notification-info">
              <p class="notification-title">库存预警通知</p>
              <p class="notification-desc">当库存低于阈值时发送通知</p>
            </div>
            <el-switch v-model="notificationSettings.notifyStockWarning" />
          </div>
          <div class="notification-item">
            <div class="notification-info">
              <p class="notification-title">欠桶预警通知</p>
              <p class="notification-desc">当水站欠桶达到阈值时发送通知</p>
            </div>
            <el-switch v-model="notificationSettings.notifyBucketOwed" />
          </div>
          <el-form-item>
            <el-button @click="resetNotificationSettings">重置</el-button>
            <el-button type="primary" @click="saveNotificationSettings" :loading="saving">保存设置</el-button>
          </el-form-item>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Watermelon } from '@element-plus/icons-vue'
import { systemApi } from '@/api/system'

const saving = ref(false)

const basicSettings = reactive({
  systemName: '水厂订货管理系统',
  contactPhone: '400-888-8888',
  contactEmail: 'admin@waterfactory.com'
})

const originalBasicSettings = { ...basicSettings }

const statementSettings = reactive({
  statementDay: 1,
  notifyMethods: ['sms', 'wechat'] as string[]
})

const originalStatementSettings = { ...statementSettings }

const inventorySettings = reactive({
  stockWarningThreshold: 100,
  autoReorder: true
})

const originalInventorySettings = { ...inventorySettings }

const notificationSettings = reactive({
  notifyOrderStatus: true,
  notifyStockWarning: true,
  notifyBucketOwed: true
})

const originalNotificationSettings = { ...notificationSettings }

const saveBasicSettings = async () => {
  saving.value = true
  try {
    await systemApi.updateBasicSettings(basicSettings)
    Object.assign(originalBasicSettings, basicSettings)
    ElMessage.success('基本设置保存成功')
  } catch (error) {
    console.error('保存失败:', error)
    ElMessage.error('保存失败，请重试')
  } finally {
    saving.value = false
  }
}

const resetBasicSettings = () => {
  Object.assign(basicSettings, originalBasicSettings)
}

const saveStatementSettings = async () => {
  saving.value = true
  try {
    await systemApi.updateStatementSettings(statementSettings)
    Object.assign(originalStatementSettings, statementSettings)
    ElMessage.success('对账设置保存成功')
  } catch (error) {
    console.error('保存失败:', error)
    ElMessage.error('保存失败，请重试')
  } finally {
    saving.value = false
  }
}

const resetStatementSettings = () => {
  Object.assign(statementSettings, originalStatementSettings)
}

const saveInventorySettings = async () => {
  saving.value = true
  try {
    await systemApi.updateInventorySettings(inventorySettings)
    Object.assign(originalInventorySettings, inventorySettings)
    ElMessage.success('库存设置保存成功')
  } catch (error) {
    console.error('保存失败:', error)
    ElMessage.error('保存失败，请重试')
  } finally {
    saving.value = false
  }
}

const resetInventorySettings = () => {
  Object.assign(inventorySettings, originalInventorySettings)
}

const saveNotificationSettings = async () => {
  saving.value = true
  try {
    await systemApi.updateNotificationSettings({
      orderStatusNotify: notificationSettings.notifyOrderStatus,
      stockWarningNotify: notificationSettings.notifyStockWarning,
      bucketOwedNotify: notificationSettings.notifyBucketOwed
    })
    Object.assign(originalNotificationSettings, notificationSettings)
    ElMessage.success('通知设置保存成功')
  } catch (error) {
    console.error('保存失败:', error)
    ElMessage.error('保存失败，请重试')
  } finally {
    saving.value = false
  }
}

const resetNotificationSettings = () => {
  Object.assign(notificationSettings, originalNotificationSettings)
}

const loadSettings = async () => {
  try {
    const [basic, statement, inventory, notification] = await Promise.all([
      systemApi.getBasicSettings().catch(() => null),
      systemApi.getStatementSettings().catch(() => null),
      systemApi.getInventorySettings().catch(() => null),
      systemApi.getNotificationSettings().catch(() => null)
    ])

    if (basic?.data) {
      Object.assign(basicSettings, basic.data)
      Object.assign(originalBasicSettings, basic.data)
    }
    if (statement?.data) {
      Object.assign(statementSettings, statement.data)
      Object.assign(originalStatementSettings, statement.data)
    }
    if (inventory?.data) {
      Object.assign(inventorySettings, inventory.data)
      Object.assign(originalInventorySettings, inventory.data)
    }
    if (notification?.data) {
      Object.assign(notificationSettings, notification.data)
      Object.assign(originalNotificationSettings, notification.data)
    }
  } catch (error) {
    console.error('加载设置失败:', error)
  }
}

onMounted(() => {
  loadSettings()
})
</script>

<style scoped>
.page-header {
  margin-bottom: 24px;
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

.mb-4 {
  margin-bottom: 20px;
}

.card-title {
  font-weight: 600;
  font-size: 16px;
}

.max-w-2xl {
  max-width: 600px;
}

.logo-preview {
  width: 80px;
  height: 80px;
  background: #ecf5ff;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.form-help-text {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
}

.ml-3 {
  margin-left: 12px;
}

.notification-list {
  display: flex;
  flex-direction: column;
}

.notification-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 0;
  border-bottom: 1px solid #f0f0f0;
}

.notification-item:last-child {
  border-bottom: none;
}

.notification-info {
  flex: 1;
}

.notification-title {
  font-weight: 500;
  color: #303133;
  margin: 0;
}

.notification-desc {
  font-size: 12px;
  color: #909399;
  margin: 4px 0 0 0;
}
</style>
