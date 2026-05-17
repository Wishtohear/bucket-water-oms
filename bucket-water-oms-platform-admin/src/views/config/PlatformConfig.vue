<template>
  <div class="platform-config">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>平台配置</span>
          <el-button type="primary" @click="handleSave" :loading="saveLoading">保存配置</el-button>
        </div>
      </template>

      <el-tabs v-model="activeTab">
        <el-tab-pane label="基础配置" name="basic">
          <el-form :model="basicConfig" label-width="140px">
            <el-form-item label="平台名称">
              <el-input v-model="basicConfig.platformName" placeholder="请输入平台名称" />
            </el-form-item>
            <el-form-item label="平台Logo URL">
              <el-input v-model="basicConfig.platformLogo" placeholder="请输入Logo URL" />
            </el-form-item>
            <el-form-item label="系统维护模式">
              <el-switch v-model="basicConfig.maintenanceMode" />
              <span style="margin-left: 10px; color: #999">开启后用户将无法登录</span>
            </el-form-item>
          </el-form>
        </el-tab-pane>

        <el-tab-pane label="支付配置" name="payment">
          <el-form :model="paymentConfig" label-width="140px">
            <el-form-item label="启用微信支付">
              <el-switch v-model="paymentConfig.wechatEnabled" />
            </el-form-item>
            <el-form-item label="微信AppID">
              <el-input v-model="paymentConfig.wechatAppId" placeholder="请输入AppID" />
            </el-form-item>
            <el-form-item label="微信商户号">
              <el-input v-model="paymentConfig.wechatMchId" placeholder="请输入商户号" />
            </el-form-item>
            <el-form-item label="微信API密钥">
              <el-input v-model="paymentConfig.wechatApiKey" type="password" placeholder="请输入API密钥" show-password />
            </el-form-item>
          </el-form>
        </el-tab-pane>

        <el-tab-pane label="短信配置" name="sms">
          <el-form :model="smsConfig" label-width="140px">
            <el-form-item label="启用阿里云短信">
              <el-switch v-model="smsConfig.aliyunEnabled" />
            </el-form-item>
            <el-form-item label="AccessKey ID">
              <el-input v-model="smsConfig.accessKeyId" placeholder="请输入AccessKey ID" />
            </el-form-item>
            <el-form-item label="AccessKey Secret">
              <el-input v-model="smsConfig.accessKeySecret" type="password" placeholder="请输入AccessKey Secret" show-password />
            </el-form-item>
            <el-form-item label="短信签名">
              <el-input v-model="smsConfig.signName" placeholder="请输入短信签名" />
            </el-form-item>
          </el-form>
        </el-tab-pane>

        <el-tab-pane label="地图配置" name="map">
          <el-form :model="mapConfig" label-width="140px">
            <el-form-item label="地图服务商">
              <el-select v-model="mapConfig.provider" placeholder="请选择">
                <el-option label="高德地图" value="amap" />
                <el-option label="百度地图" value="baidu" />
              </el-select>
            </el-form-item>
            <el-form-item label="Web服务Key">
              <el-input v-model="mapConfig.webKey" placeholder="请输入Web服务Key" />
            </el-form-item>
            <el-form-item label="启用模拟模式">
              <el-switch v-model="mapConfig.mockMode" />
              <span style="margin-left: 10px; color: #999">开发环境使用模拟数据</span>
            </el-form-item>
          </el-form>
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import axios from 'axios'

const activeTab = ref('basic')
const saveLoading = ref(false)

const basicConfig = reactive({
  platformName: '水厂订货管理系统',
  platformLogo: '',
  maintenanceMode: false
})

const paymentConfig = reactive({
  wechatEnabled: true,
  wechatAppId: '',
  wechatMchId: '',
  wechatApiKey: ''
})

const smsConfig = reactive({
  aliyunEnabled: true,
  accessKeyId: '',
  accessKeySecret: '',
  signName: ''
})

const mapConfig = reactive({
  provider: 'amap',
  webKey: '',
  mockMode: true
})

const loadConfig = async () => {
  try {
    const response = await axios.get('/api/platform/config')
    if (response.data.success) {
      Object.assign(basicConfig, response.data.data.basic || {})
      Object.assign(paymentConfig, response.data.data.payment || {})
      Object.assign(smsConfig, response.data.data.sms || {})
      Object.assign(mapConfig, response.data.data.map || {})
    }
  } catch (error) {
    console.error('加载配置失败', error)
  }
}

const handleSave = async () => {
  saveLoading.value = true
  try {
    await axios.put('/api/platform/config', {
      basic: basicConfig,
      payment: paymentConfig,
      sms: smsConfig,
      map: mapConfig
    })
    ElMessage.success('保存成功')
  } catch (error) {
    ElMessage.error('保存失败')
  } finally {
    saveLoading.value = false
  }
}

onMounted(() => {
  loadConfig()
})
</script>

<style scoped>
.platform-config {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
