<template>
  <view class="page">
    <view class="header">
      <text class="title">{{ ticketId ? '编辑水票' : '新建水票' }}</text>
    </view>

    <view class="form-card">
      <view class="form-item">
        <text class="label">水票编号</text>
        <input class="input" v-model="form.ticketNo" placeholder="自动生成或手动输入" />
      </view>
      <view class="form-item">
        <text class="label">水票总数</text>
        <input class="input" type="number" v-model="form.totalCount" placeholder="请输入总桶数" />
      </view>
      <view class="form-item">
        <text class="label">购买金额</text>
        <input class="input" type="digit" v-model="form.amount" placeholder="请输入金额" />
      </view>
      <view class="form-item">
        <text class="label">过期日期</text>
        <picker mode="date" :value="form.expireDate" :end="endDateLimit" @change="onExpireChange">
          <view class="picker">{{ form.expireDate || '请选择过期日期' }}</view>
        </picker>
      </view>
      <view class="form-item">
        <text class="label">状态</text>
        <view class="status-row">
          <text class="status-opt" :class="{ active: form.status === 'active' }" @click="form.status = 'active'">启用</text>
          <text class="status-opt" :class="{ active: form.status === 'inactive' }" @click="form.status = 'inactive'">停用</text>
        </view>
      </view>
    </view>

    <view class="action-bar">
      <button class="btn-cancel" @click="goBack">取消</button>
      <button class="btn-primary" @click="handleSubmit" :disabled="submitting">
        {{ submitting ? '保存中...' : '保存' }}
      </button>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { get, post, put } from '@/utils/request'

const ticketId = ref<string>('')
const submitting = ref(false)
const form = reactive({
  ticketNo: '',
  totalCount: 0,
  amount: 0,
  expireDate: '',
  status: 'active' as 'active' | 'inactive'
})

const endDateLimit = computed(() => {
  const d = new Date()
  d.setFullYear(d.getFullYear() + 5)
  return d.toISOString().slice(0, 10)
})

const onExpireChange = (e: any) => {
  form.expireDate = e.detail.value
}

onLoad((options) => {
  if (options?.id) {
    ticketId.value = options.id
    loadDetail()
  } else {
    // 新增模式，自动生成编号
    form.ticketNo = 'T' + Date.now().toString().slice(-8)
    // 默认一年后过期
    const d = new Date()
    d.setFullYear(d.getFullYear() + 1)
    form.expireDate = d.toISOString().slice(0, 10)
  }
})

const loadDetail = async () => {
  try {
    const res: any = await get(`/tickets/${ticketId.value}`)
    if (res) {
      form.ticketNo = res.ticketNo || ''
      form.totalCount = res.totalCount || 0
      form.amount = res.amount || 0
      form.expireDate = res.expireDate ? String(res.expireDate).slice(0, 10) : ''
      form.status = res.status || 'active'
    }
  } catch (error) {
    uni.showToast({ title: '加载详情失败', icon: 'none' })
  }
}

const goBack = () => uni.navigateBack()

const validateForm = (): string | null => {
  if (!form.ticketNo?.trim()) return '请输入水票编号'
  if (!form.totalCount || form.totalCount <= 0) return '请输入正确的总桶数'
  if (form.amount < 0) return '金额不能为负数'
  if (!form.expireDate) return '请选择过期日期'
  return null
}

const handleSubmit = async () => {
  const err = validateForm()
  if (err) {
    uni.showToast({ title: err, icon: 'none' })
    return
  }
  submitting.value = true
  try {
    if (ticketId.value) {
      // 更新 - 后端暂无对应更新接口，跳过
      uni.showToast({ title: '更新功能开发中', icon: 'none' })
    } else {
      // 新建 - 调用购买水票接口
      await post('/tickets/purchase', null, {
        count: form.totalCount,
        amount: form.amount,
        expireDate: form.expireDate
      }, {
        loading: true,
        loadingText: '保存中...',
        header: { 'Content-Type': 'application/x-www-form-urlencoded' }
      })
      uni.showToast({ title: '创建成功', icon: 'success' })
    }
    setTimeout(() => uni.navigateBack(), 800)
  } catch (error: any) {
    uni.showToast({ title: error?.message || '保存失败', icon: 'none' })
  } finally {
    submitting.value = false
  }
}

onMounted(() => {})
</script>

<style lang="scss" scoped>
.page {
  min-height: 100vh;
  background: $bg-color;
  padding: 24rpx;
}
.header {
  padding: 16rpx 8rpx 24rpx;
  .title {
    font-size: 40rpx;
    font-weight: bold;
    color: #1f2937;
  }
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
  .label {
    width: 200rpx;
    font-size: 28rpx;
    color: #374151;
  }
  .input {
    flex: 1;
    font-size: 28rpx;
    color: #1f2937;
  }
  .picker {
    flex: 1;
    font-size: 28rpx;
    color: #1f2937;
  }
}
.status-row {
  flex: 1;
  display: flex;
  gap: 16rpx;
  .status-opt {
    padding: 12rpx 32rpx;
    border: 2rpx solid #e5e7eb;
    border-radius: 12rpx;
    font-size: 26rpx;
    color: #6b7280;
    &.active {
      background: $primary-color;
      color: #fff;
      border-color: $primary-color;
    }
  }
}
.action-bar {
  display: flex;
  gap: 24rpx;
  padding: 32rpx 24rpx;
  .btn-cancel, .btn-primary {
    flex: 1;
    border-radius: 12rpx;
    font-size: 30rpx;
    padding: 24rpx 0;
    margin: 0;
    border: none;
  }
  .btn-cancel {
    background: #e5e7eb;
    color: #4b5563;
  }
  .btn-primary {
    background: $primary-color;
    color: #fff;
  }
  .btn-primary[disabled] {
    background: #9ca3af;
    color: #fff;
  }
}
</style>
