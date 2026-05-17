<template>
  <view class="search-page">
    <view class="search-header">
      <view class="search-input-wrap">
        <text class="search-icon">🔍</text>
        <input
          class="search-input"
          v-model="keyword"
          placeholder="搜索水站名称或地址"
          confirm-type="search"
          @confirm="handleSearch"
          @input="onInput"
          focus
        />
        <text class="clear-icon" v-if="keyword" @click="clearKeyword">✕</text>
      </view>
      <text class="cancel-btn" @click="goBack">取消</text>
    </view>

    <view class="search-content">
      <view class="hot-search" v-if="!keyword && !searching">
        <view class="section-header">
          <text class="section-title">热门搜索</text>
        </view>
        <view class="hot-tags">
          <text class="hot-tag" v-for="tag in hotTags" :key="tag" @click="searchTag(tag)">{{ tag }}</text>
        </view>
      </view>

      <view class="search-history" v-if="!keyword && history.length > 0">
        <view class="section-header">
          <text class="section-title">搜索历史</text>
          <text class="clear-history" @click="clearHistory">清除</text>
        </view>
        <view class="history-tags">
          <text class="history-tag" v-for="item in history" :key="item" @click="searchTag(item)">{{ item }}</text>
        </view>
      </view>

      <view class="search-result" v-if="searching">
        <view class="loading-state" v-if="loading">
          <text>搜索中...</text>
        </view>
        <view class="result-list" v-else>
          <view class="result-item" v-for="station in results" :key="station.id" @click="goToStation(station)">
            <view class="item-main">
              <text class="item-name">{{ station.name }}</text>
              <text class="item-distance" v-if="station.distance">{{ formatDistance(station.distance) }}</text>
            </view>
            <view class="item-sub">
              <text class="item-address">{{ station.address }}</text>
            </view>
            <view class="item-meta">
              <text class="rating">⭐ {{ station.rating.toFixed(1) }}</text>
              <text class="tag" :class="station.isOpen ? 'tag-open' : 'tag-closed'">
                {{ station.isOpen ? '营业中' : '休息中' }}
              </text>
            </view>
          </view>
          <view class="no-result" v-if="results.length === 0">
            <text>未找到相关水站</text>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { stationService, Station } from '@/services/stationService'
import { storage } from '@/utils/storage'
import { formatDistance } from '@/utils/location'

const keyword = ref('')
const searching = ref(false)
const loading = ref(false)
const results = ref<Station[]>([])
const history = ref<string[]>([])
let searchTimer: ReturnType<typeof setTimeout> | null = null

const hotTags = ['桶装水', '矿泉水', '纯净水', '饮水机']

const loadHistory = () => {
  const saved = storage.get<string[]>('searchHistory')
  if (saved) {
    history.value = saved
  }
}

const saveHistory = (word: string) => {
  if (!word) return

  const filtered = history.value.filter(h => h !== word)
  history.value = [word, ...filtered].slice(0, 10)
  storage.set('searchHistory', history.value)
}

const clearHistory = () => {
  history.value = []
  storage.remove('searchHistory')
}

const clearKeyword = () => {
  keyword.value = ''
  results.value = []
  searching.value = false
}

const onInput = () => {
  if (searchTimer) {
    clearTimeout(searchTimer)
  }

  if (!keyword.value) {
    searching.value = false
    results.value = []
    return
  }

  searchTimer = setTimeout(() => {
    handleSearch()
  }, 300)
}

const handleSearch = async () => {
  if (!keyword.value.trim()) return

  searching.value = true
  loading.value = true
  saveHistory(keyword.value)

  try {
    results.value = await stationService.searchStations({
      keyword: keyword.value.trim(),
      page: 1,
      pageSize: 50
    })
  } catch (error) {
    console.error('搜索失败:', error)
  } finally {
    loading.value = false
  }
}

const searchTag = (tag: string) => {
  keyword.value = tag
  handleSearch()
}

const goToStation = (station: Station) => {
  uni.navigateTo({
    url: `/pages-station/detail?id=${station.id}`
  })
}

const goBack = () => {
  uni.navigateBack()
}

loadHistory()
</script>

<style lang="scss" scoped>
.search-page {
  min-height: 100vh;
  background-color: $bg-color;
}

.search-header {
  display: flex;
  align-items: center;
  padding: 16rpx 24rpx;
  background-color: #fff;
  border-bottom: 1rpx solid $border-color;
}

.search-input-wrap {
  flex: 1;
  display: flex;
  align-items: center;
  height: 72rpx;
  padding: 0 20rpx;
  background-color: #f5f5f5;
  border-radius: 36rpx;
}

.search-icon {
  font-size: 28rpx;
  margin-right: 12rpx;
}

.search-input {
  flex: 1;
  height: 100%;
  font-size: 28rpx;
}

.clear-icon {
  font-size: 28rpx;
  color: $text-tertiary;
  padding: 8rpx;
}

.cancel-btn {
  margin-left: 20rpx;
  font-size: 28rpx;
  color: $text-primary;
}

.search-content {
  padding: 24rpx;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20rpx;

  .section-title {
    font-size: 28rpx;
    font-weight: 600;
    color: $text-primary;
  }

  .clear-history {
    font-size: 24rpx;
    color: $primary-color;
  }
}

.hot-tags,
.history-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
}

.hot-tag,
.history-tag {
  padding: 12rpx 24rpx;
  background-color: #fff;
  border-radius: $radius-md;
  font-size: 26rpx;
  color: $text-secondary;
}

.hot-tag {
  background-color: rgba($primary-color, 0.1);
  color: $primary-color;
}

.loading-state {
  text-align: center;
  padding: 40rpx 0;
  color: $text-tertiary;
  font-size: 28rpx;
}

.result-list {
  .result-item {
    background-color: #fff;
    border-radius: $radius-lg;
    padding: 24rpx;
    margin-bottom: 16rpx;
  }

  .item-main {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 8rpx;

    .item-name {
      font-size: 30rpx;
      font-weight: 600;
      color: $text-primary;
    }

    .item-distance {
      font-size: 24rpx;
      color: $primary-color;
    }
  }

  .item-sub {
    margin-bottom: 8rpx;

    .item-address {
      font-size: 24rpx;
      color: $text-secondary;
    }
  }

  .item-meta {
    display: flex;
    align-items: center;
    gap: 16rpx;

    .rating {
      font-size: 24rpx;
      color: #ff9800;
    }

    .tag {
      padding: 4rpx 12rpx;
      border-radius: $radius-sm;
      font-size: 22rpx;
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
}

.no-result {
  text-align: center;
  padding: 80rpx 0;
  color: $text-tertiary;
  font-size: 28rpx;
}
</style>
