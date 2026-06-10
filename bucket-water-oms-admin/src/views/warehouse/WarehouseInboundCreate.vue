<template>
  <div class="inbound-create-container">
    <el-page-header @back="goBack" class="mb-4">
      <template #content>
        <div class="page-header-content">
          <span class="page-title">新增入库</span>
          <el-breadcrumb separator="/">
            <el-breadcrumb-item :to="{ path: '/warehouse/inbound' }">入库管理</el-breadcrumb-item>
            <el-breadcrumb-item>新增入库</el-breadcrumb-item>
          </el-breadcrumb>
        </div>
      </template>
    </el-page-header>

    <el-card shadow="never" class="inbound-card">
      <template #header>
        <div class="card-header">
          <el-icon class="header-icon"><Goods /></el-icon>
          <div class="header-text">
            <h3 class="header-title">新增入库单</h3>
            <p class="header-desc">填写入库信息并添加产品</p>
          </div>
        </div>
      </template>

      <el-form :model="newInbound" label-width="120px" class="inbound-form">
        <el-form-item label="入库类型" required>
          <el-radio-group v-model="newInbound.inboundType" class="type-group">
            <el-radio value="production">
              <el-icon class="type-icon blue"><OfficeBuilding /></el-icon>
              <span>生产入库</span>
            </el-radio>
            <el-radio value="purchase">
              <el-icon class="type-icon green"><ShoppingCart /></el-icon>
              <span>采购入库</span>
            </el-radio>
            <el-radio value="transfer_in">
              <el-icon class="type-icon orange"><Switch /></el-icon>
              <span>调拨入库</span>
            </el-radio>
            <el-radio value="return">
              <el-icon class="type-icon purple"><RefreshLeft /></el-icon>
              <span>退货入库</span>
            </el-radio>
          </el-radio-group>
        </el-form-item>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="来源">
              <el-input v-model="newInbound.source" placeholder="如：一号车间、XX供应商" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="关联订单">
              <el-input v-model="newInbound.relatedOrderNo" placeholder="关联订单号（可选）" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-divider content-position="left">
          <span class="divider-title">
            <el-icon class="divider-icon"><Box /></el-icon>
            入库产品
          </span>
        </el-divider>

        <div class="products-section">
          <el-table :data="newInbound.items" stripe style="width: 100%">
            <el-table-column label="产品" min-width="200">
              <template #default="{ row, $index }">
                <el-select
                  v-model="row.productId"
                  placeholder="选择产品"
                  style="width: 100%"
                  filterable
                  @change="handleProductChange($index)"
                >
                  <el-option
                    v-for="p in products"
                    :key="p.id"
                    :label="p.name"
                    :value="p.id"
                  >
                    <div class="product-option">
                      <span>{{ p.name }}</span>
                      <el-tag size="small" type="info">{{ p.category }}</el-tag>
                    </div>
                  </el-option>
                </el-select>
              </template>
            </el-table-column>
            <el-table-column label="单位" width="100">
              <template #default>
                <span>桶</span>
              </template>
            </el-table-column>
            <el-table-column label="入库数量" width="150">
              <template #default="{ row, $index }">
                <el-input-number
                  v-model="row.quantity"
                  :min="1"
                  :max="9999"
                  size="small"
                  style="width: 100%"
                  @change="handleQuantityChange($index)"
                />
              </template>
            </el-table-column>
            <el-table-column label="单价" width="150">
              <template #default="{ row }">
                <el-input-number
                  v-model="row.price"
                  :min="0"
                  :precision="2"
                  :step="0.1"
                  size="small"
                  style="width: 100%"
                />
              </template>
            </el-table-column>
            <el-table-column label="金额" width="120">
              <template #default="{ row }">
                <span class="amount">¥ {{ ((row.quantity || 0) * (row.price || 0)).toFixed(2) }}</span>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="80" fixed="right">
              <template #default="{ $index }">
                <el-button type="danger" link @click="removeItem($index)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>

          <el-button type="primary" plain @click="addItem" class="add-btn">
            <el-icon><Plus /></el-icon>
            添加产品
          </el-button>
        </div>

        <el-form-item label="备注">
          <el-input
            v-model="newInbound.remark"
            type="textarea"
            :rows="3"
            placeholder="请输入备注信息（可选）"
          />
        </el-form-item>

        <el-divider />

        <div class="summary-section">
          <div class="summary-row">
            <span class="summary-label">入库产品</span>
            <span class="summary-value">{{ newInbound.items.length }} 种</span>
          </div>
          <div class="summary-row">
            <span class="summary-label">总数量</span>
            <span class="summary-value">{{ totalQuantity }} 桶</span>
          </div>
          <div class="summary-row total">
            <span class="summary-label">总金额</span>
            <span class="summary-value primary">¥ {{ totalAmount.toFixed(2) }}</span>
          </div>
        </div>

        <div class="form-actions">
          <el-button @click="goBack">取消</el-button>
          <el-button type="primary" @click="handleSubmit" :loading="submitting">
            提交入库
          </el-button>
        </div>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Plus, Goods, OfficeBuilding, ShoppingCart, Switch, RefreshLeft, Box } from '@element-plus/icons-vue'

