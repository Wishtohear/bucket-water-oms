<template>
  <view class="select-address-page">
    <view class="header-bar">
      <text class="header-title">选择收货地址</text>
    </view>

    <scroll-view class="address-list" scroll-y>
      <view 
        class="address-card" 
        v-for="addr in addresses" 
        :key="addr.id"
        :class="{ selected: selectedId === addr.id }"
        @click="selectAddress(addr)"
      >
        <view class="card-main">
          <view class="radio-indicator">
            <view class="radio-outer">
              <view class="radio-inner" v-if="selectedId === addr.id"></view>
            </view>
          </view>
          
          <view class="address-info">
            <view class="contact-row">
              <text class="contact-name">{{ addr.contactName }}</text>
              <text class="contact-phone">{{ addr.contactPhone }}</text>
              <view class="default-tag" v-if="addr.isDefault">默认</view>
            </view>
            <text class="address-detail">{{ formatAddress(addr) }}</text>
          </view>
        </view>
      </view>

      <view class="empty-state" v-if="addresses.length === 0 && !loading">
        <text class="empty-icon">📍</text>
        <text class="empty-text">暂无收货地址</text>
        <button class="add-address-btn" @click="goAddAddress">添加地址</button>
      </view>
    </scroll-view>

    <view class="bottom-bar">
      <button class="add-btn" @click="goAddAddress">
        <text class="add-icon">+</text>
        <text>新增地址</text>
      </button>
      <button class="confirm-btn" :disabled="!selectedAddress" @click="confirmSelect">
        <text>确认选择</text>
      </button>
    </view>

    <view class="loading-overlay" v-if="loading">
      <text class="loading-text">加载中...</text>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { addressService } from '@/services/addressService'
import type { Address } from '@/types/order'

const addresses = ref<Address[]>([])
const selectedId = ref('')
const loading = ref(false)

const selectedAddress = computed(() => {
  return addresses.value.find(addr => addr.id === selectedId.value) || null
})

const formatAddress = (addr: Address) => {
  const parts = [addr.province, addr.city, addr.district, addr.detail].filter(Boolean)
  return parts.join('')
}

const loadAddresses = async () => {
  loading.value = true
  try {
    const result = await addressService.getAddressList()
    if (result) {
      addresses.value = result
      const defaultAddr = result.find(addr => addr.isDefault)
      if (defaultAddr) {
        selectedId.value = defaultAddr.id
      }
    }
  } catch (error) {
    console.error('加载地址列表失败:', error)
    uni.showToast({ title: '加载失败', icon: 'error' })
  } finally {
    loading.value = false
  }
}

const selectAddress = (addr: Address) => {
  selectedId.value = addr.id
}

const goAddAddress = () => {
  uni.navigateTo({
    url: '/pages-address/edit'
  })
}

const confirmSelect = () => {
  if (!selectedAddress.value) return
  
  const pages = getCurrentPages()
  const prevPage = pages[pages.length - 2]
  
  if (prevPage) {
    prevPage.setData?.({
      selectedAddress: selectedAddress.value
    })
  }
  
  uni.navigateBack()
}

onMounted(() => {
  loadAddresses()
})
</script>

<style lang="scss" scoped>
.select-address-page {
  min-height: 100vh;
  background: $bg-color;
}

.header-bar {
  padding: 24rpx;
  background: #fff;
  border-bottom: 1rpx solid $border-color;

  .header-title {
    font-size: 32rpx;
    font-weight: 600;
    color: $text-primary;
  }
}

.address-list {
  padding: 24rpx;
  padding-bottom: 200rpx;
}

.address-card {
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

  .card-main {
    display: flex;
    align-items: flex-start;

    .radio-indicator {
      margin-right: 20rpx;
      padding-top: 4rpx;

      .radio-outer {
        width: 40rpx;
        height: 40rpx;
        border-radius: 50%;
        border: 4rpx solid $border-color;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.3s;

        .address-card.selected & {
          border-color: $primary-color;
        }

        .radio-inner {
          width: 24rpx;
          height: 24rpx;
          border-radius: 50%;
          background: $primary-color;
        }
      }
    }

    .address-info {
      flex: 1;

      .contact-row {
        display: flex;
        align-items: center;
        gap: 12rpx;
        margin-bottom: 12rpx;

        .contact-name {
          font-size: 32rpx;
          font-weight: 600;
          color: $text-primary;
        }

        .contact-phone {
          font-size: 28rpx;
          color: $text-secondary;
        }

        .default-tag {
          font-size: 22rpx;
          color: #fff;
          background: $primary-color;
          padding: 4rpx 12rpx;
          border-radius: 12rpx;
        }
      }

      .address-detail {
        font-size: 26rpx;
        color: $text-secondary;
        line-height: 1.5;
      }
    }
  }
}

.empty-state {
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
    margin-bottom: 32rpx;
  }

  .add-address-btn {
    padding: 20rpx 48rpx;
    background: $primary-color;
    color: #fff;
    font-size: 28rpx;
    border-radius: 40rpx;
    border: none;
  }
}

.bottom-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  display: flex;
  gap: 24rpx;
  padding: 16rpx 24rpx;
  padding-bottom: calc(16rpx + env(safe-area-inset-bottom));
  background: #fff;
  box-shadow: 0 -2rpx 12rpx rgba(0, 0, 0, 0.06);

  .add-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8rpx;
    padding: 0 32rpx;
    height: 88rpx;
    background: $bg-color;
    color: $text-primary;
    font-size: 30rpx;
    border-radius: 44rpx;
    border: 2rpx solid $border-color;

    .add-icon {
      font-size: 32rpx;
      font-weight: 600;
    }
  }

  .confirm-btn {
    flex: 1;
    height: 88rpx;
    background: $primary-color;
    color: #fff;
    font-size: 30rpx;
    font-weight: 600;
    border-radius: 44rpx;
    border: none;
    display: flex;
    align-items: center;
    justify-content: center;

    &[disabled] {
      background: $text-tertiary;
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
