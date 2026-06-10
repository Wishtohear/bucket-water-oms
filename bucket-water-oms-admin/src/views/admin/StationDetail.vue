<template>
  <div class="station-detail-page">
    <el-page-header @back="goBack" class="mb-4">
      <template #content>
        <div class="page-header-content">
          <span class="page-title">水站详情</span>
        </div>
      </template>
    </el-page-header>

    <div v-if="loading" class="loading-container">
      <el-icon class="is-loading"><Loading /></el-icon>
      <span>加载中...</span>
    </div>

    <el-result v-else-if="error" icon="error" :title="error">
      <template #extra>
        <el-button type="primary" @click="fetchStationDetail">重试</el-button>
      </template>
    </el-result>

    <el-row :gutter="20" v-else>
      <el-col :span="16">
        <el-card shadow="never" class="mb-4">
          <template #header>
            <div class="card-header">
              <div class="station-header">
                <el-icon :size="40" color="#409eff"><Shop /></el-icon>
                <div class="station-info">
                  <h3>{{ stationData.name }}</h3>
                  <p>水站编号: {{ stationData.code }} | 创建时间: {{ stationData.createTime }}</p>
                </div>
              </div>
              <el-tag :type="getStatusType(stationData.status)" effect="dark">
                {{ getStatusText(stationData.status) }}
              </el-tag>
            </div>
          </template>
          <el-descriptions :column="2" border>
            <el-descriptions-item label="联系人">{{ stationData.contact }}</el-descriptions-item>
            <el-descriptions-item label="联系电话">{{ stationData.phone }}</el-descriptions-item>
            <el-descriptions-item label="详细地址" :span="2">{{ stationData.address }}</el-descriptions-item>
            <el-descriptions-item label="负责仓库">{{ stationData.warehouse || '未分配' }}</el-descriptions-item>
            <el-descriptions-item label="服务区域">{{ stationData.area || '未分配' }}</el-descriptions-item>
          </el-descriptions>
          <div class="card-actions">
            <el-button type="primary" plain @click="goToEdit">
              <el-icon><Edit /></el-icon>
              编辑信息
            </el-button>
            <el-button type="primary" @click="viewOrders">
              <el-icon><Document /></el-icon>
              查看订单
            </el-button>
          </div>
        </el-card>

        <el-card shadow="never" class="mb-4">
          <template #header>
            <span class="card-title">账户与财务</span>
          </template>
          <el-row :gutter="12">
            <el-col :span="6">
              <div class="stat-card stat-blue">
                <div class="stat-label">预存金余额</div>
                <div class="stat-value">¥ {{ stationData.depositBalance?.toLocaleString() || '0.00' }}</div>
              </div>
            </el-col>
            <el-col :span="6">
              <div class="stat-card stat-purple">
                <div class="stat-label">信用额度</div>
                <div class="stat-value">¥ {{ stationData.creditLimit?.toLocaleString() || '0.00' }}</div>
                <div class="stat-extra">已用 ¥{{ stationData.creditUsed || 0 }}</div>
              </div>
            </el-col>
            <el-col :span="6">
              <div class="stat-card stat-orange">
                <div class="stat-label">押金桶数量</div>
                <div class="stat-value">{{ stationData.depositBucketNum || 0 }} 个</div>
              </div>
            </el-col>
            <el-col :span="6">
              <div class="stat-card stat-red">
                <div class="stat-label">当前欠桶</div>
                <div class="stat-value">{{ stationData.owedBucketNum || 0 }} 个</div>
                <div class="stat-extra">需补缴 ¥{{ ((stationData.owedBucketNum || 0) * (stationData.bucketDepositAmount || 20)).toLocaleString() }}</div>
              </div>
            </el-col>
          </el-row>
          <el-alert
            v-if="(stationData.owedBucketNum || 0) > (stationData.owedThreshold || 30)"
            type="error"
            :closable="false"
            class="mt-4"
          >
            <template #title>
              <strong>欠桶预警</strong>
            </template>
            <template #default>
              当前欠桶数({{ stationData.owedBucketNum }})超过阈值({{ stationData.owedThreshold || 30 }}个)，请及时补缴押金
            </template>
          </el-alert>
        </el-card>

        <el-card shadow="never">
          <template #header>
            <div class="card-header">
              <span class="card-title">销售政策配置</span>
              <el-button link type="primary" @click="openPolicyDialog">修改政策</el-button>
            </div>
          </template>
          <div v-if="stationData.policyName" class="policy-info mb-4">
            <el-tag type="success" size="large">
              {{ stationData.policyType === 'vip' ? 'VIP客户' : stationData.policyType === 'promotion' ? '限时促销' : '默认通用' }}
            </el-tag>
            <span class="policy-name">{{ stationData.policyName }}</span>
          </div>
          <el-empty v-else description="未分配销售政策，请点击「修改政策」进行分配" :image-size="60" />
          <el-row :gutter="12" class="mt-4">
            <el-col :span="6">
              <div class="policy-item">
                <div class="policy-label">账期类型</div>
                <div class="policy-value">{{ getPaymentTypeText(stationData.paymentType) }}</div>
              </div>
            </el-col>
            <el-col :span="6">
              <div class="policy-item">
                <div class="policy-label">信用额度</div>
                <div class="policy-value">¥ {{ stationData.creditLimit?.toLocaleString() || '0' }}</div>
              </div>
            </el-col>
            <el-col :span="6">
              <div class="policy-item">
                <div class="policy-label">欠桶阈值</div>
                <div class="policy-value">{{ stationData.owedThreshold || 30 }} 个</div>
              </div>
            </el-col>
            <el-col :span="6">
              <div class="policy-item">
                <div class="policy-label">每桶押金金额</div>
                <div class="policy-value">¥ {{ stationData.bucketDepositAmount || 20 }}.00</div>
              </div>
            </el-col>
          </el-row>
          <div v-if="stationData.prices && stationData.prices.length > 0" class="price-section mt-4">
            <div class="section-label">商品定价</div>
            <el-table :data="stationData.prices" stripe size="small" class="mt-2">
              <el-table-column prop="productName" label="商品名称" />
              <el-table-column prop="minQuantity" label="最低起订量" align="center" width="120" />
              <el-table-column label="单价" align="right" width="120">
                <template #default="{ row }">
                  <span class="price-text">¥{{ row.price }} / 桶</span>
                </template>
              </el-table-column>
            </el-table>
          </div>
        </el-card>
      </el-col>

      <el-col :span="8">
        <el-card shadow="never" class="mb-4">
          <template #header>
            <span class="card-title">运营数据 (本月)</span>
          </template>
          <div class="data-list">
            <div class="data-item">
              <div class="data-label">
                <el-icon color="#409eff"><ShoppingCart /></el-icon>
                <span>订单总数</span>
              </div>
              <span class="data-value">{{ stationData.monthlyOrders || 0 }} 单</span>
            </div>
            <div class="data-item">
              <div class="data-label">
                <el-icon color="#67c23a"><Box /></el-icon>
                <span>进货桶数</span>
              </div>
              <span class="data-value">{{ (stationData.monthlyBuckets || 0).toLocaleString() }} 桶</span>
            </div>
            <div class="data-item">
              <div class="data-label">
                <el-icon color="#e6a23c"><Money /></el-icon>
                <span>进货金额</span>
              </div>
              <span class="data-value">¥ {{ (stationData.monthlyAmount || 0).toLocaleString() }}.00</span>
            </div>
            <div class="data-item">
              <div class="data-label">
                <el-icon color="#f56c6c"><Refresh /></el-icon>
                <span>回桶数量</span>
              </div>
              <span class="data-value">{{ stationData.monthlyReturnBuckets || 0 }} 个</span>
            </div>
          </div>
        </el-card>

        <el-card shadow="never" class="mb-4">
          <template #header>
            <div class="card-header">
              <span class="card-title">最近订单</span>
              <el-button link type="primary" @click="viewOrders">查看全部</el-button>
            </div>
          </template>
          <div class="order-list">
            <div v-for="order in recentOrders" :key="order.id" class="order-item">
              <div class="order-info">
                <p class="order-no">{{ order.orderNo }}</p>
                <p class="order-time">{{ order.createTime }}</p>
              </div>
              <div class="order-right">
                <p class="order-amount">¥ {{ order.amount?.toLocaleString() }}</p>
                <el-tag size="small" :type="getOrderStatusType(order.status)">
                  {{ getOrderStatusText(order.status) }}
                </el-tag>
              </div>
            </div>
            <el-empty v-if="recentOrders.length === 0" description="暂无订单记录" :image-size="60" />
          </div>
        </el-card>

        <el-card shadow="never">
          <template #header>
            <div class="card-header">
              <span class="card-title">店员账号</span>
              <el-button link type="primary" @click="goToStaffManagement">管理账号</el-button>
            </div>
          </template>
          <div class="staff-list">
            <div v-for="staff in stationData.staffs" :key="staff.id" class="staff-item">
              <div class="staff-avatar">
                <el-icon :size="20" color="#409eff"><User /></el-icon>
              </div>
              <div class="staff-info">
                <p class="staff-name">{{ staff.name }}{{ staff.role ? ` (${staff.role})` : '' }}</p>
                <p class="staff-phone">{{ staff.phone }}</p>
              </div>
              <el-tag size="small" type="success">正常</el-tag>
            </div>
            <el-empty v-if="!stationData.staffs || stationData.staffs.length === 0" description="暂无店员账号" :image-size="60" />
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 政策配置对话框 -->
    <el-dialog v-model="showPolicyDialog" title="选择销售政策" width="650px" destroy-on-close>
      <div class="policy-dialog-content">
        <el-alert type="info" :closable="false" class="mb-4">
          <template #title>
            选择一个销售政策模板分配给此水站，水站订货时将使用该政策的商品价格和最低起订量
          </template>
        </el-alert>
        <div class="policy-list-container">
          <el-radio-group v-model="selectedPolicyId" class="policy-list">
            <el-card
              v-for="policy in availablePolicies"
              :key="policy.id"
              shadow="hover"
              class="policy-card-item mb-3"
              :class="{ 'policy-card-selected': selectedPolicyId === policy.id }"
            >
              <el-radio :value="policy.id" class="policy-radio">
                <div class="policy-card-content">
                  <div class="policy-card-header">
                    <span class="policy-name">{{ policy.name }}</span>
                    <el-tag size="small" :type="policy.type === 'vip' ? 'success' : policy.type === 'promotion' ? 'warning' : 'info'">
                      {{ policy.type === 'vip' ? 'VIP客户' : policy.type === 'promotion' ? '限时促销' : '默认通用' }}
                    </el-tag>
                  </div>
                  <div class="policy-desc">{{ policy.remark || '暂无描述' }}</div>
                  <div class="policy-meta">
                    <span>包含 {{ policy.pricingRules?.length || 0 }} 个商品</span>
                  </div>
                </div>
              </el-radio>
            </el-card>
          </el-radio-group>
          <el-empty v-if="availablePolicies.length === 0" description="暂无可用政策模板，请先创建销售政策" :image-size="80" />
        </div>
      </div>
      <template #footer>
        <el-button @click="showPolicyDialog = false">取消</el-button>
        <el-button type="primary" :loading="policyLoading" :disabled="!selectedPolicyId" @click="assignPolicy">确认分配</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { stationsApi } from '@/api/stations'
