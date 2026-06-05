<template>
  <view class="my-tickets-page">
    <view class="tabs-bar">
      <view class="tab-item" :class="{ active: currentTab === 'available' }" @click="switchTab('available')">
        <text class="tab-text">可用水票</text>
        <text class="tab-count" v-if="availableCount > 0">{{ availableCount }}</text>
      </view>
      <view class="tab-item" :class="{ active: currentTab === 'used' }" @click="switchTab('used')">
        <text class="tab-text">已用完</text>
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
            <text class="ticket-name">{{ ticket.ticketName || ticket.ticketNo }}</text>
            <text class="product-name">水站: {{ ticket.stationName || '默认水站' }}</text>
          </view>
          <text class="ticket-status" :class="ticket.status">
            {{ getStatusText(ticket.status) }}
          </text>
        </view>

        <view class="ticket-detail">
          <view class="detail-item">
            <text class="detail-label">总数</text>
            <text class="detail-value">{{ ticket.totalCount || 0 }} 桶</text>
          </view>
          <view class="detail-item">
            <text class="detail-label">已用</text>
            <text class="detail-value">{{ ticket.usedCount || 0 }} 桶</text>
          </view>
          <view class="detail-item">
            <text class="detail-label">剩余</text>
            <text class="detail-value highlight">{{ ticket.remainingCount || 0 }} 桶</text>
          </view>
        </view>

        <view class="ticket-footer">
          <view class="date-info">
            <text class="date-label">购买时间</text>
            <text class="date-value">{{ formatDate(ticket.createdAt) }}</text>
          </view>
          <view class="date-info">
            <text class="date-label">有效期至</text>
            <text class="date-value" :class="{ expired: ticket.status === 'expired' }">
              {{ formatDate(ticket.expireDate) }}
            </text>
          </view>
        </view>

        <view class="ticket-actions" v-if="ticket.status === 'available'">
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
import { onShow } from '@dcloudio/uni-app'
import { ticketService, UserTicket } from '@/services/ticketService'

const currentTab = ref<'available' | 'used' | 'expired'>('available')
const tickets = ref<UserTicket[]>([])
const loading = ref(false)
const hasMore = ref(false)

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
    expired: '已过期',
    active: '可用水票',
    inactive: '已停用'
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
    used: '暂无已用水票',
    expired: '暂无已过期水票'
  }
  return texts[currentTab.value] || '暂无水票'
}

const formatDate = (dateStr: any) => {
  if (!dateStr) return '--'
  try {
    const date = new Date(dateStr)
    if (isNaN(date.getTime())) return dateStr
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
  } catch {
    return String(dateStr)
  }
}

const switchTab = async (tab: 'available' | 'used' | 'expired') => {
  if (currentTab.value === tab) return
  currentTab.value = tab
  await loadTickets()
}

const normalizeList = (raw: any): UserTicket[] => {
  if (Array.isArray(raw)) return raw as UserTicket[]
  if (raw && Array.isArray(raw.list)) return raw.list as UserTicket[]
  if (raw && Array.isArray(raw.records)) return raw.records as UserTicket[]
  return []
}

const computeStatus = (ticket: UserTicket): 'available' | 'used' | 'expired' => {
  if (ticket.remainingCount !== undefined && ticket.remainingCount <= 0) return 'used'
  if (ticket.expireDate) {
    const exp = new Date(ticket.expireDate)
    if (!isNaN(exp.getTime()) && exp.getTime() < Date.now()) return 'expired'
  }
  return 'available'
}

const loadTickets = async () => {
  loading.value = true
  try {
    const res = await ticketService.getMyTickets()
    const all = normalizeList(res)
    // 补齐 status 字段
    all.forEach(t => {
      if (!t.status) t.status = computeStatus(t)
    })
    // 按当前 tab 过滤
    tickets.value = all.filter(t => t.status === currentTab.value)
    hasMore.value = false

    // 更新各 tab 数量
    statusCountMap.value = {
      available: all.filter(t => t.status === 'available').length,
      used: all.filter(t => t.status === 'used').length,
      expired: all.filter(t => t.status === 'expired').length
    }
  } catch (error) {
    console.error('加载水票列表失败:', error)
    uni.showToast({ title: '加载失败', icon: 'none' })
    tickets.value = []
  } finally {
    loading.value = false
  }
}

