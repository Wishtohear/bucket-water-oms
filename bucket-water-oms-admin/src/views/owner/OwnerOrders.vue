<template>
  <div class="orders-container">
    <el-card shadow="never">
      <template #header>
        <div class="order-tabs">
          <el-radio-group v-model="orderType" @change="handleTypeChange">
            <el-radio-button label="warehouse">仓库订单</el-radio-button>
            <el-radio-button label="station">水站配送订单</el-radio-button>
          </el-radio-group>
        </div>
        <div class="toolbar">
          <el-form :inline="true" :model="filters">
            <el-form-item label="">
              <el-input v-model="filters.keyword" placeholder="搜索订单号..." clearable style="width: 200px" />
            </el-form-item>
            <el-form-item label="">
              <el-select v-model="filters.status" placeholder="订单状态" clearable style="width: 120px">
                <el-option label="全部" value="" />
                <el-option v-if="orderType === 'station'" label="待派单" value="pending_dispatch" />
                <el-option v-if="orderType === 'station'" label="待接单" value="pending_accept" />
                <el-option label="配送中" value="delivering" />
                <el-option label="已完成" value="completed" />
                <el-option v-if="orderType === 'warehouse'" label="待审查" value="pending_review" />
                <el-option v-if="orderType === 'warehouse'" label="已接单" value="reviewed" />
              </el-select>
            </el-form-item>
            <el-form-item>
              <el-button @click="handleSearch">查询</el-button>
              <el-button @click="handleReset">重置</el-button>
            </el-form-item>
          </el-form>
          <div class="toolbar-right">
            <el-button v-if="orderType === 'warehouse'" type="primary" @click="goToCreateOrder">
              <el-icon><Plus /></el-icon>
              新建订单
            </el-button>
          </div>
        </div>
      </template>

      <el-table :data="orders" stripe v-loading="loading" @row-click="handleRowClick">
        <el-table-column label="订单来源" width="100">
          <template #default="{ row }">
            <el-tag :type="row.sourceType === 'station' ? 'success' : 'primary'" size="small">
              {{ row.sourceType === 'station' ? '水站配送' : '仓库配送' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="orderNo" label="订单号" width="180" />
        <el-table-column :label="orderType === 'station' ? '目的地' : '仓库'" width="150">
          <template #default="{ row }">
            {{ row.stationName || row.warehouseName || '-' }}
          </template>
        </el-table-column>
        <el-table-column v-if="orderType === 'station'" label="配送员" width="120">
          <template #default="{ row }">
            <span v-if="row.driverName">{{ row.driverName }}</span>
            <el-tag v-else type="warning" size="small">待派单</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="订单金额" width="120">
          <template #default="{ row }">
            <span class="price-text">¥{{ row.totalAmount }}</span>
          </template>
        </el-table-column>
        <el-table-column label="桶数" width="80">
          <template #default="{ row }">
            {{ row.totalBuckets }}桶
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)" size="small">
              {{ row.statusText }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="下单时间" width="180">
          <template #default="{ row }">
            {{ row.createTime }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click.stop="goToOrderDetail(row.id)">查看详情</el-button>
            <el-button
              v-if="row.status === 'pending_review'"
              type="danger"
              link
              size="small"
              @click.stop="handleCancel(row)"
            >
              取消订单
            </el-button>
            <el-button
              v-if="orderType === 'station' && row.status === 'pending_dispatch'"
              type="warning"
              link
              size="small"
              @click.stop="goToDispatch(row)"
            >
              去派单
            </el-button>
            <el-button
              v-if="row.status === 'completed'"
              type="primary"
              link
              size="small"
              @click.stop="handleReorder(row)"
            >
              再来一单
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-container">
        <el-pagination
          v-model:current-page="currentPage"
          :page-size="pageSize"
          :total="total"
          layout="total, prev, pager, next"
          @current-change="handlePageChange"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, watch, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { stationOwnerApi, ordersApi } from '@/api'

const router = useRouter()

const loading = ref(true)
const currentPage = ref(1)
const pageSize = ref(20)
const total = ref(0)
const orderType = ref<'warehouse' | 'station'>('warehouse')

const defaultProductImage = 'https://modao.cc/agent-py/media/generated_images/2026-04-19/a334311da7854958a4c575d1ed971989.jpg'

const filters = reactive({
  keyword: '',
  status: ''
})

const orders = ref<any[]>([])

const getStatusType = (status: string) => {
  const typeMap: Record<string, string> = {
    pending_review: 'warning',
    reviewed: 'primary',
    dispatched: 'primary',
    delivering: 'primary',
    completed: 'success',
    rejected: 'danger',
    cancelled: 'info'
  }
  return typeMap[status] || 'info'
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

const loadOrders = async () => {
  try {
    loading.value = true
    const params: any = {
      page: currentPage.value,
      size: pageSize.value
    }
    if (filters.status) {
      params.status = filters.status
    }
    if (filters.keyword) {
      params.keyword = filters.keyword
    }

    let res
    if (orderType.value === 'station') {
      params.sourceType = 'station'
      res = await ordersApi.getPage(params)
    } else {
      res = await stationOwnerApi.getOrders(params)
    }

    const dataList = res?.data?.list || res?.data || []

    if (Array.isArray(dataList)) {
      orders.value = dataList.map((order: any) => ({
        id: order.orderId || order.id,
        orderNo: order.orderNo,
        warehouseId: order.warehouseId,
        warehouseName: order.warehouseName || '未知仓库',
        stationId: order.stationId,
        stationName: order.stationName || order.address || '未知水站',
        driverId: order.driverId,
        driverName: order.driverName || '',
        sourceType: order.sourceType || (orderType.value === 'station' ? 'station' : 'warehouse'),
        status: order.status,
        statusText: getStatusText(order.status),
        totalAmount: typeof order.totalAmount === 'number' ? Number(order.totalAmount).toFixed(2) : String(order.totalAmount || '0.00'),
        totalBuckets: order.totalBuckets || order.totalQuantity || 0,
        createTime: formatTime(order.createTime),
        estimatedTime: '14:30',
        rejectReason: order.rejectReason,
        items: (order.items || []).map((item: any) => ({
          productId: item.productId,
          productName: item.productName,
          price: item.price,
          quantity: item.quantity,
          image: defaultProductImage
        }))
      }))
      total.value = res?.data?.total || dataList.length
    } else {
      orders.value = []
      total.value = 0
    }
  } catch (error: any) {
    ElMessage.error('加载订单列表失败：' + (error.message || '未知错误'))
    orders.value = []
  } finally {
    loading.value = false
  }
}

const handleTypeChange = () => {
  currentPage.value = 1
  filters.status = ''
  loadOrders()
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

const handleSearch = () => {
  currentPage.value = 1
  loadOrders()
}

const handleReset = () => {
  filters.keyword = ''
  filters.status = ''
  currentPage.value = 1
  loadOrders()
}

const handlePageChange = (page: number) => {
  currentPage.value = page
  loadOrders()
}

const handleRowClick = (row: any) => {
  goToOrderDetail(row.id)
}

const goToOrderDetail = (orderId: string) => {
  router.push(`/station/orders/${orderId}`)
}

const goToCreateOrder = () => {
  router.push('/station/create-order')
}

const goToDispatch = (order: any) => {
  router.push(`/station/dispatch/${order.id}`)
}

const handleCancel = async (order: any) => {
  try {
    await ElMessageBox.confirm('确定要取消该订单吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    await stationOwnerApi.cancelOrder(order.id, '用户主动取消')
    ElMessage.success('订单已取消')
    loadOrders()
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error('取消订单失败：' + (error.message || '未知错误'))
    }
  }
}

const handleReorder = (order: any) => {
  router.push({
    path: '/station/create-order',
    query: { fromOrder: order.id }
  })
}

watch([() => filters.status], () => {
  handleSearch()
})

onMounted(() => {
  loadOrders()
})
</script>

<style scoped>
.orders-container {
  padding: 0;
}

.toolbar {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
  align-items: flex-start;
}

.order-tabs {
  margin-bottom: 16px;
}

.toolbar-right {
  display: flex;
  gap: 12px;
}
.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}

.price-text {
  font-weight: bold;
  color: #409eff;
}
</style>