import { policiesApi } from '@/api/policies'
import { ElMessage } from 'element-plus'

const router = useRouter()
const route = useRoute()

const loading = ref(false)
const error = ref('')
const stationId = computed(() => route.params.id as string || '')

const showPolicyDialog = ref(false)
const policyLoading = ref(false)
const selectedPolicyId = ref('')
const availablePolicies = ref<PolicyTemplateVO[]>([])

interface StationPrices {
  productId: string
  productName: string
  price: number
  minQuantity?: number
}

interface PolicyTemplateVO {
  id: string
  name: string
  type: string
  remark?: string
  pricingRules?: PricingRule[]
}

interface PricingRule {
  productId: string
  productName?: string
  price: number
  minQuantity?: number
}

interface StationStaff {
  id: string
  name: string
  phone: string
  role?: string
}

interface RecentOrder {
  id: string
  orderNo: string
  createTime: string
  amount: number
  status: string
}

interface StationData {
  id: string
  name: string
  code: string
  status: string
  contact: string
  phone: string
  address: string
  area: string
  stationType?: string
  balance?: number
  creditLimit?: number
  remark?: string
  owedBuckets?: number
  depositBalance?: number
  creditUsed?: number
  depositBucketNum?: number
  owedBucketNum?: number
  owedThreshold?: number
  bucketDepositAmount?: number
  paymentType?: string
  minDeposit?: number
  monthlyOrders?: number
  monthlyBuckets?: number
  monthlyAmount?: number
  monthlyReturnBuckets?: number
  warehouse?: string
  createTime?: string
  prices?: StationPrices[]
  staffs?: StationStaff[]
  lat?: number
  lng?: number
  policyId?: string
  policyName?: string
  policyType?: string
}

