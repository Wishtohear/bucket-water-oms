<template>
  <el-container class="warehouse-layout">
    <el-aside width="240px" class="warehouse-aside">
      <WarehouseSidebar />
    </el-aside>
    <el-container>
      <el-header class="warehouse-header">
        <WarehouseHeader />
      </el-header>
      <el-main class="warehouse-main">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup lang="ts">
import WarehouseSidebar from './WarehouseSidebar.vue'
import WarehouseHeader from './WarehouseHeader.vue'
</script>

<style scoped>
.warehouse-layout {
  height: 100vh;
  background: #f0f2f5;
}

.warehouse-aside {
  background: #fff;
  box-shadow: 2px 0 8px rgba(0, 0, 0, 0.05);
  overflow: hidden;
}

.warehouse-header {
  padding: 0;
  background: #fff;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.05);
}

.warehouse-main {
  padding: 20px;
  overflow-y: auto;
  background: #f0f2f5;
}
</style>
