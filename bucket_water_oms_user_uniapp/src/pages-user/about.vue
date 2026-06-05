<template>
  <view class="page">
    <view class="header">
      <text class="logo-icon">💧</text>
      <text class="title">订水平台</text>
      <text class="version">v1.0.0</text>
    </view>
    <view class="content">
      <view class="card">
        <text class="card-title">产品介绍</text>
        <text class="card-content">订水平台是一款为水站提供数字化订货、配送、售后管理的一站式服务系统，支持水站老板在线下单、仓库智能派单、司机高效配送等全流程业务。</text>
      </view>
      <view class="card">
        <text class="card-title">核心功能</text>
        <view class="feature-list">
          <view class="feature-item">· 在线订货，实时库存</view>
          <view class="feature-item">· 智能派单，路线规划</view>
          <view class="feature-item">· 电子签收，多方式核销</view>
          <view class="feature-item">· 空桶管理，押金追踪</view>
          <view class="feature-item">· 对账管理，月度结算</view>
        </view>
      </view>
      <view class="card">
        <text class="card-title">联系方式</text>
        <text class="card-content">客服电话：400-888-8888</text>
        <text class="card-content">客服邮箱：support@water-oms.com</text>
        <text class="card-content">工作时间：周一至周日 9:00-18:00</text>
      </view>
      <view class="footer">
        <text>© 2026 订水平台 · All Rights Reserved</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
</script>

<style lang="scss" scoped>
.page {
  min-height: 100vh;
  background: $bg-color;
  padding: 24rpx;
}
.header {
  background: linear-gradient(135deg, $primary-color 0%, #4096ff 100%);
  padding: 80rpx 32rpx;
  text-align: center;
  border-radius: 24rpx;
  margin-bottom: 24rpx;
  .logo-icon { font-size: 100rpx; display: block; }
  .title { font-size: 44rpx; font-weight: 700; color: #fff; display: block; margin-top: 16rpx; }
  .version { font-size: 24rpx; color: rgba(255, 255, 255, 0.8); display: block; margin-top: 8rpx; }
}
.card {
  background: #fff;
  border-radius: 16rpx;
  padding: 24rpx;
  margin-bottom: 16rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
  .card-title { font-size: 30rpx; font-weight: 600; color: #1f2937; display: block; margin-bottom: 12rpx; }
  .card-content { font-size: 26rpx; color: #4b5563; line-height: 1.7; display: block; }
  .feature-list { margin-top: 8rpx; }
  .feature-item { font-size: 26rpx; color: #4b5563; line-height: 2; display: block; }
}
.footer {
  text-align: center;
  color: #9ca3af;
  font-size: 22rpx;
  padding: 32rpx 0;
}
</style>
