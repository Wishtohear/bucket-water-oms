<template>
  <div>
    <div class="flex items-center gap-4 mb-6">
      <button @click="goBack" class="text-gray-500 hover:text-blue-500">
        <Icon icon="mdi:chevron-left" class="text-2xl" />
      </button>
      <h2 class="text-xl font-bold text-gray-800">仓库详情</h2>
      <nav class="flex text-sm text-gray-400 ml-4">
        <router-link to="/warehouses" class="hover:text-blue-500">仓库管理</router-link>
        <span class="mx-2">/</span>
        <span class="text-gray-600">仓库详情</span>
      </nav>
    </div>

    <div class="grid grid-cols-3 gap-8">
      <div class="col-span-2 space-y-6">
        <div class="bg-white p-8 rounded-3xl shadow-sm border border-gray-50">
          <div class="flex justify-between items-start mb-6">
            <div class="flex items-center gap-4">
              <div class="w-16 h-16 bg-blue-50 rounded-2xl flex items-center justify-center">
                <Icon class="text-3xl text-[#1890FF]" icon="mdi:warehouse" />
              </div>
              <div>
                <h3 class="text-xl font-bold text-gray-800">{{ warehouseData.name }}</h3>
                <p class="text-sm text-gray-400 mt-1">仓库编号: {{ warehouseData.code }} | 创建时间: {{ warehouseData.createTime }}</p>
              </div>
            </div>
            <span class="px-3 py-1.5 text-xs font-bold bg-green-50 text-green-500 rounded-full border border-green-100">
              {{ getStatusText(warehouseData.status) }}
            </span>
          </div>
          <div class="grid grid-cols-2 gap-6">
            <div>
              <label class="block text-xs font-bold text-gray-400 uppercase mb-2">仓库管理员</label>
              <p class="text-sm font-medium text-gray-800">{{ warehouseData.manager || '未分配' }}</p>
            </div>
            <div>
              <label class="block text-xs font-bold text-gray-400 uppercase mb-2">联系电话</label>
              <p class="text-sm font-medium text-gray-800">{{ warehouseData.phone }}</p>
            </div>
            <div class="col-span-2">
              <label class="block text-xs font-bold text-gray-400 uppercase mb-2">详细地址</label>
              <p class="text-sm font-medium text-gray-800">{{ warehouseData.address }}</p>
            </div>
            <div>
              <label class="block text-xs font-bold text-gray-400 uppercase mb-2">仓库面积</label>
              <p class="text-sm font-medium text-gray-800">{{ warehouseData.area || '未设置' }} 平方米</p>
            </div>
            <div>
              <label class="block text-xs font-bold text-gray-400 uppercase mb-2">覆盖区域</label>
              <p class="text-sm font-medium text-gray-800">{{ warehouseData.coverageArea || '未分配' }}</p>
            </div>
          </div>
          <div class="flex gap-3 mt-6 pt-6 border-t border-gray-50">
            <button @click="openEditDialog" class="bg-white border border-gray-200 text-gray-600 px-4 py-2 rounded-lg hover:bg-gray-50 transition-colors flex items-center gap-2">
              <Icon icon="mdi:pencil-outline" />
              编辑信息
            </button>
            <button @click="goToInbound" class="bg-[#1890FF] text-white px-4 py-2 rounded-lg hover:bg-blue-600 transition-colors flex items-center gap-2">
              <Icon icon="mdi:package-variant-plus" />
              入库登记
            </button>
          </div>
        </div>

        <div class="bg-white p-8 rounded-3xl shadow-sm border border-gray-50">
          <h4 class="font-bold text-gray-800 text-lg mb-6">库存概览</h4>
          <div class="grid grid-cols-4 gap-4 mb-6">
            <div class="p-4 bg-blue-50 rounded-2xl">
              <p class="text-xs text-gray-400 mb-1">成品水库存</p>
              <p class="text-xl font-bold text-blue-600">{{ (warehouseData.productStock || 0).toLocaleString() }} 桶</p>
              <p class="text-[10px] text-gray-400 mt-1">安全库存: {{ warehouseData.safeStock || 0 }}</p>
            </div>
            <div class="p-4 bg-green-50 rounded-2xl">
              <p class="text-xs text-gray-400 mb-1">空桶库存</p>
              <p class="text-xl font-bold text-green-600">{{ warehouseData.emptyBucketStock || 0 }} 个</p>
              <p class="text-[10px] text-gray-400 mt-1">在用: {{ warehouseData.inUseBuckets || 0 }}</p>
            </div>
            <div class="p-4 bg-purple-50 rounded-2xl">
              <p class="text-xs text-gray-400 mb-1">今日入库</p>
              <p class="text-xl font-bold text-purple-600">{{ warehouseData.todayInbound || 0 }} 桶</p>
            </div>
            <div class="p-4 bg-orange-50 rounded-2xl">
              <p class="text-xs text-gray-400 mb-1">今日出库</p>
              <p class="text-xl font-bold text-orange-600">{{ warehouseData.todayOutbound || 0 }} 桶</p>
            </div>
          </div>
          <div class="p-4 bg-gray-50 rounded-xl">
            <h5 class="text-sm font-bold text-gray-700 mb-3">分仓库库存明细</h5>
            <div class="space-y-2">
              <div v-for="item in inventoryDetails" :key="item.productId" class="flex justify-between items-center py-2 px-3 bg-white rounded-lg">
                <span class="text-sm text-gray-600">{{ item.productName }}</span>
                <span class="text-sm font-bold" :class="item.quantity < item.safeStock ? 'text-red-500' : 'text-gray-800'">
                  {{ item.quantity }} 桶
                  <span v-if="item.quantity < item.safeStock" class="text-red-400 text-xs">⚠️</span>
                </span>
              </div>
              <div v-if="inventoryDetails.length === 0" class="text-center py-4 text-gray-400 text-sm">
                暂无库存数据
              </div>
            </div>
          </div>
        </div>

        <div class="bg-white p-8 rounded-3xl shadow-sm border border-gray-50">
          <div class="flex justify-between items-center mb-6">
            <h4 class="font-bold text-gray-800 text-lg">待处理订单</h4>
            <button class="text-blue-500 text-sm font-bold">查看全部</button>
          </div>
          <table class="w-full text-left">
            <thead class="bg-gray-50 rounded-xl">
              <tr>
                <th class="px-4 py-3 text-xs font-bold text-gray-400 uppercase">订单编号</th>
                <th class="px-4 py-3 text-xs font-bold text-gray-400 uppercase">水站</th>
                <th class="px-4 py-3 text-xs font-bold text-gray-400 uppercase">下单时间</th>
                <th class="px-4 py-3 text-xs font-bold text-gray-400 uppercase text-right">桶数</th>
                <th class="px-4 py-3 text-xs font-bold text-gray-400 uppercase">状态</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-gray-50">
              <tr v-for="order in pendingOrders" :key="order.id">
                <td class="px-4 py-4 text-sm text-gray-800 font-mono">{{ order.orderNo }}</td>
                <td class="px-4 py-4 text-sm text-gray-600">{{ order.stationName }}</td>
                <td class="px-4 py-4 text-sm text-gray-400">{{ order.createTime }}</td>
                <td class="px-4 py-4 text-sm text-gray-800 text-right font-bold">{{ order.buckets }} 桶</td>
                <td class="px-4 py-4">
                  <span class="px-2 py-1 text-[10px] font-bold rounded-full" :class="getOrderStatusClass(order.status)">
                    {{ getOrderStatusText(order.status) }}
                  </span>
                </td>
              </tr>
              <tr v-if="pendingOrders.length === 0">
                <td colspan="5" class="px-4 py-8 text-center text-gray-400">暂无待处理订单</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <div class="space-y-6">
        <div class="bg-white p-6 rounded-3xl shadow-sm border border-gray-50">
          <h4 class="font-bold text-gray-800 mb-4">今日运营数据</h4>
          <div class="space-y-4">
            <div class="flex justify-between items-center py-3 border-b border-gray-50">
              <div class="flex items-center gap-2">
                <Icon class="text-blue-500" icon="mdi:clipboard-list" />
                <span class="text-sm text-gray-600">待接单</span>
              </div>
              <span class="text-sm font-bold text-red-500">{{ warehouseData.pendingOrders || 0 }} 单</span>
            </div>
            <div class="flex justify-between items-center py-3 border-b border-gray-50">
              <div class="flex items-center gap-2">
                <Icon class="text-orange-500" icon="mdi:package-variant-closed" />
                <span class="text-sm text-gray-600">备货中</span>
              </div>
              <span class="text-sm font-bold text-gray-800">{{ warehouseData.preparingOrders || 0 }} 单</span>
            </div>
            <div class="flex justify-between items-center py-3 border-b border-gray-50">
              <div class="flex items-center gap-2">
                <Icon class="text-purple-500" icon="mdi:truck-delivery" />
                <span class="text-sm text-gray-600">配送中</span>
              </div>
              <span class="text-sm font-bold text-gray-800">{{ warehouseData.deliveringOrders || 0 }} 单</span>
            </div>
            <div class="flex justify-between items-center py-3">
              <div class="flex items-center gap-2">
                <Icon class="text-green-500" icon="mdi:check-circle" />
                <span class="text-sm text-gray-600">已完成</span>
              </div>
              <span class="text-sm font-bold text-gray-800">{{ warehouseData.completedToday || 0 }} 单</span>
            </div>
          </div>
        </div>

        <div class="bg-white p-6 rounded-3xl shadow-sm border border-gray-50">
          <div class="flex justify-between items-center mb-4">
            <h4 class="font-bold text-gray-800">仓库人员</h4>
            <span class="text-xs px-2 py-1 rounded-full" :class="warehouseData.type === 'main' ? 'bg-purple-50 text-purple-500' : 'bg-green-50 text-green-500'">
              {{ warehouseData.type === 'main' ? '总仓' : '分仓' }}
            </span>
          </div>
          <div class="space-y-3">
            <div v-for="staff in warehouseData.staffs" :key="staff.id" class="flex justify-between items-center p-3 bg-gray-50 rounded-xl">
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 bg-blue-50 rounded-full flex items-center justify-center">
                  <Icon class="text-blue-500" icon="mdi:account" />
                </div>
                <div>
                  <p class="text-sm font-bold text-gray-800">{{ staff.name }}</p>
                  <p class="text-[10px] text-gray-400">{{ staff.role }}</p>
                </div>
              </div>
              <span class="text-[10px] px-2 py-0.5 rounded-full" :class="staff.onlineStatus === 'online' ? 'bg-green-50 text-green-500' : 'bg-gray-100 text-gray-500'">
                {{ staff.onlineStatus === 'online' ? '在线' : '离线' }}
              </span>
            </div>
            <div v-if="!warehouseData.staffs || warehouseData.staffs.length === 0" class="text-center py-4 text-gray-400 text-sm">
              暂无人员数据
            </div>
          </div>
        </div>

        <div class="bg-white p-6 rounded-3xl shadow-sm border border-gray-50">
          <div class="flex justify-between items-center mb-4">
            <h4 class="font-bold text-gray-800">配送司机</h4>
            <button class="text-blue-500 text-xs font-bold">分配司机</button>
          </div>
          <div class="space-y-3">
            <div v-for="driver in assignedDrivers" :key="driver.id" class="flex justify-between items-center p-3 rounded-xl" :class="driver.status === 'idle' ? 'bg-green-50' : 'bg-blue-50'">
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 bg-white rounded-full flex items-center justify-center overflow-hidden">
                  <img :src="driver.avatar" :alt="driver.name" class="w-full h-full object-cover" />
                </div>
                <div>
                  <p class="text-sm font-bold text-gray-800">{{ driver.name }}</p>
                  <p class="text-[10px] text-gray-400">当前任务: {{ driver.currentTasks }}单</p>
                </div>
              </div>
              <span class="text-xs px-2 py-0.5 rounded-full font-bold" :class="getDriverStatusClass(driver.status)">
                {{ getDriverStatusText(driver.status) }}
              </span>
            </div>
            <div v-if="assignedDrivers.length === 0" class="text-center py-4 text-gray-400 text-sm">
              暂无分配司机
            </div>
          </div>
        </div>

        <div class="bg-white p-6 rounded-3xl shadow-sm border border-gray-50">
          <h4 class="font-bold text-gray-800 mb-4">快捷操作</h4>
          <div class="space-y-2">
            <button class="w-full py-3 bg-blue-50 text-blue-600 rounded-xl text-sm font-bold flex items-center justify-center gap-2 hover:bg-blue-100 transition-colors">
              <Icon icon="mdi:clipboard-list" />
              订单管理
            </button>
            <button @click="goToInbound" class="w-full py-3 bg-green-50 text-green-600 rounded-xl text-sm font-bold flex items-center justify-center gap-2 hover:bg-green-100 transition-colors">
              <Icon icon="mdi:tray-arrow-down" />
              入库登记
            </button>
            <button @click="goToInventoryCheck" class="w-full py-3 bg-purple-50 text-purple-600 rounded-xl text-sm font-bold flex items-center justify-center gap-2 hover:bg-purple-100 transition-colors">
              <Icon icon="mdi:warehouse" />
              库存盘点
            </button>
            <button class="w-full py-3 bg-orange-50 text-orange-600 rounded-xl text-sm font-bold flex items-center justify-center gap-2 hover:bg-orange-100 transition-colors">
              <Icon icon="mdi:printer" />
              打印备货单
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-if="showEditDialog" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50" @click.self="closeEditDialog">
      <div class="bg-white rounded-2xl p-8 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <div class="flex justify-between items-center mb-6">
          <h3 class="text-xl font-bold text-gray-800">编辑仓库信息</h3>
          <button @click="closeEditDialog" class="text-gray-400 hover:text-gray-600">
            <Icon icon="mdi:close" class="text-2xl" />
          </button>
        </div>

        <form @submit.prevent="handleEditSubmit" class="space-y-6">
          <div class="grid grid-cols-2 gap-6">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">仓库名称 <span class="text-red-500">*</span></label>
              <input v-model="editForm.name" class="input-field" placeholder="请输入仓库名称" required />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">仓库编号</label>
              <input v-model="editForm.code" class="input-field bg-gray-50" disabled />
            </div>
          </div>

          <div class="grid grid-cols-2 gap-6">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">仓库管理员</label>
              <input v-model="editForm.manager" class="input-field" placeholder="请输入管理员姓名" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">联系电话</label>
              <input v-model="editForm.phone" class="input-field" placeholder="请输入联系电话" />
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">详细地址</label>
            <input v-model="editForm.address" class="input-field" placeholder="请输入详细地址" />
          </div>

          <div class="grid grid-cols-2 gap-6">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">仓库面积</label>
              <input v-model="editForm.area" type="number" class="input-field" placeholder="请输入仓库面积" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">仓库类型</label>
              <select v-model="editForm.type" class="input-field">
                <option value="main">总仓</option>
                <option value="branch">分仓</option>
              </select>
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">覆盖区域</label>
            <select v-model="editForm.coverageArea" class="input-field">
              <option value="">请选择覆盖区域</option>
              <option v-for="region in regionOptions" :key="region.value" :value="region.value">
                {{ region.label }}
              </option>
            </select>
          </div>

          <div class="flex justify-end gap-4 pt-4 border-t border-gray-100">
            <button type="button" @click="closeEditDialog" class="btn-secondary">取消</button>
            <button type="submit" class="btn-primary">保存修改</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { Icon } from '@iconify/vue'
