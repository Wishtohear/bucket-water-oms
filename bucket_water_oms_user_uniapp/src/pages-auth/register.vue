<template>
  <view class="register-page">
    <view class="page-header">
      <text class="title">注册账号</text>
      <text class="subtitle">欢迎加入订水平台</text>
    </view>

    <view class="register-form">
      <view class="form-item">
        <text class="label">手机号</text>
        <input
          class="input"
          type="number"
          v-model="form.phone"
          placeholder="请输入手机号"
          maxlength="11"
        />
      </view>

      <view class="form-item">
        <text class="label">验证码</text>
        <input
          class="input"
          type="number"
          v-model="form.smsCode"
          placeholder="请输入验证码"
          maxlength="6"
        />
        <text class="send-code" :class="{ disabled: countdown > 0 }" @click="sendCode">
          {{ countdown > 0 ? `${countdown}s` : '获取验证码' }}
        </text>
      </view>

      <view class="form-item">
        <text class="label">密码</text>
        <input
          class="input"
          :type="showPassword ? 'text' : 'password'"
          v-model="form.password"
          placeholder="请设置登录密码（6位以上）"
          minlength="6"
        />
        <text class="toggle-pwd" @click="showPassword = !showPassword">
          {{ showPassword ? '🙈' : '👁️' }}
        </text>
      </view>

      <view class="form-item">
        <text class="label">确认密码</text>
        <input
          class="input"
          :type="showPassword ? 'text' : 'password'"
          v-model="form.confirmPassword"
          placeholder="请再次输入密码"
        />
      </view>

      <view class="agreement">
        <checkbox-group @change="onAgreementChange">
          <label class="agreement-label">
            <checkbox :checked="isAgreed" />
            <text class="agreement-text">
              我已阅读并同意
              <text class="link" @click.stop="showAgreement('user')">《用户协议》</text>
              和
              <text class="link" @click.stop="showAgreement('privacy')">《隐私政策》</text>
            </text>
          </label>
        </checkbox-group>
      </view>

      <button class="register-btn" :disabled="!canRegister" @click="handleRegister">
        注册
      </button>

      <view class="login-link">
        <text>已有账号？</text>
        <text class="link" @click="goLogin">立即登录</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { authService } from '@/services/authService'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()

const showPassword = ref(false)
const countdown = ref(0)
const isAgreed = ref(false)

const form = ref({
  phone: '',
  smsCode: '',
  password: '',
  confirmPassword: ''
})

const canRegister = computed(() => {
  return (
    form.value.phone.length === 11 &&
    form.value.smsCode.length === 6 &&
    form.value.password.length >= 6 &&
    form.value.password === form.value.confirmPassword &&
    isAgreed.value
  )
})

const onAgreementChange = (e: any) => {
  isAgreed.value = e.detail.value.length > 0
}

const sendCode = async () => {
  if (countdown.value > 0 || form.value.phone.length !== 11) return

  try {
    await authService.sendSmsCode(form.value.phone, 'register')
    uni.showToast({ title: '验证码已发送', icon: 'success' })

    countdown.value = 60
    const timer = setInterval(() => {
      countdown.value--
      if (countdown.value <= 0) {
        clearInterval(timer)
      }
    }, 1000)
  } catch (error) {
    uni.showToast({ title: '发送失败', icon: 'none' })
  }
}

const handleRegister = async () => {
  if (!canRegister.value) {
    if (!isAgreed.value) {
      uni.showToast({ title: '请先同意用户协议', icon: 'none' })
      return
    }
    if (form.value.password !== form.value.confirmPassword) {
      uni.showToast({ title: '两次密码输入不一致', icon: 'none' })
      return
    }
    return
  }

  uni.showLoading({ title: '注册中...' })

  try {
    const success = await authStore.register(
      form.value.phone,
      form.value.password,
      form.value.smsCode
    )

    uni.hideLoading()

    if (success) {
      uni.showToast({ title: '注册成功', icon: 'success' })
      setTimeout(() => {
        uni.switchTab({ url: '/pages/index/index' })
      }, 1500)
    }
  } catch (error) {
    uni.hideLoading()
    uni.showToast({ title: '注册失败', icon: 'none' })
  }
}

const showAgreement = (type: 'user' | 'privacy') => {
  uni.navigateTo({ url: `/pages-user/agreement?type=${type}` })
}

const goLogin = () => {
  uni.navigateBack()
}
</script>

<style lang="scss" scoped>
.register-page {
  min-height: 100vh;
  background-color: #fff;
  padding: 0 48rpx;
}

.page-header {
  padding: 80rpx 0 60rpx;
  text-align: center;

  .title {
    display: block;
    font-size: 48rpx;
    font-weight: 700;
    color: $text-primary;
    margin-bottom: 16rpx;
  }

  .subtitle {
    font-size: 28rpx;
    color: $text-secondary;
  }
}

.register-form {
  .form-item {
    position: relative;
    margin-bottom: 32rpx;
  }

  .label {
    display: block;
    font-size: 28rpx;
    color: $text-primary;
    margin-bottom: 12rpx;
  }

  .input {
    width: 100%;
    height: 96rpx;
    padding: 0 24rpx;
    background-color: #f8f8f8;
    border-radius: $radius-lg;
    font-size: 30rpx;
  }

  .toggle-pwd {
    position: absolute;
    right: 24rpx;
    bottom: 28rpx;
    font-size: 36rpx;
  }

  .send-code {
    position: absolute;
    right: 24rpx;
    bottom: 28rpx;
    font-size: 26rpx;
    color: $primary-color;

    &.disabled {
      color: $text-tertiary;
    }
  }
}

.agreement {
  margin-bottom: 48rpx;

  .agreement-label {
    display: flex;
    align-items: flex-start;
  }

  .agreement-text {
    font-size: 24rpx;
    color: $text-secondary;
    margin-left: 8rpx;
    line-height: 1.6;
  }

  .link {
    color: $primary-color;
  }
}

.register-btn {
  width: 100%;
  height: 96rpx;
  background-color: $primary-color;
  color: #fff;
  font-size: 32rpx;
  border-radius: 48rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  border: none;
  margin-bottom: 32rpx;

  &[disabled] {
    background-color: #ccc;
  }
}

.login-link {
  text-align: center;
  font-size: 26rpx;
  color: $text-secondary;

  .link {
    color: $primary-color;
    margin-left: 8rpx;
  }
}
</style>
