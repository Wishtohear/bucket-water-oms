<template>
  <div class="platform-admins">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>管理员管理</span>
          <el-button type="primary" @click="handleCreate">
            <el-icon><Plus /></el-icon>
            创建管理员
          </el-button>
        </div>
      </template>

      <el-table :data="tableData" v-loading="loading" stripe>
        <el-table-column prop="name" label="姓名" />
        <el-table-column prop="phone" label="手机号" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="isActive(row.status) ? 'success' : 'danger'">
              {{ isActive(row.status) ? '启用' : '停用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="lastLoginTime" label="最后登录" width="180" />
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="240" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleEdit(row)">编辑</el-button>
            <el-button type="warning" link @click="handleResetPassword(row)">重置密码</el-button>
            <el-button
              :type="isActive(row.status) ? 'warning' : 'success'"
              link
              @click="handleToggleStatus(row)"
            >
              {{ isActive(row.status) ? '停用' : '启用' }}
            </el-button>
            <el-button type="danger" link @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="500px"
      @close="handleDialogClose"
    >
      <el-form :model="formData" :rules="formRules" ref="formRef" label-width="80px">
        <el-form-item label="姓名" prop="name">
          <el-input v-model="formData.name" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item label="手机号" prop="phone">
          <el-input v-model="formData.phone" placeholder="请输入手机号" :disabled="isEdit" />
        </el-form-item>
        <el-form-item label="密码" prop="password" v-if="!isEdit">
          <el-input v-model="formData.password" type="password" placeholder="不填则使用默认123456" show-password />
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="formData.email" placeholder="请输入邮箱" />
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
import { ElMessage, ElMessageBox } from 'element-plus'
import { platformApi } from '../../api/platform'

const loading = ref(false)
const submitLoading = ref(false)
const dialogVisible = ref(false)
const isEdit = ref(false)
const formRef = ref()

const tableData = ref<any[]>([])

const formData = reactive({
  id: null as number | null,
  name: '',
  phone: '',
  password: '',
  email: ''
})

const formRules = {
  name: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '手机号格式不正确', trigger: 'blur' }
  ]
}

const dialogTitle = computed(() => (isEdit.value ? '编辑管理员' : '创建管理员'))

const isActive = (status: string) => status === 'active' || status === 'ACTIVE'

const formatDateTime = (val: any) => {
  if (!val) return '-'
  if (Array.isArray(val)) {
    const [d, t] = val
    return `${d} ${t || ''}`
  }
  return val
}

const loadData = async () => {
  loading.value = true
  try {
    const response: any = await platformApi.getAdmins({ page: 1, size: 100 })
    if (response.success) {
      tableData.value = (response.data?.records || []).map((row: any) => ({
        ...row,
        lastLoginTime: formatDateTime(row.lastLoginTime),
        createTime: formatDateTime(row.createTime)
      }))
    }
  } catch (error) {
    ElMessage.error('加载数据失败')
  } finally {
    loading.value = false
  }
}

const handleCreate = () => {
  isEdit.value = false
  Object.assign(formData, {
    id: null,
    name: '',
    phone: '',
    password: '',
    email: ''
  })
  dialogVisible.value = true
}

const handleEdit = (row: any) => {
  isEdit.value = true
  Object.assign(formData, {
    id: row.id,
    name: row.name,
    phone: row.phone,
    password: '',
    email: row.email
  })
  dialogVisible.value = true
}

const handleToggleStatus = async (row: any) => {
  const isActiveNow = isActive(row.status)
  const action = isActiveNow ? '停用' : '启用'
  const newStatus = isActiveNow ? 'inactive' : 'active'
  await ElMessageBox.confirm(`确定要${action}管理员"${row.name}"吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  })

  try {
    await platformApi.updateAdminStatus(row.id, newStatus)
    ElMessage.success(`${action}成功`)
    loadData()
  } catch (error) {
    ElMessage.error(`${action}失败`)
  }
}

const handleResetPassword = async (row: any) => {
  await ElMessageBox.confirm(`确定要重置管理员"${row.name}"的密码为 123456 吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  })

  try {
    await platformApi.resetAdminPassword(row.id, '123456')
    ElMessage.success('密码已重置为 123456')
  } catch (error) {
    ElMessage.error('密码重置失败')
  }
}

const handleDelete = async (row: any) => {
  await ElMessageBox.confirm(`确定要删除管理员"${row.name}"吗？此操作不可恢复！`, '警告', {
    confirmButtonText: '确定删除',
    cancelButtonText: '取消',
    type: 'warning'
  })

  try {
    await platformApi.deleteAdmin(row.id)
    ElMessage.success('删除成功')
    loadData()
  } catch (error) {
    ElMessage.error('删除失败')
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
        const payload: any = {
          name: formData.name,
          phone: formData.phone,
          email: formData.email
        }
        await platformApi.updateAdmin(formData.id!, payload)
        ElMessage.success('编辑成功')
      } else {
        const payload: any = {
          name: formData.name,
          phone: formData.phone,
          email: formData.email
        }
        if (formData.password) {
          payload.password = formData.password
        }
        await platformApi.createAdmin(payload)
        ElMessage.success('创建成功，默认密码 123456')
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
.platform-admins {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
