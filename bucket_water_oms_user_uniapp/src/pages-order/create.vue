<template>
  <view class="create-order-page">
    <scroll-view class="content" scroll-y>
      <view class="address-section" @click="chooseAddress">
        <view class="address-content" v-if="selectedAddress">
          <view class="address-main">
            <text class="contact">{{ selectedAddress.contactName }}</text>
            <text class="phone">{{ selectedAddress.contactPhone }}</text>
          </view>
          <text class="address-detail">{{ formatAddress(selectedAddress) }}</text>
        </view>
        <view class="address-empty" v-else>
          <text>请选择收货地址</text>
        </view>
        <text class="address-arrow">></text>
      </view>

      <view class="store-section">
        <view class="store-header">
          <text class="store-name">{{ stationName || '水站商品' }}</text>
        </view>

        <view class="product-list">
          <view class="product-item" v-for="item in cartItems" :key="item.id">
            <image class="product-image" :src="item.image || '/static/images/default-product.png'" mode="aspectFill"></image>
            <view class="product-info">
              <text class="product-name">{{ item.productName }}</text>
              <text class="product-price">¥{{ item.price.toFixed(2) }}</text>
            </view>
            <view class="product-qty">x{{ item.quantity }}</view>
          </view>
        </view>
      </view>

      <view class="remark-section">
        <text class="section-label">备注</text>
        <textarea
          class="remark-input"
          v-model="remark"
          placeholder="选填，可备注特殊需求"
          maxlength="200"
        />
      </view>

      <view class="payment-section">
        <text class="section-title">支付方式</text>
        <view class="payment-list">
          <view
            class="payment-item"
            :class="{ selected: payMethod === 'wechat' }"
            @click="payMethod = 'wechat'"
          >
            <text class="payment-icon">💬</text>
            <text class="payment-name">微信支付</text>
            <view class="payment-check" v-if="payMethod === 'wechat'">✓</view>
          </view>
          <view
            class="payment-item"
            :class="{ selected: payMethod === 'balance' }"
            @click="payMethod = 'balance'"
          >
            <text class="payment-icon">💰</text>
            <text class="payment-name">余额支付</text>
            <text class="balance-hint" v-if="balance > 0">（余额：¥{{ balance.toFixed(2) }}）</text>
            <view class="payment-check" v-if="payMethod === 'balance'">✓</view>
          </view>
          <view
            class="payment-item"
            :class="{ selected: payMethod === 'cod' }"
            @click="payMethod = 'cod'"
          >
            <text class="payment-icon">💵</text>
            <text class="payment-name">货到付款</text>
            <view class="payment-check" v-if="payMethod === 'cod'">✓</view>
          </view>
        </view>
      </view>
    </scroll-view>

    <view class="bottom-bar">
      <view class="total-info">
        <text class="total-label">合计：</text>
        <text class="total-amount">¥{{ totalAmount.toFixed(2) }}</text>
      </view>
      <button class="submit-btn" @click="submitOrder" :disabled="!canSubmit">
        提交订单
      </button>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { orderService } from '@/services/orderService'
import { addressService } from '@/services/addressService'
import { useCartStore } from '@/stores/cart'
import { useAuthStore } from '@/stores/auth'
import type { Address, CartItem } from '@/types/order'

const authStore = useAuthStore()
const cartStore = useCartStore()

const selectedAddress = ref<Address | null>(null)
const cartItems = ref<CartItem[]>([])
const stationId = ref('')
const stationName = ref('')
const remark = ref('')
const payMethod = ref<'wechat' | 'balance' | 'cod'>('wechat')
const balance = ref(0)

const totalAmount = computed(() => {
  return cartItems.value.reduce((sum, item) => sum + item.price * item.quantity, 0)
})

const canSubmit = computed(() => {
  return selectedAddress.value && cartItems.value.length > 0
})

const formatAddress = (addr: Address) => {
  return `${addr.province || ''}${addr.city || ''}${addr.district || ''}${addr.detail || ''}`
}

const chooseAddress = () => {
  uni.navigateTo({
    url: '/pages-address/select?select=true'
  })
}

const loadDefaultAddress = async () => {
  try {
    const result = await addressService.getAddressList()
    if (result && result.length > 0) {
      selectedAddress.value = result.find(a => a.isDefault) || result[0]
    }
  } catch (error) {
    console.error('获取地址失败:', error)
  }
}

const submitOrder = async () => {
  if (!canSubmit.value) {
    uni.showToast({ title: '请选择收货地址', icon: 'none' })
    return
  }

  if (!authStore.isLoggedIn) {
    uni.navigateTo({ url: '/pages-auth/login' })
    return
  }

  uni.showModal({
    title: '确认下单',
    content: `确认提交订单，金额 ¥${totalAmount.value.toFixed(2)}？`,
    success: async (res) => {
      if (res.confirm) {
        uni.showLoading({ title: '提交中...' })

        try {
          const result = await orderService.createOrder({
            stationId: stationId.value,
            addressId: selectedAddress.value!.id,
            items: cartItems.value.map(item => ({
              productId: item.productId,
              quantity: item.quantity
            })),
            remark: remark.value || undefined,
            payMethod: payMethod.value
          })

          if (result) {
            cartStore.clearCart()

            uni.hideLoading()
            uni.showToast({ title: '订单提交成功', icon: 'success' })

            setTimeout(() => {
              uni.redirectTo({
                url: `/pages/order/detail?id=${result.orderId}`
              })
            }, 1500)
          }
        } catch (error) {
          uni.hideLoading()
          uni.showToast({ title: '订单提交失败', icon: 'none' })
        }
      }
    }
  })
}

