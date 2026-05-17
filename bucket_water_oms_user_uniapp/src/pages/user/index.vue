<template>
  <view class="user-page">
    <view class="user-header" v-if="authStore.isLoggedIn">
      <image class="avatar" :src="authStore.userInfo?.avatar || '/static/images/default-avatar.png'" mode="aspectFill"></image>
      <view class="user-info">
        <text class="nickname">{{ authStore.userInfo?.nickname || authStore.userInfo?.phone || '用户' }}</text>
        <text class="phone">{{ formatPhone(authStore.userInfo?.phone || '') }}</text>
      </view>
      <text class="edit-btn" @click="editProfile">编辑</text>
    </view>

    <view class="user-header login-tip" v-else @click="goLogin">
      <image class="avatar" src="/static/images/default-avatar.png" mode="aspectFill"></image>
      <view class="user-info">
        <text class="nickname">点击登录</text>
        <text class="phone">登录后享受更多服务</text>
      </view>
    </view>

    <view class="order-section">
      <view class="section-header">
        <text class="section-title">我的订单</text>
        <text class="see-all" @click="goOrderList">查看全部</text>
      </view>
      <view class="order-tabs">
        <view class="tab-item" @click="goOrderList('pending_pay')">
          <text class="tab-icon">💳</text>
          <text class="tab-text">待支付</text>
        </view>
        <view class="tab-item" @click="goOrderList('delivering')">
          <text class="tab-icon">🚚</text>
          <text class="tab-text">配送中</text>
        </view>
        <view class="tab-item" @click="goOrderList('completed')">
          <text class="tab-icon">✅</text>
          <text class="tab-text">已完成</text>
        </view>
        <view class="tab-item" @click="goOrderList('')">
          <text class="tab-icon">📋</text>
          <text class="tab-text">全部</text>
        </view>
      </view>
    </view>

    <view class="menu-section">
      <view class="menu-item" @click="goAddress">
        <text class="menu-icon">📍</text>
        <text class="menu-text">收货地址</text>
        <text class="menu-arrow">></text>
      </view>
      <view class="menu-item" @click="goFavorites">
        <text class="menu-icon">❤️</text>
        <text class="menu-text">收藏的水站</text>
        <text class="menu-arrow">></text>
      </view>
      <view class="menu-item" @click="goMyTickets">
        <text class="menu-icon">🎫</text>
        <text class="menu-text">我的水票</text>
        <text class="menu-arrow">></text>
      </view>
    </view>

    <view class="menu-section">
      <view class="menu-item" @click="goSettings">
        <text class="menu-icon">⚙️</text>
        <text class="menu-text">设置</text>
        <text class="menu-arrow">></text>
      </view>
      <view class="menu-item" @click="goAbout">
        <text class="menu-icon">ℹ️</text>
        <text class="menu-text">关于我们</text>
        <text class="menu-arrow">></text>
      </view>
      <view class="menu-item" @click="goHelp">
        <text class="menu-icon">❓</text>
        <text class="menu-text">帮助与反馈</text>
        <text class="menu-arrow">></text>
      </view>
    </view>

    <button class="logout-btn" v-if="authStore.isLoggedIn" @click="logout">退出登录</button>
  </view>
</template>

<script setup lang="ts">
import { useAuthStore } from '@/stores/auth'
import { useCartStore } from '@/stores/cart'

const authStore = useAuthStore()
const cartStore = useCartStore()

const formatPhone = (phone: string) => {
  if (!phone) return ''
  return phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2')
}

const goLogin = () => {
  uni.navigateTo({ url: '/pages-auth/login' })
}

const editProfile = () => {
  uni.showToast({ title: '功能开发中', icon: 'none' })
}

const goOrderList = (status?: string) => {
  if (!authStore.isLoggedIn) {
    uni.navigateTo({ url: '/pages-auth/login' })
    return
  }
  const url = status ? `/pages/order/list?status=${status}` : '/pages/order/list'
  uni.switchTab({ url: '/pages/order/list' })
}

