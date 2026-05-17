<template>
  <div class="factory-detail">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>水厂详情</span>
          <el-button @click="router.back()">返回</el-button>
        </div>
      </template>

      <el-descriptions :column="2" border v-loading="loading">
        <el-descriptions-item label="水厂名称">{{ factory.name }}</el-descriptions-item>
        <el-descriptions-item label="水厂编码">{{ factory.code }}</el-descriptions-item>
        <el-descriptions-item label="联系人">{{ factory.contact }}</el-descriptions-item>
        <el-descriptions-item label="联系电话">{{ factory.phone }}</el-descriptions-item>
        <el-descriptions-item label="详细地址" :span="2">{{ factory.address }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="factory.status === 'ACTIVE' ? 'success' : 'danger'">
            {{ factory.status === 'ACTIVE' ? '启用' : '停用' }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ factory.createTime }}</el-descriptions-item>
        <el-descriptions-item label="备注" :span="2">{{ factory.remark || '-' }}</el-descriptions-item>
      </el-descriptions>
    </el-card>

    <el-row :gutter="20" style="margin-top: 20px">
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-value">{{ stats.stations }}</div>
          <div class="stat-label">水站数量</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-value">{{ stats.warehouses }}</div>
          <div class="stat-label">仓库数量</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-value">{{ stats.drivers }}</div>
          <div class="stat-label">司机数量</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-value">{{ stats.orders }}</div>
          <div class="stat-label">订单数量</div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px">
      <el-col :span="24">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>关联账号</span>
              <el-button type="primary" size="small">创建水厂管理员</el-button>
            </div>
          </template>
          <el-table :data="admins" style="width: 100%">
            <el-table-column prop="name" label="姓名" />
            <el-table-column prop="username" label="用户名" />
            <el-table-column prop="phone" label="手机号" />
            <el-table-column prop="role" label="角色">
              <template #default="{ row }">
                <el-tag type="warning">水厂管理员</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="status" label="状态">
              <template #default="{ row }">
                <el-tag :type="row.status === 'ACTIVE' ? 'success' : 'danger'">
                  {{ row.status === 'ACTIVE' ? '启用' : '停用' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="lastLoginTime" label="最后登录" />
          </el-table>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import axios from 'axios'

const route = useRoute()
const router = useRouter()

const loading = ref(false)
const factoryId = route.params.id as string

const factory = reactive({
  name: '',
  code: '',
  contact: '',
  phone: '',
  address: '',
  status: '',
  remark: '',
  createTime: ''
})

const stats = reactive({
  stations: 0,
  warehouses: 0,
  drivers: 0,
  orders: 0
})

const admins = ref([])

onMounted(async () => {
  loading.value = true
  try {
    const response = await axios.get(`/api/platform/factories/${factoryId}`)
    if (response.data.success) {
      Object.assign(factory, response.data.data.factory)
      Object.assign(stats, response.data.data.stats)
      admins.value = response.data.data.admins || []
    }
  } catch (error) {
    ElMessage.error('加载数据失败')
  } finally {
    loading.value = false
  }
})
</script>

<style scoped>
.factory-detail {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.stat-card {
  text-align: center;
  padding: 20px;
}

.stat-value {
  font-size: 32px;
  font-weight: bold;
  color: #409EFF;
}

.stat-label {
  font-size: 14px;
  color: #999;
  margin-top: 10px;
}
</style>
