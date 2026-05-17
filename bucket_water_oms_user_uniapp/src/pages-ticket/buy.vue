<template>
  <view class="buy-ticket-page">
    <scroll-view class="content" scroll-y v-if="ticket">
      <view class="ticket-banner">
        <view class="ticket-icon">🎫</view>
        <view class="ticket-info">
          <text class="ticket-name">{{ ticket.ticketName }}</text>
          <text class="product-name">{{ ticket.productName }}{{ ticket.productSpec ? ` (${ticket.productSpec})` : '' }}</text>
        </view>
      </view>

      <view class="price-section">
        <view class="price-row">
          <text class="price-label">售价</text>
          <view class="price-value">
            <text class="current-price">¥{{ ticket.price }}</text>
            <text class="original-price" v-if="ticket.discount < 10">¥{{ ticket.originalPrice }}</text>
            <text class="discount-tag" v-if="ticket.discount < 10">{{ ticket.discount }}折</text>
          </view>
        </view>
        <view class="price-row">
          <text class="price-label">节省</text>
          <text class="save-amount">¥{{ (ticket.originalPrice - ticket.price).toFixed(2) }}</text>
        </view>
      </view>

      <view class="info-section">
        <view class="info-item">
          <text class="info-icon">🪣</text>
          <view class="info-content">
            <text class="info-label">桶数</text>
            <text class="info-value">{{ ticket.bucketCount }} 桶</text>
          </view>
        </view>
        <view class="info-item">
          <text class="info-icon">📅</text>
          <view class="info-content">
            <text class="info-label">有效期</text>
            <text class="info-value">自购买日起 {{ ticket.validityDays }} 天</text>
          </view>
        </view>
        <view class="info-item">
          <text class="info-icon">📦</text>
          <view class="info-content">
            <text class="info-label">库存</text>
            <text class="info-value" :class="{ 'low-stock': ticket.stock < 10 }">
              {{ ticket.stock > 0 ? `剩余 ${ticket.stock} 份` : '已售罄' }}
            </text>
          </view>
        </view>
      </view>

      <view class="quantity-section">
        <text class="section-title">购买数量</text>
        <view class="quantity-control">
          <text class="quantity-btn" @click="decreaseQuantity">−</text>
          <input class="quantity-input" type="number" v-model="quantity" @input="onQuantityChange" />
          <text class="quantity-btn" @click="increaseQuantity">+</text>
        </view>
      </view>

      <view class="summary-section">
        <view class="summary-row">
          <text class="summary-label">水票小计</text>
          <text class="summary-value">¥{{ (ticket.price * quantity).toFixed(2) }}</text>
        </view>
        <view class="summary-row">
          <text class="summary-label">原价小计</text>
          <text class="summary-original">¥{{ (ticket.originalPrice * quantity).toFixed(2) }}</text>
        </view>
        <view class="summary-row total">
          <text class="summary-label">合计</text>
          <text class="summary-total">¥{{ totalAmount.toFixed(2) }}</text>
        </view>
        <view class="summary-row save">
          <text class="summary-label">共节省</text>
          <text class="summary-save">¥{{ totalSave.toFixed(2) }}</text>
        </view>
      </view>

      <view class="payment-section">
        <text class="section-title">支付方式</text>
        <radio-group @change="onPaymentChange">
          <view class="payment-item" :class="{ selected: payMethod === 'wechat' }" @click="payMethod = 'wechat'">
            <view class="payment-left">
              <text class="payment-icon wechat">微信</text>
              <view class="payment-info">
                <text class="payment-name">微信支付</text>
                <text class="payment-desc">推荐</text>
              </view>
            </view>
            <radio :checked="payMethod === 'wechat'" value="wechat" color="#07C160" />
          </view>

          <view class="payment-item" :class="{ selected: payMethod === 'balance' }" @click="payMethod = 'balance'">
            <view class="payment-left">
              <text class="payment-icon balance">余额</text>
              <view class="payment-info">
                <text class="payment-name">账户余额</text>
                <text class="payment-balance">可用余额: ¥{{ userBalance.toFixed(2) }}</text>
              </view>
            </view>
            <radio :checked="payMethod === 'balance'" value="balance" color="#07C160" />
          </view>
        </radio-group>
      </view>

      <view class="notice-section">
        <text class="notice-title">购买须知</text>
        <view class="notice-list">
          <text class="notice-item">1. 水票购买后不支持退款，请谨慎选择</text>
          <text class="notice-item">2. 水票有效期为 {{ ticket.validityDays }} 天，请在有效期内使用</text>
          <text class="notice-item">3. 使用水票下单时，系统自动抵扣相应桶数</text>
          <text class="notice-item">4. 如有疑问，请联系水站客服</text>
        </view>
      </view>
    </scroll-view>

    <view class="bottom-bar">
      <view class="total-info">
        <text class="total-label">合计</text>
        <text class="total-amount">¥{{ totalAmount.toFixed(2) }}</text>
      </view>
      <button class="buy-btn" :disabled="!canBuy || buying" @click="handleBuy">
        <text class="btn-text" v-if="!buying">立即购买</text>
        <text class="btn-text" v-else>购买中...</text>
      </button>
    </view>

    <view class="loading-overlay" v-if="loading">
      <text class="loading-text">加载中...</text>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { ticketService, TicketPackage } from '@/services/ticketService'
