<template>
  <div class="apply-container">
    <el-page-header @back="goBack" class="mb-4">
      <template #content>
        <div class="page-header-content">
          <span class="page-title">发起售后申请</span>
          <el-breadcrumb separator="/">
            <el-breadcrumb-item :to="{ path: '/station/after-sales' }">售后管理</el-breadcrumb-item>
            <el-breadcrumb-item>发起申请</el-breadcrumb-item>
          </el-breadcrumb>
        </div>
      </template>
    </el-page-header>

    <el-card shadow="never" class="apply-card">
      <template #header>
        <div class="card-header">
          <el-icon class="header-icon"><Headset /></el-icon>
          <div class="header-text">
            <h3 class="header-title">售后申请</h3>
            <p class="header-desc">提交售后申请，水厂将尽快处理</p>
          </div>
        </div>
      </template>

      <el-form :model="applyForm" label-width="120px" class="apply-form">
        <el-form-item label="关联订单" required>
          <el-select
            v-model="applyForm.orderId"
            placeholder="请选择订单"
            style="width: 100%"
            @change="handleOrderChange"
          >
            <el-option
              v-for="order in availableOrders"
              :key="order.id"
              :label="`${order.orderNo} - ${order.createdAt}`"
              :value="order.id"
            >
              <div class="order-option">
                <span>{{ order.orderNo }}</span>
                <span class="order-date">{{ order.createdAt }}</span>
              </div>
            </el-option>
          </el-select>
        </el-form-item>

        <el-form-item label="售后类型" required>
          <el-radio-group v-model="applyForm.type">
            <el-radio label="resupply">
              <el-icon class="type-icon orange"><Goods /></el-icon>
              <span>补货</span>
            </el-radio>
            <el-radio label="refund">
              <el-icon class="type-icon red"><Wallet /></el-icon>
              <span>退款</span>
            </el-radio>
            <el-radio label="return">
              <el-icon class="type-icon blue"><RefreshRight /></el-icon>
              <span>退货</span>
            </el-radio>
          </el-radio-group>
        </el-form-item>

        <el-form-item label="选择商品" required>
          <el-radio-group v-model="applyForm.productId" class="product-radio-group">
            <el-radio
              v-for="item in orderItems"
              :key="item.productId"
              :label="item.productId"
              :value="item.productId"
              border
              class="product-radio"
            >
              <div class="product-item">
                <div class="product-info">
                  <span class="product-name">{{ item.productName }}</span>
                  <span class="product-qty">已配送: {{ item.deliveredQty }}桶</span>
                </div>
                <el-tag size="small" type="info">{{ item.productSpec }}</el-tag>
              </div>
            </el-radio>
          </el-radio-group>
          <div v-if="orderItems.length === 0 && applyForm.orderId" class="empty-state">
            <el-icon class="empty-icon"><Box /></el-icon>
            <p>该订单暂无商品明细</p>
          </div>
          <div v-if="!applyForm.orderId" class="empty-state">
            <el-icon class="empty-icon"><ShoppingCart /></el-icon>
            <p>请先选择关联订单</p>
          </div>
        </el-form-item>

        <el-form-item label="售后数量" required>
          <el-input-number
            v-model="applyForm.quantity"
            :min="1"
            :max="99"
            style="width: 100%"
          />
        </el-form-item>

        <el-form-item label="原因说明" required>
          <el-input
            v-model="applyForm.reason"
            type="textarea"
            :rows="4"
            placeholder="请详细描述售后原因，以便水厂快速处理..."
            maxlength="300"
            show-word-limit
          />
        </el-form-item>

        <el-form-item label="图片凭证">
          <el-upload
            action="#"
            :auto-upload="false"
            :limit="3"
            :on-change="handleImageChange"
            list-type="picture-card"
            :on-preview="handlePictureCardPreview"
            :on-remove="handleImageRemove"
          >
            <el-icon><Plus /></el-icon>
          </el-upload>
          <div class="upload-tip">
            <el-icon><InfoFilled /></el-icon>
            <span>最多上传3张图片，支持 JPG、PNG 格式</span>
          </div>
        </el-form-item>

        <el-divider />

        <div class="info-box">
          <el-icon class="info-icon"><InfoFilled /></el-icon>
          <div class="info-content">
            <p class="info-title">温馨提示</p>
            <ul class="info-list">
              <li>1. 请确保填写的信息真实有效</li>
              <li>2. 售后申请提交后，水厂将在24小时内处理</li>
              <li>3. 如有疑问，可联系水厂客服</li>
            </ul>
          </div>
        </div>

        <div class="form-actions">
          <el-button @click="goBack">取消</el-button>
          <el-button type="primary" :loading="submitting" :disabled="!canSubmit" @click="handleSubmit">
            <el-icon v-if="!submitting"><Check /></el-icon>
            提交申请
          </el-button>
        </div>
      </el-form>
    </el-card>

    <el-dialog v-model="previewVisible">
      <img :src="previewUrl" alt="Preview" style="width: 100%;" />
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Plus, Check, Headset, Goods, Wallet, RefreshRight, Box, ShoppingCart, InfoFilled } from '@element-plus/icons-vue'
import { stationOwnerApi } from '@/api'

const router = useRouter()

const submitting = ref(false)
const loading = ref(false)
const previewVisible = ref(false)
const previewUrl = ref('')