import { warehousesApi } from '@/api/warehouses'
import { useRegionStore } from '@/stores/regions'

const router = useRouter()
const route = useRoute()
const regionStore = useRegionStore()

const regionOptions = computed(() => regionStore.getRegionOptions())

const showEditDialog = ref(false)
const warehouseId = ref(route.params.id as string || '')

interface WarehouseStaff {
  id: string
  name: string
  role: string
  onlineStatus: string
}

interface InventoryDetail {
  productId: string
  productName: string
  quantity: number
  safeStock: number
}

interface PendingOrder {
  id: string
  orderNo: string
  stationName: string
  createTime: string
  buckets: number
  status: string
}

interface AssignedDriver {
  id: string
  name: string
  avatar: string
  currentTasks: number
  status: string
}

interface WarehouseData {
  id: string
  name: string
  code: string
  status: string
  contact: string
  phone: string
  address: string
  type: string
  createTime: string
  remark?: string
  stock?: number
  stationCount?: number
  manager?: string
  productStock?: number
  emptyBucketStock?: number
  inUseBuckets?: number
  safeStock?: number
  todayInbound?: number
  todayOutbound?: number
  pendingOrders?: number
  preparingOrders?: number
  deliveringOrders?: number
  completedToday?: number
  coverageArea?: string
  area?: string
  staffs?: WarehouseStaff[]
}

