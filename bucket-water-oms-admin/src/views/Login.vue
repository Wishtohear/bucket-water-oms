<template>
  <div class="login-container">
    <div class="login-left">
      <div class="login-left-content">
        <div class="logo-section">
          <el-icon size="40" color="#fff"><Shop /></el-icon>
          <span class="logo-title">水厂订货管理系统</span>
        </div>
        <div class="slogan-section">
          <h1 class="slogan-title">数字化水厂<br />智慧运营后台</h1>
          <p class="slogan-desc">
            高效连接水站，实时掌控销售、财务与库存，<br />
            提升水厂运营效能。
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
          <h2>管理员登录</h2>
          <p>请使用管理员账号登录后台</p>
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

          <el-form-item v-if="!useSmsLogin" prop="password">
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

          <el-form-item v-if="useSmsLogin" prop="code">
            <div class="sms-code-input">
              <el-input
                v-model="formData.code"
                placeholder="请输入验证码"
                :prefix-icon="Lock"
                clearable
                size="large"
                class="sms-input"
              />
              <el-button
                :disabled="countdown > 0"
                size="large"
                class="sms-btn"
                @click="sendSmsCode"
              >
                {{ countdown > 0 ? `${countdown}秒后重发` : '获取验证码' }}
              </el-button>
            </div>
          </el-form-item>

          <div class="login-type-toggle">
            <el-link type="primary" :underline="false" @click="toggleLoginType">
              {{ useSmsLogin ? '密码登录' : '验证码登录' }}
            </el-link>
          </div>

          <div class="form-options">
            <el-checkbox v-if="!useSmsLogin" v-model="formData.remember">记住登录状态</el-checkbox>
            <span v-else></span>
            <el-link type="primary" :underline="false" @click="showResetDialog">忘记密码？</el-link>
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
          <el-link type="info" :underline="false" @click="goToWarehouseLogin">
            仓库管理员登录
          </el-link>
          <el-divider direction="vertical" />
          <el-link type="info" :underline="false" @click="goToOwnerLogin">
            水站老板登录
          </el-link>
        </div>
      </div>
    </div>

    <el-dialog v-model="resetDialogVisible" title="找回密码" width="400px" :close-on-click-modal="false">
      <el-form ref="resetFormRef" :model="resetFormData" :rules="resetRules" label-width="80px">
        <el-form-item label="手机号" prop="phone">
          <el-input v-model="resetFormData.phone" placeholder="请输入注册手机号" size="large" />
        </el-form-item>
        <el-form-item label="验证码" prop="code">
          <div class="reset-code-input">
            <el-input v-model="resetFormData.code" placeholder="请输入验证码" size="large" class="code-input" />
            <el-button :disabled="resetCountdown > 0" size="large" class="code-btn" @click="sendResetCode">
              {{ resetCountdown > 0 ? `${resetCountdown}秒` : '获取验证码' }}
            </el-button>
          </div>
        </el-form-item>
        <el-form-item label="新密码" prop="newPassword">
          <el-input v-model="resetFormData.newPassword" type="password" placeholder="请输入新密码(至少6位)" size="large" show-password />
        </el-form-item>
        <el-form-item label="确认密码" prop="confirmPassword">
          <el-input v-model="resetFormData.confirmPassword" type="password" placeholder="请再次输入新密码" size="large" show-password />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="resetDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="resetLoading" @click="handleResetPassword">确认重置</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { authApi } from '@/api/auth'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { Phone, Lock, Shop } from '@element-plus/icons-vue'

const router = useRouter()
const authStore = useAuthStore()
const formRef = ref<FormInstance>()

const formData = reactive({
  phone: '',
  password: '',
  code: '',
  remember: true
})

const loading = ref(false)
const errorMessage = ref('')
const useSmsLogin = ref(false)
const countdown = ref(0)
let countdownTimer: number | null = null

const resetDialogVisible = ref(false)
const resetFormRef = ref<FormInstance>()
const resetLoading = ref(false)
const resetCountdown = ref(0)
let resetCountdownTimer: number | null = null

const resetFormData = reactive({
  phone: '',
  code: '',
  newPassword: '',
  confirmPassword: ''
})

const validateConfirmPassword = (rule: any, value: string, callback: any) => {
  if (value === '') {
    callback(new Error('请再次输入密码'))
  } else if (value !== resetFormData.newPassword) {
    callback(new Error('两次输入的密码不一致'))
  } else {
    callback()
  }
}

const resetRules: FormRules = {
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ],
  code: [
    { required: true, message: '请输入验证码', trigger: 'blur' },
    { len: 6, message: '验证码为6位', trigger: 'blur' }
  ],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, message: '密码至少6位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, validator: validateConfirmPassword, trigger: 'blur' }
  ]
}

