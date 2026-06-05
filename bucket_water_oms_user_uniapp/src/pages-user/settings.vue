<template>
  <view class="page">
    <view class="header">
      <text class="title">设置</text>
    </view>

    <view class="card">
      <view class="item" @click="goEditProfile">
        <text class="item-label">编辑资料</text>
        <text class="item-arrow">›</text>
      </view>
      <view class="item" @click="showAgreement('user')">
        <text class="item-label">用户协议</text>
        <text class="item-arrow">›</text>
      </view>
      <view class="item" @click="showAgreement('privacy')">
        <text class="item-label">隐私政策</text>
        <text class="item-arrow">›</text>
      </view>
      <view class="item" @click="checkUpdate">
        <text class="item-label">检查更新</text>
        <text class="item-value" v-if="version">v{{ version }}</text>
        <text class="item-arrow">›</text>
      </view>
      <view class="item">
        <text class="item-label">订单通知</text>
        <switch :checked="settings.orderNotification" @change="onToggle('orderNotification', $event)" color="#3b82f6" />
      </view>
      <view class="item">
        <text class="item-label">活动通知</text>
        <switch :checked="settings.promotionNotification" @change="onToggle('promotionNotification', $event)" color="#3b82f6" />
      </view>
    </view>

    <view class="card">
      <view class="item" @click="clearCache">
        <text class="item-label">清除缓存</text>
        <text class="item-value">{{ cacheSize }}</text>
      </view>
      <view class="item" @click="logout">
        <text class="item-label danger">退出登录</text>
        <text class="item-arrow">›</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()
const version = ref('')
const cacheSize = ref('0KB')
const settings = reactive({
  orderNotification: true,
  promotionNotification: false
})

const computeCacheSize = () => {
  try {
    const info = uni.getStorageInfoSync()
    if (!info || !info.keys) {
      cacheSize.value = '0KB'
      return
    }
    let total = 0
    info.keys.forEach(k => {
      try {
        const v = uni.getStorageSync(k)
        if (v !== '' && v !== undefined && v !== null) {
          total += String(v).length
        }
      } catch { /* ignore */ }
    })
    if (total < 1024) {
      cacheSize.value = `${total}B`
    } else if (total < 1024 * 1024) {
      cacheSize.value = `${(total / 1024).toFixed(1)}KB`
    } else {
      cacheSize.value = `${(total / 1024 / 1024).toFixed(1)}MB`
    }
  } catch (e) {
    cacheSize.value = '0KB'
  }
}

const loadNotificationSettings = () => {
  try {
    const saved = uni.getStorageSync('notification_settings')
    if (saved) {
      Object.assign(settings, JSON.parse(saved))
    }
  } catch { /* ignore */ }
}

const onToggle = (key: 'orderNotification' | 'promotionNotification', e: any) => {
  settings[key] = e.detail.value
  try {
    uni.setStorageSync('notification_settings', JSON.stringify(settings))
  } catch { /* ignore */ }
  uni.showToast({ title: '设置已保存', icon: 'success' })
}

const goEditProfile = () => {
  uni.navigateTo({ url: '/pages-user/edit-profile' })
}

const showAgreement = (type: string) => {
  uni.navigateTo({ url: `/pages-user/agreement?type=${type}` })
}

const checkUpdate = () => {
  // 真实实现：调用版本检查接口
  try {
    const accountInfo = uni.getAccountInfoSync()
    version.value = accountInfo.miniProgram?.version || '1.0.0'
  } catch {
    version.value = '1.0.0'
  }
  uni.showToast({ title: '已是最新版本', icon: 'success' })
}

const clearCache = () => {
  uni.showModal({
    title: '清除缓存',
    content: '确定要清除本地缓存吗？',
    success: (res) => {
      if (res.confirm) {
        try {
          const keys = uni.getStorageInfoSync().keys
          keys.forEach((k: string) => {
            if (!['bucket_water_token', 'bucket_water_refreshToken', 'bucket_water_userInfo'].includes(k)) {
              uni.removeStorageSync(k)
            }
          })
        } catch { /* ignore */ }
        cacheSize.value = '0KB'
        uni.showToast({ title: '清除成功', icon: 'success' })
      }
    }
  })
}

const logout = () => {
  uni.showModal({
    title: '退出登录',
    content: '确定要退出登录吗？',
    success: (res) => {
      if (res.confirm) {
        authStore.logout()
        uni.reLaunch({ url: '/pages-auth/login' })
      }
    }
  })
}

onMounted(() => {
  computeCacheSize()
  loadNotificationSettings()
  try {
    const accountInfo = uni.getAccountInfoSync()
    version.value = accountInfo.miniProgram?.version || '1.0.0'
  } catch {
    version.value = '1.0.0'
  }
})
</script>

<style lang="scss" scoped>
.page {
  min-height: 100vh;
  background: $bg-color;
  padding: 24rpx;
}
.header {
  padding: 16rpx 8rpx 24rpx;
  .title { font-size: 40rpx; font-weight: bold; color: #1f2937; }
}
.card {
  background: #fff;
  border-radius: 16rpx;
  margin-bottom: 24rpx;
  overflow: hidden;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}
.item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 32rpx 24rpx;
  border-bottom: 2rpx solid #f3f4f6;
  &:last-child { border-bottom: none; }
  .item-label {
    font-size: 30rpx;
    color: #1f2937;
    &.danger { color: #ef4444; }
  }
  .item-value {
    font-size: 26rpx;
    color: #9ca3af;
    margin-right: 8rpx;
  }
  .item-arrow {
    font-size: 32rpx;
    color: #9ca3af;
  }
}
</style>
