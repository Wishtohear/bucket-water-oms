<template>
  <el-container class="layout-container">
    <el-aside width="220px" class="aside-container">
      <Sidebar />
    </el-aside>
    <el-container>
      <el-header class="header-container">
        <Header>
          <template #actions>
            <slot name="header-actions"></slot>
          </template>
        </Header>
      </el-header>
      <el-main class="main-container">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup lang="ts">
import Sidebar from './Sidebar.vue'
import Header from './Header.vue'
</script>

<style scoped>
.layout-container {
  height: 100vh;
  background: #f0f2f5;
}

.aside-container {
  background: #fff;
  box-shadow: 2px 0 8px rgba(0, 0, 0, 0.05);
  overflow: hidden;
}

.header-container {
  padding: 0;
  background: #fff;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.05);
}

.main-container {
  padding: 16px 20px;
  overflow-y: auto;
  background: #f0f2f5;
}
</style>
