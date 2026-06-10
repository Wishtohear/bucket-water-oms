<template>
  <div class="statements-container">
    <el-row :gutter="20" class="mb-4">
      <el-col :span="6">
        <el-card shadow="hover">
          <el-statistic title="期末应收余额" :value="statementData.closingBalance">
            <template #prefix>
              <span class="price-prefix">¥</span>
            </template>
          </el-statistic>
          <div class="stat-sub">截止{{ currentMonth }}月{{ lastDay }}日</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <el-statistic title="期初余额" :value="statementData.openingBalance">
            <template #prefix>
              <span class="price-prefix">¥</span>
            </template>
          </el-statistic>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <el-statistic title="本月进货" :value="statementData.totalAmount">
            <template #prefix>
              <span class="price-prefix">¥</span>
            </template>
          </el-statistic>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <el-statistic title="本月回款" :value="statementData.paymentReceived">
            <template #prefix>
              <span class="price-prefix">¥</span>
            </template>
          </el-statistic>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" class="mb-4">
      <el-col :span="12">
        <el-card shadow="never">
          <template #header>
            <div class="card-header">
              <span>账户信息</span>
              <el-button link type="primary" @click="goToRecharge">充值</el-button>
            </div>
          </template>
          <el-descriptions :column="3" border>
            <el-descriptions-item label="总额度">
              <span class="price-text">¥{{ accountInfo.creditLimit }}</span>
            </el-descriptions-item>
            <el-descriptions-item label="剩余额度">
              <span class="price-text">¥{{ accountInfo.availableCredit }}</span>
            </el-descriptions-item>
            <el-descriptions-item label="欠桶数量">
              <span class="text-danger">{{ accountInfo.owedBucketNum }}个</span>
            </el-descriptions-item>
          </el-descriptions>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card shadow="never">
          <template #header>
            <div class="card-header">
              <span>账单状态</span>
              <el-tag v-if="currentStatement" :type="getStatusType(currentStatement.status)">
                {{ currentStatement.statusText }}
              </el-tag>
            </div>
          </template>
          <div v-if="currentStatement && currentStatement.status === 'pending'" class="alert-box">
            <el-alert
              title="请及时确认对账单"
              description="如对账单有疑问，请在3个工作日内联系水厂，逾期未确认将自动确认"
              type="warning"
              show-icon
              :closable="false"
            />
            <div class="action-buttons">
              <el-button type="primary" @click="handleConfirm" :loading="confirming">
                确认对账单无误
              </el-button>
              <el-button type="danger" @click="handleDispute">
                对账单有争议
              </el-button>
            </div>
          </div>
          <div v-else-if="currentStatement && currentStatement.status === 'confirmed'">
            <el-alert
              title="已确认"
              description="该月对账单已确认"
              type="success"
              show-icon
              :closable="false"
            />
          </div>
          <el-empty v-else description="暂无对账单" />
        </el-card>
      </el-col>
    </el-row>

    <el-card shadow="never" class="mb-4">
      <template #header>
        <div class="card-header">
          <span>对账月份选择</span>
          <el-space>
            <el-button @click="prevMonth" :icon="ArrowLeft">上月</el-button>
            <span class="month-label">{{ currentYear }}年{{ currentMonth }}月</span>
            <el-button @click="nextMonth" :icon="ArrowRight">下月</el-button>
          </el-space>
        </div>
      </template>
    </el-card>

    <el-card shadow="never" class="mb-4">
      <template #header>
        <div class="card-header">
          <span>进货明细</span>
          <el-button link type="primary">查看全部</el-button>
        </div>
      </template>
      <el-table :data="purchaseRecords" stripe v-loading="loading">
        <el-table-column prop="orderNo" label="订单号" width="180" />
        <el-table-column prop="product" label="商品" min-width="150" />
        <el-table-column label="金额" width="120">
          <template #default="{ row }">
            <span class="price-text">¥{{ row.amount }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="date" label="日期" width="180" />
        <el-table-column prop="paymentType" label="支付方式" width="120" />
      </el-table>
      <el-empty v-if="purchaseRecords.length === 0 && !loading" description="暂无进货记录" />
    </el-card>

    <el-row :gutter="20">
      <el-col :span="12">
        <el-card shadow="never">
          <template #header>
            <div class="card-header">
              <span>回款记录</span>
            </div>
          </template>
          <el-table :data="paymentRecords" stripe v-loading="loading">
            <el-table-column prop="type" label="类型" width="120" />
            <el-table-column label="金额" width="120">
              <template #default="{ row }">
                <span class="price-text text-success">+¥{{ row.amount }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="date" label="日期" width="180" />
          </el-table>
          <el-empty v-if="paymentRecords.length === 0 && !loading" description="暂无回款记录" />
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card shadow="never">
          <template #header>
            <div class="card-header">
              <span>空桶往来</span>
              <el-button link type="primary" @click="goToBuckets">查看详情</el-button>
            </div>
          </template>
          <el-descriptions :column="2" border>
            <el-descriptions-item label="本期回桶">
              <span class="text-success">+{{ bucketStats.return }}个</span>
            </el-descriptions-item>
            <el-descriptions-item label="本期欠桶">
              <span class="text-warning">+{{ bucketStats.owe }}个</span>
            </el-descriptions-item>
            <el-descriptions-item label="期末欠桶数量">
              <span class="text-danger">{{ bucketStats.closing }}个</span>
            </el-descriptions-item>
            <el-descriptions-item label="欠桶押金金额">
              <span class="price-text">¥{{ bucketStats.depositAmount }}</span>
            </el-descriptions-item>
            <el-descriptions-item label="押金桶总数">
              {{ bucketStats.total }}个
            </el-descriptions-item>
          </el-descriptions>
        </el-card>
      </el-col>
    </el-row>

  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, watch, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { ArrowLeft, ArrowRight } from '@element-plus/icons-vue'
import { stationOwnerApi } from '@/api'

const router = useRouter()

const loading = ref(true)
const confirming = ref(false)

const currentYear = ref(new Date().getFullYear())
const currentMonth = ref(new Date().getMonth() + 1)

const currentStatement = ref<any>(null)

const statementData = reactive({
  openingBalance: 0,
  totalAmount: 0,
  paymentReceived: 0,
  closingBalance: 0
})

const accountInfo = reactive({
  depositBalance: 0,
  creditLimit: 0,
  availableCredit: 0,
  owedBucketNum: 0
})

const purchaseRecords = ref<any[]>([])
const paymentRecords = ref<any[]>([])

const bucketStats = reactive({
  return: 0,
  owe: 0,
  closing: 0,
  depositAmount: 0,
  total: 0
})

const lastDay = computed(() => {
  return new Date(currentYear.value, currentMonth.value, 0).getDate()
})

const yearMonth = computed(() => {
  return `${currentYear.value}-${String(currentMonth.value).padStart(2, '0')}`
})

const getStatusType = (status: string) => {
  const typeMap: Record<string, string> = {
    pending: 'warning',
    confirmed: 'success',
    disputed: 'danger'
  }
  return typeMap[status] || 'info'
}

const getStatusText = (status: string) => {
  const map: Record<string, string> = {
    pending: '待确认',
    confirmed: '已确认',
    disputed: '有争议'
  }
  return map[status] || status
}

const loadStatements = async () => {
  try {
    loading.value = true

    const statementsRes = await stationOwnerApi.getStatements({ yearMonth: yearMonth.value })
    if (statementsRes && Array.isArray(statementsRes) && statementsRes.length > 0) {
      currentStatement.value = statementsRes[0]
      currentStatement.value.statusText = getStatusText(currentStatement.value.status)

      statementData.openingBalance = Number(currentStatement.value.openingBalance) || 0
      statementData.totalAmount = Number(currentStatement.value.totalAmount) || 0
      statementData.paymentReceived = Number(currentStatement.value.paymentReceived) || 0
      statementData.closingBalance = Number(currentStatement.value.closingBalance) || 0
    } else {
      currentStatement.value = null
      statementData.openingBalance = 0
      statementData.totalAmount = 0
      statementData.paymentReceived = 0
      statementData.closingBalance = 0
    }

    purchaseRecords.value = []
    paymentRecords.value = []
  } catch (error: any) {
    ElMessage.error('加载对账单失败：' + (error.message || '未知错误'))
  } finally {
    loading.value = false
  }
}

const loadDashboard = async () => {
  try {
    const dashboardRes = await stationOwnerApi.getDashboard()
    if (dashboardRes && (dashboardRes as any).data) {
      const data = (dashboardRes as any).data
      accountInfo.depositBalance = Number(data.accountBalance) || 0
      accountInfo.creditLimit = Number(data.creditLimit) || 0
      accountInfo.availableCredit = Number(data.availableCredit) || 0
      accountInfo.owedBucketNum = data.owedBucketNum || 0

      bucketStats.return = 70
      bucketStats.owe = 8
      bucketStats.closing = data.owedBucketNum || 0
      bucketStats.depositAmount = (data.owedBucketNum || 0) * 40
      bucketStats.total = 100
    }
  } catch (error: any) {
    console.error('加载账户信息失败：' + (error.message || '未知错误'))
  }
}

const prevMonth = () => {
  if (currentMonth.value === 1) {
    currentMonth.value = 12
    currentYear.value--
  } else {
    currentMonth.value--
  }
}

const nextMonth = () => {
  if (currentMonth.value === 12) {
    currentMonth.value = 1
    currentYear.value++
  } else {
    currentMonth.value++
  }
}

const goToRecharge = () => {
  router.push('/station/recharge')
}

const goToBuckets = () => {
  router.push('/station/buckets')
}

const handleConfirm = async () => {
  if (!currentStatement.value) return

  try {
    await ElMessageBox.confirm('确定要确认对账单吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    confirming.value = true
    await stationOwnerApi.confirmStatement(currentStatement.value.id)
    ElMessage.success('对账单已确认')
    loadStatements()
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error('确认失败：' + (error.message || '未知错误'))
    }
  } finally {
    confirming.value = false
  }
}

const handleDispute = () => {
  router.push('/station/statements/dispute')
}

watch(yearMonth, () => {
  loadStatements()
})

onMounted(() => {
  loadStatements()
  loadDashboard()
})
</script>

<style scoped>
.statements-container {
  padding: 20px;
}

.mb-4 {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.month-label {
  font-size: 16px;
  font-weight: 500;
  color: #303133;
  padding: 0 16px;
}

.stat-sub {
  margin-top: 8px;
  font-size: 12px;
  color: #909399;
}

.price-prefix {
  font-size: 14px;
  color: #409eff;
  margin-right: 4px;
}

.price-text {
  font-weight: bold;
  color: #409eff;
}

.text-success {
  color: #67c23a;
}

.text-danger {
  color: #f56c6c;
}

.text-warning {
  color: #e6a23c;
}

.alert-box {
  padding: 16px 0;
}

.action-buttons {
  margin-top: 16px;
  display: flex;
  gap: 12px;
}
</style>
