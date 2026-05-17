<template>
  <view class="station-detail-page">
    <view class="header-section">
      <image class="station-cover" :src="station?.logo || '/static/images/default-station.png'" mode="aspectFill"></image>
      <view class="station-mask">
        <view class="back-btn" @click="goBack">
          <text>←</text>
        </view>
        <view class="station-basic">
          <text class="station-name">{{ station?.name || '加载中...' }}</text>
          <view class="station-rating">
            <text class="rating-star">⭐</text>
            <text class="rating-value">{{ station?.rating?.toFixed(1) || '0.0' }}</text>
            <text class="rating-count">月销{{ station?.salesCount || 0 }}单</text>
          </view>
        </view>
      </view>
    </view>

    <view class="info-section" v-if="station">
      <view class="info-row" @click="openMap">
        <text class="info-icon">📍</text>
        <text class="info-text">{{ station.address }}</text>
        <text class="info-arrow">></text>
      </view>
      <view class="info-row" @click="callPhone">
        <text class="info-icon">📞</text>
        <text class="info-text">{{ station.phone }}</text>
        <text class="info-arrow">></text>
      </view>
      <view class="info-row">
        <text class="info-icon">⏰</text>
        <text class="info-text">营业时间: {{ station.businessHours || '全天营业' }}</text>
      </view>
      <view class="info-row" v-if="station.distance">
        <text class="info-icon">🚗</text>
        <text class="info-text">
          距离您 {{ formatDistance(station.distance) }}
          <text class="delivery-hint" :class="station.canDelivery ? 'in-range' : 'out-range'">
            ({{ station.canDelivery ? '在配送范围内' : '超出配送范围' }})
          </text>
        </text>
      </view>
    </view>

    <view class="category-section" v-if="categories.length > 0">
      <view class="category-tabs">
        <text
          class="category-tab"
          :class="{ active: selectedCategory === '' }"
          @click="selectCategory('')"
        >全部</text>
        <text
          class="category-tab"
          :class="{ active: selectedCategory === cat }"
          v-for="cat in categories"
          :key="cat"
          @click="selectCategory(cat)"
        >{{ cat }}</text>
      </view>
    </view>

    <scroll-view class="product-list" scroll-y>
      <view class="product-card" v-for="product in filteredProducts" :key="product.id" @click="goToProduct(product)">
        <image class="product-image" :src="product.image || '/static/images/default-product.png'" mode="aspectFill"></image>
        <view class="product-info">
          <text class="product-name">{{ product.name }}</text>
          <text class="product-spec" v-if="product.specifications">{{ product.specifications }}</text>
          <view class="product-tags">
            <text class="product-tag hot" v-if="product.isHot">热销</text>
            <text class="product-tag new" v-if="product.isNew">新品</text>
          </view>
          <view class="product-bottom">
            <view class="price-wrap">
              <text class="price">¥{{ product.price.toFixed(2) }}</text>
              <text class="original-price" v-if="product.originalPrice">¥{{ product.originalPrice.toFixed(2) }}</text>
            </view>
            <view class="stock-wrap">
              <text class="stock" :class="{ 'low-stock': product.stock < 10 }">
                {{ product.stock > 0 ? `库存${product.stock}` : '缺货' }}
              </text>
            </view>
          </view>
        </view>
        <view class="add-btn" @click.stop="addToCart(product)">
          <text>+</text>
        </view>
      </view>

      <view class="empty-products" v-if="filteredProducts.length === 0">
        <text>暂无商品</text>
      </view>
    </scroll-view>

    <view class="action-bar" v-if="station">
      <view class="action-favorite" @click="toggleFavorite">
        <text class="action-icon">{{ isFavorite ? '❤️' : '🤍' }}</text>
        <text class="action-text">收藏</text>
      </view>
      <view class="action-cart" @click="goToCart">
        <text class="action-icon">🛒</text>
        <text class="action-text">购物车</text>
        <view class="cart-badge" v-if="cartCount > 0">{{ cartCount > 99 ? '99+' : cartCount }}</view>
      </view>
      <button class="action-order" @click="goToCreateOrder">立即下单</button>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { stationService, StationDetail, Product } from '@/services/stationService'
