<template>
  <view class="stats-page">
    <view class="header-section">
      <view class="greeting">
        <text class="greeting-text">{{ greeting }}</text>
        <text class="date-text">{{ currentDate }}</text>
      </view>
    </view>

    <view class="stats-overview" v-if="stats">
      <view class="stat-card primary">
        <text class="stat-value">{{ stats.todayOrders || 0 }}</text>
        <text class="stat-label">今日配送</text>
        <text class="stat-unit">单</text>
      </view>

      <view class="stat-grid">
        <view class="stat-item">
          <text class="stat-value">{{ stats.monthOrders || 0 }}</text>
          <text class="stat-label">本月配送</text>
        </view>
        <view class="stat-item">
          <text class="stat-value">{{ stats.totalOrders || 0 }}</text>
          <text class="stat-label">累计配送</text>
        </view>
        <view class="stat-item">
          <text class="stat-value">¥{{ formatAmount(stats.totalIncome || 0) }}</text>
          <text class="stat-label">累计收入</text>
        </view>
        <view class="stat-item">
          <text class="stat-value">{{ stats.totalBuckets || 0 }}</text>
          <text class="stat-label">累计桶数</text>
        </view>
      </view>
    </view>

    <view class="chart-section">
      <view class="section-title">
        <text class="title-text">配送趋势</text>
        <view class="tab-bar">
          <text class="tab-item" :class="{ active: chartPeriod === 'week' }" @click="switchPeriod('week')">本周</text>
          <text class="tab-item" :class="{ active: chartPeriod === 'month' }" @click="switchPeriod('month')">本月</text>
        </view>
      </view>

      <view class="chart-placeholder">
        <view class="chart-bars" v-if="chartData.length > 0">
          <view class="chart-bar" v-for="(item, index) in chartData" :key="index">
            <view class="bar-fill" :style="{ height: getBarHeight(item.count) + '%' }"></view>
            <text class="bar-label">{{ item.label }}</text>
            <text class="bar-value">{{ item.count }}</text>
          </view>
        </view>
        <view class="empty-chart" v-else>
          <text class="empty-text">暂无数据</text>
        </view>
      </view>
    </view>

    <view class="achievement-section">
      <view class="section-title">
        <text class="title-text">我的成就</text>
      </view>

      <view class="achievement-list">
        <view class="achievement-item" v-for="achievement in achievements" :key="achievement.id">
          <text class="achievement-icon">{{ achievement.icon }}</text>
          <view class="achievement-info">
            <text class="achievement-name">{{ achievement.name }}</text>
            <view class="achievement-progress">
              <view class="progress-bar">
                <view class="progress-fill" :style="{ width: achievement.progress + '%' }"></view>
              </view>
              <text class="progress-text">{{ achievement.current }}/{{ achievement.target }}</text>
            </view>
          </view>
          <text class="achievement-badge" v-if="achievement.completed">🏆</text>
        </view>
      </view>
    </view>

    <view class="bottom-actions">
      <button class="action-btn" @click="viewHistory">查看历史记录</button>
    </view>

    <view class="loading-overlay" v-if="loading">
      <text class="loading-text">加载中...</text>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { deliveryPersonService, DeliveryStats } from '@/services/deliveryPersonService'

const loading = ref(false)
const stats = ref<DeliveryStats | null>(null)
const chartPeriod = ref<'week' | 'month'>('week')
const chartData = ref<Array<{ label: string; count: number }>>([])

const greeting = computed(() => {
  const hour = new Date().getHours()
  if (hour < 12) return '早上好'
  if (hour < 18) return '下午好'
  return '晚上好'
})

const currentDate = computed(() => {
  const now = new Date()
  const month = now.getMonth() + 1
  const day = now.getDate()
  const weekDay = ['日', '一', '二', '三', '四', '五', '六'][now.getDay()]
  return `${month}月${day}日 星期${weekDay}`
})