const warehouseData = reactive<WarehouseData>({
  id: '',
  name: '加载中...',
  code: '',
  status: 'active',
  contact: '',
  phone: '',
  address: '',
  type: 'main',
  createTime: '',
  manager: '',
  productStock: 0,
  emptyBucketStock: 0,
  inUseBuckets: 0,
  safeStock: 2000,
  todayInbound: 0,
  todayOutbound: 0,
  pendingOrders: 0,
  preparingOrders: 0,
  deliveringOrders: 0,
  completedToday: 0,
  coverageArea: '',
  area: ''
})

const inventoryDetails = ref<InventoryDetail[]>([])
const pendingOrders = ref<PendingOrder[]>([])
const assignedDrivers = ref<AssignedDriver[]>([])

const editForm = reactive({
  name: '',
  code: '',
  manager: '',
  phone: '',
  address: '',
  area: '',
  type: 'main',
  coverageArea: ''
})

const getStatusText = (status: string) => {
  const statusMap: Record<string, string> = {
    active: '正常运营',
    inactive: '已停用'
  }
  return statusMap[status] || status
}

const getOrderStatusText = (status: string) => {
  const statusMap: Record<string, string> = {
    PENDING_REVIEW: '待派单',
    PREPARING: '备货中',
    DISPATCHED: '已派单',
    DELIVERING: '配送中',
    COMPLETED: '已完成'
  }
  return statusMap[status] || status
}