import { useCartStore } from '@/stores/cart'
import { formatDistance } from '@/utils/location'

const stationId = ref('')
const station = ref<StationDetail | null>(null)
const products = ref<Product[]>([])
const categories = ref<string[]>([])
const selectedCategory = ref('')
const isFavorite = ref(false)
const loading = ref(true)

const cartStore = useCartStore()
const cartCount = computed(() => cartStore.totalCount)

const filteredProducts = computed(() => {
  if (!selectedCategory.value) {
    return products.value
  }
  return products.value.filter(p => p.category === selectedCategory.value)
})

const loadStationDetail = async () => {
  loading.value = true

  try {
    const result = await stationService.getStationDetail(stationId.value)
    if (result) {
      station.value = result
      products.value = result.products || []

      const cats = [...new Set(products.value.map(p => p.category).filter(Boolean))]
      categories.value = cats

      const favResult = await stationService.checkFavorite(stationId.value)
      isFavorite.value = favResult || false
    }
  } catch (error) {
    console.error('获取水站详情失败:', error)
  } finally {
    loading.value = false
  }
}

const selectCategory = (category: string) => {
  selectedCategory.value = category
}

const toggleFavorite = async () => {
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

const addToCart = (product: Product) => {
  if (!station.value) return

  cartStore.addToCart({
    stationId: station.value.id,
    stationName: station.value.name,
    productId: product.id,
    productName: product.name,
    price: product.price,
    quantity: 1,
    image: product.image
  })

  uni.showToast({ title: '已加入购物车', icon: 'success' })
}

const goToProduct = (product: Product) => {
  uni.navigateTo({
    url: `/pages-product/detail?id=${product.id}&stationId=${stationId.value}`
  })
}

const goToCart = () => {
  uni.switchTab({ url: '/pages/cart/index' })
}

const goToCreateOrder = () => {
  uni.showToast({ title: '请先添加商品到购物车', icon: 'none' })
}

const openMap = () => {
  if (!station.value) return
  uni.openLocation({
    latitude: station.value.latitude,
    longitude: station.value.longitude,
    name: station.value.name,
    address: station.value.address
  })
}

const callPhone = () => {
  if (!station.value?.phone) return
  uni.makePhoneCall({
    phoneNumber: station.value.phone
  })
}

const goBack = () => {
  uni.navigateBack()
}

onMounted(() => {
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1] as any
  const options = currentPage?.options || {}
  stationId.value = options.id || ''

  if (stationId.value) {
    loadStationDetail()
  }
})
</script>

<style lang="scss" scoped>
.station-detail-page {
  min-height: 100vh;
  background-color: $bg-color;
  padding-bottom: 120rpx;
}

.header-section {
  position: relative;
  height: 400rpx;
}

.station-cover {
  width: 100%;
  height: 100%;
  background-color: #f5f5f5;
}

.station-mask {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(to bottom, rgba(0,0,0,0.4) 0%, rgba(0,0,0,0) 50%);
  padding: 60rpx 24rpx 24rpx;
}

.back-btn {
  width: 64rpx;
  height: 64rpx;
  background-color: rgba(0,0,0,0.3);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32rpx;
  color: #fff;
}

.station-basic {
  position: absolute;
  bottom: 24rpx;
  left: 24rpx;
  right: 24rpx;

  .station-name {
    font-size: 40rpx;
    font-weight: 700;
    color: #fff;
    text-shadow: 0 2rpx 4rpx rgba(0,0,0,0.3);
    margin-bottom: 12rpx;
  }

  .station-rating {
    display: flex;
    align-items: center;
    gap: 8rpx;

    .rating-star {
      font-size: 24rpx;
    }

    .rating-value {
      font-size: 28rpx;
      color: #ff9800;
      font-weight: 600;
    }

    .rating-count {
      font-size: 24rpx;
      color: rgba(255,255,255,0.8);
    }
  }
}

