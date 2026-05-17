<template>
  <view class="bind-page">
    <view class="header-section">
      <text class="app-name">配送员登录</text>
      <text class="app-desc">绑定您的配送员账号，开始配送工作</text>
    </view>

    <view class="form-section">
      <view class="input-group">
        <view class="input-item">
          <text class="input-label">手机号</text>
          <view class="input-row">
            <input 
              class="input-field" 
              type="number" 
              v-model="phone" 
              placeholder="请输入手机号"
              maxlength="11"
              @input="onPhoneInput"
            />
            <button 
              class="send-code-btn" 
              :disabled="countdown > 0 || !isPhoneValid"
              @click="sendCode"
            >
              {{ countdown > 0 ? `${countdown}s` : '发送验证码' }}
            </button>
          </view>
        </view>

        <view class="input-item">
          <text class="input-label">验证码</text>
          <input 
            class="input-field" 
            type="number" 
            v-model="code" 
            placeholder="请输入验证码"
            maxlength="6"
          />
        </view>

        <view class="input-item" v-if="!isBinding">
          <text class="input-label">配送员姓名</text>
          <input 
            class="input-field" 
            v-model="name" 
            placeholder="请输入您的姓名"
          />
        </view>

        <view class="binding-tip" v-if="existingPerson">
          <text class="tip-icon">ℹ️</text>
          <view class="tip-content">
            <text class="tip-text">检测到您已绑定过配送员账号</text>
            <text class="tip-name">{{ existingPerson.name }} ({{ existingPerson.phone }})</text>
            <text class="tip-action" @click="confirmBind">绑定新账号</text>
          </view>
        </view>
      </view>

      <view class="agreement-row">
        <checkbox-group @change="onAgreementChange">
          <label class="agreement-label">
            <checkbox :checked="agreed" color="#1890FF" style="transform: scale(0.8)" />
            <text class="agreement-text">
              我已阅读并同意
              <text class="link" @click.stop="showUserAgreement">《用户协议》</text>
              和
              <text class="link" @click.stop="showPrivacyPolicy">《隐私政策》</text>
            </text>
          </label>
        </checkbox-group>
      </view>

      <button 
        class="submit-btn" 
        :disabled="!canSubmit || binding"
        @click="handleSubmit"
      >
        <text class="btn-text" v-if="!binding">{{ isBinding ? '绑定中...' : '登录' }}</text>
        <text class="btn-text" v-else>登录中...</text>
      </button>

      <view class="switch-mode">
        <text class="switch-text" v-if="isBinding" @click="isBinding = false">已有账号？立即登录</text>
        <text class="switch-text" v-else @click="isBinding = true">没有账号？立即绑定</text>
      </view>
    </view>

    <view class="footer-section">
      <text class="footer-text">水厂订货管理系统</text>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onUnmounted } from 'vue'
import { deliveryPersonService, DeliveryPerson } from '@/services/deliveryPersonService'
import { authService } from '@/services/authService'

const phone = ref('')
const code = ref('')
const name = ref('')
const agreed = ref(false)
const isBinding = ref(false)
const binding = ref(false)
const countdown = ref(0)
const existingPerson = ref<DeliveryPerson | null>(null)
let countdownTimer: ReturnType<typeof setInterval> | null = null

const isPhoneValid = computed(() => {
  return /^1[3-9]\d{9}$/.test(phone.value)
})

const canSubmit = computed(() => {
  if (isBinding.value) {
    return isPhoneValid.value && code.value.length === 6 && agreed.value
  } else {
    return existingPerson.value ? (isPhoneValid.value && code.value.length === 6 && agreed.value) : (isPhoneValid.value && code.value.length === 6 && agreed.value && name.value.trim())
  }
})

const onPhoneInput = () => {
  if (phone.value.length === 11) {
    checkExistingPerson()
  }
}

const checkExistingPerson = async () => {
  try {
    const info = await deliveryPersonService.getInfo()
    if (info && info.phone === phone.value) {
      existingPerson.value = info
      name.value = info.name
    } else {
      existingPerson.value = null
    }
  } catch (error) {
    existingPerson.value = null
  }
}

const sendCode = async () => {
  if (!isPhoneValid.value || countdown.value > 0) return

  try {
    await authService.sendSmsCode(phone.value, 'login')
    uni.showToast({ title: '验证码已发送' })
    startCountdown()
  } catch (error) {
    console.error('发送验证码失败:', error)
    uni.showToast({ title: '发送失败，请重试', icon: 'error' })
  }
}

const startCountdown = () => {
  countdown.value = 60
  countdownTimer = setInterval(() => {
    countdown.value--
    if (countdown.value <= 0) {
      if (countdownTimer) {
        clearInterval(countdownTimer)
        countdownTimer = null
      }
    }
  }, 1000)
}

const onAgreementChange = (e: any) => {
  agreed.value = e.detail.value.length > 0
}

const confirmBind = () => {
  uni.showModal({
    title: '提示',
    content: '确定要绑定新账号吗？原账号的绑定关系将被解除。',
    success: (res) => {
      if (res.confirm) {
        isBinding.value = true
        existingPerson.value = null
        name.value = ''
      }
    }
  })
}

