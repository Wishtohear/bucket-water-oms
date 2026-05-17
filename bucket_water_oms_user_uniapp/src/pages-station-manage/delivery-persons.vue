<template>
  <view class="delivery-persons-page">
    <view class="header-bar">
      <text class="header-title">配送员管理</text>
      <button class="add-btn" @click="showAddDialog">添加配送员</button>
    </view>

    <view class="stats-bar">
      <view class="stat-item">
        <text class="stat-value">{{ totalCount }}</text>
        <text class="stat-label">配送员总数</text>
      </view>
      <view class="stat-item">
        <text class="stat-value">{{ onlineCount }}</text>
        <text class="stat-label">在线配送员</text>
      </view>
      <view class="stat-item">
        <text class="stat-value">{{ todayOrders }}</text>
        <text class="stat-label">今日配送</text>
      </view>
    </view>

    <scroll-view class="persons-list" scroll-y v-if="persons.length > 0">
      <view class="person-card" v-for="person in persons" :key="person.id">
        <view class="person-main">
          <view class="person-avatar">
            <image class="avatar-img" :src="person.avatar || '/static/images/default-avatar.png'" mode="aspectFill" />
            <view class="status-indicator" :class="person.status"></view>
          </view>
          
          <view class="person-info">
            <view class="name-row">
              <text class="person-name">{{ person.name }}</text>
              <text class="person-status" :class="person.status">
                {{ getStatusText(person.status) }}
              </text>
            </view>
            <text class="person-phone">{{ person.phone }}</text>
            <view class="person-stats">
              <text class="stat-tag">今日 {{ person.todayOrders }} 单</text>
              <text class="stat-tag">累计 {{ person.totalOrders }} 单</text>
              <text class="stat-tag rating">评分 {{ person.rating.toFixed(1) }}</text>
            </view>
          </view>
        </view>

        <view class="person-actions">
          <button class="action-btn call" @click="callPerson(person.phone)">📞</button>
          <button class="action-btn edit" @click="editPerson(person)">✏️</button>
          <button class="action-btn toggle" :class="person.status === 'active' ? 'stop' : 'start'" @click="toggleStatus(person)">
            {{ person.status === 'active' ? '停用' : '启用' }}
          </button>
          <button class="action-btn delete" @click="deletePerson(person)">🗑️</button>
        </view>
      </view>
    </scroll-view>

    <view class="empty-state" v-if="persons.length === 0 && !loading">
      <text class="empty-icon">👤</text>
      <text class="empty-text">暂无配送员</text>
      <button class="add-first-btn" @click="showAddDialog">添加第一个配送员</button>
    </view>

    <!-- 添加/编辑对话框 -->
    <view class="dialog-overlay" v-if="dialogVisible" @click="closeDialog">
      <view class="dialog-content" @click.stop>
        <view class="dialog-header">
          <text class="dialog-title">{{ isEditing ? '编辑配送员' : '添加配送员' }}</text>
          <text class="dialog-close" @click="closeDialog">✕</text>
        </view>

        <view class="dialog-body">
          <view class="form-item">
            <text class="form-label">姓名</text>
            <input class="form-input" v-model="formData.name" placeholder="请输入配送员姓名" />
          </view>
          
          <view class="form-item">
            <text class="form-label">手机号</text>
            <input class="form-input" type="number" v-model="formData.phone" placeholder="请输入手机号" maxlength="11" />
          </view>
          
          <view class="form-item">
            <text class="form-label">身份证号</text>
            <input class="form-input" v-model="formData.idCard" placeholder="请输入身份证号（选填）" />
          </view>
        </view>

        <view class="dialog-footer">
          <button class="dialog-btn cancel" @click="closeDialog">取消</button>
          <button class="dialog-btn confirm" @click="submitForm" :disabled="submitting">
            {{ submitting ? '提交中...' : '确认' }}
          </button>
        </view>
      </view>
    </view>

    <view class="loading-overlay" v-if="loading">
      <text class="loading-text">加载中...</text>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { stationOrderService, DeliveryPerson } from '@/services/stationOrderService'

const loading = ref(false)
const persons = ref<DeliveryPerson[]>([])
const dialogVisible = ref(false)
const isEditing = ref(false)
const submitting = ref(false)
const currentPersonId = ref('')

const formData = reactive({
  name: '',
  phone: '',
  idCard: ''
})

const totalCount = computed(() => persons.value.length)
const onlineCount = computed(() => persons.value.filter(p => p.status === 'active').length)
const todayOrders = computed(() => persons.value.reduce((sum, p) => sum + (p.todayOrders || 0), 0))

const getStatusText = (status: string) => {
  const map: Record<string, string> = {
    active: '在线',
    inactive: '离线'
  }
  return map[status] || status
}

