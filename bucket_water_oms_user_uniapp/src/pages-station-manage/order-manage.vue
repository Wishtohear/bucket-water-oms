<template>
  <view class="order-manage-page">
    <view class="tabs-bar">
      <view class="tab-item" :class="{ active: currentTab === 'all' }" @click="switchTab('all')">
        <text class="tab-text">全部</text>
        <text class="tab-count" v-if="counts.all > 0">{{ counts.all }}</text>
      </view>
      <view class="tab-item" :class="{ active: currentTab === 'pending' }" @click="switchTab('pending')">
        <text class="tab-text">待派单</text>
        <text class="tab-count warning" v-if="counts.pending > 0">{{ counts.pending }}</text>
      </view>
      <view class="tab-item" :class="{ active: currentTab === 'dispatched' }" @click="switchTab('dispatched')">
        <text class="tab-text">已派单</text>
        <text class="tab-count" v-if="counts.dispatched > 0">{{ counts.dispatched }}</text>
      </view>
      <view class="tab-item" :class="{ active: currentTab === 'delivering' }" @click="switchTab('delivering')">
        <text class="tab-text">配送中</text>
        <text class="tab-count" v-if="counts.delivering > 0">{{ counts.delivering }}</text>
      </view>
      <view class="tab-item" :class="{ active: currentTab === 'completed' }" @click="switchTab('completed')">
        <text class="tab-text">已完成</text>
        <text class="tab-count" v-if="counts.completed > 0">{{ counts.completed }}</text>
      </view>
    </view>

    <scroll-view class="order-list" scroll-y @scrolltolower="loadMore" v-if="orders.length > 0">
      <view class="order-card" v-for="order in orders" :key="order.id" @click="viewDetail(order.id)">
        <view class="order-header">
          <text class="order-no">订单号: {{ order.orderNo }}</text>
          <text class="order-status" :class="getStatusClass(order.status)">{{ getStatusText(order.status) }}</text>
        </view>

        <view class="order-items">
          <view class="item-row" v-for="item in order.items.slice(0, 2)" :key="item.id">
            <text class="item-name">{{ item.productName }} x{{ item.quantity }}</text>
            <text class="item-price">¥{{ item.subtotal.toFixed(2) }}</text>
          </view>
          <text class="more-items" v-if="order.items.length > 2">共 {{ order.items.length }} 件商品</text>
        </view>

        <view class="order-footer">
          <view class="customer-info">
            <text class="customer-name">{{ order.address?.contactName || '匿名' }}</text>
            <text class="customer-phone">{{ order.address?.contactPhone || '' }}</text>
          </view>
          <view class="order-total">
            <text class="total-label">合计</text>
            <text class="total-amount">¥{{ order.payAmount.toFixed(2) }}</text>
          </view>
        </view>

        <view class="order-actions" v-if="order.status === 'pending_dispatch'">
          <button class="action-btn dispatch" @click.stop="goDispatch(order.id)">立即派单</button>
        </view>

        <view class="delivery-info" v-if="order.deliveryPerson">
          <text class="delivery-icon">🚚</text>
          <text class="delivery-name">{{ order.deliveryPerson.name }}</text>
          <text class="delivery-phone" @click.stop="callDelivery(order.deliveryPerson.phone)">{{ order.deliveryPerson.phone }}</text>
        </view>
      </view>

      <view class="load-more" v-if="hasMore">
        <text class="loading-text">加载中...</text>
      </view>

      <view class="no-more" v-if="!hasMore && orders.length > 0">
        <text class="no-more-text">没有更多订单了</text>
      </view>
    </scroll-view>

    <view class="empty-state" v-if="orders.length === 0 && !loading">
      <text class="empty-icon">📦</text>
      <text class="empty-text">暂无订单</text>
    </view>

    <view class="loading-overlay" v-if="loading && orders.length === 0">
      <text class="loading-text">加载中...</text>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { stationOrderService, StationOrder } from '@/services/stationOrderService'

const currentTab = ref('all')
const orders = ref<StationOrder[]>([])
const loading = ref(false)
const page = ref(1)
const pageSize = ref(20)
const hasMore = ref(true)

const counts = reactive({
  all: 0,
  pending: 0,
  dispatched: 0,
  delivering: 0,
  completed: 0
})

const statusMap: Record<string, string> = {
  pending_dispatch: '待派单',
  dispatched: '已派单',
  delivering: '配送中',
  completed: '已完成',
  cancelled: '已取消'
}

const getStatusText = (status: string) => statusMap[status] || status

const getStatusClass = (status: string) => {
  const classMap: Record<string, string> = {
    pending_dispatch: 'warning',
    dispatched: 'primary',
    delivering: 'primary',
    completed: 'success',
    cancelled: 'gray'
  }
  return classMap[status] || ''
}

const switchTab = async (tab: string) => {
  if (currentTab.value === tab) return
  currentTab.value = tab
  page.value = 1
  orders.value = []
  hasMore.value = true
  await loadOrders()
}

const loadOrders = async (append = false) => {
  if (loading.value) return
  
  loading.value = true
  
  try {
    const statusMap: Record<string, string> = {
      all: undefined,
      pending: 'pending_dispatch',
      dispatched: 'dispatched',
      delivering: 'delivering',
      completed: 'completed'
    }
    
    const result = await stationOrderService.getStationOrders({
      status: statusMap[currentTab.value],
      page: page.value,
      pageSize: pageSize.value
    })
    
    if (result && result.list) {
      if (append) {
        orders.value = [...orders.value, ...result.list]
      } else {
        orders.value = result.list
      }
      
      hasMore.value = orders.value.length < result.total
      
      if (!append) {
        updateCounts(result.list)
      }
    }
  } catch (error) {
    console.error('加载订单失败:', error)
    uni.showToast({ title: '加载失败', icon: 'error' })
  } finally {
    loading.value = false
  }
}