import { authStore } from '@/stores/auth'

const ticketId = ref('')
const ticket = ref<TicketPackage | null>(null)
const quantity = ref(1)
const payMethod = ref<'wechat' | 'balance'>('wechat')
const loading = ref(false)
const buying = ref(false)
const userBalance = ref(0)

const totalAmount = computed(() => {
  if (!ticket.value) return 0
  return ticket.value.price * quantity.value
})

const totalSave = computed(() => {
  if (!ticket.value) return 0
  return (ticket.value.originalPrice - ticket.value.price) * quantity.value
})

const canBuy = computed(() => {
  if (!ticket.value || ticket.value.stock <= 0) return false
  if (quantity.value < 1 || quantity.value > ticket.value.stock) return false
  if (payMethod.value === 'balance' && userBalance.value < totalAmount.value) return false
  return true
})

const decreaseQuantity = () => {
  if (quantity.value > 1) {
    quantity.value--
  }
}

const increaseQuantity = () => {
  if (ticket.value && quantity.value < ticket.value.stock) {
    quantity.value++
  }
}

const onQuantityChange = () => {
  const val = parseInt(String(quantity.value))
  if (isNaN(val) || val < 1) {
    quantity.value = 1
  } else if (ticket.value && val > ticket.value.stock) {
    quantity.value = ticket.value.stock
  } else {
    quantity.value = val
  }
}

const onPaymentChange = (e: any) => {
  payMethod.value = e.detail.value
}

const loadTicketDetail = async () => {
  if (!ticketId.value) return
  
  loading.value = true
  
  try {
    const result = await ticketService.getTicketPackageDetail(ticketId.value)
    if (result) {
      ticket.value = result
      uni.setNavigationBarTitle({ title: `购买 ${result.ticketName}` })
    }
  } catch (error) {
    console.error('加载水票详情失败:', error)
    uni.showToast({ title: '加载失败', icon: 'error' })
  } finally {
    loading.value = false
  }
}

const loadUserBalance = () => {
  const userInfo = authStore.state.userInfo
  if (userInfo) {
    userBalance.value = userInfo.balance || 0
  }
}

const handleBuy = async () => {
  if (!canBuy.value || buying.value || !ticket.value) return
  
  buying.value = true
  
  try {
    const result = await ticketService.buyTicket({
      ticketPackageId: ticket.value.id,
      quantity: quantity.value,
      payMethod: payMethod.value
    })
    
    if (result.needPay) {
      if (payMethod.value === 'wechat') {
        uni.showToast({ title: '即将跳转微信支付' })
      } else {
        uni.showToast({ title: '余额不足，请选择其他支付方式' })
      }
    } else {
      uni.showToast({ title: '购买成功' })
      setTimeout(() => {
        uni.navigateBack()
      }, 1500)
    }
  } catch (error) {
    console.error('购买失败:', error)
    uni.showToast({ title: '购买失败，请重试', icon: 'error' })
  } finally {
    buying.value = false
  }
}

onMounted(() => {
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1] as any
  const options = currentPage?.options || {}
  
  ticketId.value = options.id || ''
  
  if (ticketId.value) {
    loadTicketDetail()
  }
  
  loadUserBalance()
})
</script>

<style lang="scss" scoped>
.buy-ticket-page {
  min-height: 100vh;
  background: $bg-color;
  padding-bottom: 140rpx;
}

.content {
  padding: 24rpx;
}

.ticket-banner {
  display: flex;
  align-items: center;
  background: linear-gradient(135deg, $primary-color 0%, #4096ff 100%);
  border-radius: $radius-xl;
  padding: 32rpx;
  margin-bottom: 24rpx;

  .ticket-icon {
    font-size: 80rpx;
    margin-right: 24rpx;
  }

  .ticket-info {
    flex: 1;

    .ticket-name {
      display: block;
      font-size: 36rpx;
      font-weight: 700;
      color: #fff;
      margin-bottom: 8rpx;
    }

    .product-name {
      display: block;
      font-size: 26rpx;
      color: rgba(255, 255, 255, 0.8);
    }
  }
}

.price-section {
  background: #fff;
  border-radius: $radius-lg;
  padding: 24rpx;
  margin-bottom: 24rpx;

  .price-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12rpx 0;

    &:first-child {
      border-bottom: 1rpx solid $border-color;
      padding-bottom: 20rpx;
      margin-bottom: 12rpx;
    }

    .price-label {
      font-size: 28rpx;
      color: $text-secondary;
    }

    .price-value {
      display: flex;
      align-items: baseline;
      gap: 12rpx;

      .current-price {
        font-size: 48rpx;
        font-weight: 700;
        color: $error-color;
      }

      .original-price {
        font-size: 28rpx;
        color: $text-tertiary;
        text-decoration: line-through;
      }

      .discount-tag {
        font-size: 22rpx;
        color: #fff;
        background: $error-color;
        padding: 4rpx 12rpx;
        border-radius: 12rpx;
      }
    }

    .save-amount {
      font-size: 32rpx;
      font-weight: 600;
      color: $success-color;
    }
  }
}