const stationData = reactive<StationData>({
  id: '',
  name: '加载中...',
  code: '',
  status: 'active',
  contact: '',
  phone: '',
  address: '',
  area: '',
  warehouse: '',
  createTime: '',
  depositBalance: 0,
  creditLimit: 0,
  creditUsed: 0,
  depositBucketNum: 0,
  owedBucketNum: 0,
  owedThreshold: 30,
  bucketDepositAmount: 20,
  paymentType: 'PREPAID',
  minDeposit: 0,
  monthlyOrders: 0,
  monthlyBuckets: 0,
  monthlyAmount: 0,
  monthlyReturnBuckets: 0,
  prices: [],
  staffs: []
})

const recentOrders = ref<RecentOrder[]>([])

const getStatusText = (status: string) => {
  const statusMap: Record<string, string> = {
    active: '正常运营',
    suspended: '欠费停供',
    closed: '已注销'
  }
  return statusMap[status] || status
}

const getStatusType = (status: string) => {
  const typeMap: Record<string, string> = {
    active: 'success',
    suspended: 'warning',
    closed: 'info'
  }
  return typeMap[status] || 'info'
}

const getPaymentTypeText = (type?: string) => {
  const typeMap: Record<string, string> = {
    PREPAID: '预存金',
    immediate: '现结',
    monthly: '月结',
    quarterly: '季结',
    MONTHLY: '月结',
    QUARTERLY: '季结'
  }
  return typeMap[type || ''] || '预存金'
}

