<template>
  <div class="settings-container">
    <el-card shadow="never" class="mb-4">
      <template #header>
        <span class="card-title">个人设置</span>
      </template>
      <el-form :model="formData" label-width="100px" style="max-width: 600px">
        <el-form-item label="姓名">
          <el-input v-model="formData.name" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item label="手机号">
          <el-input v-model="formData.phone" placeholder="请输入手机号" />
        </el-form-item>
        <el-form-item label="水站名称">
          <el-input v-model="formData.stationName" disabled />
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never" class="mb-4">
      <template #header>
        <span class="card-title">账户安全</span>
      </template>
      <el-form :model="passwordForm" label-width="100px" style="max-width: 600px">
        <el-form-item label="当前密码">
          <el-input v-model="passwordForm.currentPassword" type="password" show-password placeholder="请输入当前密码" />
        </el-form-item>
        <el-form-item label="新密码">
          <el-input v-model="passwordForm.newPassword" type="password" show-password placeholder="请输入新密码" />
        </el-form-item>
        <el-form-item label="确认密码">
          <el-input v-model="passwordForm.confirmPassword" type="password" show-password placeholder="请再次输入新密码" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSave" :loading="saving">保存修改</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never" class="mb-4">
      <template #header>
        <span class="card-title">通知设置</span>
      </template>
      <div class="notification-list">
        <div class="notification-item">
          <div class="notification-info">
            <span class="notification-title">订单状态通知</span>
            <span class="notification-desc">接收订单状态变更通知</span>
          </div>
          <el-switch v-model="notifications.orderStatus" />
        </div>
        <div class="notification-item">
          <div class="notification-info">
            <span class="notification-title">欠桶预警通知</span>
            <span class="notification-desc">接收欠桶达到阈值提醒</span>
          </div>
          <el-switch v-model="notifications.bucketWarning" />
        </div>
        <div class="notification-item">
          <div class="notification-info">
            <span class="notification-title">对账单通知</span>
            <span class="notification-desc">接收对账单生成提醒</span>
          </div>
          <el-switch v-model="notifications.statement" />
        </div>
        <div class="notification-item">
          <div class="notification-info">
            <span class="notification-title">库存预警通知</span>
            <span class="notification-desc">接收商品库存不足提醒</span>
          </div>
          <el-switch v-model="notifications.inventory" />
        </div>
      </div>
    </el-card>

    <el-card shadow="never" class="mb-4">
      <template #header>
        <span class="card-title">其他设置</span>
      </template>
      <div class="menu-list">
        <div class="menu-item" @click="handleFeedback">
          <div class="menu-icon">
            <el-icon><Edit /></el-icon>
          </div>
          <div class="menu-info">
            <span class="menu-title">意见反馈</span>
            <span class="menu-desc">提交您的宝贵意见</span>
          </div>
          <el-icon class="menu-arrow"><ArrowRight /></el-icon>
        </div>
        <div class="menu-item" @click="handleHelp">
          <div class="menu-icon">
            <el-icon><QuestionFilled /></el-icon>
          </div>
          <div class="menu-info">
            <span class="menu-title">帮助中心</span>
            <span class="menu-desc">查看使用指南和常见问题</span>
          </div>
          <el-icon class="menu-arrow"><ArrowRight /></el-icon>
        </div>
        <div class="menu-item">
          <div class="menu-icon">
            <el-icon><InfoFilled /></el-icon>
          </div>
          <div class="menu-info">
            <span class="menu-title">关于我们</span>
            <span class="menu-desc">版本 1.0.0</span>
          </div>
          <el-icon class="menu-arrow"><ArrowRight /></el-icon>
        </div>
      </div>
    </el-card>

    <el-card shadow="never">
      <el-button type="danger" plain @click="handleLogout" class="logout-btn">退出登录</el-button>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Edit, QuestionFilled, InfoFilled, ArrowRight } from '@element-plus/icons-vue'
import { useAuthStore } from '@/stores/auth'
import { stationOwnerApi } from '@/api'

const router = useRouter()
const authStore = useAuthStore()

const saving = ref(false)

const formData = reactive({
  name: '',
  phone: '',
  stationName: ''
})

const passwordForm = reactive({
  currentPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const notifications = reactive({
  orderStatus: true,
  bucketWarning: true,
  statement: true,
  inventory: false
})

const loadProfile = async () => {
  try {
    const res = await stationOwnerApi.getUserProfile()
    if (res) {
      formData.name = res.name || ''
      formData.phone = res.phone || ''
      formData.stationName = res.stationName || ''
    }
  } catch (error: any) {
    console.error('加载用户信息失败：' + (error.message || '未知错误'))
  }
}

const handleSave = async () => {
  if (passwordForm.newPassword || passwordForm.confirmPassword) {
    if (!passwordForm.currentPassword) {
      ElMessage.warning('请输入当前密码')
      return
    }
    if (passwordForm.newPassword !== passwordForm.confirmPassword) {
      ElMessage.warning('两次输入的新密码不一致')
      return
    }
    if (passwordForm.newPassword.length < 6) {
      ElMessage.warning('新密码长度不能少于6位')
      return
    }

    try {
      await stationOwnerApi.changePassword({
        currentPassword: passwordForm.currentPassword,
        newPassword: passwordForm.newPassword
      })
      ElMessage.success('密码修改成功')
      handleReset()
    } catch (error: any) {
      ElMessage.error('密码修改失败：' + (error.message || '未知错误'))
      return
    }
  }

  try {
    saving.value = true
    await stationOwnerApi.updateProfile({
      name: formData.name,
      phone: formData.phone
    })
    ElMessage.success('个人信息保存成功')
  } catch (error: any) {
    ElMessage.error('保存失败：' + (error.message || '未知错误'))
  } finally {
    saving.value = false
  }
}

const handleReset = () => {
  passwordForm.currentPassword = ''
  passwordForm.newPassword = ''
  passwordForm.confirmPassword = ''
  loadProfile()
}

const handleFeedback = () => {
  ElMessage.info('意见反馈功能开发中')
}

const handleHelp = () => {
  ElMessage.info('帮助中心功能开发中')
}

const handleLogout = async () => {
  try {
    await ElMessageBox.confirm('确定要退出登录吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    authStore.logout()
    router.push('/login')
  } catch (error) {
    // 用户取消操作
  }
}

onMounted(() => {
  loadProfile()
})
</script>

<style scoped>
.settings-container {
  padding: 20px;
}

.mb-4 {
  margin-bottom: 20px;
}

.card-title {
  font-weight: 500;
  font-size: 16px;
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
  display: flex;
  flex-direction: column;
}

.notification-title {
  font-weight: 500;
  color: #303133;
}

.notification-desc {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
}

.menu-list {
  display: flex;
  flex-direction: column;
}

.menu-item {
  display: flex;
  align-items: center;
  padding: 16px 0;
  border-bottom: 1px solid #f0f0f0;
  cursor: pointer;
  transition: background-color 0.3s;
}

.menu-item:last-child {
  border-bottom: none;
}

.menu-item:hover {
  background-color: #f5f7fa;
}

.menu-icon {
  width: 40px;
  height: 40px;
  background: #ecf5ff;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #409eff;
  font-size: 20px;
}

.menu-info {
  flex: 1;
  margin-left: 12px;
  display: flex;
  flex-direction: column;
}

.menu-title {
  font-weight: 500;
  color: #303133;
}

.menu-desc {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
}

.menu-arrow {
  color: #c0c4cc;
}

.logout-btn {
  width: 100%;
}
</style>
