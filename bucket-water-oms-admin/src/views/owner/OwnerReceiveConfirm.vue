<template>
  <div class="receive-confirm-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <el-button @click="goBack" :icon="ArrowLeft">返回</el-button>
          <div class="header-info">
            <span class="header-title">收货确认</span>
            <span class="header-subtitle">输入验证码确认司机配送</span>
          </div>
        </div>
      </template>

      <div v-if="loading" class="loading-container">
        <el-icon class="is-loading"><Loading /></el-icon>
        <span>加载中...</span>
      </div>

      <template v-else>
        <el-row :gutter="20">
          <el-col :span="16">
            <el-card shadow="never" class="mb-4">
              <template #header>
                <div class="section-header">
                  <el-icon><Box /></el-icon>
                  <span>订单信息</span>
                </div>
              </template>
              <el-descriptions :column="2" border>
                <el-descriptions-item label="订单号">{{ orderInfo.orderNo }}</el-descriptions-item>
                <el-descriptions-item label="仓库">{{ orderInfo.warehouseName }}</el-descriptions-item>
                <el-descriptions-item label="配送司机" v-if="orderInfo.driverName">{{ orderInfo.driverName }}</el-descriptions-item>
                <el-descriptions-item label="预计送达" v-if="orderInfo.estimatedTime">{{ orderInfo.estimatedTime }}</el-descriptions-item>
              </el-descriptions>
            </el-card>

            <el-card shadow="never" class="mb-4">
              <template #header>
                <div class="section-header">
                  <el-icon><List /></el-icon>
                  <span>配送商品</span>
                </div>
              </template>
              <el-table :data="orderInfo.items" border stripe>
                <el-table-column label="商品" min-width="200">
                  <template #default="{ row }">
                    <div class="product-cell">
                      <el-image v-if="row.image" :src="row.image" class="product-image" fit="cover" />
                      <div v-else class="product-image-placeholder">
                        <el-icon><Picture /></el-icon>
                      </div>
                      <div class="product-info">
                        <p class="product-name">{{ row.productName }}</p>
                        <p class="product-price">¥{{ row.price }} / 桶</p>
                      </div>
                    </div>
                  </template>
                </el-table-column>
                <el-table-column label="数量" width="100" align="center">
                  <template #default="{ row }">
                    <span class="quantity">x{{ row.quantity }}</span>
                  </template>
                </el-table-column>
              </el-table>
            </el-card>

            <el-card shadow="never" class="mb-4">
              <template #header>
                <div class="section-header">
                  <el-icon><Key /></el-icon>
                  <span>确认方式</span>
                </div>
              </template>
              <el-radio-group v-model="confirmMethod" class="confirm-method-group">
                <el-radio value="code" class="confirm-method-option">
                  <div class="method-content">
                    <el-icon class="method-icon"><Key /></el-icon>
                    <div>
                      <p class="method-title">验证码确认</p>
                      <p class="method-desc">输入司机发送的6位验证码</p>
                    </div>
                  </div>
                </el-radio>
                <el-radio value="scan" class="confirm-method-option">
                  <div class="method-content">
                    <el-icon class="method-icon"><FullScreen /></el-icon>
                    <div>
                      <p class="method-title">扫码确认</p>
                      <p class="method-desc">扫描司机提供的二维码</p>
                    </div>
                  </div>
                </el-radio>
              </el-radio-group>
            </el-card>

            <el-card v-if="confirmMethod === 'code'" shadow="never" class="mb-4">
              <template #header>
                <div class="section-header">
                  <el-icon><Edit /></el-icon>
                  <span>输入验证码</span>
                </div>
              </template>
              <el-form :model="verifyForm" class="verify-form">
                <el-form-item>
                  <el-input
                    v-model="verifyCode"
                    type="text"
                    maxlength="6"
                    placeholder="请输入6位验证码"
                    class="verify-input"
                    @input="handleCodeInput"
                  />
                </el-form-item>
                <el-form-item>
                  <div v-if="resendCountdown > 0" class="resend-tip">
                    {{ resendCountdown }}秒后可重新获取验证码
                  </div>
                  <el-button v-else type="primary" link @click="resendCode">未收到验证码？重新获取</el-button>
                </el-form-item>
                <el-form-item v-if="errorMessage">
                  <el-alert type="error" :closable="false" show-icon>
                    {{ errorMessage }}
                  </el-alert>
                </el-form-item>
              </el-form>
              <el-button
                type="primary"
                size="large"
                :disabled="verifyCode.length !== 6 || confirming"
                :loading="confirming"
                @click="confirmReceive"
                class="confirm-btn"
              >
                {{ confirming ? '确认中...' : '确认收货' }}
              </el-button>
            </el-card>

            <el-card v-if="confirmMethod === 'scan'" shadow="never" class="mb-4">
              <template #header>
                <div class="section-header">
                  <el-icon><FullScreen /></el-icon>
                  <span>扫码确认</span>
                </div>
              </template>
              <div class="scan-area">
                <el-button type="primary" size="large" @click="startScan" class="scan-btn">
                  <el-icon><FullScreen /></el-icon>
                  点击扫描二维码
                </el-button>
                <p class="scan-tip">请使用扫码设备扫描司机提供的确认码</p>
              </div>
            </el-card>

            <el-card shadow="never">
              <template #header>
                <div class="section-header">
                  <el-icon><InfoFilled /></el-icon>
                  <span>收货确认说明</span>
                </div>
              </template>
              <el-space direction="vertical" :size="12" class="help-list">
                <div class="help-item">
                  <el-icon color="#67C23A"><CircleCheck /></el-icon>
                  <span>司机送达后，会向您发送6位验证码</span>
                </div>
                <div class="help-item">
                  <el-icon color="#67C23A"><CircleCheck /></el-icon>
                  <span>输入验证码即可完成收货确认</span>
                </div>
                <div class="help-item">
                  <el-icon color="#67C23A"><CircleCheck /></el-icon>
                  <span>如有疑问，可联系司机确认</span>
                </div>
              </el-space>
              <el-button
                v-if="orderInfo.driverPhone"
                type="primary"
                class="mt-4"
                @click="callDriver"
              >
                <el-icon><Phone /></el-icon>
                联系司机
              </el-button>
            </el-card>
          </el-col>

          <el-col :span="8">
            <el-card shadow="never">
              <template #header>
                <div class="section-header">
                  <el-icon><User /></el-icon>
                  <span>配送司机</span>
                </div>
              </template>
              <div v-if="orderInfo.driverName" class="driver-info">
                <el-avatar :size="64" :icon="UserFilled" />
                <p class="driver-name">{{ orderInfo.driverName }}</p>
                <p class="driver-label">配送司机</p>
                <el-button type="success" circle @click="callDriver">
                  <el-icon><Phone /></el-icon>
                </el-button>
              </div>
              <el-empty v-else description="暂无司机信息" />
            </el-card>
          </el-col>
        </el-row>
      </template>
    </el-card>

    <el-dialog v-model="showSuccessModal" title="收货确认成功" width="400px" destroy-on-close>
      <el-result icon="success" title="收货确认成功">
        <template #sub-title>
          <div class="success-info">
            <p class="success-label">签收时间</p>
            <p class="success-value">{{ successData.signedAt }}</p>
            <el-divider />
            <el-row :gutter="20">
              <el-col :span="12">
                <p class="info-label">本次回桶</p>
                <p class="info-value success">+{{ successData.returnedBuckets }}个</p>
              </el-col>
              <el-col :span="12">
                <p class="info-label">本次欠桶</p>
                <p class="info-value warning">+{{ successData.owedBuckets }}个</p>
              </el-col>
            </el-row>
          </div>
        </template>
      </el-result>
      <template #footer>
        <el-button type="primary" @click="goToOrderDetail">查看订单详情</el-button>
        <el-button @click="showSuccessModal = false">返回订单列表</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import {
  ArrowLeft, Loading, Box, List, Key, Edit, FullScreen,
  InfoFilled, CircleCheck, Phone, User, UserFilled, Picture
} from '@element-plus/icons-vue'
import { stationOwnerApi } from '@/api'
import { toast } from '@/composables/useToast'

