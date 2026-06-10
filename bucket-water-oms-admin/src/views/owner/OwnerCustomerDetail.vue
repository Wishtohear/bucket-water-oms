<template>
  <div class="customer-detail-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <el-button @click="goBack" :icon="ArrowLeft">返回</el-button>
          <div class="header-info">
            <span class="header-title">客户详情</span>
            <span class="header-subtitle">客户编号: {{ customer.id }}</span>
          </div>
          <el-button type="primary" @click="handleEdit">编辑信息</el-button>
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
                  <span>基本信息</span>
                </div>
              </template>
              <el-row :gutter="20" align="middle">
                <el-col :span="4">
                  <el-avatar :size="80" :src="customer.avatar || defaultAvatar" />
                </el-col>
                <el-col :span="20">
                  <div class="customer-info">
                    <div class="info-row">
                      <h3 class="customer-name">{{ customer.name }}</h3>
                      <el-tag :type="getCustomerTypeTagType(customer.type)">{{ customer.typeText }}</el-tag>
                    </div>
                    <p class="customer-phone">{{ customer.phone }}</p>
                    <p class="customer-address">
                      <el-icon><Location /></el-icon>
                      {{ customer.address }}
                    </p>
                  </div>
                </el-col>
              </el-row>

              <el-divider />

              <el-row :gutter="20">
                <el-col :span="6">
                  <div class="stat-item">
                    <p class="stat-label">账户余额</p>
                    <p class="stat-value" :class="customer.balance < 0 ? 'danger' : ''">
                      ¥{{ formatAmount(customer.balance) }}
                    </p>
                  </div>
                </el-col>
                <el-col :span="6">
                  <div class="stat-item">
                    <p class="stat-label">剩余水票</p>
                    <p class="stat-value">{{ customer.tickets }}张</p>
                  </div>
                </el-col>
                <el-col :span="6">
                  <div class="stat-item">
                    <p class="stat-label">欠桶数</p>
                    <p class="stat-value" :class="customer.owedBuckets > 0 ? 'danger' : ''">
                      {{ customer.owedBuckets }}个
                    </p>
                  </div>
                </el-col>
                <el-col :span="6">
                  <div class="stat-item">
                    <p class="stat-label">累计订单</p>
                    <p class="stat-value">{{ customer.totalOrders }}笔</p>
                  </div>
                </el-col>
              </el-row>
            </el-card>

            <el-card shadow="never" class="mb-4">
              <template #header>
                <div class="section-header">
                  <span>联系方式</span>
                </div>
              </template>
              <el-descriptions :column="2" border>
                <el-descriptions-item label="联系电话">{{ customer.phone }}</el-descriptions-item>
                <el-descriptions-item label="备用电话">{{ customer.backupPhone || '暂无' }}</el-descriptions-item>
                <el-descriptions-item label="微信">{{ customer.wechat || '暂无' }}</el-descriptions-item>
                <el-descriptions-item label="地址类型">{{ customer.addressType || '家庭' }}</el-descriptions-item>
                <el-descriptions-item label="详细地址" :span="2">{{ customer.address }}</el-descriptions-item>
                <el-descriptions-item label="备注" :span="2">{{ customer.note || '暂无' }}</el-descriptions-item>
              </el-descriptions>
              <div class="action-buttons mt-4">
                <el-button type="primary" :icon="Phone">拨打电话</el-button>
                <el-button type="success" :icon="Message">发送短信</el-button>
                <el-button :icon="List">查看历史地址</el-button>
              </div>
            </el-card>

            <el-card shadow="never">
              <template #header>
                <div class="section-header">
                  <span>最近订单</span>
                  <el-button type="primary" link>查看全部</el-button>
                </div>
              </template>
              <el-table :data="recentOrders" border stripe>
                <el-table-column label="订单号" prop="orderNo" min-width="150" />
                <el-table-column label="商品" prop="items" min-width="200">
                  <template #default="{ row }">
                    <span class="order-items">{{ row.items }}</span>
                  </template>
                </el-table-column>
                <el-table-column label="金额" prop="amount" width="100" align="center">
                  <template #default="{ row }">
                    <span class="order-amount">¥{{ row.amount }}</span>
                  </template>
                </el-table-column>
                <el-table-column label="时间" prop="time" width="160" />
                <el-table-column label="状态" width="100" align="center">
                  <template #default="{ row }">
                    <el-tag :type="getStatusTagType(row.status)">{{ row.statusText }}</el-tag>
                  </template>
                </el-table-column>
                <el-table-column label="操作" width="100" align="center">
                  <template #default="{ row }">
                    <el-button type="primary" link @click="goToOrder(row.id)">查看</el-button>
                  </template>
                </el-table-column>
              </el-table>
              <el-empty v-if="recentOrders.length === 0" description="暂无订单" />
            </el-card>
          </el-col>

          <el-col :span="8">
            <el-card shadow="never">
              <template #header>
                <div class="section-header">
                  <span>操作面板</span>
                </div>
              </template>
              <div class="action-panel">
                <el-button type="primary" size="large" class="action-btn">
                  <el-icon><ShoppingCart /></el-icon>
                  创建订单
                </el-button>
                <el-button size="large" class="action-btn">
                  <el-icon><Coin /></el-icon>
                  账户充值
                </el-button>
                <el-button size="large" class="action-btn">
                  <el-icon><Tickets /></el-icon>
                  购买水票
                </el-button>
                <el-button size="large" class="action-btn">
                  <el-icon><EditPen /></el-icon>
                  编辑信息
                </el-button>
              </div>
            </el-card>
          </el-col>
        </el-row>
      </template>
    </el-card>

    <el-dialog v-model="showEditDialog" title="编辑客户" width="500px" destroy-on-close>
      <el-form :model="editForm" label-width="100px">
        <el-form-item label="客户名称">
          <el-input v-model="editForm.name" placeholder="请输入客户名称" />
        </el-form-item>
        <el-form-item label="联系电话">
          <el-input v-model="editForm.phone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="地址">
          <el-input v-model="editForm.address" placeholder="请输入地址" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showEditDialog = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="confirmEdit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import {
  ArrowLeft, Loading, Location, Phone, Message, List,
  ShoppingCart, Coin, Tickets, EditPen
} from '@element-plus/icons-vue'
import { stationOwnerApi } from '@/api'
import { toast } from '@/composables/useToast'

