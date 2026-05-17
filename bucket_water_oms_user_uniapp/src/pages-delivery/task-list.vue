<template>
  <view class="task-list-page">
    <view class="tabs-bar">
      <view class="tab-item" :class="{ active: currentTab === 'pending' }" @click="switchTab('pending')">
        <text class="tab-text">待接单</text>
        <text class="tab-count" :class="{ warning: pendingCount > 0 }" v-if="pendingCount > 0">{{ pendingCount }}</text>
      </view>
      <view class="tab-item" :class="{ active: currentTab === 'accepted' }" @click="switchTab('accepted')">
        <text class="tab-text">已接单</text>
        <text class="tab-count" v-if="acceptedCount > 0">{{ acceptedCount }}</text>
      </view>
      <view class="tab-item" :class="{ active: currentTab === 'delivering' }" @click="switchTab('delivering')">
        <text class="tab-text">配送中</text>
        <text class="tab-count" v-if="deliveringCount > 0">{{ deliveringCount }}</text>
      </view>
      <view class="tab-item" :class="{ active: currentTab === 'completed' }" @click="switchTab('completed')">
        <text class="tab-text">已完成</text>
      </view>
    </view>

    <scroll-view class="task-list" scroll-y @scrolltolower="loadMore" v-if="tasks.length > 0">
      <view class="task-card" v-for="task in tasks" :key="task.id" @click="viewDetail(task.id)">
        <view class="task-header">
          <text class="task-status" :class="getStatusClass(task.status)">
            {{ getStatusText(task.status) }}
          </text>
          <text class="task-time">{{ formatTime(task.createdAt) }}</text>
        </view>

        <view class="task-address">
          <text class="address-icon">📍</text>
          <view class="address-content">
            <text class="address-detail">{{ formatAddress(task.address) }}</text>
            <text class="contact-info">{{ task.address?.contactName }} {{ task.address?.contactPhone }}</text>
          </view>
        </view>

        <view class="task-items">
          <text class="items-count">共 {{ task.items?.length || 0 }} 件商品</text>
          <text class="items-preview" v-if="task.items && task.items.length > 0">
            {{ getItemsPreview(task.items) }}
          </text>
        </view>

        <view class="task-footer">
          <text class="order-no">订单号: {{ task.orderNo }}</text>
          <text class="task-action" v-if="task.status === 'pending'" @click.stop="acceptTask(task.id)">
            立即接单
          </text>
          <text class="task-action delivering" v-if="task.status === 'accepted'" @click.stop="startDelivery(task.id)">
            开始配送
          </text>
        </view>
      </view>

      <view class="load-more" v-if="hasMore">
        <text class="loading-text">加载中...</text>
      </view>

      <view class="no-more" v-if="!hasMore && tasks.length > 0">
        <text class="no-more-text">没有更多任务了</text>
      </view>
    </scroll-view>

    <view class="empty-state" v-if="tasks.length === 0 && !loading">
      <text class="empty-icon">{{ getEmptyIcon() }}</text>
      <text class="empty-text">{{ getEmptyText() }}</text>
    </view>

    <view class="loading-overlay" v-if="loading && tasks.length === 0">
      <text class="loading-text">加载中...</text>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { deliveryPersonService, DeliveryTask } from '@/services/deliveryPersonService'

const currentTab = ref('pending')
const tasks = ref<DeliveryTask[]>([])
const loading = ref(false)
const page = ref(1)
const pageSize = ref(20)
const hasMore = ref(true)

const pendingCount = computed(() => tasks.value.filter(t => t.status === 'pending').length)
const acceptedCount = computed(() => tasks.value.filter(t => t.status === 'accepted').length)
const deliveringCount = computed(() => tasks.value.filter(t => t.status === 'delivering').length)

const statusMap: Record<string, string> = {
  pending: '待接单',
  accepted: '已接单',
  delivering: '配送中',
  completed: '已完成'
}

const getStatusText = (status: string) => statusMap[status] || status

const getStatusClass = (status: string) => {
  const classMap: Record<string, string> = {
    pending: 'warning',
    accepted: 'primary',
    delivering: 'primary',
    completed: 'success'
  }
  return classMap[status] || ''
}

const getItemsPreview = (items: any[]) => {
  if (!items || items.length === 0) return ''
  const names = items.slice(0, 2).map(item => item.productName)
  const suffix = items.length > 2 ? `等${items.length}件` : ''
  return names.join('、') + suffix
}

const formatAddress = (addr: any) => {
  if (!addr) return ''
  const parts = [addr.province, addr.city, addr.district, addr.detail].filter(Boolean)
  return parts.join('')
}

