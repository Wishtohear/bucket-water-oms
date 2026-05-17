<template>
  <view class="order-list-page">
    <view class="tabs">
      <view
        class="tab-item"
        :class="{ active: currentTab === item.value }"
        v-for="item in tabs"
        :key="item.value"
        @click="switchTab(item.value)"
      >
        <text>{{ item.label }}</text>
      </view>
    </view>

    <scroll-view class="order-list" scroll-y refresher-enabled @refresherrefresh="onRefresh">
      <view class="loading-state" v-if="loading">
        <text>加载中...</text>
      </view>

      <view class="order-card" v-for="order in orders" :key="order.id" @click="goDetail(order.id)">
        <view class="order-header">
          <text class="station-name">{{ order.stationName }}</text>
          <text class="order-status" :class="getStatusClass(order.status)">{{ getStatusText(order.status) }}</text>
        </view>

        <view class="order-items">
          <view class="item" v-for="item in order.items.slice(0, 3)" :key="item.id">
            <text class="item-name">{{ item.productName }} x{{ item.quantity }}</text>
          </view>
          <text class="more-items" v-if="order.items.length > 3">共{{ order.items.length }}件</text>
        </view>

        <view class="order-footer">
          <text class="order-time">{{ formatTime(order.createdAt) }}</text>
          <text class="order-amount">¥{{ order.payAmount.toFixed(2) }}</text>
        </view>

        <view class="driver-info" v-if="order.deliveryPerson">
          <text class="driver-label">配送员：</text>
          <text class="driver-name">{{ order.deliveryPerson.name }}</text>
          <text class="driver-phone" @click.stop="callDriver(order.deliveryPerson.phone)">📞</text>
        </view>
      </view>

      <view class="empty-state" v-if="!loading && orders.length === 0">
        <text class="empty-icon">📋</text>
        <text class="empty-text">暂无相关订单</text>
      </view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { stationOrderService, StationOrder } from '@/services/stationOrderService'
import { format } from '@/utils/format'

const tabs = [
  { label: '全部', value: '' },
  { label: '待派单', value: 'pending_dispatch' },
  { label: '配送中', value: 'delivering' },
  { label: '已完成', value: 'completed' }
]

const currentTab = ref('')
const orders = ref<StationOrder[]>([])
const loading = ref(false)

const getStatusText = (status: string) => {
  const map: Record<string, string> = {
    pending_pay: '待支付',
    paid: '待支付',
    pending_dispatch: '待派单',
    pending_accept: '待接单',
    delivering: '配送中',
    completed: '已完成',
    cancelled: '已取消'
  }
  return map[status] || status
}

const getStatusClass = (status: string) => {
  if (status === 'delivering') return 'status-primary'
  if (status === 'completed') return 'status-success'
  if (status === 'cancelled') return 'status-gray'
  return 'status-warning'
}

const formatTime = (time: string) => format.datetime(time)

const switchTab = async (status: string) => {
  currentTab.value = status
  await loadOrders(true)
}

const loadOrders = async (reset = false) => {
  loading.value = true
  try {
    const result = await stationOrderService.getOrders({ status: currentTab.value || undefined })
    if (result) {
      orders.value = result.list
    }
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

const onRefresh = async () => {
  await loadOrders(true)
}

const goDetail = (orderId: string) => {
  uni.navigateTo({ url: `/pages-station-order/detail?id=${orderId}` })
}

const callDriver = (phone: string) => {
  uni.makePhoneCall({ phoneNumber: phone })
}

onMounted(() => {
  loadOrders()
})
</script>

<style lang="scss" scoped>
.order-list-page {
  height: 100vh;
  background: $bg-color;
}

.tabs {
  display: flex;
  background: #fff;
  border-bottom: 1rpx solid $border-color;
}

.tab-item {
  flex: 1;
  height: 88rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28rpx;
  color: $text-secondary;
  position: relative;

  &.active {
    color: $primary-color;
    font-weight: 600;
    &::after {
      content: '';
      position: absolute;
      bottom: 0;
      width: 48rpx;
      height: 4rpx;
      background: $primary-color;
      border-radius: 2rpx;
    }
  }
}

.order-list {
  height: calc(100vh - 88rpx);
  padding: 24rpx;
}

.order-card {
  background: #fff;
  border-radius: $radius-lg;
  padding: 24rpx;
  margin-bottom: 24rpx;
  box-shadow: $shadow-sm;
}

.order-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 16rpx;

  .station-name {
    font-size: 28rpx;
    font-weight: 600;
  }

  .order-status {
    font-size: 26rpx;
  }

  .status-primary { color: $primary-color; }
  .status-success { color: $success-color; }
  .status-warning { color: $warning-color; }
  .status-gray { color: $text-tertiary; }
}

.order-items {
  padding: 16rpx 0;
  border-top: 1rpx solid $border-color;
  border-bottom: 1rpx solid $border-color;

  .item {
    margin-bottom: 8rpx;
    font-size: 26rpx;
    color: $text-primary;
  }

  .more-items {
    font-size: 24rpx;
    color: $text-tertiary;
  }
}

.order-footer {
  display: flex;
  justify-content: space-between;
  margin-top: 16rpx;

  .order-time {
    font-size: 24rpx;
    color: $text-tertiary;
  }

  .order-amount {
    font-size: 32rpx;
    font-weight: 600;
    color: $text-primary;
  }
}

.driver-info {
  display: flex;
  align-items: center;
  margin-top: 16rpx;
  padding-top: 16rpx;
  border-top: 1rpx solid $border-color;
  gap: 8rpx;
  font-size: 26rpx;
}

.loading-state, .empty-state {
  text-align: center;
  padding: 100rpx 0;
  color: $text-tertiary;
}

.empty-state {
  .empty-icon {
    font-size: 120rpx;
    display: block;
    margin-bottom: 24rpx;
  }
}
</style>
