<template>
  <div class="create-order-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <el-button @click="goBack" :icon="ArrowLeft">返回</el-button>
          <span class="header-title">创建订单</span>
        </div>
      </template>

      <div v-if="loading" class="loading-container">
        <el-icon class="is-loading"><Loading /></el-icon>
        <span>加载中...</span>
      </div>

      <el-row v-else :gutter="20">
        <el-col :span="16">
          <el-card shadow="never" class="mb-4">
            <template #header>
              <div class="section-header">
                <el-icon><Location /></el-icon>
                <span>收货信息</span>
                <el-button type="primary" link @click="showAddressEdit = true">编辑</el-button>
              </div>
            </template>
            <div class="address-info">
              <p class="contact-name">{{ stationInfo.contactName || '水站老板' }}</p>
              <p class="contact-phone">{{ stationInfo.contactPhone || '暂无电话' }}</p>
              <p class="contact-address">{{ stationInfo.address || '暂无收货地址' }}</p>
            </div>
          </el-card>

          <el-card shadow="never" class="mb-4">
            <template #header>
              <div class="section-header">
                <el-icon><ShoppingCart /></el-icon>
                <span>商品清单</span>
                <el-button type="primary" :icon="Plus" @click="showProductSelector = true">添加商品</el-button>
              </div>
            </template>

            <el-table :data="cartItems" border stripe v-if="cartItems.length > 0">
              <el-table-column label="商品信息" min-width="200">
                <template #default="{ row }">
                  <div class="product-cell">
                    <el-image :src="row.image || defaultProductImage" class="product-image" fit="cover" />
                    <div class="product-info">
                      <p class="product-name">{{ row.productName }}</p>
                      <p class="product-stock">库存: {{ row.stock }}桶</p>
                    </div>
                  </div>
                </template>
              </el-table-column>
              <el-table-column label="单价" width="150" align="center">
                <template #default="{ row }">
                  <span class="price">¥{{ row.price }}</span>
                  <el-tag v-if="selectedPaymentMethod === 'monthly'" size="small" type="info">月结价</el-tag>
                  <p v-if="row.minOrderQuantity && row.minOrderQuantity > 1" class="text-xs text-gray-400 mt-1">最低起订{{ row.minOrderQuantity }}桶</p>
                </template>
              </el-table-column>
              <el-table-column label="数量" width="180" align="center">
                <template #default="{ row, $index }">
                  <el-input-number
                    v-model="row.quantity"
                    :min="row.minOrderQuantity || 1"
                    :max="row.stock"
                    @change="handleQuantityChange($index)"
                  />
                </template>
              </el-table-column>
              <el-table-column label="小计" width="120" align="center">
                <template #default="{ row }">
                  <span class="subtotal">¥{{ calculateItemSubtotal(row).toFixed(2) }}</span>
                </template>
              </el-table-column>
              <el-table-column label="操作" width="80" align="center">
                <template #default="{ $index }">
                  <el-button type="danger" :icon="Delete" circle @click="removeItem($index)" />
                </template>
              </el-table-column>
            </el-table>

            <el-empty v-else description="购物车是空的">
              <el-button type="primary" @click="showProductSelector = true">添加商品</el-button>
            </el-empty>
          </el-card>

          <el-card v-if="cartItems.length > 0" shadow="never" class="mb-4">
            <template #header>
              <div class="section-header">
                <el-icon><Wallet /></el-icon>
                <span>空桶回收</span>
              </div>
            </template>
            <el-row :gutter="20" align="middle">
              <el-col :span="12">
                <p class="bucket-info">预计归还 <strong>{{ expectedReturnBuckets }}</strong> 个空桶</p>
                <p class="bucket-sub">上次欠桶: {{ bucketSummary.owedBucketNum }}个</p>
              </el-col>
              <el-col :span="12" class="text-right">
                <el-switch
                  v-model="includeBucketReturn"
                  active-text="包含空桶回收"
                />
              </el-col>
            </el-row>
            <el-divider />
            <el-row :gutter="20">
              <el-col :span="12">
                <p class="info-label">押金桶总数</p>
                <p class="info-value">{{ bucketSummary.depositBucketNum }} 个</p>
              </el-col>
              <el-col :span="12">
                <p class="info-label">当前欠桶</p>
                <p class="info-value danger">{{ bucketSummary.owedBucketNum }} 个</p>
              </el-col>
            </el-row>
          </el-card>

          <el-card shadow="never" v-if="cartItems.length > 0">
            <template #header>
              <div class="section-header">
                <el-icon><EditPen /></el-icon>
                <span>订单备注</span>
              </div>
            </template>
            <el-input
              v-model="orderRemark"
              type="textarea"
              :rows="3"
              placeholder="备注说明：如有特殊派送要求请在此留言..."
            />
          </el-card>
        </el-col>

        <el-col :span="8">
          <el-card shadow="never" class="mb-4">
            <template #header>
              <div class="section-header">
                <el-icon><Coin /></el-icon>
                <span>支付方式</span>
              </div>
            </template>
            <el-radio-group v-model="selectedPaymentMethod" class="payment-group">
              <el-radio value="monthly" class="payment-option">
                <div class="payment-content">
                  <el-icon class="payment-icon"><Calendar /></el-icon>
                  <div>
                    <p class="payment-label">月结</p>
                    <p class="payment-sub">账期30天</p>
                  </div>
                </div>
              </el-radio>
              <el-radio value="prepaid" class="payment-option">
                <div class="payment-content">
                  <el-icon class="payment-icon"><Wallet /></el-icon>
                  <div>
                    <p class="payment-label">预存金</p>
                    <p class="payment-sub">余额¥{{ stationInfo.accountBalance }}</p>
                  </div>
                </div>
              </el-radio>
              <el-radio value="credit" class="payment-option">
                <div class="payment-content">
                  <el-icon class="payment-icon"><Money /></el-icon>
                  <div>
                    <p class="payment-label">信用额度</p>
                    <p class="payment-sub">可用¥{{ stationInfo.availableCredit }}/¥{{ stationInfo.creditLimit }}</p>
                  </div>
                </div>
              </el-radio>
            </el-radio-group>
          </el-card>

          <el-card shadow="never" class="mb-4">
            <template #header>
              <div class="section-header">
                <el-icon><PriceTag /></el-icon>
                <span>费用明细</span>
              </div>
            </template>
            <div class="fee-list">
              <div v-for="item in cartItems" :key="item.productId" class="fee-item">
                <span>{{ item.productName }} × {{ item.quantity }}桶</span>
                <span>¥{{ calculateItemSubtotal(item).toFixed(2) }}</span>
              </div>
              <div class="fee-item">
                <span>配送费</span>
                <span>¥{{ deliveryFee.toFixed(2) }}</span>
              </div>
              <div class="fee-item">
                <span>水票抵扣</span>
                <span class="text-danger">-¥{{ ticketDiscount.toFixed(2) }}</span>
              </div>
              <el-divider />
              <div class="fee-total">
                <span>应付金额</span>
                <span class="total-price">¥{{ totalAmount.toFixed(2) }}</span>
              </div>
            </div>
          </el-card>

          <el-card v-if="showAccountInfo && cartItems.length > 0" shadow="never" class="mb-4" type="info">
            <el-alert type="info" :closable="false" show-icon>
              <template #title>
                <div class="account-info">
                  <p>当前支付方式: <strong>{{ selectedPaymentMethodText }}</strong></p>
                  <p>信用额度剩余: <strong class="text-success">¥{{ stationInfo.availableCredit }}</strong></p>
                  <p>本次订单金额: <strong class="text-primary">¥{{ totalAmount.toFixed(2) }}</strong></p>
                  <p>订单完成后额度剩余: <strong class="text-success">¥{{ remainingCredit.toFixed(2) }}</strong></p>
                </div>
              </template>
            </el-alert>
          </el-card>

          <el-card v-if="bucketWarning" shadow="never" type="warning" class="mb-4">
            <el-alert type="warning" :closable="false" show-icon>
              <template #title>
                <div>欠桶预警: {{ bucketWarning }}</div>
              </template>
            </el-alert>
          </el-card>

          <el-card shadow="never" class="stock-check-card" :class="stockCheckPass ? 'success' : 'warning'">
            <div class="stock-check">
              <el-icon :color="stockCheckPass ? '#67C23A' : '#E6A23C'">
                <component :is="stockCheckPass ? 'CircleCheck' : 'Warning'" />
              </el-icon>
              <span>{{ stockCheckMessage }}</span>
            </div>
          </el-card>

          <div class="action-bar">
            <div class="order-summary">
              <p class="summary-label">共 {{ totalQuantity }} 件商品</p>
              <p class="summary-price">¥{{ totalAmount.toFixed(2) }}</p>
            </div>
            <el-button
              type="primary"
              size="large"
              :disabled="submitting || !stockCheckPass || cartItems.length === 0"
              :loading="submitting"
              @click="submitOrder"
              class="submit-btn"
            >
              提交订单
            </el-button>
          </div>
        </el-col>
      </el-row>
    </el-card>

    <el-dialog v-model="showProductSelector" title="选择商品" width="800px" destroy-on-close>
      <el-table :data="availableProducts" border stripe @row-click="handleProductRowClick">
        <el-table-column label="商品" min-width="200">
          <template #default="{ row }">
            <div class="product-cell">
              <el-image :src="row.image || defaultProductImage" class="product-image" fit="cover" />
              <div class="product-info">
                <p class="product-name">{{ row.name }}</p>
                <p class="product-spec">{{ row.spec || '标准规格' }}</p>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="价格" width="120" align="center">
          <template #default="{ row }">
            <span class="price">¥{{ row.price }}</span>
            <p v-if="row.minOrderQuantity && row.minOrderQuantity > 1" class="text-xs text-gray-400">起订{{ row.minOrderQuantity }}桶</p>
          </template>
        </el-table-column>
        <el-table-column label="库存" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.stock > 10 ? 'success' : row.stock > 0 ? 'warning' : 'danger'">
              {{ row.stock }}桶
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="100" align="center">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click.stop="addProductToCart(row)">添加</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-dialog>

    <el-dialog v-model="showAddressEdit" title="编辑收货地址" width="500px" destroy-on-close>
      <el-form :model="stationInfo" label-width="80px">
        <el-form-item label="联系人">
          <el-input v-model="stationInfo.contactName" placeholder="请输入联系人姓名" />
        </el-form-item>
        <el-form-item label="联系电话">
          <el-input v-model="stationInfo.contactPhone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="收货地址">
          <el-input v-model="stationInfo.address" type="textarea" :rows="3" placeholder="请输入详细收货地址" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showAddressEdit = false">取消</el-button>
        <el-button type="primary" @click="showAddressEdit = false">保存</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="showConfirmDialog" title="确认提交订单" width="400px" destroy-on-close>
      <div class="confirm-content">
        <el-result icon="success" title="确认提交订单？" />
        <div class="confirm-info">
          <p>订单金额：<strong class="text-primary">¥{{ totalAmount.toFixed(2) }}</strong></p>
          <p>支付方式：<strong class="text-primary">{{ selectedPaymentMethodText }}</strong></p>
          <p>预计送达：<strong>明日 14:00 前</strong></p>
        </div>
      </div>
      <template #footer>
        <el-button @click="showConfirmDialog = false">取消</el-button>
        <el-button type="primary" @click="confirmSubmit">确认提交</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import {
  ArrowLeft, Loading, Location, ShoppingCart, Plus, Delete, Wallet,
  EditPen, Coin, Calendar, Money, PriceTag
} from '@element-plus/icons-vue'
import { stationOwnerApi } from '@/api'

