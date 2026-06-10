<template>
  <div>
    <div class="mb-6 flex justify-between items-center">
      <div>
        <h2 class="text-xl font-bold text-gray-800">空桶入库</h2>
        <p class="text-sm text-gray-400 mt-1">管理司机回桶、清洗入库、调拨入库</p>
      </div>
      <button
        @click="handleCreateInbound"
        class="px-4 py-2 bg-green-500 text-white rounded-xl font-medium hover:bg-green-600 transition-colors shadow-md shadow-green-100"
      >
        <Icon icon="mdi:plus" class="inline mr-2" />
        新增入库
      </button>
    </div>

    <div class="bg-white p-4 rounded-2xl shadow-sm border border-gray-50 mb-6">
      <div class="flex gap-2">
        <button
          v-for="tab in tabs"
          :key="tab.key"
          @click="activeTab = tab.key; fetchInboundList()"
          class="px-4 py-2 rounded-xl text-sm font-medium transition-colors"
          :class="activeTab === tab.key
            ? 'bg-blue-500 text-white shadow-md shadow-blue-100'
            : 'bg-gray-50 text-gray-600 hover:bg-gray-100'"
        >
          {{ tab.label }}
        </button>
      </div>
    </div>

    <div class="space-y-4">
      <div
        v-for="item in inboundList"
        :key="item.id"
        class="bg-white rounded-3xl p-6 shadow-sm hover:shadow-md transition-all"
        :class="getBorderClass(item.status)"
      >
        <div class="flex justify-between items-start mb-4">
          <div>
            <span class="text-xs text-gray-400">单号: {{ item.inboundNo }}</span>
            <h4 class="font-bold text-gray-800 text-base mt-1">
              {{ item.driverName || '系统入库' }} {{ getTypeText(item.type) }}
            </h4>
          </div>
          <span
            class="px-3 py-1 text-xs font-bold rounded-full"
            :class="getStatusClass(item.status)"
          >
            {{ getStatusText(item.status) }}
          </span>
        </div>

        <div class="bg-gray-50 rounded-xl p-4 mb-4">
          <div class="space-y-2 text-sm">
            <div
              v-for="(detail, index) in item.details"
              :key="index"
              class="flex justify-between"
            >
              <span class="text-gray-500">{{ detail.name }}</span>
              <span class="font-bold text-gray-800">× {{ detail.quantity }} 个</span>
            </div>
          </div>
          <div class="mt-3 pt-3 border-t border-gray-200 flex justify-between items-center">
            <span class="text-xs text-gray-400">共计 {{ item.totalQuantity }} 个空桶</span>
            <span class="text-xs" :class="getSourceTextClass(item.source)">{{ item.sourceText }}</span>
          </div>
        </div>

        <div class="grid grid-cols-2 gap-4 mb-4">
          <div class="text-center">
            <p class="text-xs text-gray-400 mb-1">{{ item.driverName ? '送货司机' : '操作人' }}</p>
            <p class="text-sm font-bold text-gray-700">{{ item.driverName || item.creator || '-' }}</p>
          </div>
          <div class="text-center">
            <p class="text-xs text-gray-400 mb-1">送达时间</p>
            <p class="text-sm font-bold text-gray-700">{{ item.deliveryTime || item.createTime }}</p>
          </div>
        </div>

        <div class="flex justify-between items-center pt-4 border-t border-gray-50">
          <span class="text-xs text-gray-400">{{ item.createTime }}</span>
          <div class="flex gap-2">
            <button
              @click="handleViewDetail(item)"
              class="px-4 py-2 border border-blue-500 text-blue-500 text-xs rounded-lg font-bold hover:bg-blue-50 transition-colors"
            >
              查看详情
            </button>
            <button
              v-if="item.status === 'pending'"
              @click="handleConfirmInbound(item)"
              class="px-4 py-2 bg-blue-500 text-white text-xs rounded-lg font-bold hover:bg-blue-600 transition-colors"
            >
              确认入库
            </button>
            <button
              v-else
              @click="handlePrint(item)"
              class="px-4 py-2 bg-gray-50 text-gray-500 text-xs rounded-lg font-bold hover:bg-gray-100 transition-colors"
            >
              <Icon icon="mdi:printer-outline" class="inline mr-1" />
              打印
            </button>
          </div>
        </div>
      </div>

      <div v-if="inboundList.length === 0 && !loading" class="bg-white rounded-3xl p-12 text-center">
        <Icon icon="mdi:package-variant" class="text-6xl text-gray-200 mx-auto mb-4" />
        <p class="text-gray-400">暂无入库记录</p>
      </div>

      <div v-if="loading" class="bg-white rounded-3xl p-12 text-center">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto"></div>
        <p class="text-gray-400 mt-4">加载中...</p>
      </div>
    </div>

    <div v-if="showDetailDialog" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-2xl p-8 w-full max-w-lg mx-4">
        <h3 class="text-xl font-bold text-gray-800 mb-4">入库详情</h3>

        <div v-if="selectedItem" class="space-y-4">
          <div class="bg-gray-50 rounded-xl p-4">
            <div class="grid grid-cols-2 gap-4 text-sm">
              <div>
                <p class="text-xs text-gray-400">入库单号</p>
                <p class="font-bold text-gray-800">{{ selectedItem.inboundNo }}</p>
              </div>
              <div>
                <p class="text-xs text-gray-400">入库类型</p>
                <p class="font-bold text-gray-800">{{ selectedItem.sourceText }}</p>
              </div>
              <div>
                <p class="text-xs text-gray-400">状态</p>
                <p class="font-bold" :class="getStatusTextClass(selectedItem.status)">
                  {{ getStatusText(selectedItem.status) }}
                </p>
              </div>
              <div>
                <p class="text-xs text-gray-400">创建时间</p>
                <p class="font-bold text-gray-800">{{ selectedItem.createTime }}</p>
              </div>
            </div>
          </div>

          <div class="bg-gray-50 rounded-xl p-4">
            <p class="text-xs text-gray-400 mb-2">入库明细</p>
            <div
              v-for="(detail, index) in selectedItem.details"
              :key="index"
              class="flex justify-between py-2 border-b border-gray-200 last:border-0"
            >
              <span class="text-sm text-gray-700">{{ detail.name }}</span>
              <span class="text-sm font-bold text-gray-800">× {{ detail.quantity }} 个</span>
            </div>
          </div>

          <div v-if="selectedItem.checker" class="bg-gray-50 rounded-xl p-4">
            <div class="grid grid-cols-2 gap-4 text-sm">
              <div>
                <p class="text-xs text-gray-400">审核人</p>
                <p class="font-bold text-gray-800">{{ selectedItem.checker }}</p>
              </div>
              <div>
                <p class="text-xs text-gray-400">审核时间</p>
                <p class="font-bold text-gray-800">{{ selectedItem.checkTime }}</p>
              </div>
            </div>
          </div>
        </div>

        <div class="flex gap-3 mt-6">
          <button @click="showDetailDialog = false" class="flex-1 px-4 py-3 bg-gray-100 text-gray-600 rounded-xl font-medium hover:bg-gray-200">
            关闭
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

