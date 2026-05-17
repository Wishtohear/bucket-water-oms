<template>
  <view class="result-page">
    <view class="result-content" :class="status">
      <view class="result-icon">
        <text v-if="status === 'success'">✅</text>
        <text v-else>❌</text>
      </view>
      <text class="result-title">{{ status === 'success' ? '支付成功' : '支付失败' }}</text>
      <text class="result-amount" v-if="status === 'success'">¥{{ amount?.toFixed(2) || '0.00' }}</text>
      <text class="result-message" v-else>{{ message }}</text>
    </view>

    <view class="order-info" v-if="orderNo">
      <view class="info-row">
        <text class="info-label">订单编号</text>
        <text class="info-value">{{ orderNo }}</text>
      </view>
      <view class="info-row" v-if="createTime">
        <text class="info-label">支付时间</text>
        <text class="info-value">{{ createTime }}</text>
      </view>
    </view>

    <view class="action-buttons">
      <button class="btn btn-primary btn-block" @click="viewOrder">查看订单</button>
      <button class="btn btn-outline btn-block" @click="goHome">返回首页</button>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'

const status = ref<'success' | 'fail'>('success')
const amount = ref<number>(0)
const orderNo = ref('')
const message = ref('')
const createTime = ref('')

const viewOrder = () => {
  if (orderNo.value) {
    uni.redirectTo({
      url: `/pages/order/detail?id=${orderNo.value}`
    })
  }
}

const goHome = () => {
  uni.switchTab({
    url: '/pages/index/index'
  })
}

onMounted(() => {
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1] as any
  const options = currentPage?.options || {}

  status.value = options.status === 'success' ? 'success' : 'fail'
  amount.value = parseFloat(options.amount || '0')
  orderNo.value = options.orderNo || ''
  message.value = options.message || (status.value === 'success' ? '' : '支付失败，请稍后重试')
  createTime.value = options.time || ''
})
</script>

<style lang="scss" scoped>
.result-page {
  min-height: 100vh;
  background-color: $bg-color;
  padding: 48rpx 32rpx;
}

.result-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 64rpx 32rpx;
  background-color: #fff;
  border-radius: $radius-lg;
  margin-bottom: 32rpx;

  &.success {
    .result-icon {
      color: $success-color;
    }

    .result-title {
      color: $text-primary;
    }

    .result-amount {
      color: $error-color;
    }
  }

  &.fail {
    .result-icon {
      color: $error-color;
    }

    .result-title {
      color: $error-color;
    }

    .result-message {
      color: $text-secondary;
      font-size: 28rpx;
    }
  }
}

.result-icon {
  font-size: 120rpx;
  margin-bottom: 24rpx;
}

.result-title {
  font-size: 40rpx;
  font-weight: 700;
  margin-bottom: 24rpx;
}

.result-amount {
  font-size: 64rpx;
  font-weight: 700;
  margin-bottom: 16rpx;
}

.order-info {
  background-color: #fff;
  border-radius: $radius-lg;
  padding: 24rpx;
  margin-bottom: 48rpx;
}

.info-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16rpx 0;
  border-bottom: 1rpx solid $border-color;

  &:last-child {
    border-bottom: none;
  }

  .info-label {
    font-size: 26rpx;
    color: $text-secondary;
  }

  .info-value {
    font-size: 26rpx;
    color: $text-primary;
  }
}

.action-buttons {
  display: flex;
  flex-direction: column;
  gap: 24rpx;
}

.btn {
  height: 88rpx;
  border-radius: 44rpx;
  font-size: 32rpx;
  font-weight: 600;
  display: flex;
  align-items: center;
  justify-content: center;
  border: none;
}

.btn-primary {
  background-color: $primary-color;
  color: #fff;
}

.btn-outline {
  background-color: transparent;
  border: 2rpx solid $primary-color;
  color: $primary-color;
}
</style>
