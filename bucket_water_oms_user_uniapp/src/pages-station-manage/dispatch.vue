<template>
  <view class="dispatch-page">
    <view class="order-info" v-if="order">
      <view class="info-header">
        <text class="section-title">订单信息</text>
      </view>
      
      <view class="info-card">
        <view class="info-row">
          <text class="info-label">订单号</text>
          <text class="info-value">{{ order.orderNo }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">下单时间</text>
          <text class="info-value">{{ formatTime(order.createdAt) }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">客户姓名</text>
          <text class="info-value">{{ order.address?.contactName }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">联系电话</text>
          <text class="info-value link" @click="callCustomer">{{ order.address?.contactPhone }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">收货地址</text>
          <text class="info-value">{{ formatAddress(order.address) }}</text>
        </view>
      </view>

      <view class="info-card">
        <view class="items-header">
          <text class="items-title">商品明细</text>
          <text class="items-count">共 {{ order.items.length }} 件</text>
        </view>
        <view class="item-row" v-for="item in order.items" :key="item.id">
          <text class="item-name">{{ item.productName }}</text>
          <text class="item-qty">x{{ item.quantity }}</text>
          <text class="item-price">¥{{ item.subtotal.toFixed(2) }}</text>
        </view>
        <view class="total-row">
          <text class="total-label">合计</text>
          <text class="total-amount">¥{{ order.payAmount.toFixed(2) }}</text>
        </view>
      </view>
    </view>

    <view class="delivery-persons-section">
      <view class="section-header">
        <text class="section-title">选择配送员</text>
        <text class="section-count">{{ availablePersons.length }} 人可派</text>
      </view>

      <view class="persons-list">
        <view class="person-card" 
          v-for="person in availablePersons" 
          :key="person.id"
          :class="{ selected: selectedPersonId === person.id }"
          @click="selectPerson(person.id)">
          <view class="person-avatar">
            <image class="avatar-img" :src="person.avatar || '/static/images/default-avatar.png'" mode="aspectFill" />
            <view class="status-dot" :class="person.status"></view>
          </view>
          <view class="person-info">
            <text class="person-name">{{ person.name }}</text>
            <text class="person-phone">{{ person.phone }}</text>
            <view class="person-stats">
              <text class="stat-item">今日 {{ person.todayOrders }} 单</text>
              <text class="stat-separator">|</text>
              <text class="stat-item">评分 {{ person.rating.toFixed(1) }}</text>
            </view>
          </view>
          <view class="select-indicator">
            <text class="check-icon" v-if="selectedPersonId === person.id">✓</text>
          </view>
        </view>
      </view>

      <view class="empty-persons" v-if="availablePersons.length === 0 && !loading">
        <text class="empty-icon">👤</text>
        <text class="empty-text">暂无可用配送员</text>
        <text class="empty-hint">请先添加配送员</text>
      </view>
    </view>

    <view class="bottom-bar">
      <button class="dispatch-btn" :disabled="!selectedPersonId || dispatching" @click="confirmDispatch">
        <text class="btn-text" v-if="!dispatching">确认派单</text>
        <text class="btn-text" v-else>派单中...</text>
      </button>
    </view>

    <view class="loading-overlay" v-if="loading">
      <text class="loading-text">加载中...</text>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { stationOrderService, StationOrder, DeliveryPerson } from '@/services/stationOrderService'

const orderId = ref('')
const order = ref<StationOrder | null>(null)
const availablePersons = ref<DeliveryPerson[]>([])
const selectedPersonId = ref('')
const loading = ref(false)
const dispatching = ref(false)

const formatTime = (time: string) => {
  if (!time) return '--'
  const date = new Date(time)
  return `${date.getMonth() + 1}-${date.getDate()} ${date.getHours()}:${String(date.getMinutes()).padStart(2, '0')}`
}

const formatAddress = (addr: any) => {
  if (!addr) return ''
  return `${addr.province || ''}${addr.city || ''}${addr.district || ''}${addr.detail || ''}`
}

const callCustomer = () => {
  if (order.value?.address?.contactPhone) {
    uni.makePhoneCall({ phoneNumber: order.value.address.contactPhone })
  }
}

const selectPerson = (personId: string) => {
  selectedPersonId.value = selectedPersonId.value === personId ? '' : personId
}

const loadOrderDetail = async () => {
  if (!orderId.value) return
  loading.value = true
  try {
    const result = await stationOrderService.getOrderDetail(orderId.value)
    if (result) {
      order.value = result
    }
  } catch (error) {
    console.error('加载订单详情失败:', error)
    uni.showToast({ title: '加载失败', icon: 'error' })
  } finally {
    loading.value = false
  }
}

const loadDeliveryPersons = async () => {
  loading.value = true
  try {
    const result = await stationOrderService.getDeliveryPersons({ status: 'active' })
    if (result) {
      availablePersons.value = result.filter(p => p.status === 'active' || p.status === 'online')
    }
  } catch (error) {
    console.error('加载配送员列表失败:', error)
    uni.showToast({ title: '加载失败', icon: 'error' })
  } finally {
    loading.value = false
  }
}

const confirmDispatch = async () => {
  if (!selectedPersonId.value || !orderId.value) return
  
  uni.showModal({
    title: '确认派单',
    content: `确定派单给 ${availablePersons.value.find(p => p.id === selectedPersonId.value)?.name} 吗？`,
    success: async (res) => {
      if (res.confirm) {
        dispatching.value = true
        try {
          await stationOrderService.dispatch(orderId.value, selectedPersonId.value)
          uni.showToast({ title: '派单成功' })
          setTimeout(() => {
            uni.navigateBack()
          }, 1500)
        } catch (error) {
          console.error('派单失败:', error)
          uni.showToast({ title: '派单失败', icon: 'error' })
        } finally {
          dispatching.value = false
        }
      }
    }
  })
}

onMounted(() => {
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1] as any
  const options = currentPage?.options || {}
  
  orderId.value = options.orderId || ''
  
  if (orderId.value) {
    loadOrderDetail()
  }
  
  loadDeliveryPersons()
})
</script>

<style lang="scss" scoped>
.dispatch-page {
  min-height: 100vh;
  background: $bg-color;
  padding-bottom: 140rpx;
}

.order-info {
  .info-header,
  .section-header {
    padding: 24rpx;
    background: #fff;
    border-bottom: 1rpx solid $border-color;

    .section-title {
      font-size: 32rpx;
      font-weight: 600;
      color: $text-primary;
    }

    .section-count {
      font-size: 26rpx;
      color: $primary-color;
      margin-left: auto;
    }
  }

  .info-card {
    background: #fff;
    margin: 0 24rpx 24rpx;
    border-radius: $radius-lg;
    padding: 24rpx;
    box-shadow: $shadow-sm;

    .info-row {
      display: flex;
      justify-content: space-between;
      padding: 16rpx 0;
      border-bottom: 1rpx solid $border-color;

      &:last-child {
        border-bottom: none;
      }

      .info-label {
        font-size: 28rpx;
        color: $text-secondary;
        min-width: 140rpx;
      }

      .info-value {
        flex: 1;
        font-size: 28rpx;
        color: $text-primary;
        text-align: right;

        &.link {
          color: $primary-color;
        }
      }
    }

    .items-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 16rpx;

      .items-title {
        font-size: 28rpx;
        font-weight: 600;
        color: $text-primary;
      }

      .items-count {
        font-size: 26rpx;
        color: $text-tertiary;
      }
    }

    .item-row {
      display: flex;
      align-items: center;
      padding: 12rpx 0;

      .item-name {
        flex: 1;
        font-size: 28rpx;
        color: $text-primary;
      }

      .item-qty {
        font-size: 26rpx;
        color: $text-secondary;
        margin-right: 24rpx;
      }

      .item-price {
        font-size: 28rpx;
        color: $text-primary;
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
}

.delivery-persons-section {
  .section-header {
    padding: 24rpx;
    background: #fff;
    border-bottom: 1rpx solid $border-color;
    display: flex;
    align-items: center;

    .section-title {
      font-size: 32rpx;
      font-weight: 600;
      color: $text-primary;
    }

    .section-count {
      font-size: 26rpx;
      color: $primary-color;
      margin-left: auto;
    }
  }

  .persons-list {
    padding: 24rpx;

    .person-card {
      display: flex;
      align-items: center;
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

      .person-avatar {
        position: relative;
        margin-right: 20rpx;

        .avatar-img {
          width: 96rpx;
          height: 96rpx;
          border-radius: 50%;
          background: $bg-color;
        }

        .status-dot {
          position: absolute;
          bottom: 4rpx;
          right: 4rpx;
          width: 20rpx;
          height: 20rpx;
          border-radius: 50%;
          border: 4rpx solid #fff;

          &.online,
          &.active {
            background: $success-color;
          }

          &.offline,
          &.inactive {
            background: $text-tertiary;
          }
        }
      }

      .person-info {
        flex: 1;

        .person-name {
          display: block;
          font-size: 30rpx;
          font-weight: 600;
          color: $text-primary;
          margin-bottom: 8rpx;
        }

        .person-phone {
          display: block;
          font-size: 26rpx;
          color: $text-secondary;
          margin-bottom: 8rpx;
        }

        .person-stats {
          display: flex;
          align-items: center;
          gap: 8rpx;

          .stat-item {
            font-size: 24rpx;
            color: $text-tertiary;
          }

          .stat-separator {
            color: $border-color;
          }
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

        .person-card.selected & {
          border-color: $primary-color;
          background: $primary-color;
        }

        .person-card.selected & .check-icon {
          color: #fff;
        }
      }
    }
  }

  .empty-persons {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 80rpx 0;

    .empty-icon {
      font-size: 100rpx;
      margin-bottom: 24rpx;
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

  .dispatch-btn {
    width: 100%;
    height: 88rpx;
    background: $primary-color;
    color: #fff;
    font-size: 32rpx;
    font-weight: 600;
    border-radius: 44rpx;
    border: none;
    display: flex;
    align-items: center;
    justify-content: center;

    &[disabled] {
      background: $text-tertiary;
    }

    .btn-text {
      font-size: 32rpx;
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
