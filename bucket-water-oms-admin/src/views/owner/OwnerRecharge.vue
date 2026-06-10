<template>
  <div class="recharge-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span>账户充值</span>
        </div>
      </template>

      <div v-if="loading" class="loading-container">
        <el-icon class="is-loading"><Loading /></el-icon>
        <span>加载中...</span>
      </div>

      <el-row v-else :gutter="20">
        <el-col :span="16">
          <el-row :gutter="16" class="mb-4">
            <el-col :span="8">
              <el-statistic title="总额度" :value="accountInfo.creditLimit" prefix="¥" :precision="2" />
            </el-col>
            <el-col :span="8">
              <el-statistic title="剩余额度" :value="accountInfo.availableCredit" prefix="¥" :precision="2" />
              <div class="stat-sub">已用 ¥{{ accountInfo.usedCredit }}</div>
            </el-col>
            <el-col :span="8">
              <el-statistic title="预存金余额" :value="accountInfo.depositBalance" prefix="¥" :precision="2" />
              <div class="stat-sub">账期: {{ accountInfo.billingCycle }}</div>
            </el-col>
          </el-row>

          <el-divider />

          <el-card shadow="never" class="mb-4">
            <template #header>
              <div class="section-header">
                <el-icon><Money /></el-icon>
                <span>选择充值金额</span>
              </div>
            </template>
            <el-radio-group v-model="selectedAmount" class="amount-group">
              <el-radio-button v-for="amount in presetAmounts" :key="amount" :value="amount">
                ¥{{ amount }}
              </el-radio-button>
            </el-radio-group>
            <div class="custom-amount mt-4">
              <span class="label">自定义金额</span>
              <el-input-number v-model="customAmount" :min="0" :precision="2" :step="100" />
            </div>
          </el-card>

          <el-card shadow="never" class="mb-4">
            <template #header>
              <div class="section-header">
                <el-icon><Wallet /></el-icon>
                <span>优惠信息</span>
              </div>
            </template>
            <el-alert type="success" :closable="false" show-icon>
              <template #title>
                <div class="promotion-info">
                  <p><strong>充值优惠活动</strong></p>
                  <ul>
                    <li>充值满1000元，赠送50元</li>
                    <li>充值满5000元，赠送300元</li>
                    <li>充值满10000元，赠送800元</li>
                  </ul>
                </div>
              </template>
            </el-alert>
          </el-card>

          <el-card shadow="never" class="mb-4">
            <template #header>
              <div class="section-header">
                <el-icon><Coin /></el-icon>
                <span>充值明细</span>
              </div>
            </template>
            <el-descriptions :column="1" border>
              <el-descriptions-item label="充值金额">
                <span class="amount-value">¥{{ rechargeAmount.toFixed(2) }}</span>
              </el-descriptions-item>
              <el-descriptions-item label="赠送金额">
                <span class="gift-value">+¥{{ giftAmount.toFixed(2) }}</span>
              </el-descriptions-item>
              <el-descriptions-item label="实际到账">
                <span class="total-value">¥{{ actualAmount.toFixed(2) }}</span>
              </el-descriptions-item>
            </el-descriptions>
          </el-card>

          <el-card shadow="never" class="mb-4">
            <template #header>
              <div class="section-header">
                <el-icon><CreditCard /></el-icon>
                <span>选择支付方式</span>
              </div>
            </template>
            <el-radio-group v-model="paymentMethod" class="payment-group">
              <el-radio value="wechat" class="payment-option">
                <div class="payment-content">
                  <el-icon class="payment-icon" color="#07C160"><ChatDotRound /></el-icon>
                  <span>微信支付</span>
                </div>
              </el-radio>
              <el-radio value="alipay" class="payment-option">
                <div class="payment-content">
                  <el-icon class="payment-icon" color="#1677FF"><Shop /></el-icon>
                  <span>支付宝</span>
                </div>
              </el-radio>
              <el-radio value="bankcard" class="payment-option">
                <div class="payment-content">
                  <el-icon class="payment-icon" color="#409EFF"><CreditCard /></el-icon>
                  <span>银行卡</span>
                </div>
              </el-radio>
            </el-radio-group>
          </el-card>

          <el-card shadow="never" class="mb-4">
            <template #header>
              <div class="section-header">
                <el-icon><InfoFilled /></el-icon>
                <span>温馨提示</span>
              </div>
            </template>
            <el-alert type="info" :closable="false" show-icon>
              <template #default>
                <div class="tips">
                  <p>如需充值预存金，请联系水厂进行处理。</p>
                  <p>水厂工作人员将为您提供充值服务。</p>
                </div>
              </template>
            </el-alert>
          </el-card>

          <div class="action-section">
            <el-button type="primary" size="large" :disabled="rechargeAmount <= 0" @click="handleRecharge">
              立即充值 ¥{{ rechargeAmount.toFixed(2) }}
            </el-button>
          </div>
        </el-col>

        <el-col :span="8">
          <el-card shadow="never" class="info-card">
            <template #header>
              <div class="section-header white">
                <el-icon><Phone /></el-icon>
                <span>联系水厂</span>
              </div>
            </template>
            <el-descriptions :column="1" border class="info-descriptions">
              <el-descriptions-item label="水厂名称">
                {{ stationInfo.warehouseName || '水厂客服中心' }}
              </el-descriptions-item>
              <el-descriptions-item label="联系电话">
                {{ stationInfo.warehousePhone || '400-XXX-XXXX' }}
              </el-descriptions-item>
              <el-descriptions-item label="服务时间">
                周一至周六 9:00-18:00
              </el-descriptions-item>
            </el-descriptions>
            <div class="action-buttons mt-4">
              <el-button type="primary" @click="handleCopyPhone">
                <el-icon><DocumentCopy /></el-icon>
                复制电话
              </el-button>
              <el-button type="success" @click="handleCallPhone">
                <el-icon><Phone /></el-icon>
                拨打电话
              </el-button>
            </div>
          </el-card>

          <el-card shadow="never" class="mt-4">
            <template #header>
              <div class="section-header">
                <el-icon><QuestionFilled /></el-icon>
                <span>常见问题</span>
              </div>
            </template>
            <el-collapse>
              <el-collapse-item title="如何进行充值？" name="1">
                <p>您可以通过以下方式联系水厂进行充值：</p>
                <ul class="list-disc">
                  <li>拨打水厂客服电话</li>
                  <li>添加水厂客服微信</li>
                  <li>前往水厂营业厅办理</li>
                </ul>
              </el-collapse-item>
              <el-collapse-item title="充值后多久到账？" name="2">
                <p>转账成功后，一般在1-2个工作日内到账。如有疑问请随时联系水厂客服。</p>
              </el-collapse-item>
              <el-collapse-item title="支持哪些支付方式？" name="3">
                <p>水厂支持以下支付方式：</p>
                <ul class="list-disc">
                  <li>银行转账</li>
                  <li>微信支付</li>
                  <li>支付宝</li>
                  <li>现金支付（仅限营业厅）</li>
                </ul>
              </el-collapse-item>
              <el-collapse-item title="充值有优惠吗？" name="4">
                <p>具体优惠政策请咨询水厂客服，不同充值金额可能有不同的优惠方案。</p>
              </el-collapse-item>
            </el-collapse>
          </el-card>
        </el-col>
      </el-row>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import {
  Loading, Money, Wallet, Coin, CreditCard, Phone, DocumentCopy,
  ChatDotRound, Shop, InfoFilled, QuestionFilled
} from '@element-plus/icons-vue'
import { stationOwnerApi } from '@/api'

