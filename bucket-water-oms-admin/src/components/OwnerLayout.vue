<template>
  <el-container class="owner-layout">
    <el-aside width="240px" class="owner-aside">
      <OwnerSidebar />
    </el-aside>
    <el-container>
      <el-header class="owner-header">
        <OwnerHeader>
          <template #actions>
            <slot name="header-actions"></slot>
          </template>
        </OwnerHeader>
      </el-header>
      <el-main class="owner-main">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup lang="ts">
import OwnerSidebar from './OwnerSidebar.vue'
import OwnerHeader from './OwnerHeader.vue'
</script>

<style scoped>
.owner-layout {
  height: 100vh;
  background: #f0f2f5;
}

.owner-aside {
  background: #fff;
  box-shadow: 2px 0 8px rgba(0, 0, 0, 0.05);
  overflow: hidden;
}

.owner-header {
  padding: 0;
  background: #fff;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.05);
}

.owner-main {
  padding: 20px;
  overflow-y: auto;
  background: #f0f2f5;
}
</style>
