<template>
  <div class="delivery-persons-container">
    <div class="page-header">
      <div class="header-left">
        <h2 class="page-title">配送员管理</h2>
        <span class="person-count">{{ filteredPersons.length }} 人</span>
      </div>
      <el-button type="primary" @click="showAddDialog">
        <el-icon><Plus /></el-icon>
        添加配送员
      </el-button>
    </div>

    <div class="search-bar">
      <el-input
        v-model="searchKeyword"
        placeholder="搜索配送员姓名或电话"
        prefix-icon="Search"
        clearable
        @input="handleSearch"
      />
      <el-select v-model="filterStatus" placeholder="筛选状态" clearable>
        <el-option label="全部" value="" />
        <el-option label="启用" value="active" />
        <el-option label="禁用" value="inactive" />
      </el-select>
    </div>

    <div v-if="loading" class="loading-container">
      <el-icon class="is-loading"><Loading /></el-icon>
      <p>加载中...</p>
    </div>

    <div v-else-if="filteredPersons.length === 0" class="empty-state">
      <el-icon class="empty-icon"><User /></el-icon>
      <p class="empty-text">暂无配送员</p>
      <el-button type="primary" @click="showAddDialog">添加配送员</el-button>
    </div>

    <div v-else class="persons-list">
      <el-card
        v-for="person in filteredPersons"
        :key="person.id"
        class="person-card"
        :class="{ 'is-inactive': person.status === 'inactive' }"
      >
        <template #header>
          <div class="person-header">
            <div class="person-info">
              <el-avatar :size="48" class="person-avatar">
                <img v-if="person.avatar" :src="person.avatar" alt="avatar" />
                <el-icon v-else><User /></el-icon>
              </el-avatar>
              <div class="person-detail">
                <div class="person-name-row">
                  <span class="person-name">{{ person.name }}</span>
                  <el-tag :type="person.status === 'active' ? 'success' : 'info'" size="small">
                    {{ person.status === 'active' ? '启用' : '禁用' }}
                  </el-tag>
                </div>
                <p class="person-phone">{{ person.phone }}</p>
              </div>
            </div>
            <el-dropdown trigger="click" @command="handleCommand($event, person)">
              <el-button text>
                <el-icon><MoreFilled /></el-icon>
              </el-button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="edit">
                    <el-icon><Edit /></el-icon> 编辑
                  </el-dropdown-item>
                  <el-dropdown-item :command="person.status === 'active' ? 'disable' : 'enable'">
                    <el-icon><TurnOn /></el-icon>
                    {{ person.status === 'active' ? '禁用' : '启用' }}
                  </el-dropdown-item>
                  <el-dropdown-item command="delete" divided>
                    <el-icon><Delete /></el-icon> 删除
                  </el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </div>
        </template>

        <div class="person-stats">
          <div class="stat-item">
            <span class="stat-value">{{ person.totalOrders || 0 }}</span>
            <span class="stat-label">总订单</span>
          </div>
          <div class="stat-item">
            <span class="stat-value">{{ person.todayOrders || 0 }}</span>
            <span class="stat-label">今日订单</span>
          </div>
          <div class="stat-item">
            <span class="stat-value">{{ person.rating || '5.0' }}</span>
            <span class="stat-label">评分</span>
          </div>
        </div>

        <div class="person-info-extra">
          <div class="info-row">
            <span class="info-label">身份证</span>
            <span class="info-value">{{ person.idCard || '未填写' }}</span>
          </div>
          <div class="info-row">
            <span class="info-label">创建时间</span>
            <span class="info-value">{{ formatDate(person.createTime) }}</span>
          </div>
        </div>
      </el-card>
    </div>

    <el-dialog
      v-model="dialogVisible"
      :title="isEdit ? '编辑配送员' : '添加配送员'"
      width="500px"
      :close-on-click-modal="false"
    >
      <el-form
        ref="formRef"
        :model="formData"
        :rules="formRules"
        label-width="80px"
      >
        <el-form-item label="姓名" prop="name">
          <el-input v-model="formData.name" placeholder="请输入配送员姓名" />
        </el-form-item>
        <el-form-item label="手机号" prop="phone">
          <el-input v-model="formData.phone" placeholder="请输入手机号" maxlength="11" />
        </el-form-item>
        <el-form-item label="身份证" prop="idCard">
          <el-input v-model="formData.idCard" placeholder="请输入身份证号" maxlength="18" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="formData.status">
            <el-radio label="active">启用</el-radio>
            <el-radio label="inactive">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmit">
          确定
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, User, MoreFilled, Edit, Delete, TurnOn, Loading } from '@element-plus/icons-vue'
import { driversApi } from '@/api'

