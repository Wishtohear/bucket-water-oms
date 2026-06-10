<template>
  <div class="aftersales-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span>售后管理</span>
          <el-button type="primary" @click="goToApply">
            <el-icon><Plus /></el-icon>
            发起售后申请
          </el-button>
        </div>
      </template>

      <el-tabs v-model="activeTab" @tab-change="handleTabChange">
        <el-tab-pane label="全部" name="all" />
        <el-tab-pane label="待处理" name="pending">
          <template #label>
            <span>待处理<span v-if="tabCounts.pending > 0" class="tab-badge">{{ tabCounts.pending }}</span></span>
          </template>
        </el-tab-pane>
        <el-tab-pane label="处理中" name="processing">
          <template #label>
            <span>处理中<span v-if="tabCounts.processing > 0" class="tab-badge">{{ tabCounts.processing }}</span></span>
          </template>
        </el-tab-pane>
        <el-tab-pane label="已完成" name="completed">
          <template #label>
            <span>已完成<span v-if="tabCounts.completed > 0" class="tab-badge">{{ tabCounts.completed }}</span></span>
          </template>
        </el-tab-pane>
        <el-tab-pane label="已拒绝" name="rejected">
          <template #label>
            <span>已拒绝<span v-if="tabCounts.rejected > 0" class="tab-badge">{{ tabCounts.rejected }}</span></span>
          </template>
        </el-tab-pane>
      </el-tabs>

      <el-table :data="filteredList" stripe v-loading="loading" @row-click="goToDetail">
        <el-table-column label="售后单号" width="180">
          <template #default="{ row }">
            {{ row.afterSalesNo }}
          </template>
        </el-table-column>
        <el-table-column label="关联订单" width="180">
          <template #default="{ row }">
            {{ row.orderNo }}
          </template>
        </el-table-column>
        <el-table-column label="售后类型" width="100">
          <template #default="{ row }">
            <el-tag :type="getTypeTagType(row.type)">{{ getTypeText(row.type) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="商品" min-width="150">
          <template #default="{ row }">
            {{ row.productName }} × {{ row.quantity }}
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusTagType(row.status)">{{ getStatusText(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="申请时间" width="180">
          <template #default="{ row }">
            {{ row.createdAt }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click.stop="goToDetail(row.id)">详情</el-button>
            <el-button
              v-if="row.status === 'pending'"
              type="danger"
              link
              size="small"
              @click.stop="cancelAfterSales(row)"
            >
              取消
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

    <el-dialog v-model="showDetailModal" title="售后详情" width="600px">
      <div v-if="currentDetail">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="售后单号">{{ currentDetail.afterSalesNo }}</el-descriptions-item>
          <el-descriptions-item label="售后类型">
            <el-tag :type="getTypeTagType(currentDetail.type)">{{ getTypeText(currentDetail.type) }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="getStatusTagType(currentDetail.status)">{{ getStatusText(currentDetail.status) }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="申请时间">{{ currentDetail.createdAt }}</el-descriptions-item>
        </el-descriptions>

        <el-divider />

        <el-descriptions title="关联订单" :column="1" border>
          <el-descriptions-item label="订单号">{{ currentDetail.orderNo }}</el-descriptions-item>
        </el-descriptions>

        <el-divider />

        <el-descriptions title="商品信息" :column="1" border>
          <el-descriptions-item label="商品名称">{{ currentDetail.productName }}</el-descriptions-item>
          <el-descriptions-item label="售后数量">{{ currentDetail.quantity }}</el-descriptions-item>
        </el-descriptions>

        <el-divider />

        <el-form label-width="80px" v-if="currentDetail.reason">
          <el-form-item label="原因说明">
            <span>{{ currentDetail.reason }}</span>
          </el-form-item>
        </el-form>

        <div v-if="currentDetail.result" class="result-box">
          <el-alert :title="'处理结果: ' + currentDetail.result" type="success" :closable="false" show-icon />
          <div v-if="currentDetail.handledAt" class="handled-time">处理时间: {{ currentDetail.handledAt }}</div>
        </div>
      </div>
      <template #footer>
        <el-button @click="showDetailModal = false">关闭</el-button>
        <el-button v-if="currentDetail && currentDetail.orderId" type="primary" @click="goToOrderDetail(currentDetail.orderId)">
          查看订单
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { stationOwnerApi } from '@/api'

const router = useRouter()

const loading = ref(true)

const activeTab = ref('all')
const currentPage = ref(1)
const pageSize = ref(20)
const total = ref(0)

const tabCounts = reactive({
  pending: 0,
  processing: 0,
  completed: 0,
  rejected: 0
})

const afterSalesList = ref<any[]>([])

const filteredList = computed(() => {
  if (activeTab.value === 'all') {
    return afterSalesList.value
  }
  return afterSalesList.value.filter(item => item.status === activeTab.value)
})

const showDetailModal = ref(false)
const currentDetail = ref<any>(null)

const getTypeText = (type: string) => {
  const map: Record<string, string> = {
    resupply: '补货',
    refund: '退款',
    return: '退货'
  }
  return map[type] || type
}

const getTypeTagType = (type: string) => {
  const map: Record<string, string> = {
    resupply: 'primary',
    refund: 'success',
    return: 'warning'
  }
  return map[type] || ''
}

const getStatusText = (status: string) => {
  const map: Record<string, string> = {
    pending: '待处理',
    processing: '处理中',
    completed: '已完成',
    rejected: '已拒绝',
    cancelled: '已取消'
  }
  return map[status] || status
}

const getStatusTagType = (status: string) => {
  const map: Record<string, string> = {
    pending: 'warning',
    processing: 'primary',
    completed: 'success',
    rejected: 'danger',
    cancelled: 'info'
  }
  return map[status] || ''
}

const loadAfterSalesList = async () => {
  try {
    loading.value = true
    const res = await stationOwnerApi.getAfterSalesList({
      status: activeTab.value === 'all' ? undefined : activeTab.value,
      page: currentPage.value,
      size: pageSize.value
    })

    if (res && (res as any).list) {
      const response = res as any
      afterSalesList.value = response.list.map((item: any) => ({
        id: item.id,
        afterSalesNo: item.afterSalesNo || item.id,
        orderId: item.orderId,
        orderNo: item.orderNo || '',
        type: item.type,
        productId: item.productId,
        productName: item.productName || '未知商品',
        productImage: item.productImage || '',
        quantity: item.quantity || 0,
        reason: item.reason || '',
        images: item.images || [],
        status: item.status,
        createdAt: item.createdAt || '',
        handledAt: item.handledAt,
        result: item.result
      }))
      total.value = response.total || response.list.length
    } else if (Array.isArray(res)) {
      afterSalesList.value = res.map((item: any) => ({
        id: item.id,
        afterSalesNo: item.afterSalesNo || item.id,
        orderId: item.orderId,
        orderNo: item.orderNo || '',
        type: item.type,
        productId: item.productId,
        productName: item.productName || '未知商品',
        productImage: item.productImage || '',
        quantity: item.quantity || 0,
        reason: item.reason || '',
        images: item.images || [],
        status: item.status,
        createdAt: item.createdAt || '',
        handledAt: item.handledAt,
        result: item.result
      }))
      total.value = res.length
    } else {
      afterSalesList.value = []
      total.value = 0
    }

    updateTabCounts()
  } catch (error: any) {
    ElMessage.error('加载售后列表失败：' + (error.message || '未知错误'))
    afterSalesList.value = []
  } finally {
    loading.value = false
  }
}

const updateTabCounts = () => {
  const counts = {
    pending: 0,
    processing: 0,
    completed: 0,
    rejected: 0
  }

  afterSalesList.value.forEach(item => {
    if (counts[item.status as keyof typeof counts] !== undefined) {
      counts[item.status as keyof typeof counts]++
    }
  })

  tabCounts.pending = counts.pending
  tabCounts.processing = counts.processing
  tabCounts.completed = counts.completed
  tabCounts.rejected = counts.rejected
}

const handleTabChange = () => {
  currentPage.value = 1
  loadAfterSalesList()
}

const handlePageChange = (page: number) => {
  currentPage.value = page
  loadAfterSalesList()
}

const goToApply = () => {
  router.push('/station/after-sales/apply')
}

const cancelAfterSales = async (item: any) => {
  try {
    await stationOwnerApi.cancelAfterSales(item.id)
    ElMessage.success('已取消售后申请')
    loadAfterSalesList()
  } catch (error: any) {
    ElMessage.error('取消失败：' + (error.message || '未知错误'))
  }
}

const goToDetail = async (id: string) => {
  try {
    const detail = await stationOwnerApi.getAfterSalesById(id)
    currentDetail.value = detail
    showDetailModal.value = true
  } catch (error: any) {
    ElMessage.error('加载详情失败：' + (error.message || '未知错误'))
  }
}

const goToOrderDetail = (orderId: string) => {
  showDetailModal.value = false
  router.push(`/station/orders/${orderId}`)
}

onMounted(() => {
  loadAfterSalesList()
})
</script>

<style scoped>
.aftersales-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.tab-badge {
  display: inline-block;
  margin-left: 4px;
  padding: 2px 6px;
  font-size: 12px;
  background-color: #f56c6c;
  color: white;
  border-radius: 10px;
}

.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}

.result-box {
  margin-top: 16px;
}

.handled-time {
  margin-top: 8px;
  font-size: 12px;
  color: #909399;
}
</style>