const getOrderStatusText = (status: string) => {
  const statusMap: Record<string, string> = {
    PENDING_REVIEW: '待审查',
    REVIEWED: '已接单',
    DISPATCHED: '已派单',
    DELIVERING: '配送中',
    COMPLETED: '已完成',
    CANCELLED: '已取消',
    REJECTED: '已拒单'
  }
  return statusMap[status] || status
}

const getOrderStatusType = (status: string) => {
  const typeMap: Record<string, string> = {
    PENDING_REVIEW: 'warning',
    REVIEWED: 'primary',
    DISPATCHED: 'primary',
    DELIVERING: 'primary',
    COMPLETED: 'success',
    CANCELLED: 'info',
    REJECTED: 'danger'
  }
  return typeMap[status] || 'info'
}

const goBack = () => {
  router.push('/stations')
}

const goToEdit = () => {
  router.push(`/stations/${stationId.value}/edit`)
}

const viewOrders = () => {
  router.push({ path: '/orders', query: { stationId: stationId.value } })
}

const goToStaffManagement = () => {
  router.push(`/stations/${stationId.value}/staff`)
}

const openPolicyDialog = async () => {
  showPolicyDialog.value = true
  selectedPolicyId.value = stationData.policyId || ''
  policyLoading.value = true
  try {
    const res = await policiesApi.getTemplates({ status: 'active' })
    if (res.data) {
      availablePolicies.value = res.data
    } else {
      availablePolicies.value = []
    }
  } catch (err) {
    console.error('获取政策列表失败:', err)
    ElMessage.error('获取政策列表失败')
    availablePolicies.value = []
  } finally {
    policyLoading.value = false
  }
}

