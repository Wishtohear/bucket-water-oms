<template>
  <view class="select-ticket-page">
    <view class="header-section">
      <text class="section-title">选择使用的水票</text>
      <text class="section-desc">请选择要使用的水票来抵扣订单</text>
    </view>

    <view class="stats-bar">
      <view class="stat-item">
        <text class="stat-value">{{ availableTickets.length }}</text>
        <text class="stat-label">可用水票</text>
      </view>
      <view class="stat-item">
        <text class="stat-value">{{ selectedTickets.length }}</text>
        <text class="stat-label">已选</text>
      </view>
      <view class="stat-item">
        <text class="stat-value">{{ selectedBucketCount }}</text>
        <text class="stat-label">可用桶数</text>
      </view>
    </view>

    <scroll-view class="ticket-list" scroll-y v-if="availableTickets.length > 0">
      <view 
        class="ticket-card" 
        v-for="ticket in availableTickets" 
        :key="ticket.id"
        :class="{ selected: isSelected(ticket.id) }"
        @click="toggleTicket(ticket)"
      >
        <view class="ticket-main">
          <view class="ticket-info">
            <text class="ticket-name">{{ ticket.ticketName }}</text>
            <text class="product-name">{{ ticket.productName }}</text>
          </view>
          <view class="select-indicator">
            <text class="check-icon" v-if="isSelected(ticket.id)">✓</text>
          </view>
        </view>

        <view class="ticket-detail">
          <view class="detail-item">
            <text class="detail-label">剩余桶数</text>
            <text class="detail-value highlight">{{ ticket.remainingBucketCount }} 桶</text>
          </view>
          <view class="detail-item">
            <text class="detail-label">有效期至</text>
            <text class="detail-value">{{ formatDate(ticket.expireDate) }}</text>
          </view>
        </view>

        <view class="use-quantity" v-if="isSelected(ticket.id)">
          <text class="quantity-label">使用桶数</text>
          <view class="quantity-control">
            <text class="quantity-btn" @click.stop="decreaseQuantity(ticket)">−</text>
            <input class="quantity-input" type="number" :value="getSelectedQuantity(ticket.id)" @input="onQuantityInput($event, ticket)" />
            <text class="quantity-btn" @click.stop="increaseQuantity(ticket)">+</text>
          </view>
          <text class="max-hint">最多 {{ ticket.remainingBucketCount }} 桶</text>
        </view>
      </view>
    </scroll-view>

    <view class="empty-state" v-if="availableTickets.length === 0 && !loading">
      <text class="empty-icon">🎫</text>
      <text class="empty-text">暂无可用水票</text>
      <text class="empty-hint">请先购买水票</text>
    </view>

    <view class="bottom-bar">
      <view class="summary-info">
        <text class="summary-label">已选水票</text>
        <text class="summary-value">{{ selectedBucketCount }} 桶</text>
      </view>
      <button class="confirm-btn" :disabled="selectedTickets.length === 0" @click="confirmSelect">
        确认使用
      </button>
    </view>

    <view class="loading-overlay" v-if="loading">
      <text class="loading-text">加载中...</text>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { ticketService, UserTicket } from '@/services/ticketService'

const loading = ref(false)
const availableTickets = ref<UserTicket[]>([])
const selectedTickets = ref<Array<{ ticket: UserTicket; quantity: number }>>([])

const selectedBucketCount = computed(() => {
  return selectedTickets.value.reduce((sum, item) => sum + item.quantity, 0)
})

const isSelected = (ticketId: string) => {
  return selectedTickets.value.some(item => item.ticket.id === ticketId)
}

const getSelectedQuantity = (ticketId: string) => {
  const item = selectedTickets.value.find(item => item.ticket.id === ticketId)
  return item?.quantity || 0
}

const toggleTicket = (ticket: UserTicket) => {
  const index = selectedTickets.value.findIndex(item => item.ticket.id === ticket.id)
  if (index > -1) {
    selectedTickets.value.splice(index, 1)
  } else {
    selectedTickets.value.push({
      ticket,
      quantity: Math.min(1, ticket.remainingBucketCount)
    })
  }
}

const decreaseQuantity = (ticket: UserTicket) => {
  const item = selectedTickets.value.find(item => item.ticket.id === ticket.id)
  if (item && item.quantity > 1) {
    item.quantity--
  }
}

const increaseQuantity = (ticket: UserTicket) => {
  const item = selectedTickets.value.find(item => item.ticket.id === ticket.id)
  if (item && item.quantity < ticket.remainingBucketCount) {
    item.quantity++
  }
}

const onQuantityInput = (event: any, ticket: UserTicket) => {
  const value = parseInt(event.detail.value)
  const item = selectedTickets.value.find(item => item.ticket.id === ticket.id)
  if (item) {
    if (isNaN(value) || value < 1) {
      item.quantity = 1
    } else if (value > ticket.remainingBucketCount) {
      item.quantity = ticket.remainingBucketCount
    } else {
      item.quantity = value
    }
  }
}

const formatDate = (dateStr: string) => {
  if (!dateStr) return '--'
  const date = new Date(dateStr)
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
}

const loadAvailableTickets = async () => {
  loading.value = true
  try {
    const result = await ticketService.getMyTickets({ status: 'available' })
    if (result && result.list) {
      availableTickets.value = result.list.filter(t => t.remainingBucketCount > 0)
    }
  } catch (error) {
    console.error('加载水票列表失败:', error)
    uni.showToast({ title: '加载失败', icon: 'error' })
  } finally {
    loading.value = false
  }
}