const achievements = computed(() => {
  const todayOrders = stats.value?.todayOrders || 0
  const monthOrders = stats.value?.monthOrders || 0
  const totalIncome = stats.value?.totalIncome || 0
  // 连续配送天数从后端返回的连续字段读取，无则展示 0
  const continuousDays = (stats.value as any)?.continuousDays || 0
  return [
    {
      id: 1,
      icon: '🎯',
      name: '今日任务',
      current: todayOrders,
      target: 10,
      progress: Math.min((todayOrders / 10) * 100, 100),
      completed: todayOrders >= 10
    },
    {
      id: 2,
      icon: '🔥',
      name: '连续配送',
      current: continuousDays,
      target: 7,
      progress: Math.min((continuousDays / 7) * 100, 100),
      completed: continuousDays >= 7
    },
    {
      id: 3,
      icon: '⭐',
      name: '月度之星',
      current: monthOrders,
      target: 100,
      progress: Math.min((monthOrders / 100) * 100, 100),
      completed: monthOrders >= 100
    },
    {
      id: 4,
      icon: '💰',
      name: '收入目标',
      current: Math.floor(totalIncome),
      target: 10000,
      progress: Math.min((totalIncome / 10000) * 100, 100),
      completed: totalIncome >= 10000
    }
  ]
})

