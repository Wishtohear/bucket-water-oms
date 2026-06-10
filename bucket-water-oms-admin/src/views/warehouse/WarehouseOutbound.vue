<template>
  <div class="warehouse-outbound">
    <el-card shadow="never" class="mb-4">
      <template #header>
        <div class="header">
          <div>
            <h2 class="page-title">出库管理</h2>
            <p class="page-desc">管理商品出库单据</p>
          </div>
        </div>
      </template>
      <el-radio-group v-model="activeTab" @change="handleTabChange">
        <el-radio-button value="all">全部</el-radio-button>
        <el-radio-button value="ready">待出库</el-radio-button>
        <el-radio-button value="shipped">已出库</el-radio-button>
      </el-radio-group>
    </el-card>

    <el-card shadow="never" v-loading="loading">
      <template #header>
        <div class="table-header">
          <span>出库单列表</span>
          <span class="total-count">共 {{ outboundList.length }} 条记录</span>
        </div>
      </template>
      <el-table :data="outboundList" stripe style="width: 100%">
        <el-table-column prop="outboundNo" label="出库单号" width="180">
          <template #default="{ row }">
            <span class="mono">{{ row.outboundNo }}</span>
          </template>
        </el-table-column>
        <el-table-column label="关联订单" width="150">
          <template #default="{ row }">
            <span class="link-text">{{ row.orderNo || '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column label="商品数量" width="120" align="center">
          <template #default="{ row }">
            {{ row.totalQuantity || 0 }} 桶
          </template>
        </el-table-column>
        <el-table-column label="状态" width="120" align="center">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)" size="small">
              {{ row.statusText || getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="出库时间" width="180">
          <template #default="{ row }">
            {{ row.outboundTime || row.createTime }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" align="center">
          <template #default="{ row }">
            <el-button link type="primary" @click="viewDetail(row)">详情</el-button>
            <el-button
              v-if="row.status === 'ready'"
              link
              type="success"
              @click="handleConfirmOutbound(row)"
            >
              确认出库
            </el-button>
          </template>
        </el-table-column>
        <template #empty>
          <el-empty description="暂无出库数据" :image-size="80" />
        </template>
      </el-table>
    </el-card>

    <el-dialog v-model="showDetailDialog" title="出库单详情" width="700px">
      <div v-if="selectedOutbound" class="outbound-detail">
        <el-card shadow="never" class="info-card">
          <el-descriptions :column="2" border>
            <el-descriptions-item label="出库单号">
              <span class="mono">{{ selectedOutbound.outboundNo }}</span>
            </el-descriptions-item>
            <el-descriptions-item label="关联订单">
              <span class="link-text">{{ selectedOutbound.orderNo || '-' }}</span>
            </el-descriptions-item>
            <el-descriptions-item label="状态">
              <el-tag :type="getStatusType(selectedOutbound.status)" size="small">
                {{ selectedOutbound.statusText || getStatusText(selectedOutbound.status) }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="出库时间">
              {{ selectedOutbound.outboundTime || selectedOutbound.createTime || '-' }}
            </el-descriptions-item>
          </el-descriptions>
        </el-card>

        <el-card v-if="selectedOutbound.driverInfo" shadow="never" class="info-card">
          <template #header>
            <span>配送信息</span>
          </template>
          <div class="driver-info">
            <el-avatar :size="48" :icon="UserFilled" />
            <div class="driver-details">
              <p class="driver-name">{{ selectedOutbound.driverInfo.name }}</p>
              <p class="driver-phone">{{ selectedOutbound.driverInfo.phone }}</p>
              <p v-if="selectedOutbound.driverInfo.vehicleNo" class="driver-vehicle">
                车牌号: {{ selectedOutbound.driverInfo.vehicleNo }}
              </p>
            </div>
          </div>
        </el-card>

        <el-card shadow="never" class="info-card">
          <template #header>
            <span>出库明细</span>
          </template>
          <el-table :data="selectedOutbound.items || []" stripe>
            <el-table-column prop="productName" label="商品名称" />
            <el-table-column prop="quantity" label="出库数量" align="right">
              <template #default="{ row }">
                {{ row.quantity }} 桶
              </template>
            </el-table-column>
            <template #empty>
              <el-empty description="暂无明细数据" :image-size="60" />
            </template>
          </el-table>
          <div class="total-row">
            <span>合计</span>
            <span class="total-amount">{{ selectedOutbound.totalQuantity || 0 }} 桶</span>
          </div>
        </el-card>

        <div v-if="selectedOutbound.remark" class="remark-card">
          <p class="remark-label">备注</p>
          <p class="remark-content">{{ selectedOutbound.remark }}</p>
        </div>

        <div v-if="selectedOutbound.status === 'ready'" class="action-buttons">
          <el-button @click="showDetailDialog = false">返回</el-button>
          <el-button type="primary" @click="handleConfirmOutbound(selectedOutbound)">
            确认出库
          </el-button>
        </div>

        <div v-else-if="selectedOutbound.status === 'shipped'" class="action-buttons">
          <el-button type="default" @click="handlePrint">
            <el-icon><Printer /></el-icon>
            打印出库单
          </el-button>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { warehouseApi } from '@/api'
import { toast } from '@/composables/useToast'
import { Printer, UserFilled } from '@element-plus/icons-vue'

interface OutboundItem {
  id: string
  outboundNo: string
  orderNo?: string
  type: string
  typeText: string
  status: string
  statusText: string
  totalQuantity: number
  createTime: string
  outboundTime?: string
  remark?: string
  driverInfo?: {
    name: string
    phone: string
    vehicleNo?: string
  }
  items?: Array<{
    productId: string
    productName: string
    quantity: number
    price?: number
    amount?: number
  }>
}

const activeTab = ref('all')
const loading = ref(false)
const showDetailDialog = ref(false)
const selectedOutbound = ref<OutboundItem | null>(null)

const outboundList = ref<OutboundItem[]>([])

const getStatusText = (status: string) => {
  const map: Record<string, string> = {
    ready: '待出库',
    shipped: '已出库',
    cancelled: '已取消'
  }
  return map[status] || status
}

const getStatusType = (status: string) => {
  const map: Record<string, string> = {
    ready: 'warning',
    shipped: 'success',
    cancelled: 'danger'
  }
  return map[status] || 'info'
}

const handleTabChange = () => {
  fetchOutboundList()
}

const fetchOutboundList = async () => {
  loading.value = true
  try {
    const params: any = {}
    if (activeTab.value !== 'all') {
      params.status = activeTab.value
    }
    const res: any = await warehouseApi.getOutboundList(params)
    const outboundData = res.data || res || []
    outboundList.value = Array.isArray(outboundData) ? outboundData : (outboundData.records || [])
  } catch (error: any) {
    console.error('获取出库列表失败:', error)
    toast.error('获取出库列表失败')
  } finally {
    loading.value = false
  }
}

const viewDetail = async (item: OutboundItem) => {
  try {
    const res: any = await warehouseApi.getOutboundDetail(item.id)
    const detailData = res.data || res
    selectedOutbound.value = {
      ...item,
      ...detailData
    }
    showDetailDialog.value = true
  } catch (error: any) {
    selectedOutbound.value = item
    showDetailDialog.value = true
  }
}

const handleConfirmOutbound = async (item: OutboundItem) => {
  try {
    await warehouseApi.confirmOutbound(item.id)
    toast.success('出库成功')
    showDetailDialog.value = false
    fetchOutboundList()
  } catch (error: any) {
    toast.error('操作失败: ' + (error.message || ''))
  }
}

const handlePrint = () => {
  toast.info('正在生成打印文件...')
}

onMounted(() => {
  fetchOutboundList()
})
</script>

<style scoped>
.warehouse-outbound {
  padding: 20px;
}

.mb-4 {
  margin-bottom: 16px;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.page-title {
  margin: 0;
  font-size: 18px;
  font-weight: bold;
  color: #303133;
}

.page-desc {
  margin: 4px 0 0;
  font-size: 12px;
  color: #909399;
}

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.total-count {
  font-size: 12px;
  color: #909399;
}

.mono {
  font-family: 'Monaco', 'Menlo', monospace;
}

.link-text {
  color: #409eff;
}

.outbound-detail {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.info-card {
  margin-bottom: 0;
}

.driver-info {
  display: flex;
  align-items: center;
  gap: 16px;
}

.driver-details {
  flex: 1;
}

.driver-name {
  font-size: 16px;
  font-weight: 500;
  color: #303133;
  margin: 0 0 4px;
}

.driver-phone {
  font-size: 14px;
  color: #606266;
  margin: 0;
}

.driver-vehicle {
  font-size: 12px;
  color: #909399;
  margin: 4px 0 0;
}

.total-row {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  padding: 12px 0;
  font-weight: bold;
  gap: 16px;
}

.total-amount {
  color: #409eff;
  font-size: 16px;
}

.remark-card {
  background: #f5f7fa;
  padding: 12px 16px;
  border-radius: 8px;
}

.remark-label {
  font-size: 12px;
  color: #909399;
  margin: 0 0 4px;
}

.remark-content {
  font-size: 14px;
  color: #606266;
  margin: 0;
}

.action-buttons {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}
</style>
