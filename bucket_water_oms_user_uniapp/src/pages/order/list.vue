<template>
  <view class="page">
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

    <scroll-view
      class="order-list"
      scroll-y
      refresher-enabled
      :refresher-triggered="isRefreshing"
      @refresherrefresh="onRefresh"
      @scrolltolower="loadMore"
    >
      <view class="order-card" v-for="order in orders" :key="order.id" @click="goToDetail(order.id)">
        <view class="order-header">
          <text class="station-name">{{ order.stationName }}</text>
          <text class="order-status" :class="getStatusClass(order.status)">
            {{ formatStatus(order.status) }}
          </text>
        </view>

        <view class="order-items">
          <view class="item" v-for="item in order.items.slice(0, 3)" :key="item.id">
            <text class="item-name">{{ item.productName }}</text>
            <text class="item-qty">x{{ item.quantity }}</text>
          </view>
          <text class="more-items" v-if="order.items.length > 3">共{{ order.items.length }}件商品</text>
        </view>

        <view class="order-footer">
          <text class="order-time">{{ formatTime(order.createdAt) }}</text>
          <text class="order-amount">¥{{ order.payAmount.toFixed(2) }}</text>
        </view>

        <view class="order-actions" v-if="showActions(order.status)">
          <button class="action-btn btn-outline" v-if="order.status === 'pending_pay'" @click.stop="cancelOrder(order.id)">
            取消订单
          </button>
          <button class="action-btn btn-primary" v-if="order.status === 'delivering'" @click.stop="confirmOrder(order.id)">
            确认收货
          </button>
        </view>
      </view>

      <view class="no-more" v-if="noMore && orders.length > 0">
        <text>没有更多了</text>
      </view>

      <view class="empty-state" v-if="!loading && orders.length === 0">
        <text class="empty-icon">📋</text>
        <text class="empty-text">暂无订单</text>
        <button class="btn btn-primary" @click="goHome">去下单</button>
      </view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { orderService, Order } from '@/services/orderService'
import { format } from '@/utils/format'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()

const tabs = [
  { label: '全部', value: '' },
  { label: '待支付', value: 'pending_pay' },
  { label: '配送中', value: 'delivering' },
  { label: '已完成', value: 'completed' }
]

const currentTab = ref('')
const orders = ref<Order[]>([])
const loading = ref(false)
const isRefreshing = ref(false)
const page = ref(1)
const pageSize = 10
const noMore = ref(false)

const loadOrders = async (reset = false) => {
  if (!authStore.isLoggedIn) {
    uni.navigateTo({ url: '/pages-auth/login' })
    return
  }

  if (loading.value) return

  if (reset) {
    page.value = 1
    noMore.value = false
  }

  loading.value = true

  try {
    const result = await orderService.getOrders({
      status: currentTab.value || undefined,
      page: page.value,
      pageSize
    })

    if (result) {
      if (reset) {
        orders.value = result.list
      } else {
        orders.value = [...orders.value, ...result.list]
      }

      if (result.list.length < pageSize) {
        noMore.value = true
      }
    }
  } catch (error) {
    console.error('加载订单失败:', error)
  } finally {
    loading.value = false
    isRefreshing.value = false
  }
}

const onRefresh = async () => {
  isRefreshing.value = true
  await loadOrders(true)
}

const loadMore = async () => {
  if (noMore.value || loading.value) return
  page.value++
  await loadOrders()
}

const switchTab = async (status: string) => {
  currentTab.value = status
  await loadOrders(true)
}

const goToDetail = (orderId: string) => {
  uni.navigateTo({
    url: `/pages-order/detail?id=${orderId}`
  })
}

const goHome = () => {
  uni.switchTab({
    url: '/pages/index/index'
  })
}

const cancelOrder = async (orderId: string) => {
  uni.showModal({
    title: '提示',
    content: '确定要取消该订单吗？',
    success: async (res) => {
      if (res.confirm) {
        try {
          await orderService.cancelOrder(orderId)
          uni.showToast({ title: '订单已取消', icon: 'success' })
          await loadOrders(true)
        } catch (error) {
          uni.showToast({ title: '取消失败', icon: 'none' })
        }
      }
    }
  })
}

const confirmOrder = async (orderId: string) => {
  uni.showModal({
    title: '提示',
    content: '确认已收到货物吗？',
    success: async (res) => {
      if (res.confirm) {
        try {
          await orderService.confirmOrder(orderId)
          uni.showToast({ title: '已确认收货', icon: 'success' })
          await loadOrders(true)
        } catch (error) {
          uni.showToast({ title: '确认失败', icon: 'none' })
        }
      }
    }
  })
}

const showActions = (status: string) => {
  return ['pending_pay', 'delivering'].includes(status)
}

const formatStatus = (status: string) => format.orderStatus(status)

const formatTime = (time: string) => format.datetime(time)

const getStatusClass = (status: string) => {
  const classMap: Record<string, string> = {
    'pending_pay': 'status-warning',
    'delivering': 'status-primary',
    'completed': 'status-success',
    'cancelled': 'status-gray'
  }
  return classMap[status] || ''
}

onMounted(() => {
  loadOrders(true)
})
</script>

<style lang="scss" scoped>
.page {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background-color: $bg-color;
}

.tabs {
  display: flex;
  background-color: #fff;
  padding: 0 32rpx;
  border-bottom: 1rpx solid $border-color;
}

.tab-item {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  height: 88rpx;
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
      left: 50%;
      transform: translateX(-50%);
      width: 48rpx;
      height: 4rpx;
      background-color: $primary-color;
      border-radius: 2rpx;
    }
  }
}

.order-list {
  flex: 1;
  padding: 24rpx;
}

.order-card {
  background-color: #fff;
  border-radius: $radius-lg;
  padding: 24rpx;
  margin-bottom: 24rpx;
  box-shadow: $shadow-sm;
}

.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16rpx;

  .station-name {
    font-size: 28rpx;
    font-weight: 600;
    color: $text-primary;
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
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 8rpx;

    &:last-child { margin-bottom: 0; }
  }

  .item-name {
    font-size: 26rpx;
    color: $text-primary;
  }

  .item-qty {
    font-size: 26rpx;
    color: $text-secondary;
  }

  .more-items {
    font-size: 24rpx;
    color: $text-tertiary;
    margin-top: 8rpx;
  }
}

.order-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
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

.order-actions {
  display: flex;
  justify-content: flex-end;
  gap: 16rpx;
  margin-top: 16rpx;

  .action-btn {
    padding: 12rpx 32rpx;
    border-radius: 32rpx;
    font-size: 24rpx;
  }

  .btn-outline {
    border: 1rpx solid $border-color;
    color: $text-secondary;
    background: transparent;
  }

  .btn-primary {
    background-color: $primary-color;
    color: #fff;
  }
}

.no-more,
.empty-state {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 40rpx 0;
  color: $text-tertiary;
  font-size: 28rpx;
}

.empty-state {
  flex-direction: column;

  .empty-icon {
    font-size: 120rpx;
    margin-bottom: 24rpx;
  }

  .empty-text {
    margin-bottom: 32rpx;
  }
}
</style>
