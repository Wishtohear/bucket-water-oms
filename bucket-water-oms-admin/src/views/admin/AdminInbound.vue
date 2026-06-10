<template>
  <div class="p-6 bg-gray-50 min-h-screen">
    <div class="mb-6">
      <el-button @click="goBack" class="mb-4">
        <el-icon class="mr-1"><ArrowLeft /></el-icon>
        返回库存管理
      </el-button>
      <h1 class="text-2xl font-bold text-gray-800">入库登记</h1>
      <p class="text-sm text-gray-500 mt-1">对仓库产品进行入库操作登记</p>
    </div>

    <el-card shadow="never" class="mb-6">
      <template #header>
        <div class="flex justify-between items-center">
          <span class="font-bold text-lg">入库信息</span>
          <el-tag type="info">登记日期: {{ currentDate }}</el-tag>
        </div>
      </template>

      <el-form :model="inboundForm" label-width="120px" class="max-w-4xl">
        <el-form-item label="入库类型" required>
          <el-radio-group v-model="inboundForm.type" class="flex flex-wrap gap-4">
            <el-radio value="production">
              <div class="flex items-center gap-2">
                <el-icon><Box /></el-icon>
                <span>生产入库</span>
              </div>
            </el-radio>
            <el-radio value="return">
              <div class="flex items-center gap-2">
                <el-icon><RefreshRight /></el-icon>
                <span>退货入库</span>
              </div>
            </el-radio>
            <el-radio value="transfer">
              <div class="flex items-center gap-2">
                <el-icon><Connection /></el-icon>
                <span>调拨入库</span>
              </div>
            </el-radio>
            <el-radio value="other">
              <div class="flex items-center gap-2">
                <el-icon><MoreFilled /></el-icon>
                <span>其他入库</span>
              </div>
            </el-radio>
          </el-radio-group>
        </el-form-item>

        <el-row :gutter="24">
          <el-col :span="12">
            <el-form-item label="产品名称" required>
              <el-select
                v-model="inboundForm.productId"
                placeholder="请选择产品"
                filterable
                style="width: 100%"
                @change="handleProductChange"
              >
                <el-option
                  v-for="product in products"
                  :key="product.id"
                  :value="product.id"
                  :label="product.name"
                >
                  <div class="flex justify-between items-center">
                    <span>{{ product.name }}</span>
                    <span class="text-gray-400 text-sm">{{ product.unit }}</span>
                  </div>
                </el-option>
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="入库数量" required>
              <el-input-number
                v-model="inboundForm.quantity"
                :min="1"
                :max="99999"
                controls-position="right"
                style="width: 100%"
              >
                <template #append>{{ inboundForm.unit }}</template>
              </el-input-number>
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="24">
          <el-col :span="12">
            <el-form-item label="关联水站/车间">
              <el-select
                v-model="inboundForm.relatedObject"
                placeholder="请选择（选填）"
                clearable
                filterable
                style="width: 100%"
              >
                <el-option
                  v-for="station in stations"
                  :key="station.id"
                  :value="station.id"
                  :label="station.name"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="入库仓库" required>
              <el-select
                v-model="inboundForm.warehouseId"
                placeholder="请选择仓库"
                filterable
                style="width: 100%"
              >
                <el-option
                  v-for="warehouse in warehouses"
                  :key="warehouse.id"
                  :value="warehouse.id"
                  :label="warehouse.name"
                />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="备注说明">
          <el-input
            v-model="inboundForm.remark"
            type="textarea"
            :rows="4"
            placeholder="请输入备注信息（选填）..."
            maxlength="500"
            show-word-limit
          />
        </el-form-item>
      </el-form>

      <div class="mt-6 pt-6 border-t border-gray-100 flex justify-end gap-3">
        <el-button @click="goBack">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmit">
          <el-icon class="mr-1"><Check /></el-icon>
          确认入库
        </el-button>
      </div>
    </el-card>

    <el-card shadow="never" v-if="recentInboundRecords.length > 0">
      <template #header>
        <span class="font-bold text-lg">最近入库记录</span>
      </template>
      <el-table :data="recentInboundRecords" stripe>
        <el-table-column label="入库时间" width="180">
          <template #default="{ row }">
            {{ formatTime(row.createTime) }}
          </template>
        </el-table-column>
        <el-table-column label="入库类型" width="120">
          <template #default="{ row }">
            <el-tag :type="getTypeTagType(row.type)" size="small">
              {{ getTypeText(row.type) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="产品名称" min-width="150">
          <template #default="{ row }">
            <span class="font-bold">{{ row.productName || '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column label="数量" width="100" align="right">
          <template #default="{ row }">
            <span class="text-green-600 font-bold">+{{ row.quantity }}</span>
          </template>
        </el-table-column>
        <el-table-column label="仓库" width="150">
          <template #default="{ row }">
            {{ row.warehouseName || '-' }}
          </template>
        </el-table-column>
        <el-table-column label="经办人" width="100" align="center">
          <template #default="{ row }">
            {{ row.operator || '-' }}
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import {
  ArrowLeft, Check, Box, RefreshRight, Connection, MoreFilled
} from '@element-plus/icons-vue'
import { warehousesApi } from '@/api/warehouses'
import { productsApi } from '@/api/products'
import { stationsApi } from '@/api/stations'
import { inventoryApi } from '@/api/inventory'
import { ElMessage, ElMessageBox } from 'element-plus'

interface Product {
  id: string
  name: string
  unit: string
}

interface Warehouse {
  id: string
  name: string
}

interface Station {
  id: string
  name: string
}

interface InboundRecord {
  createTime: string
  type: string
  productName: string
  quantity: number
  warehouseName: string
  operator: string
}

const router = useRouter()

const submitting = ref(false)
const products = ref<Product[]>([])
const stations = ref<Station[]>([])
const warehouses = ref<Warehouse[]>([])
const recentInboundRecords = ref<InboundRecord[]>([])

const inboundForm = ref({
  type: 'production',
  productId: '',
  quantity: 1,
  unit: '桶',
  relatedObject: '',
  warehouseId: '',
  remark: ''
})

const currentDate = computed(() => {
  return new Date().toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
})

const typeTextMap: Record<string, string> = {
  production: '生产入库',
  return: '退货入库',
  transfer: '调拨入库',
  other: '其他入库'
}

const getTypeText = (type: string) => {
  return typeTextMap[type] || type || '未知'
}

const getTypeTagType = (type: string) => {
  switch (type) {
    case 'production':
      return ''
    case 'return':
      return 'warning'
    case 'transfer':
      return 'success'
    default:
      return 'info'
  }
}

const formatTime = (timeStr: string) => {
  if (!timeStr) return '-'
  try {
    const date = new Date(timeStr)
    return date.toLocaleString('zh-CN', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    })
  } catch {
    return timeStr
  }
}

const goBack = () => {
  router.push('/inventory')
}

const fetchProducts = async () => {
  try {
    const res: any = await productsApi.getAll({ status: 'active' })
    const productList = res.data || res
    if (Array.isArray(productList)) {
      products.value = productList.map((p: any) => ({
        id: String(p.id),
        name: p.name,
        unit: p.unit || '桶'
      }))
    }
  } catch (error) {
    console.error('获取产品列表失败:', error)
  }
}

const fetchStations = async () => {
  try {
    const res: any = await stationsApi.getAll({ status: 'active' })
    const stationList = res.data || res
    if (Array.isArray(stationList)) {
      stations.value = stationList.map((s: any) => ({
        id: String(s.id),
        name: s.name
      }))
    }
  } catch (error) {
    console.error('获取水站列表失败:', error)
  }
}

const fetchWarehouses = async () => {
  try {
    const res: any = await warehousesApi.getAll({ status: 'active' })
    const warehouseList = res.data || res
    if (Array.isArray(warehouseList)) {
      warehouses.value = warehouseList.map((w: any) => ({
        id: String(w.id),
        name: w.name
      }))

      if (warehouses.value.length > 0 && !inboundForm.value.warehouseId) {
        inboundForm.value.warehouseId = warehouses.value[0].id
      }
    }
  } catch (error) {
    console.error('获取仓库列表失败:', error)
  }
}

const handleProductChange = (productId: string) => {
  const product = products.value.find(p => p.id === productId)
  if (product) {
    inboundForm.value.unit = product.unit || '桶'
  }
}

const fetchRecentInboundRecords = async () => {
  try {
    const res: any = await inventoryApi.getInventoryRecords({
      warehouseId: inboundForm.value.warehouseId,
      dateRange: 'week'
    })
    const recordList = res.data || res
    if (Array.isArray(recordList)) {
      recentInboundRecords.value = recordList
        .filter((r: any) => r.quantityChange > 0)
        .slice(0, 5)
    }
  } catch (error) {
    console.error('获取最近入库记录失败:', error)
  }
}

const handleSubmit = async () => {
  if (!inboundForm.value.productId) {
    ElMessage.warning('请选择产品')
    return
  }

  if (!inboundForm.value.quantity || inboundForm.value.quantity <= 0) {
    ElMessage.warning('请输入有效的入库数量')
    return
  }

  if (!inboundForm.value.warehouseId) {
    ElMessage.warning('请选择仓库')
    return
  }

  try {
    await ElMessageBox.confirm(
      `确认入库登记？\n\n产品: ${products.value.find(p => p.id === inboundForm.value.productId)?.name}\n数量: ${inboundForm.value.quantity} ${inboundForm.value.unit}\n类型: ${getTypeText(inboundForm.value.type)}\n仓库: ${warehouses.value.find(w => w.id === inboundForm.value.warehouseId)?.name}`,
      '确认入库',
      {
        confirmButtonText: '确认入库',
        cancelButtonText: '取消',
        type: 'info'
      }
    )
  } catch {
    return
  }

  submitting.value = true
  try {
    const result = await inventoryApi.recordInbound({
      warehouseId: inboundForm.value.warehouseId,
      productId: inboundForm.value.productId,
      quantity: inboundForm.value.quantity,
      type: inboundForm.value.type,
      operator: '系统管理员',
      remark: inboundForm.value.remark
    })

    const isSuccess = result && (
      result.success === true ||
      result.success !== false ||
      result.code === 200 ||
      result.code === 0
    )

    if (isSuccess) {
      ElMessage.success('入库登记成功')
      resetForm()
      await fetchRecentInboundRecords()
    } else {
      ElMessage.error(result?.message || '入库登记失败')
    }
  } catch (error: any) {
    if (error !== 'cancel') {
      console.error('入库登记失败:', error)
      ElMessage.error('入库登记失败')
    }
  } finally {
    submitting.value = false
  }
}

const resetForm = () => {
  inboundForm.value = {
    type: 'production',
    productId: '',
    quantity: 1,
    unit: '桶',
    relatedObject: '',
    warehouseId: warehouses.value[0]?.id || '',
    remark: ''
  }
}

onMounted(async () => {
  await Promise.all([
    fetchProducts(),
    fetchStations(),
    fetchWarehouses()
  ])
  await fetchRecentInboundRecords()
})
</script>

<style scoped>
:deep(.el-card) {
  border-radius: 16px;
}

:deep(.el-table) {
  border-radius: 8px;
}

:deep(.el-radio) {
  height: 40px;
  line-height: 40px;
}

:deep(.el-radio__label) {
  display: flex;
  align-items: center;
  gap: 6px;
}
</style>