const loadMore = () => {
  // 后端单页返回全量，无需分页
}

const goBuyTicket = () => {
  uni.navigateTo({
    url: '/pages-ticket/product-tickets'
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
onShow(() => {
  // 页面显示时刷新（购买后返回等场景）
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
    text-align: center;
    padding: 24rpx 0;
    position: relative;
    &.active {
      .tab-text { color: $primary-color; font-weight: 600; }
      &::after {
        content: '';
        position: absolute;
        bottom: 0;
        left: 50%;
        transform: translateX(-50%);
        width: 60rpx;
        height: 6rpx;
        background: $primary-color;
        border-radius: 3rpx;
      }
    }
  }
  .tab-text { font-size: 28rpx; color: #6b7280; }
  .tab-count {
    display: inline-block;
    background: $primary-color;
    color: #fff;
    font-size: 20rpx;
    padding: 2rpx 10rpx;
    border-radius: 20rpx;
    margin-left: 8rpx;
  }
}
.ticket-list {
  height: calc(100vh - 100rpx);
  padding: 24rpx;
}
.ticket-card {
  background: #fff;
  border-radius: 16rpx;
  padding: 32rpx;
  margin-bottom: 24rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}
.ticket-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding-bottom: 20rpx;
  border-bottom: 2rpx dashed #e5e7eb;
}
.ticket-info { flex: 1; }
.ticket-name { font-size: 32rpx; font-weight: 600; color: #1f2937; display: block; }
.product-name { font-size: 24rpx; color: #6b7280; margin-top: 6rpx; display: block; }
.ticket-status {
  font-size: 24rpx;
  padding: 4rpx 16rpx;
  border-radius: 16rpx;
  &.available, &.active { background: #d1fae5; color: #059669; }
  &.used { background: #e5e7eb; color: #6b7280; }
  &.expired { background: #fee2e2; color: #dc2626; }
}
.ticket-detail {
  display: flex;
  padding: 24rpx 0;
  .detail-item { flex: 1; text-align: center; }
  .detail-label { font-size: 24rpx; color: #9ca3af; display: block; }
  .detail-value { font-size: 30rpx; color: #1f2937; font-weight: 500; margin-top: 6rpx; display: block; }
  .highlight { color: $primary-color; font-weight: 600; }
}
.ticket-footer {
  display: flex;
  padding-top: 20rpx;
  border-top: 2rpx solid #f3f4f6;
  .date-info { flex: 1; }
  .date-label { font-size: 22rpx; color: #9ca3af; display: block; }
  .date-value { font-size: 26rpx; color: #4b5563; margin-top: 4rpx; display: block;
    &.expired { color: #dc2626; }
  }
}
.ticket-actions {
  display: flex;
  gap: 16rpx;
  margin-top: 24rpx;
  .action-btn {
    flex: 1;
    font-size: 26rpx;
    border-radius: 12rpx;
    padding: 16rpx 0;
    margin: 0;
    border: none;
    &.use { background: $primary-color; color: #fff; }
    &.history { background: #f3f4f6; color: #4b5563; }
  }
}
.load-more, .no-more {
  text-align: center;
  padding: 32rpx 0;
  .loading-text, .no-more-text {
    font-size: 24rpx;
    color: #9ca3af;
  }
}
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 200rpx 0;
  .empty-icon { font-size: 120rpx; margin-bottom: 30rpx; }
  .empty-text {
    font-size: 28rpx;
    color: #6b7280;
    margin-bottom: 40rpx;
  }
  .go-buy-btn {
    background: $primary-color;
    color: #fff;
    border-radius: 32rpx;
    padding: 16rpx 60rpx;
    font-size: 28rpx;
    border: none;
  }
}
.loading-overlay {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 200rpx 0;
  .loading-text { font-size: 28rpx; color: #6b7280; }
}
</style>