const assignPolicy = async () => {
  if (!selectedPolicyId.value) {
    ElMessage.warning('请选择一个销售政策')
    return
  }
  policyLoading.value = true
  try {
    const selectedPolicy = availablePolicies.value.find(p => p.id === selectedPolicyId.value)
    await stationsApi.assignPolicy(stationId.value, selectedPolicyId.value)
    stationData.policyId = selectedPolicyId.value
    stationData.policyName = selectedPolicy?.name
    stationData.policyType = selectedPolicy?.type
    if (selectedPolicy?.pricingRules) {
      stationData.prices = selectedPolicy.pricingRules.map(rule => ({
        productId: rule.productId,
        productName: rule.productName || '',
        price: rule.price,
        minQuantity: rule.minQuantity || 50
      }))
    }
    ElMessage.success('政策分配成功')
    showPolicyDialog.value = false
  } catch (err) {
    console.error('分配政策失败:', err)
    ElMessage.error('分配政策失败，请重试')
  } finally {
    policyLoading.value = false
  }
}

const fetchStationDetail = async () => {
  if (!stationId.value) {
    error.value = '水站ID无效'
    loading.value = false
    return
  }
  loading.value = true
  error.value = ''
  try {
    const res: any = await stationsApi.getDetail(stationId.value)
    if (res && res.data && typeof res.data === 'object') {
      Object.assign(stationData, res.data)
    } else if (res && typeof res === 'object') {
      Object.assign(stationData, res)
    } else if (res && res.message) {
      error.value = res.message || '获取水站详情失败'
    }
  } catch (err: any) {
    console.error('获取水站详情失败:', err)
    error.value = err.message || '获取水站详情失败，请刷新重试'
  } finally {
    loading.value = false
  }
}

const fetchRecentOrders = async () => {
  if (!stationId.value) return
  try {
    const res: any = await stationsApi.getOrders(stationId.value, 10)
    if (res.data) {
      recentOrders.value = res.data || []
    }
  } catch (err: any) {
    console.error('获取水站订单失败:', err)
  }
}

onMounted(async () => {
  await Promise.all([
    fetchStationDetail(),
    fetchRecentOrders()
  ])
})
</script>

<style scoped>
.station-detail-page {
  padding: 0;
}

.mb-4 {
  margin-bottom: 20px;
}

.mt-4 {
  margin-top: 16px;
}

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 0;
  color: #909399;
  gap: 12px;
}

.page-header-content {
  display: flex;
  align-items: center;
}

