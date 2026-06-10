<template>
  <div>
    <div class="page-header">
      <div>
        <h2 class="page-title">管理员管理</h2>
        <p class="page-desc">管理系统管理员账号和权限配置</p>
      </div>
      <el-button type="primary" @click="openAdminDialog('add')">
        <el-icon><Plus /></el-icon>
        添加管理员
      </el-button>
    </div>

    <el-card shadow="never">
      <el-row :gutter="16">
        <el-col v-for="admin in admins" :key="admin.id" :span="12" class="admin-col">
          <el-card shadow="hover" class="admin-card">
            <div class="admin-content">
              <div class="admin-avatar">
                <el-avatar v-if="admin.avatar" :src="admin.avatar" :size="56" />
                <div v-else class="avatar-placeholder">
                  <el-icon size="28" color="#409eff"><User /></el-icon>
                </div>
              </div>
              <div class="admin-info">
                <div class="admin-name-row">
                  <span class="admin-name">{{ admin.name }}</span>
                  <el-tag v-if="admin.role === 'super_admin'" type="danger" size="small">超级管理员</el-tag>
                </div>
                <p class="admin-role">{{ getRoleName(admin.role) }}</p>
                <p class="admin-login-time">最后登录: {{ admin.lastLogin || '从未登录' }}</p>
              </div>
              <div class="admin-actions">
                <el-tag :type="admin.status === 'active' ? 'success' : 'info'" size="small">
                  {{ admin.status === 'active' ? '启用' : '停用' }}
                </el-tag>
                <div class="action-buttons">
                  <el-button link @click.stop="openAdminDialog('edit', admin)">
                    <el-icon><Edit /></el-icon>
                  </el-button>
                  <el-button link @click.stop="handleResetPassword(admin)">
                    <el-icon><Key /></el-icon>
                  </el-button>
                  <el-button
                    :type="admin.status === 'active' ? 'warning' : 'success'"
                    link
                    @click.stop="toggleAdminStatus(admin)"
                  >
                    <el-icon><component :is="admin.status === 'active' ? 'CloseBold' : 'Check'" /></el-icon>
                  </el-button>
                  <el-button
                    v-if="admin.role !== 'super_admin'"
                    type="danger"
                    link
                    @click.stop="handleDeleteAdmin(admin)"
                  >
                    <el-icon><Delete /></el-icon>
                  </el-button>
                </div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>

      <el-empty v-if="admins.length === 0" description="暂无管理员数据">
        <el-button type="primary" @click="openAdminDialog('add')">添加管理员</el-button>
      </el-empty>
    </el-card>

    <el-dialog
      v-model="showAdminDialog"
      :title="dialogMode === 'add' ? '添加管理员' : '编辑管理员'"
      width="600px"
      :close-on-click-modal="false"
    >
      <el-form :model="adminForm" label-width="100px">
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="姓名" required>
              <el-input v-model="adminForm.name" placeholder="请输入管理员姓名" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="手机号码" required>
              <el-input v-model="adminForm.phone" placeholder="请输入手机号码" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="账号" required>
              <el-input v-model="adminForm.username" placeholder="请输入登录账号" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item :label="dialogMode === 'add' ? '初始密码' : '新密码'">
              <el-input
                v-model="adminForm.password"
                type="password"
                show-password
                :placeholder="dialogMode === 'add' ? '请输入初始密码' : '留空则不修改'"
              />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="角色" required>
          <el-radio-group v-model="adminForm.role">
            <el-radio value="super_admin">超级管理员</el-radio>
            <el-radio value="finance_admin">财务主管</el-radio>
            <el-radio value="warehouse_admin">仓管经理</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="权限配置">
          <div class="permissions-box">
            <el-checkbox v-model="adminForm.permissions" value="stations" label="水站管理" />
            <el-checkbox v-model="adminForm.permissions" value="products" label="产品管理" />
            <el-checkbox v-model="adminForm.permissions" value="inventory" label="库存管理" />
            <el-checkbox v-model="adminForm.permissions" value="finance" label="财务管理" />
            <el-checkbox v-model="adminForm.permissions" value="reports" label="报表统计" />
            <el-checkbox v-model="adminForm.permissions" value="settings" label="系统设置" />
          </div>
        </el-form-item>
        <el-form-item>
          <el-checkbox v-model="adminForm.status">启用此账号</el-checkbox>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="closeAdminDialog">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleAdminSubmit">
          {{ dialogMode === 'add' ? '创建账号' : '保存修改' }}
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, User, Edit, Key, Delete } from '@element-plus/icons-vue'
import { systemApi } from '@/api/system'
import type { AdminVO } from '@/api/system'

const admins = ref<AdminVO[]>([])
const loading = ref(false)
const submitting = ref(false)

const showAdminDialog = ref(false)
const dialogMode = ref<'add' | 'edit'>('add')
const selectedAdmin = ref<AdminVO | null>(null)

const adminForm = reactive({
  name: '',
  username: '',
  phone: '',
  password: '',
  role: 'warehouse_admin',
  permissions: [] as string[],
  status: true
})

