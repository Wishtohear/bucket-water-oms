<template>
  <view class="task-detail-page">
    <scroll-view class="content" scroll-y v-if="task.id">
      <view class="status-banner" :class="getStatusClass(task.status)">
        <text class="status-icon">{{ getStatusIcon(task.status) }}</text>
        <text class="status-text">{{ getStatusText(task.status) }}</text>
      </view>

      <view class="map-section">
        <map class="map" :latitude="mapLatitude" :longitude="mapLongitude" :markers="markers" scale="14" show-location />
        <view class="map-cover" @click="openMap">
          <text class="cover-text">查看完整地图</text>
        </view>
      </view>

      <view class="address-card">
        <view class="address-icon">📍</view>
        <view class="address-content">
          <view class="contact-row">
            <text class="contact-name">{{ task.address?.contactName }}</text>
            <text class="contact-phone">{{ task.address?.contactPhone }}</text>
          </view>
          <text class="address-detail">{{ formatAddress(task.address) }}</text>
        </view>
        <view class="address-actions">
          <text class="action-icon" @click="navigate">🗺️</text>
          <text class="action-icon" @click="call">📞</text>
        </view>
      </view>

      <view class="order-card">
        <view class="store-name">{{ task.stationName }}</view>
        <view class="product-list">
          <view class="product-item" v-for="item in task.items" :key="item.id">
            <view class="product-info">
              <text class="product-name">{{ item.productName }}</text>
              <text class="product-spec" v-if="item.spec">{{ item.spec }}</text>
            </view>
            <view class="product-right">
              <text class="product-qty">x{{ item.quantity }}</text>
              <text class="product-price">¥{{ item.subtotal.toFixed(2) }}</text>
            </view>
          </view>
        </view>
        <view class="total-row">
          <text class="total-label">合计</text>
          <text class="total-amount">¥{{ totalAmount.toFixed(2) }}</text>
        </view>
      </view>

      <view class="timeline-card" v-if="hasTimeline">
        <view class="timeline-title">配送进度</view>
        <view class="timeline">
          <view class="timeline-item" :class="{ active: task.acceptTime, completed: task.startTime }">
            <view class="timeline-dot"></view>
            <view class="timeline-content">
              <text class="timeline-text">接单时间</text>
              <text class="timeline-time" v-if="task.acceptTime">{{ formatTime(task.acceptTime) }}</text>
              <text class="timeline-time" v-else>--</text>
            </view>
          </view>
          <view class="timeline-item" :class="{ active: task.startTime, completed: task.completeTime }">
            <view class="timeline-dot"></view>
            <view class="timeline-content">
              <text class="timeline-text">开始配送</text>
              <text class="timeline-time" v-if="task.startTime">{{ formatTime(task.startTime) }}</text>
              <text class="timeline-time" v-else>--</text>
            </view>
          </view>
          <view class="timeline-item" :class="{ completed: task.completeTime }">
            <view class="timeline-dot"></view>
            <view class="timeline-content">
              <text class="timeline-text">完成配送</text>
              <text class="timeline-time" v-if="task.completeTime">{{ formatTime(task.completeTime) }}</text>
              <text class="timeline-time" v-else>--</text>
            </view>
          </view>
        </view>
      </view>

      <view class="info-card">
        <view class="info-row">
          <text class="info-label">订单编号</text>
          <text class="info-value">{{ task.orderNo }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">下单时间</text>
          <text class="info-value">{{ formatTime(task.createdAt) }}</text>
        </view>
        <view class="info-row" v-if="task.payTime">
          <text class="info-label">支付时间</text>
          <text class="info-value">{{ formatTime(task.payTime) }}</text>
        </view>
        <view class="info-row" v-if="task.remark">
          <text class="info-label">订单备注</text>
          <text class="info-value remark">{{ task.remark }}</text>
        </view>
      </view>
    </scroll-view>

    <view class="bottom-bar" v-if="task.id">
      <button class="action-btn navigate" @click="navigate">🗺️ 导航</button>
      <button class="action-btn call" @click="call">📞 联系</button>
      <button class="action-btn primary" v-if="task.status === 'pending'" @click="acceptTask">接单</button>
      <button class="action-btn warning" v-if="task.status === 'accepted'" @click="startDelivery">开始配送</button>
      <button class="action-btn success" v-if="task.status === 'delivering'" @click="completeTask">完成配送</button>
    </view>

    <view class="loading-page" v-if="!task.id && loading">
      <text class="loading-text">加载中...</text>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { deliveryPersonService, DeliveryTask } from '@/services/deliveryPersonService'
import { format } from '@/utils/format'

const taskId = ref('')
const task = ref<DeliveryTask | null>(null)
const loading = ref(false)

const mapLatitude = computed(() => task.value?.address?.latitude || 25.2744)
const mapLongitude = computed(() => task.value?.address?.longitude || 110.29)

const markers = computed(() => [{
  id: 1,
  latitude: mapLatitude.value,
  longitude: mapLongitude.value,
  iconPath: '/static/marker.png',
  width: 32,
  height: 32,
  title: task.value?.address?.detail || '配送地址'
}])

const totalAmount = computed(() => {
  if (!task.value?.items) return 0
  return task.value.items.reduce((sum, item) => sum + item.subtotal, 0)
})

const hasTimeline = computed(() => {
  return task.value?.acceptTime || task.value?.startTime || task.value?.completeTime
})

const getStatusIcon = (status: string) => {
  const map: Record<string, string> = {
    pending: '📋',
    accepted: '✅',
    delivering: '🚚',
    completed: '✅'
  }
  return map[status] || '⏰'
}

const getStatusText = (status: string) => {
  const map: Record<string, string> = {
    pending: '待接单',
    accepted: '已接单',
    delivering: '配送中',
    completed: '已完成'
  }
  return map[status] || status
}

const getStatusClass = (status: string) => {
  if (status === 'completed') return 'success'
  if (status === 'delivering') return 'primary'
  if (status === 'accepted') return 'warning'
  return 'default'
}

const formatAddress = (addr: any) => {
  if (!addr) return ''
  const parts = [addr.province, addr.city, addr.district, addr.detail].filter(Boolean)
  return parts.join('')
}

const formatTime = (time: string) => {
  if (!time) return '--'
  return format.datetime(time)
}

const loadDetail = async () => {
  if (!taskId.value) return
  loading.value = true
  try {
    const result = await deliveryPersonService.getTaskDetail(taskId.value)
    if (result) {
      task.value = result
    }
  } catch (error) {
    console.error('加载任务详情失败:', error)
    uni.showToast({ title: '加载失败', icon: 'error' })
  } finally {
    loading.value = false
  }
}

const acceptTask = async () => {
  uni.showModal({
    title: '确认接单',
    content: '确定要接下这个配送任务吗？',
    success: async (res) => {
      if (res.confirm) {
        try {
          await deliveryPersonService.acceptTask(taskId.value)
          uni.showToast({ title: '接单成功' })
          loadDetail()
        } catch (error) {
          uni.showToast({ title: '接单失败', icon: 'error' })
        }
      }
    }
  })
}

const startDelivery = async () => {
  uni.showModal({
    title: '开始配送',
    content: '确定开始配送吗？',
    success: async (res) => {
      if (res.confirm) {
        try {
          await deliveryPersonService.startDelivery(taskId.value)
          uni.showToast({ title: '已开始配送' })
          loadDetail()
        } catch (error) {
          uni.showToast({ title: '操作失败', icon: 'error' })
        }
      }
    }
  })
}

const completeTask = async () => {
  uni.showModal({
    title: '完成配送',
    content: '确认货物已送达吗？',
    success: async (res) => {
      if (res.confirm) {
        try {
          await deliveryPersonService.completeDelivery(taskId.value)
          uni.showToast({ title: '配送完成' })
          setTimeout(() => {
            uni.navigateBack()
          }, 1500)
        } catch (error) {
          uni.showToast({ title: '操作失败', icon: 'error' })
        }
      }
    }
  })
}

const openMap = () => {
  if (!task.value?.address) return
  uni.openLocation({
    latitude: mapLatitude.value,
    longitude: mapLongitude.value,
    name: task.value.stationName,
    address: formatAddress(task.value.address)
  })
}

const navigate = () => {
  if (!task.value?.address) return
  uni.openLocation({
    latitude: mapLatitude.value,
    longitude: mapLongitude.value,
    name: '配送地址',
    address: formatAddress(task.value.address)
  })
}

const call = () => {
  if (!task.value?.address?.contactPhone) return
  uni.makePhoneCall({
    phoneNumber: task.value.address.contactPhone
  })
}

onMounted(() => {
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1] as any
  const options = currentPage?.options || {}
  taskId.value = options.id || ''
  if (taskId.value) {
    loadDetail()
  }
})
</script>

