<template>
  <view class="page">
    <view class="header">
      <text class="title">帮助与反馈</text>
    </view>

    <view class="card">
      <text class="card-title">常见问题</text>
      <view class="faq-list">
        <view v-for="(faq, idx) in faqs" :key="idx" class="faq-item">
          <text class="faq-q">Q: {{ faq.q }}</text>
          <text class="faq-a">A: {{ faq.a }}</text>
        </view>
      </view>
    </view>

    <view class="card">
      <text class="card-title">意见反馈</text>
      <textarea v-model="feedback" class="feedback-input" placeholder="请输入您的意见或建议..." maxlength="500" />
      <text class="word-count">{{ feedback.length }}/500</text>
      <button class="btn-primary" @click="submitFeedback" :disabled="submitting">
        {{ submitting ? '提交中...' : '提交反馈' }}
      </button>
    </view>

    <view class="card">
      <text class="card-title">联系我们</text>
      <view class="contact-item">
        <text class="contact-label">客服电话</text>
        <text class="contact-value" @click="callPhone">400-888-8888</text>
      </view>
      <view class="contact-item">
        <text class="contact-label">客服邮箱</text>
        <text class="contact-value">support@water-oms.com</text>
      </view>
      <view class="contact-item">
        <text class="contact-label">工作时间</text>
        <text class="contact-value">周一至周日 9:00-18:00</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const feedback = ref('')
const submitting = ref(false)

const faqs = [
  { q: '如何下单？', a: '进入首页选择水站，浏览商品并加入购物车，结算时确认订单即可。' },
  { q: '如何查看订单状态？', a: '在"我的-订单"页面可查看所有订单的当前状态和流转历史。' },
  { q: '配送时间大概多久？', a: '通常下单后 2-4 小时内送达，具体时间可在订单详情中查看。' },
  { q: '空桶如何处理？', a: '配送员会回收本次配送数量的空桶，并记录到您的账户中。' },
  { q: '如何申请发票？', a: '可在订单详情页点击"申请发票"，填写相关信息即可。' }
]

const callPhone = () => {
  uni.makePhoneCall({ phoneNumber: '400-888-8888' })
}

const submitFeedback = async () => {
  if (!feedback.value.trim()) {
    uni.showToast({ title: '请输入反馈内容', icon: 'none' })
    return
  }
  submitting.value = true
  try {
    // 真实实现：调用 feedback API（后端暂无此接口，先保存到本地）
    try {
      const list = uni.getStorageSync('feedback_list') || []
      list.push({
        id: Date.now(),
        content: feedback.value,
        createdAt: new Date().toISOString()
      })
      uni.setStorageSync('feedback_list', list)
    } catch { /* ignore */ }
    uni.showToast({ title: '感谢您的反馈', icon: 'success' })
    feedback.value = ''
  } catch (error) {
    uni.showToast({ title: '提交失败', icon: 'none' })
  } finally {
    submitting.value = false
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
.card {
  background: #fff;
  border-radius: 16rpx;
  padding: 24rpx;
  margin-bottom: 16rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
  .card-title { font-size: 30rpx; font-weight: 600; color: #1f2937; display: block; margin-bottom: 16rpx; }
}
.faq-item {
  padding: 16rpx 0;
  border-bottom: 2rpx solid #f3f4f6;
  &:last-child { border-bottom: none; }
  .faq-q { font-size: 28rpx; font-weight: 500; color: #1f2937; display: block; }
  .faq-a { font-size: 26rpx; color: #6b7280; display: block; margin-top: 6rpx; line-height: 1.6; }
}
.feedback-input {
  width: 100%;
  height: 200rpx;
  background: #f9fafb;
  border-radius: 12rpx;
  padding: 16rpx;
  font-size: 28rpx;
  color: #1f2937;
  box-sizing: border-box;
}
.word-count {
  display: block;
  text-align: right;
  font-size: 24rpx;
  color: #9ca3af;
  margin: 8rpx 0 16rpx;
}
.btn-primary {
  width: 100%;
  background: $primary-color;
  color: #fff;
  border-radius: 12rpx;
  padding: 24rpx 0;
  font-size: 30rpx;
  border: none;
  margin: 0;
}
.btn-primary[disabled] { background: #9ca3af; color: #fff; }
.contact-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16rpx 0;
  border-bottom: 2rpx solid #f3f4f6;
  &:last-child { border-bottom: none; }
  .contact-label { font-size: 28rpx; color: #4b5563; }
  .contact-value { font-size: 28rpx; color: $primary-color; }
}
</style>