const getOrderStatusClass = (status: string) => {
  const classMap: Record<string, string> = {
    PENDING_REVIEW: 'bg-orange-50 text-orange-500',
    PREPARING: 'bg-blue-50 text-blue-500',
    DISPATCHED: 'bg-purple-50 text-purple-500',
    DELIVERING: 'bg-blue-50 text-blue-500',
    COMPLETED: 'bg-green-50 text-green-500'
  }
  return classMap[status] || 'bg-gray-50 text-gray-500'
}

const getDriverStatusText = (status: string) => {
  const statusMap: Record<string, string> = {
    idle: '空闲',
    busy: '配送中'
  }
  return statusMap[status] || status
}

const getDriverStatusClass = (status: string) => {
  const classMap: Record<string, string> = {
    idle: 'bg-green-100 text-green-600',
    busy: 'bg-blue-100 text-blue-600'
  }
  return classMap[status] || 'bg-gray-100 text-gray-500'
}

const goBack = () => {
  router.push('/warehouses')
}

const openEditDialog = () => {
  editForm.name = warehouseData.name
  editForm.code = warehouseData.code
  editForm.manager = warehouseData.manager || ''
  editForm.phone = warehouseData.phone
  editForm.address = warehouseData.address
  editForm.area = warehouseData.area || ''
  editForm.type = warehouseData.type || 'main'
  editForm.coverageArea = warehouseData.coverageArea || ''
  showEditDialog.value = true
}

