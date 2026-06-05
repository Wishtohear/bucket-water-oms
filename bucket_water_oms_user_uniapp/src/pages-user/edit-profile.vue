<template>
  <view class="page">
    <view class="header">
      <text class="title">编辑资料</text>
    </view>
    <view class="form-card">
      <view class="form-item">
        <text class="label">姓名</text>
        <input class="input" v-model="form.name" placeholder="请输入姓名" />
      </view>
      <view class="form-item">
        <text class="label">手机号</text>
        <input class="input" type="number" v-model="form.phone" placeholder="请输入手机号" maxlength="11" />
      </view>
      <view class="form-item">
        <text class="label">邮箱</text>
        <input class="input" v-model="form.email" placeholder="请输入邮箱（选填）" />
      </view>
      <view class="form-item">
        <text class="label">地址</text>
        <input class="input" v-model="form.address" placeholder="请输入联系地址" />
      </view>
    </view>
    <view class="action-bar">
      <button class="btn-cancel" @click="goBack">取消</button>
      <button class="btn-primary" @click="handleSave" :disabled="saving">{{ saving ? '保存中...' : '保存' }}</button>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()
const saving = ref(false)
const form = reactive({
  name: '',
  phone: '',
  email: '',
  address: ''
})

onMounted(() => {
  const user = authStore.userInfo as any
  if (user) {
    form.name = user.name || ''
    form.phone = user.phone || ''
    form.email = user.email || ''
    form.address = user.address || ''
  }
})

const goBack = () => uni.navigateBack()

const handleSave = async () => {
  if (!form.name?.trim()) {
    uni.showToast({ title: '请输入姓名', icon: 'none' })
    return
  }
  if (!/^1[3-9]\d{9}$/.test(form.phone)) {
    uni.showToast({ title: '手机号格式不正确', icon: 'none' })
    return
  }
  saving.value = true
  try {
    // 更新本地存储的用户信息（实际应调用后端 user update API）
    const updated = {
      ...(authStore.userInfo || {}),
      name: form.name,
      phone: form.phone,
      email: form.email,
      address: form.address
    }
    authStore.setUserInfo(updated as any)
    uni.showToast({ title: '保存成功', icon: 'success' })
    setTimeout(() => uni.navigateBack(), 800)
  } catch (error) {
    uni.showToast({ title: '保存失败', icon: 'none' })
  } finally {
    saving.value = false
  }
}
</script>

<style lang="scss" scoped>
.page {
  min-height: 100vh;
  background: $bg-color;
  padding: 24rpx;
}
.header {
  padding: 16rpx 8rpx 24rpx;
  .title { font-size: 40rpx; font-weight: bold; color: #1f2937; }
}
.form-card {
  background: #fff;
  border-radius: 16rpx;
  padding: 0 24rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}
.form-item {
  display: flex;
  align-items: center;
  padding: 32rpx 0;
  border-bottom: 2rpx solid #f3f4f6;
  &:last-child { border-bottom: none; }
  .label { width: 160rpx; font-size: 28rpx; color: #374151; }
  .input { flex: 1; font-size: 28rpx; color: #1f2937; }
}
.action-bar {
  display: flex;
  gap: 24rpx;
  padding: 32rpx 24rpx;
  .btn-cancel, .btn-primary {
    flex: 1; border-radius: 12rpx; font-size: 30rpx;
    padding: 24rpx 0; margin: 0; border: none;
  }
  .btn-cancel { background: #e5e7eb; color: #4b5563; }
  .btn-primary { background: $primary-color; color: #fff; }
  .btn-primary[disabled] { background: #9ca3af; color: #fff; }
}
</style>
