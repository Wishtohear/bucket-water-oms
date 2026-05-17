<template>
  <view class="order-detail-page">
    <scroll-view class="content" scroll-y v-if="order">
      <view class="status-section">
        <view class="status-icon">
          <text v-if="order.status === 'completed'">✅</text>
          <text v-else-if="order.status === 'cancelled'">❌</text>
          <text v-else-if="order.status === 'refunded'">💰</text>
          <text v-else>🚚</text>
        </view>
        <view class="status-text">
          <text class="status-main">{{ statusText }}</text>
          <text class="status-sub">{{ statusDesc }}</text>
        </view>
      </view>

      <view class="address-card">
        <view class="address-header">
          <text class="icon">📍</text>
          <text class="label">收货地址</text>
        </view>
        <view class="address-info">
          <view class="contact-row">
            <text class="contact-name">{{ order.address.contactName }}</text>
            <text class="contact-phone">{{ order.address.contactPhone }}</text>
          </view>
          <text class="address-detail">{{ formatAddress(order.address) }}</text>
        </view>
      </view>

      <view class="store-card">
        <view class="store-header">
          <text class="store-name">{{ order.stationName }}</text>
        </view>
        <view class="product-list">
          <view class="product-item" v-for="item in order.items" :key="item.id">
            <view class="product-info">
              <text class="product-name">{{ item.productName }}</text>
              <text class="product-qty">x{{ item.quantity }}</text>
            </view>
            <text class="product-price">¥{{ item.subtotal.toFixed(2) }}</text>
          </view>
        </view>
      </view>

      <view class="order-info-card">
        <view class="info-row">
          <text class="info-label">订单编号</text>
          <view class="info-value">
            <text>{{ order.orderNo }}</text>
            <text class="copy-btn" @click="copyOrderNo">复制</text>
          </view>
        </view>
        <view class="info-row">
          <text class="info-label">下单时间</text>
          <text class="info-value">{{ formatTime(order.createdAt) }}</text>
        </view>
        <view class="info-row" v-if="order.payTime">
          <text class="info-label">支付时间</text>
          <text class="info-value">{{ formatTime(order.payTime) }}</text>
        </view>
      </view>

      <view class="amount-card">
        <view class="amount-row">
          <text class="amount-label">商品金额</text>
          <text class="amount-value">¥{{ order.totalAmount.toFixed(2) }}</text>
        </view>
        <view class="amount-row">
          <text class="amount-label">配送费</text>
          <text class="amount-value">¥{{ order.freight.toFixed(2) }}</text>
        </view>
        <view class="amount-row total">
          <text class="amount-label">实付金额</text>
          <text class="amount-value">¥{{ order.payAmount.toFixed(2) }}</text>
        </view>
      </view>

      <view class="remark-card" v-if="order.remark">
        <text class="remark-label">备注</text>
        <text class="remark-content">{{ order.remark }}</text>
      </view>
    </scroll-view>

    <view class="loading-state" v-if="!order">
      <text>加载中...</text>
    </view>

    <view class="bottom-bar" v-if="order">
      <view class="action-buttons" v-if="showActions">
        <button class="action-btn outline" v-if="order.status === 'pending_pay'" @click="cancelOrder">
          取消订单
        </button>
        <button class="action-btn primary" v-if="order.status === 'delivering'" @click="confirmReceive">
          确认收货
        </button>
        <button class="action-btn outline" v-if="order.status === 'completed'" @click="evaluateOrder">
          评价订单
        </button>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { orderService, Order } from '@/services/orderService'
import { format } from '@/utils/format'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()

const orderId = ref('')
const order = ref<Order | null>(null)

const statusText = computed(() => {
  if (!order.value) return ''
  const statusMap: Record<string, string> = {
    'pending_pay': '待支付',
    'paid': '已支付',
    'processing': '处理中',
    'delivering': '配送中',
    'completed': '已完成',
    'cancelled': '已取消',
    'refunded': '已退款'
  }
  return statusMap[order.value.status] || order.value.status
})

const statusDesc = computed(() => {
  if (!order.value) return ''
  const descMap: Record<string, string> = {
    'pending_pay': '请尽快完成支付',
    'paid': '商家正在准备中',
    'processing': '商品准备中，请耐心等待',
    'delivering': '配送员正在送货中',
    'completed': '感谢您的购买',
    'cancelled': '订单已取消',
    'refunded': '退款已原路退回'
  }
  return descMap[order.value.status] || ''
})

const showActions = computed(() => {
  if (!order.value) return false
  return ['pending_pay', 'delivering', 'completed'].includes(order.value.status)
})

const formatAddress = (addr: any) => {
  return `${addr.province || ''}${addr.city || ''}${addr.district || ''}${addr.detail || ''}`
}

const formatTime = (time: string) => {
  return format.datetime(time)
}

const copyOrderNo = () => {
  if (order.value?.orderNo) {
    uni.setClipboardData({
      data: order.value.orderNo,
      success: () => {
        uni.showToast({ title: '已复制', icon: 'success' })
      }
    })
  }
}

const cancelOrder = () => {
  uni.showModal({
    title: '提示',
    content: '确定要取消该订单吗？',
    success: async (res) => {
      if (res.confirm) {
        try {
          await orderService.cancelOrder(orderId.value)
          loadOrderDetail()
          uni.showToast({ title: '订单已取消', icon: 'success' })
        } catch (error) {
          uni.showToast({ title: '取消失败', icon: 'none' })
        }
      }
    }
  })
}