const formatTime = (time: string) => {
  if (!time) return ''
  const date = new Date(time)
  const now = new Date()
  const diff = now.getTime() - date.getTime()
  
  if (diff < 60000) return '刚刚'
  if (diff < 3600000) return `${Math.floor(diff / 60000)}分钟前`
  if (diff < 86400000) return `${Math.floor(diff / 3600000)}小时前`
  
  return `${date.getMonth() + 1}-${date.getDate()} ${date.getHours()}:${String(date.getMinutes()).padStart(2, '0')}`
}

const getEmptyIcon = () => {
  const icons: Record<string, string> = {
    pending: '📋',
    accepted: '📦',
    delivering: '🚚',
    completed: '✅'
  }
  return icons[currentTab.value] || '📋'
}

const getEmptyText = () => {
  const texts: Record<string, string> = {
    pending: '暂无待接单任务',
    accepted: '暂无已接单任务',
    delivering: '暂无配送中任务',
    completed: '暂无已完成任务'
  }
  return texts[currentTab.value] || '暂无任务'
}

const switchTab = async (tab: string) => {
  if (currentTab.value === tab) return
  currentTab.value = tab
  page.value = 1
  tasks.value = []
  hasMore.value = true
  await loadTasks()
}

const loadTasks = async (append = false) => {
  if (loading.value) return
  
  loading.value = true
  
  try {
    const statusMap: Record<string, string> = {
      pending: 'pending',
      accepted: 'accepted',
      delivering: 'delivering',
      completed: 'completed'
    }
    
    const result = await deliveryPersonService.getTasks({
      status: statusMap[currentTab.value]
    })
    
    if (result && Array.isArray(result)) {
      if (append) {
        tasks.value = [...tasks.value, ...result]
      } else {
        tasks.value = result
      }
      
      hasMore.value = result.length >= pageSize.value
    }
  } catch (error) {
    console.error('加载任务列表失败:', error)
    uni.showToast({ title: '加载失败', icon: 'error' })
  } finally {
    loading.value = false
  }
}

const loadMore = () => {
  if (!hasMore.value || loading.value) return
  page.value++
  loadTasks(true)
}

const viewDetail = (taskId: string) => {
  uni.navigateTo({
    url: `/pages-delivery/task-detail?id=${taskId}`
  })
}

const acceptTask = async (taskId: string) => {
  uni.showModal({
    title: '确认接单',
    content: '确定要接下这个配送任务吗？',
    success: async (res) => {
      if (res.confirm) {
        try {
          await deliveryPersonService.acceptTask(taskId)
          uni.showToast({ title: '接单成功' })
          loadTasks()
        } catch (error) {
          uni.showToast({ title: '接单失败', icon: 'error' })
        }
      }
    }
  })
}

const startDelivery = async (taskId: string) => {
  uni.showModal({
    title: '开始配送',
    content: '确定开始配送吗？',
    success: async (res) => {
      if (res.confirm) {
        try {
          await deliveryPersonService.startDelivery(taskId)
          uni.showToast({ title: '已开始配送' })
          loadTasks()
        } catch (error) {
          uni.showToast({ title: '操作失败', icon: 'error' })
        }
      }
    }
  })
}

onMounted(() => {
  loadTasks()
})
</script>

<style lang="scss" scoped>
.task-list-page {
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

.task-list {
  padding: 24rpx;

  .task-card {
    background: #fff;
    border-radius: $radius-lg;
    padding: 24rpx;
    margin-bottom: 24rpx;
    box-shadow: $shadow-sm;

    .task-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 16rpx;

      .task-status {
        font-size: 26rpx;
        padding: 6rpx 16rpx;
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
      }

      .task-time {
        font-size: 24rpx;
        color: $text-tertiary;
      }
    }

    .task-address {
      display: flex;
      align-items: flex-start;
      margin-bottom: 16rpx;
      padding-bottom: 16rpx;
      border-bottom: 1rpx solid $border-color;

      .address-icon {
        font-size: 32rpx;
        margin-right: 12rpx;
      }

      .address-content {
        flex: 1;

        .address-detail {
          display: block;
          font-size: 28rpx;
          color: $text-primary;
          margin-bottom: 8rpx;
        }

        .contact-info {
          display: block;
          font-size: 26rpx;
          color: $text-secondary;
        }
      }
    }

    .task-items {
      margin-bottom: 16rpx;

      .items-count {
        display: block;
        font-size: 26rpx;
        color: $text-secondary;
        margin-bottom: 8rpx;
      }

      .items-preview {
        display: block;
        font-size: 28rpx;
        color: $text-primary;
      }
    }

    .task-footer {
      display: flex;
      justify-content: space-between;
      align-items: center;

      .order-no {
        font-size: 24rpx;
        color: $text-tertiary;
      }

      .task-action {
        font-size: 28rpx;
        color: $primary-color;
        font-weight: 600;
        padding: 8rpx 24rpx;
        background: rgba($primary-color, 0.1);
        border-radius: 24rpx;

        &.delivering {
          background: rgba($warning-color, 0.1);
          color: $warning-color;
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
