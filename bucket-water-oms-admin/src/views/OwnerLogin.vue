<template>
  <div class="login-container">
    <div class="login-left">
      <div class="login-left-content">
        <div class="logo-section">
          <el-icon size="40" color="#fff"><Shop /></el-icon>
          <span class="logo-title">水站管理系统</span>
        </div>
        <div class="slogan-section">
          <h1 class="slogan-title">便捷订货<br />轻松经营</h1>
          <p class="slogan-desc">
            一键下单，订单追踪，<br />
            让水站经营更简单。
          </p>
        </div>
        <div class="footer-section">
          <span>© 2026 水厂管理系统</span>
          <el-divider direction="vertical" />
          <span>{{ currentDate }}</span>
        </div>
      </div>
      <div class="decoration-circle circle-1"></div>
      <div class="decoration-circle circle-2"></div>
    </div>

    <div class="login-right">
      <div class="login-form-container">
        <div class="form-header">
          <h2>水站老板登录</h2>
          <p>请使用水站老板账号登录</p>
        </div>

        <el-form
          ref="formRef"
          :model="formData"
          :rules="rules"
          class="login-form"
          size="large"
        >
          <el-form-item prop="phone">
            <el-input
              v-model="formData.phone"
              placeholder="请输入手机号"
              :prefix-icon="Phone"
              clearable
              size="large"
            />
          </el-form-item>

          <el-form-item prop="password">
            <el-input
              v-model="formData.password"
              type="password"
              placeholder="请输入登录密码"
              :prefix-icon="Lock"
              show-password
              clearable
              size="large"
            />
          </el-form-item>

          <div class="form-options">
            <el-checkbox v-model="formData.remember">记住登录状态</el-checkbox>
            <el-link type="primary" :underline="false">忘记密码？</el-link>
          </div>

          <el-alert
            v-if="errorMessage"
            :title="errorMessage"
            type="error"
            show-icon
            :closable="false"
            class="mb-4"
          />

          <el-button
            type="primary"
            :loading="loading"
            class="login-button"
            size="large"
            @click="handleLogin"
          >
            {{ loading ? '登录中...' : '立即登录' }}
          </el-button>
        </el-form>

        <div class="login-links">
          <el-link type="info" :underline="false" @click="goToAdminLogin">
            管理员登录
          </el-link>
          <el-divider direction="vertical" />
          <el-link type="info" :underline="false" @click="goToWarehouseLogin">
            仓库管理员登录
          </el-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import type { FormInstance, FormRules } from 'element-plus'
import { Phone, Lock, Shop } from '@element-plus/icons-vue'

const router = useRouter()
const authStore = useAuthStore()
const formRef = ref<FormInstance>()

const formData = reactive({
  phone: '',
  password: '',
  remember: true
})

const loading = ref(false)
const errorMessage = ref('')

const rules: FormRules = {
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码至少6位', trigger: 'blur' }
  ]
}

const currentDate = computed(() => {
  const now = new Date()
  return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`
})

const handleLogin = async () => {
  if (!formRef.value) return

  await formRef.value.validate(async (valid) => {
    if (!valid) return

    errorMessage.value = ''
    loading.value = true

    try {
      const result = await authStore.login({
        phone: formData.phone,
        password: formData.password,
        role: 'station'
      })

      if (result.success) {
        if (!authStore.token) {
          errorMessage.value = '登录状态异常，请重试'
          return
        }

        await new Promise(resolve => setTimeout(resolve, 200))
        const targetRoute = authStore.getDefaultRoute()
        console.log('水站老板登录成功，跳转到:', targetRoute)
        await router.replace(targetRoute)
      } else {
        errorMessage.value = result.message || '登录失败'
      }
    } catch (error: any) {
      if (error.message?.includes('Infinite redirect') || error.message?.includes('Redirected')) {
        const targetRoute = authStore.getDefaultRoute()
        window.location.href = targetRoute
      } else {
        errorMessage.value = '登录过程出现错误，请重试'
      }
    } finally {
      loading.value = false
    }
  })
}

const goToAdminLogin = () => {
  router.push('/login')
}

const goToWarehouseLogin = () => {
  router.push('/login/warehouse')
}
</script>

<style scoped>
.login-container {
  display: flex;
  min-height: 100vh;
}

.login-left {
  flex: 1;
  background: linear-gradient(135deg, #E6A23C 0%, #D8762C 100%);
  padding: 60px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  position: relative;
  overflow: hidden;
}

.login-left-content {
  position: relative;
  z-index: 2;
}

.logo-section {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 60px;
}

.logo-title {
  font-size: 24px;
  font-weight: 600;
  color: #fff;
  letter-spacing: 2px;
}

.slogan-section {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.slogan-title {
  font-size: 42px;
  font-weight: 700;
  color: #fff;
  line-height: 1.3;
  margin-bottom: 24px;
}

.slogan-desc {
  font-size: 18px;
  color: rgba(255, 255, 255, 0.9);
  line-height: 1.8;
}

.footer-section {
  display: flex;
  align-items: center;
  color: rgba(255, 255, 255, 0.8);
  font-size: 14px;
}

.decoration-circle {
  position: absolute;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.1);
}

.circle-1 {
  width: 400px;
  height: 400px;
  bottom: -150px;
  right: -100px;
}

.circle-2 {
  width: 200px;
  height: 200px;
  top: 150px;
  left: -50px;
}

.login-right {
  width: 480px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #fff;
}

.login-form-container {
  width: 340px;
}

.form-header {
  margin-bottom: 40px;
}

.form-header h2 {
  font-size: 28px;
  font-weight: 600;
  color: #303133;
  margin: 0 0 8px 0;
}

.form-header p {
  color: #909399;
  font-size: 14px;
  margin: 0;
}

.login-form {
  margin-top: 20px;
}

.form-options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.login-button {
  width: 100%;
  height: 48px;
  font-size: 16px;
  font-weight: 500;
}

.login-links {
  margin-top: 40px;
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 8px;
}

.mb-4 {
  margin-bottom: 16px;
}

:deep(.el-input__wrapper) {
  padding: 8px 16px;
}

:deep(.el-input__prefix-inner) {
  margin-right: 8px;
}

:deep(.el-checkbox__label) {
  color: #606266;
}

:deep(.el-link--primary) {
  color: #E6A23C;
}

:deep(.el-link--primary:hover) {
  color: #EBB563;
}
</style>
