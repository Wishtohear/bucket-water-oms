<template>
  <div class="warehouse-settings">
    <el-card shadow="never" class="mb-4">
      <template #header>
        <div>
          <h2 class="page-title">仓库设置</h2>
          <p class="page-desc">管理个人信息和企业设置</p>
        </div>
      </template>
    </el-card>

    <div v-if="loading" class="loading-wrapper">
      <el-icon class="is-loading"><Loading /></el-icon>
    </div>

    <div v-else class="settings-content">
      <el-card shadow="never" class="mb-4">
        <template #header>
          <span class="section-title">个人信息</span>
        </template>
        <el-form :model="userInfo" label-width="100px">
          <el-form-item label="头像">
            <el-avatar :size="80" :icon="UserFilled" />
          </el-form-item>
          <el-form-item label="姓名">
            <el-input v-model="userInfo.name" placeholder="请输入姓名" />
          </el-form-item>
          <el-form-item label="手机号">
            <el-input v-model="userInfo.phone" placeholder="请输入手机号" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" :loading="saving" @click="saveUserInfo">
              保存修改
            </el-button>
          </el-form-item>
        </el-form>
      </el-card>

      <el-card shadow="never" class="mb-4">
        <template #header>
          <span class="section-title">修改密码</span>
        </template>
        <el-form :model="passwordForm" label-width="100px">
          <el-form-item label="当前密码">
            <el-input v-model="passwordForm.oldPassword" type="password" placeholder="请输入当前密码" show-password />
          </el-form-item>
          <el-form-item label="新密码">
            <el-input v-model="passwordForm.newPassword" type="password" placeholder="请输入新密码" show-password />
          </el-form-item>
          <el-form-item label="确认新密码">
            <el-input v-model="passwordForm.confirmPassword" type="password" placeholder="请再次输入新密码" show-password />
          </el-form-item>
          <el-form-item>
            <el-button
              type="primary"
              :loading="changingPassword"
              :disabled="!passwordForm.oldPassword || !passwordForm.newPassword || !passwordForm.confirmPassword"
              @click="changePassword"
            >
              修改密码
            </el-button>
          </el-form-item>
        </el-form>
      </el-card>

      <el-card shadow="never" class="mb-4">
        <template #header>
          <span class="section-title">通知设置</span>
        </template>
        <el-form label-width="140px">
          <el-form-item label="新订单提醒">
            <el-switch v-model="notificationSettings.newOrder" />
            <span class="form-tip">当有新的配送订单时发送通知</span>
          </el-form-item>
          <el-form-item label="库存预警">
            <el-switch v-model="notificationSettings.lowStock" />
            <span class="form-tip">当库存低于安全库存时发送通知</span>
          </el-form-item>
          <el-form-item label="司机回仓提醒">
            <el-switch v-model="notificationSettings.driverReturn" />
            <span class="form-tip">当司机发起回仓申请时发送通知</span>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="saveNotificationSettings">
              保存设置
            </el-button>
          </el-form-item>
        </el-form>
      </el-card>

      <el-card shadow="never" class="mb-4">
        <template #header>
          <span class="section-title">仓库信息</span>
        </template>
        <el-form :model="warehouseInfo" label-width="100px">
          <el-form-item label="仓库名称">
            <el-input v-model="warehouseInfo.name" placeholder="请输入仓库名称" />
          </el-form-item>
          <el-form-item label="仓库地址">
            <el-input v-model="warehouseInfo.address" placeholder="请输入仓库地址" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" :loading="savingWarehouse" @click="saveWarehouseInfo">
              保存仓库信息
            </el-button>
          </el-form-item>
        </el-form>
      </el-card>

      <el-card shadow="never">
        <template #header>
          <span class="section-title">其他</span>
        </template>
        <div class="other-actions">
          <el-button class="action-item" @click="handleAbout">
            <span>关于我们</span>
            <el-icon><ArrowRight /></el-icon>
          </el-button>
          <el-button class="action-item" @click="handleClearCache">
            <span>清理缓存</span>
            <el-icon><ArrowRight /></el-icon>
          </el-button>
          <el-button class="action-item danger" @click="handleLogout">
            退出登录
          </el-button>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { warehouseApi } from '@/api'
import { toast } from '@/composables/useToast'
import { UserFilled, Loading, ArrowRight } from '@element-plus/icons-vue'

const router = useRouter()

const loading = ref(true)
const saving = ref(false)
const changingPassword = ref(false)
const savingWarehouse = ref(false)

