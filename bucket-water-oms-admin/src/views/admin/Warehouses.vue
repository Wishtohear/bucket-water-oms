<template>
  <div>
    <!-- 搜索筛选区 -->
    <el-card shadow="never" class="mb-4">
      <el-form :inline="true" :model="filters" class="flex flex-wrap gap-4 items-end">
        <el-form-item label="仓库名称/地址" class="flex-1 min-w-[200px]">
          <el-input v-model="filters.search" placeholder="搜索仓库名称、地址..." clearable />
        </el-form-item>
        <el-form-item label="仓库状态">
          <el-select v-model="filters.status" placeholder="全部状态" clearable style="width: 160px">
            <el-option value="active" label="正常运营" />
            <el-option value="inactive" label="已停用" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button @click="resetFilters">重置</el-button>
          <el-button type="primary" @click="searchWarehouses">查询</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 仓库列表 -->
    <el-card shadow="never">
      <template #header>
        <div class="flex justify-between items-center">
          <span class="font-bold text-lg">仓库列表</span>
          <el-button type="primary" @click="openAddDialog">
            <el-icon><Plus /></el-icon>
            新增仓库
          </el-button>
        </div>
      </template>

      <el-table :data="warehouseStore.warehouses" stripe>
        <el-table-column label="仓库信息" min-width="200">
          <template #default="{ row }">
            <div class="flex items-center gap-3">
              <div class="w-10 h-10 bg-blue-50 rounded-lg flex items-center justify-center text-blue-500">
                <el-icon><Warehouse /></el-icon>
              </div>
              <div>
                <p class="text-sm font-bold text-gray-800">{{ row.name }}</p>
                <p class="text-[10px] text-gray-400">{{ row.address }}</p>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="仓库类型" width="100">
          <template #default="{ row }">
            <el-tag :type="row.type === 'main' ? '' : 'success'" size="small">
              {{ row.type === 'main' ? '总仓' : '分仓' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="当前库存" width="120" align="right">
          <template #default="{ row }">
            <span class="font-bold">{{ row.stock || 0 }} 桶</span>
          </template>
        </el-table-column>
        <el-table-column label="覆盖水站数" width="120" align="right">
          <template #default="{ row }">
            {{ row.stationCount || 0 }} 家
          </template>
        </el-table-column>
        <el-table-column label="负责人" width="100">
          <template #default="{ row }">
            {{ row.contact }}
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 'active' ? 'success' : 'info'" size="small">
              {{ row.status === 'active' ? '正常运营' : '已停用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" align="center">
          <template #default="{ row }">
            <el-button link type="primary" @click="openEditDialog(row)">编辑</el-button>
            <el-button link type="primary" @click="viewDetails(row)">详情</el-button>
            <el-button
              v-if="row.status === 'active'"
              link
              type="warning"
              @click="toggleStatus(row)"
            >
              停用
            </el-button>
            <el-button
              v-else
              link
              type="success"
              @click="toggleStatus(row)"
            >
              启用
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="mt-4 flex justify-between items-center">
        <span class="text-sm text-gray-400">共 {{ warehouseStore.total }} 个仓库</span>
        <el-pagination
          v-model:current-page="warehouseStore.currentPage"
          :page-size="warehouseStore.pageSize"
          :total="warehouseStore.total"
          layout="prev, pager, next"
          @current-change="goToPage"
        />
      </div>
    </el-card>

    <!-- 新增/编辑仓库对话框 -->
    <el-dialog
      v-model="showDialog"
      :title="dialogMode === 'add' ? '新增仓库' : '编辑仓库'"
      width="500px"
      :close-on-click-modal="false"
    >
      <el-form :model="formData" label-width="100px" @submit.prevent="handleSubmit">
        <el-form-item label="仓库名称" required>
          <el-input v-model="formData.name" placeholder="请输入仓库名称" />
        </el-form-item>
        <el-form-item label="仓库类型" required>
          <el-select v-model="formData.type" style="width: 100%">
            <el-option value="main" label="总仓" />
            <el-option value="branch" label="分仓" />
          </el-select>
        </el-form-item>
        <el-form-item label="仓库地址" required>
          <el-input v-model="formData.address" placeholder="请输入详细地址" />
        </el-form-item>
        <el-form-item label="负责人" required>
          <el-input v-model="formData.manager" placeholder="请输入负责人姓名" />
        </el-form-item>
        <el-form-item label="联系电话">
          <el-input v-model="formData.phone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="覆盖区域">
          <el-select v-model="formData.area" placeholder="请选择覆盖区域" clearable style="width: 100%">
            <el-option
              v-for="region in regionOptions"
              :key="region.value"
              :value="region.value"
              :label="region.label"
            />
          </el-select>
        </el-form-item>
        <el-form-item :label="dialogMode === 'add' ? '登录密码' : '新密码'">
          <el-input
            v-model="formData.password"
            :placeholder="dialogMode === 'add' ? '请输入登录密码(留空则使用默认密码123456)' : '请输入新密码(留空则不修改密码)'"
            type="password"
            show-password
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="closeDialog">取消</el-button>
        <el-button type="primary" @click="handleSubmit">
          {{ dialogMode === 'add' ? '创建仓库' : '保存修改' }}
        </el-button>
      </template>
    </el-dialog>

    <!-- 仓库详情对话框 -->
    <el-dialog
      v-model="showDetailsDialog"
      title="仓库详情"
      width="600px"
    >
      <div v-if="selectedWarehouse">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="仓库名称">{{ selectedWarehouse.name }}</el-descriptions-item>
          <el-descriptions-item label="仓库类型">
            {{ selectedWarehouse.type === 'main' ? '总仓' : '分仓' }}
          </el-descriptions-item>
          <el-descriptions-item label="仓库地址">{{ selectedWarehouse.address }}</el-descriptions-item>
          <el-descriptions-item label="负责人">{{ selectedWarehouse.contact }}</el-descriptions-item>
          <el-descriptions-item label="联系电话">{{ selectedWarehouse.phone }}</el-descriptions-item>
          <el-descriptions-item label="覆盖区域">
            {{ selectedWarehouse.coverageArea ? regionStore.getRegionName(selectedWarehouse.coverageArea) : '未设置' }}
          </el-descriptions-item>
          <el-descriptions-item label="当前库存">
            <el-tag type="primary">{{ selectedWarehouse.stock || 0 }} 桶</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="覆盖水站数">
            <el-tag type="success">{{ selectedWarehouse.stationCount || 0 }} 家</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="创建时间">{{ selectedWarehouse.createTime }}</el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="selectedWarehouse.status === 'active' ? 'success' : 'info'">
              {{ selectedWarehouse.status === 'active' ? '正常运营' : '已停用' }}
            </el-tag>
          </el-descriptions-item>
        </el-descriptions>
      </div>
      <template #footer>
        <el-button @click="closeDetailsDialog">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Plus } from '@element-plus/icons-vue'
import { useWarehouseStore } from '@/stores/warehouses'
import { useRegionStore } from '@/stores/regions'
import { warehousesApi } from '@/api/warehouses'
import type { WarehouseVO } from '@/api/warehouses'
import { ElMessage } from 'element-plus'

const router = useRouter()
const warehouseStore = useWarehouseStore()
const regionStore = useRegionStore()

const filters = ref({
  search: '',
  status: ''
})

const showDialog = ref(false)
const showDetailsDialog = ref(false)
const dialogMode = ref<'add' | 'edit'>('add')
const selectedWarehouse = ref<WarehouseVO | null>(null)

const formData = ref({
  name: '',
  type: 'branch' as 'main' | 'branch',
  address: '',
  manager: '',
  phone: '',
  area: '',
  password: ''
})

const regionOptions = computed(() => regionStore.getRegionOptions())

const searchWarehouses = async () => {
  await warehouseStore.fetchWarehouses(filters.value, 1)
}

const resetFilters = () => {
  filters.value = {
    search: '',
    status: ''
  }
  searchWarehouses()
}

const openAddDialog = () => {
  dialogMode.value = 'add'
  formData.value = {
    name: '',
    type: 'branch',
    address: '',
    manager: '',
    phone: '',
    area: '',
    password: ''
  }
  showDialog.value = true
}

const openEditDialog = (warehouse: WarehouseVO) => {
  dialogMode.value = 'edit'
  selectedWarehouse.value = warehouse
  formData.value = {
    name: warehouse.name,
    type: (warehouse.type || 'branch') as 'main' | 'branch',
    address: warehouse.address,
    manager: warehouse.contact,
    phone: warehouse.phone,
    area: warehouse.coverageArea || '',
    password: ''
  }
  showDialog.value = true
}

const closeDialog = () => {
  showDialog.value = false
  selectedWarehouse.value = null
}

const handleSubmit = async () => {
  try {
    if (dialogMode.value === 'add') {
      await warehouseStore.createWarehouse({
        name: formData.value.name,
        address: formData.value.address,
        contact: formData.value.manager,
        contactPhone: formData.value.phone,
        phone: formData.value.phone,
        type: formData.value.type,
        coverageArea: formData.value.area
      })
      ElMessage.success('创建仓库成功')
    } else if (selectedWarehouse.value) {
      await warehouseStore.updateWarehouse(selectedWarehouse.value.id, {
        name: formData.value.name,
        address: formData.value.address,
        contact: formData.value.manager,
        contactPhone: formData.value.phone,
        phone: formData.value.phone,
        type: formData.value.type,
        coverageArea: formData.value.area
      })
      ElMessage.success('保存修改成功')
    }
    closeDialog()
  } catch (error) {
    console.error('提交仓库信息失败:', error)
    ElMessage.error('提交失败，请重试')
  }
}

const viewDetails = (warehouse: WarehouseVO) => {
  router.push(`/warehouses/${warehouse.id}`)
}

const closeDetailsDialog = () => {
  showDetailsDialog.value = false
  selectedWarehouse.value = null
}

const toggleStatus = async (warehouse: WarehouseVO) => {
  try {
    const newStatus = warehouse.status === 'active' ? 'inactive' : 'active'
    await warehousesApi.updateStatus(warehouse.id, newStatus)
    await warehouseStore.fetchWarehouses(filters.value, warehouseStore.currentPage)
    ElMessage.success(newStatus === 'active' ? '仓库已启用' : '仓库已停用')
  } catch (error) {
    console.error('更新仓库状态失败:', error)
    ElMessage.error('更新状态失败')
  }
}

const goToPage = async (page: number) => {
  await warehouseStore.fetchWarehouses(filters.value, page)
}

onMounted(async () => {
  await warehouseStore.fetchWarehouses()
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