const router = useRouter()
const route = useRoute()

const loading = ref(false)
const submitting = ref(false)
const defaultProductImage = 'https://modao.cc/agent-py/media/generated_images/2026-04-19/a334311da7854958a4c575d1ed971989.jpg'

const stationInfo = ref<any>({
  contactName: '张老板',
  contactPhone: '138****8888',
  address: '广西壮族自治区桂林市秀峰区XX路XX号张记旗舰水站',
  availableCredit: '5000.00',
  accountBalance: '12500.00'
})

const bucketSummary = ref({
  depositBucketNum: 100,
  owedBucketNum: 8,
  owedThreshold: 10
})

const cartItems = ref<any[]>([])
const showProductSelector = ref(false)
const availableProducts = ref<any[]>([])
const selectedWarehouseId = ref<string>('1')

const selectedPaymentMethod = ref('monthly')
const includeBucketReturn = ref(true)
const orderRemark = ref('')
const showAddressEdit = ref(false)
const showConfirmDialog = ref(false)

const totalQuantity = computed(() => {
  return cartItems.value.reduce((sum, item) => sum + item.quantity, 0)
})

const expectedReturnBuckets = computed(() => {
  return includeBucketReturn.value ? totalQuantity.value : 0
})

const deliveryFee = computed(() => 0.00)
const ticketDiscount = computed(() => 0.00)

