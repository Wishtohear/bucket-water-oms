<template>
  <div class="sidebar-container">
    <el-menu
      :default-active="activeIndex"
      class="sidebar-menu"
      :collapse="isCollapse"
      :collapse-transition="false"
      @select="handleSelect"
    >
      <div class="logo-container">
        <el-icon :size="isCollapse ? 24 : 28" color="#409EFF"><Water /></el-icon>
        <span v-if="!isCollapse" class="logo-text">水厂运营后台</span>
      </div>

      <el-menu-item index="/dashboard">
        <el-icon><HomeFilled /></el-icon>
        <template #title>后台首页</template>
      </el-menu-item>

      <el-sub-menu index="business">
        <template #title>
          <el-icon><Shop /></el-icon>
          <span>业务管理</span>
        </template>
        <el-menu-item index="/stations">水站管理</el-menu-item>
        <el-menu-item index="/orders">订单管理</el-menu-item>
        <el-menu-item index="/products">产品管理</el-menu-item>
        <el-menu-item index="/drivers">司机管理</el-menu-item>
        <el-menu-item index="/policies">销售政策</el-menu-item>
      </el-sub-menu>

      <el-sub-menu index="warehouse">
        <template #title>
          <el-icon><Box /></el-icon>
          <span>仓储管理</span>
        </template>
        <el-menu-item index="/warehouses">仓库管理</el-menu-item>
        <el-menu-item index="/inventory">库存管理</el-menu-item>
      </el-sub-menu>

      <el-sub-menu index="finance">
        <template #title>
          <el-icon><Money /></el-icon>
          <span>财务管理</span>
        </template>
        <el-menu-item index="/finance">财务对账</el-menu-item>
        <el-menu-item index="/reports">报表统计</el-menu-item>
      </el-sub-menu>

      <el-sub-menu index="system">
        <template #title>
          <el-icon><Setting /></el-icon>
          <span>系统设置</span>
        </template>
        <el-menu-item index="/settings/basic">基本设置</el-menu-item>
        <el-menu-item index="/settings/regions">地域配置</el-menu-item>
        <el-menu-item index="/settings/admins">管理员管理</el-menu-item>
        <el-menu-item index="/settings/logs">审计日志</el-menu-item>
      </el-sub-menu>
    </el-menu>

    <div class="collapse-btn" @click="toggleCollapse">
      <el-icon v-if="isCollapse"><DArrowRight /></el-icon>
      <el-icon v-else><DArrowLeft /></el-icon>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'

const router = useRouter()
const route = useRoute()
const isCollapse = ref(false)

const activeIndex = ref('/dashboard')

watch(() => route.path, (newPath) => {
  activeIndex.value = newPath
}, { immediate: true })

const handleSelect = (index: string) => {
  router.push(index)
}

const toggleCollapse = () => {
  isCollapse.value = !isCollapse.value
}

defineExpose({ isCollapse })
</script>

<style scoped>
.sidebar-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background: #fff;
}

.sidebar-menu {
  flex: 1;
  border-right: none;
  background: #fff;
  overflow-y: auto;
}

.sidebar-menu:not(.el-menu--collapse) {
  width: 220px;
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
  background-color: #409eff;
  color: #fff;
}

:deep(.el-menu-item.is-active:hover) {
  background-color: #66b1ff;
}

:deep(.el-sub-menu .el-menu-item) {
  min-width: 180px;
  height: 44px;
  line-height: 44px;
  margin: 2px 8px;
  padding-left: 52px !important;
}

:deep(.el-sub-menu__icon-arrow) {
  right: 16px;
}

:deep(.el-sub-menu .el-menu-item.is-active) {
  background-color: #e6f0ff;
  color: #409eff;
}

:deep(.el-sub-menu .el-menu-item.is-active::before) {
  content: '';
  position: absolute;
  left: 24px;
  top: 50%;
  transform: translateY(-50%);
  width: 4px;
  height: 4px;
  background: #409eff;
  border-radius: 50%;
}

.collapse-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 48px;
  border-top: 1px solid #f0f0f0;
  cursor: pointer;
  color: #909399;
  transition: all 0.2s;
}

.collapse-btn:hover {
  background: #f5f7fa;
  color: #409eff;
}
</style>