const goAddress = () => {
  if (!authStore.isLoggedIn) {
    uni.navigateTo({ url: '/pages-auth/login' })
    return
  }
  uni.navigateTo({ url: '/pages-address/list' })
}

const goFavorites = () => {
  if (!authStore.isLoggedIn) {
    uni.navigateTo({ url: '/pages-auth/login' })
    return
  }
  uni.navigateTo({ url: '/pages-station/favorites' })
}

const goMyTickets = () => {
  if (!authStore.isLoggedIn) {
    uni.navigateTo({ url: '/pages-auth/login' })
    return
  }
  uni.navigateTo({ url: '/pages-ticket/my-tickets' })
}

const goSettings = () => {
  uni.navigateTo({ url: '/pages/user/settings' })
}

const goAbout = () => {
  uni.showToast({ title: '功能开发中', icon: 'none' })
}

const goHelp = () => {
  uni.showToast({ title: '功能开发中', icon: 'none' })
}

const logout = () => {
  uni.showModal({
    title: '提示',
    content: '确定要退出登录吗？',
    success: (res) => {
      if (res.confirm) {
        authStore.logout()
        cartStore.clearCart()
        uni.showToast({ title: '已退出登录', icon: 'success' })
      }
    }
  })
}
</script>

<style lang="scss" scoped>
.user-page {
  min-height: 100vh;
  background-color: $bg-color;
  padding-bottom: 40rpx;
}

.user-header {
  display: flex;
  align-items: center;
  padding: 48rpx 32rpx;
  background: linear-gradient(135deg, $primary-color, #4db8ff);

  &.login-tip {
    background: linear-gradient(135deg, #909090, #b0b0b0);
  }
}

.avatar {
  width: 120rpx;
  height: 120rpx;
  border-radius: 60rpx;
  background-color: #fff;
}

.user-info {
  flex: 1;
  margin-left: 24rpx;

  .nickname {
    display: block;
    font-size: 36rpx;
    font-weight: 600;
    color: #fff;
    margin-bottom: 8rpx;
  }

  .phone {
    font-size: 26rpx;
    color: rgba(255, 255, 255, 0.8);
  }
}

.edit-btn {
  font-size: 26rpx;
  color: #fff;
  padding: 8rpx 24rpx;
  border: 1rpx solid rgba(255, 255, 255, 0.5);
  border-radius: 24rpx;
}

.order-section {
  background-color: #fff;
  margin: 24rpx;
  border-radius: $radius-lg;
  padding: 24rpx;
  box-shadow: $shadow-sm;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24rpx;

  .section-title {
    font-size: 32rpx;
    font-weight: 600;
    color: $text-primary;
  }

  .see-all {
    font-size: 26rpx;
    color: $text-tertiary;
  }
}

.order-tabs {
  display: flex;
  justify-content: space-around;
}

.tab-item {
  display: flex;
  flex-direction: column;
  align-items: center;

  .tab-icon {
    font-size: 48rpx;
    margin-bottom: 8rpx;
  }

  .tab-text {
    font-size: 24rpx;
    color: $text-secondary;
  }
}

.menu-section {
  background-color: #fff;
  margin: 24rpx;
  border-radius: $radius-lg;
  overflow: hidden;
  box-shadow: $shadow-sm;
}

.menu-item {
  display: flex;
  align-items: center;
  padding: 32rpx 24rpx;
  border-bottom: 1rpx solid $border-color;

  &:last-child {
    border-bottom: none;
  }

  .menu-icon {
    font-size: 40rpx;
    margin-right: 20rpx;
  }

  .menu-text {
    flex: 1;
    font-size: 28rpx;
    color: $text-primary;
  }

  .menu-arrow {
    font-size: 28rpx;
    color: $text-tertiary;
  }
}

.logout-btn {
  display: block;
  width: calc(100% - 48rpx);
  margin: 48rpx 24rpx;
  height: 88rpx;
  background-color: #fff;
  color: $error-color;
  font-size: 30rpx;
  border-radius: $radius-lg;
  border: none;
  box-shadow: $shadow-sm;
}
</style>
