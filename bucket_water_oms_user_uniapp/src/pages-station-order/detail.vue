<template>
  <view class="order-detail-page">
    <scroll-view class="content" scroll-y v-if="order">
      <view class="status-banner" :class="getStatusClass(order.status)">
        <text class="status-icon">{{ getStatusIcon(order.status) }}</text>
        <text class="status-text">{{ getStatusText(order.status) }}</text>
      </view>

      <view class="driver-card" v-if="order.deliveryPerson">
        <view class="driver-info">
          <image class="driver-avatar" :src="order.deliveryPerson.avatar || '/static/images/default-avatar.png'" mode="aspectFill" />
          <view class="driver-content">
            <text class="driver-name">{{ order.deliveryPerson.name }}</text>
            <text class="driver-phone">{{ order.deliveryPerson.phone }}</text>
          </view>
          <text class="call-btn" @click="callDriver">📞</text>
        </view>
      </view>

      <view class="address-card">
        <text class="icon">📍</text>
        <view class="address-content">
          <view class="contact">
            <text class="name">{{ order.address.contactName }}</text>
            <text class="phone">{{ order.address.contactPhone }}</text>
          </view>
          <text class="detail">{{ formatAddress(order.address) }}</text>
        </view>
      </view>

      <view class="order-card">
        <view class="store-name">{{ order.stationName }}</view>
        <view class="product-list">
          <view class="product-item" v-for="item in order.items" :key="item.id">
            <text class="name">{{ item.productName }} x{{ item.quantity }}</text>
            <text class="price">¥{{ item.subtotal.toFixed(2) }}</text>
          </view>
        </view>
        <view class="total-row">
          <text>合计</text>
          <text class="total-amount">¥{{ order.payAmount.toFixed(2) }}</text>
        </view>
      </view>

      <view class="info-card">
        <view class="info-row">
          <text class="label">订单编号</text>
          <text class="value">{{ order.orderNo }}</text>
        </view>
        <view class="info-row">
          <text class="label">下单时间</text>
          <text class="value">{{ formatTime(order.createdAt) }}</text>
        </view>
        <view class="info-row" v-if="order.payTime">
          <text class="label">支付时间</text>
          <text class="value">{{ formatTime(order.payTime) }}</text>
        </view>
      </view>
    </scroll-view>

    <view class="bottom-bar" v-if="order">
      <button class="confirm-btn" v-if="order.status === 'delivering'" @click="confirmReceive">确认收货</button>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { stationOrderService, StationOrder } from '@/services/stationOrderService'
import { format } from '@/utils/format'

const orderId = ref('')
const order = ref<StationOrder | null>(null)

const getStatusIcon = (status: string) => {
  const map: Record<string, string> = { pending_dispatch: '📋', delivering: '🚚', completed: '✅', cancelled: '❌' }
  return map[status] || '⏰'
}

const getStatusText = (status: string) => {
  const map: Record<string, string> = {
    pending_pay: '待支付', pending_dispatch: '待派单', delivering: '配送中', completed: '已完成', cancelled: '已取消'
  }
  return map[status] || status
}

const getStatusClass = (status: string) => {
  if (status === 'completed') return 'success'
  if (status === 'cancelled') return 'gray'
  if (status === 'delivering') return 'primary'
  return 'warning'
}

const formatAddress = (addr: any) => `${addr.province}${addr.city}${addr.district}${addr.detail}`
const formatTime = (time: string) => format.datetime(time)

const callDriver = () => {
  if (order.value?.deliveryPerson?.phone) {
    uni.makePhoneCall({ phoneNumber: order.value.deliveryPerson.phone })
  }
}

const confirmReceive = async () => {
  uni.showModal({
    title: '提示',
    content: '确认收到货物了吗？',
    success: async (res) => {
      if (res.confirm) {
        await stationOrderService.confirmReceive(orderId.value)
        uni.showToast({ title: '已确认收货' })
        loadDetail()
      }
    }
  })
}

const loadDetail = async () => {
  const result = await stationOrderService.getOrderDetail(orderId.value)
  if (result) order.value = result
}

onMounted(() => {
  const pages = getCurrentPages()
  const options = (pages[pages.length - 1] as any)?.options || {}
  orderId.value = options.id || ''
  if (orderId.value) loadDetail()
})
</script>

<style lang="scss" scoped>
.order-detail-page { min-height: 100vh; background: $bg-color; padding-bottom: 120rpx; }
.status-banner { display: flex; align-items: center; padding: 48rpx 32rpx; color: #fff; &.primary { background: $primary-color; } &.success { background: $success-color; } &.warning { background: $warning-color; } &.gray { background: $text-tertiary; } .status-icon { font-size: 48rpx; margin-right: 16rpx; } .status-text { font-size: 32rpx; font-weight: 600; } }
.driver-card { background: #fff; margin: 24rpx; border-radius: $radius-lg; padding: 24rpx; }
.driver-info { display: flex; align-items: center; }
.driver-avatar { width: 80rpx; height: 80rpx; border-radius: 50%; background: #f5f5f5; margin-right: 20rpx; }
.driver-content { flex: 1; .driver-name { display: block; font-size: 30rpx; font-weight: 600; color: $text-primary; margin-bottom: 8rpx; } .driver-phone { font-size: 26rpx; color: $text-secondary; } }
.call-btn { font-size: 48rpx; }
.address-card { background: #fff; margin: 0 24rpx 24rpx; border-radius: $radius-lg; padding: 24rpx; display: flex; .icon { font-size: 32rpx; margin-right: 16rpx; } .contact { display: flex; gap: 16rpx; margin-bottom: 8rpx; .name { font-weight: 600; font-size: 30rpx; } .phone { font-size: 26rpx; color: $text-secondary; } } .detail { font-size: 26rpx; color: $text-secondary; } }
.order-card { background: #fff; margin: 0 24rpx 24rpx; border-radius: $radius-lg; padding: 24rpx; .store-name { font-size: 28rpx; font-weight: 600; margin-bottom: 20rpx; padding-bottom: 20rpx; border-bottom: 1rpx solid $border-color; } .product-item { display: flex; justify-content: space-between; padding: 12rpx 0; .name { font-size: 28rpx; } .price { font-size: 28rpx; } } .total-row { display: flex; justify-content: space-between; padding-top: 16rpx; margin-top: 16rpx; border-top: 1rpx solid $border-color; font-size: 28rpx; .total-amount { font-size: 36rpx; font-weight: 700; color: $error-color; } } }
.info-card { background: #fff; margin: 0 24rpx; border-radius: $radius-lg; padding: 24rpx; .info-row { display: flex; justify-content: space-between; padding: 12rpx 0; .label { font-size: 26rpx; color: $text-secondary; } .value { font-size: 26rpx; } } }
.bottom-bar { position: fixed; bottom: 0; left: 0; right: 0; padding: 16rpx 24rpx; background: #fff; box-shadow: 0 -2rpx 12rpx rgba(0,0,0,0.06); }
.confirm-btn { width: 100%; height: 88rpx; background: $primary-color; color: #fff; font-size: 32rpx; font-weight: 600; border-radius: 44rpx; border: none; }
</style>
