<template>
  <div class="p-6">
    <el-card shadow="never">
      <template #header>
        <div class="flex justify-between items-center">
          <span class="font-bold text-lg">{{ isEdit ? '编辑政策' : '创建新政策' }}</span>
          <el-button @click="goBack">
            <el-icon class="mr-1"><ArrowLeft /></el-icon>
            返回列表
          </el-button>
        </div>
      </template>

      <el-form
        ref="formRef"
        :model="formData"
        :rules="formRules"
        label-width="120px"
        class="max-w-4xl"
      >
        <div class="bg-gray-50 rounded-xl p-6 mb-6">
          <h3 class="text-base font-bold mb-4 flex items-center">
            <el-icon class="mr-2"><Document /></el-icon>
            基本信息
          </h3>
          <el-row :gutter="24">
            <el-col :span="12">
              <el-form-item label="政策名称" prop="name" required>
                <el-input v-model="formData.name" placeholder="如：标准经销政策、VIP客户政策" />
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="政策类型" prop="type" required>
                <el-radio-group v-model="formData.type">
                  <el-radio value="default">默认通用</el-radio>
                  <el-radio value="vip">VIP客户</el-radio>
                  <el-radio value="promotion">限时促销</el-radio>
                </el-radio-group>
              </el-form-item>
            </el-col>
          </el-row>
          <el-form-item label="政策描述">
            <el-input
              v-model="formData.remark"
              type="textarea"
              :rows="3"
              placeholder="简要描述此政策的适用范围和特点..."
            />
          </el-form-item>
          <el-form-item>
            <el-checkbox v-model="formData.status">立即启用此政策</el-checkbox>
          </el-form-item>
        </div>

        <div class="bg-gray-50 rounded-xl p-6 mb-6">
          <h3 class="text-base font-bold mb-4 flex items-center">
            <el-icon class="mr-2"><PriceTag /></el-icon>
            账期与额度
          </h3>
          <el-row :gutter="24">
            <el-col :span="12">
              <el-form-item label="账期类型">
                <el-select v-model="formData.paymentType" style="width: 100%">
                  <el-option value="immediate" label="现结" />
                  <el-option value="monthly" label="月结" />
                  <el-option value="quarterly" label="季结" />
                </el-select>
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="信用额度">
                <el-input-number
                  v-model="formData.creditLimit"
                  :min="0"
                  :precision="2"
                  controls-position="right"
                  style="width: 100%"
                />
              </el-form-item>
            </el-col>
          </el-row>
          <el-row :gutter="24">
            <el-col :span="12">
              <el-form-item label="预存金要求">
                <el-input-number
                  v-model="formData.preDeposit"
                  :min="0"
                  :precision="2"
                  controls-position="right"
                  style="width: 100%"
                />
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="欠桶阈值">
                <el-input-number
                  v-model="formData.bucketThreshold"
                  :min="0"
                  controls-position="right"
                  style="width: 100%"
                />
              </el-form-item>
            </el-col>
          </el-row>
        </div>

        <div class="bg-gray-50 rounded-xl p-6">
          <div class="flex justify-between items-center mb-4">
            <h3 class="text-base font-bold flex items-center">
              <el-icon class="mr-2"><Goods /></el-icon>
              商品定价
            </h3>
            <el-button type="primary" plain @click="loadProducts">
              <el-icon class="mr-1"><Refresh /></el-icon>
              刷新商品列表
            </el-button>
          </div>
          <el-alert
            type="info"
            :closable="false"
            show-icon
            class="mb-4"
          >
            <template #title>
              提示：政策中的商品单价不能低于商品的最低指导价，最低起订量不能低于1
            </template>
          </el-alert>

          <el-table :data="formData.productPrices" stripe border>
            <el-table-column label="商品名称" min-width="200" prop="productName" />
            <el-table-column label="分类" width="100" align="center">
              <template #default="{ row }">
                <el-tag size="small" type="info">{{ getCategoryText(row.category) }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="出厂价" width="100" align="center">
              <template #default="{ row }">
                <span class="font-bold text-blue-600">¥{{ row.factoryPrice || 0 }}</span>
              </template>
            </el-table-column>
            <el-table-column label="最低指导价" width="120" align="center">
              <template #default="{ row }">
                <span class="text-orange-600 font-medium">¥{{ row.guidePriceMin || 0 }}</span>
              </template>
            </el-table-column>
            <el-table-column label="最高指导价" width="120" align="center">
              <template #default="{ row }">
                <span class="text-orange-600">¥{{ row.guidePriceMax || 0 }}</span>
              </template>
            </el-table-column>
            <el-table-column label="政策单价 *" width="150" align="center">
              <template #default="{ row }">
                <el-input-number
                  v-model="row.price"
                  :min="row.guidePriceMin || 0"
                  :precision="2"
                  :step="0.5"
                  size="small"
                  controls-position="right"
                  style="width: 100%"
                  @change="validatePrice(row)"
                />
              </template>
            </el-table-column>
            <el-table-column label="最低起订量 *" width="140" align="center">
              <template #default="{ row }">
                <el-input-number
                  v-model="row.minQuantity"
                  :min="1"
                  :max="9999"
                  :step="10"
                  size="small"
                  controls-position="right"
                  style="width: 100%"
                />
              </template>
            </el-table-column>
          </el-table>

          <div v-if="priceWarning" class="mt-4 p-3 bg-orange-50 border border-orange-200 rounded-lg">
            <div class="flex items-center text-orange-600">
              <el-icon class="mr-2"><Warning /></el-icon>
              <span>{{ priceWarning }}</span>
            </div>
          </div>
        </div>
      </el-form>

      <div class="flex justify-end gap-4 mt-6 pt-6 border-t">
        <el-button @click="goBack">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmit">
          {{ isEdit ? '保存修改' : '创建政策' }}
        </el-button>
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ArrowLeft, Document, PriceTag, Goods, Refresh, Warning } from '@element-plus/icons-vue'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'
import { policiesApi } from '@/api/policies'
import { productsApi } from '@/api/products'