.info-section {
  background: #fff;
  border-radius: $radius-lg;
  padding: 24rpx;
  margin-bottom: 24rpx;

  .info-item {
    display: flex;
    align-items: center;
    padding: 16rpx 0;
    border-bottom: 1rpx solid $border-color;

    &:last-child {
      border-bottom: none;
    }

    .info-icon {
      font-size: 40rpx;
      margin-right: 20rpx;
    }

    .info-content {
      flex: 1;
      display: flex;
      justify-content: space-between;
      align-items: center;

      .info-label {
        font-size: 28rpx;
        color: $text-secondary;
      }

      .info-value {
        font-size: 28rpx;
        color: $text-primary;
        font-weight: 600;

        &.low-stock {
          color: $warning-color;
        }
      }
    }
  }
}

.quantity-section {
  background: #fff;
  border-radius: $radius-lg;
  padding: 24rpx;
  margin-bottom: 24rpx;

  .section-title {
    display: block;
    font-size: 28rpx;
    font-weight: 600;
    color: $text-primary;
    margin-bottom: 20rpx;
  }

  .quantity-control {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 32rpx;

    .quantity-btn {
      width: 64rpx;
      height: 64rpx;
      line-height: 64rpx;
      text-align: center;
      font-size: 40rpx;
      color: $primary-color;
      background: rgba($primary-color, 0.1);
      border-radius: 50%;
    }

    .quantity-input {
      width: 160rpx;
      height: 64rpx;
      text-align: center;
      font-size: 36rpx;
      font-weight: 600;
      background: $bg-color;
      border-radius: 12rpx;
    }
  }
}

.summary-section {
  background: #fff;
  border-radius: $radius-lg;
  padding: 24rpx;
  margin-bottom: 24rpx;

  .summary-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12rpx 0;

    &.total {
      border-top: 2rpx solid $border-color;
      margin-top: 12rpx;
      padding-top: 20rpx;

      .summary-label {
        font-size: 32rpx;
        font-weight: 600;
      }

      .summary-total {
        font-size: 48rpx;
        font-weight: 700;
        color: $error-color;
      }
    }

    &.save {
      .summary-save {
        font-size: 28rpx;
        color: $success-color;
        font-weight: 600;
      }
    }

    .summary-label {
      font-size: 28rpx;
      color: $text-secondary;
    }

    .summary-value {
      font-size: 28rpx;
      color: $text-primary;
    }

    .summary-original {
      font-size: 26rpx;
      color: $text-tertiary;
      text-decoration: line-through;
    }
  }
}

.payment-section {
  background: #fff;
  border-radius: $radius-lg;
  padding: 24rpx;
  margin-bottom: 24rpx;

  .section-title {
    display: block;
    font-size: 28rpx;
    font-weight: 600;
    color: $text-primary;
    margin-bottom: 20rpx;
  }

  .payment-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 24rpx;
    border: 2rpx solid $border-color;
    border-radius: $radius-lg;
    margin-bottom: 16rpx;
    transition: all 0.3s;

    &:last-child {
      margin-bottom: 0;
    }

    &.selected {
      border-color: $success-color;
      background: rgba($success-color, 0.05);
    }

    .payment-left {
      display: flex;
      align-items: center;

      .payment-icon {
        width: 64rpx;
        height: 64rpx;
        line-height: 64rpx;
        text-align: center;
        font-size: 24rpx;
        font-weight: 600;
        color: #fff;
        border-radius: 12rpx;
        margin-right: 16rpx;

        &.wechat {
          background: #07C160;
        }

        &.balance {
          background: $warning-color;
        }
      }

      .payment-info {
        .payment-name {
          display: block;
          font-size: 28rpx;
          font-weight: 600;
          color: $text-primary;
          margin-bottom: 4rpx;
        }

        .payment-desc {
          display: block;
          font-size: 22rpx;
          color: $primary-color;
        }

        .payment-balance {
          display: block;
          font-size: 24rpx;
          color: $text-secondary;
        }
      }
    }
  }
}

.notice-section {
  background: #fff;
  border-radius: $radius-lg;
  padding: 24rpx;
  margin-bottom: 24rpx;

  .notice-title {
    display: block;
    font-size: 28rpx;
    font-weight: 600;
    color: $text-primary;
    margin-bottom: 16rpx;
  }

  .notice-list {
    .notice-item {
      display: block;
      font-size: 24rpx;
      color: $text-secondary;
      line-height: 1.8;
      margin-bottom: 8rpx;

      &:last-child {
        margin-bottom: 0;
      }
    }
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

  .total-info {
    .total-label {
      font-size: 26rpx;
      color: $text-secondary;
      margin-right: 8rpx;
    }

    .total-amount {
      font-size: 40rpx;
      font-weight: 700;
      color: $error-color;
    }
  }

  .buy-btn {
    margin-left: auto;
    padding: 0 48rpx;
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
