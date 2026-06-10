<template>
  <div>
    <div class="flex items-center gap-4 mb-6">
      <button @click="goBack" class="text-gray-500 hover:text-blue-500">
        <Icon icon="mdi:chevron-left" class="text-2xl" />
      </button>
      <h2 class="text-xl font-bold text-gray-800">导出财务报表</h2>
      <nav class="flex text-sm text-gray-400 ml-4">
        <router-link to="/finance" class="hover:text-blue-500">财务管理</router-link>
        <span class="mx-2">/</span>
        <span class="text-gray-600">导出报表</span>
      </nav>
    </div>

    <div class="max-w-4xl">
      <el-card shadow="never">
        <template #header>
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 bg-blue-50 rounded-xl flex items-center justify-center">
              <Icon class="text-2xl text-blue-500" icon="mdi:file-export-outline" />
            </div>
            <div>
              <h3 class="font-bold text-gray-800">导出财务报表</h3>
              <p class="text-xs text-gray-400 mt-1">选择报表类型并设置导出参数</p>
            </div>
          </div>
        </template>

        <el-form :model="exportForm" label-width="120px" class="export-form">
          <el-form-item label="报表类型" required>
            <el-radio-group v-model="exportForm.reportType" class="report-type-group">
              <el-radio value="receivable">
                <div class="flex items-center gap-2">
                  <Icon class="text-blue-500" icon="mdi:file-document-outline" />
                  <div>
                    <p class="font-bold">应收款报表</p>
                    <p class="text-xs text-gray-400">统计各水站应收款项明细</p>
                  </div>
                </div>
              </el-radio>
              <el-radio value="predeposit">
                <div class="flex items-center gap-2">
                  <Icon class="text-green-500" icon="mdi:wallet-outline" />
                  <div>
                    <p class="font-bold">预存金报表</p>
                    <p class="text-xs text-gray-400">统计各水站预存金余额</p>
                  </div>
                </div>
              </el-radio>
              <el-radio value="settlement">
                <div class="flex items-center gap-2">
                  <Icon class="text-purple-500" icon="mdi:calculator" />
                  <div>
                    <p class="font-bold">结算报表</p>
                    <p class="text-xs text-gray-400">水站与水厂结算明细</p>
                  </div>
                </div>
              </el-radio>
              <el-radio value="comprehensive">
                <div class="flex items-center gap-2">
                  <Icon class="text-orange-500" icon="mdi:chart-box-outline" />
                  <div>
                    <p class="font-bold">综合报表</p>
                    <p class="text-xs text-gray-400">包含所有财务数据汇总</p>
                  </div>
                </div>
              </el-radio>
            </el-radio-group>
          </el-form-item>

          <el-row :gutter="20">
            <el-col :span="12">
              <el-form-item label="开始日期" required>
                <el-date-picker
                  v-model="exportForm.startDate"
                  type="date"
                  placeholder="选择开始日期"
                  style="width: 100%"
                  format="YYYY-MM-DD"
                  value-format="YYYY-MM-DD"
                />
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="结束日期" required>
                <el-date-picker
                  v-model="exportForm.endDate"
                  type="date"
                  placeholder="选择结束日期"
                  style="width: 100%"
                  format="YYYY-MM-DD"
                  value-format="YYYY-MM-DD"
                />
              </el-form-item>
            </el-col>
          </el-row>

          <el-form-item label="筛选条件">
            <el-row :gutter="16">
              <el-col :span="8">
                <el-select v-model="exportForm.stationId" placeholder="全部水站" clearable style="width: 100%">
                  <el-option
                    v-for="station in stations"
                    :key="station.id"
                    :value="station.id"
                    :label="station.name"
                  />
                </el-select>
              </el-col>
              <el-col :span="8">
                <el-select v-model="exportForm.paymentType" placeholder="全部类型" clearable style="width: 100%">
                  <el-option value="immediate" label="现结" />
                  <el-option value="monthly" label="月结" />
                  <el-option value="quarterly" label="季结" />
                </el-select>
              </el-col>
              <el-col :span="8">
                <el-select v-model="exportForm.status" placeholder="全部状态" clearable style="width: 100%">
                  <el-option value="paid" label="已结清" />
                  <el-option value="pending" label="待付款" />
                  <el-option value="overdue" label="已逾期" />
                </el-select>
              </el-col>
            </el-row>
          </el-form-item>

          <el-form-item label="导出格式" required>
            <el-radio-group v-model="exportForm.format">
              <el-radio value="excel">
                <div class="flex items-center gap-2">
                  <Icon class="text-green-500" icon="mdi:file-excel" />
                  <span>Excel (.xlsx)</span>
                </div>
              </el-radio>
              <el-radio value="pdf">
                <div class="flex items-center gap-2">
                  <Icon class="text-red-500" icon="mdi:file-pdf-box" />
                  <span>PDF (.pdf)</span>
                </div>
              </el-radio>
              <el-radio value="csv">
                <div class="flex items-center gap-2">
                  <Icon class="text-blue-500" icon="mdi:file-delimited" />
                  <span>CSV (.csv)</span>
                </div>
              </el-radio>
            </el-radio-group>
          </el-form-item>

          <el-form-item>
            <el-checkbox v-model="exportForm.includeDetails">包含明细数据</el-checkbox>
          </el-form-item>

          <el-divider />

          <div class="preview-section">
            <h4 class="font-bold text-gray-800 mb-4">导出预览</h4>
            <div class="preview-content">
              <div class="preview-item">
                <Icon class="text-blue-500" icon="mdi:file-document-outline" />
                <div>
                  <p class="font-bold text-gray-800">{{ getReportTypeName() }}</p>
                  <p class="text-xs text-gray-400">
                    {{ exportForm.startDate || '开始日期' }} 至 {{ exportForm.endDate || '结束日期' }}
                  </p>
                </div>
              </div>
              <div class="preview-meta">
                <div class="meta-item">
                  <span class="label">导出格式：</span>
                  <span class="value">{{ getFormatName() }}</span>
                </div>
                <div class="meta-item">
                  <span class="label">包含明细：</span>
                  <span class="value">{{ exportForm.includeDetails ? '是' : '否' }}</span>
                </div>
              </div>
            </div>
          </div>

          <div class="form-actions">
            <el-button @click="goBack">取消</el-button>
            <el-button type="primary" :loading="exporting" @click="handleExport">
              <Icon v-if="!exporting" icon="mdi:download" />
              {{ exporting ? '导出中...' : '确认导出' }}
            </el-button>
          </div>
        </el-form>
      </el-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Icon } from '@iconify/vue'