const loading = ref(true)
const presetAmounts = [500, 1000, 2000, 5000, 10000]
const selectedAmount = ref(1000)
const customAmount = ref(0)

const accountInfo = reactive({
  depositBalance: 0,
  creditLimit: 0,
  usedCredit: 0,
  availableCredit: 0,
  paymentType: '月结',
  billingCycle: '30天'
})

const stationInfo = reactive({
  warehouseName: '',
  warehousePhone: '400-XXX-XXXX'
})

const paymentMethod = ref('wechat')

const rechargeAmount = computed(() => {
  return customAmount.value > 0 ? customAmount.value : selectedAmount.value
})

const giftAmount = computed(() => {
  const amount = rechargeAmount.value
  if (amount >= 10000) return 800
  if (amount >= 5000) return 300
  if (amount >= 1000) return 50
  return 0
})

const actualAmount = computed(() => {
  return rechargeAmount.value + giftAmount.value
})

const loadDashboard = async () => {
  try {
    loading.value = true
    const res = await stationOwnerApi.getDashboard()
    if (res && (res as any).data) {
      const data = (res as any).data
      accountInfo.depositBalance = Number(data.accountBalance) || 0
      accountInfo.creditLimit = Number(data.creditLimit) || 0
      accountInfo.usedCredit = Number(data.usedCredit) || 0
      accountInfo.availableCredit = Number(data.availableCredit) || 0
    }
  } catch (error: any) {
    console.error('加载账户信息失败:', error)
  } finally {
    loading.value = false
  }
}

