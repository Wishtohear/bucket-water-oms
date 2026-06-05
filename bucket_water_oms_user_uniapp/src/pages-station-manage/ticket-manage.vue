<template>
  <view class="page">
    <view class="header">
      <text class="title">水票管理</text>
    </view>

    <view class="stats-row">
      <view class="stat-item">
        <text class="stat-value">{{ stats.total || 0 }}</text>
        <text class="stat-label">总票数</text>
      </view>
      <view class="stat-item">
        <text class="stat-value">{{ stats.remaining || 0 }}</text>
        <text class="stat-label">剩余</text>
      </view>
      <view class="stat-item">
        <text class="stat-value">{{ stats.used || 0 }}</text>
        <text class="stat-label">已用</text>
      </view>
      <view class="stat-item">
        <text class="stat-value">{{ stats.expired || 0 }}</text>
        <text class="stat-label">已过期</text>
      </view>
    </view>

    <view class="toolbar">
      <input v-model="searchKeyword" class="search-input" placeholder="搜索水票编号" @confirm="loadTickets" />
      <button class="btn-primary" @click="goEdit(null)">+ 新建水票</button>
    </view>

    <view class="ticket-list" v-if="!loading && ticketList.length > 0">
      <view class="ticket-row" v-for="item in ticketList" :key="item.id">
        <view class="row-main">
          <text class="row-title">{{ item.ticketNo || '水票#' + item.id }}</text>
          <text class="row-meta">水站: {{ item.stationName || '默认' }}</text>
          <text class="row-meta">总数 {{ item.totalCount || 0 }} / 剩余 {{ item.remainingCount || 0 }} / 已用 {{ item.usedCount || 0 }}</text>
          <text class="row-meta">金额: ¥{{ item.amount || 0 }}</text>
        </view>
        <view class="row-side">
          <text class="status" :class="getStatusClass(item.status, item.expireDate)">{{ getStatusText(item.status, item.expireDate) }}</text>
          <view class="row-actions">
            <button class="btn-link" @click="goEdit(item)">编辑</button>
            <button class="btn-link danger" @click="confirmDelete(item)">删除</button>
          </view>
        </view>
      </view>
    </view>

    <view v-else-if="loading" class="empty">
      <text class="empty-text">加载中...</text>
    </view>

    <view v-else class="empty">
      <text class="empty-icon">🎫</text>
      <text class="empty-text">暂无水票记录</text>
      <text class="empty-tip">点击右上角"新建水票"创建第一条记录</text>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { get, del, post } from '@/utils/request'

const loading = ref(false)
const searchKeyword = ref('')
const ticketList = ref<any[]>([])

const stats = reactive({ total: 0, remaining: 0, used: 0, expired: 0 })

const getStatusText = (status: string, expireDate: any) => {
  if (status === 'inactive') return '已停用'
  if (expireDate) {
    const exp = new Date(expireDate)
    if (!isNaN(exp.getTime()) && exp.getTime() < Date.now()) return '已过期'
  }
  return '有效'
}

const getStatusClass = (status: string, expireDate: any) => {
  if (status === 'inactive') return 'inactive'
  if (expireDate) {
    const exp = new Date(expireDate)
    if (!isNaN(exp.getTime()) && exp.getTime() < Date.now()) return 'expired'
  }
  return 'active'
}

const loadStats = async () => {
  try {
    const res: any = await get('/tickets/stats')
    Object.assign(stats, res || {})
  } catch (error) {
    console.error('加载水票统计失败:', error)
  }
}

const loadTickets = async () => {
  loading.value = true
  try {
    const res: any = await get('/tickets', {
      keyword: searchKeyword.value || undefined
    })
    ticketList.value = Array.isArray(res) ? res : (res?.list || res?.records || [])
  } catch (error) {
    console.error('加载水票列表失败:', error)
    ticketList.value = []
  } finally {
    loading.value = false
  }
}

const goEdit = (item: any) => {
  const id = item?.id || ''
  uni.navigateTo({ url: `/pages-station-manage/ticket-edit${id ? '?id=' + id : ''}` })
}

const confirmDelete = (item: any) => {
  uni.showModal({
    title: '确认删除',
    content: `确定要删除水票 ${item.ticketNo || '#' + item.id} 吗？`,
    success: async (res) => {
      if (res.confirm) {
        await deleteTicket(item.id)
      }
    }
  })
}

const deleteTicket = async (id: number) => {
  try {
    await del(`/tickets/${id}`)
    uni.showToast({ title: '删除成功', icon: 'success' })
    loadTickets()
    loadStats()
  } catch (error) {
    uni.showToast({ title: '删除失败', icon: 'none' })
  }
}

onMounted(() => {
  loadStats()
  loadTickets()
})
onShow(() => {
  loadStats()
  loadTickets()
})
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
.stats-row {
  display: flex;
  background: #fff;
  border-radius: 16rpx;
  padding: 24rpx;
  margin-bottom: 24rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
  .stat-item {
    flex: 1;
    text-align: center;
    .stat-value {
      display: block;
      font-size: 40rpx;
      font-weight: bold;
      color: $primary-color;
    }
    .stat-label {
      display: block;
      font-size: 24rpx;
      color: #6b7280;
      margin-top: 6rpx;
    }
  }
}
.toolbar {
  display: flex;
  gap: 16rpx;
  margin-bottom: 24rpx;
  .search-input {
    flex: 1;
    background: #fff;
    border-radius: 12rpx;
    padding: 0 24rpx;
    height: 72rpx;
    font-size: 28rpx;
  }
  .btn-primary {
    background: $primary-color;
    color: #fff;
    border-radius: 12rpx;
    padding: 0 32rpx;
    font-size: 28rpx;
    line-height: 72rpx;
    border: none;
    margin: 0;
  }
}
.ticket-list {
  background: #fff;
  border-radius: 16rpx;
  overflow: hidden;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}
.ticket-row {
  display: flex;
  justify-content: space-between;
  padding: 24rpx;
  border-bottom: 2rpx solid #f3f4f6;
  &:last-child { border-bottom: none; }
  .row-main { flex: 1; }
  .row-title {
    font-size: 30rpx;
    font-weight: 600;
    color: #1f2937;
    display: block;
  }
  .row-meta {
    font-size: 24rpx;
    color: #6b7280;
    margin-top: 6rpx;
    display: block;
  }
  .row-side {
    text-align: right;
    margin-left: 24rpx;
  }
  .status {
    display: inline-block;
    font-size: 22rpx;
    padding: 4rpx 14rpx;
    border-radius: 14rpx;
    &.active { background: #d1fae5; color: #059669; }
    &.inactive { background: #e5e7eb; color: #6b7280; }
    &.expired { background: #fee2e2; color: #dc2626; }
  }
  .row-actions {
    margin-top: 12rpx;
    display: flex;
    gap: 12rpx;
  }
  .btn-link {
    font-size: 24rpx;
    color: $primary-color;
    background: none;
    border: none;
    padding: 0;
    margin: 0;
    line-height: 1.4;
    &.danger { color: #ef4444; }
  }
}
.empty {
  text-align: center;
  padding: 200rpx 0;
  .empty-icon { font-size: 120rpx; display: block; margin-bottom: 30rpx; }
  .empty-text { font-size: 32rpx; color: #6b7280; display: block; margin-bottom: 10rpx; }
  .empty-tip { font-size: 24rpx; color: #9ca3af; display: block; }
}
</style>
