<template>
  <div class="dashboard">
    <el-row :gutter="20">
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background-color: #409EFF">
              <el-icon :size="30"><OfficeBuilding /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.totalFactories }}</div>
              <div class="stat-label">水厂总数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background-color: #67C23A">
              <el-icon :size="30"><Shop /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.totalStations }}</div>
              <div class="stat-label">水站总数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background-color: #E6A23C">
              <el-icon :size="30"><Van /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.totalDrivers }}</div>
              <div class="stat-label">司机总数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background-color: #F56C6C">
              <el-icon :size="30"><Goods /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.totalOrders }}</div>
              <div class="stat-label">订单总数</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px">
      <el-col :span="12">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>各水厂订单量对比</span>
            </div>
          </template>
          <div ref="factoryChartRef" style="height: 300px"></div>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>近7天订单趋势</span>
            </div>
          </template>
          <div ref="orderTrendChartRef" style="height: 300px"></div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px">
      <el-col :span="24">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>水厂列表</span>
              <el-button type="primary" @click="router.push('/factories')">查看全部</el-button>
            </div>
          </template>
          <el-table :data="factories" style="width: 100%">
            <el-table-column prop="name" label="水厂名称" />
            <el-table-column prop="code" label="水厂编码" />
            <el-table-column prop="contact" label="联系人" />
            <el-table-column prop="phone" label="联系电话" />
            <el-table-column prop="status" label="状态">
              <template #default="{ row }">
                <el-tag :type="row.status === 'ACTIVE' ? 'success' : 'danger'">
                  {{ row.status === 'ACTIVE' ? '启用' : '停用' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="120">
              <template #default="{ row }">
                <el-button type="primary" link @click="router.push(`/factories/${row.id}`)">
                  查看详情
                </el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'

const router = useRouter()
const factoryChartRef = ref<HTMLElement>()
const orderTrendChartRef = ref<HTMLElement>()

const stats = reactive({
  totalFactories: 0,
  totalStations: 0,
  totalDrivers: 0,
  totalOrders: 0
})

const factories = ref([])

onMounted(async () => {
  try {
    const response = await axios.get('/api/platform/dashboard/stats')
    if (response.data.success) {
      Object.assign(stats, response.data.data.stats)
      factories.value = response.data.data.factories || []
    }
  } catch (error) {
    console.error('获取数据失败', error)
  }
})
</script>

<style scoped>
.dashboard {
  padding: 20px;
}

.stat-card {
  cursor: pointer;
  transition: transform 0.2s;
}

.stat-card:hover {
  transform: translateY(-5px);
}

.stat-content {
  display: flex;
  align-items: center;
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  margin-right: 20px;
}

.stat-info {
  flex: 1;
}

.stat-value {
  font-size: 28px;
  font-weight: bold;
  color: #333;
}

.stat-label {
  font-size: 14px;
  color: #999;
  margin-top: 5px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