.page-title {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.station-header {
  display: flex;
  align-items: center;
  gap: 16px;
}

.station-info h3 {
  margin: 0 0 4px 0;
  font-size: 18px;
  font-weight: 600;
  color: #303133;
}

.station-info p {
  margin: 0;
  font-size: 14px;
  color: #909399;
}

.card-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.card-actions {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #f0f0f0;
  display: flex;
  gap: 12px;
}

.stat-card {
  padding: 16px;
  border-radius: 8px;
  text-align: center;
}

.stat-blue {
  background: linear-gradient(135deg, #e6f7ff 0%, #bae7ff 100%);
}

.stat-purple {
  background: linear-gradient(135deg, #f9f0ff 0%, #efdbff 100%);
}

.stat-orange {
  background: linear-gradient(135deg, #fff7e6 0%, #ffe7ba 100%);
}

.stat-red {
  background: linear-gradient(135deg, #fff1f0 0%, #ffccc7 100%);
}

.stat-label {
  font-size: 12px;
  color: #909399;
  margin-bottom: 8px;
}

.stat-value {
  font-size: 20px;
  font-weight: 600;
}

.stat-blue .stat-value {
  color: #1890ff;
}

.stat-purple .stat-value {
  color: #722ed1;
}

.stat-orange .stat-value {
  color: #fa8c16;
}

.stat-red .stat-value {
  color: #f5222d;
}

.stat-extra {
  font-size: 10px;
  color: #909399;
  margin-top: 4px;
}

.policy-item {
  padding: 12px;
  background: #fafafa;
  border-radius: 8px;
  text-align: center;
}

.policy-label {
  font-size: 12px;
  color: #909399;
  margin-bottom: 8px;
}

.policy-value {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
}

.price-section {
  padding-top: 16px;
  border-top: 1px solid #f0f0f0;
}

.section-label {
  font-size: 14px;
  font-weight: 600;
  color: #606266;
  margin-bottom: 8px;
}

.price-text {
  color: #f56c6c;
  font-weight: 600;
}

.data-list {
  display: flex;
  flex-direction: column;
}

.data-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 0;
  border-bottom: 1px solid #f0f0f0;
}

.data-item:last-child {
  border-bottom: none;
}

.data-label {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #606266;
  font-size: 14px;
}

.data-value {
  font-weight: 600;
  color: #303133;
}

.order-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.order-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px;
  background: #fafafa;
  border-radius: 8px;
}

.order-info {
  flex: 1;
}

.order-no {
  margin: 0 0 4px 0;
  font-size: 14px;
  font-weight: 600;
  color: #303133;
  font-family: monospace;
}

.order-time {
  margin: 0;
  font-size: 12px;
  color: #909399;
}

.order-right {
  text-align: right;
}

.order-amount {
  margin: 0 0 4px 0;
  font-size: 14px;
  font-weight: 600;
  color: #303133;
}

.staff-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.staff-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: #fafafa;
  border-radius: 8px;
}

.staff-avatar {
  width: 40px;
  height: 40px;
  background: #e6f4ff;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.staff-info {
  flex: 1;
}

.staff-name {
  margin: 0 0 4px 0;
  font-size: 14px;
  font-weight: 600;
  color: #303133;
}

.staff-phone {
  margin: 0;
  font-size: 12px;
  color: #909399;
}

.policy-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.policy-name {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.policy-selection {
  padding: 8px 0;
}

.policy-tip {
  color: #606266;
  font-size: 14px;
}

.policy-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.policy-dialog-content {
  max-height: 60vh;
  overflow-y: auto;
}

.policy-list-container {
  max-height: 400px;
  overflow-y: auto;
}

.policy-list {
  width: 100%;
  display: flex;
  flex-direction: column;
}

.policy-card-item {
  cursor: pointer;
  transition: all 0.3s;
}

.policy-card-item:hover {
  border-color: #409eff;
}

.policy-card-selected {
  border-color: #409eff !important;
  background-color: #f0f9ff;
}

.policy-radio {
  width: 100%;
  display: flex;
  align-items: flex-start;
}

.policy-radio :deep(.el-radio__label) {
  flex: 1;
}

.policy-card-content {
  padding: 0;
}

.policy-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.policy-name {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.policy-desc {
  font-size: 14px;
  color: #909399;
  margin-bottom: 8px;
  line-height: 1.5;
}

.policy-meta {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 13px;
  color: #409eff;
}
</style>
