<template>
  <div class="customers-container">
    <el-card shadow="never">
      <template #header>
        <div class="toolbar">
          <el-form :inline="true" :model="filters">
            <el-form-item label="">
              <el-input v-model="filters.keyword" placeholder="搜索客户姓名、电话..." clearable style="width: 200px" />
            </el-form-item>
            <el-form-item label="">
              <el-select v-model="filters.type" placeholder="客户类型" clearable style="width: 120px">
                <el-option label="全部" value="" />
                <el-option label="常客" value="regular" />
                <el-option label="VIP" value="vip" />
                <el-option label="企业" value="enterprise" />
              </el-select>
            </el-form-item>
            <el-form-item>
              <el-button @click="handleSearch">查询</el-button>
              <el-button @click="handleReset">重置</el-button>
            </el-form-item>
          </el-form>
          <div class="toolbar-right">
            <el-button type="primary" @click="showAddDialog = true">
              <el-icon><Plus /></el-icon>
              新增客户
            </el-button>
          </div>
        </div>
      </template>

      <el-table :data="customers" stripe v-loading="loading" @row-click="handleRowClick">
        <el-table-column label="客户信息" min-width="200">
          <template #default="{ row }">
            <div class="customer-info">
              <el-avatar :size="40" :src="row.avatar" />
              <div class="customer-detail">
                <p class="customer-name">{{ row.name }}</p>
                <p class="customer-phone">{{ row.phone }}</p>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="类型" width="100">
          <template #default="{ row }">
            <el-tag :type="getCustomerTypeTagType(row.type)" size="small">
              {{ row.typeText }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="账户余额" width="120" align="right">
          <template #default="{ row }">
            <span :class="row.balance < 0 ? 'text-danger' : 'text-primary'">
              ¥{{ Math.abs(row.balance || 0).toFixed(2) }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="剩余水票" width="100" align="right">
          <template #default="{ row }">
            {{ row.tickets }}张
          </template>
        </el-table-column>
        <el-table-column label="欠桶数" width="100" align="right">
          <template #default="{ row }">
            <span :class="row.owedBuckets > 0 ? 'text-warning' : ''">
              {{ row.owedBuckets }}个
            </span>
          </template>
        </el-table-column>
        <el-table-column prop="address" label="地址" min-width="200" show-overflow-tooltip />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click.stop="goToCustomerDetail(row.id)">详情</el-button>
            <el-button type="primary" link size="small" @click.stop="handleEdit(row)">编辑</el-button>
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

    <el-dialog
      v-model="showAddDialog"
      :title="editMode ? '编辑客户' : '新增客户'"
      width="500px"
      :close-on-click-modal="false"
    >
      <el-form ref="formRef" :model="customerForm" :rules="rules" label-width="100px">
        <el-form-item label="客户名称" prop="name">
          <el-input v-model="customerForm.name" placeholder="请输入客户名称" />
        </el-form-item>
        <el-form-item label="联系电话" prop="phone">
          <el-input v-model="customerForm.phone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="联系人">
          <el-input v-model="customerForm.contact" placeholder="请输入联系人" />
        </el-form-item>
        <el-form-item label="地址">
          <el-input v-model="customerForm.address" placeholder="请输入地址" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showAddDialog = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitting">
          {{ editMode ? '保存' : '确认添加' }}
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, FormInstance, FormRules } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { stationOwnerApi } from '@/api'

const router = useRouter()

const loading = ref(true)
const submitting = ref(false)
const showAddDialog = ref(false)
const editMode = ref(false)
const currentPage = ref(1)
const pageSize = ref(20)
const total = ref(0)
const formRef = ref<FormInstance>()
const selectedCustomerId = ref<string | null>(null)

const defaultAvatar = 'https://modao.cc/agent-py/media/generated_images/2026-04-19/c8552e5188ad493b88794201879bfbd0.jpg'

const filters = reactive({
  keyword: '',
  type: ''
})

const customers = ref<any[]>([])

const customerForm = reactive({
  name: '',
  phone: '',
  contact: '',
  address: ''
})

const rules: FormRules = {
  name: [{ required: true, message: '请输入客户名称', trigger: 'blur' }],
  phone: [
    { required: true, message: '请输入联系电话', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ]
}

const getCustomerTypeTagType = (type: string) => {
  const typeMap: Record<string, string> = {
    regular: '',
    vip: 'success',
    enterprise: 'info'
  }
  return typeMap[type] || ''
}

const getTypeText = (type: string) => {
  const map: Record<string, string> = {
    regular: '常客',
    vip: 'VIP',
    enterprise: '企业'
  }
  return map[type] || '常客'
}

const loadCustomers = async () => {
  try {
    loading.value = true
    const res = await stationOwnerApi.getCustomers({
      page: currentPage.value,
      size: pageSize.value,
      keyword: filters.keyword || undefined
    })

    if (res && Array.isArray(res)) {
      customers.value = res.map((c: any) => ({
        id: c.id,
        name: c.name,
        phone: c.phone || '',
        avatar: c.avatar || defaultAvatar,
        type: c.type || 'regular',
        typeText: getTypeText(c.type),
        balance: c.balance || 0,
        tickets: c.tickets || 0,
        owedBuckets: c.owedBuckets || 0,
        owedAmount: c.owedAmount || 0,
        address: c.address || ''
      }))
      total.value = res.length
    } else {
      customers.value = []
      total.value = 0
    }
  } catch (error: any) {
    ElMessage.error('加载客户列表失败：' + (error.message || '未知错误'))
    customers.value = []
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  currentPage.value = 1
  loadCustomers()
}

const handleReset = () => {
  filters.keyword = ''
  filters.type = ''
  currentPage.value = 1
  loadCustomers()
}

const handlePageChange = (page: number) => {
  currentPage.value = page
  loadCustomers()
}

const handleRowClick = (row: any) => {
  goToCustomerDetail(row.id)
}

const goToCustomerDetail = (id: string) => {
  router.push(`/station/customers/${id}`)
}

const handleEdit = (row: any) => {
  editMode.value = true
  selectedCustomerId.value = row.id
  customerForm.name = row.name
  customerForm.phone = row.phone
  customerForm.contact = row.contact || ''
  customerForm.address = row.address || ''
  showAddDialog.value = true
}

const handleSubmit = async () => {
  if (!formRef.value) return

  await formRef.value.validate(async (valid) => {
    if (!valid) return

    submitting.value = true
    try {
      if (editMode.value && selectedCustomerId.value) {
        await stationOwnerApi.updateCustomer(selectedCustomerId.value, customerForm)
        ElMessage.success('修改成功')
      } else {
        await stationOwnerApi.createCustomer(customerForm)
        ElMessage.success('添加成功')
      }
      showAddDialog.value = false
      resetForm()
      loadCustomers()
    } catch (error: any) {
      ElMessage.error((editMode.value ? '修改' : '添加') + '客户失败：' + (error.message || '未知错误'))
    } finally {
      submitting.value = false
    }
  })
}

const resetForm = () => {
  customerForm.name = ''
  customerForm.phone = ''
  customerForm.contact = ''
  customerForm.address = ''
  editMode.value = false
  selectedCustomerId.value = null
  formRef.value?.resetFields()
}

onMounted(() => {
  loadCustomers()
})
</script>

<style scoped>
.customers-container {
  padding: 20px;
}

.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.toolbar-right {
  display: flex;
  gap: 12px;
}

.customer-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.customer-detail {
  flex: 1;
}

.customer-name {
  font-weight: 500;
  color: #303133;
  margin: 0;
}

.customer-phone {
  font-size: 12px;
  color: #909399;
  margin: 4px 0 0 0;
}

.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}

.text-primary {
  color: #409eff;
}

.text-danger {
  color: #f56c6c;
}

.text-warning {
  color: #e6a23c;
}
</style>