const userInfo = ref({
  name: '',
  phone: '',
  role: '仓库管理员'
})

const passwordForm = ref({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const notificationSettings = ref({
  newOrder: true,
  lowStock: true,
  driverReturn: true
})

const warehouseInfo = ref({
  name: '',
  address: ''
})

const fetchUserInfo = async () => {
  try {
    const res = await warehouseApi.getProfile()
    userInfo.value = {
      name: res.name || '',
      phone: res.phone || '',
      role: '仓库管理员'
    }
  } catch (error: any) {
    console.error('获取用户信息失败:', error)
  }
}

const fetchWarehouseInfo = async () => {
  try {
    const res = await warehouseApi.getWarehouseInfo()
    warehouseInfo.value = {
      name: res.name || '',
      address: res.address || ''
    }
  } catch (error: any) {
    console.error('获取仓库信息失败:', error)
  }
}

const fetchNotificationSettings = async () => {
  try {
    const res = await warehouseApi.getNotificationSettings()
    notificationSettings.value = {
      newOrder: res.newOrder ?? true,
      lowStock: res.lowStock ?? true,
      driverReturn: res.driverReturn ?? true
    }
  } catch (error: any) {
    console.error('获取通知设置失败:', error)
  }
}

const saveUserInfo = async () => {
  if (!userInfo.value.name || !userInfo.value.phone) {
    toast.warning('请填写完整信息')
    return
  }

  saving.value = true
  try {
    await warehouseApi.updateProfile({
      name: userInfo.value.name,
      phone: userInfo.value.phone
    })
    toast.success('保存成功')
  } catch (error: any) {
    toast.error('保存失败: ' + (error.message || ''))
  } finally {
    saving.value = false
  }
}

const changePassword = async () => {
  if (passwordForm.value.newPassword !== passwordForm.value.confirmPassword) {
    toast.warning('两次输入的密码不一致')
    return
  }

  if (passwordForm.value.newPassword.length < 6) {
    toast.warning('新密码长度不能少于6位')
    return
  }

  changingPassword.value = true
  try {
    await warehouseApi.changePassword({
      oldPassword: passwordForm.value.oldPassword,
      newPassword: passwordForm.value.newPassword
    })
    toast.success('密码修改成功')
    passwordForm.value = {
      oldPassword: '',
      newPassword: '',
      confirmPassword: ''
    }
  } catch (error: any) {
    toast.error('修改失败: ' + (error.message || ''))
  } finally {
    changingPassword.value = false
  }
}

const saveNotificationSettings = async () => {
  try {
    await warehouseApi.updateNotificationSettings(notificationSettings.value)
    toast.success('设置已保存')
  } catch (error: any) {
    toast.error('保存失败: ' + (error.message || ''))
  }
}

const saveWarehouseInfo = async () => {
  savingWarehouse.value = true
  try {
    await warehouseApi.updateWarehouseInfo(warehouseInfo.value)
    toast.success('仓库信息已保存')
  } catch (error: any) {
    toast.error('保存失败: ' + (error.message || ''))
  } finally {
    savingWarehouse.value = false
  }
}

const handleAbout = () => {
  toast.info('关于我们')
}

const handleClearCache = () => {
  toast.success('缓存已清理')
}

const handleLogout = async () => {
  localStorage.removeItem('token')
  localStorage.removeItem('userInfo')
  router.push('/login')
}

onMounted(async () => {
  loading.value = true
  await Promise.all([
    fetchUserInfo(),
    fetchWarehouseInfo(),
    fetchNotificationSettings()
  ])
  loading.value = false
})
</script>

<style scoped>
.warehouse-settings {
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

.loading-wrapper {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 80px 0;
}

.loading-wrapper .el-icon {
  font-size: 40px;
  color: #409eff;
}

.section-title {
  font-weight: bold;
  color: #303133;
}

.form-tip {
  margin-left: 12px;
  font-size: 12px;
  color: #909399;
}

.other-actions {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.action-item {
  width: 100%;
  justify-content: space-between;
  display: flex;
  padding: 12px 16px;
  border-radius: 8px;
  background: #f5f7fa;
  border: none;
  color: #606266;
}

.action-item:hover {
  background: #ecf5ff;
  color: #409eff;
}

.action-item.danger {
  background: #fef0f0;
  color: #f56c6c;
}

.action-item.danger:hover {
  background: #f56c6c;
  color: #fff;
}
</style>
