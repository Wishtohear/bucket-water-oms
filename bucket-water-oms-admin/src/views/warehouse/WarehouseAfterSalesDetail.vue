<template>
  <div>
    <div class="mb-6">
      <router-link
        to="/warehouse/after-sales"
        class="inline-flex items-center text-gray-500 hover:text-gray-700 mb-4"
      >
        <Icon icon="mdi:chevron-left" class="text-xl mr-1" />
        返回售后列表
      </router-link>
      <h2 class="text-xl font-bold text-gray-800">售后详情</h2>
      <p class="text-sm text-gray-400 mt-1">查看并处理售后申请</p>
    </div>

    <div v-if="loading" class="flex items-center justify-center py-20">
      <div class="text-center">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto"></div>
        <p class="text-gray-400 mt-4">加载中...</p>
      </div>
    </div>

    <div v-else-if="detail" class="space-y-4">
      <div class="bg-white rounded-3xl p-6 shadow-sm">
        <div class="flex justify-between items-start mb-4">
          <div>
            <p class="text-xs text-gray-400 mb-1">售后单号</p>
            <p class="text-base font-bold text-gray-800">{{ detail.ticketNo }}</p>
          </div>
          <span
            class="px-3 py-1 rounded-full text-xs font-medium"
            :class="getStatusClass(detail.status)"
          >
            {{ getStatusText(detail.status) }}
          </span>
        </div>

        <div class="bg-gray-50 rounded-xl p-4 space-y-3">
          <div class="flex justify-between text-sm">
            <span class="text-gray-500">申请时间</span>
            <span class="font-medium text-gray-800">{{ detail.createdAt || '-' }}</span>
          </div>
          <div class="flex justify-between text-sm">
            <span class="text-gray-500">售后类型</span>
            <span class="font-medium text-gray-800">{{ detail.typeText || getTypeText(detail.type) }}</span>
          </div>
          <div class="flex justify-between text-sm">
            <span class="text-gray-500">关联订单</span>
            <span class="font-medium text-blue-500">{{ detail.orderNo }}</span>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-3xl p-6 shadow-sm">
        <h3 class="font-bold text-gray-800 mb-4">关联订单信息</h3>
        <div class="space-y-3">
          <div class="flex justify-between text-sm">
            <span class="text-gray-500">水站名称</span>
            <span class="font-medium text-gray-800">{{ detail.stationName }}</span>
          </div>
          <div class="flex justify-between text-sm">
            <span class="text-gray-500">仓库名称</span>
            <span class="font-medium text-gray-800">{{ detail.warehouseName }}</span>
          </div>
          <div class="flex justify-between text-sm">
            <span class="text-gray-500">配送地址</span>
            <span class="font-medium text-gray-800 text-right max-w-[200px]">{{ detail.stationAddress }}</span>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-3xl p-6 shadow-sm">
        <h3 class="font-bold text-gray-800 mb-4">问题明细</h3>
        <div class="space-y-3">
          <div class="flex items-start gap-2 p-3 bg-orange-50 rounded-xl mb-3">
            <Icon class="text-orange-500 flex-shrink-0 mt-0.5" icon="mdi:alert-circle-outline" />
            <span class="text-sm text-orange-700">{{ detail.reason }}</span>
          </div>
          <div
            v-for="(item, index) in detail.items"
            :key="index"
            class="flex items-center justify-between py-2 border-b border-gray-100 last:border-0"
          >
            <div>
              <p class="font-medium text-gray-800">{{ item.productName }}</p>
              <p class="text-xs text-gray-400">申请数量: {{ item.quantity }}</p>
            </div>
            <span class="text-orange-500 font-medium">-{{ item.quantity - (item.actualQuantity || 0) }}桶</span>
          </div>
        </div>
      </div>

      <div v-if="detail.images && detail.images.length > 0" class="bg-white rounded-3xl p-6 shadow-sm">
        <h3 class="font-bold text-gray-800 mb-4">附件照片</h3>
        <div class="grid grid-cols-3 gap-2">
          <div
            v-for="(photo, index) in detail.images"
            :key="index"
            class="aspect-square bg-gray-100 rounded-xl overflow-hidden"
          >
            <img :src="photo" alt="附件" class="w-full h-full object-cover" />
          </div>
        </div>
      </div>

      <div v-if="detail.handleResult" class="bg-white rounded-3xl p-6 shadow-sm">
        <h3 class="font-bold text-gray-800 mb-4">处理结果</h3>
        <div class="p-4 bg-green-50 rounded-xl">
          <p class="text-sm text-green-700">{{ detail.handleResult }}</p>
          <p v-if="detail.handledAt" class="text-xs text-green-500 mt-2">处理时间: {{ detail.handledAt }}</p>
        </div>
      </div>

      <div v-if="detail.status === 'pending'" class="bg-white rounded-3xl p-6 shadow-sm">
        <h3 class="font-bold text-gray-800 mb-4">处理方式</h3>
        <div class="space-y-3">
          <label class="flex items-center gap-3 p-3 rounded-xl border cursor-pointer transition-all hover:bg-gray-50"
            :class="selectedAction === 'resend' ? 'border-blue-500 bg-blue-50' : 'border-gray-200'"
          >
            <input type="radio" value="resend" v-model="selectedAction" class="w-5 h-5 text-blue-500" />
            <div>
              <p class="font-medium text-gray-800">补发商品</p>
              <p class="text-xs text-gray-400">从库存中补发缺失的商品</p>
            </div>
          </label>
          <label class="flex items-center gap-3 p-3 rounded-xl border cursor-pointer transition-all hover:bg-gray-50"
            :class="selectedAction === 'refund' ? 'border-blue-500 bg-blue-50' : 'border-gray-200'"
          >
            <input type="radio" value="refund" v-model="selectedAction" class="w-5 h-5 text-blue-500" />
            <div>
              <p class="font-medium text-gray-800">退款处理</p>
              <p class="text-xs text-gray-400">对缺失商品进行退款</p>
            </div>
          </label>
        </div>

        <div class="mt-4">
          <label class="block text-sm text-gray-600 mb-2">处理备注</label>
          <textarea
            v-model="remark"
            rows="3"
            class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-blue-500 focus:ring-2 focus:ring-blue-100 outline-none resize-none"
            placeholder="请输入处理备注..."
          ></textarea>
        </div>
      </div>

      <div v-if="detail.status === 'pending'" class="flex gap-3 mt-6">
        <button
          @click="handleReject"
          class="flex-1 py-4 bg-white border-2 border-red-500 text-red-500 rounded-2xl font-bold hover:bg-red-50"
        >
          拒绝申请
        </button>
        <button
          @click="handleApprove"
          class="flex-1 py-4 bg-blue-500 text-white rounded-2xl font-bold hover:bg-blue-600"
        >
          确认处理
        </button>
      </div>

      <div v-if="detail.status === 'processing'" class="bg-blue-50 rounded-2xl p-4">
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
            <Icon icon="mdi:clock-outline" class="text-blue-500 text-xl" />
          </div>
          <div>
            <p class="font-medium text-blue-800">处理中</p>
            <p class="text-xs text-blue-500">正在补发商品，请等待...</p>
          </div>
        </div>
      </div>

      <div v-if="detail.status === 'completed'" class="bg-green-50 rounded-2xl p-4">
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 bg-green-100 rounded-full flex items-center justify-center">
            <Icon icon="mdi:check-circle" class="text-green-500 text-xl" />
          </div>
          <div>
            <p class="font-medium text-green-800">已完成</p>
            <p class="text-xs text-green-500">{{ detail.handledAt || '-' }}</p>
          </div>
        </div>
      </div>
    </div>

    <div v-else class="text-center py-20">
      <Icon icon="mdi:alert-circle-outline" class="text-6xl text-gray-200 mx-auto mb-4" />
      <p class="text-gray-400">未找到相关售后记录</p>
    </div>

    <div v-if="showConfirmDialog" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-2xl p-8 w-full max-w-md mx-4">
        <h3 class="text-xl font-bold text-gray-800 mb-4">确认处理</h3>
        <p class="text-sm text-gray-600 mb-6">
          确认对此售后单进行"{{ selectedAction === 'resend' ? '补发商品' : '退款处理' }}"处理吗？
        </p>
        <div class="flex gap-3">
          <button @click="showConfirmDialog = false" class="flex-1 px-4 py-3 bg-gray-100 text-gray-600 rounded-xl font-medium hover:bg-gray-200">
            取消
          </button>
          <button @click="confirmAction" class="flex-1 px-4 py-3 bg-blue-500 text-white rounded-xl font-bold hover:bg-blue-600">
            确认
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Icon } from '@iconify/vue'
import { warehouseApi } from '@/api'
import { toast } from '@/composables/useToast'