const loadStationInfo = async () => {
  try {
    const res = await stationOwnerApi.getInventory()
    const data = (res as any).data
    if (data?.warehouses?.length > 0) {
      stationInfo.warehouseName = data.warehouses[0].warehouseName || '水厂'
    }
  } catch (error: any) {
    console.error('加载水站信息失败:', error)
  }
}

const handleCopyPhone = async () => {
  try {
    await navigator.clipboard.writeText(stationInfo.warehousePhone)
    ElMessage.success('电话号码已复制到剪贴板')
  } catch (error) {
    ElMessage.error('复制失败，请手动复制')
  }
}

const handleCallPhone = () => {
  window.location.href = `tel:${stationInfo.warehousePhone}`
}

const handleRecharge = () => {
  ElMessage.info('充值功能开发中，请联系水厂进行充值')
}

onMounted(() => {
  loadDashboard()
  loadStationInfo()
})
</script>

<style scoped>
.recharge-container {
  padding: 0;
}

.card-header {
  font-weight: 600;
  font-size: 16px;
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
  font-weight: 500;
}

.section-header.white {
  color: white;
}

.stat-sub {
  margin-top: 8px;
  font-size: 12px;
  color: #909399;
}

.amount-group {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}

.custom-amount {
  display: flex;
  align-items: center;
  gap: 12px;
}

.custom-amount .label {
  font-size: 14px;
  color: #606266;
}

.promotion-info {
  padding: 8px 0;
}

.promotion-info p {
  margin: 0 0 8px;
}

.promotion-info ul {
  margin: 0;
  padding-left: 20px;
}

.promotion-info li {
  margin: 4px 0;
}

.tips p {
  margin: 4px 0;
}

.amount-value {
  font-size: 18px;
  font-weight: 600;
  color: #409EFF;
}

.gift-value {
  font-size: 16px;
  font-weight: 600;
  color: #67C23A;
}

.total-value {
  font-size: 20px;
  font-weight: 700;
  color: #409EFF;
}

.payment-group {
  display: flex;
  gap: 12px;
}

.payment-option {
  flex: 1;
  padding: 16px;
  border: 1px solid #DCDFE6;
  border-radius: 8px;
  margin-right: 0;
}

.payment-option:has(.is-checked) {
  border-color: #409EFF;
  background-color: #ECF5FF;
}

.payment-content {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.payment-icon {
  font-size: 20px;
}

.action-section {
  margin-top: 24px;
  text-align: center;
}

.action-section .el-button {
  min-width: 300px;
  height: 48px;
  font-size: 16px;
}

.info-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
}

.info-card :deep(.el-card__header) {
  background: transparent;
  border-bottom: 1px solid rgba(255, 255, 255, 0.2);
}

.info-card :deep(.el-card__body) {
  background: transparent;
}

.info-descriptions :deep(.el-descriptions__label) {
  background: rgba(255, 255, 255, 0.1);
  border-color: rgba(255, 255, 255, 0.2);
  color: white;
}

.info-descriptions :deep(.el-descriptions__content) {
  color: white;
  border-color: rgba(255, 255, 255, 0.2);
}

.action-buttons {
  display: flex;
  gap: 12px;
}

.action-buttons .el-button {
  flex: 1;
}

.mb-4 {
  margin-bottom: 16px;
}

.mt-4 {
  margin-top: 16px;
}

.list-disc {
  list-style-type: disc;
  padding-left: 20px;
  margin: 8px 0;
}

.list-disc li {
  margin: 4px 0;
}

:deep(.el-radio) {
  margin-right: 0;
}
</style>
