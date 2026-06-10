<template>
  <div class="warehouse-sidebar-container">
    <el-menu
      :default-active="activeIndex"
      class="warehouse-sidebar-menu"
      :collapse="isCollapse"
      :collapse-transition="false"
      @select="handleSelect"
    >
      <div class="logo-container">
        <el-icon :size="isCollapse ? 24 : 28" color="#8B5CF6"><Box /></el-icon>
        <span v-if="!isCollapse" class="logo-text">仓库管理</span>
      </div>

      <el-menu-item index="/warehouse/dashboard">
        <el-icon><HomeFilled /></el-icon>
        <template #title>仓库首页</template>
      </el-menu-item>

      <el-menu-item index="/warehouse/orders">
        <el-icon><List /></el-icon>
        <template #title>
          <span>订单管理</span>
          <el-badge :value="orderBadge" :max="99" class="menu-badge" />
        </template>
      </el-menu-item>

      <el-sub-menu index="return">
        <template #title>
          <el-icon><Van /></el-icon>
          <span>回仓管理</span>
        </template>
        <el-menu-item index="/warehouse/return-check">
          <template #title>
            <span>回仓核对</span>
            <el-badge :value="returnBadge" :max="99" class="menu-badge" />
          </template>
        </el-menu-item>
        <el-menu-item index="/warehouse/return-list">回仓列表</el-menu-item>
      </el-sub-menu>

      <el-menu-item index="/warehouse/after-sales">
        <el-icon><Service /></el-icon>
        <template #title>
          <span>售后处理</span>
          <el-badge :value="afterSalesBadge" :max="99" class="menu-badge" />
        </template>
      </el-menu-item>

      <el-divider class="menu-divider" />

      <el-sub-menu index="inventory">
        <template #title>
          <el-icon><Goods /></el-icon>
          <span>库存管理</span>
        </template>
        <el-menu-item index="/warehouse/inventory">库存概览</el-menu-item>
        <el-menu-item index="/warehouse/inbound">入库管理</el-menu-item>
        <el-menu-item index="/warehouse/outbound">出库管理</el-menu-item>
        <el-menu-item index="/warehouse/bucket-inbound">空桶入库</el-menu-item>
        <el-menu-item index="/warehouse/bucket-outbound">空桶出库</el-menu-item>
      </el-sub-menu>

      <el-menu-item index="/warehouse/drivers">
        <el-icon><Van /></el-icon>
        <template #title>司机管理</template>
      </el-menu-item>

      <el-divider class="menu-divider" />

      <el-menu-item index="/warehouse/settings">
        <el-icon><Setting /></el-icon>
        <template #title>个人设置</template>
      </el-menu-item>
    </el-menu>

    <div class="user-card">
      <el-avatar :size="40" class="user-avatar">
        {{ userName?.charAt(0) || '仓' }}
      </el-avatar>
      <div class="user-info">
        <p class="user-name">{{ userName }}</p>
        <p class="user-role">仓库管理员</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()
const isCollapse = ref(false)

const activeIndex = ref('/warehouse/dashboard')

watch(() => route.path, (newPath) => {
  activeIndex.value = newPath
}, { immediate: true })

const userName = computed(() => authStore.userInfo?.name || authStore.userInfo?.username || '仓库管理员')

const orderBadge = ref(5)
const returnBadge = ref(3)
const afterSalesBadge = ref(2)

const handleSelect = (index: string) => {
  router.push(index)
}

defineExpose({ isCollapse })
</script>

<style scoped>
.warehouse-sidebar-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background: #fff;
}

.warehouse-sidebar-menu {
  flex: 1;
  border-right: none;
  background: #fff;
  overflow-y: auto;
}

.warehouse-sidebar-menu:not(.el-menu--collapse) {
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
  background-color: #f5f0ff;
}

:deep(.el-menu-item.is-active) {
  background-color: #8B5CF6;
  color: #fff;
}

:deep(.el-menu-item.is-active:hover) {
  background-color: #9d72fb;
}

:deep(.el-sub-menu .el-menu-item) {
  min-width: 200px;
  height: 44px;
  line-height: 44px;
  margin: 2px 8px;
  padding-left: 52px !important;
}

:deep(.el-sub-menu .el-menu-item.is-active) {
  background-color: #f0ebfe;
  color: #8B5CF6;
}

:deep(.el-sub-menu .el-menu-item.is-active::before) {
  content: '';
  position: absolute;
  left: 24px;
  top: 50%;
  transform: translateY(-50%);
  width: 4px;
  height: 4px;
  background: #8B5CF6;
  border-radius: 50%;
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
  background: #8B5CF6;
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