const availableOrders = ref<any[]>([])
const orderItems = ref<any[]>([])

const applyForm = reactive({
  orderId: '',
  type: 'resupply',
  productId: '',
  quantity: 1,
  reason: '',
  images: [] as string[]
})

const canSubmit = computed(() => {
  return (
    applyForm.orderId &&
    applyForm.type &&
    applyForm.productId &&
    applyForm.quantity > 0 &&
    applyForm.reason &&
    applyForm.reason.trim().length > 0
  )
})

const goBack = () => {
  router.push('/station/after-sales')
}

const loadOrders = async () => {
  loading.value = true
  try {
    const res = await stationOwnerApi.getOrders({ page: 1, size: 100 })
    if (res && (res as any).data && Array.isArray((res as any).data)) {
      availableOrders.value = ((res as any).data).filter((order: any) =>
        ['completed', 'delivering', 'dispatched'].includes(order.status)
      ).map((order: any) => ({
        id: order.id,
        orderNo: order.orderNo,
        createdAt: order.createdAt
      }))
    }
  } catch (error) {
    console.error('获取订单列表失败:', error)
    ElMessage.error('获取订单列表失败')
  } finally {
    loading.value = false
  }
}

const handleOrderChange = async (orderId: string) => {
  applyForm.productId = ''
  orderItems.value = []

  if (!orderId) return

  try {
    const res = await stationOwnerApi.getOrderById(orderId)
    const data = (res as any).data
    if (data && data.items) {
      orderItems.value = data.items.map((item: any) => ({
        productId: item.productId,
        productName: item.productName || item.name,
        productSpec: item.spec || '-',
        deliveredQty: item.quantity || item.deliveredQty || 0
      }))
    }
  } catch (error) {
    console.error('获取订单详情失败:', error)
    ElMessage.error('获取订单详情失败')
  }
}

const handleImageChange = (file: any) => {
  const reader = new FileReader()
  reader.onload = (e) => {
    if (e.target?.result) {
      applyForm.images.push(e.target.result as string)
    }
  }
  reader.readAsDataURL(file.raw)
}

const handleImageRemove = (file: any) => {
  const index = applyForm.images.indexOf(file.url)
  if (index > -1) {
    applyForm.images.splice(index, 1)
  }
}

const handlePictureCardPreview = (file: any) => {
  previewUrl.value = file.url
  previewVisible.value = true
}

const handleSubmit = async () => {
  if (!canSubmit.value) {
    ElMessage.warning('请完善售后申请信息')
    return
  }

  submitting.value = true

  try {
    await stationOwnerApi.createAfterSales({
      orderId: applyForm.orderId,
      type: applyForm.type,
      productId: applyForm.productId,
      quantity: applyForm.quantity,
      reason: applyForm.reason,
      images: applyForm.images
    } as any)

    ElMessage.success('售后申请提交成功')
    router.push('/station/after-sales')
  } catch (error) {
    console.error('提交售后申请失败:', error)
    ElMessage.error('提交售后申请失败，请重试')
  } finally {
    submitting.value = false
  }
}

onMounted(() => {
  loadOrders()
})
</script>

<style scoped>
.apply-container {
  padding: 20px;
}

.mb-4 {
  margin-bottom: 16px;
}

.page-header-content {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.page-title {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
}

.apply-card {
  max-width: 800px;
}

.card-header {
  display: flex;
  align-items: center;
  gap: 12px;
}

.header-icon {
  font-size: 32px;
  color: #409eff;
  background: #ecf5ff;
  padding: 12px;
  border-radius: 12px;
}

.header-title {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
  margin: 0 0 4px 0;
}

.header-desc {
  font-size: 12px;
  color: #909399;
  margin: 0;
}

.apply-form {
  padding: 0 20px;
}

.order-option {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.order-date {
  font-size: 12px;
  color: #909399;
}

.type-icon {
  margin-right: 4px;
}

.type-icon.orange {
  color: #e6a23c;
}

.type-icon.red {
  color: #f56c6c;
}

.type-icon.blue {
  color: #409eff;
}

.product-radio-group {
  display: flex;
  flex-direction: column;
  gap: 12px;
  width: 100%;
}

.product-radio {
  width: 100%;
  margin-right: 0;
}

.product-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
  width: 100%;
}

.product-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.product-name {
  font-weight: 600;
}

.product-qty {
  font-size: 12px;
  color: #909399;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 0;
  color: #909399;
}

.empty-icon {
  font-size: 48px;
  margin-bottom: 8px;
}

.upload-tip {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 8px;
  color: #909399;
  font-size: 12px;
}

.info-box {
  display: flex;
  gap: 16px;
  padding: 16px;
  background: #ecf5ff;
  border-radius: 12px;
}

.info-icon {
  color: #409eff;
  font-size: 20px;
}

.info-content {
  flex: 1;
}

.info-title {
  font-weight: 600;
  color: #303133;
  margin: 0 0 8px 0;
}

.info-list {
  margin: 0;
  padding-left: 20px;
  color: #606266;
  font-size: 14px;
  line-height: 1.8;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 16px;
  padding-top: 24px;
}

:deep(.el-radio.is-bordered) {
  width: 100%;
  margin-right: 0;
}

:deep(.el-radio__label) {
  flex: 1;
  display: flex;
  align-items: center;
}
</style>