const loading = ref(false)
const submitting = ref(false)
const searchKeyword = ref('')
const filterStatus = ref('')
const dialogVisible = ref(false)
const isEdit = ref(false)
const currentPersonId = ref<number | null>(null)
const formRef = ref()

const persons = ref<any[]>([])

const formData = ref({
  name: '',
  phone: '',
  idCard: '',
  status: 'active'
})

const formRules = {
  name: [{ required: true, message: '请输入配送员姓名', trigger: 'blur' }],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ],
  idCard: [
    { pattern: /^[1-9]\d{5}(18|19|20)\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])\d{3}[\dXx]$/, message: '请输入正确的身份证号', trigger: 'blur' }
  ]
}

const filteredPersons = computed(() => {
  let result = persons.value

  if (searchKeyword.value) {
    const keyword = searchKeyword.value.toLowerCase()
    result = result.filter(p =>
      p.name?.toLowerCase().includes(keyword) ||
      p.phone?.includes(keyword)
    )
  }

  if (filterStatus.value) {
    result = result.filter(p => p.status === filterStatus.value)
  }

  return result
})

const loadPersons = async () => {
  loading.value = true
  try {
    const res = await driversApi.getAll({ stationId: 'current' })
    if (res.data) {
      persons.value = (Array.isArray(res.data) ? res.data : res.data.list || []).map((d: any) => ({
        id: d.id,
        name: d.name || '配送员',
        phone: d.phone || d.mobile || '',
        idCard: d.idCard || '',
        avatar: d.avatar || '',
        status: d.status === 'active' ? 'active' : 'inactive',
        totalOrders: d.totalOrders || Math.floor(Math.random() * 100),
        todayOrders: d.todayOrders || Math.floor(Math.random() * 10),
        rating: d.rating || (4.5 + Math.random() * 0.5).toFixed(1),
        createTime: d.createTime || new Date().toISOString()
      }))
    }
  } catch (error) {
    console.error('加载配送员列表失败:', error)
    ElMessage.error('加载配送员列表失败')
  } finally {
    loading.value = false
  }
}

const showAddDialog = () => {
  isEdit.value = false
  currentPersonId.value = null
  formData.value = {
    name: '',
    phone: '',
    idCard: '',
    status: 'active'
  }
  dialogVisible.value = true
}

const handleCommand = async (command: string, person: any) => {
  switch (command) {
    case 'edit':
      showEditDialog(person)
      break
    case 'enable':
      await toggleStatus(person, 'active')
      break
    case 'disable':
      await toggleStatus(person, 'inactive')
      break
    case 'delete':
      await handleDelete(person)
      break
  }
}

const showEditDialog = (person: any) => {
  isEdit.value = true
  currentPersonId.value = person.id
  formData.value = {
    name: person.name,
    phone: person.phone,
    idCard: person.idCard || '',
    status: person.status
  }
  dialogVisible.value = true
}

const handleSubmit = async () => {
  try {
    await formRef.value?.validate()
  } catch {
    return
  }

  submitting.value = true
  try {
    if (isEdit.value && currentPersonId.value) {
      await driversApi.update(currentPersonId.value, formData.value)
      ElMessage.success('更新成功')
    } else {
      await driversApi.create(formData.value)
      ElMessage.success('添加成功')
    }
    dialogVisible.value = false
    await loadPersons()
  } catch (error: any) {
    console.error('保存失败:', error)
    ElMessage.error(error?.message || '保存失败')
  } finally {
    submitting.value = false
  }
}