const showResetDialog = () => {
  resetDialogVisible.value = true
}

const sendResetCode = async () => {
  if (!resetFormData.phone || !/^1[3-9]\d{9}$/.test(resetFormData.phone)) {
    ElMessage.warning('请输入正确的手机号')
    return
  }

  try {
    await authApi.sendResetCode(resetFormData.phone)
    resetCountdown.value = 60
    resetCountdownTimer = window.setInterval(() => {
      resetCountdown.value--
      if (resetCountdown.value <= 0 && resetCountdownTimer) {
        clearInterval(resetCountdownTimer)
        resetCountdownTimer = null
      }
    }, 1000)
    ElMessage.success('验证码已发送')
  } catch (error) {
    ElMessage.error('验证码发送失败，请重试')
  }
}

const handleResetPassword = async () => {
  if (!resetFormRef.value) return

  await resetFormRef.value.validate(async (valid) => {
    if (!valid) return

    resetLoading.value = true
    try {
      await authApi.resetPassword(
        resetFormData.phone,
        resetFormData.code,
        resetFormData.newPassword
      )
      ElMessage.success('密码重置成功，请使用新密码登录')
      resetDialogVisible.value = false
      resetFormRef.value?.resetFields()
    } catch (error: any) {
      ElMessage.error(error.message || '密码重置失败')
    } finally {
      resetLoading.value = false
    }
  })
}

const rules: FormRules = {
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码至少6位', trigger: 'blur' }
  ],
  code: [
    { required: true, message: '请输入验证码', trigger: 'blur' },
    { len: 6, message: '验证码为6位', trigger: 'blur' }
  ]
}

const toggleLoginType = () => {
  useSmsLogin.value = !useSmsLogin.value
  errorMessage.value = ''
}

const sendSmsCode = async () => {
  if (!formData.phone || !/^1[3-9]\d{9}$/.test(formData.phone)) {
    errorMessage.value = '请输入正确的手机号'
    return
  }

  try {
    await authApi.sendSmsCode(formData.phone)
    countdown.value = 60
    countdownTimer = window.setInterval(() => {
      countdown.value--
      if (countdown.value <= 0 && countdownTimer) {
        clearInterval(countdownTimer)
        countdownTimer = null
      }
    }, 1000)
  } catch (error: any) {
    errorMessage.value = '验证码发送失败，请重试'
  }
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
      let result

      if (useSmsLogin.value) {
        result = await authApi.loginBySmsCode(formData.phone, formData.code, 'admin')
        if (result && result.data) {
          result.success = true
          result.token = result.data.token
          result.data = result.data
          authStore.setToken(result.data.token)
          authStore.setUser(result.data.userInfo || result.data.user)
        } else {
          result = { success: false, message: result.message || '验证码登录失败' }
        }
      } else {
        result = await authStore.login({
          phone: formData.phone,
          password: formData.password,
          role: 'admin'
        })
      }

      if (result.success) {
        if (!authStore.token) {
          errorMessage.value = '登录状态异常，请重试'
          return
        }

        await new Promise(resolve => setTimeout(resolve, 200))
        const targetRoute = authStore.getDefaultRoute()
        console.log('管理员登录成功，跳转到:', targetRoute)
        await router.replace(targetRoute)
      } else {
        errorMessage.value = result.message || '登录失败'
      }
    } catch (error: any) {
      if (error.message?.includes('Infinite redirect') || error.message?.includes('Redirected')) {
        const targetRoute = authStore.getDefaultRoute()
        window.location.href = targetRoute
      } else {
        errorMessage.value = error.message || '登录过程出现错误，请重试'
      }
    } finally {
      loading.value = false
    }
  })
}

const goToWarehouseLogin = () => {
  router.push('/login/warehouse')
}

const goToOwnerLogin = () => {
  router.push('/login/station')
}
</script>

<style scoped>
.login-container {
  display: flex;
  min-height: 100vh;
}

.login-left {
  flex: 1;
  background: linear-gradient(135deg, #409eff 0%, #1890ff 100%);
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

.sms-code-input {
  display: flex;
  gap: 8px;
  width: 100%;
}

.sms-input {
  flex: 1;
}

.sms-btn {
  width: 120px;
  flex-shrink: 0;
}

.login-type-toggle {
  text-align: right;
  margin-bottom: 16px;
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
  color: #409eff;
}

:deep(.el-link--primary:hover) {
  color: #66b1ff;
}

.reset-code-input {
  display: flex;
  gap: 8px;
  width: 100%;
}

.reset-code-input .code-input {
  flex: 1;
}

.reset-code-input .code-btn {
  width: 100px;
  flex-shrink: 0;
}
</style>