const totalAmount = computed(() => {
  const subtotal = cartItems.value.reduce((sum, item) => sum + calculateItemSubtotal(item), 0)
  return subtotal + deliveryFee.value - ticketDiscount.value
})

const selectedPaymentMethodText = computed(() => {
  const map: Record<string, string> = {
    monthly: '月结',
    prepaid: '预存金',
    credit: '信用额度'
  }
  return map[selectedPaymentMethod.value] || '月结'
})

const remainingCredit = computed(() => {
  const available = parseFloat(stationInfo.value.availableCredit) || 0
  return Math.max(0, available - totalAmount.value)
})

const showAccountInfo = computed(() => {
  return selectedPaymentMethod.value === 'monthly' || selectedPaymentMethod.value === 'credit'
})

const stockCheckPass = computed(() => {
  return cartItems.value.every(item => item.quantity <= item.stock)
})

const stockCheckMessage = computed(() => {
  if (cartItems.value.length === 0) return '请添加商品'
  return stockCheckPass.value ? '库存充足，商品可正常下单' : '部分商品库存不足'
})

const bucketWarning = computed(() => {
  if (expectedReturnBuckets.value === 0) {
    return '本次订单不归还空桶，请注意欠桶数量'
  }
  const newOwedBuckets = bucketSummary.value.depositBucketNum - expectedReturnBuckets.value + bucketSummary.value.owedBucketNum
  if (newOwedBuckets > bucketSummary.value.owedThreshold) {
    return `归还后将欠桶 ${newOwedBuckets} 个，超过预警阈值 ${bucketSummary.value.owedThreshold} 个`
  }
  return ''
})