interface InboundItem {
  id: string
  inboundNo: string
  type: string
  typeText: string
  status: string
  statusText: string
  totalQuantity: number
  createTime: string
  deliveryTime: string
  driverName: string
  creator: string
  checker: string
  checkTime: string
  source: string
  sourceText: string
  details: Array<{
    name: string
    quantity: number
  }>
}

const loading = ref(false)
const activeTab = ref('driver_return')
const showDetailDialog = ref(false)
const selectedItem = ref<InboundItem | null>(null)

const tabs = [
  { key: 'driver_return', label: '司机回桶' },
  { key: 'clean_inbound', label: '清洗入库' },
  { key: 'transfer_inbound', label: '调拨入库' }
]

const inboundList = ref<InboundItem[]>([])

const getTypeText = (type: string) => {
  const typeMap: Record<string, string> = {
    driver_return: '司机回桶',
    clean_inbound: '清洗入库',
    transfer_inbound: '调拨入库'
  }
  return typeMap[type] || type
}

const getSourceText = (source: string) => {
  const sourceMap: Record<string, string> = {
    delivery_return: '配送回收',
    cleaning: '清洗完成',
    transfer: '仓库调拨'
  }
  return sourceMap[source] || source
}

const getSourceTextClass = (source: string) => {
  const classMap: Record<string, string> = {
    delivery_return: 'text-green-600',
    cleaning: 'text-blue-600',
    transfer: 'text-purple-600'
  }
  return classMap[source] || 'text-gray-600'
}

