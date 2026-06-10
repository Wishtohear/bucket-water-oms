<template>
  <el-header class="owner-header-container">
    <div class="header-left">
      <h1 class="page-title">{{ pageTitle }}</h1>
      <el-tag size="small" type="info" effect="plain">{{ currentDate }}</el-tag>
    </div>

    <div class="header-right">
      <slot name="actions"></slot>

      <el-button type="primary" @click="goToCreateOrder">
        <el-icon><Plus /></el-icon>
        新建订单
      </el-button>

      <el-badge :value="notificationCount" :max="99" class="notification-badge" :hidden="notificationCount === 0">
        <el-icon :size="22" class="badge-icon"><Bell /></el-icon>
      </el-badge>

      <el-dropdown trigger="click" @command="handleCommand" placement="bottom-end">
        <span class="user-info">
          <el-avatar :size="32" :src="avatarUrl" class="user-avatar">
            {{ userName?.charAt(0) || '老' }}
          </el-avatar>
          <div class="user-detail">
            <span class="user-name">{{ userName }}</span>
            <span class="user-role">{{ stationName }}</span>
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
import { stationOwnerApi } from '@/api'

defineProps<{
  showBack?: boolean
}>()

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const stationName = ref('我的水站')
const notificationCount = ref(5)

const loadStationInfo = async () => {
  try {
    const res = await stationOwnerApi.getDashboard()
    if (res) {
      stationName.value = res.stationName || authStore.userInfo?.warehouseName || '我的水站'
    }
  } catch (error) {
    console.error('获取水站信息失败:', error)
    stationName.value = authStore.userInfo?.warehouseName || '我的水站'
  }
}

const loadNotifications = async () => {
  try {
    const notifications = await stationOwnerApi.getNotifications()
    notificationCount.value = notifications?.length || 0
  } catch (error) {
    console.error('获取通知失败:', error)
    notificationCount.value = 0
  }
}

onMounted(() => {
  loadStationInfo()
  loadNotifications()
})

const pageTitle = computed(() => {
  const titleMap: Record<string, string> = {
    '/station/dashboard': '老板首页',
    '/station/orders': '订单管理',
    '/station/orders/': '订单详情',
    '/station/customers': '客户管理',
    '/station/customers/': '客户详情',
    '/station/statements': '对账管理',
    '/station/buckets': '空桶管理',
    '/station/settings': '个人设置',
    '/station/recharge': '账户充值',
    '/station/after-sales': '售后管理',
    '/station/receive-confirm/': '收货确认',
    '/station/tickets': '水票管理',
    '/station/create-order': '创建订单'
  }

  for (const [path, title] of Object.entries(titleMap)) {
    if (route.path.startsWith(path)) {
      return title
    }
  }
  return '水站管理'
})

const currentDate = computed(() => {
  const now = new Date()
  return `${now.getFullYear()}年${now.getMonth() + 1}月${now.getDate()}日 ${['周日', '周一', '周二', '周三', '周四', '周五', '周六'][now.getDay()]}`
})

const userName = computed(() => authStore.userInfo?.name || authStore.userInfo?.username || '水站老板')

const avatarUrl = computed(() => {
  return `https://api.dicebear.com/7.x/avataaars/svg?seed=${authStore.userInfo?.username || 'owner'}`
})

const goToCreateOrder = () => {
  router.push('/station/create-order')
}

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
      router.push('/station/settings')
      break
    case 'settings':
      router.push('/station/settings')
      break
  }
}
</script>

<style scoped>
.owner-header-container {
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

.page-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  margin: 0;
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