<style lang="scss" scoped>
.task-detail-page {
  min-height: 100vh;
  background: $bg-color;
  padding-bottom: 120rpx;
}

.status-banner {
  display: flex;
  align-items: center;
  padding: 48rpx 32rpx;
  color: #fff;

  &.primary {
    background: $primary-color;
  }

  &.success {
    background: $success-color;
  }

  &.warning {
    background: $warning-color;
  }

  &.default {
    background: $text-tertiary;
  }

  .status-icon {
    font-size: 48rpx;
    margin-right: 16rpx;
  }

  .status-text {
    font-size: 32rpx;
    font-weight: 600;
  }
}

.map-section {
  position: relative;
  height: 300rpx;
  margin: 24rpx;
  border-radius: $radius-lg;
  overflow: hidden;

  .map {
    width: 100%;
    height: 100%;
  }

  .map-cover {
    position: absolute;
    bottom: 16rpx;
    left: 50%;
    transform: translateX(-50%);
    background: rgba(0, 0, 0, 0.6);
    padding: 12rpx 24rpx;
    border-radius: 32rpx;

    .cover-text {
      color: #fff;
      font-size: 24rpx;
    }
  }
}

.address-card {
  background: #fff;
  margin: 0 24rpx 24rpx;
  border-radius: $radius-lg;
  padding: 24rpx;
  display: flex;
  align-items: flex-start;

  .address-icon {
    font-size: 40rpx;
    margin-right: 16rpx;
  }

  .address-content {
    flex: 1;

    .contact-row {
      display: flex;
      align-items: center;
      gap: 16rpx;
      margin-bottom: 8rpx;

      .contact-name {
        font-size: 32rpx;
        font-weight: 600;
        color: $text-primary;
      }

      .contact-phone {
        font-size: 28rpx;
        color: $text-secondary;
      }
    }

    .address-detail {
      font-size: 26rpx;
      color: $text-secondary;
      line-height: 1.4;
    }
  }

  .address-actions {
    display: flex;
    gap: 16rpx;

    .action-icon {
      font-size: 48rpx;
      padding: 8rpx;
    }
  }
}