const loadPersons = async () => {
  loading.value = true
  try {
    const result = await stationOrderService.getDeliveryPersons()
    if (result) {
      persons.value = result
    }
  } catch (error) {
    console.error('加载配送员列表失败:', error)
    uni.showToast({ title: '加载失败', icon: 'error' })
  } finally {
    loading.value = false
  }
}

const showAddDialog = () => {
  isEditing.value = false
  currentPersonId.value = ''
  formData.name = ''
  formData.phone = ''
  formData.idCard = ''
  dialogVisible.value = true
}

const editPerson = (person: DeliveryPerson) => {
  isEditing.value = true
  currentPersonId.value = person.id
  formData.name = person.name
  formData.phone = person.phone
  formData.idCard = ''
  dialogVisible.value = true
}

const closeDialog = () => {
  dialogVisible.value = false
}

const submitForm = async () => {
  if (!formData.name.trim()) {
    uni.showToast({ title: '请输入姓名', icon: 'none' })
    return
  }
  
  if (!/^1[3-9]\d{9}$/.test(formData.phone)) {
    uni.showToast({ title: '请输入正确的手机号', icon: 'none' })
    return
  }
  
  submitting.value = true
  
  try {
    if (isEditing.value) {
      await stationOrderService.updateDeliveryPerson(currentPersonId.value, {
        name: formData.name,
        phone: formData.phone
      })
      uni.showToast({ title: '更新成功' })
    } else {
      await stationOrderService.createDeliveryPerson({
        name: formData.name,
        phone: formData.phone,
        idCard: formData.idCard || undefined
      })
      uni.showToast({ title: '添加成功' })
    }
    
    closeDialog()
    loadPersons()
  } catch (error) {
    console.error('操作失败:', error)
    uni.showToast({ title: '操作失败', icon: 'error' })
  } finally {
    submitting.value = false
  }
}

const toggleStatus = async (person: DeliveryPerson) => {
  const newStatus = person.status === 'active' ? 'inactive' : 'active'
  const action = newStatus === 'active' ? '启用' : '停用'
  
  uni.showModal({
    title: '确认' + action,
    content: `确定要${action}配送员 ${person.name} 吗？`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await stationOrderService.updateDeliveryPerson(person.id, {
            status: newStatus
          })
          uni.showToast({ title: action + '成功' })
          loadPersons()
        } catch (error) {
          uni.showToast({ title: action + '失败', icon: 'error' })
        }
      }
    }
  })
}

const deletePerson = (person: DeliveryPerson) => {
  uni.showModal({
    title: '确认删除',
    content: `确定要删除配送员 ${person.name} 吗？删除后不可恢复。`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await stationOrderService.deleteDeliveryPerson(person.id)
          uni.showToast({ title: '删除成功' })
          loadPersons()
        } catch (error) {
          uni.showToast({ title: '删除失败', icon: 'error' })
        }
      }
    }
  })
}

const callPerson = (phone: string) => {
  uni.makePhoneCall({ phoneNumber: phone })
}

onMounted(() => {
  loadPersons()
})
</script>

<style lang="scss" scoped>
.delivery-persons-page {
  min-height: 100vh;
  background: $bg-color;
}

.header-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24rpx;
  background: #fff;
  border-bottom: 1rpx solid $border-color;

  .header-title {
    font-size: 32rpx;
    font-weight: 600;
    color: $text-primary;
  }

  .add-btn {
    padding: 12rpx 24rpx;
    background: $primary-color;
    color: #fff;
    font-size: 26rpx;
    border-radius: 24rpx;
    border: none;
  }
}

.stats-bar {
  display: flex;
  padding: 24rpx;
  gap: 24rpx;

  .stat-item {
    flex: 1;
    background: #fff;
    border-radius: $radius-lg;
    padding: 20rpx;
    text-align: center;
    box-shadow: $shadow-sm;

    .stat-value {
      display: block;
      font-size: 36rpx;
      font-weight: 700;
      color: $primary-color;
      margin-bottom: 8rpx;
    }

    .stat-label {
      display: block;
      font-size: 22rpx;
      color: $text-secondary;
    }
  }
}

