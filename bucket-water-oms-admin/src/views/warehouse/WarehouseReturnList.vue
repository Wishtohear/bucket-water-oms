<template>
  <div>
    <div class="mb-6 flex justify-between items-center">
      <div>
        <h2 class="text-xl font-bold text-gray-800">回仓核对</h2>
        <p class="text-sm text-gray-400 mt-1">核对司机回仓空桶数量</p>
      </div>
      <div class="flex items-center gap-3">
        <span class="px-3 py-1.5 bg-red-100 text-red-500 text-sm font-bold rounded-lg">
          {{ pendingCount }} 待核对
        </span>
      </div>
    </div>

    <div class="bg-white p-4 rounded-2xl shadow-sm border border-gray-50 mb-6">
      <div class="flex gap-2">
        <button
          v-for="tab in tabs"
          :key="tab.key"
          @click="activeTab = tab.key; fetchReturnList()"
          class="px-4 py-2 rounded-xl text-sm font-medium transition-colors"
          :class="activeTab === tab.key
            ? 'bg-blue-500 text-white shadow-md shadow-blue-100'
            : 'bg-gray-50 text-gray-600 hover:bg-gray-100'"
        >
          {{ tab.label }}
          <span
            v-if="tab.badge !== null"
            class="ml-1 px-1.5 py-0.5 text-xs rounded-full"
            :class="activeTab === tab.key ? 'bg-white/20 text-white' : 'bg-red-500 text-white'"
          >
            {{ tab.badge }}
          </span>
        </button>
      </div>
    </div>

    <div class="space-y-4">
      <div
        v-for="item in returnList"
        :key="item.id"
        class="bg-white rounded-3xl p-6 shadow-sm hover:shadow-md transition-all"
        :class="getBorderClass(item.status)"
      >
        <div class="flex justify-between items-start mb-4">
          <div class="flex items-center gap-3">
            <span
              class="w-3 h-3 rounded-full animate-pulse"
              :class="getStatusDotClass(item.status)"
            ></span>
            <span class="text-sm font-bold text-gray-800">{{ item.returnNo }}</span>
          </div>
          <div class="text-xs text-gray-400 bg-gray-50 px-3 py-1 rounded-lg">
            等待 {{ item.waitMinutes || 0 }}分钟
          </div>
        </div>

        <div class="flex items-center gap-4 mb-4">
          <div class="w-12 h-12 bg-blue-50 rounded-full flex items-center justify-center">
            <Icon class="text-2xl text-blue-500" icon="mdi:account" />
          </div>
          <div class="flex-1">
            <p class="text-sm font-bold text-gray-800">{{ item.driverName }}</p>
            <p class="text-xs text-gray-400">
              工号: {{ item.driverCode }} | 今日配送 {{ item.todayDeliveries || 0 }} 单
            </p>
          </div>
          <button class="w-10 h-10 bg-green-50 text-green-500 rounded-full flex items-center justify-center">
            <Icon class="text-xl" icon="mdi:phone" />
          </button>
        </div>

        <div class="bg-gray-50 rounded-xl p-4 mb-4">
          <div class="grid grid-cols-2 gap-4">
            <div class="text-center p-3 bg-white rounded-xl">
              <p class="text-xs text-gray-400 mb-1">配送订单</p>
              <p class="text-sm font-bold text-gray-800">{{ item.orderNo }}</p>
            </div>
            <div class="text-center p-3 bg-white rounded-xl">
              <p class="text-xs text-gray-400 mb-1">送达时间</p>
              <p class="text-sm font-bold text-gray-800">{{ item.deliveryTime }}</p>
            </div>
          </div>
        </div>

        <div class="space-y-3 mb-4">
          <div class="flex justify-between items-center p-3 bg-blue-50 rounded-xl">
            <div class="flex items-center gap-2">
              <Icon class="text-blue-500" icon="mdi:package-variant" />
              <span class="text-sm text-gray-700">司机上报回收空桶</span>
            </div>
            <span class="text-base font-bold text-blue-600">{{ item.bucketReturned || 0 }} 个</span>
          </div>

          <div
            class="flex justify-between items-center p-3 rounded-xl"
            :class="item.difference > 0 ? 'bg-orange-50' : 'bg-green-50'"
          >
            <div class="flex items-center gap-2">
              <Icon
                :icon="item.difference > 0 ? 'mdi:alert-circle-outline' : 'mdi:check-circle-outline'"
                :class="item.difference > 0 ? 'text-orange-500' : 'text-green-500'"
              />
              <span class="text-sm text-gray-700">其中欠桶</span>
            </div>
            <span
              class="text-base font-bold"
              :class="item.difference > 0 ? 'text-orange-500' : 'text-green-500'"
            >
              {{ item.difference || 0 }} 个
            </span>
          </div>

          <div v-if="item.replenishRequest" class="flex justify-between items-center p-3 bg-purple-50 rounded-xl">
            <div class="flex items-center gap-2">
              <Icon class="text-purple-500" icon="mdi:truck-outline" />
              <span class="text-sm text-gray-700">申请补货</span>
            </div>
            <span class="text-base font-bold text-purple-500">{{ item.replenishRequest }}</span>
          </div>
        </div>

        <div class="flex gap-3">
          <button
            @click="handleCheck(item)"
            class="flex-1 py-3 bg-blue-500 text-white rounded-xl text-sm font-bold shadow-md shadow-blue-100 hover:bg-blue-600 transition-colors"
          >
            <Icon icon="mdi:checkbox-marked-outline" class="inline mr-2" />
            核对空桶
          </button>
          <button
            @click="handlePrint(item)"
            class="py-3 px-4 bg-gray-50 text-gray-500 rounded-xl hover:bg-gray-100 transition-colors"
          >
            <Icon icon="mdi:printer-outline" />
          </button>
        </div>
      </div>

      <div v-if="returnList.length === 0 && !loading" class="bg-white rounded-3xl p-12 text-center">
        <Icon icon="mdi:clipboard-check-outline" class="text-6xl text-gray-200 mx-auto mb-4" />
        <p class="text-gray-400">暂无回仓记录</p>
      </div>

      <div v-if="loading" class="bg-white rounded-3xl p-12 text-center">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto"></div>
        <p class="text-gray-400 mt-4">加载中...</p>
      </div>
    </div>

    <div v-if="showCheckDialog" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-2xl p-8 w-full max-w-lg mx-4">
        <h3 class="text-xl font-bold text-gray-800 mb-4">核对空桶</h3>

        <div v-if="selectedItem" class="space-y-4">
          <div class="bg-gray-50 rounded-xl p-4">
            <div class="grid grid-cols-2 gap-4 text-sm">
              <div>
                <p class="text-xs text-gray-400">回仓单号</p>
                <p class="font-bold text-gray-800">{{ selectedItem.returnNo }}</p>
              </div>
              <div>
                <p class="text-xs text-gray-400">司机</p>
                <p class="font-bold text-gray-800">{{ selectedItem.driverName }}</p>
              </div>
              <div>
                <p class="text-xs text-gray-400">配送订单</p>
                <p class="font-bold text-gray-800">{{ selectedItem.orderNo }}</p>
              </div>
              <div>
                <p class="text-xs text-gray-400">送达时间</p>
                <p class="font-bold text-gray-800">{{ selectedItem.deliveryTime }}</p>
              </div>
            </div>
          </div>

          <div class="bg-blue-50 rounded-xl p-4">
            <div class="flex justify-between items-center mb-2">
              <span class="text-sm text-gray-700">司机上报回收空桶</span>
              <span class="text-base font-bold text-blue-600">{{ selectedItem.bucketReturned }} 个</span>
            </div>
            <div class="flex justify-between items-center">
              <span class="text-sm text-gray-700">其中欠桶</span>
              <span
                class="text-base font-bold"
                :class="selectedItem.difference > 0 ? 'text-orange-500' : 'text-green-500'"
              >
                {{ selectedItem.difference }} 个
              </span>
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">实际回收数量</label>
            <input
              v-model.number="actualQuantity"
              type="number"
              class="w-full px-4 py-3 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-300"
              placeholder="请输入实际回收数量"
            />
          </div>

          <div v-if="actualQuantity !== selectedItem.bucketReturned">
            <label class="block text-sm font-medium text-gray-700 mb-2">差异说明</label>
            <textarea
              v-model="differenceReason"
              class="w-full px-4 py-3 border border-gray-200 rounded-xl text-sm resize-none focus:outline-none focus:ring-2 focus:ring-blue-300"
              rows="3"
              placeholder="请说明差异原因..."
            ></textarea>
          </div>
        </div>

        <div class="flex gap-3 mt-6">
          <button
            @click="showCheckDialog = false"
            class="flex-1 px-4 py-3 bg-gray-100 text-gray-600 rounded-xl font-medium hover:bg-gray-200"
          >
            取消
          </button>
          <button
            @click="confirmCheck"
            class="flex-1 px-4 py-3 bg-blue-500 text-white rounded-xl font-bold hover:bg-blue-600"
          >
            确认核对
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { Icon } from '@iconify/vue'
import { warehouseApi } from '@/api'
import { toast } from '@/composables/useToast'

