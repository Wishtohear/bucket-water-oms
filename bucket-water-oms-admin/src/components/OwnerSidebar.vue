<template>
  <div class="owner-sidebar-container">
    <el-menu
      :default-active="activeIndex"
      class="owner-sidebar-menu"
      :collapse="isCollapse"
      :collapse-transition="false"
      @select="handleSelect"
    >
      <div class="logo-container">
        <el-icon :size="isCollapse ? 24 : 28" color="#1890FF"><Shop /></el-icon>
        <span v-if="!isCollapse" class="logo-text">水站管理</span>
      </div>

      <el-menu-item index="/station/dashboard">
        <el-icon><HomeFilled /></el-icon>
        <template #title>老板首页</template>
      </el-menu-item>

      <el-menu-item index="/station/orders">
        <el-icon><List /></el-icon>
        <template #title>
          <span>订单管理</span>
          <el-badge :value="2" :max="99" class="menu-badge" />
        </template>
      </el-menu-item>

      <el-menu-item index="/station/customers">
        <el-icon><User /></el-icon>
        <template #title>客户管理</template>
      </el-menu-item>

      <el-menu-item index="/station/statements">
        <el-icon><Money /></el-icon>
        <template #title>对账管理</template>
      </el-menu-item>

      <el-menu-item index="/station/buckets">
        <el-icon><Box /></el-icon>
        <template #title>空桶管理</template>
      </el-menu-item>

      <el-menu-item index="/station/recharge">
        <el-icon><Wallet /></el-icon>
        <template #title>账户充值</template>
      </el-menu-item>

      <el-menu-item index="/station/after-sales">
        <el-icon><Service /></el-icon>
        <template #title>售后管理</template>
      </el-menu-item>

      <el-menu-item index="/station/tickets">
        <el-icon><Tickets /></el-icon>
        <template #title>水票管理</template>
      </el-menu-item>

      <el-divider class="menu-divider" />

      <el-menu-item index="/station/settings">
        <el-icon><Setting /></el-icon>
        <template #title>个人设置</template>
      </el-menu-item>
    </el-menu>

    <div class="user-card">
      <el-avatar :size="40" class="user-avatar">
        {{ userName?.charAt(0) || '老' }}
      </el-avatar>
      <div class="user-info">
        <p class="user-name">{{ userName }}</p>
        <p class="user-role">水站老板</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()
const isCollapse = ref(false)

const activeIndex = ref('/station/dashboard')

watch(() => route.path, (newPath) => {
  activeIndex.value = newPath
}, { immediate: true })

const userName = computed(() => authStore.userInfo?.name || authStore.userInfo?.username || '水站老板')

const handleSelect = (index: string) => {
  router.push(index)
}

defineExpose({ isCollapse })
</script>

<style scoped>
.owner-sidebar-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background: #fff;
}

.owner-sidebar-menu {
  flex: 1;
  border-right: none;
  background: #fff;
  overflow-y: auto;
}

.owner-sidebar-menu:not(.el-menu--collapse) {
  width: 240px;
}

.logo-container {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 16px 20px;
  gap: 10px;
  border-bottom: 1px solid #f0f0f0;
  margin-bottom: 8px;
  height: 60px;
}

.logo-text {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.menu-divider {
  margin: 8px 0;
  border-color: #f0f0f0;
}

.menu-badge {
  margin-left: 8px;
}

:deep(.el-menu-item),
:deep(.el-sub-menu__title) {
  height: 48px;
  line-height: 48px;
  margin: 2px 8px;
  padding-left: 16px !important;
  padding-right: 16px;
  border-radius: 8px;
  font-size: 14px;
  transition: all 0.2s;
}

:deep(.el-menu-item:hover),
:deep(.el-sub-menu__title:hover) {
  background-color: #ecf5ff;
}

:deep(.el-menu-item.is-active) {
  background-color: #1890FF;
  color: #fff;
}

:deep(.el-menu-item.is-active:hover) {
  background-color: #40a9ff;
}

.user-card {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px 20px;
  border-top: 1px solid #f0f0f0;
  background: #fafafa;
}

.user-avatar {
  flex-shrink: 0;
  background: #1890FF;
  color: #fff;
}

.user-info {
  flex: 1;
  overflow: hidden;
}

.user-name {
  font-size: 14px;
  font-weight: 500;
  color: #303133;
  margin: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.user-role {
  font-size: 12px;
  color: #909399;
  margin: 4px 0 0;
}
</style>