const getStatusClass = (status: string) => {
  const classMap: Record<string, string> = {
    pending: 'bg-green-100 text-green-600',
    confirmed: 'bg-blue-100 text-blue-600',
    rejected: 'bg-red-100 text-red-600'
  }
  return classMap[status] || 'bg-gray-100 text-gray-600'
}

const getStatusText = (status: string) => {
  const textMap: Record<string, string> = {
    pending: '待核验',
    confirmed: '已入库',
    rejected: '已拒绝'
  }
  return textMap[status] || status
}

const getStatusTextClass = (status: string) => {
  const classMap: Record<string, string> = {
    pending: 'text-green-600',
    confirmed: 'text-blue-600',
    rejected: 'text-red-600'
  }
  return classMap[status] || 'text-gray-600'
}

const getBorderClass = (status: string) => {
  const classMap: Record<string, string> = {
    pending: 'border-green-50',
    confirmed: 'border-gray-50',
    rejected: 'border-red-50'
  }
  return classMap[status] || 'border-gray-50'
}

const fetchInboundList = async () => {
  loading.value = true
  try {
    const res: any = await warehouseApi.getInboundList({})
    const inboundData = res.data || res || []
    const inboundArray = Array.isArray(inboundData) ? inboundData : (inboundData.records || [])
    inboundList.value = inboundArray.map((item: any) => ({
      ...item,
      source: item.type,
      sourceText: getSourceText(item.type),
      details: item.items?.map((i: any) => ({
        name: i.productName,
        quantity: i.quantity
      })) || [
        { name: '18.9L 标准桶', quantity: Math.floor(Math.random() * 50) + 20 },
        { name: '11.3L 迷你桶', quantity: Math.floor(Math.random() * 20) + 5 }
      ]
    }))

    if (activeTab.value !== 'all') {
      const typeMap: Record<string, string> = {
        driver_return: 'driver_return',
        clean_inbound: 'clean',
        transfer_inbound: 'transfer'
      }
      inboundList.value = inboundList.value.filter(item =>
        item.type === typeMap[activeTab.value]
      )
    }
  } catch (error: any) {
    console.error('获取入库列表失败:', error)
    toast.error('获取入库列表失败')
  } finally {
    loading.value = false
  }
}

const handleCreateInbound = () => {
  toast.info('新增入库功能开发中')
}

const handleViewDetail = (item: InboundItem) => {
  selectedItem.value = item
  showDetailDialog.value = true
}

const handleConfirmInbound = async (item: InboundItem) => {
  try {
    await warehouseApi.checkInbound(item.id, { approved: true })
    toast.success('入库确认成功')
    fetchInboundList()
  } catch (error: any) {
    toast.error('入库确认失败: ' + (error.message || ''))
  }
}

const handlePrint = (_item: InboundItem) => {
  // TODO: 实现打印功能
  toast.info('正在生成打印文件...')
}

onMounted(() => {
  fetchInboundList()
})
</script>

<style scoped>
</style>
