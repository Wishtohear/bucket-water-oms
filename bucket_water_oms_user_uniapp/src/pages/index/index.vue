<template>
  <view class="page">
    <view class="search-bar" @click="goToSearch">
      <view class="search-input">
        <text class="iconfont icon-search">🔍</text>
        <text class="placeholder">搜索水站、商品</text>
      </view>
    </view>

    <view class="location-bar" @click="chooseLocation">
      <text class="iconfont icon-location">📍</text>
      <text class="location-text">{{ locationName }}</text>
      <text class="iconfont icon-arrow">▼</text>
    </view>

    <scroll-view
      class="station-list"
      scroll-y
      refresher-enabled
      :refresher-triggered="isRefreshing"
      @refresherrefresh="onRefresh"
      @scrolltolower="loadMore"
    >
      <view class="list-loading" v-if="loading && stations.length === 0">
        <text>加载中...</text>
      </view>

      <view class="station-card" v-for="station in stations" :key="station.id" @click="goToStation(station.id)">
        <view class="station-header">
          <image class="station-logo" :src="station.logo || '/static/images/default-logo.png'" mode="aspectFill"></image>
          <view class="station-info">
            <view class="station-name">{{ station.name }}</view>
            <view class="station-meta">
              <text class="rating">⭐ {{ station.rating.toFixed(1) }}</text>
              <text class="sales">月销{{ station.salesCount || 0 }}</text>
              <text class="distance" v-if="station.distance">{{ formatDistance(station.distance) }}</text>
            </view>
          </view>
        </view>

        <view class="station-address">
          <text class="iconfont">📍</text>
          <text class="address-text">{{ station.address }}</text>
        </view>

        <view class="station-tags">
          <text class="tag" :class="station.isOpen ? 'tag-open' : 'tag-closed'">
            {{ station.isOpen ? '营业中' : '休息中' }}
          </text>
          <text class="tag" v-if="station.distance && station.deliveryRange">
            配送范围{{ station.deliveryRange }}km
          </text>
        </view>
      </view>

      <view class="no-more" v-if="noMore">
        <text>没有更多了</text>
      </view>

      <view class="empty-state" v-if="!loading && stations.length === 0">
        <text class="empty-icon">🏪</text>
        <text class="empty-text">附近没有水站</text>
      </view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { stationService, Station } from '@/services/stationService'
import { getCurrentLocation, formatDistance } from '@/utils/location'

const locationName = ref('获取定位中...')
const location = ref<{ latitude: number; longitude: number } | null>(null)
const stations = ref<Station[]>([])
const loading = ref(false)
const isRefreshing = ref(false)
const page = ref(1)
const pageSize = 10
const noMore = ref(false)

const loadStations = async (reset = false) => {
  if (loading.value) return

  if (reset) {
    page.value = 1
    noMore.value = false
  }

  loading.value = true

  try {
    const result = await stationService.getNearbyStations({
      latitude: location.value?.latitude,
      longitude: location.value?.longitude,
      sortBy: 'distance',
      page: page.value,
      pageSize
    })

    if (result) {
      if (reset) {
        stations.value = result.list
      } else {
        stations.value = [...stations.value, ...result.list]
      }

      if (result.list.length < pageSize) {
        noMore.value = true
      }
    }
  } catch (error) {
    console.error('加载水站失败:', error)
  } finally {
    loading.value = false
    isRefreshing.value = false
  }
}

const onRefresh = async () => {
  isRefreshing.value = true
  await loadStations(true)
}

const loadMore = async () => {
  if (noMore.value || loading.value) return
  page.value++
  await loadStations()
}

const initLocation = async () => {
  try {
    const res = await getCurrentLocation()
    location.value = {
      latitude: res.latitude,
      longitude: res.longitude
    }
    locationName.value = '定位成功'

    await loadStations(true)
  } catch (error) {
    console.error('获取定位失败:', error)
    locationName.value = '定位失败，点击重试'
    await loadStations(true)
  }
}

const chooseLocation = () => {
  uni.chooseLocation({
    success: (res) => {
      if (res.name) {
        locationName.value = res.name
        location.value = {
          latitude: res.latitude,
          longitude: res.longitude
        }
        loadStations(true)
      }
    }
  })
}

const goToSearch = () => {
  uni.navigateTo({
    url: '/pages-station/search'
  })
}

const goToStation = (stationId: string) => {
  uni.navigateTo({
    url: `/pages-station/detail?id=${stationId}`
  })
}

onMounted(() => {
  initLocation()
})
</script>

<style lang="scss" scoped>
.page {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background-color: $bg-color;
}

.search-bar {
  padding: 20rpx 32rpx;
  background-color: #fff;
}

.search-input {
  display: flex;
  align-items: center;
  height: 72rpx;
  padding: 0 24rpx;
  background-color: #f5f5f5;
  border-radius: 36rpx;

  .icon-search {
    font-size: 28rpx;
    color: $text-tertiary;
    margin-right: 12rpx;
  }

  .placeholder {
    font-size: 28rpx;
    color: $text-tertiary;
  }
}

.location-bar {
  display: flex;
  align-items: center;
  padding: 16rpx 32rpx;
  background-color: #fff;
  border-bottom: 1rpx solid $border-color;

  .icon-location {
    font-size: 28rpx;
    color: $primary-color;
    margin-right: 8rpx;
  }

  .location-text {
    flex: 1;
    font-size: 28rpx;
    color: $text-primary;
  }

  .icon-arrow {
    font-size: 20rpx;
    color: $text-tertiary;
  }
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

  .sales {
    margin-right: 16rpx;
  }

  .distance {
    color: $primary-color;
  }
}

.station-address {
  display: flex;
  align-items: flex-start;
  margin-bottom: 12rpx;

  .iconfont {
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
  }

  .tag-open {
    background-color: rgba($success-color, 0.1);
    color: $success-color;
  }

  .tag-closed {
    background-color: rgba($text-tertiary, 0.1);
    color: $text-tertiary;
  }
}

.list-loading,
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
}
</style>
