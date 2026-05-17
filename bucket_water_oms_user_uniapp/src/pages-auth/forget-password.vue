<template>
  <view class="forget-page">
    <view class="page-header">
      <text class="title">找回密码</text>
      <text class="subtitle">通过手机验证码重置密码</text>
    </view>

    <view class="forget-form">
      <view class="form-item">
        <text class="label">手机号</text>
        <input
          class="input"
          type="number"
          v-model="form.phone"
          placeholder="请输入注册手机号"
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
        <text class="label">新密码</text>
        <input
          class="input"
          :type="showPassword ? 'text' : 'password'"
          v-model="form.password"
          placeholder="请设置新密码（6位以上）"
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
          placeholder="请再次输入新密码"
        />
      </view>

      <button class="submit-btn" :disabled="!canSubmit" @click="handleSubmit">
        重置密码
      </button>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { authService } from '@/services/authService'

const showPassword = ref(false)
const countdown = ref(0)

const form = ref({
  phone: '',
  smsCode: '',
  password: '',
  confirmPassword: ''
})

const canSubmit = computed(() => {
  return (
    form.value.phone.length === 11 &&
    form.value.smsCode.length === 6 &&
    form.value.password.length >= 6 &&
    form.value.password === form.value.confirmPassword
  )
})

const sendCode = async () => {
  if (countdown.value > 0 || form.value.phone.length !== 11) return

  try {
    await authService.sendSmsCode(form.value.phone, 'reset')
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

const handleSubmit = async () => {
  if (!canSubmit.value) {
    if (form.value.password !== form.value.confirmPassword) {
      uni.showToast({ title: '两次密码输入不一致', icon: 'none' })
      return
    }
    return
  }

  uni.showLoading({ title: '重置中...' })

  try {
    await authService.resetPassword(
      form.value.phone,
      form.value.smsCode,
      form.value.password
    )

    uni.hideLoading()
    uni.showToast({ title: '密码重置成功', icon: 'success' })

    setTimeout(() => {
      uni.navigateBack()
    }, 1500)
  } catch (error) {
    uni.hideLoading()
    uni.showToast({ title: '重置失败', icon: 'none' })
  }
}
</script>

<style lang="scss" scoped>
.forget-page {
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

.forget-form {
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

.submit-btn {
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
  margin-top: 48rpx;

  &[disabled] {
    background-color: #ccc;
  }
}
</style>
