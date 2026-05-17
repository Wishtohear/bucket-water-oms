<template>
  <div class="factory-list">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>水厂列表</span>
          <el-button type="primary" @click="handleCreate">
            <el-icon><Plus /></el-icon>
            创建水厂
          </el-button>
        </div>
      </template>

      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="水厂名称">
          <el-input v-model="searchForm.name" placeholder="请输入水厂名称" clearable />
        </el-form-item>
        <el-form-item label="水厂编码">
          <el-input v-model="searchForm.code" placeholder="请输入水厂编码" clearable />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="请选择状态" clearable>
            <el-option label="启用" value="ACTIVE" />
            <el-option label="停用" value="INACTIVE" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="tableData" v-loading="loading" stripe>
        <el-table-column prop="name" label="水厂名称" />
        <el-table-column prop="code" label="水厂编码" />
        <el-table-column prop="contact" label="联系人" />
        <el-table-column prop="phone" label="联系电话" />
        <el-table-column prop="address" label="地址" show-overflow-tooltip />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 'ACTIVE' ? 'success' : 'danger'">
              {{ row.status === 'ACTIVE' ? '启用' : '停用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleDetail(row)">详情</el-button>
            <el-button type="primary" link @click="handleEdit(row)">编辑</el-button>
            <el-button
              :type="row.status === 'ACTIVE' ? 'warning' : 'success'"
              link
              @click="handleToggleStatus(row)"
            >
              {{ row.status === 'ACTIVE' ? '停用' : '启用' }}
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        v-model:current-page="pagination.page"
        v-model:page-size="pagination.size"
        :total="pagination.total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        style="margin-top: 20px; justify-content: flex-end"
      />
    </el-card>

    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="600px"
      @close="handleDialogClose"
    >
      <el-form :model="formData" :rules="formRules" ref="formRef" label-width="100px">
        <el-form-item label="水厂名称" prop="name">
          <el-input v-model="formData.name" placeholder="请输入水厂名称" />
        </el-form-item>
        <el-form-item label="水厂编码" prop="code">
          <el-input v-model="formData.code" placeholder="请输入水厂编码" :disabled="isEdit" />
        </el-form-item>
        <el-form-item label="联系人" prop="contact">
          <el-input v-model="formData.contact" placeholder="请输入联系人" />
        </el-form-item>
        <el-form-item label="联系电话" prop="phone">
          <el-input v-model="formData.phone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="详细地址" prop="address">
          <el-input v-model="formData.address" type="textarea" placeholder="请输入详细地址" />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="formData.remark" type="textarea" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitLoading">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import axios from 'axios'

const router = useRouter()

const loading = ref(false)
const submitLoading = ref(false)
const dialogVisible = ref(false)
const isEdit = ref(false)
const formRef = ref()

const searchForm = reactive({
  name: '',
  code: '',
  status: ''
})

const pagination = reactive({
  page: 1,
  size: 10,
  total: 0
})

const tableData = ref([])

const formData = reactive({
  id: null as number | null,
  name: '',
  code: '',
  contact: '',
  phone: '',
  address: '',
  remark: ''
})

const formRules = {
  name: [{ required: true, message: '请输入水厂名称', trigger: 'blur' }],
  code: [{ required: true, message: '请输入水厂编码', trigger: 'blur' }],
  phone: [{ required: true, message: '请输入联系电话', trigger: 'blur' }]
}

const dialogTitle = computed(() => (isEdit.value ? '编辑水厂' : '创建水厂'))

const loadData = async () => {
  loading.value = true
  try {
    const response = await axios.get('/api/platform/factories', {
      params: {
        page: pagination.page,
        size: pagination.size,
        ...searchForm
      }
    })
    if (response.data.success) {
      tableData.value = response.data.data.records
      pagination.total = response.data.data.total
    }
  } catch (error) {
    ElMessage.error('加载数据失败')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pagination.page = 1
  loadData()
}

const handleReset = () => {
  Object.assign(searchForm, { name: '', code: '', status: '' })
  handleSearch()
}

const handleSizeChange = () => {
  pagination.page = 1
  loadData()
}

const handleCurrentChange = () => {
  loadData()
}

const handleCreate = () => {
  isEdit.value = false
  Object.assign(formData, {
    id: null,
    name: '',
    code: '',
    contact: '',
    phone: '',
    address: '',
    remark: ''
  })
  dialogVisible.value = true
}

const handleEdit = (row: any) => {
  isEdit.value = true
  Object.assign(formData, row)
  dialogVisible.value = true
}

const handleDetail = (row: any) => {
  router.push(`/factories/${row.id}`)
}

const handleToggleStatus = async (row: any) => {
  const action = row.status === 'ACTIVE' ? '停用' : '启用'
  await ElMessageBox.confirm(`确定要${action}水厂"${row.name}"吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  })

  try {
    await axios.put(`/api/platform/factories/${row.id}/status`, {
      status: row.status === 'ACTIVE' ? 'INACTIVE' : 'ACTIVE'
    })
    ElMessage.success(`${action}成功`)
    loadData()
  } catch (error) {
    ElMessage.error(`${action}失败`)
  }
}

const handleDialogClose = () => {
  formRef.value?.resetFields()
}

const handleSubmit = async () => {
  await formRef.value?.validate(async (valid: boolean) => {
    if (!valid) return

    submitLoading.value = true
    try {
      if (isEdit.value) {
        await axios.put(`/api/platform/factories/${formData.id}`, formData)
        ElMessage.success('编辑成功')
      } else {
        await axios.post('/api/platform/factories', formData)
        ElMessage.success('创建成功')
      }
      dialogVisible.value = false
      loadData()
    } catch (error) {
      ElMessage.error('操作失败')
    } finally {
      submitLoading.value = false
    }
  })
}

loadData()
</script>

<style scoped>
.factory-list {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.search-form {
  margin-bottom: 20px;
}
</style>