interface ReturnItem {
  id: string
  returnNo: string
  orderNo: string
  status: string
  statusText: string
  driverName: string
  driverCode: string
  todayDeliveries: number
  deliveryTime: string
  bucketReturned: number
  actualBucketQty: number
  difference: number
  differenceReason: string
  replenishRequest: string
  waitMinutes: number
  createTime: string
}

const loading = ref(false)
const activeTab = ref('pending')
const showCheckDialog = ref(false)
const selectedItem = ref<ReturnItem | null>(null)
const actualQuantity = ref(0)
const differenceReason = ref('')

const tabs = [
  { key: 'pending', label: '待核对', badge: 0 },
  { key: 'completed', label: '已核对', badge: null },
  { key: 'difference', label: '差异记录', badge: null }
]

const returnList = ref<ReturnItem[]>([])
const pendingCount = ref(0)

const getBorderClass = (status: string) => {
  const classMap: Record<string, string> = {
    pending: 'border-red-50',
    completed: 'border-gray-50',
    difference: 'border-orange-50'
  }
  return classMap[status] || 'border-gray-50'
}

const getStatusDotClass = (status: string) => {
  const classMap: Record<string, string> = {
    pending: 'bg-red-500',
    completed: 'bg-green-500',
    difference: 'bg-orange-500'
  }
  return classMap[status] || 'bg-gray-500'
}

