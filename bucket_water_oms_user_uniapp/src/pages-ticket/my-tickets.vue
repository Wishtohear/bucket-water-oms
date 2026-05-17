<template>
  <view class="my-tickets-page">
    <view class="tabs-bar">
      <view class="tab-item" :class="{ active: currentTab === 'available' }" @click="switchTab('available')">
        <text class="tab-text">可用水票</text>
        <text class="tab-count" v-if="availableCount > 0">{{ availableCount }}</text>
      </view>
      <view class="tab-item" :class="{ active: currentTab === 'used' }" @click="switchTab('used')">
        <text class="tab-text">已使用</text>
        <text class="tab-count" v-if="usedCount > 0">{{ usedCount }}</text>
      </view>
      <view class="tab-item" :class="{ active: currentTab === 'expired' }" @click="switchTab('expired')">
        <text class="tab-text">已过期</text>
        <text class="tab-count" v-if="expiredCount > 0">{{ expiredCount }}</text>
      </view>
    </view>

    <scroll-view class="ticket-list" scroll-y @scrolltolower="loadMore" v-if="tickets.length > 0">
      <view class="ticket-card" v-for="ticket in tickets" :key="ticket.id">
        <view class="ticket-header">
          <view class="ticket-info">
            <text class="ticket-name">{{ ticket.ticketName }}</text>
            <text class="product-name">{{ ticket.productName }}</text>
          </view>
          <text class="ticket-status" :class="ticket.status">
            {{ getStatusText(ticket.status) }}
          </text>
        </view>

        <view class="ticket-detail">
          <view class="detail-item">
            <text class="detail-label">桶数</text>
            <text class="detail-value">{{ ticket.bucketCount }} 桶</text>
          </view>
          <view class="detail-item">
            <text class="detail-label">已用</text>
            <text class="detail-value">{{ ticket.usedBucketCount }} 桶</text>
          </view>
          <view class="detail-item">
            <text class="detail-label">剩余</text>
            <text class="detail-value highlight">{{ ticket.remainingBucketCount }} 桶</text>
          </view>
        </view>

        <view class="ticket-footer">
          <view class="date-info">
            <text class="date-label">购买时间</text>
            <text class="date-value">{{ formatDate(ticket.purchaseDate) }}</text>
          </view>
          <view class="date-info">
            <text class="date-label">有效期至</text>
            <text class="date-value" :class="{ expired: ticket.status === 'expired' }">
              {{ formatDate(ticket.expireDate) }}
            </text>
          </view>
        </view>

        <view class="ticket-actions" v-if="ticket.status === 'available'">
          <button class="action-btn use" @click="goUseTicket(ticket)">使用水票</button>
          <button class="action-btn history" @click="goUsageHistory(ticket.id)">使用记录</button>
        </view>
      </view>

      <view class="load-more" v-if="hasMore">
        <text class="loading-text">加载中...</text>
      </view>

      <view class="no-more" v-if="!hasMore && tickets.length > 0">
        <text class="no-more-text">没有更多水票了</text>
      </view>
    </scroll-view>

    <view class="empty-state" v-if="tickets.length === 0 && !loading">
      <text class="empty-icon">{{ getEmptyIcon() }}</text>
      <text class="empty-text">{{ getEmptyText() }}</text>
      <button class="go-buy-btn" @click="goBuyTicket">去购买水票</button>
    </view>

    <view class="loading-overlay" v-if="loading && tickets.length === 0">
      <text class="loading-text">加载中...</text>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { ticketService, UserTicket } from '@/services/ticketService'

const currentTab = ref<'available' | 'used' | 'expired'>('available')
const tickets = ref<UserTicket[]>([])
const loading = ref(false)
const page = ref(1)
const pageSize = ref(20)
const hasMore = ref(true)

const statusCountMap = ref({
  available: 0,
  used: 0,
  expired: 0
})

const availableCount = computed(() => statusCountMap.value.available)
const usedCount = computed(() => statusCountMap.value.used)
const expiredCount = computed(() => statusCountMap.value.expired)

const getStatusText = (status: string) => {
  const map: Record<string, string> = {
    available: '可用水票',
    used: '已用完',
    expired: '已过期'
  }
  return map[status] || status
}

const getEmptyIcon = () => {
  const icons: Record<string, string> = {
    available: '🎫',
    used: '✅',
    expired: '⏰'
  }
  return icons[currentTab.value] || '🎫'
}

const getEmptyText = () => {
  const texts: Record<string, string> = {
    available: '暂无可用水票',
    used: '暂无已使用水票',
    expired: '暂无已过期水票'
  }
  return texts[currentTab.value] || '暂无水票'
}

const formatDate = (dateStr: string) => {
  if (!dateStr) return '--'
  const date = new Date(dateStr)
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
}

const switchTab = async (tab: 'available' | 'used' | 'expired') => {
  if (currentTab.value === tab) return
  currentTab.value = tab
  page.value = 1
  tickets.value = []
  hasMore.value = true
  await loadTickets()
}

