import { defineStore } from 'pinia'
import { ref } from 'vue'
import { policiesApi, type PolicyTemplateVO, type PolicyTemplateDTO } from '@/api/policies'

export const usePolicyStore = defineStore('policy', () => {
  const policies = ref<PolicyTemplateVO[]>([])
  const loading = ref(false)

  const fetchPolicies = async () => {
    loading.value = true
    try {
      const res: any = await policiesApi.getTemplates()
      if (res.data) {
        policies.value = res.data
      } else {
        policies.value = []
      }
    } catch (error) {
      console.error('获取政策模板列表失败:', error)
      policies.value = []
    } finally {
      loading.value = false
    }
  }

  const getPolicyById = async (id: string) => {
    try {
      const res: any = await policiesApi.getTemplateById(id)
      return { success: true, data: res.data }
    } catch (error) {
      console.error('获取政策详情失败:', error)
      return { success: false, message: '获取政策详情失败' }
    }
  }

  const createPolicy = async (data: PolicyTemplateDTO) => {
    loading.value = true
    try {
      await policiesApi.createTemplate(data)
      await fetchPolicies()
      return { success: true }
    } catch (error) {
      console.error('创建政策模板失败:', error)
      return { success: false, message: '创建政策模板失败' }
    } finally {
      loading.value = false
    }
  }

  const updatePolicy = async (id: string, data: PolicyTemplateDTO) => {
    loading.value = true
    try {
      await policiesApi.updateTemplate(id, data)
      await fetchPolicies()
      return { success: true }
    } catch (error) {
      console.error('更新政策模板失败:', error)
      return { success: false, message: '更新政策模板失败' }
    } finally {
      loading.value = false
    }
  }

  const deletePolicy = async (id: string) => {
    loading.value = true
    try {
      await policiesApi.deleteTemplate(id)
      await fetchPolicies()
      return { success: true }
    } catch (error) {
      console.error('删除政策模板失败:', error)
      return { success: false, message: '删除政策模板失败' }
    } finally {
      loading.value = false
    }
  }

  const copyPolicy = async (id: string) => {
    loading.value = true
    try {
      await policiesApi.copyTemplate(id)
      await fetchPolicies()
      return { success: true }
    } catch (error) {
      console.error('复制政策模板失败:', error)
      return { success: false, message: '复制政策模板失败' }
    } finally {
      loading.value = false
    }
  }

  const enablePolicy = async (id: string) => {
    try {
      await policiesApi.enableTemplate(id)
      await fetchPolicies()
      return { success: true }
    } catch (error) {
      console.error('启用政策模板失败:', error)
      return { success: false, message: '启用政策模板失败' }
    }
  }

  const disablePolicy = async (id: string) => {
    try {
      await policiesApi.disableTemplate(id)
      await fetchPolicies()
      return { success: true }
    } catch (error) {
      console.error('停用政策模板失败:', error)
      return { success: false, message: '停用政策模板失败' }
    }
  }

  return {
    policies,
    loading,
    fetchPolicies,
    getPolicyById,
    createPolicy,
    updatePolicy,
    deletePolicy,
    copyPolicy,
    enablePolicy,
    disablePolicy
  }
})
