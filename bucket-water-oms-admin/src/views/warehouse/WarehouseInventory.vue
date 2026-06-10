<template>
  <div class="warehouse-inventory">
    <el-card shadow="never" class="mb-4">
      <template #header>
        <div class="header">
          <div>
            <h2 class="page-title">库存管理</h2>
            <p class="page-desc">查看和管理仓库库存</p>
          </div>
          <div>
            <el-button type="primary">
              <el-icon><Printer /></el-icon>
              打印库存
            </el-button>
          </div>
        </div>
      </template>
    </el-card>

    <el-row :gutter="20" class="mb-4">
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-icon-wrapper blue">
            <el-icon class="stat-icon"><Goods /></el-icon>
          </div>
          <div class="stat-content">
            <p class="stat-label">总库存种类</p>
            <h3 class="stat-value">{{ stats.totalTypes }} <span class="stat-unit">类</span></h3>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-icon-wrapper green">
            <el-icon class="stat-icon"><Box /></el-icon>
          </div>
          <div class="stat-content">
            <p class="stat-label">成品水库存</p>
            <h3 class="stat-value">{{ stats.waterStock }} <span class="stat-unit">桶</span></h3>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-icon-wrapper purple">
            <el-icon class="stat-icon"><CoffeeCup /></el-icon>
          </div>
          <div class="stat-content">
            <p class="stat-label">空桶库存</p>
            <h3 class="stat-value">{{ stats.bucketStock }} <span class="stat-unit">个</span></h3>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-icon-wrapper red">
            <el-icon class="stat-icon"><Warning /></el-icon>
          </div>
          <div class="stat-content">
            <p class="stat-label">库存预警</p>
            <h3 class="stat-value danger">{{ stats.lowStockWarnings }} <span class="stat-unit">类</span></h3>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-card shadow="never" class="mb-4">
      <el-radio-group v-model="activeTab">
        <el-radio-button value="current">当前库存</el-radio-button>
        <el-radio-button value="task">盘点任务</el-radio-button>
        <el-radio-button value="log">变动记录</el-radio-button>
      </el-radio-group>
    </el-card>

    <el-card shadow="never" v-loading="loading">
      <template #header>
        <span class="section-title">库存明细</span>
      </template>
      <el-table :data="inventory" stripe style="width: 100%">
        <el-table-column prop="productName" label="商品名称" min-width="150" />
        <el-table-column prop="category" label="分类" width="120">
          <template #default="{ row }">
            {{ getCategoryText(row.category) }}
          </template>
        </el-table-column>
        <el-table-column prop="quantity" label="当前库存" width="120" align="right">
          <template #default="{ row }">
            <span class="bold">{{ row.quantity }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="safeStock" label="安全库存" width="120" align="right">
          <template #default="{ row }">
            {{ row.safeStock || 0 }}
          </template>
        </el-table-column>
        <el-table-column label="状态" width="120" align="center">
          <template #default="{ row }">
            <el-tag :type="row.quantity < (row.safeStock || 0) ? 'danger' : 'success'" size="small">
              {{ row.quantity < (row.safeStock || 0) ? '库存不足' : '正常' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="100" align="center">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="showCalibrateDialog(row)">校准</el-button>
          </template>
        </el-table-column>
        <template #empty>
          <el-empty description="暂无库存数据" :image-size="80" />
        </template>
      </el-table>
    </el-card>

    <el-dialog v-model="calibrateDialogVisible" title="库存校准" width="400px">
      <el-form :model="calibrateForm" label-width="100px">
        <el-form-item label="商品名称">
          <span>{{ calibrateForm.productName }}</span>
        </el-form-item>
        <el-form-item label="当前库存">
          <span>{{ calibrateForm.currentQuantity }}</span>
        </el-form-item>
        <el-form-item label="校准后库存" required>
          <el-input-number v-model="calibrateForm.newQuantity" :min="0" controls-position="right" />
        </el-form-item>
        <el-form-item label="校准原因">
          <el-input v-model="calibrateForm.reason" type="textarea" :rows="2" placeholder="请输入校准原因（选填）" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="calibrateDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="calibrateLoading" @click="handleCalibrate">确认校准</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { warehouseApi } from '@/api'
import { toast } from '@/composables/useToast'
import { Printer, Goods, Box, CoffeeCup, Warning } from '@element-plus/icons-vue'
import type { WarehouseInventoryVO } from '@/api/warehouse'

const activeTab = ref('current')
const loading = ref(false)

const stats = ref({
  totalTypes: 0,
  waterStock: 0,
  bucketStock: 0,
  lowStockWarnings: 0
})

const inventory = ref<WarehouseInventoryVO[]>([])

const calibrateDialogVisible = ref(false)
const calibrateLoading = ref(false)
const calibrateForm = ref({
  id: 0,
  productName: '',
  currentQuantity: 0,
  newQuantity: 0,
  reason: ''
})

const getCategoryText = (category: string) => {
  const map: Record<string, string> = {
    bucket_water: '桶装水',
    bottle_water: '瓶装水',
    equipment: '饮水设备',
    other: '其他'
  }
  return map[category] || category || '-'
}

const fetchInventory = async () => {
  loading.value = true
  try {
    const res: any = await warehouseApi.getInventory()
    const inventoryData = res.data || res || []
    inventory.value = Array.isArray(inventoryData) ? inventoryData : (inventoryData.records || [])

    stats.value = {
      totalTypes: inventory.value.length,
      waterStock: inventory.value.reduce((sum: number, item: any) => sum + (item.category?.includes('水') ? item.quantity : 0), 0),
      bucketStock: inventory.value.reduce((sum: number, item: any) => sum + (item.category?.includes('桶') ? item.quantity : 0), 0),
      lowStockWarnings: inventory.value.filter((item: any) => item.quantity < (item.safeStock || 0)).length
    }
  } catch (error: any) {
    console.error('获取库存数据失败:', error)
    toast.error('获取库存数据失败')
  } finally {
    loading.value = false
  }
}

const showCalibrateDialog = (row: any) => {
  calibrateForm.value = {
    id: row.id,
    productName: row.productName || '-',
    currentQuantity: row.quantity || 0,
    newQuantity: row.quantity || 0,
    reason: ''
  }
  calibrateDialogVisible.value = true
}

const handleCalibrate = async () => {
  if (calibrateForm.value.newQuantity < 0) {
    toast.warning('校准后库存不能为负数')
    return
  }

  calibrateLoading.value = true
  try {
    await warehouseApi.calibrateInventory(calibrateForm.value.id, {
      quantity: calibrateForm.value.newQuantity,
      reason: calibrateForm.value.reason
    })
    toast.success('库存校准成功')
    calibrateDialogVisible.value = false
    fetchInventory()
  } catch (error: any) {
    console.error('库存校准失败:', error)
    toast.error('库存校准失败')
  } finally {
    calibrateLoading.value = false
  }
}

onMounted(() => {
  fetchInventory()
})
</script>

<style scoped>
.warehouse-inventory {
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

.stat-card {
  margin-bottom: 20px;
}

.stat-card :deep(.el-card__body) {
  display: flex;
  align-items: center;
  gap: 16px;
}

.stat-icon-wrapper {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.stat-icon-wrapper.blue {
  background: #ecf5ff;
  color: #409eff;
}

.stat-icon-wrapper.green {
  background: #f0f9eb;
  color: #67c23a;
}

.stat-icon-wrapper.purple {
  background: #faf5ff;
  color: #a855f7;
}

.stat-icon-wrapper.red {
  background: #fef0f0;
  color: #f56c6c;
}

.stat-icon {
  font-size: 24px;
}

.stat-content {
  flex: 1;
}

.stat-label {
  color: #909399;
  font-size: 14px;
  margin: 0 0 4px;
}

.stat-value {
  font-size: 24px;
  font-weight: bold;
  color: #303133;
  margin: 0;
}

.stat-value.danger {
  color: #f56c6c;
}

.stat-unit {
  font-size: 14px;
  font-weight: normal;
  color: #909399;
}

.section-title {
  font-weight: bold;
  color: #303133;
}

.bold {
  font-weight: 500;
}
</style>