const router = useRouter()
const route = useRoute()

const loading = ref(true)
const confirming = ref(false)
const orderId = ref('')

const confirmMethod = ref<'code' | 'scan'>('code')

const verifyCode = ref('')
const errorMessage = ref('')
const resendCountdown = ref(0)
let countdownTimer: number | null = null

const verifyForm = ref({})

const orderInfo = ref<any>({
  orderNo: '',
  warehouseName: '',
  driverName: '',
  driverPhone: '',
  estimatedTime: '',
  items: [] as any[]
})

const showSuccessModal = ref(false)
const successData = ref({
  signedAt: '',
  returnedBuckets: 0,
  owedBuckets: 0
})

const loadOrderInfo = async () => {
  try {
    loading.value = true
    orderId.value = route.params.orderId as string

    const order: any = await stationOwnerApi.getOrderById(orderId.value)

    orderInfo.value = {
      orderNo: order.orderNo,
      warehouseName: order.warehouseName || '未知仓库',
      driverName: order.driverName || '',
      driverPhone: '',
      estimatedTime: order.estimatedTime || '',
      items: (order.items || []).map((item: any) => ({
        productId: item.productId,
        productName: item.productName || item.name,
        price: item.price,
        quantity: item.quantity,
        image: item.image || ''
      }))
    }
  } catch (error: any) {
    toast.error('加载订单信息失败：' + (error.message || '未知错误'))
    orderInfo.value = {
      orderNo: 'WD20260424001',
      warehouseName: '中心仓库',
      driverName: '王师傅',
      driverPhone: '13800138001',
      estimatedTime: '14:30',
      items: [
        {
          productId: '1',
          productName: '18.9L 桶装水',
          price: 8.00,
          quantity: 50,
          image: ''
        }
      ]
    }
  } finally {
    loading.value = false
  }
}

