<template>
  <div class="p-6">
    <el-card shadow="never">
      <template #header>
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-4">
            <el-button circle @click="goBack">
              <el-icon><ArrowLeft /></el-icon>
            </el-button>
            <span class="text-lg font-bold">新增产品</span>
          </div>
        </div>
      </template>

      <el-form :model="productForm" label-width="120px" class="max-w-4xl" @submit.prevent="handleSubmit">
        <el-form-item label="产品名称" required>
          <el-input v-model="productForm.name" placeholder="如：18L 桶装纯净水" />
        </el-form-item>

        <el-form-item label="产品分类" required>
          <el-select v-model="productForm.category" style="width: 100%">
            <el-option value="" label="请选择分类" />
            <el-option value="bucket_water" label="桶装水" />
            <el-option value="bottle_water" label="瓶装水" />
            <el-option value="equipment" label="饮水设备" />
            <el-option value="other" label="其他" />
          </el-select>
        </el-form-item>

        <el-form-item label="产品规格">
          <el-input v-model="productForm.spec" placeholder="如：18.9L、24瓶/箱" />
        </el-form-item>

        <el-row :gutter="24">
          <el-col :span="12">
            <el-form-item label="出厂价" required>
              <el-input v-model.number="productForm.factoryPrice" type="number" step="0.01" placeholder="0.00">
                <template #prepend>¥</template>
              </el-input>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="计量单位">
              <el-select v-model="productForm.unit" style="width: 100%">
                <el-option value="桶" label="桶" />
                <el-option value="箱" label="箱" />
                <el-option value="个" label="个" />
                <el-option value="件" label="件" />
                <el-option value="台" label="台" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="指导价区间">
          <el-row :gutter="12">
            <el-col :span="12">
              <el-input v-model.number="productForm.guidePriceMin" type="number" step="0.01" placeholder="最低价格">
                <template #prepend>最低 ¥</template>
              </el-input>
            </el-col>
            <el-col :span="12">
              <el-input v-model.number="productForm.guidePriceMax" type="number" step="0.01" placeholder="最高价格">
                <template #prepend>最高 ¥</template>
              </el-input>
            </el-col>
          </el-row>
        </el-form-item>

        <el-form-item label="安全库存">
          <div class="w-full">
            <el-input v-model.number="productForm.minStock" type="number" placeholder="0" style="width: 100%">
              <template #append>{{ productForm.unit || '桶' }}</template>
            </el-input>
            <div class="text-xs text-gray-400 mt-1">库存低于此值时触发预警</div>
          </div>
        </el-form-item>

        <el-form-item label="产品图片">
          <div class="flex items-center gap-4">
            <div class="w-24 h-24 bg-gray-50 rounded-lg border border-gray-200 flex items-center justify-center overflow-hidden">
              <el-image v-if="productForm.imageUrl" :src="productForm.imageUrl" fit="cover" class="w-full h-full" />
              <el-icon v-else size="32" class="text-gray-300"><Picture /></el-icon>
            </div>
            <el-button>上传图片</el-button>
          </div>
        </el-form-item>

        <el-form-item label="产品描述">
          <el-input v-model="productForm.description" type="textarea" :rows="4" placeholder="简要描述产品特点..." />
        </el-form-item>

        <el-form-item>
          <el-checkbox v-model="productForm.status">立即上架此产品</el-checkbox>
        </el-form-item>

        <el-form-item>
          <div class="flex gap-4">
            <el-button @click="goBack">取消</el-button>
            <el-button type="primary" :loading="submitting" @click="handleSubmit">
              创建产品
            </el-button>
          </div>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { ArrowLeft, Picture } from '@element-plus/icons-vue'
import { productsApi } from '@/api'
import { ElMessage } from 'element-plus'

const router = useRouter()

const submitting = ref(false)

const productForm = ref({
  name: '',
  category: '',
  spec: '',
  factoryPrice: '' as number | string,
  guidePriceMin: '' as number | string,
  guidePriceMax: '' as number | string,
  unit: '桶',
  minStock: '' as number | string,
  description: '',
  status: true,
  imageUrl: ''
})

const goBack = () => {
  router.push('/products')
}

const handleSubmit = async () => {
  if (!productForm.value.name) {
    ElMessage.warning('请输入产品名称')
    return
  }

  if (!productForm.value.category) {
    ElMessage.warning('请选择产品分类')
    return
  }

  if (!productForm.value.factoryPrice) {
    ElMessage.warning('请输入出厂价')
    return
  }

  submitting.value = true

  try {
    const data = {
      name: productForm.value.name,
      category: productForm.value.category,
      spec: productForm.value.spec,
      factoryPrice: Number(productForm.value.factoryPrice),
      guidePriceMin: Number(productForm.value.guidePriceMin) || Number(productForm.value.factoryPrice),
      guidePriceMax: Number(productForm.value.guidePriceMax) || Number(productForm.value.factoryPrice),
      unit: productForm.value.unit,
      minStock: Number(productForm.value.minStock) || 0,
      description: productForm.value.description,
      status: productForm.value.status ? 'active' : 'inactive',
      image: productForm.value.imageUrl
    }

    await productsApi.create(data)
    ElMessage.success('创建产品成功')
    router.push('/products')
  } catch (error) {
    console.error('提交产品信息失败:', error)
    ElMessage.error('提交失败，请重试')
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped>
:deep(.el-card) {
  border-radius: 12px;
}
</style>
