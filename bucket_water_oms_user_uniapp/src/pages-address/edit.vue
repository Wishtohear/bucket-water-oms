<template>
  <view class="edit-page">
    <view class="form-section">
      <view class="form-item">
        <text class="form-label">联系人</text>
        <input
          class="form-input"
          v-model="form.contactName"
          placeholder="请输入联系人姓名"
          maxlength="20"
        />
      </view>

      <view class="form-item">
        <text class="form-label">手机号</text>
        <input
          class="form-input"
          type="number"
          v-model="form.contactPhone"
          placeholder="请输入手机号"
          maxlength="11"
        />
      </view>

      <view class="form-item" @click="chooseLocation">
        <text class="form-label">所在地区</text>
        <view class="form-value">
          <text v-if="form.province || form.city || form.district">
            {{ form.province }} {{ form.city }} {{ form.district }}
          </text>
          <text class="placeholder" v-else>请选择省市区</text>
        </view>
        <text class="form-arrow">></text>
      </view>

      <view class="form-item">
        <text class="form-label">详细地址</text>
        <textarea
          class="form-textarea"
          v-model="form.detail"
          placeholder="请输入详细地址"
          maxlength="200"
        />
      </view>

      <view class="form-item switch-item">
        <text class="form-label">设为默认地址</text>
        <switch
          :checked="form.isDefault"
          @change="onDefaultChange"
          color="#1890FF"
        />
      </view>
    </view>

    <view class="form-actions">
      <button class="save-btn" @click="saveAddress" :disabled="!canSave">
        保存
      </button>
      <button class="delete-btn" v-if="addressId" @click="deleteAddress">
        删除地址
      </button>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { addressService } from '@/services/addressService'
import type { Address } from '@/types/order'

const addressId = ref('')
const isEdit = computed(() => !!addressId.value)

const form = ref({
  contactName: '',
  contactPhone: '',
  province: '',
  city: '',
  district: '',
  detail: '',
  isDefault: false
})

const canSave = computed(() => {
  return (
    form.value.contactName.trim() &&
    form.value.contactPhone.length === 11 &&
    form.value.province &&
    form.value.city &&
    form.value.detail.trim()
  )
})

const onDefaultChange = (e: any) => {
  form.value.isDefault = e.detail.value
}

const chooseLocation = () => {
  uni.chooseLocation({
    success: (res) => {
      if (res.address) {
        const address = res.address
        const parts = address.split(/省|市|区|县/)
        if (parts.length >= 3) {
          form.value.province = parts[0] + (address.includes('省') ? '省' : '')
          form.value.city = parts[1] + (address.includes('市') ? '市' : '')
          form.value.district = parts[2] + (address.includes('区') ? '区' : address.includes('县') ? '县' : '')
        } else if (parts.length === 2) {
          form.value.province = parts[0]
          form.value.city = parts[1]
          form.value.district = ''
        }
        form.value.detail = res.name || parts[parts.length - 1] || ''
      }
    }
  })
}

const loadAddress = async () => {
  if (!addressId.value) return

  try {
    const result = await addressService.getAddress(addressId.value)
    if (result) {
      form.value = {
        contactName: result.contactName,
        contactPhone: result.contactPhone,
        province: result.province || '',
        city: result.city || '',
        district: result.district || '',
        detail: result.detail || '',
        isDefault: result.isDefault
      }
    }
  } catch (error) {
    console.error('获取地址失败:', error)
  }
}

const saveAddress = async () => {
  if (!canSave.value) {
    uni.showToast({ title: '请填写完整信息', icon: 'none' })
    return
  }

  uni.showLoading({ title: '保存中...' })

  try {
    const data = {
      contactName: form.value.contactName.trim(),
      contactPhone: form.value.contactPhone,
      province: form.value.province,
      city: form.value.city,
      district: form.value.district,
      detail: form.value.detail.trim(),
      isDefault: form.value.isDefault,
      latitude: 0,
      longitude: 0
    }

    if (isEdit.value) {
      await addressService.updateAddress(addressId.value, data)
    } else {
      await addressService.addAddress(data as any)
    }

    uni.hideLoading()
    uni.showToast({ title: '保存成功', icon: 'success' })

    setTimeout(() => {
      uni.navigateBack()
    }, 1500)
  } catch (error) {
    uni.hideLoading()
    uni.showToast({ title: '保存失败', icon: 'none' })
  }
}

const deleteAddress = () => {
  if (!addressId.value) return

  uni.showModal({
    title: '提示',
    content: '确定要删除该地址吗？',
    success: async (res) => {
      if (res.confirm) {
        try {
          await addressService.deleteAddress(addressId.value)
          uni.showToast({ title: '删除成功', icon: 'success' })

          setTimeout(() => {
            uni.navigateBack()
          }, 1500)
        } catch (error) {
          uni.showToast({ title: '删除失败', icon: 'none' })
        }
      }
    }
  })
}

onMounted(() => {
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1] as any
  const options = currentPage?.options || {}

  addressId.value = options.id || ''

  if (isEdit.value) {
    uni.setNavigationBarTitle({ title: '编辑地址' })
    loadAddress()
  } else {
    uni.setNavigationBarTitle({ title: '新增地址' })
  }
})
</script>

<style lang="scss" scoped>
.edit-page {
  min-height: 100vh;
  background-color: $bg-color;
  padding: 24rpx;
}

.form-section {
  background-color: #fff;
  border-radius: $radius-lg;
  padding: 0 24rpx;
}

.form-item {
  display: flex;
  align-items: flex-start;
  padding: 28rpx 0;
  border-bottom: 1rpx solid $border-color;

  &:last-child {
    border-bottom: none;
  }

  &.switch-item {
    align-items: center;
  }
}

.form-label {
  width: 160rpx;
  font-size: 28rpx;
  color: $text-primary;
  flex-shrink: 0;
}

.form-input {
  flex: 1;
  height: 48rpx;
  font-size: 28rpx;
  color: $text-primary;
}

.form-value {
  flex: 1;
  font-size: 28rpx;
  color: $text-primary;

  .placeholder {
    color: $text-tertiary;
  }
}

.form-arrow {
  font-size: 24rpx;
  color: $text-tertiary;
  margin-left: 12rpx;
}

.form-textarea {
  flex: 1;
  min-height: 120rpx;
  font-size: 28rpx;
  color: $text-primary;
  line-height: 1.6;
}

.form-actions {
  margin-top: 48rpx;
}

.save-btn {
  width: 100%;
  height: 88rpx;
  background-color: $primary-color;
  color: #fff;
  font-size: 32rpx;
  font-weight: 600;
  border-radius: 44rpx;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 24rpx;

  &[disabled] {
    background-color: #ccc;
  }
}

.delete-btn {
  width: 100%;
  height: 88rpx;
  background-color: transparent;
  color: $error-color;
  font-size: 32rpx;
  border: 2rpx solid $error-color;
  border-radius: 44rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