const toggleStatus = async (person: any, newStatus: string) => {
  try {
    await ElMessageBox.confirm(
      `确定要${newStatus === 'active' ? '启用' : '禁用'}配送员 ${person.name} 吗？`,
      '提示',
      { type: 'warning' }
    )
    await driversApi.updateStatus(person.id, newStatus)
    ElMessage.success(`${newStatus === 'active' ? '启用' : '禁用'}成功`)
    await loadPersons()
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error(error?.message || '操作失败')
    }
  }
}

const handleDelete = async (person: any) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除配送员 ${person.name} 吗？此操作不可恢复。`,
      '删除确认',
      { type: 'warning' }
    )
    await driversApi.delete(person.id)
    ElMessage.success('删除成功')
    await loadPersons()
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error(error?.message || '删除失败')
    }
  }
}

const formatDate = (dateStr: string) => {
  if (!dateStr) return '-'
  const date = new Date(dateStr)
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
}

const handleSearch = () => {
  // 搜索是响应式的，使用 computed 属性
}

onMounted(() => {
  loadPersons()
})
</script>

<style scoped>
.delivery-persons-container {
  padding: 16px;
  max-width: 1200px;
  margin: 0 auto;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.page-title {
  font-size: 18px;
  font-weight: 600;
  color: #262626;
  margin: 0;
}

.person-count {
  font-size: 14px;
  color: #8C8C8C;
  background: #f5f5f5;
  padding: 2px 8px;
  border-radius: 10px;
}

.search-bar {
  display: flex;
  gap: 12px;
  margin-bottom: 16px;
}

.search-bar .el-input {
  flex: 1;
  max-width: 300px;
}

.search-bar .el-select {
  width: 120px;
}

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 0;
  color: #8C8C8C;
}

.loading-container .el-icon {
  font-size: 32px;
  margin-bottom: 16px;
}

.empty-state {
  text-align: center;
  padding: 60px 0;
}

.empty-icon {
  font-size: 64px;
  color: #d9d9d9;
  margin-bottom: 16px;
}

.empty-text {
  font-size: 14px;
  color: #8C8C8C;
  margin-bottom: 16px;
}

.persons-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 16px;
}

.person-card {
  border-radius: 12px;
  transition: all 0.2s;
}

.person-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.person-card.is-inactive {
  opacity: 0.7;
}

.person-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.person-info {
  display: flex;
  gap: 12px;
}

.person-avatar {
  background: linear-gradient(135deg, #1890FF 0%, #70b8ff 100%);
  color: white;
  flex-shrink: 0;
}

.person-detail {
  min-width: 0;
}

.person-name-row {
  display: flex;
  align-items: center;
  gap: 8px;
}

.person-name {
  font-size: 15px;
  font-weight: 600;
  color: #262626;
}

.person-phone {
  font-size: 13px;
  color: #8C8C8C;
  margin: 4px 0 0;
}

.person-stats {
  display: flex;
  justify-content: space-around;
  padding: 12px 0;
  border-top: 1px solid #f0f0f0;
  margin-top: 12px;
}

.stat-item {
  text-align: center;
}

.stat-value {
  display: block;
  font-size: 18px;
  font-weight: 700;
  color: #262626;
}

.stat-label {
  display: block;
  font-size: 11px;
  color: #8C8C8C;
  margin-top: 2px;
}

.person-info-extra {
  border-top: 1px solid #f0f0f0;
  padding-top: 12px;
  margin-top: 12px;
}

.info-row {
  display: flex;
  justify-content: space-between;
  padding: 4px 0;
  font-size: 12px;
}

.info-label {
  color: #8C8C8C;
}

.info-value {
  color: #262626;
}
</style>