interface ProductPrice {
  productId: string
  productName: string
  category: string
  factoryPrice: number
  guidePriceMin: number
  guidePriceMax: number
  price: number
  minQuantity: number
}

const route = useRoute()
const router = useRouter()
const formRef = ref<FormInstance>()
const submitting = ref(false)
const loading = ref(false)

const isEdit = computed(() => !!route.params.id)
const policyId = computed(() => route.params.id as string)

const formData = ref({
  name: '',
  type: 'default' as 'default' | 'vip' | 'promotion',
  remark: '',
  status: true,
  paymentType: 'immediate',
  creditLimit: 0,
  preDeposit: 0,
  bucketThreshold: 10,
  productPrices: [] as ProductPrice[]
})

const priceWarning = ref('')

const formRules: FormRules = {
  name: [
    { required: true, message: '请输入政策名称', trigger: 'blur' }
  ],
  type: [
    { required: true, message: '请选择政策类型', trigger: 'change' }
  ]
}

const getCategoryText = (category: string) => {
  const map: Record<string, string> = {
    bucket_water: '桶装水',
    bottled_water: '瓶装水',
    equipment: '饮水设备',
    other: '其他'
  }
  return map[category] || category
}

const validatePrice = (row: ProductPrice) => {
  if (row.price < (row.guidePriceMin || 0)) {
    priceWarning.value = `商品"${row.productName}"的单价 ¥${row.price} 低于最低指导价 ¥${row.guidePriceMin || 0}，请调整价格`
  } else {
    const hasLowPrice = formData.value.productPrices.some(
      p => p.price < (p.guidePriceMin || 0)
    )
    if (!hasLowPrice) {
      priceWarning.value = ''
    }
  }
}

