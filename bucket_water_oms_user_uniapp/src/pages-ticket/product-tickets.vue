<template>
  <view class="page">
    <view class="header">
      <text class="title">水票套餐</text>
      <text class="subtitle">购买水票更划算</text>
    </view>

    <view class="ticket-list" v-if="!loading && ticketList.length > 0">
      <view
        v-for="item in ticketList"
        :key="item.id"
        class="ticket-card"
        @tap="goBuy(item)"
      >
        <view class="ticket-head">
          <text class="ticket-name">{{ item.name || '桶装水水票' }}</text>
          <text class="ticket-stock">库存 {{ item.stock || 0 }}</text>
        </view>
        <view class="ticket-body">
          <view class="face">
            <text class="face-num">{{ item.faceValue || 0 }}</text>
            <text class="face-unit">桶</text>
          </view>
          <view class="price">
            <text class="price-cur">¥</text>
            <text class="price-num">{{ item.price || 0 }}</text>
            <text class="price-original">原价¥{{ item.originalPrice || (item.faceValue * 20) }}</text>
          </view>
        </view>
        <view class="ticket-foot">
          <text class="foot-tip">折合每桶 ¥{{ ((item.price || 0) / (item.faceValue || 1)).toFixed(2) }}</text>
          <text class="buy-btn">立即购买</text>
        </view>
      </view>
    </view>

    <view v-else-if="loading" class="empty">
      <text class="empty-text">加载中...</text>
    </view>

    <view v-else class="empty">
      <text class="empty-icon">🎫</text>
      <text class="empty-text">暂无可用水票套餐</text>
      <text class="empty-tip">请联系水厂或稍后再来查看</text>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { ticketService, WaterTicket } from '@/services/ticketService'

const loading = ref(false)
const ticketList = ref<WaterTicket[]>([])

const loadTickets = async () => {
  loading.value = true
  try {
    const res: any = await ticketService.getTickets({ status: 'active' })
    ticketList.value = res?.list || res?.records || res || []
  } catch (error) {
    console.error('加载水票套餐失败:', error)
    ticketList.value = []
  } finally {
    loading.value = false
  }
}

const goBuy = (item: WaterTicket) => {
  uni.navigateTo({
    url: `/pages-ticket/buy?id=${item.id}`
  })
}

onMounted(() => {
  loadTickets()
})
onShow(() => {
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
  padding: 24rpx 8rpx 32rpx;
  .title {
    display: block;
    font-size: 44rpx;
    font-weight: bold;
    color: #1f2937;
  }
  .subtitle {
    display: block;
    margin-top: 8rpx;
    font-size: 26rpx;
    color: #6b7280;
  }
}
.ticket-list {
  display: flex;
  flex-direction: column;
  gap: 24rpx;
}
.ticket-card {
  background: linear-gradient(135deg, #3b82f6, #60a5fa);
  color: #fff;
  border-radius: 24rpx;
  padding: 32rpx;
  box-shadow: 0 8rpx 24rpx rgba(59, 130, 246, 0.2);
}
.ticket-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  .ticket-name {
    font-size: 32rpx;
    font-weight: 600;
  }
  .ticket-stock {
    font-size: 24rpx;
    background: rgba(255, 255, 255, 0.2);
    padding: 4rpx 16rpx;
    border-radius: 16rpx;
  }
}
.ticket-body {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  margin: 32rpx 0 24rpx;
  .face {
    display: flex;
    align-items: baseline;
    .face-num {
      font-size: 80rpx;
      font-weight: bold;
      line-height: 1;
    }
    .face-unit {
      margin-left: 8rpx;
      font-size: 28rpx;
    }
  }
  .price {
    text-align: right;
    .price-cur {
      font-size: 28rpx;
    }
    .price-num {
      font-size: 48rpx;
      font-weight: bold;
    }
    .price-original {
      display: block;
      font-size: 24rpx;
      text-decoration: line-through;
      opacity: 0.8;
    }
  }
}
.ticket-foot {
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-top: 2rpx dashed rgba(255, 255, 255, 0.3);
  padding-top: 24rpx;
  .foot-tip {
    font-size: 24rpx;
    opacity: 0.9;
  }
  .buy-btn {
    background: #fff;
    color: #3b82f6;
    padding: 8rpx 28rpx;
    border-radius: 32rpx;
    font-size: 26rpx;
    font-weight: 600;
  }
}
.empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 200rpx 0;
  .empty-icon {
    font-size: 120rpx;
    margin-bottom: 30rpx;
  }
  .empty-text {
    font-size: 32rpx;
    color: #6b7280;
    margin-bottom: 10rpx;
  }
  .empty-tip {
    font-size: 26rpx;
    color: #9ca3af;
  }
}
</style>