const calculateItemSubtotal = (item: any) => {
  return (parseFloat(item.price) || 0) * item.quantity
}

const handleQuantityChange = (_index: number) => {
}

const removeItem = (index: number) => {
  cartItems.value.splice(index, 1)
}

const handleProductRowClick = (row: any) => {
  addProductToCart(row)
}

const addProductToCart = (product: any) => {
  const existingIndex = cartItems.value.findIndex(item => item.productId === product.id)
  if (existingIndex >= 0) {
    cartItems.value[existingIndex].quantity++
  } else {
    cartItems.value.push({
      productId: product.id,
      productName: product.name,
      price: product.price,
      quantity: product.minOrderQuantity || 1,
      stock: product.stock,
      image: product.image || defaultProductImage,
      minOrderQuantity: product.minOrderQuantity || 1
    })
  }
  ElMessage.success(`已添加 ${product.name}（最低起订${product.minOrderQuantity || 1}桶）`)
}

const goBack = () => {
  if (cartItems.value.length > 0) {
    if (!confirm('确定要返回吗？购物车中的商品将被清空')) {
      return
    }
  }
  router.back()
}

const submitOrder = () => {
  showConfirmDialog.value = true
}

const confirmSubmit = async () => {
  if (cartItems.value.length === 0) {
    ElMessage.warning('请添加商品')
    return
  }

  if (!stockCheckPass.value) {
    ElMessage.error('部分商品库存不足，请调整数量')
    return
  }

  try {
    submitting.value = true
    showConfirmDialog.value = false

    const orderData = {
      warehouseId: selectedWarehouseId.value,
      contactName: stationInfo.value.contactName || '',
      contactPhone: stationInfo.value.contactPhone || '',
      deliveryAddress: stationInfo.value.address || '',
      items: cartItems.value.map(item => ({
        productId: item.productId,
        quantity: item.quantity
      })),
      remark: orderRemark.value || '',
      paymentType: selectedPaymentMethod.value || 'prepaid'
    }

    const result = await stationOwnerApi.createOrder(orderData)

    if (result && (result as any).data) {
      ElMessage.success('订单提交成功！订单号：' + (((result as any).data).orderNo || ''))
      router.push('/station/orders')
    }
  } catch (error: any) {
    ElMessage.error('提交订单失败：' + (error.message || '未知错误'))
  } finally {
    submitting.value = false
  }
}

