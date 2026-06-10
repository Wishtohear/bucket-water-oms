<template>
  <el-header class="header-container">
    <div class="header-left">
      <el-page-header @back="goBack" :title="'返回'" v-if="showBack">
        <template #content>
          <span class="page-title">{{ pageTitle }}</span>
        </template>
      </el-page-header>
      <template v-else>
        <h2 class="page-title">{{ pageTitle }}</h2>
        <el-tag size="small" type="info" effect="plain">{{ currentDate }}</el-tag>
      </template>
    </div>

    <div class="header-right">
      <slot name="actions"></slot>

      <el-badge :value="notificationCount" :max="99" class="notification-badge" :hidden="notificationCount === 0">
        <el-icon :size="22" class="badge-icon"><Bell /></el-icon>
      </el-badge>

      <el-dropdown trigger="click" @command="handleCommand" placement="bottom-end">
        <span class="user-info">
          <el-avatar :size="32" :src="avatarUrl" class="user-avatar">
            {{ authStore.userInfo?.name?.charAt(0) || '管' }}
          </el-avatar>
          <div class="user-detail">
            <span class="user-name">{{ authStore.userInfo?.name || '管理员' }}</span>
            <span class="user-role">{{ authStore.userInfo?.role || '管理员' }}</span>
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
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { ElMessageBox } from 'element-plus'

defineProps<{
  showBack?: boolean
}>()

const emit = defineEmits<{
  back: []
}>()

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const pageTitle = computed(() => {
  return (route.meta.title as string) || '后台管理'
})

const showBack = computed(() => {
  return route.path.includes('/') && route.path !== '/dashboard'
})

const currentDate = computed(() => {
  const now = new Date()
  return `${now.getFullYear()}年${now.getMonth() + 1}月${now.getDate()}日 ${['周日', '周一', '周二', '周三', '周四', '周五', '周六'][now.getDay()]}`
})

const notificationCount = computed(() => 5)

const avatarUrl = computed(() => {
  return `https://api.dicebear.com/7.x/avataaars/svg?seed=${authStore.userInfo?.username || 'admin'}`
})

const goBack = () => {
  emit('back')
  router.back()
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
      router.push('/settings/basic')
      break
    case 'settings':
      router.push('/settings/basic')
      break
  }
}
</script>

<style scoped>
.header-container {
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
