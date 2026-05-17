<template>
  <view class="product-detail-page">
    <scroll-view class="content" scroll-y>
      <view class="image-section">
        <swiper class="product-swiper" indicator-dots autoplay circular v-if="productImages.length > 1">
          <swiper-item v-for="(img, index) in productImages" :key="index">
            <image class="product-image" :src="img" mode="aspectFill" @click="previewImage(index)"></image>
          </swiper-item>
        </swiper>
        <image class="product-image single" v-else :src="productImages[0] || '/static/images/default-product.png'" mode="aspectFill"></image>
      </view>

      <view class="info-section">
        <view class="price-row">
          <text class="current-price">¥{{ product?.price?.toFixed(2) || '0.00' }}</text>
          <text class="original-price" v-if="product?.originalPrice">¥{{ product.originalPrice.toFixed(2) }}</text>
          <view class="discount-tag" v-if="product?.originalPrice">
            {{ discountText }}
          </view>
        </view>

        <view class="product-name">{{ product?.name || '加载中...' }}</view>

        <view class="product-specs" v-if="product?.specifications">
          <text class="spec-label">规格：</text>
          <text class="spec-value">{{ product.specifications }}</text>
        </view>

        <view class="stock-row">
          <text class="stock-label">库存：</text>
          <text class="stock-value" :class="{ 'low-stock': product?.stock && product.stock < 10 }">
            {{ product?.stock || 0 }} {{ product?.unit || '桶' }}
          </text>
        </view>
      </view>

      <view class="tickets-section" v-if="tickets.length > 0">
        <view class="section-header">
          <text class="section-title">水票套餐</text>
          <text class="section-sub">更优惠的选择</text>
        </view>
        <view class="ticket-list">
          <view
            class="ticket-card"
            :class="{ selected: selectedTicket?.id === ticket.id }"
            v-for="ticket in tickets"
            :key="ticket.id"
            @click="selectTicket(ticket)"
          >
            <view class="ticket-main">
              <text class="ticket-name">{{ ticket.name }}</text>
              <text class="ticket-bucket">含{{ ticket.bucketCount }}桶水</text>
            </view>
            <view class="ticket-price">
              <text class="price">¥{{ ticket.price.toFixed(2) }}</text>
              <text class="original">¥{{ ticket.originalPrice.toFixed(2) }}</text>
            </view>
            <view class="ticket-discount">
              <text class="discount">{{ ticket.discount.toFixed(1) }}折</text>
            </view>
            <view class="ticket-select" v-if="selectedTicket?.id === ticket.id">
              <text>✓</text>
            </view>
          </view>
        </view>
      </view>

      <view class="desc-section" v-if="product?.description">
        <view class="section-header">
          <text class="section-title">商品详情</text>
        </view>
        <view class="description">
          <text>{{ product.description }}</text>
        </view>
      </view>
    </scroll-view>

    <view class="action-bar">
      <view class="action-icons">
        <view class="action-icon-item" @click="toggleFavorite">
          <text class="icon">{{ isFavorite ? '❤️' : '🤍' }}</text>
          <text class="label">收藏</text>
        </view>
        <view class="action-icon-item" @click="goToCart">
          <text class="icon">🛒</text>
          <text class="label">购物车</text>
          <view class="badge" v-if="cartCount > 0">{{ cartCount > 99 ? '99+' : cartCount }}</view>
        </view>
      </view>

      <view class="action-buttons">
        <button class="btn-add-cart" @click="addToCart">加入购物车</button>
        <button class="btn-buy-now" @click="buyNow">立即购买</button>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { productService, Product } from '@/services/productService'
import { stationService } from '@/services/stationService'
import type { ProductTicket } from '@/types/ticket'
import { useCartStore } from '@/stores/cart'
import { useAuthStore } from '@/stores/auth'

interface CartItemData {
  stationId: string
  stationName: string
  productId: string
  productName: string
  price: number
  quantity: number
  image: string
}