const loadTickets = async (append = false) => {
  if (loading.value) return
  
  loading.value = true
  
  try {
    const statusMap: Record<string, string> = {
      available: 'available',
      used: 'used',
      expired: 'expired'
    }
    
    const result = await ticketService.getMyTickets({
      status: statusMap[currentTab.value],
      page: page.value,
      pageSize: pageSize.value
    })
    
    if (result && result.list) {
      if (append) {
        tickets.value = [...tickets.value, ...result.list]
      } else {
        tickets.value = result.list
      }
      
      hasMore.value = tickets.value.length < result.total
      
      if (!append) {
        updateStatusCounts(result.list)
      }
    }
  } catch (error) {
    console.error('加载水票列表失败:', error)
    uni.showToast({ title: '加载失败', icon: 'error' })
  } finally {
    loading.value = false
  }
}

const updateStatusCounts = (ticketList: UserTicket[]) => {
  const newCounts = {
    available: currentTab.value === 'available' ? ticketList.length : statusCountMap.value.available,
    used: currentTab.value === 'used' ? ticketList.length : statusCountMap.value.used,
    expired: currentTab.value === 'expired' ? ticketList.length : statusCountMap.value.expired
  }
  
  if (currentTab.value !== 'available') {
    newCounts.available = ticketList.filter(t => t.status === 'available').length
  }
  if (currentTab.value !== 'used') {
    newCounts.used = ticketList.filter(t => t.status === 'used').length
  }
  if (currentTab.value !== 'expired') {
    newCounts.expired = ticketList.filter(t => t.status === 'expired').length
  }
  
  statusCountMap.value = newCounts
}

const loadMore = () => {
  if (!hasMore.value || loading.value) return
  page.value++
  loadTickets(true)
}

const goBuyTicket = () => {
  uni.navigateBack()
}

const goUseTicket = (ticket: UserTicket) => {
  uni.navigateTo({
    url: `/pages/product/detail?id=${ticket.productId}&ticketId=${ticket.id}`
  })
}

const goUsageHistory = (ticketId: string) => {
  uni.navigateTo({
    url: `/pages-ticket/use-record?ticketId=${ticketId}`
  })
}

onMounted(() => {
  loadTickets()
})
</script>

<style lang="scss" scoped>
.my-tickets-page {
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

.ticket-list {
  padding: 24rpx;

  .ticket-card {
    background: #fff;
    border-radius: $radius-lg;
    padding: 24rpx;
    margin-bottom: 24rpx;
    box-shadow: $shadow-sm;

    .ticket-header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      margin-bottom: 20rpx;

      .ticket-info {
        .ticket-name {
          display: block;
          font-size: 32rpx;
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

      .ticket-status {
        font-size: 24rpx;
        padding: 6rpx 16rpx;
        border-radius: 16rpx;

        &.available {
          background: rgba($success-color, 0.1);
          color: $success-color;
        }

        &.used {
          background: rgba($text-tertiary, 0.1);
          color: $text-tertiary;
        }

        &.expired {
          background: rgba($error-color, 0.1);
          color: $error-color;
        }
      }
    }

    .ticket-detail {
      display: flex;
      justify-content: space-around;
      padding: 20rpx 0;
      margin-bottom: 20rpx;
      border-top: 1rpx solid $border-color;
      border-bottom: 1rpx solid $border-color;

      .detail-item {
        text-align: center;

        .detail-label {
          display: block;
          font-size: 24rpx;
          color: $text-secondary;
          margin-bottom: 8rpx;
        }

        .detail-value {
          display: block;
          font-size: 32rpx;
          font-weight: 600;
          color: $text-primary;

          &.highlight {
            color: $primary-color;
          }
        }
      }
    }

    .ticket-footer {
      display: flex;
      justify-content: space-between;

      .date-info {
        .date-label {
          display: block;
          font-size: 22rpx;
          color: $text-tertiary;
          margin-bottom: 4rpx;
        }

        .date-value {
          display: block;
          font-size: 26rpx;
          color: $text-secondary;

          &.expired {
            color: $error-color;
          }
        }
      }
    }

    .ticket-actions {
      display: flex;
      gap: 16rpx;
      margin-top: 20rpx;
      padding-top: 20rpx;
      border-top: 1rpx solid $border-color;

      .action-btn {
        flex: 1;
        height: 72rpx;
        font-size: 28rpx;
        border-radius: 36rpx;
        border: none;
        display: flex;
        align-items: center;
        justify-content: center;

        &.use {
          background: $primary-color;
          color: #fff;
        }

        &.history {
          background: rgba($primary-color, 0.1);
          color: $primary-color;
        }
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
    margin-bottom: 48rpx;
  }

  .go-buy-btn {
    padding: 20rpx 48rpx;
    background: $primary-color;
    color: #fff;
    font-size: 28rpx;
    border-radius: 40rpx;
    border: none;
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
