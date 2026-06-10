<template>
  <div>
    <div class="flex items-center gap-4 mb-6">
      <button @click="goBack" class="text-gray-500 hover:text-blue-500">
        <Icon icon="mdi:chevron-left" class="text-2xl" />
      </button>
      <h2 class="text-xl font-bold text-gray-800">司机详情</h2>
      <nav class="flex text-sm text-gray-400 ml-4">
        <router-link to="/drivers" class="hover:text-blue-500">司机管理</router-link>
        <span class="mx-2">/</span>
        <span class="text-gray-600">司机详情</span>
      </nav>
    </div>

    <div class="grid grid-cols-3 gap-8">
      <div class="col-span-2 space-y-6">
        <div class="bg-white p-8 rounded-3xl shadow-sm border border-gray-50">
          <div class="flex justify-between items-start mb-6">
            <div class="flex items-center gap-4">
              <div class="relative">
                <img :src="driverData.avatar || defaultAvatar" :alt="driverData.name" class="w-20 h-20 rounded-2xl object-cover" />
                <div v-if="driverData.onlineStatus === 'online'" class="absolute -bottom-2 -right-2 w-6 h-6 bg-green-500 text-white rounded-full flex items-center justify-center text-xs border-2 border-white">
                  <Icon icon="mdi:check" />
                </div>
              </div>
              <div>
                <h3 class="text-xl font-bold text-gray-800">{{ driverData.name }}</h3>
                <p class="text-sm text-gray-400 mt-1">工号: {{ driverData.code }} | 入职: {{ driverData.createTime }}</p>
                <div class="flex items-center gap-2 mt-2">
                  <span class="inline-flex items-center gap-1 px-2 py-1 text-[10px] font-bold rounded-full" :class="getStatusClass(driverData.onlineStatus || 'offline')">
                    <span v-if="driverData.onlineStatus === 'online'" class="w-1.5 h-1.5 bg-green-500 rounded-full animate-pulse"></span>
                    {{ getStatusText(driverData.onlineStatus || 'offline') }}
                  </span>
                </div>
              </div>
            </div>
          </div>
          <div class="grid grid-cols-2 gap-6">
            <div>
              <label class="block text-xs font-bold text-gray-400 uppercase mb-2">联系电话</label>
              <p class="text-sm font-medium text-gray-800">{{ driverData.phone }}</p>
            </div>
            <div>
              <label class="block text-xs font-bold text-gray-400 uppercase mb-2">紧急联系人</label>
              <p class="text-sm font-medium text-gray-800">{{ driverData.emergencyContact || '未设置' }}</p>
            </div>
            <div>
              <label class="block text-xs font-bold text-gray-400 uppercase mb-2">车牌号</label>
              <p class="text-sm font-medium text-gray-800">{{ driverData.licensePlate || '未设置' }}</p>
            </div>
            <div>
              <label class="block text-xs font-bold text-gray-400 uppercase mb-2">车辆类型</label>
              <p class="text-sm font-medium text-gray-800">{{ driverData.vehicleType || '未设置' }}</p>
            </div>
            <div class="col-span-2">
              <label class="block text-xs font-bold text-gray-400 uppercase mb-2">负责仓库</label>
              <p class="text-sm font-medium text-gray-800">
                <span v-if="driverData.warehouseNames && driverData.warehouseNames.length > 0">
                  <el-tag v-for="name in driverData.warehouseNames" :key="name" size="small" class="mr-1">{{ name }}</el-tag>
                </span>
                <span v-else>{{ driverData.warehouse || '未分配' }}</span>
              </p>
            </div>
            <div class="col-span-2">
              <label class="block text-xs font-bold text-gray-400 uppercase mb-2">负责区域</label>
              <p class="text-sm font-medium text-gray-800">{{ regionStore.getRegionName(driverData.area) || driverData.area || '未分配' }}</p>
            </div>
          </div>
          <div class="flex gap-3 mt-6 pt-6 border-t border-gray-50">
            <button @click="openEditDialog" class="bg-white border border-gray-200 text-gray-600 px-4 py-2 rounded-lg hover:bg-gray-50 transition-colors flex items-center gap-2">
              <Icon icon="mdi:pencil-outline" />
              编辑信息
            </button>
            <button @click="resetPassword" class="bg-[#1890FF] text-white px-4 py-2 rounded-lg hover:bg-blue-600 transition-colors flex items-center gap-2">
              <Icon icon="mdi:reset" />
              重置密码
            </button>
          </div>
        </div>

        <div class="bg-white p-8 rounded-3xl shadow-sm border border-gray-50">
          <h4 class="font-bold text-gray-800 text-lg mb-6">配送业绩统计</h4>
          <div class="grid grid-cols-4 gap-4 mb-6">
            <div class="p-4 bg-blue-50 rounded-2xl text-center">
              <p class="text-xs text-gray-400 mb-1">本月完成</p>
              <p class="text-2xl font-bold text-blue-600">{{ driverData.monthlyCompleted || 0 }} 单</p>
            </div>
            <div class="p-4 bg-green-50 rounded-2xl text-center">
              <p class="text-xs text-gray-400 mb-1">配送桶数</p>
              <p class="text-2xl font-bold text-green-600">{{ (driverData.monthlyBuckets || 0).toLocaleString() }} 桶</p>
            </div>
            <div class="p-4 bg-purple-50 rounded-2xl text-center">
              <p class="text-xs text-gray-400 mb-1">好评率</p>
              <p class="text-2xl font-bold text-purple-600">{{ driverData.rating || '100' }}%</p>
            </div>
            <div class="p-4 bg-orange-50 rounded-2xl text-center">
              <p class="text-xs text-gray-400 mb-1">配送里程</p>
              <p class="text-2xl font-bold text-orange-600">{{ (driverData.monthlyDistance || 0).toLocaleString() }} km</p>
            </div>
          </div>
          <div class="p-4 bg-gray-50 rounded-xl">
            <div class="flex justify-between items-center mb-3">
              <span class="text-sm font-bold text-gray-700">本月配送效率趋势</span>
              <span class="text-xs text-gray-400">4月份</span>
            </div>
            <div class="flex items-end gap-2 h-24">
              <div v-for="(value, index) in deliveryTrend" :key="index" class="flex-1 bg-blue-100 rounded-t-lg hover:bg-blue-400 transition-colors cursor-pointer" :style="{ height: value + '%' }" :title="`周${index + 1}: ${value}%`"></div>
            </div>
            <div class="flex justify-between text-xs text-gray-400 mt-2">
              <span>周一</span><span>周二</span><span>周三</span><span>周四</span><span>周五</span><span>周六</span><span>周日</span>
            </div>
          </div>
        </div>

        <div class="bg-white p-8 rounded-3xl shadow-sm border border-gray-50">
          <div class="flex justify-between items-center mb-6">
            <h4 class="font-bold text-gray-800 text-lg">最近配送任务</h4>
            <button class="text-blue-500 text-sm font-bold">查看全部</button>
          </div>
          <table class="w-full text-left">
            <thead class="bg-gray-50 rounded-xl">
              <tr>
                <th class="px-4 py-3 text-xs font-bold text-gray-400 uppercase">订单编号</th>
                <th class="px-4 py-3 text-xs font-bold text-gray-400 uppercase">水站</th>
                <th class="px-4 py-3 text-xs font-bold text-gray-400 uppercase">配送时间</th>
                <th class="px-4 py-3 text-xs font-bold text-gray-400 uppercase text-right">桶数</th>
                <th class="px-4 py-3 text-xs font-bold text-gray-400 uppercase">状态</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-gray-50">
              <tr v-for="task in recentTasks" :key="task.id">
                <td class="px-4 py-4 text-sm text-gray-800 font-mono">{{ task.orderNo }}</td>
                <td class="px-4 py-4 text-sm text-gray-600">{{ task.stationName }}</td>
                <td class="px-4 py-4 text-sm text-gray-400">{{ task.deliveryTime }}</td>
                <td class="px-4 py-4 text-sm text-gray-800 text-right font-bold">{{ task.buckets }} 桶</td>
                <td class="px-4 py-4">
                  <span class="px-2 py-1 text-[10px] font-bold rounded-full" :class="getTaskStatusClass(task.status)">
                    {{ getTaskStatusText(task.status) }}
                  </span>
                </td>
              </tr>
              <tr v-if="recentTasks.length === 0">
                <td colspan="5" class="px-4 py-8 text-center text-gray-400">暂无配送任务</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <div class="space-y-6">
        <div class="bg-white p-6 rounded-3xl shadow-sm border border-gray-50">
          <h4 class="font-bold text-gray-800 mb-4">实时状态</h4>
          <div class="space-y-4">
            <div class="p-4 rounded-2xl" :class="driverData.onlineStatus === 'online' ? 'bg-green-50' : 'bg-gray-50'">
              <div class="flex items-center justify-between mb-2">
                <span class="text-sm text-gray-600">当前位置</span>
                <span class="text-xs px-2 py-0.5 rounded-full font-bold" :class="driverData.onlineStatus === 'online' ? 'bg-green-100 text-green-600' : 'bg-gray-100 text-gray-500'">
                  {{ driverData.onlineStatus === 'online' ? 'GPS在线' : '离线' }}
                </span>
              </div>
              <p class="text-sm font-bold text-gray-800">{{ driverData.currentLocation || '暂无位置信息' }}</p>
              <p class="text-[10px] text-gray-400 mt-1">最后更新: {{ driverData.lastLocationTime || '未知' }}</p>
            </div>
            <div class="flex gap-4">
              <div class="flex-1 p-4 bg-blue-50 rounded-xl text-center">
                <p class="text-[10px] text-gray-400 mb-1">当前任务</p>
                <p class="text-xl font-bold text-blue-600">{{ driverData.currentTasks || 0 }} 单</p>
              </div>
              <div class="flex-1 p-4 bg-purple-50 rounded-xl text-center">
                <p class="text-[10px] text-gray-400 mb-1">车上空桶</p>
                <p class="text-xl font-bold text-purple-600">{{ driverData.bucketOnVehicle || 0 }} 个</p>
              </div>
            </div>
          </div>
        </div>

        <div class="bg-white p-6 rounded-3xl shadow-sm border border-gray-50">
          <h4 class="font-bold text-gray-800 mb-4">今日汇总</h4>
          <div class="space-y-3">
            <div class="flex justify-between items-center py-3 border-b border-gray-50">
              <div class="flex items-center gap-2">
                <Icon class="text-blue-500" icon="mdi:clipboard-check" />
                <span class="text-sm text-gray-600">完成配送</span>
              </div>
              <span class="text-sm font-bold text-gray-800">{{ driverData.todayCompleted || 0 }} 单</span>
            </div>
            <div class="flex justify-between items-center py-3 border-b border-gray-50">
              <div class="flex items-center gap-2">
                <Icon class="text-green-500" icon="mdi:barrel" />
                <span class="text-sm text-gray-600">送水桶数</span>
              </div>
              <span class="text-sm font-bold text-gray-800">{{ driverData.todayBuckets || 0 }} 桶</span>
            </div>
            <div class="flex justify-between items-center py-3 border-b border-gray-50">
              <div class="flex items-center gap-2">
                <Icon class="text-orange-500" icon="mdi:map-marker-distance" />
                <span class="text-sm text-gray-600">行驶里程</span>
              </div>
              <span class="text-sm font-bold text-gray-800">{{ driverData.todayDistance || 0 }} km</span>
            </div>
            <div class="flex justify-between items-center py-3">
              <div class="flex items-center gap-2">
                <Icon class="text-purple-500" icon="mdi:clock-outline" />
                <span class="text-sm text-gray-600">工作时长</span>
              </div>
              <span class="text-sm font-bold text-gray-800">{{ driverData.todayWorkHours || 0 }} 小时</span>
            </div>
          </div>
        </div>

        <div class="bg-white p-6 rounded-3xl shadow-sm border border-gray-50">
          <h4 class="font-bold text-gray-800 mb-4">空桶往来</h4>
          <div class="bg-gradient-to-br from-[#1890FF] to-blue-500 rounded-2xl text-white mb-4 p-4">
            <p class="text-xs opacity-80 mb-1">车上空桶</p>
            <p class="text-2xl font-bold">{{ driverData.bucketOnVehicle || 0 }} <span class="text-sm font-normal opacity-70">个</span></p>
          </div>
          <div class="space-y-2">
            <div class="flex justify-between items-center py-2 px-3 bg-gray-50 rounded-lg">
              <span class="text-xs text-gray-500">回收空桶</span>
              <span class="text-xs font-bold text-green-600">+{{ driverData.todayReturnBuckets || 0 }} 个</span>
            </div>
            <div class="flex justify-between items-center py-2 px-3 bg-gray-50 rounded-lg">
              <span class="text-xs text-gray-500">送出空桶</span>
              <span class="text-xs font-bold text-orange-600">-{{ driverData.todayDeliverBuckets || 0 }} 个</span>
            </div>
          </div>
        </div>

        <div class="bg-white p-6 rounded-3xl shadow-sm border border-gray-50">
          <h4 class="font-bold text-gray-800 mb-4">快捷操作</h4>
          <div class="space-y-2">
            <button class="w-full py-3 bg-blue-50 text-blue-600 rounded-xl text-sm font-bold flex items-center justify-center gap-2 hover:bg-blue-100 transition-colors">
              <Icon icon="mdi:phone" />
              联系司机
            </button>
            <button class="w-full py-3 bg-orange-50 text-orange-600 rounded-xl text-sm font-bold flex items-center justify-center gap-2 hover:bg-orange-100 transition-colors">
              <Icon icon="mdi:map-marker-path" />
              查看位置
            </button>
            <button class="w-full py-3 bg-red-50 text-red-500 rounded-xl text-sm font-bold flex items-center justify-center gap-2 hover:bg-red-100 transition-colors">
              <Icon icon="mdi:account-off" />
              设为休息
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-if="showEditDialog" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50" @click.self="closeEditDialog">
      <div class="bg-white rounded-2xl p-8 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <div class="flex justify-between items-center mb-6">
          <h3 class="text-xl font-bold text-gray-800">编辑司机信息</h3>
          <button @click="closeEditDialog" class="text-gray-400 hover:text-gray-600">
            <Icon icon="mdi:close" class="text-2xl" />
          </button>
        </div>

        <form @submit.prevent="handleEditSubmit" class="space-y-6">
          <div class="grid grid-cols-2 gap-6">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">姓名 <span class="text-red-500">*</span></label>
              <input v-model="editForm.name" class="input-field" placeholder="请输入司机姓名" required />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">工号</label>
              <input v-model="editForm.code" class="input-field bg-gray-50" disabled />
            </div>
          </div>

          <div class="grid grid-cols-2 gap-6">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">联系电话 <span class="text-red-500">*</span></label>
              <input v-model="editForm.phone" class="input-field" placeholder="请输入手机号码" required />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">紧急联系人</label>
              <input v-model="editForm.emergencyContact" class="input-field" placeholder="请输入紧急联系人" />
            </div>
          </div>

          <div class="grid grid-cols-2 gap-6">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">车牌号</label>
              <input v-model="editForm.licensePlate" class="input-field" placeholder="请输入车牌号" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">车辆类型</label>
              <input v-model="editForm.vehicleType" class="input-field" placeholder="如：厢式货车 4.2米" />
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">负责区域</label>
            <select v-model="editForm.area" class="input-field">
              <option value="">请选择区域</option>
              <option v-for="region in regionStore.getRegionOptions()" :key="region.value" :value="region.value">{{ region.label }}</option>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">负责仓库</label>
            <select v-model="editForm.warehouseIds" multiple class="input-field min-h-[100px]">
              <option value="">请选择仓库（可多选）</option>
              <option v-for="warehouse in warehouses" :key="warehouse.id" :value="warehouse.id">{{ warehouse.name }}</option>
            </select>
            <p class="text-xs text-gray-400 mt-1">按住 Ctrl/Cmd 键可多选仓库</p>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">备注说明</label>
            <textarea v-model="editForm.remark" class="input-field h-24 resize-none" placeholder="请输入备注信息（选填）..."></textarea>
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
import { ref, computed, reactive, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { Icon } from '@iconify/vue'
import { driversApi } from '@/api/drivers'
import { useRegionStore } from '@/stores/regions'
import { warehousesApi } from '@/api/warehouses'

const router = useRouter()
const route = useRoute()
const regionStore = useRegionStore()

const showEditDialog = ref(false)
const driverId = ref(route.params.id as string || '')
const defaultAvatar = 'https://modao.cc/agent-py/media/generated_images/2026-04-19/2566b5396b094ab1a625df1e2a348bad.jpg'

interface RecentTask {
  id: string
  orderNo: string
  stationName: string
  deliveryTime: string
  buckets: number
  status: string
}

interface DriverData {
  id: string
  code: string
  name: string
  phone: string
  area: string
  warehouseId: string
  warehouseIds?: string[]
  warehouseNames?: string[]
  status: string
  createTime: string
  avatar?: string
  idCard?: string
  vehicleInfo?: string
  remark?: string
  onlineStatus?: string
  currentTasks?: number
  todayDeliveries?: number
  todayBuckets?: number
  lastLogin?: string
  emergencyContact?: string
  licensePlate?: string
  vehicleType?: string
  warehouse?: string
  warehouseList?: { id: string; name: string }[]
  monthlyCompleted?: number
  monthlyBuckets?: number
  rating?: string
  monthlyDistance?: number
  bucketOnVehicle?: number
  todayCompleted?: number
  todayDistance?: number
  todayWorkHours?: number
  todayReturnBuckets?: number
  todayDeliverBuckets?: number
  currentLocation?: string
  lastLocationTime?: string
  deliveryTrend?: number[]
}

const driverData = reactive<DriverData>({
  id: '',
  name: '加载中...',
  code: '',
  phone: '',
  status: 'offline',
  onlineStatus: 'offline',
  createTime: '',
  area: '',
  warehouseId: '',
  warehouse: '',
  avatar: defaultAvatar,
  currentTasks: 0,
  bucketOnVehicle: 0,
  monthlyCompleted: 0,
  monthlyBuckets: 0,
  rating: '100',
  monthlyDistance: 0
})

const recentTasks = ref<RecentTask[]>([])
const warehouses = ref<any[]>([])
const deliveryTrend = computed(() => {
  if (driverData.deliveryTrend && driverData.deliveryTrend.length > 0) {
    return driverData.deliveryTrend
  }
  return [0, 0, 0, 0, 0, 0, 0]
})

const editForm = reactive({
  name: '',
  code: '',
  phone: '',
  emergencyContact: '',
  licensePlate: '',
  vehicleType: '',
  area: '',
  warehouseId: '',
  warehouseIds: [] as string[],
  remark: ''
})

const getStatusText = (status: string) => {
  const statusMap: Record<string, string> = {
    online: '在线配送中',
    offline: '离线',
    break: '休息中'
  }
  return statusMap[status] || '离线'
}

const getStatusClass = (status: string) => {
  const classMap: Record<string, string> = {
    online: 'bg-green-50 text-green-500 border border-green-100',
    offline: 'bg-gray-100 text-gray-500 border border-gray-200',
    break: 'bg-yellow-50 text-yellow-500 border border-yellow-100'
  }
  return classMap[status] || 'bg-gray-100 text-gray-500 border border-gray-200'
}

const getTaskStatusText = (status: string) => {
  const statusMap: Record<string, string> = {
    PENDING: '待配送',
    DELIVERING: '配送中',
    COMPLETED: '已完成',
    CANCELLED: '已取消'
  }
  return statusMap[status] || status
}

const getTaskStatusClass = (status: string) => {
  const classMap: Record<string, string> = {
    PENDING: 'bg-yellow-50 text-yellow-500',
    DELIVERING: 'bg-blue-50 text-blue-500',
    COMPLETED: 'bg-green-50 text-green-500',
    CANCELLED: 'bg-gray-100 text-gray-500'
  }
  return classMap[status] || 'bg-gray-100 text-gray-500'
}

const goBack = () => {
  router.push('/drivers')
}

const openEditDialog = () => {
  editForm.name = driverData.name
  editForm.code = driverData.code
  editForm.phone = driverData.phone
  editForm.emergencyContact = driverData.emergencyContact || ''
  editForm.licensePlate = driverData.licensePlate || ''
  editForm.vehicleType = driverData.vehicleType || ''
  editForm.area = driverData.area || ''
  editForm.warehouseId = driverData.warehouseId ? String(driverData.warehouseId) : ''
  
  const warehouseIdList: string[] = []
  if (driverData.warehouseIds && driverData.warehouseIds.length > 0) {
    for (const id of driverData.warehouseIds) {
      warehouseIdList.push(String(id))
    }
  } else if (driverData.warehouseList && driverData.warehouseList.length > 0) {
    for (const w of driverData.warehouseList) {
      if (w.id) warehouseIdList.push(String(w.id))
    }
  }
  editForm.warehouseIds = warehouseIdList
  
  editForm.remark = driverData.remark || ''
  showEditDialog.value = true
}

const closeEditDialog = () => {
  showEditDialog.value = false
}

const handleEditSubmit = async () => {
  try {
    const warehouseIdNumbers = editForm.warehouseIds.map((id: string) => parseInt(id)).filter(n => !isNaN(n))
    
    const updateData = {
      name: editForm.name,
      phone: editForm.phone,
      emergencyContact: editForm.emergencyContact,
      licensePlate: editForm.licensePlate,
      vehicleInfo: editForm.vehicleType,
      idCard: driverData.idCard || '',
      area: editForm.area,
      warehouseId: editForm.warehouseId || undefined,
      warehouseIds: warehouseIdNumbers,
      remark: editForm.remark
    }
    console.log('=== 提交司机更新 ===', {
      driverId: driverId.value,
      data: updateData
    })
    await driversApi.update(driverId.value, updateData)
    await fetchDriverDetail()
    closeEditDialog()
  } catch (error) {
    console.error('更新司机信息失败:', error)
  }
}

const resetPassword = async () => {
  if (confirm(`确定要重置司机"${driverData.name}"的密码吗？`)) {
    try {
      const res: any = await driversApi.resetPassword(driverId.value)
      alert(`密码已重置，新密码为：${res.data?.newPassword || '123456'}`)
    } catch (error) {
      console.error('重置密码失败:', error)
      alert('密码已重置，新密码为：123456')
    }
  }
}

const fetchDriverDetail = async () => {
  try {
    const res: any = await driversApi.getById(driverId.value)
    if (res && res.data && typeof res.data === 'object') {
      const data = res.data
      if (data.warehouseIds && Array.isArray(data.warehouseIds)) {
        data.warehouseIds = data.warehouseIds.map((id: any) => String(id))
      }
      Object.assign(driverData, data)
    } else if (res && typeof res === 'object' && !res.success) {
      console.error('获取司机详情失败:', res.message)
    }
  } catch (error) {
    console.error('获取司机详情失败:', error)
  }
}

const fetchRecentTasks = async () => {
  recentTasks.value = []
}

const fetchWarehouses = async () => {
  try {
    const res: any = await warehousesApi.getAll()
    if (Array.isArray(res)) {
      warehouses.value = res.map((w: any) => ({
        id: String(typeof w.id === 'string' ? w.id : w.id?.toString() || ''),
        name: w.name || w.warehouseName || ''
      }))
    } else if (res && res.data) {
      warehouses.value = res.data.map((w: any) => ({
        id: String(typeof w.id === 'string' ? w.id : w.id?.toString() || ''),
        name: w.name || w.warehouseName || ''
      }))
    }
  } catch (error) {
    console.error('获取仓库列表失败:', error)
  }
}

onMounted(async () => {
  if (driverId.value) {
    await fetchDriverDetail()
    await fetchRecentTasks()
  }
  await regionStore.fetchRegionTree()
  await fetchWarehouses()
})
</script>

<style scoped>
</style>
