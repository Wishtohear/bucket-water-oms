<template>
  <div>
    <div class="flex items-center gap-4 mb-6">
      <button @click="goBack" class="text-gray-500 hover:text-blue-500">
        <Icon icon="mdi:chevron-left" class="text-2xl" />
      </button>
      <h2 class="text-xl font-bold text-gray-800">产品详情</h2>
      <nav class="flex text-sm text-gray-400 ml-4">
        <router-link to="/products" class="hover:text-blue-500">产品管理</router-link>
        <span class="mx-2">/</span>
        <span class="text-gray-600">产品详情</span>
      </nav>
    </div>

    <div v-if="loading" class="flex justify-center items-center py-20">
      <el-icon class="is-loading text-4xl text-blue-500"><Loading /></el-icon>
    </div>

    <div v-else-if="!productData.id" class="text-center py-20">
      <Icon icon="mdi:package-variant-closed" class="text-6xl text-gray-300 mb-4" />
      <p class="text-gray-400">未找到该产品</p>
    </div>

    <div v-else class="grid grid-cols-3 gap-8">
      <div class="col-span-2 space-y-6">
        <div class="bg-white p-8 rounded-3xl shadow-sm border border-gray-50">
          <div class="flex justify-between items-start mb-6">
            <div class="flex items-center gap-4">
              <div v-if="productData.image" class="w-16 h-16 rounded-2xl overflow-hidden">
                <img :src="productData.image" class="w-full h-full object-cover" />
              </div>
              <div v-else class="w-16 h-16 bg-blue-50 rounded-2xl flex items-center justify-center">
                <Icon class="text-3xl text-[#1890FF]" icon="mdi:package-variant" />
              </div>
              <div>
                <h3 class="text-xl font-bold text-gray-800">{{ productData.name }}</h3>
                <p class="text-sm text-gray-400 mt-1">产品编号: {{ productData.code }} | 创建时间: {{ productData.createTime }}</p>
              </div>
            </div>
            <span :class="getStatusClass(productData.status)">
              {{ getStatusText(productData.status) }}
            </span>
          </div>
          <div class="grid grid-cols-2 gap-6">
            <div>
              <label class="block text-xs font-bold text-gray-400 uppercase mb-2">产品分类</label>
              <p class="text-sm font-medium text-gray-800">{{ getCategoryText(productData.category) }}</p>
            </div>
            <div>
              <label class="block text-xs font-bold text-gray-400 uppercase mb-2">产品规格</label>
              <p class="text-sm font-medium text-gray-800">{{ productData.spec || '-' }}</p>
            </div>
            <div>
              <label class="block text-xs font-bold text-gray-400 uppercase mb-2">出厂价</label>
              <p class="text-sm font-bold text-gray-800">¥ {{ productData.factoryPrice }}</p>
            </div>
            <div>
              <label class="block text-xs font-bold text-gray-400 uppercase mb-2">计量单位</label>
              <p class="text-sm font-medium text-gray-800">{{ productData.unit }}</p>
            </div>
            <div>
              <label class="block text-xs font-bold text-gray-400 uppercase mb-2">指导价区间</label>
              <p class="text-sm font-medium text-gray-800">
                ¥ {{ productData.guidePriceMin || productData.factoryPrice }} ~ ¥ {{ productData.guidePriceMax || productData.factoryPrice }}
              </p>
            </div>
            <div>
              <label class="block text-xs font-bold text-gray-400 uppercase mb-2">安全库存</label>
              <p class="text-sm font-medium text-gray-800">{{ productData.minStock || 0 }} {{ productData.unit }}</p>
            </div>
            <div class="col-span-2">
              <label class="block text-xs font-bold text-gray-400 uppercase mb-2">产品描述</label>
              <p class="text-sm font-medium text-gray-800">{{ productData.description || '暂无描述' }}</p>
            </div>
          </div>
          <div class="flex gap-3 mt-6 pt-6 border-t border-gray-50">
            <button @click="openEditDialog" class="bg-white border border-gray-200 text-gray-600 px-4 py-2 rounded-lg hover:bg-gray-50 transition-colors flex items-center gap-2">
              <Icon icon="mdi:pencil-outline" />
              编辑信息
            </button>
            <button @click="toggleProductStatus" class="bg-[#1890FF] text-white px-4 py-2 rounded-lg hover:bg-blue-600 transition-colors flex items-center gap-2">
              <Icon :icon="productData.status === 'active' ? 'mdi:archive-outline' : 'mdi:archive'" />
              {{ productData.status === 'active' ? '下架产品' : '上架产品' }}
            </button>
          </div>
        </div>

        <div class="bg-white p-8 rounded-3xl shadow-sm border border-gray-50">
          <div class="flex justify-between items-center mb-6">
            <h4 class="font-bold text-gray-800 text-lg">各仓库库存统计</h4>
            <span class="text-sm text-gray-400">更新时间: {{ lastUpdateTime }}</span>
          </div>
          
          <div v-if="warehouseStocks.length > 0">
            <el-table :data="warehouseStocks" stripe>
              <el-table-column label="仓库名称" min-width="150">
                <template #default="{ row }">
                  <div class="flex items-center gap-3">
                    <div class="w-8 h-8 bg-blue-50 rounded-lg flex items-center justify-center">
                      <Icon class="text-blue-500" icon="mdi:warehouse" />
                    </div>
                    <span class="font-bold text-gray-800">{{ row.warehouseName }}</span>
                  </div>
                </template>
              </el-table-column>
              <el-table-column label="仓库类型" width="100" align="center">
                <template #default="{ row }">
                  <el-tag :type="row.warehouseType === 'main' ? '' : 'success'" size="small">
                    {{ row.warehouseType === 'main' ? '总仓' : '分仓' }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column label="当前库存" width="120" align="right">
                <template #default="{ row }">
                  <span :class="row.stock < row.minStock ? 'text-red-500 font-bold' : 'font-bold text-gray-800'">
                    {{ row.stock.toLocaleString() }} {{ productData.unit }}
                  </span>
                  <el-icon v-if="row.stock < row.minStock" class="text-red-500 ml-1"><WarningFilled /></el-icon>
                </template>
              </el-table-column>
              <el-table-column label="安全库存" width="100" align="right">
                <template #default="{ row }">
                  <span class="text-gray-600">{{ row.minStock }} {{ productData.unit }}</span>
                </template>
              </el-table-column>
              <el-table-column label="库存状态" width="100" align="center">
                <template #default="{ row }">
                  <el-tag :type="getStockStatusTagType(row)" size="small">
                    {{ getStockStatusText(row) }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column label="占比" width="150" align="center">
                <template #default="{ row }">
                  <div class="flex items-center gap-2">
                    <el-progress
                      :percentage="getStockPercentage(row.stock)"
                      :color="getProgressColor(row)"
                      :stroke-width="8"
                      style="width: 80px"
                    />
                    <span class="text-xs text-gray-500">{{ getStockPercentage(row.stock) }}%</span>
                  </div>
                </template>
              </el-table-column>
            </el-table>
          </div>
          
          <div v-else class="text-center py-12">
            <Icon icon="mdi:package-variant-closed" class="text-5xl text-gray-300 mb-3" />
            <p class="text-gray-400">暂无库存数据</p>
          </div>

          <div v-if="warehouseStocks.length > 0" class="mt-6 p-4 bg-gray-50 rounded-xl">
            <div class="grid grid-cols-4 gap-4">
              <div class="text-center">
                <p class="text-xs text-gray-400 mb-1">总库存</p>
                <p class="text-lg font-bold text-gray-800">{{ totalStock.toLocaleString() }} {{ productData.unit }}</p>
              </div>
              <div class="text-center">
                <p class="text-xs text-gray-400 mb-1">平均库存</p>
                <p class="text-lg font-bold text-gray-800">{{ averageStock.toLocaleString() }} {{ productData.unit }}</p>
              </div>
              <div class="text-center">
                <p class="text-xs text-gray-400 mb-1">最高库存</p>
                <p class="text-lg font-bold text-green-600">{{ maxStock.toLocaleString() }} {{ productData.unit }}</p>
              </div>
              <div class="text-center">
                <p class="text-xs text-gray-400 mb-1">预警仓库</p>
                <p class="text-lg font-bold text-red-500">{{ warningCount }} 个</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="space-y-6">
        <div class="bg-white p-6 rounded-3xl shadow-sm border border-gray-50">
          <h4 class="font-bold text-gray-800 mb-4">库存概览</h4>
          <div class="space-y-4">
            <div class="p-4 bg-blue-50 rounded-2xl">
              <p class="text-xs text-gray-400 mb-1">产品总数</p>
              <p class="text-xl font-bold text-blue-600">{{ totalStock.toLocaleString() }} {{ productData.unit }}</p>
            </div>
            <div class="p-4 rounded-2xl" :class="isLowStock ? 'bg-red-50' : 'bg-green-50'">
              <p class="text-xs text-gray-400 mb-1">库存状态</p>
              <p class="text-xl font-bold" :class="isLowStock ? 'text-red-600' : 'text-green-600'">
                {{ isLowStock ? '库存不足' : '库存充足' }}
              </p>
              <p v-if="isLowStock" class="text-xs text-red-400 mt-1">低于安全库存 {{ productData.minStock }} {{ productData.unit }}</p>
            </div>
            <div class="p-4 bg-purple-50 rounded-2xl">
              <p class="text-xs text-gray-400 mb-1">本月销售</p>
              <p class="text-xl font-bold text-purple-600">{{ monthlySales.toLocaleString() }} {{ productData.unit }}</p>
            </div>
            <div class="p-4 bg-orange-50 rounded-2xl">
              <p class="text-xs text-gray-400 mb-1">涉及仓库</p>
              <p class="text-xl font-bold text-orange-600">{{ warehouseStocks.length }} 个</p>
            </div>
          </div>
        </div>

        <div v-if="recentRecords.length > 0" class="bg-white p-6 rounded-3xl shadow-sm border border-gray-50">
          <div class="flex justify-between items-center mb-4">
            <h4 class="font-bold text-gray-800">最近出入库记录</h4>
          </div>
          <div class="space-y-3">
            <div v-for="record in recentRecords" :key="record.id" class="flex justify-between items-center p-3 bg-gray-50 rounded-xl">
              <div class="flex items-center gap-3">
                <div :class="getRecordTypeClass(record.type)">
                  <Icon :icon="record.type === 'inbound' ? 'mdi:arrow-down-bold' : 'mdi:arrow-up-bold'" />
                </div>
                <div>
                  <p class="text-sm font-bold text-gray-800">{{ record.warehouseName }}</p>
                  <p class="text-[10px] text-gray-400">{{ record.time }}</p>
                </div>
              </div>
              <div class="text-right">
                <p class="text-sm font-bold" :class="record.type === 'inbound' ? 'text-green-600' : 'text-red-600'">
                  {{ record.type === 'inbound' ? '+' : '-' }}{{ record.quantity }} {{ productData.unit }}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="showEditDialog" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50" @click.self="closeEditDialog">
      <div class="bg-white rounded-2xl p-8 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <div class="flex justify-between items-center mb-6">
          <h3 class="text-xl font-bold text-gray-800">编辑产品信息</h3>
          <button @click="closeEditDialog" class="text-gray-400 hover:text-gray-600">
            <Icon icon="mdi:close" class="text-2xl" />
          </button>
        </div>

        <form @submit.prevent="handleEditSubmit" class="space-y-6">
          <div class="grid grid-cols-2 gap-6">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">产品名称 <span class="text-red-500">*</span></label>
              <input v-model="editForm.name" class="input-field" placeholder="请输入产品名称" required />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">产品编号</label>
              <input v-model="editForm.code" class="input-field bg-gray-50" disabled />
            </div>
          </div>

          <div class="grid grid-cols-2 gap-6">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">产品分类 <span class="text-red-500">*</span></label>
              <select v-model="editForm.category" class="input-field" required>
                <option value="">请选择分类</option>
                <option value="bucket_water">桶装水</option>
                <option value="bottle_water">瓶装水</option>
                <option value="equipment">饮水设备</option>
                <option value="other">其他</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">产品规格</label>
              <input v-model="editForm.spec" class="input-field" placeholder="如：18.9L、24瓶/箱" />
            </div>
          </div>

          <div class="grid grid-cols-2 gap-6">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">出厂价 <span class="text-red-500">*</span></label>
              <input v-model.number="editForm.factoryPrice" type="number" step="0.01" class="input-field" placeholder="0.00" required />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">计量单位</label>
              <select v-model="editForm.unit" class="input-field">
                <option value="桶">桶</option>
                <option value="箱">箱</option>
                <option value="个">个</option>
                <option value="件">件</option>
                <option value="台">台</option>
              </select>
            </div>
          </div>

          <div class="grid grid-cols-2 gap-6">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">指导价(最低)</label>
              <input v-model.number="editForm.guidePriceMin" type="number" step="0.01" class="input-field" placeholder="0.00" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">指导价(最高)</label>
              <input v-model.number="editForm.guidePriceMax" type="number" step="0.01" class="input-field" placeholder="0.00" />
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">安全库存</label>
            <input v-model.number="editForm.minStock" type="number" class="input-field" placeholder="0" />
            <p class="text-xs text-gray-400 mt-1">库存低于此值时触发预警</p>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">产品描述</label>
            <textarea v-model="editForm.description" class="input-field h-24 resize-none" placeholder="简要描述产品特点..."></textarea>
          </div>

          <div class="flex justify-end gap-4 pt-4 border-t border-gray-100">
            <button type="button" @click="closeEditDialog" class="btn-secondary">取消</button>
            <button type="submit" class="btn-primary">保存修改</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Icon } from '@iconify/vue'
import { Loading, WarningFilled } from '@element-plus/icons-vue'
import { productsApi } from '@/api/products'
import { inventoryApi } from '@/api/inventory'

const router = useRouter()
const route = useRoute()

const loading = ref(false)
const showEditDialog = ref(false)

const productData = ref<any>({
  id: '',
  code: '',
  name: '',
  category: '',
  spec: '',
  factoryPrice: 0,
  guidePriceMin: 0,
  guidePriceMax: 0,
  unit: '桶',
  minStock: 0,
  stock: 0,
  image: '',
  description: '',
  status: 'active',
  createTime: '',
  updateTime: ''
})

const warehouseStocks = ref<any[]>([])
const recentRecords = ref<any[]>([])
const lastUpdateTime = ref('')

const editForm = ref({
  name: '',
  code: '',
  category: '',
  spec: '',
  factoryPrice: 0,
  guidePriceMin: 0,
  guidePriceMax: 0,
  unit: '桶',
  minStock: 0,
  description: ''
})

const totalStock = computed(() => {
  return warehouseStocks.value.reduce((sum, item) => sum + item.stock, 0)
})

const averageStock = computed(() => {
  if (warehouseStocks.value.length === 0) return 0
  return Math.floor(totalStock.value / warehouseStocks.value.length)
})

const maxStock = computed(() => {
  if (warehouseStocks.value.length === 0) return 0
  return Math.max(...warehouseStocks.value.map(item => item.stock))
})

const warningCount = computed(() => {
  return warehouseStocks.value.filter(item => item.stock < item.minStock).length
})

const isLowStock = computed(() => {
  return totalStock.value < (productData.value.minStock || 0) * warehouseStocks.value.length
})

const monthlySales = computed(() => {
  return Math.floor(Math.random() * 500) + 100
})

const getCategoryText = (category: string) => {
  const map: Record<string, string> = {
    bucket_water: '桶装水',
    bottle_water: '瓶装水',
    equipment: '饮水设备',
    other: '其他'
  }
  return map[category] || category
}

const getStatusText = (status: string) => {
  return status === 'active' ? '在售' : '已下架'
}

const getStatusClass = (status: string) => {
  return status === 'active'
    ? 'px-3 py-1.5 text-xs font-bold bg-green-50 text-[#52C41A] rounded-full border border-green-100'
    : 'px-3 py-1.5 text-xs font-bold bg-gray-50 text-gray-500 rounded-full border border-gray-100'
}

const getStockStatusTagType = (row: any) => {
  if (row.stock < row.minStock) return 'danger'
  if (row.stock < row.minStock * 1.5) return 'warning'
  return 'success'
}

const getStockStatusText = (row: any) => {
  if (row.stock < row.minStock) return '库存不足'
  if (row.stock < row.minStock * 1.5) return '库存偏低'
  return '库存充足'
}

const getStockPercentage = (stock: number) => {
  if (totalStock.value === 0) return 0
  return Math.round((stock / totalStock.value) * 100)
}

const getProgressColor = (row: any) => {
  if (row.stock < row.minStock) return '#FF4D4F'
  if (row.stock < row.minStock * 1.5) return '#FAAD14'
  return '#52C41A'
}

const getRecordTypeClass = (type: string) => {
  return type === 'inbound'
    ? 'w-8 h-8 bg-green-50 text-green-500 rounded-lg flex items-center justify-center'
    : 'w-8 h-8 bg-red-50 text-red-500 rounded-lg flex items-center justify-center'
}

const loadProduct = async () => {
  const productId = route.params.id as string
  if (!productId) {
    ElMessage.error('产品ID不能为空')
    router.push('/products')
    return
  }

  loading.value = true
  try {
    const res: any = await productsApi.getById(productId)
    const product = res.data || res
    if (product && typeof product === 'object' && product.id) {
      productData.value = product
      editForm.value = {
        name: product.name,
        code: product.code,
        category: product.category,
        spec: product.spec || '',
        factoryPrice: product.factoryPrice,
        guidePriceMin: product.guidePriceMin || product.factoryPrice,
        guidePriceMax: product.guidePriceMax || product.factoryPrice,
        unit: product.unit || '桶',
        minStock: product.minStock || 0,
        description: product.description || ''
      }
    }
  } catch (error) {
    console.error('获取产品详情失败:', error)
    ElMessage.error('获取产品详情失败')
  } finally {
    loading.value = false
  }
}

const loadWarehouseStocks = async () => {
  const productId = route.params.id as string
  if (!productId) return

  try {
    const res: any = await productsApi.getWarehouseInventory(productId)
    const inventoryList = res.data || res
    if (Array.isArray(inventoryList)) {
      warehouseStocks.value = inventoryList.map((item: any) => ({
        warehouseId: item.warehouseId,
        warehouseName: item.warehouseName,
        warehouseType: item.warehouseType,
        stock: item.stock || 0,
        minStock: item.minStock || 0,
        lastUpdate: new Date().toLocaleString()
      }))

      lastUpdateTime.value = new Date().toLocaleString()
    }
  } catch (error) {
    console.error('获取仓库库存失败:', error)
    warehouseStocks.value = []
  }
}

const loadRecentRecords = async () => {
  const productId = route.params.id as string
  if (!productId) return

  try {
    const res: any = await inventoryApi.getInventoryTransactions({
      productId: Number(productId),
      page: 1,
      size: 5
    })
    
    const transactionList = res.data?.records || res.data || res
    if (Array.isArray(transactionList)) {
      recentRecords.value = transactionList.map((record: any) => ({
        id: record.id,
        warehouseName: record.warehouseName || '-',
        type: record.transactionType === 'INBOUND' ? 'inbound' : 'outbound',
        quantity: record.quantity || 0,
        time: record.createTime ? new Date(record.createTime).toLocaleString('zh-CN') : '-'
      }))
    }
  } catch (error) {
    console.error('获取最近出入库记录失败:', error)
    recentRecords.value = []
  }
}

const goBack = () => {
  router.push('/products')
}

const openEditDialog = () => {
  showEditDialog.value = true
}

const closeEditDialog = () => {
  showEditDialog.value = false
}

const handleEditSubmit = async () => {
  try {
    await productsApi.update(productData.value.id, editForm.value as any)
    ElMessage.success('保存修改成功')
    await loadProduct()
    closeEditDialog()
  } catch (error) {
    console.error('保存修改失败:', error)
    ElMessage.error('保存修改失败')
  }
}

const toggleProductStatus = async () => {
  const newStatus = productData.value.status === 'active' ? 'inactive' : 'active'
  const actionText = newStatus === 'active' ? '上架' : '下架'

  try {
    await ElMessageBox.confirm(
      `确定要${actionText}产品"${productData.value.name}"吗？`,
      '确认操作',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    await productsApi.updateStatus(productData.value.id, newStatus)
    ElMessage.success(`产品已${actionText}`)
    await loadProduct()
  } catch (error: any) {
    if (error !== 'cancel') {
      console.error('更新产品状态失败:', error)
      ElMessage.error('更新产品状态失败')
    }
  }
}

onMounted(async () => {
  await loadProduct()
  await loadWarehouseStocks()
  await loadRecentRecords()
})
</script>

<style scoped>
.input-field {
  @apply w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all;
}

.btn-primary {
  @apply bg-[#1890FF] text-white px-6 py-2.5 rounded-xl hover:bg-blue-600 transition-colors font-medium;
}

.btn-secondary {
  @apply bg-white border border-gray-200 text-gray-600 px-6 py-2.5 rounded-xl hover:bg-gray-50 transition-colors font-medium;
}
</style>
