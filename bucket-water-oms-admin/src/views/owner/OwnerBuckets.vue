<template>
  <div class="buckets-container">
    <el-row :gutter="20" class="mb-4">
      <el-col :span="8">
        <el-card shadow="hover" class="stat-card">
          <el-statistic title="押金桶总数" :value="bucketData.depositBucketNum" suffix="个">
            <template #prefix>
              <el-icon class="stat-icon"><Box /></el-icon>
            </template>
          </el-statistic>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="hover" class="stat-card">
          <el-statistic title="当前欠桶" :value="bucketData.owedBucketNum" suffix="个">
            <template #prefix>
              <el-icon class="stat-icon warning"><Warning /></el-icon>
            </template>
          </el-statistic>
          <div class="stat-sub">欠桶押金: ¥{{ bucketData.owedDepositAmount }}</div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="hover" class="stat-card">
          <el-statistic title="每桶押金" :value="bucketData.bucketDepositPerUnit" prefix="¥">
            <template #prefix>
              <el-icon class="stat-icon success"><Money /></el-icon>
            </template>
          </el-statistic>
          <div class="stat-sub">欠桶阈值: {{ bucketData.owedThreshold }}个</div>
        </el-card>
      </el-col>
    </el-row>

    <el-alert
      v-if="bucketData.overThreshold"
      title="欠桶预警"
      type="warning"
      description="您当前欠桶已达到阈值，请及时补缴押金"
      show-icon
      :closable="false"
      class="mb-4"
    >
      <template #default>
        <div class="alert-content">
          <span>欠桶 {{ bucketData.owedBucketNum }} 个，占阈值 {{ bucketData.owedThreshold }} 个的 {{ bucketData.percent }}%</span>
          <el-button type="danger" size="small" @click="handlePayDeposit">立即补缴</el-button>
        </div>
      </template>
    </el-alert>

    <el-card shadow="never" class="mb-4">
      <template #header>
        <div class="card-header">
          <span>月度统计</span>
        </div>
      </template>
      <el-row :gutter="20">
        <el-col :span="6">
          <el-statistic title="本月回桶" :value="bucketData.monthReturn" suffix="个">
            <template #prefix>
              <el-icon class="stat-icon success"><Top /></el-icon>
            </template>
          </el-statistic>
        </el-col>
        <el-col :span="6">
          <el-statistic title="本月欠桶" :value="bucketData.monthOwe" suffix="个">
            <template #prefix>
              <el-icon class="stat-icon warning"><Bottom /></el-icon>
            </template>
          </el-statistic>
        </el-col>
        <el-col :span="6">
          <el-statistic title="净回桶" :value="bucketData.monthNet" suffix="个">
            <template #prefix>
              <el-icon class="stat-icon"><RefreshRight /></el-icon>
            </template>
          </el-statistic>
        </el-col>
        <el-col :span="6">
          <el-statistic title="历史累计回桶" :value="bucketData.totalReturn" suffix="个">
            <template #prefix>
              <el-icon class="stat-icon"><Collection /></el-icon>
            </template>
          </el-statistic>
        </el-col>
      </el-row>
    </el-card>

    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span>空桶流水</span>
          <el-radio-group v-model="activeFilter" size="default">
            <el-radio-button label="">全部</el-radio-button>
            <el-radio-button label="return">回桶</el-radio-button>
            <el-radio-button label="owe">欠桶</el-radio-button>
            <el-radio-button label="deposit">押金</el-radio-button>
          </el-radio-group>
        </div>
      </template>

      <el-table :data="filteredRecords" stripe v-loading="loading">
        <el-table-column label="类型" width="120">
          <template #default="{ row }">
            <el-tag :type="getTypeTagType(row.type)">{{ row.typeText }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="description" label="说明" min-width="200" />
        <el-table-column label="数量" width="100">
          <template #default="{ row }">
            <span :class="getAmountClass(row.type)">{{ row.amount }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="driver" label="司机" width="150" />
        <el-table-column prop="date" label="日期" width="180" />
      </el-table>

      <el-empty v-if="filteredRecords.length === 0 && !loading" description="暂无流水记录" />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Box, Warning, Money, Top, Bottom, RefreshRight, Collection } from '@element-plus/icons-vue'
import { stationOwnerApi } from '@/api'

const loading = ref(true)
const activeFilter = ref('')

const bucketData = ref({
  depositBucketNum: 0,
  owedBucketNum: 0,
  owedDepositAmount: 0,
  bucketDepositPerUnit: 0,
  owedThreshold: 10,
  overThreshold: false,
  percent: 0,
  monthReturn: 0,
  monthOwe: 0,
  monthNet: 0,
  totalReturn: 0,
  totalOwe: 0
})

const bucketRecords = ref<any[]>([])

const filteredRecords = computed(() => {
  if (!activeFilter.value) {
    return bucketRecords.value
  }
  return bucketRecords.value.filter(record => record.type === activeFilter.value)
})

const getTypeTagType = (type: string) => {
  const typeMap: Record<string, string> = {
    return: 'success',
    owe: 'warning',
    deposit: ''
  }
  return typeMap[type] || ''
}

const getTypeText = (type: string) => {
  const map: Record<string, string> = {
    return: '回桶',
    owe: '欠桶',
    deposit: '补缴押金'
  }
  return map[type] || type
}

const getAmountClass = (type: string) => {
  const classMap: Record<string, string> = {
    return: 'text-success',
    owe: 'text-warning',
    deposit: 'text-primary'
  }
  return classMap[type] || ''
}

const loadBucketData = async () => {
  try {
    loading.value = true

    const summaryRes = await stationOwnerApi.getBucketSummary()
    if (summaryRes) {
      const percent = summaryRes.owedThreshold > 0
        ? Math.round((summaryRes.owedBucketNum / summaryRes.owedThreshold) * 100)
        : 0

      bucketData.value = {
        depositBucketNum: summaryRes.depositBucketNum || 0,
        owedBucketNum: summaryRes.owedBucketNum || 0,
        owedDepositAmount: summaryRes.owedDepositAmount || 0,
        bucketDepositPerUnit: summaryRes.bucketDepositPerUnit || 40,
        owedThreshold: summaryRes.owedThreshold || 10,
        overThreshold: summaryRes.overThreshold || false,
        percent: percent,
        monthReturn: summaryRes.monthReturn || 0,
        monthOwe: summaryRes.monthOwe || 0,
        monthNet: summaryRes.monthNet || 0,
        totalReturn: summaryRes.totalReturn || 0,
        totalOwe: summaryRes.totalOwe || 0
      }
    }

    const transactionsRes = await stationOwnerApi.getBucketTransactions()
    if (transactionsRes && Array.isArray(transactionsRes)) {
      bucketRecords.value = transactionsRes.map((t: any) => ({
        id: t.id,
        type: t.type,
        typeText: getTypeText(t.type),
        description: t.description || t.orderNo ? `订单${t.orderNo}` : '',
        amount: formatTransactionAmount(t),
        date: t.date || (t.createTime ? new Date(t.createTime).toLocaleDateString('zh-CN') : ''),
        driver: t.driver || (t.driverName ? '司机：' + t.driverName : '')
      }))
    }
  } catch (error: any) {
    ElMessage.error('加载空桶数据失败：' + (error.message || '未知错误'))
  } finally {
    loading.value = false
  }
}

const formatTransactionAmount = (t: any) => {
  if (t.amount) {
    return t.amount.startsWith('+') || t.amount.startsWith('-') ? t.amount : (t.quantity > 0 ? `+${t.quantity}个` : `${t.quantity}个`)
  }
  if (t.quantity) {
    return t.quantity > 0 ? `+${t.quantity}个` : `${t.quantity}个`
  }
  return '0'
}

const handlePayDeposit = async () => {
  const owedNum = bucketData.value.owedBucketNum
  if (owedNum <= 0) {
    ElMessage.info('当前没有欠桶，无需补缴')
    return
  }

  try {
    await ElMessageBox.confirm(`确定要补缴${owedNum}个空桶的押金吗？`, '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    await stationOwnerApi.payBucketDeposit(owedNum)
    ElMessage.success('押金补缴成功')
    loadBucketData()
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error('押金补缴失败：' + (error.message || '未知错误'))
    }
  }
}

onMounted(() => {
  loadBucketData()
})
</script>

<style scoped>
.buckets-container {
  padding: 20px;
}

.mb-4 {
  margin-bottom: 20px;
}

.stat-card {
  height: 100%;
}

.stat-icon {
  font-size: 20px;
  color: #409eff;
  margin-right: 8px;
}

.stat-icon.success {
  color: #67c23a;
}

.stat-icon.warning {
  color: #e6a23c;
}

.stat-sub {
  margin-top: 8px;
  font-size: 12px;
  color: #909399;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.alert-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 8px;
}

.text-success {
  color: #67c23a;
  font-weight: bold;
}

.text-warning {
  color: #e6a23c;
  font-weight: bold;
}

.text-primary {
  color: #409eff;
  font-weight: bold;
}
</style>