const router = useRouter()
const route = useRoute()

const loading = ref(true)
const saving = ref(false)
const showEditDialog = ref(false)
const defaultAvatar = 'https://modao.cc/agent-py/media/generated_images/2026-04-19/c8552e5188ad493b88794201879bfbd0.jpg'

const customer = ref<any>({
  id: '',
  name: '',
  phone: '',
  avatar: '',
  type: 'regular',
  typeText: '常客',
  balance: 0,
  tickets: 0,
  owedBuckets: 0,
  totalOrders: 0,
  address: '',
  backupPhone: '',
  wechat: '',
  addressType: '',
  note: ''
})

const editForm = ref({
  name: '',
  phone: '',
  address: ''
})

const recentOrders = ref<any[]>([])

const loadCustomerDetail = async () => {
  try {
    loading.value = true
    const customerId = route.params.id as string
    const res = await stationOwnerApi.getCustomerById(customerId)

    if (res) {
      customer.value = {
        id: res.id || '',
        name: res.name || '',
        phone: res.phone || '',
        avatar: res.avatar || defaultAvatar,
        type: res.type || 'regular',
        typeText: getTypeText(res.type),
        balance: res.balance || 0,
        tickets: res.tickets || 0,
        owedBuckets: res.owedBuckets || 0,
        totalOrders: res.totalOrders || 0,
        address: res.address || '',
        backupPhone: res.backupPhone || '',
        wechat: res.wechat || '',
        addressType: res.addressType || '家庭',
        note: res.note || ''
      }

      recentOrders.value = []
    }
  } catch (error: any) {
    toast.error('加载客户详情失败：' + (error.message || '未知错误'))
  } finally {
    loading.value = false
  }
}

const getTypeText = (type: string) => {
  const map: Record<string, string> = {
    regular: '常客',
    vip: 'VIP',
    enterprise: '企业'
  }
  return map[type] || '常客'
}

const getCustomerTypeTagType = (type: string) => {
  const map: Record<string, string> = {
    regular: '',
    vip: 'danger',
    enterprise: 'info'
  }
  return map[type] || ''
}

const getStatusTagType = (status: string) => {
  const map: Record<string, string> = {
    pending_review: 'warning',
    preparing: 'primary',
    delivering: 'primary',
    completed: 'success',
    cancelled: 'info'
  }
  return map[status] || ''
}

const formatAmount = (amount: number) => {
  return amount.toFixed(2)
}

const goBack = () => {
  router.back()
}

const goToOrder = (orderId: string) => {
  router.push(`/station/orders/${orderId}`)
}

const handleEdit = () => {
  editForm.value = {
    name: customer.value.name,
    phone: customer.value.phone,
    address: customer.value.address
  }
  showEditDialog.value = true
}

const confirmEdit = async () => {
  if (!editForm.value.name || !editForm.value.phone) {
    toast.warning('请填写客户名称和联系电话')
    return
  }

  try {
    saving.value = true
    await stationOwnerApi.updateCustomer(customer.value.id, editForm.value)
    toast.success('客户信息已更新')
    showEditDialog.value = false
    loadCustomerDetail()
  } catch (error: any) {
    toast.error('更新失败：' + (error.message || '未知错误'))
  } finally {
    saving.value = false
  }
}

onMounted(() => {
  loadCustomerDetail()
})
</script>

<style scoped>
.customer-detail-container {
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
  font-weight: 600;
  font-size: 16px;
}

.customer-info {
  padding: 8px 0;
}

.info-row {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 8px;
}

.customer-name {
  font-size: 20px;
  font-weight: 600;
  color: #303133;
  margin: 0;
}

.customer-phone {
  font-size: 14px;
  color: #909399;
  margin-bottom: 8px;
}

.customer-address {
  font-size: 14px;
  color: #606266;
  display: flex;
  align-items: center;
  gap: 4px;
}

.stat-item {
  text-align: center;
  padding: 12px;
}

.stat-label {
  font-size: 12px;
  color: #909399;
  margin-bottom: 8px;
}

.stat-value {
  font-size: 20px;
  font-weight: 600;
  color: #303133;
}

.stat-value.danger {
  color: #F56C6C;
}

.action-buttons {
  display: flex;
  gap: 12px;
}

.order-items {
  font-size: 13px;
  color: #606266;
}

.order-amount {
  font-weight: 600;
  color: #409EFF;
}

.action-panel {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.action-btn {
  width: 100%;
  justify-content: flex-start;
}

.mb-4 {
  margin-bottom: 16px;
}

.mt-4 {
  margin-top: 16px;
}

:deep(.el-card__header) {
  padding: 12px 20px;
  border-bottom: 1px solid #ebeef5;
}

:deep(.el-card__body) {
  padding: 20px;
}
</style>