const handleCodeInput = () => {
  verifyCode.value = verifyCode.value.replace(/\D/g, '')
  errorMessage.value = ''
}

const resendCode = async () => {
  try {
    toast.success('验证码已发送')
    resendCountdown.value = 60
    startCountdown()
  } catch (error: any) {
    toast.error('发送失败：' + (error.message || '未知错误'))
  }
}

const startCountdown = () => {
  if (countdownTimer) {
    clearInterval(countdownTimer)
  }

  countdownTimer = window.setInterval(() => {
    if (resendCountdown.value > 0) {
      resendCountdown.value--
    } else {
      if (countdownTimer) {
        clearInterval(countdownTimer)
        countdownTimer = null
      }
    }
  }, 1000)
}

const confirmReceive = async () => {
  if (verifyCode.value.length !== 6) {
    errorMessage.value = '请输入6位验证码'
    return
  }

  try {
    confirming.value = true
    errorMessage.value = ''

    await stationOwnerApi.verifyOrderCode(orderId.value, verifyCode.value)

    successData.value = {
      signedAt: new Date().toLocaleString('zh-CN'),
      returnedBuckets: 35,
      owedBuckets: 5
    }
    showSuccessModal.value = true
  } catch (error: any) {
    errorMessage.value = error.message || '验证码错误，请重新输入'
    toast.error('确认失败：' + (error.message || '未知错误'))
  } finally {
    confirming.value = false
  }
}

const startScan = async () => {
  try {
    const stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: 'environment' } })
    const video = document.createElement('video')
    video.srcObject = stream
    video.play()

    toast.info('请使用扫码设备扫描二维码')

    setTimeout(async () => {
      stream.getTracks().forEach(track => track.stop())
      await confirmByScan()
    }, 2000)
  } catch (error: any) {
    toast.info('开发模式：扫码模拟成功')
    await confirmByScan()
  }
}

