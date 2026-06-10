<template>
  <div class="station-edit-page">
    <el-page-header @back="goBack" class="mb-4">
      <template #content>
        <div class="page-header-content">
          <span class="page-title">{{ isEdit ? '编辑水站' : '新增水站' }}</span>
        </div>
      </template>
    </el-page-header>

    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="card-title">{{ isEdit ? '编辑水站信息' : '新增水站账号' }}</span>
        </div>
      </template>

      <el-form
        ref="formRef"
        :model="formData"
        :rules="rules"
        label-width="120px"
        class="station-form"
      >
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="水站名称" prop="name">
              <el-input v-model="formData.name" placeholder="请输入水站名称" maxlength="50" show-word-limit />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="水站编号">
              <el-input v-model="formData.code" placeholder="系统自动生成" disabled />
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="水站地址" prop="address">
          <el-input v-model="formData.address" placeholder="请输入详细地址" maxlength="200" show-word-limit />
        </el-form-item>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="纬度(DMM)" prop="latDmm">
              <el-input
                v-model="formData.latDmm"
                placeholder="25°16.1234'N 或 25⁰¹⁶.1234'N"
                clearable
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="经度(DMM)" prop="lngDmm">
              <el-input
                v-model="formData.lngDmm"
                placeholder="110°30.5678'E 或 11⁰³⁰.5678'E"
                clearable
              />
            </el-form-item>
          </el-col>
        </el-row>

        <div class="location-tip">
          <el-icon color="#909399"><InfoFilled /></el-icon>
          <span>经纬度使用度十进制分(DMM)格式，如 25°16.1234'N 表示北纬25度16.1234分。支持°符号或角标⁰¹²格式</span>
        </div>

        <el-divider />

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="联系人" prop="contact">
              <el-input v-model="formData.contact" placeholder="请输入联系人姓名" maxlength="20" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="联系电话" prop="phone">
              <el-input v-model="formData.phone" placeholder="请输入联系电话" maxlength="11" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="所属区域">
              <el-select v-model="formData.area" placeholder="请选择区域" style="width: 100%" clearable>
                <el-option
                  v-for="region in regionStore.regionTree"
                  :key="region.code"
                  :label="region.name"
                  :value="region.name"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="负责仓库">
              <el-select v-model="formData.warehouseId" placeholder="请选择仓库" style="width: 100%" clearable>
                <el-option
                  v-for="warehouse in warehouses"
                  :key="warehouse.id"
                  :label="warehouse.name"
                  :value="warehouse.id"
                />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="水站类型">
              <el-select v-model="formData.type" style="width: 100%">
                <el-option label="普通水站" value="normal" />
                <el-option label="VIP水站" value="vip" />
                <el-option label="社区水站" value="community" />
                <el-option label="企业水站" value="enterprise" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="账期类型">
              <el-select v-model="formData.paymentType" style="width: 100%">
                <el-option label="预存金" value="PREPAID" />
                <el-option label="月结" value="MONTHLY" />
                <el-option label="季结" value="QUARTERLY" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <el-divider />

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="预存金余额">
              <el-input-number
                v-model="formData.depositBalance"
                :min="0"
                :precision="2"
                :step="100"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="信用额度">
              <el-input-number
                v-model="formData.creditLimit"
                :min="0"
                :precision="2"
                :step="100"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="欠桶阈值">
              <el-input-number
                v-model="formData.owedThreshold"
                :min="0"
                :max="999"
                :step="5"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="每桶押金">
              <el-input-number
                v-model="formData.bucketDepositAmount"
                :min="0"
                :precision="2"
                :step="1"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
        </el-row>

        <el-divider />

        <el-form-item label="备注说明">
          <el-input
            v-model="formData.remark"
            type="textarea"
            :rows="3"
            maxlength="500"
            show-word-limit
            placeholder="请输入备注信息（选填）..."
          />
        </el-form-item>

        <el-form-item :label="isEdit ? '新密码' : '登录密码'">
          <el-input
            v-model="formData.password"
            type="password"
            show-password
            :placeholder="isEdit ? '请输入新密码(留空则不修改密码)' : '请输入登录密码(留空则使用默认密码123456)'"
          />
        </el-form-item>

        <el-form-item>
          <div class="form-actions">
            <el-button @click="goBack">取消</el-button>
            <el-button type="primary" @click="handleSubmit" :loading="submitting">
              {{ isEdit ? '保存修改' : '确认添加' }}
            </el-button>
          </div>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, FormInstance, FormRules } from 'element-plus'
