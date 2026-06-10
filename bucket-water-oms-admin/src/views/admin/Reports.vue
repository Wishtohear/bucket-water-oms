<template>
  <div>
    <!-- 头部控制 -->
    <div class="flex items-center justify-between mb-6">
      <el-radio-group v-model="activeTab" @change="handleTabChange">
        <el-radio-button value="sales">销售统计</el-radio-button>
        <el-radio-button value="stationPurchase">水站进货</el-radio-button>
        <el-radio-button value="driverDelivery">司机配送</el-radio-button>
        <el-radio-button value="bucketSummary">空桶汇总</el-radio-button>
      </el-radio-group>
      <div class="flex gap-4">
        <el-select v-model="selectedMonth" placeholder="全部月份" clearable style="width: 140px" @change="handleMonthChange">
          <el-option value="2026-04" label="2026年4月" />
          <el-option value="2026-03" label="2026年3月" />
          <el-option value="2026-02" label="2026年2月" />
          <el-option value="2026-01" label="2026年1月" />
        </el-select>
        <el-button type="success" plain>
          <el-icon><Download /></el-icon>
          导出报表
        </el-button>
      </div>
    </div>

    <!-- 销售统计 Tab -->
    <div v-show="activeTab === 'sales'" class="space-y-6">
      <el-row :gutter="16">
        <el-col :span="16">
          <el-card shadow="never">
            <template #header>
              <div class="flex justify-between items-center">
                <div>
                  <span class="font-bold text-lg">月度销售趋势</span>
                  <span class="text-sm text-gray-400 ml-2">2026年1月 - 2026年4月</span>
                </div>
                <div class="flex items-center gap-4 text-xs">
                  <div class="flex items-center gap-1">
                    <span class="w-3 h-3 bg-blue-500 rounded-full"></span>
                    销售额
                  </div>
                  <div class="flex items-center gap-1">
                    <span class="w-3 h-3 bg-blue-200 rounded-full"></span>
                    订单量
                  </div>
                </div>
              </div>
            </template>
            <div class="h-64 bg-gray-50 rounded-xl border border-dashed border-gray-200 flex flex-col items-center justify-center">
              <el-icon size="48" class="text-gray-300 mb-2"><DataLine /></el-icon>
              <span class="text-sm text-gray-300 font-bold">销售趋势折线图数据加载中...</span>
            </div>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card shadow="never">
            <template #header>
              <div>
                <span class="font-bold text-lg">产品销量构成</span>
                <span class="text-sm text-gray-400 ml-2">按品类统计占比</span>
              </div>
            </template>
            <div class="h-48 relative flex items-center justify-center mb-6">
              <div class="w-40 h-40 rounded-full border-[12px] border-blue-500 border-l-blue-200 border-b-blue-300 border-r-blue-400"></div>
              <div class="absolute flex flex-col items-center">
                <span class="text-2xl font-bold">{{ formatQuantity(totalProductQuantity) }}</span>
                <span class="text-[10px] text-gray-400">总销量(桶)</span>
              </div>
            </div>
            <div class="space-y-3">
              <div
                v-for="(product, index) in reportStore.productSales"
                :key="product.productId"
                class="flex items-center justify-between text-xs"
              >
                <div class="flex items-center gap-2">
                  <span class="w-2 h-2 rounded-full" :class="productColors[index % productColors.length]"></span>
                  <span class="text-gray-600">{{ product.productName }}</span>
                </div>
                <span class="font-bold">{{ calculatePercentage(product.quantity, totalProductQuantity) }}%</span>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>

      <el-row :gutter="16">
        <el-col :span="8">
          <el-card shadow="never">
            <template #header>
              <div class="flex justify-between items-center">
                <span class="font-bold text-lg">水站订货排行</span>
                <el-tag type="info" size="small">TOP 5</el-tag>
              </div>
            </template>
            <div class="space-y-6">
              <div
                v-for="(station, index) in reportStore.stationRanking"
                :key="station.stationId"
                class="flex items-center gap-4"
              >
                <div
                  class="w-8 h-8 rounded-lg flex items-center justify-center font-bold text-white"
                  :class="getRankClass(index)"
                >
                  {{ index + 1 }}
                </div>
                <div class="flex-1">
                  <p class="text-sm font-bold text-gray-800">{{ station.stationName }}</p>
                  <el-progress :percentage="calculateStationPercentage(station.totalAmount)" :show-text="false" :stroke-width="6" />
                </div>
                <span class="text-xs font-bold text-gray-800">¥ {{ formatAmount(station.totalAmount) }}</span>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="16">
          <el-card shadow="never">
            <template #header>
              <div class="flex justify-between items-center">
                <span class="font-bold text-lg">销售明细日报</span>
                <el-button type="primary" link size="small">
                  <el-icon><Download /></el-icon>
                  下载完整数据
                </el-button>
              </div>
            </template>
            <el-table :data="reportStore.dailySales" stripe>
              <el-table-column label="日期" prop="date" width="120" />
              <el-table-column label="订货桶数" width="100" align="right">
                <template #default="{ row }">
                  {{ formatQuantity(row.buckets) }}
                </template>
              </el-table-column>
              <el-table-column label="空桶回收" width="100" align="right">
                <template #default="{ row }">
                  {{ formatQuantity(row.returned) }}
                </template>
              </el-table-column>
              <el-table-column label="销售金额" width="120" align="right">
                <template #default="{ row }">
                  <span class="font-bold">¥ {{ formatAmount(row.amount) }}</span>
                </template>
              </el-table-column>
              <el-table-column label="新增水站" prop="newStations" width="100" align="right" />
            </el-table>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- 水站进货 Tab -->
    <div v-show="activeTab === 'stationPurchase'" class="space-y-6">
      <el-card shadow="never">
        <template #header>
          <div class="flex justify-between items-center">
            <div>
              <span class="font-bold text-lg">水站进货统计</span>
              <span class="text-sm text-gray-400 ml-2">按月份统计每个水站各产品进货量、金额</span>
            </div>
            <el-button type="success" plain :loading="exportLoading" @click="exportReport('stationPurchase')">
              <el-icon><Download /></el-icon>
              导出Excel
            </el-button>
          </div>
        </template>
        <el-table :data="stationPurchaseData" stripe v-loading="stationPurchaseLoading">
          <el-table-column label="水站名称" min-width="200">
            <template #default="{ row }">
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 bg-blue-50 rounded-lg flex items-center justify-center text-blue-500">
                  <el-icon size="20"><Shop /></el-icon>
                </div>
                <div>
                  <p class="text-sm font-bold">{{ row.stationName }}</p>
                  <p class="text-xs text-gray-400">{{ row.stationCode }}</p>
                </div>
              </div>
            </template>
          </el-table-column>
          <el-table-column label="区域" width="100" prop="area" />
          <el-table-column label="桶装水(18L)" width="140" align="right">
            <template #default="{ row }">
              <div>
                <span class="font-bold">{{ (row.bucketWaterQty || 0).toLocaleString() }}</span>
                <span class="text-gray-400 text-xs ml-1">桶</span>
              </div>
              <div class="text-xs text-gray-400">¥ {{ (row.bucketWaterAmount || 0).toLocaleString() }}</div>
            </template>
          </el-table-column>
          <el-table-column label="瓶装水" width="140" align="right">
            <template #default="{ row }">
              <div>
                <span class="font-bold">{{ (row.bottleWaterQty || 0).toLocaleString() }}</span>
                <span class="text-gray-400 text-xs ml-1">箱</span>
              </div>
              <div class="text-xs text-gray-400">¥ {{ (row.bottleWaterAmount || 0).toLocaleString() }}</div>
            </template>
          </el-table-column>
          <el-table-column label="其他商品" width="120" align="right">
            <template #default="{ row }">
              <span class="font-bold">¥ {{ (row.otherAmount || 0).toLocaleString() }}</span>
            </template>
          </el-table-column>
          <el-table-column label="进货总额" width="120" align="right">
            <template #default="{ row }">
              <span class="text-sm font-bold text-blue-600">¥ {{ (row.totalAmount || 0).toLocaleString() }}</span>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="100" align="center">
            <template #default>
              <el-button type="primary" link>查看详情</el-button>
            </template>
          </el-table-column>
          <template #empty>
            <el-empty description="暂无数据" />
          </template>
        </el-table>
      </el-card>
    </div>

    <!-- 司机配送 Tab -->
    <div v-show="activeTab === 'driverDelivery'" class="space-y-6">
      <el-row :gutter="16">
        <el-col :span="6">
          <el-card shadow="never">
            <p class="text-xs font-bold text-gray-400 uppercase mb-2">本月配送单数</p>
            <h3 class="text-2xl font-bold text-gray-800">{{ driverStats.totalOrders }} 单</h3>
            <div class="mt-2 flex items-center gap-2">
              <el-tag type="success" size="small">+12.5%</el-tag>
              <span class="text-gray-400 text-xs">较上月</span>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card shadow="never">
            <p class="text-xs font-bold text-gray-400 uppercase mb-2">本月配送桶数</p>
            <h3 class="text-2xl font-bold text-gray-800">{{ (driverStats.totalBuckets || 0).toLocaleString() }} 桶</h3>
            <div class="mt-2 flex items-center gap-2">
              <el-tag type="success" size="small">+8.3%</el-tag>
              <span class="text-gray-400 text-xs">较上月</span>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card shadow="never">
            <p class="text-xs font-bold text-gray-400 uppercase mb-2">总行驶里程</p>
            <h3 class="text-2xl font-bold text-gray-800">{{ (driverStats.totalMileage || 0).toLocaleString() }} km</h3>
            <div class="mt-2 flex items-center gap-2">
              <el-tag type="warning" size="small">平均 {{ driverStats.avgMileage || 0 }} km/单</el-tag>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card shadow="never">
            <p class="text-xs font-bold text-gray-400 uppercase mb-2">准时送达率</p>
            <h3 class="text-2xl font-bold text-green-500">{{ driverStats.onTimeRate || 0 }}%</h3>
            <div class="mt-2 flex items-center gap-2">
              <el-tag type="success" size="small">达标</el-tag>
            </div>
          </el-card>
        </el-col>
      </el-row>

      <el-card shadow="never">
        <template #header>
          <div class="flex justify-between items-center">
            <div>
              <span class="font-bold text-lg">司机配送明细</span>
              <span class="text-sm text-gray-400 ml-2">按月份统计每个司机配送单数、桶数、里程</span>
            </div>
            <el-button type="success" plain :loading="exportLoading" @click="exportReport('driverDelivery')">
              <el-icon><Download /></el-icon>
              导出Excel
            </el-button>
          </div>
        </template>
        <el-table :data="driverDeliveryData" stripe v-loading="driverLoading">
          <el-table-column label="司机信息" min-width="180">
            <template #default="{ row }">
              <div class="flex items-center gap-3">
                <el-avatar :src="'https://picsum.photos/200'" :size="40" />
                <div>
                  <p class="text-sm font-bold">{{ row.driverName }}</p>
                  <p class="text-xs text-gray-400">{{ row.driverCode }}</p>
                </div>
              </div>
            </template>
          </el-table-column>
          <el-table-column label="负责区域" width="100">
            <template #default="{ row }">
              <el-tag size="small">{{ row.area }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="配送单数" width="100" align="right" prop="orders" />
          <el-table-column label="配送桶数" width="120" align="right">
            <template #default="{ row }">
              <span class="font-bold">{{ (row.buckets || 0).toLocaleString() }}</span>
              <span class="text-gray-400 text-xs ml-1">桶</span>
            </template>
          </el-table-column>
          <el-table-column label="行驶里程" width="120" align="right">
            <template #default="{ row }">
              <span class="font-bold">{{ (row.mileage || 0).toLocaleString() }}</span>
              <span class="text-gray-400 text-xs ml-1">km</span>
            </template>
          </el-table-column>
          <el-table-column label="完成金额" width="120" align="right">
            <template #default="{ row }">
              <span class="text-sm font-bold text-blue-600">¥ {{ (row.amount || 0).toLocaleString() }}</span>
            </template>
          </el-table-column>
          <el-table-column label="准时率" width="100" align="center">
            <template #default="{ row }">
              <el-tag :type="(row.onTimeRate || 0) >= 95 ? 'success' : 'warning'" size="small">
                {{ row.onTimeRate || 0 }}%
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="100" align="center">
            <template #default>
              <el-button type="primary" link>查看详情</el-button>
            </template>
          </el-table-column>
          <template #empty>
            <el-empty description="暂无数据" />
          </template>
        </el-table>
      </el-card>
    </div>

    <!-- 空桶汇总 Tab -->
    <div v-show="activeTab === 'bucketSummary'" class="space-y-6">
      <el-row :gutter="16">
        <el-col :span="8">
          <el-card shadow="never">
            <p class="text-xs font-bold text-gray-400 uppercase mb-2">各水站欠桶总数</p>
            <h3 class="text-2xl font-bold text-orange-500">{{ (bucketStats.owedBucketsTotal || 0).toLocaleString() }} 个</h3>
            <div class="mt-2 flex items-center gap-2">
              <el-tag type="warning" size="small">{{ bucketStats.owedStations || 0 }} 家水站</el-tag>
              <span class="text-gray-400 text-xs">涉及欠桶</span>
            </div>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card shadow="never">
            <p class="text-xs font-bold text-gray-400 uppercase mb-2">仓库空桶库存</p>
            <h3 class="text-2xl font-bold text-blue-500">{{ (bucketStats.warehouseStock || 0).toLocaleString() }} 个</h3>
            <div class="mt-2 flex items-center gap-2">
              <el-tag type="success" size="small">库存充足</el-tag>
            </div>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card shadow="never">
            <p class="text-xs font-bold text-gray-400 uppercase mb-2">在途空桶</p>
            <h3 class="text-2xl font-bold text-purple-500">{{ (bucketStats.inTransit || 0).toLocaleString() }} 个</h3>
            <div class="mt-2 flex items-center gap-2">
              <el-tag type="info" size="small">{{ bucketStats.transitDrivers || 0 }} 位司机</el-tag>
              <span class="text-gray-400 text-xs">未交回</span>
            </div>
          </el-card>
        </el-col>
      </el-row>

      <el-row :gutter="16">
        <el-col :span="12">
          <el-card shadow="never">
            <template #header>
              <span class="font-bold">水站欠桶明细</span>
            </template>
            <el-table :data="stationBucketData" stripe max-height="384">
              <el-table-column label="水站名称" min-width="150">
                <template #default="{ row }">
                  <div>
                    <p class="text-sm font-bold">{{ row.stationName }}</p>
                    <p class="text-xs text-gray-400">{{ row.stationCode }}</p>
                  </div>
                </template>
              </el-table-column>
              <el-table-column label="押金桶数" width="100" align="right" prop="depositBuckets" />
              <el-table-column label="欠桶数量" width="100" align="right">
                <template #default="{ row }">
                  <span :class="(row.owedBuckets || 0) > 0 ? 'text-orange-500 font-bold' : ''">
                    {{ row.owedBuckets || 0 }}
                  </span>
                </template>
              </el-table-column>
              <el-table-column label="状态" width="80">
                <template #default="{ row }">
                  <el-tag :type="(row.owedBuckets || 0) >= (row.threshold || 0) ? 'danger' : 'success'" size="small">
                    {{ (row.owedBuckets || 0) >= (row.threshold || 0) ? '需补缴' : '正常' }}
                  </el-tag>
                </template>
              </el-table-column>
            </el-table>
          </el-card>
        </el-col>
        <el-col :span="12">
          <el-card shadow="never">
            <template #header>
              <span class="font-bold">仓库空桶库存</span>
            </template>
            <el-table :data="warehouseBucketData" stripe max-height="384">
              <el-table-column label="仓库名称" min-width="150">
                <template #default="{ row }">
                  <div class="flex items-center gap-2">
                    <div class="w-8 h-8 bg-blue-50 rounded flex items-center justify-center text-blue-500">
                      <el-icon><HomeFilled /></el-icon>
                    </div>
                    <div>
                      <p class="text-sm font-bold">{{ row.warehouseName }}</p>
                      <p class="text-xs text-gray-400">{{ row.warehouseType }}</p>
                    </div>
                  </div>
                </template>
              </el-table-column>
              <el-table-column label="可用库存" width="120" align="right">
                <template #default="{ row }">
                  <span class="text-sm font-bold text-blue-600">{{ (row.availableStock || 0).toLocaleString() }}</span>
                  <span class="text-gray-400 text-xs ml-1">个</span>
                </template>
              </el-table-column>
              <el-table-column label="周转中" width="100" align="right">
                <template #default="{ row }">
                  <span>{{ (row.inTransit || 0).toLocaleString() }}</span>
                  <span class="text-gray-400 text-xs ml-1">个</span>
                </template>
              </el-table-column>
              <el-table-column label="状态" width="80">
                <template #default="{ row }">
                  <el-tag :type="(row.availableStock || 0) < 500 ? 'warning' : 'success'" size="small">
                    {{ (row.availableStock || 0) < 500 ? '库存紧张' : '库存充足' }}
                  </el-tag>
                </template>
              </el-table-column>
            </el-table>
          </el-card>
        </el-col>
      </el-row>

      <el-card shadow="never">
        <template #header>
          <div class="flex justify-between items-center">
            <span class="font-bold">在途空桶（司机未交回）</span>
            <el-button type="success" plain :loading="exportLoading" @click="exportReport('inTransitBuckets')">
              <el-icon><Download /></el-icon>
              导出
            </el-button>
          </div>
        </template>
        <el-table :data="inTransitBucketData" stripe v-loading="bucketLoading">
          <el-table-column label="司机" min-width="180">
            <template #default="{ row }">
              <div class="flex items-center gap-3">
                <el-avatar :src="'https://picsum.photos/200'" :size="40" />
                <div>
                  <p class="text-sm font-bold">{{ row.driverName }}</p>
                  <p class="text-xs text-gray-400">{{ row.driverCode }}</p>
                </div>
              </div>
            </template>
          </el-table-column>
          <el-table-column label="联系方式" width="120" prop="phone" />
          <el-table-column label="负责区域" width="100" prop="area" />
          <el-table-column label="在途空桶" width="120" align="right">
            <template #default="{ row }">
              <span class="text-sm font-bold text-purple-600">{{ row.inTransitBuckets || 0 }}</span>
              <span class="text-gray-400 text-xs ml-1">个</span>
            </template>
          </el-table-column>
          <el-table-column label="最后交桶时间" width="160" prop="lastReturnTime" />
          <el-table-column label="操作" width="100" align="center">
            <template #default>
              <el-button type="primary" link>联系司机</el-button>
            </template>
          </el-table-column>
          <template #empty>
            <el-empty description="暂无数据" />
          </template>
        </el-table>
      </el-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import {
  Download, DataLine, Shop, HomeFilled
} from '@element-plus/icons-vue'
import { useReportStore } from '@/stores/reports'
import { reportsApi } from '@/api/reports'
import type { ProductSales, StationRanking, StationPurchaseReport, DriverDeliveryReport, DriverStatsSummary } from '@/api/reports'
import { ElMessage } from 'element-plus'

const reportStore = useReportStore()

const activeTab = ref('sales')
const selectedMonth = ref('')
const exportLoading = ref(false)

const productColors = ['bg-blue-500', 'bg-blue-400', 'bg-blue-300', 'bg-blue-200']

const totalProductQuantity = computed(() => {
  return reportStore.productSales.reduce((sum: number, product: ProductSales) => sum + (product.quantity || 0), 0)
})

const maxStationAmount = computed(() => {
  if (reportStore.stationRanking.length === 0) return 0
  return Math.max(...reportStore.stationRanking.map((s: StationRanking) => s.totalAmount || 0))
})

const formatQuantity = (value: number | undefined): string => {
  if (!value) return '0'
  if (value >= 1000) {
    return (value / 1000).toFixed(1).replace(/\.0$/, '') + 'k'
  }
  return value.toLocaleString()
}

const formatAmount = (value: number | undefined): string => {
  if (!value) return '0'
  if (value >= 1000) {
    return (value / 1000).toFixed(1).replace(/\.0$/, '') + 'k'
  }
  return value.toLocaleString()
}

const calculatePercentage = (value: number, total: number): string => {
  if (!total) return '0'
  return ((value / total) * 100).toFixed(0)
}

const calculateStationPercentage = (amount: number | undefined): number => {
  if (!amount || !maxStationAmount.value) return 0
  return ((amount / maxStationAmount.value) * 100)
}

const getRankClass = (index: number) => {
  if (index === 0) return 'bg-yellow-400'
  if (index === 1) return 'bg-gray-300'
  if (index === 2) return 'bg-orange-300'
  return 'bg-blue-50 text-blue-400'
}

// 水站进货数据
const stationPurchaseData = ref<StationPurchaseReport[]>([])
const stationPurchaseLoading = ref(false)

// 司机配送数据
const driverStats = ref<DriverStatsSummary>({
  totalOrders: 0,
  totalBuckets: 0,
  totalMileage: 0,
  avgMileage: 0,
  onTimeRate: 0
})
const driverDeliveryData = ref<DriverDeliveryReport[]>([])
const driverLoading = ref(false)

// 空桶汇总数据
const bucketStats = computed(() => reportStore.bucketSummary || {
  owedBucketsTotal: 0,
  owedStations: 0,
  warehouseStock: 0,
  inTransit: 0,
  transitDrivers: 0
})
const stationBucketData = computed(() => reportStore.stationBucketReport || [])
const warehouseBucketData = computed(() => reportStore.warehouseBucketReport || [])
const inTransitBucketData = computed(() => reportStore.inTransitBuckets || [])
const bucketLoading = ref(false)

// 获取水站进货数据
const fetchStationPurchaseData = async () => {
  stationPurchaseLoading.value = true
  try {
    const res: any = await reportsApi.getStationPurchaseReport({
      startDate: selectedMonth.value ? `${selectedMonth.value}-01` : undefined
    })
    if (Array.isArray(res)) {
      stationPurchaseData.value = res
    } else {
      stationPurchaseData.value = []
    }
  } catch (error) {
    console.error('获取水站进货报表失败:', error)
    stationPurchaseData.value = []
  } finally {
    stationPurchaseLoading.value = false
  }
}

// 获取司机配送数据
const fetchDriverDeliveryData = async () => {
  driverLoading.value = true
  try {
    const [statsRes, deliveryRes] = await Promise.all([
      reportsApi.getDriverStatsSummary({
        startDate: selectedMonth.value ? `${selectedMonth.value}-01` : undefined
      }),
      reportsApi.getDriverDeliveryReport({
        startDate: selectedMonth.value ? `${selectedMonth.value}-01` : undefined
      })
    ])
    if (statsRes.data) {
      driverStats.value = statsRes.data
    }
    if (deliveryRes.data) {
      driverDeliveryData.value = deliveryRes.data
    } else {
      driverDeliveryData.value = []
    }
  } catch (error) {
    console.error('获取司机配送报表失败:', error)
    driverDeliveryData.value = []
  } finally {
    driverLoading.value = false
  }
}

// 获取空桶汇总数据
const fetchBucketSummaryData = async () => {
  bucketLoading.value = true
  try {
    await Promise.all([
      reportStore.fetchBucketStatsSummary(),
      reportStore.fetchStationBucketReport(),
      reportStore.fetchWarehouseBucketReport(),
      reportStore.fetchInTransitBuckets()
    ])
  } catch (error) {
    console.error('获取空桶汇总数据失败:', error)
  } finally {
    bucketLoading.value = false
  }
}

// 导出报表
const exportReport = async (type: string) => {
  exportLoading.value = true
  try {
    let blob: Blob | null = null
    let filename = ''

    switch (type) {
      case 'stationPurchase':
        blob = await reportsApi.exportStationPurchaseReport({
          startDate: selectedMonth.value ? `${selectedMonth.value}-01` : undefined
        }) as unknown as Blob
        filename = `水站进货报表_${selectedMonth.value || '全部'}.xlsx`
        break
      case 'driverDelivery':
        blob = await reportsApi.exportDriverDeliveryReport({
          startDate: selectedMonth.value ? `${selectedMonth.value}-01` : undefined
        }) as unknown as Blob
        filename = `司机配送报表_${selectedMonth.value || '全部'}.xlsx`
        break
      case 'inTransitBuckets':
        blob = await reportsApi.exportInTransitBuckets() as unknown as Blob
        filename = `在途空桶报表_${new Date().toISOString().split('T')[0]}.xlsx`
        break
    }

    if (blob) {
      const url = window.URL.createObjectURL(blob)
      const link = document.createElement('a')
      link.href = url
      link.download = filename
      document.body.appendChild(link)
      link.click()
      document.body.removeChild(link)
      window.URL.revokeObjectURL(url)
      ElMessage.success('导出成功')
    }
  } catch (error) {
    console.error('导出报表失败:', error)
    ElMessage.error('导出失败，请重试')
  } finally {
    exportLoading.value = false
  }
}

const handleTabChange = async (tab: string) => {
  if (tab === 'stationPurchase') {
    await fetchStationPurchaseData()
  } else if (tab === 'driverDelivery') {
    await fetchDriverDeliveryData()
  } else if (tab === 'bucketSummary') {
    await fetchBucketSummaryData()
  }
}

const handleMonthChange = async () => {
  if (activeTab.value === 'stationPurchase') {
    await fetchStationPurchaseData()
  } else if (activeTab.value === 'driverDelivery') {
    await fetchDriverDeliveryData()
  }
}

onMounted(async () => {
  await Promise.all([
    reportStore.fetchSalesTrend(),
    reportStore.fetchProductSales(),
    reportStore.fetchStationRanking({ limit: 5 }),
    reportStore.fetchDailySales()
  ])
})
</script>

<style scoped>
:deep(.el-card) {
  border-radius: 16px;
}
:deep(.el-table) {
  border-radius: 8px;
}
</style>
