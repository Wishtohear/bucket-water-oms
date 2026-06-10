<template>
  <div class="dashboard-container">
    <el-row :gutter="20" class="mb-4">
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <el-statistic title="总额度" :value="dashboardData.creditLimit">
            <template #prefix>
              <el-icon class="stat-icon"><Money /></el-icon>
            </template>
          </el-statistic>
          <div class="stat-action">
            <el-button type="primary" size="small" @click="handleRecharge">充值</el-button>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <el-statistic title="剩余额度" :value="dashboardData.availableCredit">
            <template #prefix>
              <el-icon class="stat-icon credit"><CreditCard /></el-icon>
            </template>
          </el-statistic>
          <div class="stat-sub">
            已用额度: ¥{{ dashboardData.usedCredit }}
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <el-statistic title="押金桶总数" :value="dashboardData.totalBuckets">
            <template #prefix>
              <el-icon class="stat-icon bucket"><Box /></el-icon>
            </template>
          </el-statistic>
          <div class="stat-sub">
            账期: {{ dashboardData.billingCycle || 30 }}天
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card" :class="{ 'alert-card': dashboardData.overThreshold }">
          <el-statistic title="累计欠桶" :value="dashboardData.owedBucketNum">
            <template #prefix>
              <el-icon class="stat-icon" :class="{ alert: dashboardData.overThreshold }"><Warning /></el-icon>
            </template>
          </el-statistic>
          <div class="stat-action" v-if="dashboardData.overThreshold">
            <el-button type="danger" size="small" @click="handlePayDeposit">补缴押金</el-button>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" class="mb-4">
      <el-col :span="16">
        <el-card shadow="never" class="quick-actions-card">
          <template #header>
            <div class="card-header">
              <span>快捷功能</span>
            </div>
          </template>
          <div class="quick-actions">
            <el-button v-for="item in quickActions" :key="item.action" @click="handleQuickAction(item.action)">
              <el-icon :size="20" :class="item.iconClass">
                <component :is="item.icon" />
              </el-icon>
              <span class="ml-2">{{ item.name }}</span>
            </el-button>
          </div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="never" class="notifications-card">
          <template #header>
            <div class="card-header">
              <span>通知公告</span>
              <el-button link type="primary" size="small">查看全部</el-button>
            </div>
          </template>
          <div class="notifications-list">
            <div v-for="notice in dashboardData.notifications" :key="notice.id" class="notification-item">
              <div class="notification-title">{{ notice.title }}</div>
              <div class="notification-content">{{ notice.content }}</div>
              <div class="notification-time">{{ notice.createdAt }}</div>
            </div>
            <el-empty v-if="dashboardData.notifications.length === 0" description="暂无通知" :image-size="60" />
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" class="mb-4">
      <el-col :span="24">
        <el-card shadow="never">
          <template #header>
            <div class="card-header">
              <span>可订货商品</span>
              <el-button link type="primary" @click="goToProducts">全部商品</el-button>
            </div>
          </template>
          <div v-if="productsLoading" class="loading-container">
            <el-icon class="is-loading"><Loading /></el-icon>
          </div>
          <el-table v-else :data="products" stripe style="width: 100%">
            <el-table-column label="商品图片" width="100">
              <template #default="{ row }">
                <el-image :src="row.image || defaultProductImage" fit="cover" style="width: 60px; height: 60px; border-radius: 4px;">
                  <template #error>
                    <div class="image-placeholder">
                      <el-icon><Picture /></el-icon>
                    </div>
                  </template>
                </el-image>
              </template>
            </el-table-column>
            <el-table-column prop="name" label="商品名称" min-width="150" />
            <el-table-column prop="category" label="分类" width="120" />
            <el-table-column prop="spec" label="规格" width="120" />
            <el-table-column label="价格" width="120">
              <template #default="{ row }">
                <span class="price-text">¥{{ row.price }}</span>
                <el-tag v-if="row.tierPrice" type="info" size="small">阶梯价</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="库存状态" width="100">
              <template #default="{ row }">
                <el-tag :type="row.stock > 100 ? 'success' : 'warning'" size="small">
                  {{ row.stock > 100 ? '充足' : '紧张' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="120" fixed="right">
              <template #default="{ row }">
                <el-button type="primary" size="small" @click="addToCart(row)">加入订单</el-button>
              </template>
            </el-table-column>
          </el-table>
          <el-empty v-if="products.length === 0 && !productsLoading" description="暂无可订货商品" />
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20">
      <el-col :span="24">
        <el-card shadow="never">
          <template #header>
            <div class="card-header">
              <span>近期订单</span>
              <el-button link type="primary" @click="goToOrders">查看全部</el-button>
            </div>
          </template>
          <el-table :data="dashboardData.recentOrders" stripe style="width: 100%" v-loading="ordersLoading">
            <el-table-column prop="orderNo" label="订单号" width="180" />
            <el-table-column label="订单金额" width="120">
              <template #default="{ row }">
                <span class="price-text">¥{{ row.totalAmount }}</span>
              </template>
            </el-table-column>
            <el-table-column label="桶数" width="100">
              <template #default="{ row }">
                {{ row.totalQuantity }}桶
              </template>
            </el-table-column>
            <el-table-column label="状态" width="100">
              <template #default="{ row }">
                <el-tag :type="getStatusType(row.status)" size="small">
                  {{ row.statusText }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="createdAt" label="下单时间" width="180" />
            <el-table-column label="操作" width="120" fixed="right">
              <template #default="{ row }">
                <el-button type="primary" link size="small" @click="goToOrderDetail(row.orderId)">查看详情</el-button>
              </template>
            </el-table-column>
          </el-table>
          <el-empty v-if="dashboardData.recentOrders.length === 0 && !ordersLoading" description="暂无订单" />
        </el-card>
      </el-col>
    </el-row>

    <el-dialog v-model="showRechargeDialog" title="账户充值" width="400px">
      <el-form :model="rechargeForm" label-width="80px">
        <el-form-item label="充值金额">
          <el-input-number v-model="rechargeForm.amount" :min="1" :precision="2" style="width: 100%" />
        </el-form-item>
        <el-form-item label="快捷金额">
          <el-space>
            <el-button v-for="amount in [100, 500, 1000, 2000]" :key="amount" @click="rechargeForm.amount = amount">
              ¥{{ amount }}
            </el-button>
          </el-space>
        </el-form-item>
        <el-form-item label="支付方式">
          <el-select v-model="rechargeForm.paymentMethod" style="width: 100%">
            <el-option label="微信支付" value="wechat" />
            <el-option label="银行卡" value="bank" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showRechargeDialog = false">取消</el-button>
        <el-button type="primary" @click="confirmRecharge" :loading="rechargeLoading">确认充值</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Money, CreditCard, Box, Warning, ShoppingCart, List, Headset, Ticket, Picture, Loading } from '@element-plus/icons-vue'
import { stationOwnerApi } from '@/api'

const router = useRouter()

const loading = ref(true)
const productsLoading = ref(false)
const ordersLoading = ref(false)
const showRechargeDialog = ref(false)
const rechargeLoading = ref(false)

const defaultProductImage = 'https://modao.cc/agent-py/media/generated_images/2026-04-19/a334311da7854958a4c575d1ed971989.jpg'

const dashboardData = reactive({
  accountBalance: 0,
  creditLimit: 0,
  usedCredit: 0,
  availableCredit: 0,
  owedBucketNum: 0,
  totalBuckets: 0,
  billingCycle: 30,
  overThreshold: false,
  recentOrders: [] as any[],
  notifications: [] as any[]
})

const products = ref<any[]>([])

const rechargeForm = reactive({
  amount: 100,
  paymentMethod: 'wechat'
})

const quickActions = [
  { name: '一键下单', icon: ShoppingCart, action: 'order', iconClass: 'text-primary' },
  { name: '订单查询', icon: List, action: 'orders', iconClass: 'text-success' },
  { name: '售后管理', icon: Headset, action: 'after-sales', iconClass: 'text-purple' },
  { name: '水票管理', icon: Ticket, action: 'tickets', iconClass: 'text-danger' }
]

const getStatusType = (status: string) => {
  const typeMap: Record<string, string> = {
    pending_review: 'warning',
    reviewed: 'primary',
    dispatched: 'primary',
    delivering: 'primary',
    completed: 'success',
    cancelled: 'info',
    rejected: 'danger'
  }
  return typeMap[status] || 'info'
}

const loadDashboard = async () => {
  try {
    loading.value = true
    const res = await stationOwnerApi.getDashboard()
    if (res && (res as any).data) {
      const data = (res as any).data
      dashboardData.accountBalance = Number(data.accountBalance) || 0
      dashboardData.creditLimit = Number(data.creditLimit) || 0
      dashboardData.usedCredit = Number(data.usedCredit) || 0
      dashboardData.availableCredit = Number(data.availableCredit) || 0
      dashboardData.owedBucketNum = data.owedBucketNum || 0
      dashboardData.totalBuckets = data.totalBuckets || 100
      dashboardData.billingCycle = data.billingCycle || 30
      dashboardData.overThreshold = data.overThreshold || false
      dashboardData.recentOrders = data.recentOrders || []
      dashboardData.notifications = data.notifications || []
    }
  } catch (error: any) {
    console.error('加载仪表盘数据失败:', error)
  } finally {
    loading.value = false
  }
}

const loadProducts = async () => {
  try {
    productsLoading.value = true
    const res = await stationOwnerApi.getProducts()
    const productsData = Array.isArray((res as any).data) ? (res as any).data : ((res as any)?.data?.data || [])
    
    products.value = productsData.map((p: any) => ({
      id: p.id || p.productId,
      name: p.name,
      category: p.category,
      spec: p.spec || p.specification,
      image: p.image || defaultProductImage,
      price: p.price || '0.00',
      stock: p.stock || 0,
      tierPrice: p.tierPrice || false,
      minOrderQuantity: p.minOrderQuantity || 1
    }))
    
    try {
      const priceRes = await stationOwnerApi.getProductPrices()
      const priceData = Array.isArray((priceRes as any).data) ? (priceRes as any).data : (((priceRes as any)?.data)?.data || [])
      priceData.forEach((priceInfo: any) => {
        const product = products.value.find((p: any) => String(p.id) === String(priceInfo.productId))
        if (product) {
          product.price = String(priceInfo.unitPrice)
          product.minOrderQuantity = priceInfo.minOrderQuantity || 1
          if (priceInfo.tierPrice) {
            product.tierPrice = true
          }
        }
      })
    } catch (e) {
      console.log('获取商品价格失败，使用默认价格')
    }
  } catch (error: any) {
    console.error('加载产品列表失败:', error)
  } finally {
    productsLoading.value = false
  }
}

const loadRecentOrders = async () => {
  try {
    ordersLoading.value = true
    const res = await stationOwnerApi.getOrders({ page: 1, size: 5 })
    if (res && Array.isArray(res)) {
      dashboardData.recentOrders = res.slice(0, 5).map((order: any) => ({
        orderId: order.id,
        orderNo: order.orderNo,
        totalAmount: typeof order.totalAmount === 'number' ? Number(order.totalAmount).toFixed(2) : String(order.totalAmount || '0.00'),
        totalQuantity: order.totalBuckets || order.totalQuantity || 0,
        status: order.status,
        statusText: getStatusText(order.status),
        createdAt: formatTime(order.createTime)
      }))
    }
  } catch (error: any) {
    console.error('加载订单列表失败:', error)
  } finally {
    ordersLoading.value = false
  }
}

const getStatusText = (status: string) => {
  const map: Record<string, string> = {
    pending_review: '待审查',
    reviewed: '已接单',
    dispatched: '已派单',
    delivering: '配送中',
    completed: '已完成',
    cancelled: '已取消',
    rejected: '已拒单'
  }
  return map[status] || status
}

const formatTime = (time: string) => {
  if (!time) return ''
  const date = new Date(time)
  const now = new Date()
  const diff = now.getTime() - date.getTime()
  const oneDay = 24 * 60 * 60 * 1000

  if (diff < oneDay && date.getDate() === now.getDate()) {
    return '今天 ' + date.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
  }
  if (diff < 2 * oneDay && date.getDate() === now.getDate() - 1) {
    return '昨天 ' + date.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
  }
  return date.toLocaleDateString('zh-CN', { month: '2-digit', day: '2-digit' }) + ' ' +
         date.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
}

const handleQuickAction = (action: string) => {
  const routes: Record<string, string> = {
    order: '/station/create-order',
    orders: '/station/orders',
    'after-sales': '/station/after-sales',
    tickets: '/station/tickets'
  }
  if (routes[action]) {
    router.push(routes[action])
  }
}

const goToProducts = () => {
  router.push('/station/products')
}

const goToOrders = () => {
  router.push('/station/orders')
}

const goToOrderDetail = (orderId: string) => {
  router.push(`/station/orders/${orderId}`)
}

const addToCart = (product: any) => {
  ElMessage.success('已添加 ' + product.name + ' 到购物车（最低起订' + (product.minOrderQuantity || 1) + '桶）')
  router.push({
    path: '/station/create-order',
    query: {
      addProduct: JSON.stringify({
        id: product.id,
        name: product.name,
        price: product.price,
        minOrderQuantity: product.minOrderQuantity || 1
      })
    }
  })
}

const handleRecharge = () => {
  router.push('/station/recharge')
}

const handlePayDeposit = () => {
  ElMessage.info('请到空桶管理页面进行押金补缴')
}

const confirmRecharge = async () => {
  if (!rechargeForm.amount || rechargeForm.amount <= 0) {
    ElMessage.warning('请输入有效的充值金额')
    return
  }

  try {
    rechargeLoading.value = true
    await stationOwnerApi.recharge({
      amount: rechargeForm.amount,
      paymentMethod: rechargeForm.paymentMethod
    })
    ElMessage.success('充值成功')
    showRechargeDialog.value = false
    loadDashboard()
  } catch (error: any) {
    ElMessage.error('充值失败：' + (error.message || '未知错误'))
  } finally {
    rechargeLoading.value = false
  }
}

onMounted(() => {
  loadDashboard()
  loadProducts()
  loadRecentOrders()
})
</script>

<style scoped>
.dashboard-container {
  padding: 0;
}

.mb-4 {
  margin-bottom: 20px;
}

.stat-card {
  height: 100%;
}

.stat-card :deep(.el-statistic__head) {
  font-size: 14px;
  color: #909399;
}

.stat-card :deep(.el-statistic__content) {
  font-size: 24px;
  font-weight: bold;
  color: #303133;
}

.stat-icon {
  font-size: 20px;
  color: #409eff;
  margin-right: 8px;
}

.stat-icon.credit {
  color: #67c23a;
}

.stat-icon.bucket {
  color: #9c27b0;
}

.stat-icon.alert {
  color: #f56c6c;
}

.alert-card {
  border: 1px solid #f56c6c;
}

.stat-action {
  margin-top: 12px;
}

.stat-sub {
  margin-top: 8px;
  font-size: 12px;
  color: #909399;
}

.quick-actions-card {
  height: 100%;
}

.quick-actions {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.quick-actions .el-button {
  padding: 20px 24px;
  font-size: 14px;
}

.notifications-card {
  height: 100%;
}

.notifications-list {
  max-height: 200px;
  overflow-y: auto;
}

.notification-item {
  padding: 12px 0;
  border-bottom: 1px solid #f0f0f0;
}

.notification-item:last-child {
  border-bottom: none;
}

.notification-title {
  font-weight: 500;
  color: #303133;
  margin-bottom: 4px;
}

.notification-content {
  font-size: 12px;
  color: #909399;
  margin-bottom: 4px;
}

.notification-time {
  font-size: 12px;
  color: #c0c4cc;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: 500;
}

.loading-container {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 60px 0;
}

.price-text {
  font-weight: bold;
  color: #409eff;
  margin-right: 8px;
}

.image-placeholder {
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f5f7fa;
  border-radius: 4px;
  color: #c0c4cc;
}

.text-primary {
  color: #409eff;
}

.text-success {
  color: #67c23a;
}

.text-purple {
  color: #9c27b0;
}

.text-danger {
  color: #f56c6c;
}

.ml-2 {
  margin-left: 8px;
}
</style>