const formatAmount = (amount: number) => {
  return amount.toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

const getBarHeight = (count: number) => {
  if (chartData.value.length === 0) return 0
  const maxCount = Math.max(...chartData.value.map(item => item.count))
  if (maxCount === 0) return 0
  return (count / maxCount) * 100
}

const loadStats = async () => {
  loading.value = true
  try {
    const result = await deliveryPersonService.getStats()
    if (result) {
      stats.value = result
    }
    loadChartData()
  } catch (error) {
    console.error('加载统计数据失败:', error)
    uni.showToast({ title: '加载失败', icon: 'error' })
  } finally {
    loading.value = false
  }
}

const loadChartData = async () => {
  const period = chartPeriod.value
  try {
    // 调用后端真实接口获取图表数据
    const res: any = await deliveryPersonService.getStats({
      period
    } as any).catch(() => null)
    const list: Array<{ label: string; count: number }> =
      (res && Array.isArray(res.chart)) ? res.chart :
      (res && Array.isArray(res.list)) ? res.list : []

    if (list.length > 0) {
      chartData.value = list
      return
    }

    // 真实接口无数据时，基于统计的今日/月度数据填充前端占位（不再随机）
    if (period === 'week') {
      const weekData = []
      const today = new Date()
      for (let i = 6; i >= 0; i--) {
        const date = new Date(today)
        date.setDate(date.getDate() - i)
        weekData.push({
          label: ['日', '一', '二', '三', '四', '五', '六'][date.getDay()],
          count: i === 0 ? (stats.value?.todayOrders || 0) : 0
        })
      }
      chartData.value = weekData
    } else {
      const monthData = []
      const daysInMonth = new Date(new Date().getFullYear(), new Date().getMonth() + 1, 0).getDate()
      for (let i = 1; i <= daysInMonth; i += 5) {
        monthData.push({
          label: `${i}日`,
          count: 0
        })
      }
      chartData.value = monthData
    }
  } catch (error) {
    console.error('加载图表数据失败:', error)
    chartData.value = []
  }
}

const switchPeriod = (period: 'week' | 'month') => {
  chartPeriod.value = period
  loadChartData()
}

const viewHistory = () => {
  uni.navigateTo({
    url: '/pages-delivery/history'
  })
}

onMounted(() => {
  loadStats()
})
</script>

<style lang="scss" scoped>
.stats-page {
  min-height: 100vh;
  background: $bg-color;
  padding-bottom: 120rpx;
}

.header-section {
  background: linear-gradient(135deg, $primary-color 0%, #4096ff 100%);
  padding: 48rpx 32rpx;
  padding-top: calc(48rpx + env(safe-area-inset-top));

  .greeting {
    .greeting-text {
      display: block;
      font-size: 40rpx;
      font-weight: 700;
      color: #fff;
      margin-bottom: 8rpx;
    }

    .date-text {
      display: block;
      font-size: 28rpx;
      color: rgba(255, 255, 255, 0.8);
    }
  }
}

.stats-overview {
  margin: -60rpx 24rpx 24rpx;
  position: relative;
  z-index: 1;

  .stat-card {
    background: #fff;
    border-radius: $radius-xl;
    padding: 32rpx;
    margin-bottom: 24rpx;
    box-shadow: $shadow-md;

    &.primary {
      background: linear-gradient(135deg, $primary-color 0%, #4096ff 100%);
      color: #fff;
      text-align: center;

      .stat-value {
        font-size: 72rpx;
        font-weight: 700;
        color: #fff;
        margin-bottom: 8rpx;
      }

      .stat-label {
        font-size: 28rpx;
        color: rgba(255, 255, 255, 0.9);
        margin-bottom: 4rpx;
      }

      .stat-unit {
        font-size: 24rpx;
        color: rgba(255, 255, 255, 0.7);
      }
    }
  }

  .stat-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 24rpx;

    .stat-item {
      background: #fff;
      border-radius: $radius-lg;
      padding: 24rpx;
      text-align: center;
      box-shadow: $shadow-sm;

      .stat-value {
        display: block;
        font-size: 40rpx;
        font-weight: 700;
        color: $text-primary;
        margin-bottom: 8rpx;
      }

      .stat-label {
        display: block;
        font-size: 24rpx;
        color: $text-secondary;
      }
    }
  }
}

.chart-section {
  background: #fff;
  margin: 0 24rpx 24rpx;
  border-radius: $radius-lg;
  padding: 24rpx;
  box-shadow: $shadow-sm;

  .section-title {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24rpx;

    .title-text {
      font-size: 32rpx;
      font-weight: 600;
      color: $text-primary;
    }

    .tab-bar {
      display: flex;
      gap: 16rpx;

      .tab-item {
        font-size: 26rpx;
        color: $text-secondary;
        padding: 8rpx 16rpx;
        border-radius: 20rpx;
        transition: all 0.3s;

        &.active {
          background: $primary-color;
          color: #fff;
        }
      }
    }
  }

  .chart-placeholder {
    height: 300rpx;

    .chart-bars {
      display: flex;
      align-items: flex-end;
      justify-content: space-around;
      height: 250rpx;
      padding: 0 16rpx;

      .chart-bar {
        display: flex;
        flex-direction: column;
        align-items: center;
        flex: 1;
        height: 100%;

        .bar-fill {
          width: 40rpx;
          background: linear-gradient(180deg, $primary-color 0%, #a0cfff 100%);
          border-radius: 8rpx 8rpx 0 0;
          transition: height 0.3s;
          margin-top: auto;
        }

        .bar-label {
          font-size: 20rpx;
          color: $text-tertiary;
          margin-top: 8rpx;
        }

        .bar-value {
          font-size: 22rpx;
          color: $text-primary;
          font-weight: 600;
        }
      }
    }

    .empty-chart {
      display: flex;
      align-items: center;
      justify-content: center;
      height: 100%;

      .empty-text {
        font-size: 28rpx;
        color: $text-tertiary;
      }
    }
  }
}

.achievement-section {
  background: #fff;
  margin: 0 24rpx 24rpx;
  border-radius: $radius-lg;
  padding: 24rpx;
  box-shadow: $shadow-sm;

  .section-title {
    margin-bottom: 24rpx;

    .title-text {
      font-size: 32rpx;
      font-weight: 600;
      color: $text-primary;
    }
  }

  .achievement-list {
    .achievement-item {
      display: flex;
      align-items: center;
      padding: 20rpx 0;
      border-bottom: 1rpx solid $border-color;

      &:last-child {
        border-bottom: none;
      }

      .achievement-icon {
        font-size: 48rpx;
        margin-right: 20rpx;
      }

      .achievement-info {
        flex: 1;

        .achievement-name {
          display: block;
          font-size: 28rpx;
          font-weight: 600;
          color: $text-primary;
          margin-bottom: 12rpx;
        }

        .achievement-progress {
          display: flex;
          align-items: center;
          gap: 16rpx;

          .progress-bar {
            flex: 1;
            height: 8rpx;
            background: $border-color;
            border-radius: 4rpx;
            overflow: hidden;

            .progress-fill {
              height: 100%;
              background: linear-gradient(90deg, $primary-color 0%, $success-color 100%);
              border-radius: 4rpx;
              transition: width 0.3s;
            }
          }

          .progress-text {
            font-size: 22rpx;
            color: $text-secondary;
            min-width: 80rpx;
          }
        }
      }

      .achievement-badge {
        font-size: 32rpx;
        margin-left: 16rpx;
      }
    }
  }
}

.bottom-actions {
  padding: 24rpx;

  .action-btn {
    width: 100%;
    height: 88rpx;
    background: #fff;
    color: $primary-color;
    font-size: 32rpx;
    font-weight: 600;
    border-radius: 44rpx;
    border: 2rpx solid $primary-color;
    display: flex;
    align-items: center;
    justify-content: center;
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