const confirmSelect = () => {
  const pages = getCurrentPages()
  const prevPage = pages[pages.length - 2]
  
  if (prevPage) {
    prevPage.setData({
      selectedTickets: selectedTickets.value
    })
  }
  
  uni.navigateBack()
}

onMounted(() => {
  loadAvailableTickets()
})
</script>

<style lang="scss" scoped>
.select-ticket-page {
  min-height: 100vh;
  background: $bg-color;
  padding-bottom: 140rpx;
}

.header-section {
  padding: 24rpx;
  background: #fff;
  border-bottom: 1rpx solid $border-color;

  .section-title {
    display: block;
    font-size: 32rpx;
    font-weight: 600;
    color: $text-primary;
    margin-bottom: 8rpx;
  }

  .section-desc {
    display: block;
    font-size: 26rpx;
    color: $text-secondary;
  }
}

.stats-bar {
  display: flex;
  padding: 24rpx;
  gap: 24rpx;

  .stat-item {
    flex: 1;
    background: #fff;
    border-radius: $radius-lg;
    padding: 20rpx;
    text-align: center;
    box-shadow: $shadow-sm;

    .stat-value {
      display: block;
      font-size: 36rpx;
      font-weight: 700;
      color: $primary-color;
      margin-bottom: 8rpx;
    }

    .stat-label {
      display: block;
      font-size: 22rpx;
      color: $text-secondary;
    }
  }
}

.ticket-list {
  padding: 24rpx;

  .ticket-card {
    background: #fff;
    border-radius: $radius-lg;
    padding: 24rpx;
    margin-bottom: 24rpx;
    box-shadow: $shadow-sm;
    border: 4rpx solid transparent;
    transition: all 0.3s;

    &.selected {
      border-color: $primary-color;
      background: rgba($primary-color, 0.05);
    }

    .ticket-main {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      margin-bottom: 16rpx;

      .ticket-info {
        .ticket-name {
          display: block;
          font-size: 30rpx;
          font-weight: 600;
          color: $text-primary;
          margin-bottom: 8rpx;
        }

        .product-name {
          display: block;
          font-size: 26rpx;
          color: $text-secondary;
        }
      }

      .select-indicator {
        width: 48rpx;
        height: 48rpx;
        border-radius: 50%;
        border: 4rpx solid $border-color;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.3s;

        .check-icon {
          font-size: 28rpx;
          color: $primary-color;
          font-weight: 700;
        }

        .selected & {
          border-color: $primary-color;
          background: $primary-color;

          .check-icon {
            color: #fff;
          }
        }
      }
    }

    .ticket-detail {
      display: flex;
      justify-content: space-between;
      padding: 16rpx 0;
      border-top: 1rpx solid $border-color;
      border-bottom: 1rpx solid $border-color;
      margin-bottom: 16rpx;

      .detail-item {
        .detail-label {
          display: block;
          font-size: 22rpx;
          color: $text-tertiary;
          margin-bottom: 4rpx;
        }

        .detail-value {
          display: block;
          font-size: 26rpx;
          color: $text-primary;

          &.highlight {
            font-weight: 600;
            color: $primary-color;
          }
        }
      }
    }

    .use-quantity {
      display: flex;
      align-items: center;
      gap: 16rpx;

      .quantity-label {
        font-size: 26rpx;
        color: $text-secondary;
      }

      .quantity-control {
        display: flex;
        align-items: center;
        gap: 16rpx;

        .quantity-btn {
          width: 56rpx;
          height: 56rpx;
          line-height: 56rpx;
          text-align: center;
          font-size: 36rpx;
          color: $primary-color;
          background: rgba($primary-color, 0.1);
          border-radius: 50%;
        }

        .quantity-input {
          width: 100rpx;
          height: 56rpx;
          text-align: center;
          font-size: 32rpx;
          font-weight: 600;
          background: $bg-color;
          border-radius: 12rpx;
        }
      }

      .max-hint {
        font-size: 22rpx;
        color: $text-tertiary;
      }
    }
  }
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 120rpx 0;

  .empty-icon {
    font-size: 120rpx;
    margin-bottom: 32rpx;
  }

  .empty-text {
    font-size: 28rpx;
    color: $text-secondary;
    margin-bottom: 8rpx;
  }

  .empty-hint {
    font-size: 24rpx;
    color: $text-tertiary;
  }
}

.bottom-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  display: flex;
  align-items: center;
  padding: 16rpx 24rpx;
  padding-bottom: calc(16rpx + env(safe-area-inset-bottom));
  background: #fff;
  box-shadow: 0 -2rpx 12rpx rgba(0, 0, 0, 0.06);

  .summary-info {
    .summary-label {
      font-size: 26rpx;
      color: $text-secondary;
      margin-right: 8rpx;
    }

    .summary-value {
      font-size: 32rpx;
      font-weight: 700;
      color: $primary-color;
    }
  }

  .confirm-btn {
    margin-left: auto;
    padding: 0 48rpx;
    height: 80rpx;
    background: $primary-color;
    color: #fff;
    font-size: 30rpx;
    font-weight: 600;
    border-radius: 40rpx;
    border: none;
    display: flex;
    align-items: center;
    justify-content: center;

    &[disabled] {
      background: $text-tertiary;
    }
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