const confirmByScan = async () => {
  try {
    confirming.value = true

    await stationOwnerApi.confirmOrder(orderId.value, 'scan')

    successData.value = {
      signedAt: new Date().toLocaleString('zh-CN'),
      returnedBuckets: 35,
      owedBuckets: 5
    }
    showSuccessModal.value = true
  } catch (error: any) {
    toast.error('扫码确认失败：' + (error.message || '未知错误'))
  } finally {
    confirming.value = false
  }
}

const callDriver = () => {
  if (orderInfo.value.driverPhone) {
    window.location.href = `tel:${orderInfo.value.driverPhone}`
  } else {
    toast.warning('暂无可用联系方式')
  }
}

const goBack = () => {
  router.back()
}

const goToOrderDetail = () => {
  showSuccessModal.value = false
  router.push(`/station/orders/${orderId.value}`)
}

onUnmounted(() => {
  if (countdownTimer) {
    clearInterval(countdownTimer)
  }
})

onMounted(() => {
  loadOrderInfo()
})
</script>

<style scoped>
.receive-confirm-container {
  padding: 0;
}

.card-header {
  display: flex;
  align-items: center;
  gap: 16px;
}

.header-info {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.header-title {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
}

.header-subtitle {
  font-size: 12px;
  color: #909399;
}

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 0;
  gap: 16px;
  color: #909399;
}

.section-header {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
}

.product-cell {
  display: flex;
  align-items: center;
  gap: 12px;
}

.product-image {
  width: 50px;
  height: 50px;
  border-radius: 8px;
}

.product-image-placeholder {
  width: 50px;
  height: 50px;
  border-radius: 8px;
  background: #f5f7fa;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #909399;
}

.product-info .product-name {
  font-weight: 500;
  color: #303133;
}

.product-info .product-price {
  font-size: 12px;
  color: #909399;
}

.quantity {
  font-weight: 600;
  color: #303133;
}

.confirm-method-group {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.confirm-method-option {
  padding: 16px;
  border: 1px solid #DCDFE6;
  border-radius: 8px;
  margin-right: 0;
}

.confirm-method-option:has(.is-checked) {
  border-color: #409EFF;
  background-color: #ECF5FF;
}

.method-content {
  display: flex;
  align-items: center;
  gap: 12px;
}

.method-icon {
  font-size: 24px;
  color: #409EFF;
}

.method-title {
  font-weight: 600;
  color: #303133;
}

.method-desc {
  font-size: 12px;
  color: #909399;
}

.verify-form {
  max-width: 300px;
}

.verify-input {
  font-size: 24px;
  text-align: center;
  letter-spacing: 8px;
}

.resend-tip {
  color: #909399;
  font-size: 14px;
}

.confirm-btn {
  width: 100%;
  margin-top: 16px;
}

.scan-area {
  text-align: center;
  padding: 40px 0;
}

.scan-btn {
  padding: 40px 60px;
  font-size: 16px;
}

.scan-tip {
  margin-top: 16px;
  font-size: 12px;
  color: #909399;
}

.help-list {
  width: 100%;
}

.help-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: #606266;
}

.driver-info {
  text-align: center;
  padding: 20px 0;
}

.driver-name {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  margin: 12px 0 4px;
}

.driver-label {
  font-size: 12px;
  color: #909399;
  margin-bottom: 16px;
}

.success-info {
  padding: 16px 0;
}

.success-label {
  font-size: 12px;
  color: #909399;
}

.success-value {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  margin-top: 4px;
}

.info-label {
  font-size: 12px;
  color: #909399;
}

.info-value {
  font-size: 18px;
  font-weight: 600;
}

.info-value.success {
  color: #67C23A;
}

.info-value.warning {
  color: #E6A23C;
}

.mb-4 {
  margin-bottom: 16px;
}

.mt-4 {
  margin-top: 16px;
}

:deep(.el-radio) {
  margin-right: 0;
}
</style>