const loadProducts = async () => {
  loading.value = true
  try {
    const res = await productsApi.getAll({ status: 'active' })
    const productList = res.data || []

    formData.value.productPrices = productList.map((p: any) => {
      const existing = formData.value.productPrices.find(ep => ep.productId === p.id?.toString())
      return {
        productId: p.id?.toString() || '',
        productName: p.name,
        category: p.category,
        factoryPrice: p.factoryPrice || 0,
        guidePriceMin: p.guidePriceMin || 0,
        guidePriceMax: p.guidePriceMax || 0,
        price: existing?.price || p.guidePriceMin || 0,
        minQuantity: existing?.minQuantity || 50
      }
    })
    ElMessage.success('商品列表已刷新')
  } catch (error) {
    console.error('加载商品列表失败:', error)
    ElMessage.error('加载商品列表失败')
  } finally {
    loading.value = false
  }
}

const loadPolicyDetail = async () => {
  if (!policyId.value) return

  loading.value = true
  try {
    const res = await policiesApi.getTemplateById(policyId.value)
    const policy = res.data

    if (policy) {
      formData.value.name = policy.name || ''
      formData.value.type = policy.type || 'default'
      formData.value.remark = policy.remark || ''
      formData.value.status = policy.status === 'active'
      formData.value.paymentType = policy.paymentType || 'immediate'
      formData.value.creditLimit = policy.creditLimit || 0
      formData.value.preDeposit = policy.preDeposit || 0
      formData.value.bucketThreshold = policy.bucketThreshold || 10

      if (policy.pricingRules && policy.pricingRules.length > 0) {
        await loadProducts()
        policy.pricingRules.forEach((rule: any) => {
          const existing = formData.value.productPrices.find(
            p => p.productId === rule.productId
          )
          if (existing) {
            existing.price = rule.price || existing.guidePriceMin || 0
            existing.minQuantity = rule.minQuantity || 50
          }
        })
      } else {
        await loadProducts()
      }
    }
  } catch (error) {
    console.error('加载政策详情失败:', error)
    ElMessage.error('加载政策详情失败')
  } finally {
    loading.value = false
  }
}

const handleSubmit = async () => {
  if (!formRef.value) return

  try {
    await formRef.value.validate()
  } catch {
    ElMessage.error('请检查表单填写是否正确')
    return
  }

  const hasLowPrice = formData.value.productPrices.some(
    p => p.price < (p.guidePriceMin || 0)
  )
  if (hasLowPrice) {
    ElMessage.error('存在商品单价低于最低指导价，请调整后重试')
    return
  }

  submitting.value = true
  try {
    const payload = {
      name: formData.value.name,
      type: formData.value.type,
      remark: formData.value.remark,
      status: formData.value.status ? 'active' : 'inactive',
      paymentType: formData.value.paymentType,
      creditLimit: formData.value.creditLimit || 0,
      preDeposit: formData.value.preDeposit || 0,
      bucketThreshold: formData.value.bucketThreshold || 10,
      pricingRules: formData.value.productPrices.map(p => ({
        productId: p.productId,
        productName: p.productName,
        category: p.category,
        price: p.price,
        minQuantity: p.minQuantity,
        guidePriceMin: p.guidePriceMin,
        guidePriceMax: p.guidePriceMax
      }))
    }

    if (isEdit.value) {
      await policiesApi.updateTemplate(policyId.value, payload)
      ElMessage.success('政策修改成功')
    } else {
      await policiesApi.createTemplate(payload)
      ElMessage.success('政策创建成功')
    }
    goBack()
  } catch (error: any) {
    console.error('提交失败:', error)
    ElMessage.error(error?.message || '提交失败，请重试')
  } finally {
    submitting.value = false
  }
}

const goBack = () => {
  router.push('/policies')
}

onMounted(async () => {
  await loadProducts()
  if (isEdit.value) {
    await loadPolicyDetail()
  }
})
</script>

<style scoped>
:deep(.el-input-number) {
  width: 100%;
}
</style>