.info-section {
  background-color: #fff;
  margin-bottom: 16rpx;
}

.info-row {
  display: flex;
  align-items: center;
  padding: 24rpx;
  border-bottom: 1rpx solid $border-color;

  &:last-child {
    border-bottom: none;
  }

  .info-icon {
    font-size: 28rpx;
    margin-right: 16rpx;
  }

  .info-text {
    flex: 1;
    font-size: 28rpx;
    color: $text-primary;
  }

  .info-arrow {
    font-size: 24rpx;
    color: $text-tertiary;
  }

  .delivery-hint {
    font-size: 24rpx;
    margin-left: 12rpx;

    &.in-range {
      color: $success-color;
    }

    &.out-range {
      color: $error-color;
    }
  }
}

.category-section {
  background-color: #fff;
  padding: 0 24rpx 16rpx;
  margin-bottom: 16rpx;
}

.category-tabs {
  display: flex;
  gap: 24rpx;
  overflow-x: auto;
}

.category-tab {
  padding: 16rpx 0;
  font-size: 28rpx;
  color: $text-secondary;
  white-space: nowrap;

  &.active {
    color: $primary-color;
    font-weight: 600;
    border-bottom: 4rpx solid $primary-color;
  }
}

.product-list {
  padding: 0 24rpx;
  height: calc(100vh - 800rpx);
}

.product-card {
  display: flex;
  background-color: #fff;
  border-radius: $radius-lg;
  padding: 20rpx;
  margin-bottom: 16rpx;
}

.product-image {
  width: 160rpx;
  height: 160rpx;
  border-radius: $radius-md;
  margin-right: 20rpx;
  background-color: #f5f5f5;
}

.product-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.product-name {
  font-size: 30rpx;
  font-weight: 600;
  color: $text-primary;
  margin-bottom: 8rpx;
}

.product-spec {
  font-size: 24rpx;
  color: $text-tertiary;
  margin-bottom: 8rpx;
}

.product-tags {
  display: flex;
  gap: 8rpx;
  margin-bottom: 8rpx;
}

.product-tag {
  padding: 4rpx 12rpx;
  border-radius: $radius-sm;
  font-size: 20rpx;

  &.hot {
    background-color: rgba($error-color, 0.1);
    color: $error-color;
  }

  &.new {
    background-color: rgba($purple-color, 0.1);
    color: $purple-color;
  }
}

.product-bottom {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.price-wrap {
  display: flex;
  align-items: baseline;
  gap: 8rpx;

  .price {
    font-size: 36rpx;
    font-weight: 700;
    color: $error-color;
  }

  .original-price {
    font-size: 24rpx;
    color: $text-tertiary;
    text-decoration: line-through;
  }
}

.stock-wrap {
  .stock {
    font-size: 24rpx;
    color: $text-secondary;

    &.low-stock {
      color: $warning-color;
    }
  }
}

.add-btn {
  width: 56rpx;
  height: 56rpx;
  background-color: $primary-color;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 36rpx;
  color: #fff;
  align-self: flex-end;
}

.empty-products {
  text-align: center;
  padding: 100rpx 0;
  color: $text-tertiary;
  font-size: 28rpx;
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

.action-favorite,
.action-cart {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 0 32rpx;

  .action-icon {
    font-size: 40rpx;
    margin-bottom: 4rpx;
  }

  .action-text {
    font-size: 20rpx;
    color: $text-secondary;
  }

  .cart-badge {
    position: absolute;
    top: -8rpx;
    right: 16rpx;
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

.action-order {
  flex: 1;
  height: 80rpx;
  margin-left: 24rpx;
  background-color: $primary-color;
  color: #fff;
  font-size: 32rpx;
  font-weight: 600;
  border-radius: 40rpx;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
