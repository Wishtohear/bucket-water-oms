<template>
  <el-header class="warehouse-header-container">
    <div class="header-left">
      <div class="header-info">
        <h2 class="page-title">{{ currentTitle }}</h2>
        <div class="warehouse-tag" v-if="warehouseName">
          <el-icon><OfficeBuilding /></el-icon>
          <span>{{ warehouseName }}</span>
        </div>
      </div>
    </div>

    <div class="header-right">
      <el-badge :value="notificationCount" :max="99" class="notification-badge" :hidden="notificationCount === 0">
        <el-icon :size="22" class="badge-icon"><Bell /></el-icon>
      </el-badge>

      <el-dropdown trigger="click" @command="handleCommand" placement="bottom-end">
        <span class="user-info">
          <el-avatar :size="32" :src="avatarUrl" class="user-avatar">
            {{ userName?.charAt(0) || '仓' }}
          </el-avatar>
          <div class="user-detail">
            <span class="user-name">{{ userName }}</span>
            <span class="user-role">仓库管理员</span>
          </div>
          <el-icon class="el-icon--right"><ArrowDown /></el-icon>
        </span>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item command="profile">
              <el-icon><User /></el-icon>
              个人中心
            </el-dropdown-item>
            <el-dropdown-item command="settings">
              <el-icon><Setting /></el-icon>
              账号设置
            </el-dropdown-item>
            <el-dropdown-item divided command="logout">
              <el-icon><SwitchButton /></el-icon>
              退出登录
            </el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </div>
  </el-header>
</template>

<script setup lang="ts">
import { computed, ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { ElMessageBox } from 'element-plus'
import { Bell, User, Setting, ArrowDown, SwitchButton, OfficeBuilding } from '@element-plus/icons-vue'
import { warehouseApi } from '@/api'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const warehouseName = ref('')

const fetchWarehouseName = async () => {
  const warehouseId = localStorage.getItem('warehouseId')
  if (!warehouseId) {
    warehouseName.value = ''
    return
  }
  
  try {
    const info = await warehouseApi.getWarehouseInfo()
    if (info && info.data) {
      warehouseName.value = info.data.name || ''
    } else if (info && info.name) {
      warehouseName.value = info.name || ''
    } else {
      warehouseName.value = ''
    }
  } catch (error) {
    console.error('获取仓库信息失败:', error)
    warehouseName.value = ''
  }
}

onMounted(() => {
  fetchWarehouseName()
})

const currentTitle = computed(() => {
  const titleMap: Record<string, string> = {
    '/warehouse/dashboard': '仓库首页',
    '/warehouse/orders': '订单管理',
    '/warehouse/return-check': '回仓核对',
    '/warehouse/return-list': '回仓列表',
    '/warehouse/after-sales': '售后处理',
    '/warehouse/inventory': '库存管理',
    '/warehouse/inbound': '入库管理',
    '/warehouse/outbound': '出库管理',
    '/warehouse/bucket-inbound': '空桶入库',
    '/warehouse/bucket-outbound': '空桶出库',
    '/warehouse/drivers': '司机管理',
    '/warehouse/settings': '个人设置',
    '/warehouse/prepare-list': '备货中',
    '/warehouse/dispatch-select': '选择司机'
  }

  for (const [path, title] of Object.entries(titleMap)) {
    if (route.path.startsWith(path)) {
      return title
    }
  }

  return '仓库管理'
})

const notificationCount = computed(() => 5)

const userName = computed(() => authStore.userInfo?.name || authStore.userInfo?.username || '仓库管理员')

const avatarUrl = computed(() => {
  return `https://api.dicebear.com/7.x/avataaars/svg?seed=${authStore.userInfo?.username || 'warehouse'}`
})

const handleCommand = async (command: string) => {
  switch (command) {
    case 'logout':
      try {
        await ElMessageBox.confirm('确定要退出登录吗？', '提示', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        })
        authStore.logout()
        router.push(authStore.getLoginRoute())
      } catch {
        // 取消操作
      }
      break
    case 'profile':
      router.push('/warehouse/settings')
      break
    case 'settings':
      router.push('/warehouse/settings')
      break
  }
}
</script>

<style scoped>
.warehouse-header-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #fff;
  padding: 0 20px;
  height: 60px;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.header-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.page-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  margin: 0;
}

.warehouse-tag {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #fff;
  font-size: 12px;
  padding: 2px 8px;
  border-radius: 4px;
  width: fit-content;
}

.warehouse-tag .el-icon {
  font-size: 12px;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 16px;
}

.notification-badge {
  cursor: pointer;
  padding: 8px 12px;
  border-radius: 8px;
  transition: background 0.3s;
  display: flex;
  align-items: center;
  justify-content: center;
}

.notification-badge:hover {
  background: #f5f7fa;
}

.badge-icon {
  color: #606266;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  padding: 6px 12px;
  border-radius: 8px;
  transition: background 0.3s;
}

.user-info:hover {
  background: #f5f7fa;
}

.user-avatar {
  flex-shrink: 0;
}

.user-detail {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
}

.user-name {
  font-size: 14px;
  font-weight: 500;
  color: #303133;
  line-height: 1.3;
}

.user-role {
  font-size: 12px;
  color: #909399;
  line-height: 1.3;
}

.el-icon--right {
  margin-left: 4px;
  color: #909399;
}

:deep(.el-dropdown-menu__item) {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
}

:deep(.el-badge__content) {
  background: #f56c6c;
}
</style>