const getRoleName = (role: string) => {
  const roleMap: Record<string, string> = {
    super_admin: '超级管理员',
    finance_admin: '财务主管',
    warehouse_admin: '仓管经理'
  }
  return roleMap[role] || role
}

const loadAdmins = async () => {
  loading.value = true
  try {
    const res: any = await systemApi.getAdmins()
    if (Array.isArray(res)) {
      admins.value = res
    } else if (res && res.records) {
      admins.value = Array.isArray(res.records) ? res.records : []
    } else {
      admins.value = []
    }
  } catch (error) {
    console.error('获取管理员列表失败:', error)
    admins.value = []
  } finally {
    loading.value = false
  }
}

const openAdminDialog = (mode: 'add' | 'edit', admin?: AdminVO) => {
  dialogMode.value = mode
  if (mode === 'edit' && admin) {
    selectedAdmin.value = admin
    Object.assign(adminForm, {
      name: admin.name,
      username: admin.username || '',
      phone: admin.phone || '',
      password: '',
      role: admin.role,
      permissions: admin.permissions || [],
      status: admin.status === 'active'
    })
  } else {
    selectedAdmin.value = null
    Object.assign(adminForm, {
      name: '',
      username: '',
      phone: '',
      password: '',
      role: 'warehouse_admin',
      permissions: [],
      status: true
    })
  }
  showAdminDialog.value = true
}

const closeAdminDialog = () => {
  showAdminDialog.value = false
  selectedAdmin.value = null
}

const handleAdminSubmit = async () => {
  if (!adminForm.name || !adminForm.phone) {
    ElMessage.warning('请填写必填项')
    return
  }

  submitting.value = true
  try {
    await new Promise(resolve => setTimeout(resolve, 500))
    if (dialogMode.value === 'add') {
      await systemApi.createAdmin(adminForm as any)
      ElMessage.success('添加成功')
    } else if (selectedAdmin.value) {
      await systemApi.updateAdmin(selectedAdmin.value.id, adminForm as any)
      ElMessage.success('修改成功')
    }
    closeAdminDialog()
    await loadAdmins()
  } catch (error) {
    console.error('提交失败:', error)
    ElMessage.error('操作失败，请重试')
  } finally {
    submitting.value = false
  }
}

const handleResetPassword = async (admin: AdminVO) => {
  try {
    await ElMessageBox.confirm(`确定要重置 ${admin.name} 的密码吗？`, '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await systemApi.resetAdminPassword(admin.id)
    ElMessage.success('密码已重置为 123456')
  } catch (error: any) {
    if (error !== 'cancel') {
      console.error('重置密码失败:', error)
      ElMessage.error('操作失败，请重试')
    }
  }
}

const toggleAdminStatus = async (admin: AdminVO) => {
  try {
    if (admin.status === 'active') {
      await systemApi.disableAdmin(admin.id)
      ElMessage.success('已停用')
    } else {
      await systemApi.enableAdmin(admin.id)
      ElMessage.success('已启用')
    }
    await loadAdmins()
  } catch (error) {
    console.error('更新状态失败:', error)
    ElMessage.error('操作失败，请重试')
  }
}

const handleDeleteAdmin = async (admin: AdminVO) => {
  try {
    await ElMessageBox.confirm(`确定要删除管理员 "${admin.name}" 吗？此操作不可恢复。`, '警告', {
      confirmButtonText: '确定删除',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await systemApi.deleteAdmin(admin.id)
    ElMessage.success('删除成功')
    await loadAdmins()
  } catch (error: any) {
    if (error !== 'cancel') {
      console.error('删除失败:', error)
      ElMessage.error('操作失败，请重试')
    }
  }
}

onMounted(() => {
  loadAdmins()
})
</script>

<style scoped>
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.page-title {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
  margin: 0;
}

.page-desc {
  font-size: 14px;
  color: #909399;
  margin: 4px 0 0 0;
}

.admin-col {
  margin-bottom: 16px;
}

.admin-card {
  cursor: pointer;
  transition: all 0.3s;
}

.admin-card:hover {
  transform: translateY(-2px);
}

.admin-content {
  display: flex;
  align-items: flex-start;
  gap: 16px;
}

.admin-avatar {
  flex-shrink: 0;
}

.avatar-placeholder {
  width: 56px;
  height: 56px;
  background: #ecf5ff;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.admin-info {
  flex: 1;
  min-width: 0;
}

.admin-name-row {
  display: flex;
  align-items: center;
  gap: 8px;
}

.admin-name {
  font-weight: 600;
  font-size: 16px;
  color: #303133;
}

.admin-role {
  font-size: 13px;
  color: #909399;
  margin: 4px 0 0 0;
}

.admin-login-time {
  font-size: 12px;
  color: #c0c4cc;
  margin: 4px 0 0 0;
}

.admin-actions {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 8px;
}

.action-buttons {
  display: flex;
  gap: 4px;
}

.permissions-box {
  background: #f5f7fa;
  padding: 16px;
  border-radius: 8px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}
</style>