const productId = ref('')
const stationId = ref('')
const product = ref<Product | null>(null)
const tickets = ref<ProductTicket[]>([])
const selectedTicket = ref<ProductTicket | null>(null)
const isFavorite = ref(false)
const quantity = ref(1)

const cartStore = useCartStore()
const authStore = useAuthStore()
const cartCount = computed(() => cartStore.totalCount)

const productImages = computed(() => {
  if (product.value?.image) {
    return [product.value.image]
  }
  return ['/static/images/default-product.png']
})

const discountText = computed(() => {
  if (!product.value?.originalPrice || !product.value?.price) return ''
  const ratio = product.value.price / product.value.originalPrice
  return `${(ratio * 10).toFixed(1)}折`
})

const loadProductDetail = async () => {
  try {
    const result = await productService.getProductDetail(productId.value)
    if (result) {
      product.value = result
    }
  } catch (error) {
    console.error('获取商品详情失败:', error)
  }
}

const selectTicket = (ticket: ProductTicket) => {
  if (selectedTicket.value?.id === ticket.id) {
    selectedTicket.value = null
  } else {
    selectedTicket.value = ticket
  }
}

const toggleFavorite = async () => {
  if (!authStore.isLoggedIn) {
    uni.navigateTo({ url: '/pages-auth/login' })
    return
  }

  try {
    if (isFavorite.value) {
      await stationService.removeFavorite(stationId.value)
      isFavorite.value = false
      uni.showToast({ title: '已取消收藏', icon: 'success' })
    } else {
      await stationService.addFavorite(stationId.value)
      isFavorite.value = true
      uni.showToast({ title: '收藏成功', icon: 'success' })
    }
  } catch (error) {
    uni.showToast({ title: '操作失败', icon: 'none' })
  }
}

const addToCart = () => {
  if (!authStore.isLoggedIn) {
    uni.navigateTo({ url: '/pages-auth/login' })
    return
  }

  if (!product.value) return

  const cartItem: CartItemData = {
    stationId: stationId.value,
    stationName: product.value.name,
    productId: product.value.id,
    productName: product.value.name,
    price: selectedTicket.value ? selectedTicket.value.price : product.value.price,
    quantity: quantity.value,
    image: product.value.image || ''
  }

  cartStore.addToCart(cartItem as any)
  uni.showToast({ title: '已加入购物车', icon: 'success' })
}

const buyNow = () => {
  if (!authStore.isLoggedIn) {
    uni.navigateTo({ url: '/pages-auth/login' })
    return
  }

  addToCart()
  setTimeout(() => {
    uni.switchTab({ url: '/pages/cart/index' })
  }, 500)
}

const goToCart = () => {
  uni.switchTab({ url: '/pages/cart/index' })
}

const previewImage = (index: number) => {
  uni.previewImage({
    urls: productImages.value,
    current: index
  })
}

onMounted(() => {
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1] as any
  const options = currentPage?.options || {}

  productId.value = options.id || ''
  stationId.value = options.stationId || ''

  if (productId.value) {
    loadProductDetail()
  }

  if (stationId.value && authStore.isLoggedIn) {
    stationService.checkFavorite(stationId.value).then(res => {
      isFavorite.value = res || false
    })
  }
})
</script>

<style lang="scss" scoped>
.product-detail-page {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background-color: $bg-color;
  padding-bottom: 120rpx;
}

.content {
  flex: 1;
}

.image-section {
  width: 100%;
  height: 600rpx;
  background-color: #fff;
}

.product-swiper {
  width: 100%;
  height: 100%;
}

.product-image {
  width: 100%;
  height: 100%;

  &.single {
    object-fit: cover;
  }
}

.info-section {
  background-color: #fff;
  padding: 24rpx;
  margin-bottom: 16rpx;
}