interface AfterSalesDetail {
  id: string
  ticketNo: string
  orderNo: string
  type: string
  typeText: string
  status: string
  statusText: string
  reason: string
  images: string[]
  items: Array<{
    productId: string
    productName: string
    quantity: number
    actualQuantity: number
  }>
  handledAt?: string
  handleResult?: string
  createdAt: string
  stationName: string
  stationAddress: string
  warehouseName: string
}

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const detail = ref<AfterSalesDetail | null>(null)
const selectedAction = ref('resend')
const remark = ref('')
const showConfirmDialog = ref(false)

const getStatusClass = (status: string) => {
  const classMap: Record<string, string> = {
    pending: 'bg-yellow-100 text-yellow-700',
    processing: 'bg-blue-100 text-blue-700',
    completed: 'bg-green-100 text-green-700',
    rejected: 'bg-red-100 text-red-700'
  }
  return classMap[status] || 'bg-gray-100 text-gray-700'
}

const getStatusText = (status: string) => {
  const textMap: Record<string, string> = {
    pending: '待处理',
    processing: '处理中',
    completed: '已完成',
    rejected: '已拒绝'
  }
  return textMap[status] || status
}

const getTypeText = (type: string) => {
  const typeMap: Record<string, string> = {
    missing: '商品缺失',
    damaged: '商品损坏',
    quality: '质量问题',
    other: '其他'
  }
  return typeMap[type] || type
}

