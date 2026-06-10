<template>
  <div class="station-staff-page">
    <el-page-header @back="goBack" class="mb-4">
      <template #content>
        <div class="page-header-content">
          <span class="page-title">店员账号管理</span>
          <span class="page-subtitle" v-if="stationName"> - {{ stationName }}</span>
        </div>
      </template>
    </el-page-header>

    <el-card shadow="never" class="mb-4">
      <div class="staff-header">
        <div class="staff-stats">
          <div class="stat-item">
            <span class="stat-value">{{ staffList.length }}</span>
            <span class="stat-label">店员总数</span>
          </div>
          <div class="stat-item">
            <span class="stat-value">{{ activeCount }}</span>
            <span class="stat-label">正常账号</span>
          </div>
          <div class="stat-item">
            <span class="stat-value">{{ inactiveCount }}</span>
            <span class="stat-label">已停用</span>
          </div>
        </div>
        <el-button type="primary" @click="openAddDialog">
          <el-icon><Plus /></el-icon>
          新增店员
        </el-button>
      </div>
    </el-card>

    <el-card shadow="never">
      <div v-if="loading" class="loading-container">
        <el-icon class="is-loading"><Loading /></el-icon>
        <span>加载中...</span>
      </div>

      <el-table v-else :data="staffList" stripe class="staff-table">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column label="姓名" min-width="120">
          <template #default="{ row }">
            <div class="staff-name-cell">
              <el-icon :size="24" color="#409eff"><User /></el-icon>
              <span>{{ row.name || '未设置' }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="phone" label="手机号" min-width="130">
          <template #default="{ row }">
            <span class="phone-text">{{ formatPhone(row.phone) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="角色" width="100">
          <template #default="{ row }">
            <el-tag :type="row.role === 'owner' ? 'success' : 'primary'" size="small">
              {{ row.role === 'owner' ? '店长' : '店员' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 'active' ? 'success' : 'danger'" size="small">
              {{ row.status === 'active' ? '正常' : '已停用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="openEditDialog(row)">编辑</el-button>
            <el-button link type="warning" @click="handleResetPassword(row)">重置密码</el-button>
            <el-button link type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
        <el-empty v-if="staffList.length === 0" description="暂无店员账号" :image-size="60" />
      </el-table>
    </el-card>

    <el-dialog v-model="showDialog" :title="dialogTitle" width="500px" destroy-on-close>
      <el-form :model="staffForm" :rules="formRules" ref="formRef" label-width="80px">
        <el-form-item label="姓名" prop="name">
          <el-input v-model="staffForm.name" placeholder="请输入店员姓名" />
        </el-form-item>
        <el-form-item label="手机号" prop="phone">
          <el-input v-model="staffForm.phone" placeholder="请输入手机号" :disabled="isEdit" />
        </el-form-item>
        <el-form-item label="角色" prop="role">
          <el-select v-model="staffForm.role" placeholder="请选择角色" style="width: 100%">
            <el-option label="店长" value="owner" />
            <el-option label="店员" value="staff" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="staffForm.status">
            <el-radio label="active">正常</el-radio>
            <el-radio label="inactive">停用</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item v-if="!isEdit" label="初始密码" prop="password">
          <el-input v-model="staffForm.password" type="password" placeholder="默认密码123456，可不填" show-password />
        </el-form-item>
        <el-form-item v-else label="新密码">
          <el-input v-model="staffForm.password" type="password" placeholder="留空则不修改密码" show-password />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showDialog = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="showResetDialog" title="重置密码" width="400px">
      <div class="reset-password-content">
        <el-icon :size="48" color="#e6a23c"><Warning /></el-icon>
        <p>确定要重置店员 <strong>{{ selectedStaff?.name }}</strong> 的密码吗？</p>
        <p class="reset-tip">重置后密码将变为：<strong>123456</strong></p>
      </div>
      <template #footer>
        <el-button @click="showResetDialog = false">取消</el-button>
        <el-button type="warning" :loading="resetting" @click="confirmResetPassword">确认重置</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="showDeleteDialog" title="删除店员" width="400px">
      <div class="delete-content">
        <el-icon :size="48" color="#f56c6c"><Warning /></el-icon>
        <p>确定要删除店员 <strong>{{ selectedStaff?.name }}</strong> 吗？</p>
        <p class="delete-tip">删除后该账号将无法登录，且无法恢复</p>
      </div>
      <template #footer>
        <el-button @click="showDeleteDialog = false">取消</el-button>
        <el-button type="danger" :loading="deleting" @click="confirmDelete">确认删除</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { stationsApi } from '@/api/stations'
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from 'element-plus'

const router = useRouter()
const route = useRoute()
const formRef = ref<FormInstance>()

const stationId = computed(() => route.params.id as string || '')
const stationName = ref('')

const loading = ref(false)
const submitting = ref(false)
const resetting = ref(false)
const deleting = ref(false)

const showDialog = ref(false)
const showResetDialog = ref(false)
const showDeleteDialog = ref(false)
const isEdit = ref(false)
const selectedStaff = ref<any>(null)

interface Staff {
  id: number
  name: string
  phone: string
  role: string
  status: string
}

const staffList = ref<Staff[]>([])

const staffForm = reactive({
  name: '',
  phone: '',
  role: 'staff',
  status: 'active',
  password: ''
})

const formRules: FormRules = {
  name: [{ required: true, message: '请输入店员姓名', trigger: 'blur' }],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ],
  role: [{ required: true, message: '请选择角色', trigger: 'change' }]
}

const activeCount = computed(() => staffList.value.filter(s => s.status === 'active').length)
const inactiveCount = computed(() => staffList.value.filter(s => s.status === 'inactive').length)
const dialogTitle = computed(() => isEdit.value ? '编辑店员' : '新增店员')

const formatPhone = (phone: string) => {
  if (!phone) return '-'
  return phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2')
}

const goBack = () => {
  router.push(`/stations/${stationId.value}`)
}

const fetchStaffList = async () => {
  if (!stationId.value) return
  loading.value = true
  try {
    const res: any = await stationsApi.getStaffs(stationId.value)
    if (res.data && Array.isArray(res.data)) {
      staffList.value = res.data
    } else if (Array.isArray(res)) {
      staffList.value = res
    } else {
      staffList.value = []
    }
    if (staffList.value.length > 0) {
      stationName.value = `水站 #${stationId.value}`
    }
  } catch (err: any) {
    console.error('获取店员列表失败:', err)
    ElMessage.error('获取店员列表失败')
    staffList.value = []
  } finally {
    loading.value = false
  }
}

const resetForm = () => {
  staffForm.name = ''
  staffForm.phone = ''
  staffForm.role = 'staff'
  staffForm.status = 'active'
  staffForm.password = ''
}

const openAddDialog = () => {
  isEdit.value = false
  resetForm()
  showDialog.value = true
}

const openEditDialog = (staff: Staff) => {
  isEdit.value = true
  selectedStaff.value = staff
  staffForm.name = staff.name || ''
  staffForm.phone = staff.phone || ''
  staffForm.role = staff.role || 'staff'
  staffForm.status = staff.status || 'active'
  staffForm.password = ''
  showDialog.value = true
}

const handleSubmit = async () => {
  if (!formRef.value) return
  try {
    await formRef.value.validate()
  } catch {
    return
  }

  submitting.value = true
  try {
    if (isEdit.value && selectedStaff.value) {
      await stationsApi.updateStaff(stationId.value, String(selectedStaff.value.id), {
        name: staffForm.name,
        phone: staffForm.phone,
        role: staffForm.role,
        status: staffForm.status,
        password: staffForm.password || undefined
      })
      ElMessage.success('店员信息更新成功')
    } else {
      await stationsApi.createStaff(stationId.value, {
        name: staffForm.name,
        phone: staffForm.phone,
        role: staffForm.role,
        status: staffForm.status,
        password: staffForm.password || undefined
      })
      ElMessage.success('店员账号创建成功')
    }
    showDialog.value = false
    await fetchStaffList()
  } catch (err: any) {
    console.error('操作失败:', err)
    ElMessage.error(err.message || '操作失败，请重试')
  } finally {
    submitting.value = false
  }
}

const handleResetPassword = (staff: Staff) => {
  selectedStaff.value = staff
  showResetDialog.value = true
}

const confirmResetPassword = async () => {
  if (!selectedStaff.value) return
  resetting.value = true
  try {
    await stationsApi.resetStaffPassword(stationId.value, String(selectedStaff.value.id))
    ElMessage.success('密码重置成功，新密码为 123456')
    showResetDialog.value = false
  } catch (err: any) {
    console.error('重置密码失败:', err)
    ElMessage.error(err.message || '重置密码失败，请重试')
  } finally {
    resetting.value = false
  }
}

const handleDelete = (staff: Staff) => {
  selectedStaff.value = staff
  showDeleteDialog.value = true
}

const confirmDelete = async () => {
  if (!selectedStaff.value) return
  deleting.value = true
  try {
    await stationsApi.deleteStaff(stationId.value, String(selectedStaff.value.id))
    ElMessage.success('店员账号删除成功')
    showDeleteDialog.value = false
    await fetchStaffList()
  } catch (err: any) {
    console.error('删除失败:', err)
    ElMessage.error(err.message || '删除失败，请重试')
  } finally {
    deleting.value = false
  }
}

onMounted(() => {
  fetchStaffList()
})
</script>

<style scoped>
.station-staff-page {
  padding: 0;
}

.mb-4 {
  margin-bottom: 20px;
}

.page-header-content {
  display: flex;
  align-items: center;
}

.page-title {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
}

.page-subtitle {
  font-size: 14px;
  color: #909399;
  margin-left: 8px;
}

.staff-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.staff-stats {
  display: flex;
  gap: 32px;
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.stat-value {
  font-size: 24px;
  font-weight: 600;
  color: #409eff;
}

.stat-label {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
}

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 0;
  color: #909399;
  gap: 12px;
}

.staff-table {
  min-height: 200px;
}

.staff-name-cell {
  display: flex;
  align-items: center;
  gap: 8px;
}

.phone-text {
  font-family: monospace;
}

.reset-password-content,
.delete-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
  text-align: center;
}

.reset-tip,
.delete-tip {
  font-size: 14px;
  color: #909399;
}

.reset-tip strong,
.delete-tip strong {
  color: #303133;
}
</style>