const handleSubmit = async () => {
  if (!canSubmit.value || binding.value) return

  binding.value = true

  try {
    if (isBinding.value || existingPerson.value) {
      const result = await deliveryPersonService.bind({
        phone: phone.value,
        code: code.value
      })
      
      if (result) {
        uni.showToast({ title: '绑定成功' })
        setTimeout(() => {
          uni.navigateBack()
        }, 1500)
      }
    } else {
      await authService.loginBySms(phone.value, code.value)
      uni.showToast({ title: '登录成功' })
      setTimeout(() => {
        uni.switchTab({ url: '/pages/index/index' })
      }, 1500)
    }
  } catch (error) {
    console.error('操作失败:', error)
    uni.showToast({ 
      title: error?.message || '操作失败，请重试', 
      icon: 'error' 
    })
  } finally {
    binding.value = false
  }
}

const showUserAgreement = () => {
  uni.navigateTo({
    url: '/pages/user/agreement?type=user'
  })
}

const showPrivacyPolicy = () => {
  uni.navigateTo({
    url: '/pages/user/agreement?type=privacy'
  })
}

onUnmounted(() => {
  if (countdownTimer) {
    clearInterval(countdownTimer)
  }
})
</script>

<style lang="scss" scoped>
.bind-page {
  min-height: 100vh;
  background: linear-gradient(180deg, #f8faff 0%, #ffffff 50%);
  padding: 0 48rpx;
  padding-top: calc(120rpx + env(safe-area-inset-top));
}

.header-section {
  text-align: center;
  margin-bottom: 80rpx;

  .app-name {
    display: block;
    font-size: 56rpx;
    font-weight: 700;
    color: $primary-color;
    margin-bottom: 16rpx;
  }

  .app-desc {
    display: block;
    font-size: 28rpx;
    color: $text-secondary;
  }
}

.form-section {
  .input-group {
    .input-item {
      margin-bottom: 40rpx;

      .input-label {
        display: block;
        font-size: 28rpx;
        color: $text-primary;
        margin-bottom: 16rpx;
        font-weight: 500;
      }

      .input-row {
        display: flex;
        align-items: center;
        gap: 16rpx;

        .input-field {
          flex: 1;
          height: 88rpx;
          padding: 0 24rpx;
          background: #fff;
          border: 2rpx solid $border-color;
          border-radius: 16rpx;
          font-size: 30rpx;
          transition: border-color 0.3s;

          &:focus {
            border-color: $primary-color;
          }
        }

        .send-code-btn {
          width: 200rpx;
          height: 88rpx;
          background: $primary-color;
          color: #fff;
          font-size: 26rpx;
          border-radius: 16rpx;
          border: none;
          display: flex;
          align-items: center;
          justify-content: center;

          &[disabled] {
            background: $text-tertiary;
          }
        }
      }

      .input-field {
        width: 100%;
        height: 88rpx;
        padding: 0 24rpx;
        background: #fff;
        border: 2rpx solid $border-color;
        border-radius: 16rpx;
        font-size: 30rpx;
        transition: border-color 0.3s;

        &:focus {
          border-color: $primary-color;
        }
      }
    }

    .binding-tip {
      display: flex;
      align-items: flex-start;
      padding: 24rpx;
      background: rgba($primary-color, 0.05);
      border-radius: 16rpx;
      margin-bottom: 40rpx;

      .tip-icon {
        font-size: 32rpx;
        margin-right: 16rpx;
      }

      .tip-content {
        flex: 1;

        .tip-text {
          display: block;
          font-size: 26rpx;
          color: $text-secondary;
          margin-bottom: 8rpx;
        }

        .tip-name {
          display: block;
          font-size: 28rpx;
          font-weight: 600;
          color: $primary-color;
          margin-bottom: 12rpx;
        }

        .tip-action {
          font-size: 26rpx;
          color: $primary-color;
          text-decoration: underline;
        }
      }
    }
  }

  .agreement-row {
    margin-bottom: 48rpx;

    .agreement-label {
      display: flex;
      align-items: flex-start;

      .agreement-text {
        font-size: 24rpx;
        color: $text-secondary;
        line-height: 1.6;
        margin-left: 8rpx;

        .link {
          color: $primary-color;
        }
      }
    }
  }

  .submit-btn {
    width: 100%;
    height: 96rpx;
    background: $primary-color;
    color: #fff;
    font-size: 32rpx;
    font-weight: 600;
    border-radius: 48rpx;
    border: none;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 32rpx;

    &[disabled] {
      background: $text-tertiary;
    }

    .btn-text {
      font-size: 32rpx;
    }
  }

  .switch-mode {
    text-align: center;

    .switch-text {
      font-size: 28rpx;
      color: $primary-color;
    }
  }
}

.footer-section {
  position: fixed;
  bottom: 60rpx;
  left: 0;
  right: 0;
  text-align: center;

  .footer-text {
    font-size: 24rpx;
    color: $text-tertiary;
  }
}
</style>