const closeEditDialog = () => {
  showEditDialog.value = false
}

const goToInbound = () => {
  router.push('/inventory/inbound')
}

const goToInventoryCheck = () => {
  router.push('/inventory/check')
}

const handleEditSubmit = async () => {
  try {
    await warehousesApi.update(warehouseId.value, {
      name: editForm.name,
      contact: editForm.manager,
      phone: editForm.phone,
      address: editForm.address,
      coverageArea: editForm.coverageArea
    })
    await fetchWarehouseDetail()
    closeEditDialog()
  } catch (error) {
    console.error('更新仓库信息失败:', error)
  }
}

const fetchWarehouseDetail = async () => {
  try {
    const res: any = await warehousesApi.getById(warehouseId.value)
    const data = res.data || res
    if (data && typeof data === 'object' && data.id) {
      Object.assign(warehouseData, data)
    }
  } catch (error) {
    console.error('获取仓库详情失败:', error)
  }
}

const fetchInventoryDetails = async () => {
  inventoryDetails.value = []
}

const fetchPendingOrders = async () => {
  pendingOrders.value = []
}

const fetchAssignedDrivers = async () => {
  try {
    const res: any = await warehousesApi.getStaffs(warehouseId.value)
    const staffList = res.data || res
    if (Array.isArray(staffList)) {
      warehouseData.staffs = staffList.map((staff: any) => ({
        id: String(staff.id),
        name: staff.name,
        role: staff.role === 'admin' ? '仓库管理员' : '员工',
        onlineStatus: staff.onlineStatus
      }))
    }
  } catch (error) {
    console.error('获取仓库人员失败:', error)
    warehouseData.staffs = []
  }
}

onMounted(async () => {
  if (warehouseId.value) {
    await fetchWarehouseDetail()
    await fetchInventoryDetails()
    await fetchPendingOrders()
    await fetchAssignedDrivers()
  }
  await regionStore.fetchRegionTree()
})
</script>

<style scoped>
</style>