const loadData = async () => {
  try {
    loading.value = true

    try {
      const res = await stationOwnerApi.getProducts()
      const data = (res as any).data
      if (data && data.products && Array.isArray(data.products)) {
        availableProducts.value = data.products.map((p: any) => ({
          id: p.productId,
          name: p.name,
          category: p.category,
          spec: p.specification || p.spec || '',
          image: p.image || defaultProductImage,
          price: p.price || '0.00',
          stock: 0,
          minOrderQuantity: 1
        }))
      }
    } catch (e) {
      console.log('商品列表加载失败', e)
    }

    try {
      const priceRes = await stationOwnerApi.getProductPrices()
      if (priceRes?.data && Array.isArray(priceRes.data)) {
        priceRes.data.forEach((priceInfo: any) => {
          const product = availableProducts.value.find((p: any) => String(p.id) === String(priceInfo.productId))
          if (product) {
            product.price = String(priceInfo.unitPrice)
            product.minOrderQuantity = priceInfo.minOrderQuantity || 1
            if (priceInfo.tierPrice) {
              product.tierPrice = priceInfo.tierPrice
            }
          }
        })
      }
    } catch (e) {
      console.log('商品价格加载失败，使用默认价格', e)
    }

    try {
      const invRes = await stationOwnerApi.getInventory()
      const invData = (invRes as any).data
      if (invData?.warehouses?.length > 0) {
        const firstWarehouse = invData.warehouses[0]
        // 保存选择的仓库ID
        if (firstWarehouse?.warehouseId) {
          selectedWarehouseId.value = String(firstWarehouse.warehouseId)
        }
        if (firstWarehouse?.products) {
          availableProducts.value.forEach(product => {
            const invProduct = firstWarehouse.products.find((p: any) => p.productId === product.id)
            if (invProduct) {
              product.stock = invProduct.availableQty || 0
            }
          })
        }
      }
    } catch (e) {
      console.log('库存信息加载失败，使用默认数据')
    }

    try {
      const dashboardRes = await stationOwnerApi.getDashboard()
      if (dashboardRes && (dashboardRes as any).data) {
        const data = (dashboardRes as any).data
        stationInfo.value.availableCredit = data.availableCredit || '0.00'
        stationInfo.value.accountBalance = data.accountBalance || '0.00'
        stationInfo.value.contactName = data.contact || '水站老板'
        stationInfo.value.contactPhone = data.contactPhone || ''
        stationInfo.value.address = data.address || ''
        bucketSummary.value.owedBucketNum = data.owedBucketNum || 0
        bucketSummary.value.owedThreshold = data.owedThreshold || 10
      }
    } catch (e) {
      console.log('账户信息加载失败，使用默认数据')
    }

    try {
      const bucketRes = await stationOwnerApi.getBucketSummary()
      if (bucketRes && (bucketRes as any).data) {
        const data = (bucketRes as any).data
        bucketSummary.value.depositBucketNum = data.depositBucketNum || 100
        bucketSummary.value.owedBucketNum = data.owedBucketNum || 0
        bucketSummary.value.owedThreshold = data.owedThreshold || 10
      }
    } catch (e) {
      console.log('空桶汇总加载失败，使用默认数据')
    }

    const fromOrderId = route.query.fromOrder as string
    if (fromOrderId) {
      try {
        const orderRes = await stationOwnerApi.getOrderById(fromOrderId)
        const orderData = (orderRes as any).data
        if (orderData?.items) {
          cartItems.value = orderData.items.map((item: any) => ({
            productId: item.productId,
            productName: item.productName,
            price: item.price,
            quantity: item.quantity,
            stock: item.stock || 100,
            image: defaultProductImage,
            minOrderQuantity: 1
          }))
        }
      } catch (e) {
        console.log('订单详情加载失败')
      }
    }
    
    const addProductStr = route.query.addProduct as string
    if (addProductStr) {
      try {
        const addProduct = JSON.parse(addProductStr)
        cartItems.value.push({
          productId: addProduct.id,
          productName: addProduct.name,
          price: addProduct.price,
          quantity: addProduct.minOrderQuantity || 1,
          stock: 100,
          image: defaultProductImage,
          minOrderQuantity: addProduct.minOrderQuantity || 1
        })
      } catch (e) {
        console.log('商品参数解析失败')
      }
    }
  } catch (error: any) {
    ElMessage.error('加载数据失败：' + (error.message || '未知错误'))
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadData()
})
</script>