onMounted(() => {
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1] as any
  const options = currentPage?.options || {}

  if (options.items) {
    try {
      cartItems.value = JSON.parse(decodeURIComponent(options.items))
      stationId.value = options.stationId || ''

      if (cartItems.value.length > 0) {
        stationName.value = cartItems.value[0].stationName || ''
      }
    } catch (e) {
      console.error('解析购物车数据失败:', e)
    }
  }

  loadDefaultAddress()
})
</script>

<style lang="scss" scoped>
.create-order-page {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background-color: $bg-color;
  padding-bottom: 120rpx;
}

.content {
  flex: 1;
}

.address-section {
  display: flex;
  align-items: center;
  background-color: #fff;
  padding: 32rpx 24rpx;
  margin-bottom: 16rpx;
}

.address-content {
  flex: 1;

  .address-main {
    display: flex;
    align-items: center;
    margin-bottom: 8rpx;
  }

  .contact {
    font-size: 32rpx;
    font-weight: 600;
    color: $text-primary;
    margin-right: 16rpx;
  }

  .phone {
    font-size: 28rpx;
    color: $text-secondary;
  }

  .address-detail {
    font-size: 26rpx;
    color: $text-secondary;
  }
}

.address-empty {
  flex: 1;
  font-size: 28rpx;
  color: $text-tertiary;
}

.address-arrow {
  font-size: 24rpx;
  color: $text-tertiary;
}

.store-section {
  background-color: #fff;
  padding: 24rpx;
  margin-bottom: 16rpx;
}

.store-header {
  margin-bottom: 20rpx;

  .store-name {
    font-size: 28rpx;
    font-weight: 600;
    color: $text-primary;
  }
}

.product-list {
  .product-item {
    display: flex;
    align-items: center;
    padding: 16rpx 0;
    border-bottom: 1rpx solid $border-color;

    &:last-child {
      border-bottom: none;
    }
  }

  .product-image {
    width: 120rpx;
    height: 120rpx;
    border-radius: $radius-md;
    margin-right: 20rpx;
    background-color: #f5f5f5;
  }

  .product-info {
    flex: 1;

    .product-name {
      display: block;
      font-size: 28rpx;
      color: $text-primary;
      margin-bottom: 8rpx;
    }

    .product-price {
      font-size: 28rpx;
      font-weight: 600;
      color: $error-color;
    }
  }

  .product-qty {
    font-size: 28rpx;
    color: $text-secondary;
  }
}

.remark-section {
  background-color: #fff;
  padding: 24rpx;
  margin-bottom: 16rpx;
}

.section-label {
  font-size: 28rpx;
  font-weight: 600;
  color: $text-primary;
  margin-bottom: 16rpx;
}

.remark-input {
  width: 100%;
  min-height: 120rpx;
  padding: 16rpx;
  background-color: #f8f8f8;
  border-radius: $radius-md;
  font-size: 28rpx;
  color: $text-primary;
  line-height: 1.6;
}

.payment-section {
  background-color: #fff;
  padding: 24rpx;
}

.section-title {
  font-size: 28rpx;
  font-weight: 600;
  color: $text-primary;
  margin-bottom: 20rpx;
}

.payment-list {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}

.payment-item {
  display: flex;
  align-items: center;
  padding: 20rpx 24rpx;
  background-color: #f8f8f8;
  border-radius: $radius-lg;
  border: 2rpx solid transparent;

  &.selected {
    background-color: rgba($primary-color, 0.05);
    border-color: $primary-color;
  }

  .payment-icon {
    font-size: 36rpx;
    margin-right: 16rpx;
  }

  .payment-name {
    flex: 1;
    font-size: 28rpx;
    color: $text-primary;
  }

  .balance-hint {
    font-size: 24rpx;
    color: $text-tertiary;
    margin-right: 16rpx;
  }

  .payment-check {
    width: 40rpx;
    height: 40rpx;
    background-color: $primary-color;
    color: #fff;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 24rpx;
  }
}

.bottom-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  display: flex;
  align-items: center;
  height: 100rpx;
  padding: 0 24rpx;
  padding-bottom: constant(safe-area-inset-bottom);
  padding-bottom: env(safe-area-inset-bottom);
  background-color: #fff;
  box-shadow: 0 -2rpx 12rpx rgba(0,0,0,0.06);
}

.total-info {
  flex: 1;

  .total-label {
    font-size: 26rpx;
    color: $text-secondary;
  }

  .total-amount {
    font-size: 40rpx;
    font-weight: 700;
    color: $error-color;
    margin-left: 8rpx;
  }
}

.submit-btn {
  width: 240rpx;
  height: 80rpx;
  background-color: $primary-color;
  color: #fff;
  font-size: 30rpx;
  font-weight: 600;
  border-radius: 40rpx;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;

  &[disabled] {
    background-color: #ccc;
  }
}
</style>