.order-card {
  background: #fff;
  margin: 0 24rpx 24rpx;
  border-radius: $radius-lg;
  padding: 24rpx;

  .store-name {
    font-size: 28rpx;
    font-weight: 600;
    color: $text-primary;
    margin-bottom: 20rpx;
    padding-bottom: 20rpx;
    border-bottom: 1rpx solid $border-color;
  }

  .product-list {
    .product-item {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      padding: 16rpx 0;

      .product-info {
        flex: 1;

        .product-name {
          display: block;
          font-size: 28rpx;
          color: $text-primary;
          margin-bottom: 4rpx;
        }

        .product-spec {
          display: block;
          font-size: 24rpx;
          color: $text-tertiary;
        }
      }

      .product-right {
        display: flex;
        align-items: center;
        gap: 16rpx;

        .product-qty {
          font-size: 26rpx;
          color: $text-secondary;
        }

        .product-price {
          font-size: 28rpx;
          color: $text-primary;
          font-weight: 600;
        }
      }
    }
  }

  .total-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding-top: 16rpx;
    margin-top: 16rpx;
    border-top: 1rpx solid $border-color;

    .total-label {
      font-size: 28rpx;
      color: $text-secondary;
    }

    .total-amount {
      font-size: 36rpx;
      font-weight: 700;
      color: $error-color;
    }
  }
}

.timeline-card {
  background: #fff;
  margin: 0 24rpx 24rpx;
  border-radius: $radius-lg;
  padding: 24rpx;

  .timeline-title {
    font-size: 28rpx;
    font-weight: 600;
    color: $text-primary;
    margin-bottom: 24rpx;
  }

  .timeline {
    .timeline-item {
      display: flex;
      align-items: flex-start;
      padding-bottom: 32rpx;
      position: relative;

      &:last-child {
        padding-bottom: 0;

        &::after {
          display: none;
        }
      }

      &::after {
        content: '';
        position: absolute;
        left: 10rpx;
        top: 28rpx;
        bottom: 0;
        width: 2rpx;
        background: $border-color;
      }

      .timeline-dot {
        width: 22rpx;
        height: 22rpx;
        border-radius: 50%;
        background: $border-color;
        margin-right: 20rpx;
        margin-top: 4rpx;
        flex-shrink: 0;
      }

      &.active .timeline-dot {
        background: $primary-color;
      }

      &.completed .timeline-dot {
        background: $success-color;
      }

      .timeline-content {
        flex: 1;

        .timeline-text {
          display: block;
          font-size: 28rpx;
          color: $text-primary;
          margin-bottom: 8rpx;
        }

        .timeline-time {
          display: block;
          font-size: 24rpx;
          color: $text-tertiary;
        }
      }
    }
  }
}

.info-card {
  background: #fff;
  margin: 0 24rpx;
  border-radius: $radius-lg;
  padding: 24rpx;

  .info-row {
    display: flex;
    justify-content: space-between;
    padding: 12rpx 0;

    .info-label {
      font-size: 26rpx;
      color: $text-secondary;
    }

    .info-value {
      font-size: 26rpx;
      color: $text-primary;

      &.remark {
        color: $warning-color;
        max-width: 400rpx;
        text-align: right;
      }
    }
  }
}

.bottom-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 16rpx 24rpx;
  padding-bottom: calc(16rpx + env(safe-area-inset-bottom));
  background: #fff;
  box-shadow: 0 -2rpx 12rpx rgba(0, 0, 0, 0.06);
  display: flex;
  gap: 16rpx;

  .action-btn {
    flex: 1;
    height: 88rpx;
    font-size: 32rpx;
    font-weight: 600;
    border-radius: 44rpx;
    border: none;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8rpx;

    &.navigate {
      background: $primary-color;
      color: #fff;
    }

    &.call {
      background: $success-color;
      color: #fff;
    }

    &.primary {
      background: $primary-color;
      color: #fff;
      flex: 2;
    }

    &.warning {
      background: $warning-color;
      color: #fff;
      flex: 2;
    }

    &.success {
      background: $success-color;
      color: #fff;
      flex: 2;
    }
  }
}

.loading-page {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 60vh;

  .loading-text {
    font-size: 28rpx;
    color: $text-secondary;
  }
}
</style>
