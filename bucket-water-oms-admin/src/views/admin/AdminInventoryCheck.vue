<template>
  <div class="p-6 bg-gray-50 min-h-screen">
    <div class="mb-6">
      <el-button @click="goBack" class="mb-4">
        <el-icon class="mr-1"><ArrowLeft /></el-icon>
        返回库存管理
      </el-button>
      <h1 class="text-2xl font-bold text-gray-800">库存盘点</h1>
      <p class="text-sm text-gray-500 mt-1">对仓库库存进行实地盘点核对</p>
    </div>

    <el-card shadow="never" class="mb-6">
      <el-row :gutter="16">
        <el-col :span="8">
          <div class="p-4 bg-gradient-to-br from-blue-50 to-blue-100 rounded-2xl">
            <p class="text-xs text-blue-600 font-bold mb-2">盘点仓库</p>
            <p class="font-bold text-lg text-gray-800">
              {{ selectedWarehouseName || '请选择仓库' }}
            </p>
          </div>
        </el-col>
        <el-col :span="8">
          <div class="p-4 bg-gradient-to-br from-green-50 to-green-100 rounded-2xl">
            <p class="text-xs text-green-600 font-bold mb-2">盘点时间</p>
            <p class="font-bold text-lg text-gray-800">{{ currentDateTime }}</p>
          </div>
        </el-col>
        <el-col :span="8">
          <div class="p-4 bg-gradient-to-br from-purple-50 to-purple-100 rounded-2xl">
            <p class="text-xs text-purple-600 font-bold mb-2">盘点人</p>
            <p class="font-bold text-lg text-gray-800">系统管理员</p>
          </div>
        </el-col>
      </el-row>
    </el-card>

    <el-card shadow="never" class="mb-6">
      <template #header>
        <div class="flex justify-between items-center">
          <span class="font-bold text-lg">选择仓库</span>
          <el-select
            v-model="selectedWarehouseId"
            placeholder="请选择仓库"
            filterable
            style="width: 300px"
            @change="handleWarehouseChange"
          >
            <el-option
              v-for="warehouse in warehouses"
              :key="warehouse.id"
              :value="warehouse.id"
              :label="warehouse.name"
            />
          </el-select>
        </div>
      </template>

      <div v-if="!selectedWarehouseId" class="py-12 text-center text-gray-400">
        <el-icon :size="48"><WarningFilled /></el-icon>
        <p class="mt-4">请先选择要盘点的仓库</p>
      </div>

      <div v-else-if="loadingInventory" class="py-12 text-center text-gray-400">
        <el-icon class="is-loading" :size="48"><Loading /></el-icon>
        <p class="mt-4">正在加载库存数据...</p>
      </div>

      <div v-else>
        <div class="mb-4 flex justify-end gap-3">
          <el-button @click="resetQuantities">
            <el-icon class="mr-1"><RefreshLeft /></el-icon>
            重置数量
          </el-button>
          <el-button type="primary" @click="autoFillActual">
            <el-icon class="mr-1"><Edit /></el-icon>
            快速填入实际数量
          </el-button>
        </div>

        <el-table :data="checkItems" stripe class="mb-6">
          <el-table-column label="产品名称" prop="name" min-width="150">
            <template #default="{ row }">
              <div class="flex items-center gap-2">
                <el-icon><Box /></el-icon>
                <span class="font-bold">{{ row.name }}</span>
              </div>
            </template>
          </el-table-column>
          <el-table-column label="产品分类" width="120" align="center">
            <template #default="{ row }">
              <el-tag type="info" size="small">{{ row.category }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="系统库存" width="140" align="right">
            <template #default="{ row }">
              <span class="text-lg font-bold text-blue-600">{{ row.systemQuantity }}</span>
              <span class="text-gray-400 ml-1">{{ row.unit }}</span>
            </template>
          </el-table-column>
          <el-table-column label="实际库存" width="160">
            <template #default="{ row }">
              <el-input-number
                v-model="row.actualQuantity"
                :min="0"
                :max="99999"
                controls-position="right"
                style="width: 100%"
                size="large"
              />
            </template>
          </el-table-column>
          <el-table-column label="差异" width="120" align="right">
            <template #default="{ row }">
              <span
                :class="getDifferenceClass(row.actualQuantity - row.systemQuantity)"
                class="text-lg font-bold"
              >
                {{ formatDifference(row.actualQuantity - row.systemQuantity) }}
              </span>
            </template>
          </el-table-column>
          <el-table-column label="备注" min-width="180">
            <template #default="{ row }">
              <el-input
                v-model="row.remark"
                placeholder="差异说明"
                clearable
              />
            </template>
          </el-table-column>
        </el-table>

        <div class="bg-gray-50 rounded-2xl p-6 mb-6">
          <h3 class="font-bold text-lg mb-4">盘点统计</h3>
          <el-row :gutter="16">
            <el-col :span="6">
              <div class="text-center">
                <p class="text-sm text-gray-500 mb-2">商品总数</p>
                <p class="text-3xl font-bold text-gray-800">{{ checkItems.length }}</p>
              </div>
            </el-col>
            <el-col :span="6">
              <div class="text-center">
                <p class="text-sm text-gray-500 mb-2">一致数量</p>
                <p class="text-3xl font-bold text-green-600">{{ matchedCount }}</p>
              </div>
            </el-col>
            <el-col :span="6">
              <div class="text-center">
                <p class="text-sm text-gray-500 mb-2">盘盈数量</p>
                <p class="text-3xl font-bold text-blue-600">{{ profitCount }}</p>
              </div>
            </el-col>
            <el-col :span="6">
              <div class="text-center">
                <p class="text-sm text-gray-500 mb-2">盘亏数量</p>
                <p class="text-3xl font-bold text-red-600">{{ lossCount }}</p>
              </div>
            </el-col>
          </el-row>
        </div>

        <el-form-item label="盘点总结">
          <el-input
            v-model="summary"
            type="textarea"
            :rows="4"
            placeholder="请输入盘点总结和建议..."
            maxlength="500"
            show-word-limit
          />
        </el-form-item>

        <div class="mt-6 pt-6 border-t border-gray-100 flex justify-end gap-3">
          <el-button @click="goBack">取消</el-button>
          <el-button type="primary" :loading="submitting" @click="handleSubmit">
            <el-icon class="mr-1"><Check /></el-icon>
            提交盘点结果
          </el-button>
        </div>
      </div>
    </el-card>

    <el-card shadow="never" v-if="recentCheckRecords.length > 0">
      <template #header>
        <div class="flex justify-between items-center">
          <span class="font-bold text-lg">盘点历史记录</span>
          <el-tag type="info">共 {{ recentCheckRecords.length }} 条记录</el-tag>
        </div>
      </template>
      <el-table :data="recentCheckRecords" stripe>
        <el-table-column label="盘点时间" width="180">
          <template #default="{ row }">
            {{ formatTime(row.checkDate || row.createTime) }}
          </template>
        </el-table-column>
        <el-table-column label="仓库" min-width="120">
          <template #default="{ row }">
            <span class="font-bold">{{ row.warehouseName || '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column label="盘点人" width="100">
          <template #default="{ row }">
            {{ row.checker || '-' }}
          </template>
        </el-table-column>
        <el-table-column label="商品数" width="80" align="center">
          <template #default="{ row }">
            {{ row.totalProducts || 0 }}
          </template>
        </el-table-column>
        <el-table-column label="一致" width="80" align="center">
          <template #default="{ row }">
            <span class="text-green-600 font-bold">{{ row.matchedProducts || 0 }}</span>
          </template>
        </el-table-column>
        <el-table-column label="差异" width="80" align="center">
          <template #default="{ row }">
            <span
              :class="(row.discrepancyProducts || 0) > 0 ? 'text-red-500 font-bold' : 'text-gray-600'"
            >
              {{ row.discrepancyProducts || 0 }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 'confirmed' ? 'success' : 'warning'" size="small">
              {{ row.status === 'confirmed' ? '已确认' : '待确认' }}
            </el-tag>
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
  ArrowLeft, Check, Box, RefreshLeft, Edit, WarningFilled, Loading
} from '@element-plus/icons-vue'
import { warehousesApi } from '@/api/warehouses'
import { inventoryApi } from '@/api/inventory'
import { ElMessage, ElMessageBox } from 'element-plus'

interface CheckItem {
  id: number
  name: string
  unit: string
  category: string
  systemQuantity: number
  actualQuantity: number
  remark: string
}

interface Warehouse {
  id: string
  name: string
}

interface CheckRecord {
  checkDate: string
  createTime: string
  warehouseName: string
  checker: string
  totalProducts: number
  matchedProducts: number
  discrepancyProducts: number
  status: string
}

const router = useRouter()

const submitting = ref(false)
const loadingInventory = ref(false)
const selectedWarehouseId = ref('')
const selectedWarehouseName = ref('')
const warehouses = ref<Warehouse[]>([])
const checkItems = ref<CheckItem[]>([])
const summary = ref('')
const recentCheckRecords = ref<CheckRecord[]>([])

const currentDateTime = computed(() => {
  return new Date().toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit'
  })
})

const matchedCount = computed(() => {
  return checkItems.value.filter(item => item.actualQuantity === item.systemQuantity).length
})

const profitCount = computed(() => {
  return checkItems.value.filter(item => item.actualQuantity > item.systemQuantity).length
})

const lossCount = computed(() => {
  return checkItems.value.filter(item => item.actualQuantity < item.systemQuantity).length
})

const getDifferenceClass = (diff: number) => {
  if (diff > 0) return 'text-green-600'
  if (diff < 0) return 'text-red-600'
  return 'text-gray-600'
}

const formatDifference = (diff: number) => {
  if (diff > 0) return `+${diff}`
  return diff.toString()
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

const fetchWarehouses = async () => {
  try {
    const res: any = await warehousesApi.getAll({ status: 'active' })
    if (Array.isArray(res)) {
      warehouses.value = res.map((w: any) => ({
        id: String(w.id),
        name: w.name
      }))

      if (warehouses.value.length > 0 && !selectedWarehouseId.value) {
        selectedWarehouseId.value = warehouses.value[0].id
        selectedWarehouseName.value = warehouses.value[0].name
      }
    }
  } catch (error) {
    console.error('获取仓库列表失败:', error)
  }
}

const fetchInventoryByWarehouse = async () => {
  if (!selectedWarehouseId.value) return

  loadingInventory.value = true
  try {
    const res: any = await inventoryApi.getInventoryOverview(selectedWarehouseId.value)
    if (res && typeof res === 'object') {
      const inventory = res
      checkItems.value = [
        {
          id: 1,
          name: '桶装水（18.9L）',
          unit: '桶',
          category: '桶装水',
          systemQuantity: inventory.totalStock || 0,
          actualQuantity: 0,
          remark: ''
        },
        {
          id: 2,
          name: '瓶装水（550ml）',
          unit: '箱',
          category: '瓶装水',
          systemQuantity: 0,
          actualQuantity: 0,
          remark: ''
        },
        {
          id: 3,
          name: '空桶回收库存',
          unit: '个',
          category: '空桶',
          systemQuantity: 0,
          actualQuantity: 0,
          remark: ''
        }
      ]
    } else {
      checkItems.value = []
    }
  } catch (error) {
    console.error('获取库存数据失败:', error)
    checkItems.value = []
  } finally {
    loadingInventory.value = false
  }
}

const fetchRecentCheckRecords = async () => {
  try {
    const res: any = await inventoryApi.getInventoryChecks(selectedWarehouseId.value || undefined)
    if (Array.isArray(res)) {
      recentCheckRecords.value = res.slice(0, 5)
    } else {
      recentCheckRecords.value = []
    }
  } catch (error) {
    console.error('获取盘点记录失败:', error)
    recentCheckRecords.value = []
  }
}

const handleWarehouseChange = async (warehouseId: string) => {
  const warehouse = warehouses.value.find(w => w.id === warehouseId)
  selectedWarehouseName.value = warehouse?.name || ''
  await fetchInventoryByWarehouse()
}

const resetQuantities = () => {
  checkItems.value.forEach(item => {
    item.actualQuantity = 0
    item.remark = ''
  })
}

const autoFillActual = () => {
  checkItems.value.forEach(item => {
    item.actualQuantity = item.systemQuantity
  })
  ElMessage.success('已自动填入系统库存数量')
}

const handleSubmit = async () => {
  if (!selectedWarehouseId.value) {
    ElMessage.warning('请选择仓库')
    return
  }

  const hasDiscrepancy = checkItems.value.some(
    item => item.actualQuantity !== item.systemQuantity
  )

  const confirmTitle = hasDiscrepancy ? '存在差异' : '确认盘点'
  const confirmMessage = hasDiscrepancy
    ? `检测到 ${profitCount.value + lossCount.value} 项存在差异，确认提交盘点结果？`
    : '所有库存数量一致，确认提交盘点结果？'

  try {
    await ElMessageBox.confirm(confirmMessage, confirmTitle, {
      confirmButtonText: '确认提交',
      cancelButtonText: '取消',
      type: hasDiscrepancy ? 'warning' : 'info'
    })
  } catch {
    return
  }

  submitting.value = true
  try {
    const items = checkItems.value.map(item => ({
      productId: `product_${item.id}`,
      productName: item.name,
      category: item.category,
      systemQuantity: item.systemQuantity,
      actualQuantity: item.actualQuantity,
      remark: item.remark
    }))

    const res: any = await inventoryApi.createInventoryCheck({
      warehouseId: selectedWarehouseId.value,
      checker: '系统管理员',
      summary: summary.value,
      items
    })

    const isSuccess = res && (
      res.success === true ||
      res.success !== false ||
      res.code === 200 ||
      res.code === 0
    )

    if (isSuccess) {
      ElMessage.success('盘点记录已提交')
      resetForm()
      await fetchRecentCheckRecords()
    } else {
      ElMessage.error(res?.message || '盘点记录提交失败')
    }
  } catch (error: any) {
    if (error !== 'cancel') {
      console.error('盘点记录提交失败:', error)
      ElMessage.error('盘点记录提交失败')
    }
  } finally {
    submitting.value = false
  }
}

const resetForm = () => {
  summary.value = ''
  checkItems.value.forEach(item => {
    item.actualQuantity = 0
    item.remark = ''
  })
}

onMounted(async () => {
  await fetchWarehouses()
  if (selectedWarehouseId.value) {
    await Promise.all([
      fetchInventoryByWarehouse(),
      fetchRecentCheckRecords()
    ])
  }
})
</script>

<style scoped>
:deep(.el-card) {
  border-radius: 16px;
}

:deep(.el-table) {
  border-radius: 8px;
}

:deep(.el-input-number) {
  width: 100%;
}
</style>