const updateCounts = (orderList: StationOrder[]) => {
  const newCounts = {
    all: 0,
    pending: 0,
    dispatched: 0,
    delivering: 0,
    completed: 0
  }
  
  orderList.forEach(order => {
    newCounts.all++
    if (order.status === 'pending_dispatch') newCounts.pending++
    else if (order.status === 'dispatched') newCounts.dispatched++
    else if (order.status === 'delivering') newCounts.delivering++
    else if (order.status === 'completed') newCounts.completed++
  })
  
  Object.assign(counts, newCounts)
}

const loadMore = () => {
  if (!hasMore.value || loading.value) return
  page.value++
  loadOrders(true)
}

const viewDetail = (orderId: string) => {
  uni.navigateTo({
    url: `/pages-station-order/detail?id=${orderId}`
  })
}

const goDispatch = (orderId: string) => {
  uni.navigateTo({
    url: `/pages-station-manage/dispatch?orderId=${orderId}`
  })
}

const callDelivery = (phone: string) => {
  uni.makePhoneCall({ phoneNumber: phone })
}

onMounted(() => {
  loadOrders()
})
</script>

<style lang="scss" scoped>
.order-manage-page {
  min-height: 100vh;
  background: $bg-color;
}

.tabs-bar {
  display: flex;
  background: #fff;
  padding: 0 16rpx;
  position: sticky;
  top: 0;
  z-index: 100;
  box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.04);

  .tab-item {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 24rpx 0;
    position: relative;
    transition: all 0.3s;

    .tab-text {
      font-size: 28rpx;
      color: $text-secondary;
      margin-bottom: 4rpx;
    }

    .tab-count {
      font-size: 22rpx;
      color: $text-tertiary;
      background: $bg-color;
      padding: 4rpx 12rpx;
      border-radius: 12rpx;
      min-width: 40rpx;
      text-align: center;

      &.warning {
        background: rgba($warning-color, 0.1);
        color: $warning-color;
      }
    }

    &.active {
      .tab-text {
        color: $primary-color;
        font-weight: 600;
      }

      &::after {
        content: '';
        position: absolute;
        bottom: 0;
        left: 50%;
        transform: translateX(-50%);
        width: 48rpx;
        height: 4rpx;
        background: $primary-color;
        border-radius: 2rpx;
      }
    }
  }
}

.order-list {
  padding: 24rpx;

  .order-card {
    background: #fff;
    border-radius: $radius-lg;
    padding: 24rpx;
    margin-bottom: 24rpx;
    box-shadow: $shadow-sm;

    .order-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 16rpx;
      padding-bottom: 16rpx;
      border-bottom: 1rpx solid $border-color;

      .order-no {
        font-size: 26rpx;
        color: $text-tertiary;
      }

      .order-status {
        font-size: 26rpx;
        padding: 4rpx 16rpx;
        border-radius: 16rpx;

        &.warning {
          background: rgba($warning-color, 0.1);
          color: $warning-color;
        }

        &.primary {
          background: rgba($primary-color, 0.1);
          color: $primary-color;
        }

        &.success {
          background: rgba($success-color, 0.1);
          color: $success-color;
        }

        &.gray {
          background: rgba($text-tertiary, 0.1);
          color: $text-tertiary;
        }
      }
    }

    .order-items {
      margin-bottom: 16rpx;

      .item-row {
        display: flex;
        justify-content: space-between;
        padding: 8rpx 0;

        .item-name {
          font-size: 28rpx;
          color: $text-primary;
        }

        .item-price {
          font-size: 28rpx;
          color: $text-primary;
        }
      }

      .more-items {
        font-size: 24rpx;
        color: $text-tertiary;
        padding-top: 8rpx;
      }
    }

    .order-footer {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 16rpx;

      .customer-info {
        .customer-name {
          font-size: 28rpx;
          font-weight: 600;
          color: $text-primary;
          margin-right: 16rpx;
        }

        .customer-phone {
          font-size: 26rpx;
          color: $text-secondary;
        }
      }

      .order-total {
        display: flex;
        align-items: center;
        gap: 8rpx;

        .total-label {
          font-size: 26rpx;
          color: $text-secondary;
        }

        .total-amount {
          font-size: 32rpx;
          font-weight: 700;
          color: $error-color;
        }
      }
    }

    .order-actions {
      display: flex;
      justify-content: flex-end;
      gap: 16rpx;
      padding-top: 16rpx;
      border-top: 1rpx solid $border-color;

      .action-btn {
        padding: 12rpx 32rpx;
        border-radius: 32rpx;
        font-size: 26rpx;
        border: none;

        &.dispatch {
          background: $primary-color;
          color: #fff;
        }
      }
    }

    .delivery-info {
      display: flex;
      align-items: center;
      gap: 12rpx;
      padding-top: 16rpx;
      border-top: 1rpx solid $border-color;
      margin-top: 16rpx;

      .delivery-icon {
        font-size: 32rpx;
      }

      .delivery-name {
        flex: 1;
        font-size: 28rpx;
        color: $text-primary;
      }

      .delivery-phone {
        font-size: 28rpx;
        color: $primary-color;
      }
    }
  }

  .load-more,
  .no-more {
    text-align: center;
    padding: 32rpx;

    .loading-text,
    .no-more-text {
      font-size: 26rpx;
      color: $text-tertiary;
    }
  }
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 120rpx 0;

  .empty-icon {
    font-size: 120rpx;
    margin-bottom: 32rpx;
  }

  .empty-text {
    font-size: 28rpx;
    color: $text-tertiary;
  }
}

.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 999;

  .loading-text {
    font-size: 28rpx;
    color: #fff;
  }
}
</style>