const router = useRouter()
const submitting = ref(false)

const products = ref([
  { id: '1', name: '桶装纯净水', category: '桶装水' },
  { id: '2', name: '桶装矿泉水', category: '桶装水' },
  { id: '3', name: '瓶装纯净水', category: '瓶装水' }
])

const newInbound = ref({
  inboundType: 'production',
  source: '',
  relatedOrderNo: '',
  remark: '',
  items: [
    { productId: '', quantity: 1, price: 0 }
  ]
})

const totalQuantity = computed(() => {
  return newInbound.value.items.reduce((sum, item) => sum + (item.quantity || 0), 0)
})

const totalAmount = computed(() => {
  return newInbound.value.items.reduce((sum, item) => sum + ((item.quantity || 0) * (item.price || 0)), 0)
})

const goBack = () => {
  router.push('/warehouse/inbound')
}

const handleProductChange = (index: number) => {
  const item = newInbound.value.items[index]
  const product = products.value.find(p => p.id === item.productId)
  if (product) {
    item.price = 10
  }
}

const handleQuantityChange = (_index: number) => {
  // Quantity change handler
}

const addItem = () => {
  newInbound.value.items.push({ productId: '', quantity: 1, price: 0 })
}

const removeItem = (index: number) => {
  if (newInbound.value.items.length > 1) {
    newInbound.value.items.splice(index, 1)
  } else {
    ElMessage.warning('至少需要一条入库产品')
  }
}

const handleSubmit = async () => {
  if (!newInbound.value.source) {
    ElMessage.warning('请输入来源')
    return
  }

  const validItems = newInbound.value.items.filter(item => item.productId && item.quantity > 0)
  if (validItems.length === 0) {
    ElMessage.warning('请至少添加一个入库产品')
    return
  }

  submitting.value = true
  try {
    ElMessage.success('入库单提交成功')
    router.push('/warehouse/inbound')
  } catch (error) {
    console.error('提交失败:', error)
    ElMessage.error('提交失败')
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped>
.inbound-create-container {
  padding: 20px;
}

.mb-4 {
  margin-bottom: 16px;
}

.page-header-content {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.page-title {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
}

.inbound-card {
  max-width: 1000px;
}

.card-header {
  display: flex;
  align-items: center;
  gap: 12px;
}

.header-icon {
  font-size: 32px;
  color: #67c23a;
  background: #f0f9eb;
  padding: 12px;
  border-radius: 12px;
}

.header-title {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
  margin: 0 0 4px 0;
}

.header-desc {
  font-size: 12px;
  color: #909399;
  margin: 0;
}

.type-group {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}

.type-icon {
  margin-right: 4px;
}

.type-icon.blue {
  color: #409eff;
}

.type-icon.green {
  color: #67c23a;
}

.type-icon.orange {
  color: #e6a23c;
}

.type-icon.purple {
  color: #8b5cf6;
}

.product-option {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.amount {
  font-weight: 600;
  color: #67c23a;
}

.add-btn {
  margin-top: 16px;
}

.summary-section {
  background: #f5f7fa;
  padding: 16px;
  border-radius: 8px;
  margin-bottom: 16px;
}

.summary-row {
  display: flex;
  justify-content: space-between;
  padding: 8px 0;
}

.summary-row.total {
  border-top: 1px solid #ebeef5;
  padding-top: 16px;
  margin-top: 8px;
}

.summary-label {
  color: #606266;
}

.summary-value {
  font-weight: 600;
  color: #303133;
}

.summary-value.primary {
  color: #409eff;
  font-size: 20px;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 16px;
}

.divider-title {
  display: flex;
  align-items: center;
  gap: 8px;
}

.divider-icon {
  color: #409eff;
}
</style>
