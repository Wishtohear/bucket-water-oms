<template>
  <div>
    <!-- 操作按钮 -->
    <div class="mb-4 flex justify-end">
      <el-button type="primary" @click="router.push('/products/create')">
        <el-icon><Plus /></el-icon>
        新增产品
      </el-button>
    </div>

    <!-- 搜索筛选区 -->
    <el-card shadow="never" class="mb-4">
      <el-form :inline="true" :model="filters" class="flex flex-wrap gap-4 items-end">
        <el-form-item label="产品名称/编号" class="flex-1 min-w-[200px]">
          <el-input v-model="filters.search" placeholder="搜索产品名称、编号..." clearable @keyup.enter="searchProducts" />
        </el-form-item>
        <el-form-item label="产品分类">
          <el-select v-model="filters.category" placeholder="全部分类" clearable style="width: 140px">
            <el-option value="bucket_water" label="桶装水" />
            <el-option value="bottle_water" label="瓶装水" />
            <el-option value="equipment" label="饮水设备" />
            <el-option value="other" label="其他" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="filters.status" placeholder="全部状态" clearable style="width: 140px">
            <el-option value="active" label="在售" />
            <el-option value="inactive" label="已下架" />
            <el-option value="low_stock" label="库存预警" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button @click="resetFilters">重置</el-button>
          <el-button type="primary" @click="searchProducts">查询</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 统计卡片 -->
    <el-row :gutter="16" class="mb-4">
      <el-col :span="6">
        <el-card shadow="never" class="h-full">
          <div class="flex items-center gap-4">
            <div class="p-3 bg-blue-50 text-blue-500 rounded-xl">
              <el-icon size="24"><Box /></el-icon>
            </div>
            <div>
              <p class="text-xs text-gray-400 mb-1">产品总数</p>
              <h3 class="text-2xl font-bold">{{ stats.totalProducts }} 种</h3>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="h-full">
          <div class="flex items-center gap-4">
            <div class="p-3 bg-green-50 text-green-500 rounded-xl">
              <el-icon size="24"><CircleCheck /></el-icon>
            </div>
            <div>
              <p class="text-xs text-gray-400 mb-1">在售产品</p>
              <h3 class="text-2xl font-bold text-green-500">{{ stats.activeProducts }} 种</h3>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="h-full">
          <div class="flex items-center gap-4">
            <div class="p-3 bg-orange-50 text-orange-500 rounded-xl">
              <el-icon size="24"><Warning /></el-icon>
            </div>
            <div>
              <p class="text-xs text-gray-400 mb-1">库存预警</p>
              <h3 class="text-2xl font-bold text-orange-500">{{ stats.warningProducts }} 种</h3>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="h-full">
          <div class="flex items-center gap-4">
            <div class="p-3 bg-purple-50 text-purple-500 rounded-xl">
              <el-icon size="24"><Money /></el-icon>
            </div>
            <div>
              <p class="text-xs text-gray-400 mb-1">本月销售额</p>
              <h3 class="text-2xl font-bold">{{ formatSales(stats.monthlySales) }}</h3>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 产品列表 -->
    <el-card shadow="never">
      <template #header>
        <div class="flex justify-between items-center">
          <span class="font-bold text-lg">产品列表</span>
          <el-button type="success" plain @click="exportProducts">
            <el-icon><Download /></el-icon>
            导出
          </el-button>
        </div>
      </template>

      <el-table :data="paginatedProducts" stripe v-loading="loading">
        <el-table-column label="产品信息" min-width="220">
          <template #default="{ row }">
            <div class="flex items-center gap-3">
              <el-avatar v-if="row.image" :src="row.image" :size="48" shape="square" />
              <div v-else class="w-12 h-12 bg-gray-100 rounded-xl flex items-center justify-center">
                <el-icon size="20" class="text-gray-400"><Box /></el-icon>
              </div>
              <div>
                <p class="text-sm font-bold text-gray-800">{{ row.name }}</p>
                <p class="text-[10px] text-gray-400">产品编号: {{ row.code }}</p>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="分类" width="100">
          <template #default="{ row }">
            {{ getCategoryText(row.category) }}
          </template>
        </el-table-column>
        <el-table-column label="出厂价" width="100">
          <template #default="{ row }">
            <span class="font-bold">¥ {{ row.factoryPrice }}</span>
          </template>
        </el-table-column>
        <el-table-column label="指导价" width="160">
          <template #default="{ row }">
            ¥ {{ row.guidePriceMin }} ~ {{ row.guidePriceMax }}
          </template>
        </el-table-column>
        <el-table-column label="总库存" width="120" align="right">
          <template #default="{ row }">
            <span :class="row.stock < row.minStock ? 'text-red-500 font-bold' : 'text-gray-800 font-bold'">
              {{ row.stock.toLocaleString() }} {{ row.unit }}
            </span>
            <el-icon v-if="row.stock < row.minStock" class="text-red-500"><WarningFilled /></el-icon>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusTagType(row)" size="small">
              {{ getStatusText(row) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" align="center">
          <template #default="{ row }">
            <el-button link type="primary" @click="viewProductDetail(row)">详情</el-button>
            <el-button link type="primary" @click="openEditDialog(row)">编辑</el-button>
            <el-dropdown trigger="click" @command="(cmd: string) => handleActionCommand(cmd, row)">
              <el-button link type="primary">
                <el-icon><MoreFilled /></el-icon>
              </el-button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="pricing">产品定价</el-dropdown-item>
                  <el-dropdown-item command="toggle">
                    {{ row.status === 'active' ? '下架产品' : '上架产品' }}
                  </el-dropdown-item>
                  <el-dropdown-item command="delete" divided>删除产品</el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </template>
        </el-table-column>
        <template #empty>
          <el-empty description="暂无产品数据" />
        </template>
      </el-table>

      <div class="mt-4 flex justify-end">
        <el-pagination
          v-model:current-page="currentPage"
          :page-size="pageSize"
          :total="totalProducts"
          layout="total, prev, pager, next"
        />
      </div>
    </el-card>

    <!-- 新增/编辑产品对话框 -->
    <el-dialog
      v-model="showProductDialog"
      :title="dialogMode === 'add' ? '新增产品' : '编辑产品'"
      width="700px"
      :close-on-click-modal="false"
    >
      <el-form :model="productForm" label-width="100px" @submit.prevent="handleProductSubmit">
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="产品名称" required>
              <el-input v-model="productForm.name" placeholder="如：18L 桶装纯净水" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="产品编号">
              <el-input v-model="productForm.code" placeholder="系统自动生成" disabled />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="产品分类" required>
              <el-select v-model="productForm.category" style="width: 100%">
                <el-option value="" label="请选择分类" />
                <el-option value="bucket_water" label="桶装水" />
                <el-option value="bottle_water" label="瓶装水" />
                <el-option value="equipment" label="饮水设备" />
                <el-option value="other" label="其他" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="产品规格">
              <el-input v-model="productForm.spec" placeholder="如：18.9L、24瓶/箱" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="出厂价" required>
              <el-input v-model.number="productForm.factoryPrice" type="number" step="0.01" placeholder="0.00">
                <template #prepend>¥</template>
              </el-input>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="计量单位">
              <el-select v-model="productForm.unit" style="width: 100%">
                <el-option value="桶" label="桶" />
                <el-option value="箱" label="箱" />
                <el-option value="个" label="个" />
                <el-option value="件" label="件" />
                <el-option value="台" label="台" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="指导价区间">
          <el-row :gutter="8">
            <el-col :span="12">
              <el-input v-model.number="productForm.guidePriceMin" type="number" step="0.01" placeholder="最低价格">
                <template #prepend>最低 ¥</template>
              </el-input>
            </el-col>
            <el-col :span="12">
              <el-input v-model.number="productForm.guidePriceMax" type="number" step="0.01" placeholder="最高价格">
                <template #prepend>最高 ¥</template>
              </el-input>
            </el-col>
          </el-row>
        </el-form-item>
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="安全库存">
              <el-input v-model.number="productForm.minStock" type="number" placeholder="0">
                <template #append>{{ productForm.unit || '桶' }}</template>
              </el-input>
              <div class="text-xs text-gray-400 mt-1">库存低于此值时触发预警</div>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="产品图片">
              <div class="flex items-center gap-4">
                <div class="w-16 h-16 bg-gray-50 rounded-lg border border-gray-200 flex items-center justify-center overflow-hidden">
                  <el-image v-if="productForm.imageUrl" :src="productForm.imageUrl" fit="cover" class="w-full h-full" />
                  <el-icon v-else size="24" class="text-gray-300"><Plus /></el-icon>
                </div>
                <el-button size="small">上传图片</el-button>
              </div>
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="产品描述">
          <el-input v-model="productForm.description" type="textarea" :rows="3" placeholder="简要描述产品特点..." />
        </el-form-item>
        <el-form-item>
          <el-checkbox v-model="productForm.status">立即上架此产品</el-checkbox>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="closeProductDialog">取消</el-button>
        <el-button type="primary" @click="handleProductSubmit">
          {{ dialogMode === 'add' ? '创建产品' : '保存修改' }}
        </el-button>
      </template>
    </el-dialog>

    <!-- 定价对话框 -->
    <el-dialog v-model="showPricingDialog" title="产品定价" width="450px">
      <div v-if="selectedProduct" class="mb-4 p-4 bg-gray-50 rounded-lg">
        <p class="font-bold">{{ selectedProduct.name }}</p>
        <p class="text-xs text-gray-400">产品编号: {{ selectedProduct.code }}</p>
      </div>
      <el-form :model="pricingForm" label-width="100px">
        <el-form-item label="出厂价">
          <el-input v-model.number="pricingForm.factoryPrice" type="number" step="0.01" disabled>
            <template #prepend>¥</template>
          </el-input>
        </el-form-item>
        <el-form-item label="指导价(最低)">
          <el-input v-model.number="pricingForm.guidePriceMin" type="number" step="0.01" placeholder="0.00">
            <template #prepend>¥</template>
          </el-input>
        </el-form-item>
        <el-form-item label="指导价(最高)">
          <el-input v-model.number="pricingForm.guidePriceMax" type="number" step="0.01" placeholder="0.00">
            <template #prepend>¥</template>
          </el-input>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="closePricingDialog">取消</el-button>
        <el-button type="primary" @click="savePricing">保存定价</el-button>
      </template>
    </el-dialog>

    <!-- 删除确认对话框 -->
    <el-dialog v-model="showConfirmDialog" title="确认删除" width="400px">
      <div class="text-center">
        <el-icon size="64" class="text-red-500 mb-4"><Warning /></el-icon>
        <p class="text-lg mb-2">确定要删除产品"{{ confirmDeleteProduct?.name }}"吗？</p>
        <p class="text-gray-500">此操作无法撤销。</p>
      </div>
      <template #footer>
        <el-button @click="closeConfirmDialog">取消</el-button>
        <el-button type="danger" @click="confirmDelete">确认删除</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import {
  Plus, Box, CircleCheck, Warning, Money, Download,
  MoreFilled, WarningFilled
} from '@element-plus/icons-vue'
import { productsApi } from '@/api'
import { ElMessage } from 'element-plus'

const router = useRouter()

interface Product {
  id: string | number
  code: string
  name: string
  category: string
  spec?: string
  factoryPrice: number | string
  guidePriceMin: number | string
  guidePriceMax: number | string
  stock: number
  unit: string
  minStock: number
  image?: string
  description?: string
  status: 'active' | 'inactive'
  createTime?: string
  updateTime?: string
}

const filters = ref({
  search: '',
  category: '',
  status: ''
})

const showProductDialog = ref(false)
const showPricingDialog = ref(false)
const showConfirmDialog = ref(false)
const dialogMode = ref<'add' | 'edit'>('add')
const selectedProduct = ref<Product | null>(null)
const confirmDeleteProduct = ref<Product | null>(null)
const loading = ref(false)

const products = ref<Product[]>([])
const currentPage = ref(1)
const pageSize = 10
const totalProducts = ref(0)

const stats = ref({
  totalProducts: 0,
  activeProducts: 0,
  warningProducts: 0,
  monthlySales: 0
})

const productForm = ref({
  name: '',
  code: '',
  category: '',
  spec: '',
  factoryPrice: '' as number | string,
  guidePriceMin: '' as number | string,
  guidePriceMax: '' as number | string,
  unit: '桶',
  minStock: '' as number | string,
  description: '',
  status: true,
  imageUrl: ''
})

const pricingForm = ref({
  factoryPrice: 0,
  guidePriceMin: 0,
  guidePriceMax: 0
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

const getStatusText = (product: Product) => {
  if (product.stock < product.minStock) {
    return '库存预警'
  }
  return product.status === 'active' ? '在售' : '已下架'
}

const getStatusTagType = (product: Product) => {
  if (product.stock < product.minStock) {
    return 'warning'
  }
  return product.status === 'active' ? 'success' : 'info'
}

const formatSales = (value: number) => {
  if (value >= 10000) {
    return '¥ ' + (value / 10000).toFixed(1) + 'k'
  }
  return '¥ ' + value.toLocaleString()
}

const filteredProducts = computed(() => {
  let result = products.value

  if (filters.value.category) {
    result = result.filter(p => p.category === filters.value.category)
  }

  if (filters.value.status) {
    if (filters.value.status === 'low_stock') {
      result = result.filter(p => p.stock < p.minStock)
    } else {
      result = result.filter(p => p.status === filters.value.status)
    }
  }

  if (filters.value.search) {
    const keyword = filters.value.search.toLowerCase()
    result = result.filter(p =>
      p.name.toLowerCase().includes(keyword) ||
      (p.code && p.code.toLowerCase().includes(keyword))
    )
  }

  return result
})

const updateStats = () => {
  const all = products.value
  stats.value = {
    totalProducts: all.length,
    activeProducts: all.filter(p => p.status === 'active').length,
    warningProducts: all.filter(p => p.stock < p.minStock).length,
    monthlySales: Math.floor(Math.random() * 150000) + 100000
  }
  totalProducts.value = filteredProducts.value.length
}

watch(filteredProducts, () => {
  totalProducts.value = filteredProducts.value.length
})

const paginatedProducts = computed(() => {
  const start = (currentPage.value - 1) * pageSize
  const end = start + pageSize
  return filteredProducts.value.slice(start, end)
})

const searchProducts = () => {
  currentPage.value = 1
  totalProducts.value = filteredProducts.value.length
}

const resetFilters = () => {
  filters.value = {
    search: '',
    category: '',
    status: ''
  }
  searchProducts()
}

const fetchProducts = async () => {
  loading.value = true
  try {
    const res: any = await productsApi.getAll()
    const productList = res.data || res
    if (Array.isArray(productList)) {
      products.value = productList.map((p: any) => ({
        ...p,
        factoryPrice: typeof p.factoryPrice === 'string' ? parseFloat(p.factoryPrice) : p.factoryPrice,
        guidePriceMin: typeof p.guidePriceMin === 'string' ? parseFloat(p.guidePriceMin) : p.guidePriceMin || 0,
        guidePriceMax: typeof p.guidePriceMax === 'string' ? parseFloat(p.guidePriceMax) : p.guidePriceMax || 0
      }))
      updateStats()
    }
  } catch (error) {
    console.error('获取产品列表失败:', error)
    products.value = []
  } finally {
    loading.value = false
  }
}

const openEditDialog = (product: Product) => {
  dialogMode.value = 'edit'
  selectedProduct.value = product
  productForm.value = {
    name: product.name,
    code: product.code || '',
    category: product.category,
    spec: product.spec || '',
    factoryPrice: product.factoryPrice,
    guidePriceMin: product.guidePriceMin,
    guidePriceMax: product.guidePriceMax,
    unit: product.unit,
    minStock: product.minStock,
    description: product.description || '',
    status: product.status === 'active',
    imageUrl: product.image || ''
  }
  showProductDialog.value = true
}

const openPricingDialog = (product: Product) => {
  selectedProduct.value = product
  pricingForm.value = {
    factoryPrice: typeof product.factoryPrice === 'string' ? parseFloat(product.factoryPrice) : product.factoryPrice,
    guidePriceMin: typeof product.guidePriceMin === 'string' ? parseFloat(product.guidePriceMin) : product.guidePriceMin,
    guidePriceMax: typeof product.guidePriceMax === 'string' ? parseFloat(product.guidePriceMax) : product.guidePriceMax
  }
  showPricingDialog.value = true
}

const closeProductDialog = () => {
  showProductDialog.value = false
  selectedProduct.value = null
}

const closePricingDialog = () => {
  showPricingDialog.value = false
  selectedProduct.value = null
}

const handleProductSubmit = async () => {
  try {
    const data = {
      name: productForm.value.name,
      category: productForm.value.category,
      spec: productForm.value.spec,
      factoryPrice: Number(productForm.value.factoryPrice),
      guidePriceMin: Number(productForm.value.guidePriceMin) || Number(productForm.value.factoryPrice),
      guidePriceMax: Number(productForm.value.guidePriceMax) || Number(productForm.value.factoryPrice),
      unit: productForm.value.unit,
      minStock: Number(productForm.value.minStock) || 0,
      description: productForm.value.description,
      status: productForm.value.status ? 'active' : 'inactive',
      image: productForm.value.imageUrl
    }

    if (dialogMode.value === 'add') {
      await productsApi.create(data)
      ElMessage.success('创建产品成功')
    } else if (selectedProduct.value) {
      await productsApi.update(String(selectedProduct.value.id), data)
      ElMessage.success('保存修改成功')
    }

    await fetchProducts()
    closeProductDialog()
  } catch (error) {
    console.error('提交产品信息失败:', error)
    ElMessage.error('提交失败，请重试')
  }
}

const savePricing = async () => {
  if (!selectedProduct.value) return

  try {
    await productsApi.update(String(selectedProduct.value.id), {
      factoryPrice: pricingForm.value.factoryPrice,
      guidePriceMin: pricingForm.value.guidePriceMin,
      guidePriceMax: pricingForm.value.guidePriceMax
    } as any)

    await fetchProducts()
    closePricingDialog()
    ElMessage.success('保存定价成功')
  } catch (error) {
    console.error('保存定价失败:', error)
    ElMessage.error('保存定价失败')
  }
}

const handleActionCommand = (command: string, product: Product) => {
  selectedProduct.value = product
  if (command === 'toggle') {
    toggleProductStatus(product)
  } else if (command === 'delete') {
    openDeleteConfirm(product)
  } else if (command === 'pricing') {
    openPricingDialog(product)
  }
}

const viewProductDetail = (product: Product) => {
  router.push(`/products/${product.id}`)
}

const toggleProductStatus = async (product: Product) => {
  try {
    const newStatus = product.status === 'active' ? 'inactive' : 'active'
    await productsApi.updateStatus(String(product.id), newStatus)
    await fetchProducts()
    ElMessage.success(newStatus === 'active' ? '产品已上架' : '产品已下架')
  } catch (error) {
    console.error('更新产品状态失败:', error)
    ElMessage.error('更新状态失败')
  }
}

const openDeleteConfirm = (product: Product) => {
  confirmDeleteProduct.value = product
  showConfirmDialog.value = true
}

const closeConfirmDialog = () => {
  showConfirmDialog.value = false
  confirmDeleteProduct.value = null
}

const confirmDelete = async () => {
  if (!confirmDeleteProduct.value) return

  try {
    await productsApi.delete(String(confirmDeleteProduct.value.id))
    await fetchProducts()
    ElMessage.success('删除产品成功')
  } catch (error) {
    console.error('删除产品失败:', error)
    ElMessage.error('删除产品失败')
  }
  closeConfirmDialog()
}

const exportProducts = async () => {
  try {
    const blob = await productsApi.exportProducts({
      category: filters.value.category || undefined,
      status: filters.value.status || undefined
    }) as unknown as Blob

    if (blob) {
      const url = window.URL.createObjectURL(blob)
      const link = document.createElement('a')
      link.href = url
      link.download = `产品列表_${new Date().toISOString().split('T')[0]}.xlsx`
      document.body.appendChild(link)
      link.click()
      document.body.removeChild(link)
      window.URL.revokeObjectURL(url)
      ElMessage.success('导出成功')
    }
  } catch (error) {
    console.error('导出产品列表失败:', error)
    ElMessage.error('导出失败，请重试')
  }
}

onMounted(async () => {
  await fetchProducts()
})
</script>

<style scoped>
:deep(.el-card) {
  border-radius: 12px;
}
:deep(.el-table) {
  border-radius: 8px;
}
</style>
