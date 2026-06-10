<template>
  <router-view />
</template>

<script setup lang="ts">
import { onMounted } from 'vue'

onMounted(() => {
  console.log('水厂订货管理系统已启动')
})
</script>

<style scoped>
</style>