import { stationsApi } from '@/api/stations'
import { exportApi, downloadBlob } from '@/api/export'

const router = useRouter()

const exporting = ref(false)

const exportForm = ref({
  reportType: 'receivable',
  startDate: '',
  endDate: '',
  stationId: '',
  paymentType: '',
  status: '',
  format: 'excel',
  includeDetails: true
})

const stations = ref<any[]>([])

const getReportTypeName = () => {
  const map: Record<string, string> = {
    receivable: '应收款报表',
    predeposit: '预存金报表',
    settlement: '结算报表',
    comprehensive: '综合报表'
  }
  return map[exportForm.value.reportType] || '未知报表'
}

const getFormatName = () => {
  const map: Record<string, string> = {
    excel: 'Excel (.xlsx)',
    pdf: 'PDF (.pdf)',
    csv: 'CSV (.csv)'
  }
  return map[exportForm.value.format] || '未知格式'
}

const loadStations = async () => {
  try {
    const res: any = await stationsApi.getAll()
    if (Array.isArray(res)) {
      stations.value = res
    }
  } catch (error) {
    console.error('获取水站列表失败:', error)
    stations.value = []
  }
}

const goBack = () => {
  router.push('/finance')
}

const handleExport = async () => {
  exporting.value = true

  try {
    let blob: Blob | null = null
    let filename = ''

    switch (exportForm.value.reportType) {
      case 'receivable':
        const receivableRes: any = await exportApi.exportReceivables({
          startDate: exportForm.value.startDate || undefined,
          endDate: exportForm.value.endDate || undefined,
          stationId: exportForm.value.stationId || undefined
        })
        blob = receivableRes?.data || receivableRes
        filename = `应收款报表_${exportForm.value.startDate || '全部'}_${exportForm.value.endDate || '至今'}.xlsx`
        break

      case 'predeposit':
        const predepositRes: any = await exportApi.exportPredeposits({
          stationId: exportForm.value.stationId || undefined
        })
        blob = predepositRes?.data || predepositRes
        filename = `预存款报表_${new Date().toISOString().split('T')[0]}.xlsx`
        break

      case 'settlement':
        const settlementRes: any = await exportApi.exportDriverDeliveryReport({
          startDate: exportForm.value.startDate || undefined,
          endDate: exportForm.value.endDate || undefined
        })
        blob = settlementRes?.data || settlementRes
        filename = `结算报表_${exportForm.value.startDate || '全部'}_${exportForm.value.endDate || '至今'}.xlsx`
        break

      case 'comprehensive':
        const comprehensiveRes: any = await exportApi.exportStationPurchaseReport({
          startDate: exportForm.value.startDate || undefined,
          endDate: exportForm.value.endDate || undefined,
          stationId: exportForm.value.stationId || undefined
        })
        blob = comprehensiveRes?.data || comprehensiveRes
        filename = `综合报表_${exportForm.value.startDate || '全部'}_${exportForm.value.endDate || '至今'}.xlsx`
        break

      default:
        ElMessage.error('不支持的报表类型')
        return
    }

    if (blob && blob instanceof Blob && blob.size > 0) {
      downloadBlob(blob, filename)
      ElMessage.success('导出成功')
    } else {
      ElMessage.error('导出失败，请重试')
    }
  } catch (error) {
    console.error('导出报表失败:', error)
    ElMessage.error('导出报表失败')
  } finally {
    exporting.value = false
  }
}

onMounted(() => {
  loadStations()

  const now = new Date()
  const firstDay = new Date(now.getFullYear(), now.getMonth(), 1)
  exportForm.value.startDate = firstDay.toISOString().split('T')[0]
  exportForm.value.endDate = now.toISOString().split('T')[0]
})
</script>

<style scoped>
.export-form {
  @apply space-y-6;
}

.report-type-group {
  @apply flex flex-col gap-4;
}

.report-type-group :deep(.el-radio) {
  @apply border border-gray-200 rounded-lg p-4 hover:bg-gray-50 transition-colors;
  @apply flex items-start;
  margin-right: 0;
}

.report-type-group :deep(.el-radio.is-checked) {
  @apply border-blue-500 bg-blue-50;
}

.export-form :deep(.el-form-item__label) {
  @apply font-bold;
}

.preview-section {
  @apply bg-gray-50 rounded-xl p-6;
}

.preview-content {
  @apply space-y-4;
}

.preview-item {
  @apply flex items-center gap-4 p-4 bg-white rounded-xl;
}

.preview-meta {
  @apply grid grid-cols-2 gap-4;
}

.meta-item {
  @apply flex items-center gap-2;
}

.meta-item .label {
  @apply text-sm text-gray-400;
}

.meta-item .value {
  @apply text-sm font-bold text-gray-800;
}

.form-actions {
  @apply flex justify-end gap-4 pt-6;
}
</style>
