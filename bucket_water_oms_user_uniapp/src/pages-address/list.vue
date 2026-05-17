<template>
  <view class="address-page">
    <scroll-view class="address-list" scroll-y>
      <view class="loading-state" v-if="loading">
        <text>加载中...</text>
      </view>

      <view class="address-card" v-for="addr in addresses" :key="addr.id" @click="selectAddress(addr)">
        <view class="card-main">
          <view class="address-info">
            <view class="contact-row">
              <text class="contact-name">{{ addr.contactName }}</text>
              <text class="contact-phone">{{ addr.contactPhone }}</text>
              <view class="default-tag" v-if="addr.isDefault">默认</view>
            </view>
            <text class="address-detail">{{ formatAddress(addr) }}</text>
          </view>
        </view>

        <view class="card-actions">
          <view class="action-btn" @click.stop="setDefault(addr.id)" v-if="!addr.isDefault">
            <text>设为默认</text>
          </view>
          <view class="action-btn" @click.stop="editAddress(addr)">
            <text>编辑</text>
          </view>
          <view class="action-btn delete" @click.stop="deleteAddress(addr.id)">
            <text>删除</text>
          </view>
        </view>
      </view>

      <view class="empty-state" v-if="!loading && addresses.length === 0">
        <text class="empty-icon">📍</text>
        <text class="empty-text">暂无收货地址</text>
      </view>
    </scroll-view>

    <view class="bottom-bar">
      <button class="add-btn" @click="addAddress">
        <text class="add-icon">+</text>
        <text>新增地址</text>
      </button>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { addressService } from '@/services/addressService'
import { useAddressStore } from '@/stores/address'
import type { Address } from '@/types/order'

const addressStore = useAddressStore()

const addresses = ref<Address[]>([])
const loading = ref(false)
const isSelectMode = ref(false)

const loadAddresses = async () => {
  loading.value = true

  try {
    const result = await addressService.getAddressList()
    if (result) {
      addresses.value = result
    }
  } catch (error) {
    console.error('获取地址列表失败:', error)
  } finally {
    loading.value = false
  }
}

const formatAddress = (addr: Address) => {
  return `${addr.province || ''}${addr.city || ''}${addr.district || ''}${addr.detail || ''}`
}

const selectAddress = (addr: Address) => {
  if (isSelectMode.value) {
    const pages = getCurrentPages()
    const prevPage = pages[pages.length - 2] as any
    if (prevPage) {
      prevPage.setData?.({ selectedAddress: addr })
      prevPage.selectedAddress = addr
    }
    uni.navigateBack()
  }
}

const setDefault = async (id: string) => {
  try {
    await addressService.setDefaultAddress(id)
    await loadAddresses()
    uni.showToast({ title: '设置成功', icon: 'success' })
  } catch (error) {
    uni.showToast({ title: '设置失败', icon: 'none' })
  }
}

const editAddress = (addr: Address) => {
  uni.navigateTo({
    url: `/pages-address/edit?id=${addr.id}`
  })
}

const deleteAddress = (id: string) => {
  uni.showModal({
    title: '提示',
    content: '确定要删除该地址吗？',
    success: async (res) => {
      if (res.confirm) {
        try {
          await addressService.deleteAddress(id)
          await loadAddresses()
          uni.showToast({ title: '删除成功', icon: 'success' })
        } catch (error) {
          uni.showToast({ title: '删除失败', icon: 'none' })
        }
      }
    }
  })
}

const addAddress = () => {
  uni.navigateTo({
    url: '/pages-address/edit'
  })
}

onMounted(() => {
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1] as any
  const options = currentPage?.options || {}

  isSelectMode.value = options.select === 'true'

  if (isSelectMode.value) {
    uni.setNavigationBarTitle({ title: '选择地址' })
  }

  loadAddresses()
})
</script>

<style lang="scss" scoped>
.address-page {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background-color: $bg-color;
  padding-bottom: 140rpx;
}

.address-list {
  flex: 1;
  padding: 24rpx;
}

.address-card {
  background-color: #fff;
  border-radius: $radius-lg;
  padding: 24rpx;
  margin-bottom: 24rpx;
  box-shadow: $shadow-sm;
}

.card-main {
  margin-bottom: 20rpx;
}

.address-info {
  .contact-row {
    display: flex;
    align-items: center;
    margin-bottom: 12rpx;
  }

  .contact-name {
    font-size: 32rpx;
    font-weight: 600;
    color: $text-primary;
    margin-right: 16rpx;
  }

  .contact-phone {
    font-size: 28rpx;
    color: $text-secondary;
    margin-right: 16rpx;
  }

  .default-tag {
    padding: 4rpx 12rpx;
    background-color: rgba($primary-color, 0.1);
    color: $primary-color;
    font-size: 22rpx;
    border-radius: $radius-sm;
  }

  .address-detail {
    font-size: 26rpx;
    color: $text-secondary;
    line-height: 1.5;
  }
}

.card-actions {
  display: flex;
  justify-content: flex-end;
  gap: 24rpx;
  padding-top: 16rpx;
  border-top: 1rpx solid $border-color;
}

.action-btn {
  font-size: 26rpx;
  color: $text-secondary;

  &.delete {
    color: $error-color;
  }
}

.loading-state {
  text-align: center;
  padding: 100rpx 0;
  color: $text-tertiary;
  font-size: 28rpx;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 100rpx 0;

  .empty-icon {
    font-size: 120rpx;
    margin-bottom: 24rpx;
  }

  .empty-text {
    font-size: 28rpx;
    color: $text-secondary;
  }
}

.bottom-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 24rpx;
  padding-bottom: calc(24rpx + constant(safe-area-inset-bottom));
  padding-bottom: calc(24rpx + env(safe-area-inset-bottom));
  background-color: #fff;
  box-shadow: 0 -2rpx 12rpx rgba(0,0,0,0.06);
}

.add-btn {
  width: 100%;
  height: 88rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: $primary-color;
  color: #fff;
  font-size: 32rpx;
  font-weight: 600;
  border-radius: 44rpx;
  border: none;

  .add-icon {
    font-size: 40rpx;
    margin-right: 12rpx;
  }
}
</style>
