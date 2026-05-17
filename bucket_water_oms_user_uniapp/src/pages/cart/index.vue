<template>
  <view class="page">
    <view class="empty-state" v-if="cartStore.isEmpty">
      <text class="empty-icon">🛒</text>
      <text class="empty-text">购物车是空的</text>
      <button class="btn btn-primary" @click="goHome">去逛逛</button>
    </view>

    <scroll-view class="cart-list" scroll-y v-else>
      <view class="station-group" v-for="[stationId, items] in cartStore.getItemsByStation" :key="stationId">
        <view class="group-header">
          <text class="station-name">{{ items[0]?.stationName }}</text>
        </view>

        <view class="cart-item" v-for="item in items" :key="item.id">
          <view class="item-checkbox" @click="toggleSelect(item.id)">
            <view class="checkbox" :class="{ checked: selectedIds.includes(item.id) }">
              <text v-if="selectedIds.includes(item.id)">✓</text>
            </view>
          </view>

          <image class="item-image" :src="item.image || '/static/images/default-product.png'" mode="aspectFill"></image>

          <view class="item-info">
            <text class="item-name">{{ item.productName }}</text>
            <text class="item-price">¥{{ item.price.toFixed(2) }}</text>
          </view>

          <view class="item-actions">
            <view class="quantity-control">
              <text class="qty-btn" @click="decrease(item.id, item.quantity)">-</text>
              <text class="qty-value">{{ item.quantity }}</text>
              <text class="qty-btn" @click="increase(item.id)">+</text>
            </view>
            <text class="delete-btn" @click="removeItem(item.id)">删除</text>
          </view>
        </view>
      </view>
    </scroll-view>

    <view class="cart-footer" v-if="!cartStore.isEmpty">
      <view class="select-all" @click="toggleSelectAll">
        <view class="checkbox" :class="{ checked: isAllSelected }">
          <text v-if="isAllSelected">✓</text>
        </view>
        <text class="select-text">全选</text>
      </view>

      <view class="total-info">
        <text class="total-label">合计：</text>
        <text class="total-amount">¥{{ totalAmount.toFixed(2) }}</text>
      </view>

      <button class="checkout-btn" :disabled="selectedIds.length === 0" @click="checkout">
        结算({{ selectedCount }})
      </button>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useCartStore } from '@/stores/cart'
import { useAuthStore } from '@/stores/auth'

const cartStore = useCartStore()
const authStore = useAuthStore()

const selectedIds = ref<string[]>([])

const totalAmount = computed(() => {
  return cartStore.items
    .filter(item => selectedIds.value.includes(item.id))
    .reduce((sum, item) => sum + item.price * item.quantity, 0)
})

const selectedCount = computed(() => selectedIds.value.length)

const isAllSelected = computed(() => {
  return cartStore.items.length > 0 && selectedIds.value.length === cartStore.items.length
})

const goHome = () => {
  uni.switchTab({ url: '/pages/index/index' })
}

const toggleSelect = (id: string) => {
  const index = selectedIds.value.indexOf(id)
  if (index > -1) {
    selectedIds.value.splice(index, 1)
  } else {
    selectedIds.value.push(id)
  }
}

const toggleSelectAll = () => {
  if (isAllSelected.value) {
    selectedIds.value = []
  } else {
    selectedIds.value = cartStore.items.map(item => item.id)
  }
}

const increase = (id: string) => {
  const item = cartStore.items.find(i => i.id === id)
  if (item) {
    cartStore.updateQuantity(id, item.quantity + 1)
  }
}

const decrease = (id: string, quantity: number) => {
  if (quantity > 1) {
    cartStore.updateQuantity(id, quantity - 1)
  }
}

const removeItem = (id: string) => {
  uni.showModal({
    title: '提示',
    content: '确定要删除该商品吗？',
    success: (res) => {
      if (res.confirm) {
        cartStore.removeFromCart(id)
        selectedIds.value = selectedIds.value.filter(i => i !== id)
      }
    }
  })
}

