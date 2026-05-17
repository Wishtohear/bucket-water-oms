<template>
  <view class="evaluate-page">
    <view class="header-section">
      <text class="page-title">评价订单</text>
    </view>

    <scroll-view class="content" scroll-y>
      <view class="order-info-card">
        <view class="store-name">{{ stationName }}</view>
        <view class="product-list">
          <view class="product-item" v-for="item in orderItems" :key="item.id">
            <text class="product-name">{{ item.productName }}</text>
            <text class="product-qty">x{{ item.quantity }}</text>
          </view>
        </view>
      </view>

      <view class="rating-section">
        <text class="section-title">商品评分</text>
        <view class="rating-stars">
          <view 
            class="star-item" 
            v-for="index in 5" 
            :key="index"
            @click="setRating(index)">
            <text class="star-icon">{{ index <= rating ? '⭐' : '☆' }}</text>
          </view>
        </view>
        <text class="rating-text">{{ ratingText }}</text>
      </view>

      <view class="tags-section">
        <text class="section-title">选择标签</text>
        <view class="tags-list">
          <view 
            class="tag-item" 
            :class="{ selected: selectedTags.includes(tag) }"
            v-for="tag in availableTags" 
            :key="tag"
            @click="toggleTag(tag)">
            <text>{{ tag }}</text>
          </view>
        </view>
      </view>

      <view class="content-section">
        <text class="section-title">评价内容</text>
        <textarea 
          class="content-input"
          v-model="content"
          placeholder="分享您的购物体验（选填）"
          maxlength="200"
        />
        <text class="content-count">{{ content.length }}/200</text>
      </view>

      <view class="anonymous-section">
        <checkbox-group @change="onAnonymousChange">
          <label class="anonymous-label">
            <checkbox :checked="isAnonymous" color="#1890FF" />
            <text class="anonymous-text">匿名评价</text>
          </label>
        </checkbox-group>
      </view>
    </scroll-view>

    <view class="bottom-bar">
      <button class="submit-btn" :disabled="!canSubmit || submitting" @click="submitEvaluation">
        <text class="btn-text" v-if="!submitting">提交评价</text>
        <text class="btn-text" v-else>提交中...</text>
      </button>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { orderService } from '@/services/orderService'

const orderId = ref('')
const stationName = ref('')
const orderItems = ref<Array<{ id: string; productName: string; quantity: number }>>([])
const rating = ref(5)
const selectedTags = ref<string[]>([])
const content = ref('')
const isAnonymous = ref(false)
const submitting = ref(false)

const availableTags = [
  '配送快速',
  '服务态度好',
  '包装完好',
  '水质好',
  '性价比高',
  '准时送达',
  '包装一般',
  '有点延迟'
]

const ratingText = computed(() => {
  const texts = ['', '很差', '较差', '一般', '满意', '非常满意']
  return texts[rating.value] || ''
})

const canSubmit = computed(() => {
  return rating.value > 0
})

const setRating = (star: number) => {
  rating.value = star
}

const toggleTag = (tag: string) => {
  const index = selectedTags.value.indexOf(tag)
  if (index > -1) {
    selectedTags.value.splice(index, 1)
  } else {
    if (selectedTags.value.length < 5) {
      selectedTags.value.push(tag)
    }
  }
}

const onAnonymousChange = (e: any) => {
  isAnonymous.value = e.detail.value.length > 0
}

const submitEvaluation = async () => {
  if (!canSubmit.value || submitting.value) return
  
  submitting.value = true
  
  try {
    await orderService.evaluateOrder(orderId.value, {
      rating: rating.value,
      content: content.value || undefined,
      tags: selectedTags.value.length > 0 ? selectedTags.value : undefined
    })
    
    uni.showToast({ title: '评价成功', icon: 'success' })
    
    setTimeout(() => {
      uni.navigateBack()
    }, 1500)
  } catch (error) {
    console.error('提交评价失败:', error)
    uni.showToast({ title: '评价失败', icon: 'error' })
  } finally {
    submitting.value = false
  }
}

onMounted(() => {
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1] as any
  const options = currentPage?.options || {}
  
  orderId.value = options.id || ''
  stationName.value = options.stationName || ''
  
  if (options.items) {
    try {
      orderItems.value = JSON.parse(decodeURIComponent(options.items))
    } catch (e) {
      console.error('解析订单商品失败:', e)
    }
  }
})
</script>

<style lang="scss" scoped>
.evaluate-page {
  min-height: 100vh;
  background: $bg-color;
  padding-bottom: 140rpx;
}

.header-section {
  padding: 32rpx 24rpx;
  background: #fff;
  border-bottom: 1rpx solid $border-color;

  .page-title {
    font-size: 36rpx;
    font-weight: 700;
    color: $text-primary;
  }
}

.content {
  padding: 24rpx;
}

.order-info-card {
  background: #fff;
  border-radius: $radius-lg;
  padding: 24rpx;
  margin-bottom: 24rpx;

  .store-name {
    font-size: 30rpx;
    font-weight: 600;
    color: $text-primary;
    margin-bottom: 16rpx;
    padding-bottom: 16rpx;
    border-bottom: 1rpx solid $border-color;
  }

  .product-list {
    .product-item {
      display: flex;
      justify-content: space-between;
      padding: 8rpx 0;

      .product-name {
        font-size: 28rpx;
        color: $text-primary;
      }

      .product-qty {
        font-size: 26rpx;
        color: $text-secondary;
      }
    }
  }
}

.rating-section {
  background: #fff;
  border-radius: $radius-lg;
  padding: 32rpx 24rpx;
  margin-bottom: 24rpx;
  text-align: center;

  .section-title {
    display: block;
    font-size: 28rpx;
    font-weight: 600;
    color: $text-primary;
    margin-bottom: 24rpx;
  }

  .rating-stars {
    display: flex;
    justify-content: center;
    gap: 16rpx;
    margin-bottom: 16rpx;

    .star-item {
      .star-icon {
        font-size: 64rpx;
      }
    }
  }

  .rating-text {
    font-size: 28rpx;
    color: $warning-color;
  }
}

.tags-section {
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

  .tags-list {
    display: flex;
    flex-wrap: wrap;
    gap: 16rpx;

    .tag-item {
      padding: 12rpx 24rpx;
      background: $bg-color;
      border-radius: 32rpx;
      border: 2rpx solid transparent;
      transition: all 0.3s;

      text {
        font-size: 26rpx;
        color: $text-secondary;
      }

      &.selected {
        background: rgba($primary-color, 0.1);
        border-color: $primary-color;

        text {
          color: $primary-color;
        }
      }
    }
  }
}

.content-section {
  background: #fff;
  border-radius: $radius-lg;
  padding: 24rpx;
  margin-bottom: 24rpx;

  .section-title {
    display: block;
    font-size: 28rpx;
    font-weight: 600;
    color: $text-primary;
    margin-bottom: 16rpx;
  }

  .content-input {
    width: 100%;
    height: 200rpx;
    padding: 16rpx;
    background: $bg-color;
    border-radius: $radius-md;
    font-size: 28rpx;
    color: $text-primary;
    line-height: 1.6;
  }

  .content-count {
    display: block;
    text-align: right;
    font-size: 24rpx;
    color: $text-tertiary;
    margin-top: 12rpx;
  }
}

.anonymous-section {
  background: #fff;
  border-radius: $radius-lg;
  padding: 24rpx;

  .anonymous-label {
    display: flex;
    align-items: center;

    .anonymous-text {
      font-size: 28rpx;
      color: $text-secondary;
      margin-left: 12rpx;
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

  .submit-btn {
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
</style>
