<template>
  <div>
    <!-- 政策卡片列表 -->
    <div class="mb-8">
      <div class="text-sm font-bold text-gray-400 uppercase tracking-widest mb-4">当前生效模板</div>
      <el-row :gutter="16">
        <el-col v-for="policy in policyStore.policies" :key="policy.id" :span="8">
          <el-card shadow="hover" class="mb-4 relative overflow-hidden">
            <template #header>
              <div class="flex justify-between items-start">
                <div
                  class="w-12 h-12 rounded-xl flex items-center justify-center"
                  :class="getPolicyTypeClass(policy.type)"
                >
                  <el-icon size="24"><component :is="getPolicyIcon(policy.type)" /></el-icon>
                </div>
                <el-tag :type="getPolicyTagType(policy.type)" size="small">
                  {{ getPolicyTypeText(policy.type) }}
                </el-tag>
              </div>
            </template>
            <div>
              <h4 class="text-lg font-bold mb-2">{{ policy.name }}</h4>
              <p class="text-sm text-gray-400 mb-4">{{ policy.remark || '暂无描述' }}</p>
              <div class="border-t border-gray-100 pt-4 space-y-2">
                <div class="flex justify-between text-xs">
                  <span class="text-gray-400">桶装水(18L)</span>
                  <span class="font-bold">¥ {{ policy.pricingRules?.[0]?.price || 0 }}/桶</span>
                </div>
                <div class="flex justify-between text-xs">
                  <span class="text-gray-400">最低起订量</span>
                  <span class="font-bold">{{ policy.pricingRules?.[0]?.minQuantity || 50 }} 桶</span>
                </div>
              </div>
              <div class="mt-4 flex justify-between items-center">
                <span class="text-xs text-gray-400">状态: {{ policy.status === 'active' ? '启用' : '停用' }}</span>
                <el-button link type="primary" @click="goToEdit(policy)">配置详情</el-button>
              </div>
            </div>
            <div class="absolute top-4 right-16">
              <el-dropdown trigger="click" @command="(cmd: string) => handlePolicyAction(cmd, policy)">
                <el-button link><el-icon><MoreFilled /></el-icon></el-button>
                <template #dropdown>
                  <el-dropdown-menu>
                    <el-dropdown-item command="edit">编辑政策</el-dropdown-item>
                    <el-dropdown-item command="duplicate">复制政策</el-dropdown-item>
                    <el-dropdown-item :command="policy.status === 'active' ? 'disable' : 'enable'">
                      {{ policy.status === 'active' ? '停用政策' : '启用政策' }}
                    </el-dropdown-item>
                    <el-dropdown-item command="delete" divided style="color: var(--el-color-danger)">删除政策</el-dropdown-item>
                  </el-dropdown-menu>
                </template>
              </el-dropdown>
            </div>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card shadow="hover" class="mb-4 cursor-pointer h-full flex items-center justify-center" @click="goToCreate">
            <div class="text-center">
              <div class="w-12 h-12 rounded-xl bg-gray-100 flex items-center justify-center mx-auto mb-4">
                <el-icon size="32" class="text-gray-400"><Plus /></el-icon>
              </div>
              <p class="text-sm font-medium text-gray-500">创建新政策</p>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- 删除确认对话框 -->
    <el-dialog v-model="showConfirmDialog" title="确认删除" width="400px">
      <div class="text-center">
        <el-icon size="64" class="text-red-500 mb-4"><Warning /></el-icon>
        <p class="text-lg mb-2">确定要删除政策"{{ confirmDeletePolicy?.name }}"吗？</p>
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
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Plus, MoreFilled, Warning } from '@element-plus/icons-vue'
import { usePolicyStore } from '@/stores/policies'
import type { PolicyTemplateVO } from '@/api/policies'
import { ElMessage } from 'element-plus'

const router = useRouter()
const policyStore = usePolicyStore()

const policyTypes = [
  { value: 'default', label: '默认通用', description: '适用于常规水站' },
  { value: 'vip', label: 'VIP客户', description: '核心区域大型水站' },
  { value: 'promotion', label: '限时促销', description: '促销活动专用' }
]

const showConfirmDialog = ref(false)
const confirmDeletePolicy = ref<PolicyTemplateVO | null>(null)

const getPolicyTypeText = (type: string) => {
  return policyTypes.find(t => t.value === type)?.label || type
}

const getPolicyIcon = (type: string) => {
  const icons: Record<string, string> = {
    default: 'PriceTag',
    vip: 'Crown',
    promotion: 'Sunny'
  }
  return icons[type] || 'PriceTag'
}

const getPolicyTypeClass = (type: string) => {
  const classes: Record<string, string> = {
    default: 'bg-blue-50 text-blue-500',
    vip: 'bg-green-50 text-green-500',
    promotion: 'bg-orange-50 text-orange-500'
  }
  return classes[type] || 'bg-blue-50 text-blue-500'
}

const getPolicyTagType = (type: string) => {
  const types: Record<string, string> = {
    default: '',
    vip: 'success',
    promotion: 'warning'
  }
  return types[type] || ''
}

const goToCreate = () => {
  router.push('/policies/create')
}

const goToEdit = (policy: PolicyTemplateVO) => {
  router.push(`/policies/${policy.id}/edit`)
}

const handlePolicyAction = async (command: string, policy: PolicyTemplateVO) => {
  if (command === 'edit') {
    router.push(`/policies/${policy.id}/edit`)
  } else if (command === 'duplicate') {
    await policyStore.copyPolicy(policy.id)
    ElMessage.success('复制政策成功')
  } else if (command === 'enable') {
    await policyStore.enablePolicy(policy.id)
    ElMessage.success('政策已启用')
  } else if (command === 'disable') {
    await policyStore.disablePolicy(policy.id)
    ElMessage.success('政策已停用')
  } else if (command === 'delete') {
    openDeleteConfirm(policy)
  }
}

const openDeleteConfirm = (policy: PolicyTemplateVO) => {
  confirmDeletePolicy.value = policy
  showConfirmDialog.value = true
}

const closeConfirmDialog = () => {
  showConfirmDialog.value = false
  confirmDeletePolicy.value = null
}

const confirmDelete = async () => {
  if (confirmDeletePolicy.value) {
    await policyStore.deletePolicy(confirmDeletePolicy.value.id)
    ElMessage.success('删除政策成功')
  }
  closeConfirmDialog()
}

onMounted(async () => {
  await policyStore.fetchPolicies()
})
</script>

<style scoped>
:deep(.el-card) {
  border-radius: 16px;
}
</style>
