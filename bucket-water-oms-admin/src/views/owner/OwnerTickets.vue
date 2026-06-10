<template>
  <div class="tickets-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <div class="header-info">
            <span class="header-title">水票管理</span>
            <span class="header-subtitle">管理您的水票持有量和使用记录</span>
          </div>
          <el-button type="primary" @click="showPurchaseModal = true">
            <el-icon><Plus /></el-icon>
            购买水票
          </el-button>
        </div>
      </template>

      <div v-if="loading" class="loading-container">
        <el-icon class="is-loading"><Loading /></el-icon>
        <span>加载中...</span>
      </div>

      <template v-else>
        <el-row :gutter="20" class="mb-4">
          <el-col :span="6">
            <el-statistic title="水票总数" :value="ticketStats.totalTickets">
              <template #prefix>
                <el-icon><Tickets /></el-icon>
              </template>
            </el-statistic>
          </el-col>
          <el-col :span="6">
            <el-statistic title="可用水票" :value="ticketStats.availableTickets">
              <template #prefix>
                <el-icon color="#67C23A"><SuccessFilled /></el-icon>
              </template>
            </el-statistic>
          </el-col>
          <el-col :span="6">
            <el-statistic title="已使用" :value="ticketStats.usedTickets">
              <template #prefix>
                <el-icon color="#E6A23C"><CircleCheck /></el-icon>
              </template>
            </el-statistic>
          </el-col>
          <el-col :span="6">
            <div class="action-card">
              <el-button type="primary" size="large" @click="showPurchaseModal = true">
                <el-icon><Plus /></el-icon>
                购买水票
              </el-button>
            </div>
          </el-col>
        </el-row>

        <el-card shadow="never" class="mb-4">
          <template #header>
            <div class="section-header">
              <el-icon><Tickets /></el-icon>
              <span>水票持有明细</span>
            </div>
          </template>

          <el-table :data="ticketHoldings" border stripe>
            <el-table-column label="水票类型" min-width="150">
              <template #default="{ row }">
                <div class="ticket-info">
                  <el-icon class="ticket-icon"><Ticket /></el-icon>
                  <div>
                    <p class="ticket-name">{{ row.ticketName }}</p>
                    <p class="ticket-value">面值: {{ row.value }}桶 / 张</p>
                  </div>
                </div>
              </template>
            </el-table-column>
            <el-table-column label="持有" width="80" align="center">
              <template #default="{ row }">
                <span class="stat-value">{{ row.totalCount }}</span>
              </template>
            </el-table-column>
            <el-table-column label="已用" width="80" align="center">
              <template #default="{ row }">
                <span class="stat-value used">{{ row.usedCount }}</span>
              </template>
            </el-table-column>
            <el-table-column label="剩余" width="80" align="center">
              <template #default="{ row }">
                <span class="stat-value remaining">{{ row.remainingCount }}</span>
              </template>
            </el-table-column>
            <el-table-column label="状态" width="100" align="center">
              <template #default="{ row }">
                <el-tag :type="getTicketStatusType(row.status)">{{ getTicketStatusText(row.status) }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="有效期" width="120">
              <template #default="{ row }">
                <p>{{ row.expireDate }}</p>
              </template>
            </el-table-column>
            <el-table-column label="购买日期" width="120">
              <template #default="{ row }">
                <p>{{ row.purchaseDate }}</p>
              </template>
            </el-table-column>
          </el-table>

          <el-empty v-if="ticketHoldings.length === 0" description="暂无水票">
            <el-button type="primary" @click="showPurchaseModal = true">立即购买</el-button>
          </el-empty>
        </el-card>

        <el-card shadow="never">
          <template #header>
            <div class="section-header">
              <el-icon><Document /></el-icon>
              <span>使用记录</span>
            </div>
          </template>

          <div class="filter-section mb-4">
            <el-radio-group v-model="recordFilter">
              <el-radio-button value="all">全部</el-radio-button>
              <el-radio-button value="used">已使用</el-radio-button>
              <el-radio-button value="expired">已过期</el-radio-button>
            </el-radio-group>
            <el-radio-group v-model="dateFilter" class="date-filter">
              <el-radio-button value="week">近一周</el-radio-button>
              <el-radio-button value="month">近一月</el-radio-button>
              <el-radio-button value="quarter">近三月</el-radio-button>
            </el-radio-group>
          </div>

          <el-table :data="filteredRecords" border stripe>
            <el-table-column label="水票" min-width="150">
              <template #default="{ row }">
                <div class="record-info">
                  <el-icon :class="getRecordIconClass(row.type)">
                    <component :is="getRecordIcon(row.type)" />
                  </el-icon>
                  <span>{{ row.ticketName }}</span>
                </div>
              </template>
            </el-table-column>
            <el-table-column label="使用时间" width="180">
              <template #default="{ row }">
                <p>{{ row.usedTime }}</p>
                <p v-if="row.orderNo" class="order-no">订单: {{ row.orderNo }}</p>
              </template>
            </el-table-column>
            <el-table-column label="使用数量" width="120" align="center">
              <template #default="{ row }">
                <span class="used-count">-{{ row.usedCount }}张</span>
              </template>
            </el-table-column>
            <el-table-column label="剩余" width="100" align="center">
              <template #default="{ row }">
                <span>{{ row.remainingCount }}张</span>
              </template>
            </el-table-column>
            <el-table-column label="状态" width="100" align="center">
              <template #default="{ row }">
                <el-tag size="small" :type="getRecordTagType(row.type)">{{ getRecordTypeText(row.type) }}</el-tag>
              </template>
            </el-table-column>
          </el-table>

          <el-empty v-if="filteredRecords.length === 0" description="暂无使用记录" />

          <el-pagination
            v-if="totalPages > 1"
            v-model:current-page="currentPage"
            :page-size="10"
            :total="totalRecords"
            layout="prev, pager, next"
            class="mt-4"
          />
        </el-card>
      </template>
    </el-card>

    <el-dialog v-model="showPurchaseModal" title="购买水票" width="600px" destroy-on-close>
      <el-form :model="purchaseForm" label-width="100px">
        <el-form-item label="水票类型">
          <el-radio-group v-model="purchaseForm.ticketId" class="ticket-type-group">
            <el-radio
              v-for="ticket in availableTickets"
              :key="ticket.id"
              :value="ticket.id"
              class="ticket-option"
            >
              <div class="ticket-option-content">
                <el-icon class="ticket-icon"><Ticket /></el-icon>
                <div>
                  <p class="ticket-name">{{ ticket.name }}</p>
                  <p class="ticket-desc">面值: {{ ticket.value }}桶 / 张</p>
                </div>
                <div class="ticket-price">
                  <span>¥{{ ticket.price }}</span>
                </div>
              </div>
            </el-radio>
          </el-radio-group>
        </el-form-item>

        <el-form-item label="购买数量">
          <el-input-number v-model="purchaseForm.quantity" :min="1" :max="999" />
        </el-form-item>

        <el-form-item label="支付方式">
          <el-select v-model="purchaseForm.paymentMethod" placeholder="请选择支付方式">
            <el-option value="balance" label="账户余额" />
            <el-option value="wechat" label="微信支付" />
            <el-option value="alipay" label="支付宝" />
          </el-select>
        </el-form-item>

        <el-divider />

        <div class="price-summary">
          <div class="summary-row">
            <span>单价</span>
            <span>¥{{ selectedTicket?.price || 0 }}</span>
          </div>
          <div class="summary-row">
            <span>数量</span>
            <span>x{{ purchaseForm.quantity }}</span>
          </div>
          <div class="summary-row total">
            <span>应付金额</span>
            <span class="total-price">¥{{ totalAmount }}</span>
          </div>
        </div>
      </el-form>

      <template #footer>
        <el-button @click="showPurchaseModal = false">取消</el-button>
        <el-button type="primary" :disabled="!canPurchase" :loading="purchasing" @click="submitPurchase">
          {{ purchasing ? '支付中...' : '立即支付' }}
        </el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="showSuccessModal" title="购买成功" width="400px" destroy-on-close>
      <el-result icon="success" title="购买成功">
        <template #sub-title>
          <div class="success-content">
            <p>您已成功购买</p>
            <p class="success-count">{{ purchaseForm.quantity }}张</p>
            <p class="success-name">{{ selectedTicket?.name }}</p>
          </div>
        </template>
      </el-result>
      <template #footer>
        <el-button type="primary" @click="goToTickets">查看我的水票</el-button>
        <el-button @click="showSuccessModal = false">继续购物</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import {
  Loading, Plus, Tickets, SuccessFilled, CircleCheck, Ticket, Document
} from '@element-plus/icons-vue'
import { toast } from '@/composables/useToast'

const loading = ref(true)
const purchasing = ref(false)

const ticketStats = ref({
  totalTickets: 0,
  availableTickets: 0,
  usedTickets: 0
})

const ticketHoldings = ref<any[]>([])
const records = ref<any[]>([])
const recordFilter = ref('all')
const dateFilter = ref('month')
const currentPage = ref(1)
const totalRecords = ref(0)
const totalPages = computed(() => Math.ceil(totalRecords.value / 10))

const showPurchaseModal = ref(false)
const purchaseForm = ref({
  ticketId: '',
  quantity: 10,
  paymentMethod: 'balance'
})

const showSuccessModal = ref(false)

const availableTickets = ref([
  { id: '1', name: '18.9L 桶装水票', value: 1, price: 8, unit: '桶' },
  { id: '2', name: '11.3L 桶装水票', value: 1, price: 6, unit: '桶' },
  { id: '3', name: '5L 桶装水票', value: 1, price: 4, unit: '桶' }
])

const selectedTicket = computed(() => {
  return availableTickets.value.find(t => t.id === purchaseForm.value.ticketId)
})

const totalAmount = computed(() => {
  if (!selectedTicket.value) return '0.00'
  return (selectedTicket.value.price * purchaseForm.value.quantity).toFixed(2)
})

const canPurchase = computed(() => {
  return purchaseForm.value.ticketId && purchaseForm.value.quantity > 0 && purchaseForm.value.paymentMethod
})

const filteredRecords = computed(() => {
  let result = records.value
  if (recordFilter.value !== 'all') {
    result = result.filter(r => r.type === recordFilter.value)
  }
  return result
})

const getTicketStatusType = (status: string) => {
  const map: Record<string, string> = {
    available: 'success',
    expired: 'info',
    depleted: 'warning'
  }
  return map[status] || ''
}

const getTicketStatusText = (status: string) => {
  const map: Record<string, string> = {
    available: '可用',
    expired: '已过期',
    depleted: '已用完'
  }
  return map[status] || status
}

const getRecordIcon = (type: string) => {
  const map: Record<string, string> = {
    used: 'Tickets',
    expired: 'Clock',
    refunded: 'CircleCheck'
  }
  return map[type] || 'Tickets'
}

const getRecordIconClass = (type: string) => {
  const map: Record<string, string> = {
    used: 'text-purple',
    expired: 'text-gray',
    refunded: 'text-green'
  }
  return map[type] || 'text-gray'
}

const getRecordTagType = (type: string) => {
  const map: Record<string, string> = {
    used: '',
    expired: 'info',
    refunded: 'success'
  }
  return map[type] || ''
}

const getRecordTypeText = (type: string) => {
  const map: Record<string, string> = {
    used: '已使用',
    expired: '已过期',
    refunded: '已退款'
  }
  return map[type] || type
}

const loadData = async () => {
  try {
    loading.value = true

    ticketStats.value = {
      totalTickets: 150,
      availableTickets: 120,
      usedTickets: 30
    }

    ticketHoldings.value = [
      {
        id: '1',
        ticketName: '18.9L 桶装水票',
        value: 1,
        totalCount: 100,
        usedCount: 20,
        remainingCount: 80,
        status: 'available',
        purchaseDate: '2026-04-10',
        expireDate: '2027-04-10'
      },
      {
        id: '2',
        ticketName: '11.3L 桶装水票',
        value: 1,
        totalCount: 50,
        usedCount: 10,
        remainingCount: 40,
        status: 'available',
        purchaseDate: '2026-04-15',
        expireDate: '2027-04-15'
      }
    ]

    records.value = [
      {
        id: '1',
        ticketName: '18.9L 桶装水票',
        type: 'used',
        usedTime: '2026-04-23 14:30',
        usedCount: 5,
        remainingCount: 75,
        orderNo: 'WD20260423001'
      },
      {
        id: '2',
        ticketName: '11.3L 桶装水票',
        type: 'used',
        usedTime: '2026-04-22 10:20',
        usedCount: 3,
        remainingCount: 37,
        orderNo: 'WD20260422001'
      },
      {
        id: '3',
        ticketName: '18.9L 桶装水票',
        type: 'expired',
        usedTime: '2026-03-01 09:00',
        usedCount: 5,
        remainingCount: 0,
        orderNo: ''
      }
    ]

    totalRecords.value = records.value.length
  } catch (error: any) {
    toast.error('加载数据失败：' + (error.message || '未知错误'))
  } finally {
    loading.value = false
  }
}

const submitPurchase = async () => {
  if (!canPurchase.value) {
    toast.warning('请填写完整的购买信息')
    return
  }

  try {
    purchasing.value = true

    await new Promise(resolve => setTimeout(resolve, 1500))

    showPurchaseModal.value = false
    showSuccessModal.value = true

    loadData()
  } catch (error: any) {
    toast.error('购买失败：' + (error.message || '未知错误'))
  } finally {
    purchasing.value = false
  }
}

const goToTickets = () => {
  showSuccessModal.value = false
  showPurchaseModal.value = false
}

onMounted(() => {
  loadData()
})
</script>

<style scoped>
.tickets-container {
  padding: 0;
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.header-info {
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

.action-card {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  height: 100%;
}

.ticket-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.ticket-icon {
  font-size: 24px;
  color: #8B5CF6;
}

.ticket-info .ticket-name {
  font-weight: 500;
  color: #303133;
}

.ticket-info .ticket-value {
  font-size: 12px;
  color: #909399;
}

.stat-value {
  font-weight: 600;
  color: #303133;
}

.stat-value.used {
  color: #67C23A;
}

.stat-value.remaining {
  color: #8B5CF6;
}

.record-info {
  display: flex;
  align-items: center;
  gap: 8px;
}

.text-purple {
  color: #8B5CF6;
}

.text-gray {
  color: #909399;
}

.text-green {
  color: #67C23A;
}

.order-no {
  font-size: 12px;
  color: #909399;
}

.used-count {
  font-weight: 600;
  color: #8B5CF6;
}

.filter-section {
  display: flex;
  gap: 16px;
  flex-wrap: wrap;
}

.date-filter {
  margin-left: auto;
}

.ticket-type-group {
  display: flex;
  flex-direction: column;
  gap: 12px;
  width: 100%;
}

.ticket-option {
  width: 100%;
  padding: 16px;
  border: 1px solid #DCDFE6;
  border-radius: 8px;
  margin-right: 0;
}

.ticket-option:has(.is-checked) {
  border-color: #8B5CF6;
  background-color: #f5f3ff;
}

.ticket-option-content {
  display: flex;
  align-items: center;
  gap: 12px;
  width: 100%;
}

.ticket-option-content .ticket-icon {
  font-size: 28px;
}

.ticket-option-content .ticket-name {
  font-weight: 600;
  color: #303133;
}

.ticket-option-content .ticket-desc {
  font-size: 12px;
  color: #909399;
}

.ticket-price {
  margin-left: auto;
  font-size: 18px;
  font-weight: 600;
  color: #8B5CF6;
}

.price-summary {
  padding: 16px;
  background: #f5f7fa;
  border-radius: 8px;
}

.summary-row {
  display: flex;
  justify-content: space-between;
  padding: 8px 0;
  font-size: 14px;
  color: #606266;
}

.summary-row.total {
  border-top: 1px solid #e4e7ed;
  margin-top: 8px;
  padding-top: 16px;
  font-weight: 600;
}

.total-price {
  font-size: 24px;
  color: #8B5CF6;
}

.success-content {
  text-align: center;
  padding: 16px 0;
}

.success-count {
  font-size: 32px;
  font-weight: 700;
  color: #8B5CF6;
  margin: 8px 0;
}

.success-name {
  font-size: 14px;
  color: #606266;
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