<style scoped>
.create-order-container {
  padding: 0;
}

.card-header {
  display: flex;
  align-items: center;
  gap: 12px;
}

.header-title {
  font-size: 18px;
  font-weight: 500;
}

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 0;
  gap: 16px;
  color: #909399;
}

.section-header {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 500;
}

.address-info {
  padding: 8px 0;
}

.address-info .contact-name {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 4px;
}

.address-info .contact-phone {
  font-size: 14px;
  color: #909399;
  margin-bottom: 8px;
}

.address-info .contact-address {
  font-size: 14px;
  color: #606266;
}

.product-cell {
  display: flex;
  align-items: center;
  gap: 12px;
}

.product-image {
  width: 50px;
  height: 50px;
  border-radius: 8px;
}

.product-info .product-name {
  font-weight: 500;
  color: #303133;
}

.product-info .product-stock {
  font-size: 12px;
  color: #909399;
}

.price {
  color: #409EFF;
  font-weight: 600;
}

.subtotal {
  font-weight: 600;
  color: #303133;
}

.bucket-info {
  font-size: 14px;
  color: #606266;
}

.bucket-sub {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
}

.info-label {
  font-size: 14px;
  color: #909399;
}

.info-value {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
  margin-top: 4px;
}

.info-value.danger {
  color: #F56C6C;
}

.payment-group {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.payment-option {
  height: auto;
  padding: 12px;
  border: 1px solid #DCDFE6;
  border-radius: 8px;
  margin-right: 0;
}

.payment-option:has(.is-checked) {
  border-color: #409EFF;
  background-color: #ECF5FF;
}

.payment-content {
  display: flex;
  align-items: center;
  gap: 12px;
}

.payment-icon {
  font-size: 24px;
  color: #409EFF;
}

.payment-label {
  font-weight: 600;
  color: #303133;
}

.payment-sub {
  font-size: 12px;
  color: #909399;
}

.fee-list {
  padding: 8px 0;
}

.fee-item {
  display: flex;
  justify-content: space-between;
  padding: 8px 0;
  font-size: 14px;
  color: #606266;
}

.fee-total {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 16px;
  font-weight: 600;
}

.total-price {
  font-size: 24px;
  color: #409EFF;
}

.text-danger {
  color: #F56C6C;
}

.text-success {
  color: #67C23A;
}

.text-primary {
  color: #409EFF;
}

.account-info p {
  margin: 4px 0;
  font-size: 14px;
}

.stock-check-card {
  margin-bottom: 16px;
}

.stock-check {
  display: flex;
  align-items: center;
  gap: 8px;
  justify-content: center;
  padding: 12px;
}

.stock-check-card.success {
  background-color: #f0f9eb;
}

.stock-check-card.warning {
  background-color: #fdf6ec;
}

.action-bar {
  position: sticky;
  bottom: 20px;
  background: white;
  padding: 16px;
  border-radius: 8px;
  box-shadow: 0 -2px 12px rgba(0, 0, 0, 0.1);
}

.order-summary {
  margin-bottom: 12px;
}

.summary-label {
  font-size: 14px;
  color: #909399;
}

.summary-price {
  font-size: 24px;
  font-weight: 600;
  color: #303133;
}

.submit-btn {
  width: 100%;
  height: 48px;
  font-size: 16px;
}

.confirm-content {
  padding: 20px 0;
}

.confirm-info {
  text-align: center;
  padding: 16px;
  background: #f5f7fa;
  border-radius: 8px;
  margin-top: 16px;
}

.confirm-info p {
  margin: 8px 0;
  font-size: 14px;
  color: #606266;
}

.mb-4 {
  margin-bottom: 16px;
}

:deep(.el-radio) {
  margin-right: 0;
}
</style>
