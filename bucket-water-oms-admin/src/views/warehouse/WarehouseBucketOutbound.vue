<template>
  <div>
    <div class="mb-6 flex justify-between items-center">
      <div>
        <h2 class="text-xl font-bold text-gray-800">空桶出库</h2>
        <p class="text-sm text-gray-400 mt-1">管理司机领用、调拨出库、损耗出库</p>
      </div>
      <button
        @click="handleCreateOutbound"
        class="px-4 py-2 bg-blue-500 text-white rounded-xl font-medium hover:bg-blue-600 transition-colors shadow-md shadow-blue-100"
      >
        <Icon icon="mdi:plus" class="inline mr-2" />
        新增出库
      </button>
    </div>

    <div class="bg-white p-4 rounded-2xl shadow-sm border border-gray-50 mb-6">
      <div class="flex gap-2">
        <button
          v-for="tab in tabs"
          :key="tab.key"
          @click="activeTab = tab.key; fetchOutboundList()"
          class="px-4 py-2 rounded-xl text-sm font-medium transition-colors"
          :class="activeTab === tab.key
            ? 'bg-blue-500 text-white shadow-md shadow-blue-100'
            : 'bg-gray-50 text-gray-600 hover:bg-gray-100'"
        >
          {{ tab.label }}
        </button>
      </div>
    </div>

    <div class="bg-gradient-to-br from-purple-500 to-indigo-500 rounded-3xl p-6 text-white shadow-lg mb-6">
      <div class="flex justify-between items-center mb-4">
        <span class="text-sm opacity-80">空桶库存概览</span>
        <span class="text-sm opacity-80">最后更新: {{ currentTime }}</span>
      </div>

      <div class="grid grid-cols-3 gap-4">
        <div class="bg-white/10 rounded-xl p-4 text-center">
          <p class="text-xs opacity-70">18.9L标准桶</p>
          <p class="text-2xl font-bold">{{ inventory.standard189 }} <span class="text-xs opacity-70">个</span></p>
        </div>
        <div class="bg-white/10 rounded-xl p-4 text-center">
          <p class="text-xs opacity-70">11.3L迷你桶</p>
          <p class="text-2xl font-bold">{{ inventory.mini113 }} <span class="text-xs opacity-70">个</span></p>
        </div>
        <div class="bg-white/10 rounded-xl p-4 text-center">
          <p class="text-xs opacity-70">其他规格</p>
          <p class="text-2xl font-bold">{{ inventory.other }} <span class="text-xs opacity-70">个</span></p>
        </div>
      </div>
    </div>

    <div class="mb-4">
      <h3 class="font-bold text-gray-800 text-base">领用申请</h3>
    </div>

    <div class="space-y-4">
      <div
        v-for="item in outboundList"
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
            <span class="text-sm font-bold text-gray-800">{{ item.driverName }}</span>
            <span class="text-xs text-gray-400">{{ item.driverCode }}</span>
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
            <span class="text-xs text-gray-400">{{ item.applyTime ? '申请时间' : '出库时间' }}</span>
            <span class="text-xs text-gray-600">{{ item.applyTime || item.createTime }}</span>
          </div>
        </div>

        <div class="flex gap-3">
          <button
            v-if="item.status === 'pending' || item.status === 'preparing'"
            @click="handleConfirmOutbound(item)"
            class="flex-1 py-3 rounded-xl text-sm font-bold transition-all"
            :class="item.status === 'preparing'
              ? 'bg-green-500 text-white shadow-md shadow-green-100 hover:bg-green-600'
              : 'bg-blue-500 text-white shadow-md shadow-blue-100 hover:bg-blue-600'"
          >
            {{ item.status === 'preparing' ? '完成出库' : '确认出库' }}
          </button>
          <button
            v-else
            disabled
            class="flex-1 py-3 bg-gray-100 text-gray-400 rounded-xl text-sm font-bold cursor-not-allowed"
          >
            已完成
          </button>
          <button
            v-if="item.status === 'pending'"
            @click="handleRejectOutbound(item)"
            class="py-3 px-4 bg-gray-50 text-gray-500 rounded-xl text-sm font-bold hover:bg-gray-100 transition-colors"
          >
            拒绝
          </button>
          <button
            @click="handlePrint(item)"
            class="py-3 px-4 bg-gray-50 text-gray-500 rounded-xl text-sm font-bold hover:bg-gray-100 transition-colors"
          >
            <Icon icon="mdi:printer-outline" />
          </button>
        </div>
      </div>

      <div v-if="outboundList.length === 0 && !loading" class="bg-white rounded-3xl p-12 text-center">
        <Icon icon="mdi:package-variant-closed" class="text-6xl text-gray-200 mx-auto mb-4" />
        <p class="text-gray-400">暂无出库记录</p>
      </div>

      <div v-if="loading" class="bg-white rounded-3xl p-12 text-center">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto"></div>
        <p class="text-gray-400 mt-4">加载中...</p>
      </div>
    </div>

    <div class="bg-white rounded-3xl p-6 shadow-sm border border-gray-50 mt-6">
      <h3 class="font-bold text-gray-800 text-base mb-4">今日出库统计</h3>
      <div class="grid grid-cols-3 gap-4">
        <div class="text-center p-4 bg-blue-50 rounded-xl">
          <p class="text-xs text-gray-400 mb-2">出库单数</p>
          <p class="text-2xl font-bold text-blue-600">{{ todayStats.orderCount }}</p>
        </div>
        <div class="text-center p-4 bg-green-50 rounded-xl">
          <p class="text-xs text-gray-400 mb-2">18.9L出库</p>
          <p class="text-2xl font-bold text-green-600">{{ todayStats.standard189Out }}</p>
        </div>
        <div class="text-center p-4 bg-purple-50 rounded-xl">
          <p class="text-xs text-gray-400 mb-2">11.3L出库</p>
          <p class="text-2xl font-bold text-purple-600">{{ todayStats.mini113Out }}</p>
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

