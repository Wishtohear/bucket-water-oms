<template>
  <div class="global-reports">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>全局报表</span>
          <el-radio-group v-model="reportType" size="default">
            <el-radio-button label="sales">销售统计</el-radio-button>
            <el-radio-button label="order">订单统计</el-radio-button>
            <el-radio-button label="comparison">水厂对比</el-radio-button>
          </el-radio-group>
        </div>
      </template>

      <div v-if="reportType === 'sales'">
        <el-form :inline="true" :model="searchForm" class="search-form">
          <el-form-item label="时间范围">
            <el-date-picker
              v-model="searchForm.dateRange"
              type="daterange"
              range-separator="至"
              start-placeholder="开始日期"
              end-placeholder="结束日期"
            />
          </el-form-item>
          <el-form-item label="水厂">
            <el-select v-model="searchForm.factoryId" placeholder="请选择水厂" clearable>
              <el-option
                v-for="factory in factories"
                :key="factory.id"
                :label="factory.name"
                :value="factory.id"
              />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="loadSalesData">查询</el-button>
            <el-button @click="handleExport">导出</el-button>
          </el-form-item>
        </el-form>

        <el-row :gutter="20" style="margin-bottom: 20px">
          <el-col :span="6">
            <el-card class="stat-card">
              <div class="stat-value">¥{{ salesStats.totalAmount }}</div>
              <div class="stat-label">销售总额</div>
            </el-card>
          </el-col>
          <el-col :span="6">
            <el-card class="stat-card">
              <div class="stat-value">{{ salesStats.orderCount }}</div>
              <div class="stat-label">订单总数</div>
            </el-card>
          </el-col>
          <el-col :span="6">
            <el-card class="stat-card">
              <div class="stat-value">{{ salesStats.avgOrderAmount }}</div>
              <div class="stat-label">平均订单金额</div>
            </el-card>
          </el-col>
          <el-col :span="6">
            <el-card class="stat-card">
              <div class="stat-value">{{ salesStats.customerCount }}</div>
              <div class="stat-label">客户总数</div>
            </el-card>
          </el-col>
        </el-row>

        <div ref="salesChartRef" style="height: 400px"></div>
      </div>

      <div v-if="reportType === 'order'">
        <el-form :inline="true" :model="searchForm" class="search-form">
          <el-form-item label="时间范围">
            <el-date-picker
              v-model="searchForm.dateRange"
              type="monthrange"
              range-separator="至"
              start-placeholder="开始月份"
              end-placeholder="结束月份"
            />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="loadOrderData">查询</el-button>
            <el-button @click="handleExport">导出</el-button>
          </el-form-item>
        </el-form>

        <el-table :data="orderTableData" stripe style="width: 100%">
          <el-table-column prop="date" label="日期" />
          <el-table-column prop="orderCount" label="订单数" />
          <el-table-column prop="totalAmount" label="销售金额" />
          <el-table-column prop="completedCount" label="已完成" />
          <el-table-column prop="cancelledCount" label="已取消" />
        </el-table>
      </div>

      <div v-if="reportType === 'comparison'">
        <el-form :inline="true" :model="searchForm" class="search-form">
          <el-form-item label="时间范围">
            <el-date-picker
              v-model="searchForm.dateRange"
              type="monthrange"
              range-separator="至"
              start-placeholder="开始月份"
              end-placeholder="结束月份"
            />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="loadComparisonData">查询</el-button>
          </el-form-item>
        </el-form>

        <div ref="comparisonChartRef" style="height: 400px"></div>

        <el-table :data="comparisonTableData" stripe style="width: 100%; margin-top: 20px">
          <el-table-column prop="factoryName" label="水厂名称" />
          <el-table-column prop="orderCount" label="订单数" />
          <el-table-column prop="totalAmount" label="销售金额" />
          <el-table-column prop="avgAmount" label="平均订单金额" />
          <el-table-column prop="rank" label="排名">
            <template #default="{ row }">
              <el-tag :type="row.rank <= 3 ? 'success' : 'info'">第{{ row.rank }}名</el-tag>
            </template>
          </el-table-column>
        </el-table>
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { platformApi } from '../../api/platform'

const reportType = ref('sales')
const salesChartRef = ref<HTMLElement>()
const comparisonChartRef = ref<HTMLElement>()

const searchForm = reactive({
  dateRange: [] as string[],
  factoryId: null as number | null
})

const factories = ref<any[]>([])

const salesStats = reactive({
  totalAmount: 0,
  orderCount: 0,
  avgOrderAmount: 0,
  customerCount: 0
})

const orderTableData = ref<any[]>([])
const comparisonTableData = ref<any[]>([])

const formatDate = (val: any) => {
  if (!val) return undefined
  if (typeof val === 'string') return val
  if (val instanceof Date) return val.toISOString().slice(0, 10)
  return val
}

const loadSalesData = async () => {
  try {
    const response: any = await platformApi.getSalesReport({
      startDate: formatDate(searchForm.dateRange?.[0]),
      endDate: formatDate(searchForm.dateRange?.[1]),
      factoryId: searchForm.factoryId || undefined
    })
    if (response.success) {
      const s = response.data?.stats || {}
      salesStats.totalAmount = s.totalAmount || 0
      salesStats.orderCount = s.orderCount || 0
      salesStats.avgOrderAmount = s.avgOrderAmount || 0
      salesStats.customerCount = s.customerCount || 0
    }
  } catch (error) {
    ElMessage.error('加载销售数据失败')
  }
}

const loadOrderData = async () => {
  try {
    const response: any = await platformApi.getOrderReport({
      startDate: formatDate(searchForm.dateRange?.[0]),
      endDate: formatDate(searchForm.dateRange?.[1])
    })
    if (response.success) {
      orderTableData.value = response.data?.records || []
    }
  } catch (error) {
    ElMessage.error('加载订单数据失败')
  }
}

const loadComparisonData = async () => {
  try {
    const response: any = await platformApi.getComparisonReport({
      startDate: formatDate(searchForm.dateRange?.[0]),
      endDate: formatDate(searchForm.dateRange?.[1])
    })
    if (response.success) {
      comparisonTableData.value = response.data?.records || []
    }
  } catch (error) {
    ElMessage.error('加载对比数据失败')
  }
}

const handleExport = () => {
  ElMessage.info('导出功能开发中')
}

onMounted(async () => {
  try {
    const response: any = await platformApi.getAllFactories({ page: 1, size: 1000 })
    if (response.success) {
      factories.value = response.data?.records || []
    }
  } catch (error) {
    console.error('加载水厂列表失败', error)
  }
})
</script>

<style scoped>
.global-reports {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.search-form {
  margin-bottom: 20px;
}

.stat-card {
  text-align: center;
  padding: 20px;
}

.stat-value {
  font-size: 28px;
  font-weight: bold;
  color: #409EFF;
}

.stat-label {
  font-size: 14px;
  color: #999;
  margin-top: 10px;
}
</style>
