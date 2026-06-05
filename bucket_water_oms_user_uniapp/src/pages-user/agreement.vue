<template>
  <view class="page">
    <view class="header">
      <text class="title">{{ title }}</text>
      <text class="subtitle">{{ subtitle }}</text>
    </view>
    <scroll-view scroll-y class="content">
      <view class="section">
        <text class="section-title">一、服务说明</text>
        <text class="section-content">本平台为水站提供在线下单、桶装水配送、售后管理等服务。使用本平台前请仔细阅读以下条款。</text>
      </view>
      <view class="section">
        <text class="section-title">二、用户权利与义务</text>
        <text class="section-content">用户有权按平台规则使用各项服务，并应遵守国家法律法规，不得从事违法违规活动。</text>
      </view>
      <view class="section">
        <text class="section-title">三、隐私保护</text>
        <text class="section-content">平台严格保护用户个人信息，未经用户授权不会向第三方披露。详见《隐私政策》。</text>
      </view>
      <view class="section">
        <text class="section-title">四、服务变更与终止</text>
        <text class="section-content">平台保留根据业务发展需要修改或终止服务的权利，重大变更将提前通知用户。</text>
      </view>
      <view class="section">
        <text class="section-title">五、争议解决</text>
        <text class="section-content">因使用本平台产生的争议，双方应友好协商解决；协商不成的，提交平台运营方所在地有管辖权的人民法院解决。</text>
      </view>
      <view v-if="isPrivacy" class="section">
        <text class="section-title">六、信息收集</text>
        <text class="section-content">我们收集手机号、收货地址、订单信息等必要数据以提供完整服务。</text>
      </view>
      <view class="meta">
        <text>最后更新：2026-04-25</text>
      </view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { onLoad } from '@dcloudio/uni-app'

const type = ref('user')
const isPrivacy = computed(() => type.value === 'privacy')
const title = computed(() => isPrivacy.value ? '隐私政策' : '用户协议')
const subtitle = computed(() => isPrivacy.value ? 'Privacy Policy' : 'User Agreement')

onLoad((options) => {
  if (options?.type) {
    type.value = options.type
  }
})
</script>

<style lang="scss" scoped>
.page {
  min-height: 100vh;
  background: $bg-color;
}
.header {
  padding: 48rpx 32rpx 24rpx;
  background: #fff;
  text-align: center;
  border-bottom: 2rpx solid #f3f4f6;
  .title { display: block; font-size: 44rpx; font-weight: 700; color: #1f2937; }
  .subtitle { display: block; font-size: 24rpx; color: #6b7280; margin-top: 8rpx; }
}
.content {
  height: calc(100vh - 200rpx);
  padding: 24rpx;
}
.section {
  background: #fff;
  border-radius: 16rpx;
  padding: 24rpx;
  margin-bottom: 16rpx;
  .section-title {
    display: block;
    font-size: 30rpx;
    font-weight: 600;
    color: #1f2937;
    margin-bottom: 12rpx;
  }
  .section-content {
    display: block;
    font-size: 26rpx;
    color: #4b5563;
    line-height: 1.7;
  }
}
.meta {
  text-align: center;
  color: #9ca3af;
  font-size: 24rpx;
  padding: 32rpx 0;
}
</style>
