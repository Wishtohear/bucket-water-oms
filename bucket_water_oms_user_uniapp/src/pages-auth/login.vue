<template>
  <view class="login-page">
    <view class="login-header">
      <text class="title">欢迎登录</text>
      <text class="subtitle">订水平台</text>
    </view>

    <view class="login-form">
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

      <view class="form-item" v-if="loginType === 'password'">
        <text class="label">密码</text>
        <input
          class="input"
          :type="showPassword ? 'text' : 'password'"
          v-model="form.password"
          placeholder="请输入密码"
        />
        <text class="toggle-pwd" @click="showPassword = !showPassword">
          {{ showPassword ? '🙈' : '👁️' }}
        </text>
      </view>

      <view class="form-item" v-else>
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

      <view class="login-type">
        <text class="type-btn" @click="toggleLoginType">
          {{ loginType === 'password' ? '验证码登录' : '密码登录' }}
        </text>
      </view>

      <button class="login-btn" :disabled="!canLogin" @click="handleLogin">登录</button>

      <view class="register-link">
        <text>还没有账号？</text>
        <text class="link" @click="goRegister">立即注册</text>
      </view>

      <view class="forget-link">
        <text class="link" @click="goForgetPassword">忘记密码？</text>
      </view>
    </view>

    <view class="wechat-login" v-if="isWechatEnv">
      <view class="divider">
        <view class="line"></view>
        <text class="divider-text">其他登录方式</text>
        <view class="line"></view>
      </view>
      <view class="wechat-btn" @click="wechatLogin">
        <text class="icon">💬</text>
        <text>微信一键登录</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { authService } from '@/services/authService'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()

const loginType = ref<'password' | 'sms'>('password')
const showPassword = ref(false)
const countdown = ref(0)

const form = ref({
  phone: '',
  password: '',
  smsCode: ''
})

const isWechatEnv = ref(false)

// 真实环境检测
try {
  // #ifdef MP-WEIXIN
  isWechatEnv.value = true
  // #endif
} catch { /* ignore */ }

const canLogin = computed(() => {
  if (loginType.value === 'password') {
    return form.value.phone.length === 11 && form.value.password.length >= 6
  } else {
    return form.value.phone.length === 11 && form.value.smsCode.length === 6
  }
})

const toggleLoginType = () => {
  loginType.value = loginType.value === 'password' ? 'sms' : 'password'
  form.value.password = ''
  form.value.smsCode = ''
}

const sendCode = async () => {
  if (countdown.value > 0 || form.value.phone.length !== 11) return

  try {
    await authService.sendSmsCode(form.value.phone, loginType.value === 'password' ? 'login' : 'register')
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

const handleLogin = async () => {
  if (!canLogin.value) return

  uni.showLoading({ title: '登录中...' })

  try {
    let success = false

    if (loginType.value === 'password') {
      success = await authStore.login(form.value.phone, form.value.password)
    } else {
      success = await authStore.loginBySmsCode(form.value.phone, form.value.smsCode)
    }

    uni.hideLoading()

    if (success) {
      uni.showToast({ title: '登录成功', icon: 'success' })
      setTimeout(() => {
        uni.navigateBack()
      }, 1500)
    }
  } catch (error) {
    uni.hideLoading()
    uni.showToast({ title: '登录失败', icon: 'none' })
  }
}

const wechatLogin = async () => {
  // 真实实现：调用 uni.login 获取 code，发送到后端换取 token
  // #ifdef MP-WEIXIN
  try {
    const loginRes = await new Promise<any>((resolve, reject) => {
      uni.login({
        provider: 'weixin',
        success: (res) => resolve(res),
        fail: (err) => reject(err)
      })
    })
    if (!loginRes.code) {
      uni.showToast({ title: '获取微信授权失败', icon: 'none' })
      return
    }
    // 发送到后端 wechat-login 接口
    try {
      const authService = (await import('@/services/authService')).authService
      await authService.wechatLogin(loginRes.code)
      uni.showToast({ title: '登录成功', icon: 'success' })
      setTimeout(() => uni.reLaunch({ url: '/pages/index/index' }), 800)
    } catch (apiError: any) {
      uni.showToast({ title: apiError?.message || '微信登录失败', icon: 'none' })
    }
  } catch (error) {
    uni.showToast({ title: '微信登录失败', icon: 'none' })
  }
  // #endif
  // #ifndef MP-WEIXIN
  uni.showToast({ title: '请在小程序中使用微信登录', icon: 'none' })
  // #endif
}

const goRegister = () => {
  uni.navigateTo({ url: '/pages-auth/register' })
}

const goForgetPassword = () => {
  uni.navigateTo({ url: '/pages-auth/forget-password' })
}
</script>

<style lang="scss" scoped>
.login-page {
  min-height: 100vh;
  background-color: #fff;
  padding: 0 48rpx;
}

.login-header {
  padding: 120rpx 0 80rpx;
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

.login-form {
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

.login-type {
  text-align: right;
  margin-bottom: 48rpx;

  .type-btn {
    font-size: 26rpx;
    color: $primary-color;
  }
}

.login-btn {
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

.register-link,
.forget-link {
  text-align: center;
  font-size: 26rpx;
  color: $text-secondary;
  margin-bottom: 16rpx;

  .link {
    color: $primary-color;
    margin-left: 8rpx;
  }
}

.wechat-login {
  margin-top: 80rpx;

  .divider {
    display: flex;
    align-items: center;
    margin-bottom: 48rpx;

    .line {
      flex: 1;
      height: 1rpx;
      background-color: $border-color;
    }

    .divider-text {
      padding: 0 24rpx;
      font-size: 24rpx;
      color: $text-tertiary;
    }
  }

  .wechat-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 12rpx;
    height: 96rpx;
    background-color: #07c160;
    color: #fff;
    font-size: 30rpx;
    border-radius: 48rpx;

    .icon {
      font-size: 40rpx;
    }
  }
}
</style>
