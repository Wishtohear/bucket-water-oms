<template>
  <div class="min-h-screen flex items-center justify-center p-4 bg-gradient-to-br from-blue-50 to-blue-100">
    <div class="max-w-2xl w-full bg-white rounded-3xl overflow-hidden shadow-2xl">
      <div class="bg-[#1890FF] p-8 text-center">
        <div class="flex items-center justify-center gap-3 mb-4">
          <div class="w-12 h-12 bg-white rounded-xl flex items-center justify-center">
            <Icon icon="mdi:warehouse" class="text-[#1890FF] text-3xl" />
          </div>
          <span class="text-2xl font-bold tracking-wider text-white">选择仓库</span>
        </div>
        <p class="text-blue-100">请选择您要管理的仓库</p>
      </div>

      <div class="p-8">
        <div v-if="loading" class="flex justify-center py-8">
          <div class="animate-spin rounded-full h-12 w-12 border-4 border-blue-500 border-t-transparent"></div>
        </div>

        <div v-else-if="errorMessage" class="text-center py-8">
          <div class="text-red-500 mb-4">{{ errorMessage }}</div>
          <button
            @click="loadWarehouses"
            class="px-6 py-2 bg-[#1890FF] text-white rounded-xl hover:bg-blue-600 transition-colors"
          >
            重试
          </button>
        </div>

        <div v-else-if="warehouses.length === 0" class="text-center py-8">
          <div class="text-gray-500 mb-4">暂无可用仓库，请联系管理员</div>
        </div>

        <div v-else class="space-y-4">
          <div
            v-for="warehouse in warehouses"
            :key="warehouse.id"
            @click="selectWarehouse(warehouse.id)"
            class="p-6 border-2 rounded-2xl cursor-pointer transition-all hover:border-blue-500 hover:shadow-lg"
            :class="selectedWarehouseId === warehouse.id ? 'border-blue-500 bg-blue-50' : 'border-gray-200'"
          >
            <div class="flex items-center justify-between">
              <div class="flex items-center gap-4">
                <div class="w-12 h-12 bg-blue-100 rounded-xl flex items-center justify-center">
                  <Icon icon="mdi:warehouse" class="text-blue-500 text-2xl" />
                </div>
                <div>
                  <h3 class="text-lg font-bold text-gray-800">{{ warehouse.name }}</h3>
                  <p class="text-gray-500 text-sm mt-1">{{ warehouse.address || '暂无地址信息' }}</p>
                </div>
              </div>
              <div class="flex items-center gap-3">
                <span
                  v-if="warehouse.type === 'main'"
                  class="px-3 py-1 bg-orange-100 text-orange-600 rounded-full text-xs font-medium"
                >
                  总仓
                </span>
                <span
                  v-else
                  class="px-3 py-1 bg-green-100 text-green-600 rounded-full text-xs font-medium"
                >
                  分仓
                </span>
                <Icon
                  v-if="selectedWarehouseId === warehouse.id"
                  icon="mdi:check-circle"
                  class="text-blue-500 text-2xl"
                />
              </div>
            </div>
            <div class="mt-4 flex items-center gap-6 text-sm text-gray-500">
              <div class="flex items-center gap-1">
                <Icon icon="mdi:account" class="text-lg" />
                <span>{{ warehouse.contact || '暂无联系人' }}</span>
              </div>
              <div class="flex items-center gap-1">
                <Icon icon="mdi:phone" class="text-lg" />
                <span>{{ warehouse.contactPhone || '暂无电话' }}</span>
              </div>
            </div>
          </div>
        </div>

        <div v-if="submitting" class="mt-8 flex justify-center">
          <div class="animate-spin rounded-full h-8 w-8 border-4 border-blue-500 border-t-transparent"></div>
        </div>

        <div v-if="submitError" class="mt-4 text-center text-red-500">
          {{ submitError }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { warehousesApi } from '@/api/warehouses'
import { Icon } from '@iconify/vue'

const router = useRouter()
const authStore = useAuthStore()

const warehouses = ref<any[]>([])
const loading = ref(true)
const errorMessage = ref('')
const selectedWarehouseId = ref<string | null>(null)
const submitting = ref(false)
const submitError = ref('')

const loadWarehouses = async () => {
  loading.value = true
  errorMessage.value = ''
  try {
    const response = await warehousesApi.getAll({ status: 'active' })
    if (response.code === 200 || response.code === 0 || response.success === true) {
      warehouses.value = response.data || response || []
    } else {
      errorMessage.value = response.message || '获取仓库列表失败'
    }
  } catch (error: any) {
    console.error('获取仓库列表错误:', error)
    errorMessage.value = error.response?.data?.message || '网络错误，请稍后重试'
  } finally {
    loading.value = false
  }
}

const selectWarehouse = async (warehouseId: string) => {
  selectedWarehouseId.value = warehouseId
  submitting.value = true
  submitError.value = ''

  try {
    authStore.setWarehouseId?.(warehouseId)
    router.push('/warehouse')
  } catch (error: any) {
    console.error('选择仓库错误:', error)
    submitError.value = error.response?.data?.message || '网络错误，请稍后重试'
  } finally {
    submitting.value = false
  }
}

onMounted(() => {
  loadWarehouses()
})

</script>

<style scoped>
.bg-gradient-to-br {
  background: linear-gradient(to bottom right, #eff6ff, #dbeafe);
}
</style>