.persons-list {
  padding: 0 24rpx 24rpx;

  .person-card {
    background: #fff;
    border-radius: $radius-lg;
    padding: 24rpx;
    margin-bottom: 24rpx;
    box-shadow: $shadow-sm;

    .person-main {
      display: flex;
      margin-bottom: 20rpx;

      .person-avatar {
        position: relative;
        margin-right: 20rpx;

        .avatar-img {
          width: 100rpx;
          height: 100rpx;
          border-radius: 50%;
          background: $bg-color;
        }

        .status-indicator {
          position: absolute;
          bottom: 4rpx;
          right: 4rpx;
          width: 20rpx;
          height: 20rpx;
          border-radius: 50%;
          border: 4rpx solid #fff;

          &.active {
            background: $success-color;
          }

          &.inactive {
            background: $text-tertiary;
          }
        }
      }

      .person-info {
        flex: 1;

        .name-row {
          display: flex;
          align-items: center;
          gap: 12rpx;
          margin-bottom: 8rpx;

          .person-name {
            font-size: 30rpx;
            font-weight: 600;
            color: $text-primary;
          }

          .person-status {
            font-size: 22rpx;
            padding: 4rpx 12rpx;
            border-radius: 12rpx;

            &.active {
              background: rgba($success-color, 0.1);
              color: $success-color;
            }

            &.inactive {
              background: rgba($text-tertiary, 0.1);
              color: $text-tertiary;
            }
          }
        }

        .person-phone {
          display: block;
          font-size: 26rpx;
          color: $text-secondary;
          margin-bottom: 12rpx;
        }

        .person-stats {
          display: flex;
          gap: 12rpx;
          flex-wrap: wrap;

          .stat-tag {
            font-size: 22rpx;
            padding: 4rpx 12rpx;
            background: $bg-color;
            border-radius: 12rpx;
            color: $text-secondary;

            &.rating {
              background: rgba($warning-color, 0.1);
              color: $warning-color;
            }
          }
        }
      }
    }

    .person-actions {
      display: flex;
      gap: 12rpx;
      padding-top: 20rpx;
      border-top: 1rpx solid $border-color;

      .action-btn {
        flex: 1;
        height: 64rpx;
        font-size: 24rpx;
        border-radius: 32rpx;
        border: none;
        display: flex;
        align-items: center;
        justify-content: center;
        background: $bg-color;
        color: $text-secondary;

        &.call {
          background: rgba($success-color, 0.1);
          color: $success-color;
        }

        &.edit {
          background: rgba($primary-color, 0.1);
          color: $primary-color;
        }

        &.toggle {
          &.start {
            background: rgba($success-color, 0.1);
            color: $success-color;
          }

          &.stop {
            background: rgba($warning-color, 0.1);
            color: $warning-color;
          }
        }

        &.delete {
          background: rgba($error-color, 0.1);
          color: $error-color;
        }
      }
    }
  }
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 120rpx 0;

  .empty-icon {
    font-size: 120rpx;
    margin-bottom: 32rpx;
  }

  .empty-text {
    font-size: 28rpx;
    color: $text-tertiary;
    margin-bottom: 32rpx;
  }

  .add-first-btn {
    padding: 20rpx 48rpx;
    background: $primary-color;
    color: #fff;
    font-size: 28rpx;
    border-radius: 40rpx;
    border: none;
  }
}

.dialog-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: flex-end;
  justify-content: center;
  z-index: 999;

  .dialog-content {
    width: 100%;
    background: #fff;
    border-radius: 24rpx 24rpx 0 0;
    max-height: 80vh;
    overflow: hidden;

    .dialog-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 32rpx;
      border-bottom: 1rpx solid $border-color;

      .dialog-title {
        font-size: 32rpx;
        font-weight: 600;
        color: $text-primary;
      }

      .dialog-close {
        font-size: 40rpx;
        color: $text-tertiary;
        padding: 8rpx;
      }
    }

    .dialog-body {
      padding: 32rpx;
      max-height: 50vh;
      overflow-y: auto;

      .form-item {
        margin-bottom: 32rpx;

        .form-label {
          display: block;
          font-size: 28rpx;
          color: $text-primary;
          margin-bottom: 12rpx;
        }

        .form-input {
          width: 100%;
          height: 80rpx;
          padding: 0 24rpx;
          background: $bg-color;
          border-radius: 12rpx;
          font-size: 28rpx;
        }
      }
    }

    .dialog-footer {
      display: flex;
      gap: 24rpx;
      padding: 24rpx 32rpx;
      padding-bottom: calc(24rpx + env(safe-area-inset-bottom));
      border-top: 1rpx solid $border-color;

      .dialog-btn {
        flex: 1;
        height: 88rpx;
        font-size: 32rpx;
        border-radius: 44rpx;
        border: none;

        &.cancel {
          background: $bg-color;
          color: $text-secondary;
        }

        &.confirm {
          background: $primary-color;
          color: #fff;

          &[disabled] {
            background: $text-tertiary;
          }
        }
      }
    }
  }
}

.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 999;

  .loading-text {
    font-size: 28rpx;
    color: #fff;
  }
}
</style>