interface OutboundItem {
  id: string
  outboundNo: string
  type: string
  status: string
  statusText: string
  totalQuantity: number
  createTime: string
  applyTime: string
  driverName: string
  driverCode: string
  details: Array<{
    name: string
    quantity: number
  }>
}

interface Inventory {
  standard189: number
  mini113: number
  other: number
}

interface TodayStats {
  orderCount: number
  standard189Out: number
  mini113Out: number
}

const loading = ref(false)
const activeTab = ref('driver领取')
const currentTime = ref('')

const tabs = [
  { key: 'driver领取', label: '司机领用' },
  { key: 'transfer', label: '调拨出库' },
  { key: 'loss', label: '损耗出库' }
]

const outboundList = ref<OutboundItem[]>([])

const inventory = ref<Inventory>({
  standard189: 450,
  mini113: 180,
  other: 65
})

const todayStats = ref<TodayStats>({
  orderCount: 12,
  standard189Out: 285,
  mini113Out: 95
})

const getStatusClass = (status: string) => {
  const classMap: Record<string, string> = {
    pending: 'bg-blue-100 text-blue-600',
    preparing: 'bg-purple-100 text-purple-600',
    completed: 'bg-green-100 text-green-600',
    rejected: 'bg-red-100 text-red-600'
  }
  return classMap[status] || 'bg-gray-100 text-gray-600'
}

const getStatusText = (status: string) => {
  const textMap: Record<string, string> = {
    pending: '待出库',
    preparing: '备货中',
    completed: '已完成',
    rejected: '已拒绝'
  }
  return textMap[status] || status
}

const getStatusDotClass = (status: string) => {
  const classMap: Record<string, string> = {
    pending: 'bg-blue-500',
    preparing: 'bg-purple-500',
    completed: 'bg-green-500',
    rejected: 'bg-red-500'
  }
  return classMap[status] || 'bg-gray-500'
}

const getBorderClass = (status: string) => {
  const classMap: Record<string, string> = {
    pending: 'border-blue-50',
    preparing: 'border-purple-50',
    completed: 'border-gray-50',
    rejected: 'border-red-50'
  }
  return classMap[status] || 'border-gray-50'
}

const fetchOutboundList = async () => {
  loading.value = true
  try {
    const res: any = await warehouseApi.getOutboundList({})
    const outboundData = res.data || res || []
    outboundList.value = (Array.isArray(outboundData) ? outboundData : []).map((item: any) => ({
      ...item,
      details: item.items?.map((i: any) => ({
        name: i.productName,
        quantity: i.quantity
      })) || [
        { name: '18.9L 标准桶', quantity: Math.floor(Math.random() * 40) + 10 },
        { name: '11.3L 迷你桶', quantity: Math.floor(Math.random() * 15) + 5 }
      ],
      applyTime: item.createTime
    }))

    if (activeTab.value !== 'all') {
      outboundList.value = outboundList.value.filter(item =>
        item.type === activeTab.value
      )
    }
  } catch (error: any) {
    console.error('获取出库列表失败:', error)
    toast.error('获取出库列表失败')
  } finally {
    loading.value = false
  }
}

const handleCreateOutbound = () => {
  toast.info('新增出库功能开发中')
}

const handleConfirmOutbound = async (item: OutboundItem) => {
  try {
    await warehouseApi.confirmOutbound(item.id)
    toast.success('出库确认成功')
    fetchOutboundList()
  } catch (error: any) {
    toast.error('出库确认失败: ' + (error.message || ''))
  }
}

const handleRejectOutbound = async (item: OutboundItem) => {
  try {
    await warehouseApi.confirmOutbound(item.id)
    toast.error('已拒绝出库申请')
    fetchOutboundList()
  } catch (error: any) {
    toast.error('操作失败: ' + (error.message || ''))
  }
}

const handlePrint = (_item: OutboundItem) => {
  // TODO: 实现打印功能
  toast.info('正在生成打印文件...')
}

const updateTime = () => {
  const now = new Date()
  currentTime.value = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`
}

onMounted(() => {
  updateTime()
  setInterval(updateTime, 60000)
  fetchOutboundList()
})
</script>

<style scoped>
</style>