const checkout = () => {
  if (!authStore.isLoggedIn) {
    uni.navigateTo({ url: '/pages-auth/login' })
    return
  }

  const selectedItems = cartStore.items.filter(item => selectedIds.value.includes(item.id))
  const stationId = selectedItems[0]?.stationId

  uni.navigateTo({
    url: `/pages-order/create?items=${encodeURIComponent(JSON.stringify(selectedItems))}&stationId=${stationId}`
  })
}

onMounted(() => {
  cartStore.initCart()
})
</script>

<style lang="scss" scoped>
.page {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background-color: $bg-color;
}

.empty-state {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;

  .empty-icon {
    font-size: 160rpx;
    margin-bottom: 32rpx;
  }

  .empty-text {
    font-size: 28rpx;
    color: $text-secondary;
    margin-bottom: 48rpx;
  }
}

.cart-list {
  flex: 1;
  padding: 24rpx;
  padding-bottom: 200rpx;
}

.station-group {
  background-color: #fff;
  border-radius: $radius-lg;
  padding: 24rpx;
  margin-bottom: 24rpx;
  box-shadow: $shadow-sm;
}

.group-header {
  display: flex;
  align-items: center;
  padding-bottom: 16rpx;
  border-bottom: 1rpx solid $border-color;
  margin-bottom: 16rpx;

  .station-name {
    font-size: 28rpx;
    font-weight: 600;
    color: $text-primary;
  }
}

.cart-item {
  display: flex;
  align-items: center;
  padding: 16rpx 0;

  &:not(:last-child) {
    border-bottom: 1rpx solid $border-color;
  }
}

.item-checkbox {
  padding: 0 8rpx;
}

.checkbox {
  width: 40rpx;
  height: 40rpx;
  border: 2rpx solid $border-color;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;

  &.checked {
    background-color: $primary-color;
    border-color: $primary-color;
    color: #fff;
    font-size: 24rpx;
  }
}

.item-image {
  width: 140rpx;
  height: 140rpx;
  border-radius: $radius-md;
  margin: 0 16rpx;
  background-color: #f5f5f5;
}

.item-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;

  .item-name {
    font-size: 28rpx;
    color: $text-primary;
    margin-bottom: 8rpx;
  }

  .item-price {
    font-size: 30rpx;
    font-weight: 600;
    color: $error-color;
  }
}

.item-actions {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 12rpx;
}

.quantity-control {
  display: flex;
  align-items: center;
  background-color: #f5f5f5;
  border-radius: $radius-md;

  .qty-btn {
    width: 56rpx;
    height: 56rpx;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 32rpx;
    color: $text-primary;
  }

  .qty-value {
    width: 60rpx;
    text-align: center;
    font-size: 28rpx;
    color: $text-primary;
  }
}

.delete-btn {
  font-size: 24rpx;
  color: $text-tertiary;
}

.cart-footer {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  display: flex;
  align-items: center;
  height: 120rpx;
  padding: 0 32rpx;
  background-color: #fff;
  box-shadow: 0 -2rpx 12rpx rgba(0, 0, 0, 0.06);
  padding-bottom: constant(safe-area-inset-bottom);
  padding-bottom: env(safe-area-inset-bottom);
}

.select-all {
  display: flex;
  align-items: center;
  margin-right: 24rpx;

  .select-text {
    font-size: 28rpx;
    color: $text-primary;
    margin-left: 12rpx;
  }
}

.total-info {
  flex: 1;
  text-align: right;
  margin-right: 24rpx;

  .total-label {
    font-size: 26rpx;
    color: $text-secondary;
  }

  .total-amount {
    font-size: 36rpx;
    font-weight: 600;
    color: $error-color;
  }
}

.checkout-btn {
  width: 200rpx;
  height: 80rpx;
  background-color: $primary-color;
  color: #fff;
  font-size: 30rpx;
  border-radius: 40rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  border: none;

  &[disabled] {
    background-color: $text-tertiary;
  }
}
</style>