.price-row {
  display: flex;
  align-items: baseline;
  margin-bottom: 16rpx;

  .current-price {
    font-size: 56rpx;
    font-weight: 700;
    color: $error-color;
    margin-right: 16rpx;
  }

  .original-price {
    font-size: 28rpx;
    color: $text-tertiary;
    text-decoration: line-through;
  }

  .discount-tag {
    margin-left: 16rpx;
    padding: 4rpx 12rpx;
    background-color: rgba($error-color, 0.1);
    color: $error-color;
    font-size: 22rpx;
    border-radius: $radius-sm;
  }
}

.product-name {
  font-size: 32rpx;
  font-weight: 600;
  color: $text-primary;
  line-height: 1.5;
  margin-bottom: 16rpx;
}

.product-specs,
.stock-row {
  display: flex;
  align-items: center;
  font-size: 26rpx;
  color: $text-secondary;
  margin-bottom: 8rpx;

  .spec-label,
  .stock-label {
    margin-right: 8rpx;
  }

  .low-stock {
    color: $warning-color;
  }
}

.tickets-section {
  background-color: #fff;
  padding: 24rpx;
  margin-bottom: 16rpx;
}

.section-header {
  display: flex;
  align-items: baseline;
  margin-bottom: 20rpx;

  .section-title {
    font-size: 32rpx;
    font-weight: 600;
    color: $text-primary;
    margin-right: 12rpx;
  }

  .section-sub {
    font-size: 24rpx;
    color: $primary-color;
  }
}

.ticket-list {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}

.ticket-card {
  position: relative;
  display: flex;
  align-items: center;
  padding: 20rpx;
  background-color: #f8f8f8;
  border-radius: $radius-lg;
  border: 2rpx solid transparent;

  &.selected {
    background-color: rgba($primary-color, 0.05);
    border-color: $primary-color;
  }
}

.ticket-main {
  flex: 1;

  .ticket-name {
    display: block;
    font-size: 28rpx;
    font-weight: 600;
    color: $text-primary;
    margin-bottom: 4rpx;
  }

  .ticket-bucket {
    font-size: 24rpx;
    color: $text-secondary;
  }
}

.ticket-price {
  margin-right: 20rpx;
  text-align: right;

  .price {
    display: block;
    font-size: 32rpx;
    font-weight: 700;
    color: $error-color;
  }

  .original {
    display: block;
    font-size: 22rpx;
    color: $text-tertiary;
    text-decoration: line-through;
  }
}

.ticket-discount {
  .discount {
    padding: 4rpx 12rpx;
    background-color: $error-color;
    color: #fff;
    font-size: 22rpx;
    border-radius: $radius-sm;
  }
}

.ticket-select {
  position: absolute;
  right: 16rpx;
  bottom: 16rpx;
  width: 40rpx;
  height: 40rpx;
  background-color: $primary-color;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 24rpx;
}

.desc-section {
  background-color: #fff;
  padding: 24rpx;
}

.description {
  font-size: 28rpx;
  color: $text-secondary;
  line-height: 1.8;
  white-space: pre-wrap;
}

.action-bar {
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

.action-icons {
  display: flex;
  gap: 32rpx;
}

.action-icon-item {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;

  .icon {
    font-size: 40rpx;
    margin-bottom: 4rpx;
  }

  .label {
    font-size: 20rpx;
    color: $text-secondary;
  }

  .badge {
    position: absolute;
    top: -8rpx;
    right: -16rpx;
    min-width: 32rpx;
    height: 32rpx;
    padding: 0 8rpx;
    background-color: $error-color;
    color: #fff;
    font-size: 20rpx;
    border-radius: 16rpx;
    display: flex;
    align-items: center;
    justify-content: center;
  }
}

.action-buttons {
  flex: 1;
  display: flex;
  margin-left: 24rpx;
  gap: 16rpx;
}

.btn-add-cart,
.btn-buy-now {
  flex: 1;
  height: 80rpx;
  border-radius: 40rpx;
  font-size: 30rpx;
  font-weight: 600;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
}

.btn-add-cart {
  background-color: rgba($primary-color, 0.1);
  color: $primary-color;
}

.btn-buy-now {
  background-color: $primary-color;
  color: #fff;
}
</style>