const fetchReturnList = async () => {
  loading.value = true
  try {
    const res: any = await warehouseApi.getPendingReturns()
    const returnData = res.data || res || []
    const returnArray = Array.isArray(returnData) ? returnData : []
    returnList.value = returnArray.map((item: any) => ({
      ...item,
      waitMinutes: Math.floor(Math.random() * 30) + 5,
      replenishRequest: item.difference > 0 ? '18.9L×20 桶' : null
    }))

    pendingCount.value = returnList.value.filter(item => item.status === 'pending').length
    tabs[0].badge = pendingCount.value

    if (activeTab.value === 'pending') {
      returnList.value = returnList.value.filter(item => item.status === 'pending')
    } else if (activeTab.value === 'completed') {
      returnList.value = returnList.value.filter(item => item.status === 'completed')
    } else if (activeTab.value === 'difference') {
      returnList.value = returnList.value.filter(item => item.difference > 0)
    }
  } catch (error: any) {
    console.error('获取回仓列表失败:', error)
    toast.error('获取回仓列表失败')
  } finally {
    loading.value = false
  }
}

const handleCheck = (item: ReturnItem) => {
  selectedItem.value = item
  actualQuantity.value = item.bucketReturned
  differenceReason.value = ''
  showCheckDialog.value = true
}

const confirmCheck = async () => {
  if (!selectedItem.value) return

  try {
    await warehouseApi.checkReturn(selectedItem.value.id, {
      actualBucketQty: actualQuantity.value,
      differenceReason: differenceReason.value
    })

    toast.success('核对成功')
    showCheckDialog.value = false
    fetchReturnList()
  } catch (error: any) {
    toast.error('核对失败: ' + (error.message || ''))
  }
}

const handlePrint = (_item: ReturnItem) => {
  // TODO: 实现打印功能
  toast.info('正在生成打印文件...')
}

onMounted(() => {
  fetchReturnList()
})
</script>

<style scoped>
</style>
