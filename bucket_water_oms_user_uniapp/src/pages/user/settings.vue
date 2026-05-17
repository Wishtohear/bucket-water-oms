<template>
  <view class="settings-page">
    <view class="settings-section">
      <view class="section-title">通知设置</view>
      <view class="setting-item">
        <text class="setting-label">订单通知</text>
        <switch :checked="settings.orderNotification" @change="toggleSetting('orderNotification')" color="#1890FF" />
      </view>
      <view class="setting-item">
        <text class="setting-label">促销活动通知</text>
        <switch :checked="settings.promotionNotification" @change="toggleSetting('promotionNotification')" color="#1890FF" />
      </view>
    </view>

    <view class="settings-section">
      <view class="section-title">通用设置</view>
      <view class="setting-item" @click="clearCache">
        <text class="setting-label">清除缓存</text>
        <view class="setting-value">
          <text class="cache-size">{{ cacheSize }}</text>
          <text class="arrow">></text>
        </view>
      </view>
      <view class="setting-item" @click="checkUpdate">
        <text class="setting-label">检查更新</text>
        <view class="setting-value">
          <text class="version">v1.0.0</text>
          <text class="arrow">></text>
        </view>
      </view>
    </view>

    <view class="settings-section">
      <view class="section-title">关于</view>
      <view class="setting-item" @click="showAgreement">
        <text class="setting-label">用户协议</text>
        <text class="arrow">></text>
      </view>
      <view class="setting-item" @click="showPrivacy">
        <text class="setting-label">隐私政策</text>
        <text class="arrow">></text>
      </view>
      <view class="setting-item">
        <text class="setting-label">关于我们</text>
        <view class="setting-value">
          <text class="arrow">></text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const settings = ref({
  orderNotification: true,
  promotionNotification: true
})

const cacheSize = ref('2.5MB')

const toggleSetting = (key: keyof typeof settings.value) => {
  settings.value[key] = !settings.value[key]
}

const clearCache = () => {
  uni.showModal({
    title: '清除缓存',
    content: '确定要清除缓存吗？',
    success: (res) => {
      if (res.confirm) {
        uni.showToast({ title: '缓存已清除', icon: 'success' })
        cacheSize.value = '0 KB'
      }
    }
  })
}

const checkUpdate = () => {
  uni.showToast({ title: '已是最新版本', icon: 'success' })
}

const showAgreement = () => {
  uni.showToast({ title: '用户协议开发中', icon: 'none' })
}

const showPrivacy = () => {
  uni.showToast({ title: '隐私政策开发中', icon: 'none' })
}
</script>

<style lang="scss" scoped>
.settings-page {
  min-height: 100vh;
  background-color: $bg-color;
}

.settings-section {
  margin: 24rpx;
  background-color: #fff;
  border-radius: $radius-lg;
  overflow: hidden;
}

.section-title {
  padding: 24rpx;
  font-size: 28rpx;
  font-weight: 600;
  color: $text-primary;
  border-bottom: 1rpx solid $border-color;
}

.setting-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 28rpx 24rpx;
  border-bottom: 1rpx solid $border-color;

  &:last-child {
    border-bottom: none;
  }

  .setting-label {
    font-size: 28rpx;
    color: $text-primary;
  }

  .setting-value {
    display: flex;
    align-items: center;
  }

  .cache-size,
  .version {
    font-size: 26rpx;
    color: $text-tertiary;
    margin-right: 8rpx;
  }

  .arrow {
    font-size: 24rpx;
    color: $text-tertiary;
  }
}
</style>
