<template>
  <view class="use-record-page">
    <scroll-view class="record-list" scroll-y @scrolltolower="loadMore" v-if="records.length > 0">
      <view class="record-card" v-for="record in records" :key="record.id">
        <view class="record-header">
          <text class="record-time">{{ formatTime(record.usedAt) }}</text>
          <text class="record-count">-{{ record.usedBucketCount }} 桶</text>
        </view>

        <view class="record-body">
          <view class="info-row">
            <text class="info-label">订单号</text>
            <text class="info-value">{{ record.orderNo }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">水站</text>
            <text class="info-value">{{ record.stationName }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">商品</text>
            <text class="info-value">{{ record.productName }}</text>
          </view>
        </view>
      </view>

      <view class="load-more" v-if="hasMore">
        <text class="loading-text">加载中...</text>
      </view>

      <view class="no-more" v-if="!hasMore">
        <text class="no-more-text">没有更多记录了</text>
      </view>
    </scroll-view>

    <view class="empty-state" v-if="records.length === 0 && !loading">
      <text class="empty-icon">📋</text>
      <text class="empty-text">暂无使用记录</text>
    </view>

    <view class="loading-overlay" v-if="loading && records.length === 0">
      <text class="loading-text">加载中...</text>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ticketService, TicketUsageRecord } from '@/services/ticketService'

const ticketId = ref('')
const records = ref<TicketUsageRecord[]>([])
const loading = ref(false)
const page = ref(1)
const pageSize = ref(20)
const hasMore = ref(true)

const formatTime = (timeStr: string) => {
  if (!timeStr) return '--'
  const date = new Date(timeStr)
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')} ${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}`
}

const loadRecords = async (append = false) => {
  if (loading.value) return
  
  loading.value = true
  
  try {
    const result = await ticketService.getUsageRecords({
      page: page.value,
      pageSize: pageSize.value
    })
    
    if (result && result.list) {
      if (append) {
        records.value = [...records.value, ...result.list]
      } else {
        records.value = result.list
      }
      
      hasMore.value = records.value.length < result.total
    }
  } catch (error) {
    console.error('加载使用记录失败:', error)
    uni.showToast({ title: '加载失败', icon: 'error' })
  } finally {
    loading.value = false
  }
}

const loadMore = () => {
  if (!hasMore.value || loading.value) return
  page.value++
  loadRecords(true)
}

onMounted(() => {
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1] as any
  const options = currentPage?.options || {}
  
  ticketId.value = options.ticketId || ''
  
  uni.setNavigationBarTitle({ title: '使用记录' })
  
  loadRecords()
})
</script>

<style lang="scss" scoped>
.use-record-page {
  min-height: 100vh;
  background: $bg-color;
}

.record-list {
  padding: 24rpx;

  .record-card {
    background: #fff;
    border-radius: $radius-lg;
    padding: 24rpx;
    margin-bottom: 24rpx;
    box-shadow: $shadow-sm;

    .record-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding-bottom: 16rpx;
      margin-bottom: 16rpx;
      border-bottom: 1rpx solid $border-color;

      .record-time {
        font-size: 28rpx;
        color: $text-secondary;
      }

      .record-count {
        font-size: 32rpx;
        font-weight: 700;
        color: $error-color;
      }
    }

    .record-body {
      .info-row {
        display: flex;
        justify-content: space-between;
        padding: 8rpx 0;

        .info-label {
          font-size: 26rpx;
          color: $text-tertiary;
        }

        .info-value {
          font-size: 26rpx;
          color: $text-primary;
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