const confirmReceive = () => {
  uni.showModal({
    title: '提示',
    content: '确认已收到货物吗？',
    success: async (res) => {
      if (res.confirm) {
        try {
          await orderService.confirmOrder(orderId.value)
          loadOrderDetail()
          uni.showToast({ title: '已确认收货', icon: 'success' })
        } catch (error) {
          uni.showToast({ title: '确认失败', icon: 'none' })
        }
      }
    }
  })
}

const evaluateOrder = () => {
  uni.navigateTo({
    url: `/pages/order/evaluate?id=${orderId.value}`
  })
}

const loadOrderDetail = async () => {
  try {
    const result = await orderService.getOrderDetail(orderId.value)
    if (result) {
      order.value = result
    }
  } catch (error) {
    console.error('获取订单详情失败:', error)
  }
}

onMounted(() => {
  if (!authStore.isLoggedIn) {
    uni.navigateTo({ url: '/pages-auth/login' })
    return
  }

  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1] as any
  const options = currentPage?.options || {}

  orderId.value = options.id || ''

  if (orderId.value) {
    loadOrderDetail()
  }
})
</script>

<style lang="scss" scoped>
.order-detail-page {
  min-height: 100vh;
  background-color: $bg-color;
  padding-bottom: 120rpx;
}

.content {
  flex: 1;
}

.status-section {
  display: flex;
  align-items: center;
  background: linear-gradient(135deg, $primary-color, #4db8ff);
  padding: 48rpx 32rpx;
  color: #fff;
}

.status-icon {
  font-size: 80rpx;
  margin-right: 24rpx;
}

.status-text {
  .status-main {
    display: block;
    font-size: 36rpx;
    font-weight: 700;
    margin-bottom: 8rpx;
  }

  .status-sub {
    font-size: 26rpx;
    opacity: 0.9;
  }
}

.address-card,
.store-card,
.order-info-card,
.amount-card,
.remark-card {
  background-color: #fff;
  margin: 16rpx;
  border-radius: $radius-lg;
  padding: 24rpx;
}

.address-card {
  .address-header {
    display: flex;
    align-items: center;
    margin-bottom: 16rpx;

    .icon {
      font-size: 28rpx;
      margin-right: 12rpx;
    }

    .label {
      font-size: 28rpx;
      font-weight: 600;
      color: $text-primary;
    }
  }

  .contact-row {
    display: flex;
    align-items: center;
    margin-bottom: 8rpx;

    .contact-name {
      font-size: 30rpx;
      font-weight: 600;
      color: $text-primary;
      margin-right: 16rpx;
    }

    .contact-phone {
      font-size: 28rpx;
      color: $text-secondary;
    }
  }

  .address-detail {
    font-size: 26rpx;
    color: $text-secondary;
  }
}

.store-card {
  .store-header {
    margin-bottom: 16rpx;
    padding-bottom: 16rpx;
    border-bottom: 1rpx solid $border-color;

    .store-name {
      font-size: 28rpx;
      font-weight: 600;
      color: $text-primary;
    }
  }
}

.product-list {
  .product-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12rpx 0;

    .product-info {
      flex: 1;
    }

    .product-name {
      font-size: 28rpx;
      color: $text-primary;
      margin-right: 24rpx;
    }

    .product-qty {
      font-size: 24rpx;
      color: $text-tertiary;
    }

    .product-price {
      font-size: 28rpx;
      font-weight: 600;
      color: $text-primary;
    }
  }
}

.order-info-card {
  .info-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12rpx 0;
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
      display: flex;
      align-items: center;
      gap: 12rpx;

      .copy-btn {
        padding: 4rpx 12rpx;
        background-color: rgba($primary-color, 0.1);
        color: $primary-color;
        font-size: 22rpx;
        border-radius: $radius-sm;
      }
    }
  }
}

.amount-card {
  .amount-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12rpx 0;

    .amount-label {
      font-size: 26rpx;
      color: $text-secondary;
    }

    .amount-value {
      font-size: 26rpx;
      color: $text-primary;
    }

    &.total {
      padding-top: 16rpx;
      margin-top: 8rpx;
      border-top: 1rpx solid $border-color;

      .amount-label {
        font-size: 28rpx;
        font-weight: 600;
        color: $text-primary;
      }

      .amount-value {
        font-size: 36rpx;
        font-weight: 700;
        color: $error-color;
      }
    }
  }
}

.remark-card {
  display: flex;
  flex-direction: column;

  .remark-label {
    font-size: 26rpx;
    color: $text-secondary;
    margin-bottom: 8rpx;
  }

  .remark-content {
    font-size: 26rpx;
    color: $text-primary;
    line-height: 1.6;
  }
}

.loading-state {
  text-align: center;
  padding: 100rpx 0;
  color: $text-tertiary;
  font-size: 28rpx;
}

.bottom-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 16rpx 24rpx;
  padding-bottom: calc(16rpx + constant(safe-area-inset-bottom));
  padding-bottom: calc(16rpx + env(safe-area-inset-bottom));
  background-color: #fff;
  box-shadow: 0 -2rpx 12rpx rgba(0,0,0,0.06);
}

.action-buttons {
  display: flex;
  justify-content: flex-end;
  gap: 16rpx;
}

.action-btn {
  min-width: 160rpx;
  height: 72rpx;
  padding: 0 32rpx;
  font-size: 28rpx;
  border-radius: 36rpx;
  display: flex;
  align-items: center;
  justify-content: center;

  &.outline {
    background-color: transparent;
    border: 2rpx solid $border-color;
    color: $text-secondary;
  }

  &.primary {
    background-color: $primary-color;
    color: #fff;
    border: none;
  }
}
</style>
