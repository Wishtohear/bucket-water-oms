<template>
  <view class="favorites-page">
    <scroll-view
      class="station-list"
      scroll-y
      refresher-enabled
      :refresher-triggered="isRefreshing"
      @refresherrefresh="onRefresh"
    >
      <view class="loading-state" v-if="loading">
        <text>加载中...</text>
      </view>

      <view class="station-card" v-for="station in favorites" :key="station.id" @click="goToStation(station.id)">
        <view class="station-header">
          <image class="station-logo" :src="station.logo || '/static/images/default-logo.png'" mode="aspectFill"></image>
          <view class="station-info">
            <view class="station-name">{{ station.name }}</view>
            <view class="station-meta">
              <text class="rating">⭐ {{ station.rating.toFixed(1) }}</text>
              <text class="distance" v-if="station.distance">{{ formatDistance(station.distance) }}</text>
            </view>
          </view>
          <view class="remove-btn" @click.stop="removeFavorite(station.id)">
            <text>×</text>
          </view>
        </view>

        <view class="station-address">
          <text class="icon">📍</text>
          <text class="address-text">{{ station.address }}</text>
        </view>

        <view class="station-tags">
          <text class="tag" :class="station.isOpen ? 'tag-open' : 'tag-closed'">
            {{ station.isOpen ? '营业中' : '休息中' }}
          </text>
        </view>
      </view>

      <view class="no-more" v-if="!loading && favorites.length > 0">
        <text>没有更多了</text>
      </view>

      <view class="empty-state" v-if="!loading && favorites.length === 0">
        <text class="empty-icon">❤️</text>
        <text class="empty-text">暂无收藏的水站</text>
        <button class="btn btn-primary" @click="goHome">去逛逛</button>
      </view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { stationService, Station } from '@/services/stationService'
import { formatDistance } from '@/utils/location'

const favorites = ref<Station[]>([])
const loading = ref(false)
const isRefreshing = ref(false)

const loadFavorites = async () => {
  loading.value = true

  try {
    const result = await stationService.getFavoriteStations()
    if (result) {
      favorites.value = result
    }
  } catch (error) {
    console.error('获取收藏列表失败:', error)
  } finally {
    loading.value = false
    isRefreshing.value = false
  }
}

const onRefresh = async () => {
  isRefreshing.value = true
  await loadFavorites()
}

const removeFavorite = async (stationId: string) => {
  uni.showModal({
    title: '提示',
    content: '确定要取消收藏该水站吗？',
    success: async (res) => {
      if (res.confirm) {
        try {
          await stationService.removeFavorite(stationId)
          favorites.value = favorites.value.filter(s => s.id !== stationId)
          uni.showToast({ title: '已取消收藏', icon: 'success' })
        } catch (error) {
          uni.showToast({ title: '操作失败', icon: 'none' })
        }
      }
    }
  })
}

const goToStation = (stationId: string) => {
  uni.navigateTo({
    url: `/pages-station/detail?id=${stationId}`
  })
}

const goHome = () => {
  uni.switchTab({ url: '/pages/index/index' })
}

onMounted(() => {
  loadFavorites()
})
</script>

<style lang="scss" scoped>
.favorites-page {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background-color: $bg-color;
}

.station-list {
  flex: 1;
  padding: 24rpx;
}

.station-card {
  background-color: #fff;
  border-radius: $radius-lg;
  padding: 24rpx;
  margin-bottom: 24rpx;
  box-shadow: $shadow-sm;
}

.station-header {
  display: flex;
  margin-bottom: 16rpx;
}

.station-logo {
  width: 100rpx;
  height: 100rpx;
  border-radius: $radius-md;
  margin-right: 20rpx;
  background-color: #f5f5f5;
}

.station-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.station-name {
  font-size: 32rpx;
  font-weight: 600;
  color: $text-primary;
  margin-bottom: 8rpx;
}

.station-meta {
  display: flex;
  align-items: center;
  font-size: 24rpx;
  color: $text-secondary;

  .rating {
    margin-right: 16rpx;
    color: #ff9800;
  }

  .distance {
    color: $primary-color;
  }
}

.remove-btn {
  width: 48rpx;
  height: 48rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 40rpx;
  color: $text-tertiary;
}

.station-address {
  display: flex;
  align-items: flex-start;
  margin-bottom: 12rpx;

  .icon {
    font-size: 24rpx;
    color: $text-tertiary;
    margin-right: 8rpx;
  }

  .address-text {
    flex: 1;
    font-size: 26rpx;
    color: $text-secondary;
  }
}

.station-tags {
  display: flex;
  gap: 12rpx;

  .tag {
    padding: 4rpx 16rpx;
    border-radius: $radius-sm;
    font-size: 22rpx;
    background-color: #f5f5f5;
    color: $text-secondary;

    &.tag-open {
      background-color: rgba($success-color, 0.1);
      color: $success-color;
    }

    &.tag-closed {
      background-color: rgba($text-tertiary, 0.1);
      color: $text-tertiary;
    }
  }
}

.loading-state,
.no-more,
.empty-state {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 40rpx 0;
  color: $text-tertiary;
  font-size: 28rpx;
}

.empty-state {
  flex-direction: column;

  .empty-icon {
    font-size: 120rpx;
    margin-bottom: 24rpx;
  }

  .empty-text {
    margin-bottom: 32rpx;
  }
}
</style>