const fetchDetail = async () => {
  loading.value = true
  try {
    const ticketId = route.params.id as string
    const res: any = await warehouseApi.getAfterSalesDetail(ticketId)
    const detailData = res.data || res
    detail.value = {
      id: detailData.id || ticketId,
      ticketNo: detailData.ticketNo || `#AS${ticketId}`,
      orderNo: detailData.orderNo || '-',
      type: detailData.type || 'missing',
      typeText: detailData.typeText || '',
      status: detailData.status || 'pending',
      statusText: detailData.statusText || '',
      reason: detailData.reason || '',
      images: (detailData.images as string[]) || [],
      items: detailData.items || [],
      handledAt: detailData.handledAt,
      handleResult: detailData.handleResult,
      createdAt: detailData.createdAt || new Date().toLocaleString(),
      stationName: detailData.stationName || '-',
      stationAddress: detailData.stationAddress || '-',
      warehouseName: detailData.warehouseName || '-'
    }
  } catch (error: any) {
    console.error('获取售后详情失败:', error)
    toast.error('获取售后详情失败')
  } finally {
    loading.value = false
  }
}

const handleApprove = () => {
  if (!remark.value.trim()) {
    toast.warning('请输入处理备注')
    return
  }
  showConfirmDialog.value = true
}

const handleReject = () => {
  router.push('/warehouse/after-sales')
}

const confirmAction = async () => {
  try {
    const ticketId = route.params.id as string
    await warehouseApi.processAfterSales(ticketId, {
      action: selectedAction.value,
      remark: remark.value
    })
    toast.success('处理成功')
    showConfirmDialog.value = false
    router.push('/warehouse/after-sales')
  } catch (error: any) {
    toast.error('处理失败: ' + (error.message || ''))
  }
}

onMounted(() => {
  fetchDetail()
})
</script>

<style scoped>
</style>
