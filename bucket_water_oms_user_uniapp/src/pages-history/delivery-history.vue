<template>
  <view class="page">
    <view class="header">
      <text class="title">配送历史</text>
    </view>

    <view class="filter">
      <text class="filter-label" :class="{ active: period === 'week' }" @click="switchPeriod('week')">本周</text>
      <text class="filter-label" :class="{ active: period === 'month' }" @click="switchPeriod('month')">本月</text>
      <text class="filter-label" :class="{ active: period === 'all' }" @click="switchPeriod('all')">全部</text>
    </view>

    <view v-if="!loading && historyList.length > 0" class="list">
      <view v-for="item in historyList" :key="item.id" class="item">
        <view class="item-header">
          <text class="order-no">订单号：{{ item.orderNo }}</text>
          <text class="status" :class="item.status">{{ getStatusText(item.status) }}</text>
        </view>
        <view class="item-body">
          <text class="station">{{ item.stationName || '-' }}</text>
          <text class="address">{{ item.address || '-' }}</text>
          <text class="time">{{ formatTime(item.completeTime || item.createdAt) }}</text>
        </view>
        <view class="item-footer">
          <text class="amount">¥{{ item.amount || 0 }}</text>
        </view>
      </view>
    </view>

    <view v-else-if="loading" class="empty">
      <text class="empty-text">加载中...</text>
    </view>

    <view v-else class="empty">
      <text class="empty-icon">📋</text>
      <text class="empty-text">暂无配送记录</text>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { get } from '@/utils/request'

const loading = ref(false)
const period = ref<'week' | 'month' | 'all'>('week')
const historyList = ref<any[]>([])

const switchPeriod = (p: 'week' | 'month' | 'all') => {
  period.value = p
  loadHistory()
}

const getStatusText = (s: string) => {
  const map: Record<string, string> = {
    completed: '已完成',
    delivering: '配送中',
    cancelled: '已取消',
    rejected: '已拒单'
  }
  return map[s] || s
}

const formatTime = (t: any) => {
  if (!t) return ''
  try {
    const d = new Date(t)
    if (isNaN(d.getTime())) return String(t)
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')} ${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`
  } catch { return String(t) }
}

const loadHistory = async () => {
  loading.value = true
  try {
    const res: any = await get('/orders', { status: 'completed' })
    const list = Array.isArray(res) ? res : (res?.list || res?.records || [])
    historyList.value = list.slice(0, 50)
  } catch (error) {
    console.error('加载历史失败:', error)
    historyList.value = []
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadHistory()
})
</script>

<style lang="scss" scoped>
.page {
  min-height: 100vh;
  background: $bg-color;
  padding: 24rpx;
}
.header {
  padding: 16rpx 8rpx 24rpx;
  .title { font-size: 40rpx; font-weight: bold; color: #1f2937; }
}
.filter {
  display: flex;
  background: #fff;
  border-radius: 12rpx;
  padding: 16rpx;
  margin-bottom: 24rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
  .filter-label {
    flex: 1;
    text-align: center;
    font-size: 28rpx;
    color: #6b7280;
    padding: 12rpx 0;
    border-radius: 8rpx;
    &.active {
      background: $primary-color;
      color: #fff;
    }
  }
}
.list { display: flex; flex-direction: column; gap: 16rpx; }
.item {
  background: #fff;
  border-radius: 16rpx;
  padding: 24rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}
.item-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 16rpx;
  border-bottom: 2rpx solid #f3f4f6;
  .order-no { font-size: 24rpx; color: #6b7280; }
  .status {
    font-size: 24rpx;
    padding: 4rpx 12rpx;
    border-radius: 12rpx;
    &.completed { background: #d1fae5; color: #059669; }
    &.delivering { background: #dbeafe; color: #2563eb; }
    &.cancelled, &.rejected { background: #fee2e2; color: #dc2626; }
  }
}
.item-body {
  padding: 16rpx 0;
  .station { font-size: 28rpx; font-weight: 500; color: #1f2937; display: block; }
  .address { font-size: 24rpx; color: #6b7280; display: block; margin-top: 6rpx; }
  .time { font-size: 24rpx; color: #9ca3af; display: block; margin-top: 6rpx; }
}
.item-footer {
  border-top: 2rpx solid #f3f4f6;
  padding-top: 16rpx;
  text-align: right;
  .amount { font-size: 32rpx; font-weight: 600; color: #ef4444; }
}
.empty {
  text-align: center;
  padding: 200rpx 0;
  .empty-icon { font-size: 120rpx; display: block; margin-bottom: 30rpx; }
  .empty-text { font-size: 28rpx; color: #6b7280; }
}
</style>