import { stationsApi } from '@/api/stations'
import { warehousesApi } from '@/api/warehouses'
import { useRegionStore } from '@/stores/regions'

const router = useRouter()
const route = useRoute()
const regionStore = useRegionStore()

const formRef = ref<FormInstance>()
const submitting = ref(false)
const loading = ref(false)

const isEdit = computed(() => !!route.params.id)

interface StationFormData {
  id?: string
  name: string
  code: string
  address: string
  contact: string
  phone: string
  area: string
  warehouseId: string
  type: string
  paymentType: string
  depositBalance: number
  creditLimit: number
  owedThreshold: number
  bucketDepositAmount: number
  remark: string
  password: string
  latDmm: string
  lngDmm: string
}

const formData = reactive<StationFormData>({
  id: '',
  name: '',
  code: '',
  address: '',
  contact: '',
  phone: '',
  area: '',
  warehouseId: '',
  type: 'normal',
  paymentType: 'PREPAID',
  depositBalance: 0,
  creditLimit: 0,
  owedThreshold: 30,
  bucketDepositAmount: 20,
  remark: '',
  password: '',
  latDmm: '',
  lngDmm: ''
})

const warehouses = ref<any[]>([])

const rules: FormRules = {
  name: [
    { required: true, message: '请输入水站名称', trigger: 'blur' },
    { min: 2, max: 50, message: '水站名称长度为 2-50 个字符', trigger: 'blur' }
  ],
  address: [
    { required: true, message: '请输入水站地址', trigger: 'blur' },
    { min: 5, message: '地址至少5个字符', trigger: 'blur' }
  ],
  contact: [
    { required: true, message: '请输入联系人', trigger: 'blur' },
    { min: 2, max: 20, message: '联系人姓名为 2-20 个字符', trigger: 'blur' }
  ],
  phone: [
    { required: true, message: '请输入联系电话', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ],
  latDmm: [
    { pattern: /^\d+[°⁰¹²³⁴⁵⁶⁷⁸⁹]+\d+\.\d+'[NS]$/i, message: '格式: 25°16.1234\'N 或 25⁰¹⁶.1234\'N', trigger: 'blur' }
  ],
  lngDmm: [
    { pattern: /^\d+[°⁰¹²³⁴⁵⁶⁷⁸⁹]+\d+\.\d+'[EW]$/i, message: '格式: 110°30.5678\'E 或 11⁰³⁰.5678\'E', trigger: 'blur' }
  ]
}

const goBack = () => {
  if (isEdit.value) {
    router.push(`/stations/${route.params.id}`)
  } else {
    router.push('/stations')
  }
}

const fetchStationDetail = async () => {
  if (!route.params.id) return

  loading.value = true
  try {
    const res: any = await stationsApi.getDetail(route.params.id as string)
    const data = res.data || res
    if (data && data.id) {
      formData.id = data.id
      formData.name = data.name || ''
      formData.code = data.code || ''
      formData.address = data.address || ''
      formData.contact = data.contact || ''
      formData.phone = data.phone || ''
      formData.area = data.area || ''
      formData.type = data.stationType || data.type || 'normal'
      formData.paymentType = data.paymentType || 'PREPAID'
      formData.depositBalance = data.depositBalance || 0
      formData.creditLimit = data.creditLimit || 0
      formData.owedThreshold = data.owedThreshold || 30
      formData.bucketDepositAmount = data.bucketDepositAmount || 20
      formData.remark = data.remark || ''
      if (data.lat && data.lng) {
        formData.latDmm = formatToDmm(data.lat, true)
        formData.lngDmm = formatToDmm(data.lng, false)
      } else {
        formData.latDmm = ''
        formData.lngDmm = ''
      }
      formData.warehouseId = data.warehouse || ''
    }
  } catch (err: any) {
    console.error('获取水站详情失败:', err)
    ElMessage.error('获取水站详情失败')
  } finally {
    loading.value = false
  }
}

const formatToDmm = (decimalValue: number, isLatitude: boolean): string => {
  if (!decimalValue) return ''
  const value = parseFloat(decimalValue.toString())
  const negative = value < 0
  const absValue = Math.abs(value)
  const degrees = Math.floor(absValue)
  const minutes = (absValue - degrees) * 60
  const direction = isLatitude
    ? (negative ? 'S' : 'N')
    : (negative ? 'W' : 'E')
  return `${degrees}°${minutes.toFixed(4)}'${direction}`
}

const fetchWarehouses = async () => {
  try {
    const res: any = await warehousesApi.getAll()
    if (Array.isArray(res)) {
      warehouses.value = res
    }
  } catch (err: any) {
    console.error('获取仓库列表失败:', err)
  }
}

const handleSubmit = async () => {
  if (!formRef.value) return

  await formRef.value.validate(async (valid) => {
    if (!valid) return

    submitting.value = true
    try {
      const submitData: any = {
        name: formData.name,
        address: formData.address,
        contact: formData.contact,
        phone: formData.phone,
        area: formData.area,
        stationType: formData.type,
        paymentType: formData.paymentType,
        depositBalance: formData.depositBalance,
        creditLimit: formData.creditLimit,
        owedThreshold: formData.owedThreshold,
        bucketDepositAmount: formData.bucketDepositAmount,
        remark: formData.remark
      }

      if (formData.latDmm && formData.latDmm.trim()) {
        submitData.latDmm = formData.latDmm.trim()
      }
      if (formData.lngDmm && formData.lngDmm.trim()) {
        submitData.lngDmm = formData.lngDmm.trim()
      }

      if (formData.warehouseId) {
        submitData.warehouseId = formData.warehouseId
      }

      if (isEdit.value) {
        if (formData.password) {
          submitData.password = formData.password
        }
        await stationsApi.update(formData.id!, submitData)
        ElMessage.success('修改成功')
        router.push(`/stations/${formData.id}`)
      } else {
        if (formData.password) {
          submitData.password = formData.password
        }
        await stationsApi.create(submitData)
        ElMessage.success('添加成功')
        router.push('/stations')
      }
    } catch (err: any) {
      console.error('提交失败:', err)
      ElMessage.error(err.message || '提交失败')
    } finally {
      submitting.value = false
    }
  })
}

onMounted(async () => {
  await Promise.all([
    regionStore.fetchRegionTree(),
    fetchWarehouses()
  ])

  if (isEdit.value) {
    await fetchStationDetail()
  }
})
</script>

<style scoped>
.station-edit-page {
  padding: 0;
  max-width: 900px;
}

.mb-4 {
  margin-bottom: 20px;
}

.page-header-content {
  display: flex;
  align-items: center;
}

.page-title {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.location-tip {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 16px;
  background: #f5f7fa;
  border-radius: 4px;
  margin: -10px 0 10px 120px;
  font-size: 12px;
  color: #909399;
}

.form-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
  width: 100%;
  padding-top: 20px;
  border-top: 1px solid #f0f0f0;
}

.station-form :deep(.el-form-item__label) {
  font-weight: 500;
}

.station-form :deep(.el-input-number) {
  width: 100%;
}
</style>
