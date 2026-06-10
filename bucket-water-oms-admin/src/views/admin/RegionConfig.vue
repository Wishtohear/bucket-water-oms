<template>
  <div>
    <div class="page-header">
      <div>
        <h2 class="page-title">地域配置</h2>
        <p class="page-desc">管理水站配送覆盖的区域范围</p>
      </div>
      <el-button type="primary" @click="openRegionDialog('add')">
        <el-icon><Plus /></el-icon>
        添加区域
      </el-button>
    </div>

    <el-card shadow="never">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="搜索区域">
          <el-input v-model="searchForm.keyword" placeholder="搜索区域名称..." clearable style="width: 200px" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="filteredRegions" stripe v-loading="loading">
        <el-table-column label="区域名称" min-width="180">
          <template #default="{ row }">
            <div class="region-name-cell">
              <div class="level-icon" :class="getLevelClass(row.level)">
                <el-icon><component :is="getLevelIcon(row.level)" /></el-icon>
              </div>
              <span class="region-name">{{ row.name }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="区域编码" width="140">
          <template #default="{ row }">
            <code class="region-code">{{ row.code }}</code>
          </template>
        </el-table-column>
        <el-table-column label="上级区域" width="140">
          <template #default="{ row }">
            {{ row.parentCode ? regionStore.getRegionName(row.parentCode) : '-' }}
          </template>
        </el-table-column>
        <el-table-column label="层级" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getLevelTagType(row.level)" size="small">
              {{ getLevelText(row.level) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 'active' ? 'success' : 'info'" size="small">
              {{ row.status === 'active' ? '启用' : '停用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" align="center">
          <template #default="{ row }">
            <el-button type="primary" link @click="editRegion(row)">编辑</el-button>
            <el-button
              :type="row.status === 'active' ? 'warning' : 'success'"
              link
              @click="toggleRegionStatus(row)"
            >
              {{ row.status === 'active' ? '停用' : '启用' }}
            </el-button>
            <el-button type="danger" link @click="deleteRegionConfirm(row)">删除</el-button>
          </template>
        </el-table-column>
        <template #empty>
          <el-empty :description="searchForm.keyword ? '未找到匹配的地域' : '暂无地域数据'">
            <el-button v-if="!searchForm.keyword" type="primary" @click="openRegionDialog('add')">
              添加第一个地域
            </el-button>
          </el-empty>
        </template>
      </el-table>

      <div class="pagination-container">
        <span class="total-text">共 {{ filteredRegions.length }} 条记录</span>
        <el-pagination
          v-model:current-page="currentPage"
          :page-size="pageSize"
          :total="filteredRegions.length"
          layout="prev, pager, next"
        />
      </div>
    </el-card>

    <el-dialog
      v-model="showRegionDialog"
      :title="dialogMode === 'add' ? '添加区域' : '编辑区域'"
      width="500px"
      :close-on-click-modal="false"
    >
      <el-form :model="regionForm" label-width="100px">
        <el-form-item label="区域名称" required>
          <el-input v-model="regionForm.name" placeholder="请输入区域名称" />
        </el-form-item>
        <el-form-item label="区域编码" required>
          <el-input v-model="regionForm.code" placeholder="请输入区域编码" />
        </el-form-item>
        <el-form-item label="上级区域">
          <el-select v-model="regionForm.parentCode" placeholder="无（顶级区域）" clearable style="width: 100%">
            <el-option
              v-for="region in flatRegions"
              :key="region.code"
              :value="region.code"
              :label="region.name"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="regionForm.sort" :min="0" />
          <span class="sort-help">数值越小越靠前</span>
        </el-form-item>
        <el-form-item label="备注说明">
          <el-input v-model="regionForm.remark" type="textarea" :rows="3" placeholder="请输入备注信息（选填）..." />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="closeRegionDialog">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleRegionSubmit">
          {{ dialogMode === 'add' ? '确认添加' : '保存修改' }}
        </el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="showDeleteDialog" title="确认删除" width="400px">
      <div class="delete-confirm-content">
        <el-icon size="64" class="text-red-500 mb-4"><WarningFilled /></el-icon>
        <p class="delete-message">确定要删除区域 "{{ selectedRegionForDelete?.name }}" 吗？</p>
        <p class="delete-warning">此操作不可恢复。</p>
      </div>
      <template #footer>
        <el-button @click="closeDeleteDialog">取消</el-button>
        <el-button type="danger" :loading="submitting" @click="confirmDeleteRegion">确认删除</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Plus, WarningFilled } from '@element-plus/icons-vue'
import { useRegionStore } from '@/stores/regions'
import type { RegionVO } from '@/api/region'

const regionStore = useRegionStore()
const loading = ref(false)
const submitting = ref(false)
const currentPage = ref(1)
const pageSize = 20

const searchForm = reactive({
  keyword: ''
})

const showRegionDialog = ref(false)
const dialogMode = ref<'add' | 'edit'>('add')
const selectedRegion = ref<RegionVO | null>(null)

const showDeleteDialog = ref(false)
const selectedRegionForDelete = ref<RegionVO | null>(null)

const regionForm = reactive({
  name: '',
  code: '',
  parentCode: '',
  sort: 0,
  remark: ''
})

const filteredRegions = computed(() => {
  if (!searchForm.keyword) {
    return regionStore.regions
  }
  const keyword = searchForm.keyword.toLowerCase()
  return regionStore.regions.filter(region =>
    region.name.toLowerCase().includes(keyword) ||
    region.code.toLowerCase().includes(keyword)
  )
})

const flatRegions = computed(() => {
  return regionStore.regions.filter(r => r.status === 'active')
})

const getLevelClass = (level: number) => {
  const classMap: Record<number, string> = {
    1: 'level-province',
    2: 'level-city',
    3: 'level-district',
    4: 'level-street'
  }
  return classMap[level] || 'level-default'
}

const getLevelIcon = (level: number) => {
  const iconMap: Record<number, string> = {
    1: 'OfficeBuilding',
    2: 'Location',
    3: 'House',
    4: 'Position'
  }
  return iconMap[level] || 'Location'
}

const getLevelText = (level: number) => {
  const textMap: Record<number, string> = {
    1: '省/直辖市',
    2: '市/区',
    3: '县/街道',
    4: '乡镇'
  }
  return textMap[level] || '未知'
}

const getLevelTagType = (level: number) => {
  const typeMap: Record<number, string> = {
    1: 'danger',
    2: 'warning',
    3: 'primary',
    4: 'info'
  }
  return typeMap[level] || 'info'
}

const handleSearch = () => {
  currentPage.value = 1
}

const resetSearch = () => {
  searchForm.keyword = ''
  currentPage.value = 1
}

const openRegionDialog = (mode: 'add' | 'edit', region?: RegionVO) => {
  dialogMode.value = mode
  if (mode === 'edit' && region) {
    selectedRegion.value = region
    Object.assign(regionForm, {
      name: region.name,
      code: region.code,
      parentCode: region.parentCode || '',
      sort: region.sort || 0,
      remark: region.remark || ''
    })
  } else {
    selectedRegion.value = null
    Object.assign(regionForm, {
      name: '',
      code: '',
      parentCode: '',
      sort: 0,
      remark: ''
    })
  }
  showRegionDialog.value = true
}

const editRegion = (region: RegionVO) => {
  openRegionDialog('edit', region)
}

const closeRegionDialog = () => {
  showRegionDialog.value = false
  selectedRegion.value = null
}

const handleRegionSubmit = async () => {
  if (!regionForm.name || !regionForm.code) {
    ElMessage.warning('请填写必填项')
    return
  }

  submitting.value = true
  try {
    await new Promise(resolve => setTimeout(resolve, 500))
    if (dialogMode.value === 'add') {
      ElMessage.success('添加成功')
    } else if (selectedRegion.value) {
      ElMessage.success('修改成功')
    }
    closeRegionDialog()
    await regionStore.fetchRegions()
  } catch (error) {
    console.error('提交失败:', error)
    ElMessage.error('操作失败，请重试')
  } finally {
    submitting.value = false
  }
}

const toggleRegionStatus = async (region: RegionVO) => {
  try {
    const newStatus = region.status === 'active' ? 'inactive' : 'active'
    await regionStore.updateRegion(region.code, { status: newStatus } as any)
    ElMessage.success(newStatus === 'active' ? '已启用' : '已停用')
    await regionStore.fetchRegions()
  } catch (error) {
    console.error('更新状态失败:', error)
    ElMessage.error('操作失败，请重试')
  }
}

const deleteRegionConfirm = (region: RegionVO) => {
  selectedRegionForDelete.value = region
  showDeleteDialog.value = true
}

const closeDeleteDialog = () => {
  showDeleteDialog.value = false
  selectedRegionForDelete.value = null
}

const confirmDeleteRegion = async () => {
  if (!selectedRegionForDelete.value) return

  submitting.value = true
  try {
    await regionStore.deleteRegion(selectedRegionForDelete.value.code)
    ElMessage.success('删除成功')
    closeDeleteDialog()
    await regionStore.fetchRegions()
  } catch (error) {
    console.error('删除失败:', error)
    ElMessage.error('删除失败，请重试')
  } finally {
    submitting.value = false
  }
}

onMounted(async () => {
  loading.value = true
  try {
    await regionStore.fetchRegions()
  } catch (error) {
    console.error('加载地域数据失败:', error)
  } finally {
    loading.value = false
  }
})
</script>

<style scoped>
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.page-title {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
  margin: 0;
}

.page-desc {
  font-size: 14px;
  color: #909399;
  margin: 4px 0 0 0;
}

.search-form {
  margin-bottom: 20px;
}

.region-name-cell {
  display: flex;
  align-items: center;
  gap: 12px;
}

.level-icon {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.level-province {
  background: #fef0f0;
  color: #f56c6c;
}

.level-city {
  background: #fff7e6;
  color: #e6a23c;
}

.level-district {
  background: #ecf5ff;
  color: #409eff;
}

.level-street {
  background: #f0f9eb;
  color: #67c23a;
}

.level-default {
  background: #f5f5f5;
  color: #909399;
}

.region-name {
  font-weight: 500;
  color: #303133;
}

.region-code {
  font-family: monospace;
  font-size: 13px;
  background: #f5f5f5;
  padding: 2px 6px;
  border-radius: 4px;
}

.pagination-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 20px;
}

.total-text {
  color: #909399;
  font-size: 14px;
}

.sort-help {
  margin-left: 12px;
  font-size: 12px;
  color: #909399;
}

.delete-confirm-content {
  text-align: center;
  padding: 20px 0;
}

.delete-message {
  font-size: 16px;
  color: #303133;
  margin: 0 0 8px 0;
}

.delete-warning {
  font-size: 14px;
  color: #909399;
  margin: 0;
}

.text-red-500 {
  color: #f56c6c;
}

.mb-4 {
  margin-bottom: 16px;
}
</style>
