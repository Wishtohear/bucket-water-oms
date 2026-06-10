<template>
  <div class="p-8">
    <h1 class="text-2xl font-bold mb-6">Toast 通知测试页面</h1>

    <div class="grid grid-cols-2 gap-4 mb-8">
      <button @click="testSuccess" class="btn-success">成功通知</button>
      <button @click="testError" class="btn-error">错误通知</button>
      <button @click="testWarning" class="btn-warning">警告通知</button>
      <button @click="testInfo" class="btn-info">信息通知</button>
    </div>

    <div class="border-t pt-6">
      <h2 class="text-lg font-semibold mb-4">自定义通知</h2>
      <button @click="testCustom" class="btn-primary">
        显示自定义详细通知
      </button>
    </div>

    <div class="border-t pt-6 mt-6">
      <h2 class="text-lg font-semibold mb-4">API 请求测试</h2>
      <div class="flex gap-4">
        <button @click="testApiSuccess" class="btn-primary">
          测试成功请求
        </button>
        <button @click="testApiError" class="btn-error">
          测试失败请求
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { toast } from '@/api'

const testSuccess = () => {
  toast.success('操作成功！')
}

const testError = () => {
  toast.error('请求失败，请稍后重试')
}

const testWarning = () => {
  toast.warning('余额不足，请及时充值')
}

const testInfo = () => {
  toast.info('系统将在今晚进行维护')
}

const testCustom = () => {
  toast.show({
    type: 'error',
    title: '详细的错误信息',
    message: '这是一条带详细信息的错误通知',
    details: `错误码: ERR_001
错误位置: src/utils/request.ts:45
错误堆栈:
  at ApiClient.request (request.ts:45)
  at async function main (index.ts:123)
  at processTicksAndRejections (node:internal/process/task_queues:95)

完整响应数据:
{
  "code": 500,
  "message": "服务器内部错误",
  "error": "Database connection timeout",
  "timestamp": "2026-04-22T10:30:00.000Z"
}`,
    duration: 10000,
    showDetails: true
  })
}

const testApiSuccess = async () => {
  try {
    const response = await fetch('https://httpbin.org/get')
    const data = await response.json()
    toast.success('API 请求成功', {
      details: `状态码: ${response.status}\n响应数据: ${JSON.stringify(data, null, 2)}`,
      showDetails: true
    })
  } catch (error) {
    console.error(error)
  }
}

const testApiError = async () => {
  try {
    const response = await fetch('https://httpbin.org/status/500')
    toast.show({
      type: 'error',
      title: '测试 API 错误',
      message: `HTTP ${response.status} - 内部服务器错误`,
      details: '这是一个用于测试的错误通知',
      duration: 8000,
      showDetails: true
    })
  } catch (error) {
    console.error(error)
  }
}
</script>

<style scoped>
.btn-success {
  @apply bg-green-500 text-white px-6 py-3 rounded-xl hover:bg-green-600 transition-colors;
}
.btn-error {
  @apply bg-red-500 text-white px-6 py-3 rounded-xl hover:bg-red-600 transition-colors;
}
.btn-warning {
  @apply bg-yellow-500 text-white px-6 py-3 rounded-xl hover:bg-yellow-600 transition-colors;
}
.btn-info {
  @apply bg-blue-500 text-white px-6 py-3 rounded-xl hover:bg-blue-600 transition-colors;
}
.btn-primary {
  @apply bg-[#1890FF] text-white px-6 py-3 rounded-xl hover:bg-blue-600 transition-colors;
}
</style>
