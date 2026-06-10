import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const routes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/login/warehouse',
    name: 'WarehouseLogin',
    component: () => import('@/views/WarehouseLogin.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/login/station',
    name: 'OwnerLogin',
    component: () => import('@/views/OwnerLogin.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/',
    component: () => import('@/components/Layout.vue'),
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        name: 'Dashboard',
        component: () => import('@/views/admin/Dashboard.vue'),
        meta: { title: '后台首页', roles: ['FACTORY_ADMIN'] }
      },
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/admin/Dashboard.vue'),
        meta: { title: '后台首页', roles: ['FACTORY_ADMIN'] }
      },
      {
        path: 'stations',
        name: 'Stations',
        component: () => import('@/views/admin/Stations.vue'),
        meta: { title: '水站管理', roles: ['FACTORY_ADMIN'] }
      },
      {
        path: 'stations/:id',
        name: 'StationDetail',
        component: () => import('@/views/admin/StationDetail.vue'),
        meta: { title: '水站详情', roles: ['FACTORY_ADMIN'] }
      },
      {
        path: 'stations/:id/edit',
        name: 'StationEdit',
        component: () => import('@/views/admin/StationEdit.vue'),
        meta: { title: '编辑水站', roles: ['FACTORY_ADMIN'] }
      },
      {
        path: 'stations/:id/staff',
        name: 'StationStaff',
        component: () => import('@/views/admin/StationStaff.vue'),
        meta: { title: '店员账号管理', roles: ['FACTORY_ADMIN'] }
      },
      {
        path: 'stations/create',
        name: 'StationCreate',
        component: () => import('@/views/admin/StationEdit.vue'),
        meta: { title: '新增水站', roles: ['FACTORY_ADMIN'] }
      },
      {
        path: 'orders',
        name: 'Orders',
        component: () => import('@/views/admin/Orders.vue'),
        meta: { title: '订单管理', roles: ['FACTORY_ADMIN'] }
      },
      {
        path: 'orders/:id',
        name: 'OrderDetail',
        component: () => import('@/views/admin/OrderDetail.vue'),
        meta: { title: '订单详情', roles: ['FACTORY_ADMIN'] }
      },
      {
        path: 'policies',
        name: 'Policies',
        component: () => import('@/views/admin/Policies.vue'),
        meta: { title: '销售政策', roles: ['FACTORY_ADMIN'] }
      },
      {
        path: 'policies/create',
        name: 'PolicyCreate',
        component: () => import('@/views/admin/PolicyEdit.vue'),
        meta: { title: '创建政策', roles: ['FACTORY_ADMIN'] }
      },
      {
        path: 'policies/:id/edit',
        name: 'PolicyEdit',
        component: () => import('@/views/admin/PolicyEdit.vue'),
        meta: { title: '编辑政策', roles: ['FACTORY_ADMIN'] }
      },
      {
        path: 'warehouses',
        name: 'Warehouses',
        component: () => import('@/views/admin/Warehouses.vue'),
        meta: { title: '仓库管理', roles: ['FACTORY_ADMIN'] }
      },
      {
        path: 'warehouses/:id',
        name: 'WarehouseDetail',
        component: () => import('@/views/admin/WarehouseDetail.vue'),
        meta: { title: '仓库详情', roles: ['FACTORY_ADMIN'] }
      },
      {
        path: 'products',
        name: 'Products',
        component: () => import('@/views/admin/Products.vue'),
        meta: { title: '产品管理', roles: ['FACTORY_ADMIN'] }
      },
      {
        path: 'products/create',
        name: 'ProductCreate',
        component: () => import('@/views/admin/ProductCreate.vue'),
        meta: { title: '新增产品', roles: ['FACTORY_ADMIN'] }
      },
      {
        path: 'products/:id',
        name: 'ProductDetail',
        component: () => import('@/views/admin/ProductDetail.vue'),
        meta: { title: '产品详情', roles: ['FACTORY_ADMIN'] }
      },
      {
        path: 'drivers',
        name: 'Drivers',
        component: () => import('@/views/admin/Drivers.vue'),
        meta: { title: '司机管理', roles: ['FACTORY_ADMIN'] }
      },
      {
        path: 'drivers/:id',
        name: 'DriverDetail',
        component: () => import('@/views/admin/DriverDetail.vue'),
        meta: { title: '司机详情', roles: ['FACTORY_ADMIN'] }
      },
      {
        path: 'inventory',
        name: 'Inventory',
        component: () => import('@/views/admin/Inventory.vue'),
        meta: { title: '库存管理', roles: ['FACTORY_ADMIN'] }
      },
      {
        path: 'inventory/inbound',
        name: 'AdminInbound',
        component: () => import('@/views/admin/AdminInbound.vue'),
        meta: { title: '入库登记', roles: ['FACTORY_ADMIN'] }
      },
      {
        path: 'inventory/check',
        name: 'AdminInventoryCheck',
        component: () => import('@/views/admin/AdminInventoryCheck.vue'),
        meta: { title: '库存盘点', roles: ['FACTORY_ADMIN'] }
      },
      {
        path: 'finance',
        name: 'Finance',
        component: () => import('@/views/admin/Finance.vue'),
        meta: { title: '财务管理', roles: ['FACTORY_ADMIN'] }
      },
      {
        path: 'finance/export',
        name: 'FinanceExport',
        component: () => import('@/views/admin/FinanceExport.vue'),
        meta: { title: '导出报表', roles: ['FACTORY_ADMIN'] }
      },
      {
        path: 'reports',
        name: 'Reports',
        component: () => import('@/views/admin/Reports.vue'),
        meta: { title: '报表统计', roles: ['FACTORY_ADMIN'] }
      },
      {
        path: 'settings/basic',
        name: 'BasicSettings',
        component: () => import('@/views/admin/BasicSettings.vue'),
        meta: { title: '基本设置', roles: ['FACTORY_ADMIN'] }
      },
      {
        path: 'settings/regions',
        name: 'RegionConfig',
        component: () => import('@/views/admin/RegionConfig.vue'),
        meta: { title: '地域配置', roles: ['FACTORY_ADMIN'] }
      },
      {
        path: 'settings/admins',
        name: 'AdminManagement',
        component: () => import('@/views/admin/AdminManagement.vue'),
        meta: { title: '管理员管理', roles: ['FACTORY_ADMIN'] }
      },
      {
        path: 'settings/logs',
        name: 'AuditLogs',
        component: () => import('@/views/admin/AuditLogs.vue'),
        meta: { title: '审计日志', roles: ['FACTORY_ADMIN'] }
      }
    ]
  },
  {
    path: '/station',
    component: () => import('@/components/OwnerLayout.vue'),
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        name: 'OwnerDashboard',
        component: () => import('@/views/owner/OwnerDashboard.vue'),
        meta: { title: '老板首页', roles: ['STATION_OWNER'] }
      },
      {
        path: 'dashboard',
        name: 'OwnerDashboard',
        component: () => import('@/views/owner/OwnerDashboard.vue'),
        meta: { title: '老板首页', roles: ['STATION_OWNER'] }
      },
      {
        path: 'orders',
        name: 'OwnerOrders',
        component: () => import('@/views/owner/OwnerOrders.vue'),
        meta: { title: '订单管理', roles: ['STATION_OWNER'] }
      },
      {
        path: 'orders/:id',
        name: 'OwnerOrderDetail',
        component: () => import('@/views/owner/OwnerOrderDetail.vue'),
        meta: { title: '订单详情', roles: ['STATION_OWNER'] }
      },
      {
        path: 'create-order',
        name: 'OwnerCreateOrder',
        component: () => import('@/views/owner/OwnerCreateOrder.vue'),
        meta: { title: '创建订单', roles: ['STATION_OWNER'] }
      },
      {
        path: 'customers',
        name: 'OwnerCustomers',
        component: () => import('@/views/owner/OwnerCustomers.vue'),
        meta: { title: '客户管理', roles: ['STATION_OWNER'] }
      },
      {
        path: 'customers/:id',
        name: 'OwnerCustomerDetail',
        component: () => import('@/views/owner/OwnerCustomerDetail.vue'),
        meta: { title: '客户详情', roles: ['STATION_OWNER'] }
      },
      {
        path: 'statements',
        name: 'OwnerStatements',
        component: () => import('@/views/owner/OwnerStatements.vue'),
        meta: { title: '对账管理', roles: ['STATION_OWNER'] }
      },
      {
        path: 'statements/dispute',
        name: 'OwnerStatementsDispute',
        component: () => import('@/views/owner/OwnerStatementsDispute.vue'),
        meta: { title: '提交异议', roles: ['STATION_OWNER'] }
      },
      {
        path: 'buckets',
        name: 'OwnerBuckets',
        component: () => import('@/views/owner/OwnerBuckets.vue'),
        meta: { title: '空桶管理', roles: ['STATION_OWNER'] }
      },
      {
        path: 'settings',
        name: 'OwnerSettings',
        component: () => import('@/views/owner/OwnerSettings.vue'),
        meta: { title: '个人设置', roles: ['STATION_OWNER'] }
      },
      {
        path: 'recharge',
        name: 'OwnerRecharge',
        component: () => import('@/views/owner/OwnerRecharge.vue'),
        meta: { title: '账户充值', roles: ['STATION_OWNER'] }
      },
      {
        path: 'after-sales',
        name: 'OwnerAfterSales',
        component: () => import('@/views/owner/OwnerAfterSales.vue'),
        meta: { title: '售后管理', roles: ['STATION_OWNER'] }
      },
      {
        path: 'after-sales/apply',
        name: 'OwnerAfterSalesApply',
        component: () => import('@/views/owner/OwnerAfterSalesApply.vue'),
        meta: { title: '发起售后', roles: ['STATION_OWNER'] }
      },
      {
        path: 'receive-confirm/:orderId',
        name: 'OwnerReceiveConfirm',
        component: () => import('@/views/owner/OwnerReceiveConfirm.vue'),
        meta: { title: '收货确认', roles: ['STATION_OWNER'] }
      },
      {
        path: 'tickets',
        name: 'OwnerTickets',
        component: () => import('@/views/owner/OwnerTickets.vue'),
        meta: { title: '水票管理', roles: ['STATION_OWNER'] }
      },
      {
        path: 'dispatch/:orderId',
        name: 'OwnerDispatch',
        component: () => import('@/views/owner/OwnerDispatch.vue'),
        meta: { title: '选择配送司机', roles: ['STATION_OWNER'] }
      },
      {
        path: 'delivery-persons',
        name: 'OwnerDeliveryPersons',
        component: () => import('@/views/owner/OwnerDeliveryPersons.vue'),
        meta: { title: '配送员管理', roles: ['STATION_OWNER'] }
      }
    ]
  },
  {
    path: '/warehouse',
    component: () => import('@/components/WarehouseLayout.vue'),
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        name: 'WarehouseDashboard',
        component: () => import('@/views/warehouse/WarehouseDashboard.vue'),
        meta: { title: '仓库首页', roles: ['WAREHOUSE_ADMIN'] }
      },
      {
        path: 'dashboard',
        name: 'WarehouseDashboard',
        component: () => import('@/views/warehouse/WarehouseDashboard.vue'),
        meta: { title: '仓库首页', roles: ['WAREHOUSE_ADMIN'] }
      },
      {
        path: 'orders',
        name: 'WarehouseOrders',
        component: () => import('@/views/warehouse/WarehouseOrders.vue'),
        meta: { title: '订单管理', roles: ['WAREHOUSE_ADMIN'] }
      },
      {
        path: 'orders/:id',
        name: 'WarehouseOrderDetail',
        component: () => import('@/views/warehouse/WarehouseOrderDetail.vue'),
        meta: { title: '订单详情', roles: ['WAREHOUSE_ADMIN'] }
      },
      {
        path: 'orders/:id/action',
        name: 'WarehouseOrderAction',
        component: () => import('@/views/warehouse/WarehouseOrderAction.vue'),
        meta: { title: '订单操作', roles: ['WAREHOUSE_ADMIN'] }
      },
      {
        path: 'orders/:id/reject',
        name: 'WarehouseOrderReject',
        component: () => import('@/views/warehouse/WarehouseOrderReject.vue'),
        meta: { title: '拒单处理', roles: ['WAREHOUSE_ADMIN'] }
      },
      {
        path: 'prepare-list',
        name: 'WarehousePrepareList',
        component: () => import('@/views/warehouse/WarehousePrepareList.vue'),
        meta: { title: '备货中', roles: ['WAREHOUSE_ADMIN'] }
      },
      {
        path: 'dispatch-select/:id',
        name: 'WarehouseDispatchSelect',
        component: () => import('@/views/warehouse/WarehouseDispatchSelect.vue'),
        meta: { title: '选择司机', roles: ['WAREHOUSE_ADMIN'] }
      },
      {
        path: 'bucket-inbound',
        name: 'WarehouseBucketInbound',
        component: () => import('@/views/warehouse/WarehouseBucketInbound.vue'),
        meta: { title: '空桶入库', roles: ['WAREHOUSE_ADMIN'] }
      },
      {
        path: 'bucket-outbound',
        name: 'WarehouseBucketOutbound',
        component: () => import('@/views/warehouse/WarehouseBucketOutbound.vue'),
        meta: { title: '空桶出库', roles: ['WAREHOUSE_ADMIN'] }
      },
      {
        path: 'return-list',
        name: 'WarehouseReturnList',
        component: () => import('@/views/warehouse/WarehouseReturnList.vue'),
        meta: { title: '回仓列表', roles: ['WAREHOUSE_ADMIN'] }
      },
      {
        path: 'return-check',
        name: 'WarehouseReturnCheck',
        component: () => import('@/views/warehouse/WarehouseReturnCheck.vue'),
        meta: { title: '回仓核对', roles: ['WAREHOUSE_ADMIN'] }
      },
      {
        path: 'return-check/:id',
        name: 'WarehouseReturnCheckDetail',
        component: () => import('@/views/warehouse/WarehouseReturnCheckDetail.vue'),
        meta: { title: '回仓核对详情', roles: ['WAREHOUSE_ADMIN'] }
      },
      {
        path: 'after-sales',
        name: 'WarehouseAfterSales',
        component: () => import('@/views/warehouse/WarehouseAfterSales.vue'),
        meta: { title: '售后处理', roles: ['WAREHOUSE_ADMIN'] }
      },
      {
        path: 'after-sales/:id',
        name: 'WarehouseAfterSalesDetail',
        component: () => import('@/views/warehouse/WarehouseAfterSalesDetail.vue'),
        meta: { title: '售后详情', roles: ['WAREHOUSE_ADMIN'] }
      },
      {
        path: 'inventory',
        name: 'WarehouseInventory',
        component: () => import('@/views/warehouse/WarehouseInventory.vue'),
        meta: { title: '库存管理', roles: ['WAREHOUSE_ADMIN'] }
      },
      {
        path: 'inbound',
        name: 'WarehouseInbound',
        component: () => import('@/views/warehouse/WarehouseInbound.vue'),
        meta: { title: '入库管理', roles: ['WAREHOUSE_ADMIN'] }
      },
      {
        path: 'inbound/create',
        name: 'WarehouseInboundCreate',
        component: () => import('@/views/warehouse/WarehouseInboundCreate.vue'),
        meta: { title: '新增入库', roles: ['WAREHOUSE_ADMIN'] }
      },
      {
        path: 'outbound',
        name: 'WarehouseOutbound',
        component: () => import('@/views/warehouse/WarehouseOutbound.vue'),
        meta: { title: '出库管理', roles: ['WAREHOUSE_ADMIN'] }
      },
      {
        path: 'drivers',
        name: 'WarehouseDrivers',
        component: () => import('@/views/warehouse/WarehouseDrivers.vue'),
        meta: { title: '司机管理', roles: ['WAREHOUSE_ADMIN'] }
      },
      {
        path: 'settings',
        name: 'WarehouseSettings',
        component: () => import('@/views/warehouse/WarehouseSettings.vue'),
        meta: { title: '个人设置', roles: ['WAREHOUSE_ADMIN'] }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, _from, next) => {
  // 如果是登录页，直接放行
  if (to.path === '/login' || to.path === '/login/warehouse' || to.path === '/login/station') {
    const authStore = useAuthStore()
    // 如果已登录，跳转到对应首页
    if (authStore.isAuthenticated) {
      next(authStore.getDefaultRoute())
    } else {
      next()
    }
    return
  }

  const authStore = useAuthStore()
  const requiresAuth = to.matched.some(record => record.meta.requiresAuth !== false)

  console.log('路由守卫执行 - 目标路由:', to.path)
  console.log('路由守卫执行 - requiresAuth:', requiresAuth)
  console.log('路由守卫执行 - isAuthenticated:', authStore.isAuthenticated)
  console.log('路由守卫执行 - token:', authStore.token)
  console.log('路由守卫执行 - userRole:', authStore.getUserRole())

  if (requiresAuth && !authStore.isAuthenticated) {
    console.log('路由守卫 - 未认证，跳转到登录页')
    next(authStore.getLoginRoute())
  } else {
    const currentRole = authStore.getUserRole()
    
    // 获取目标路由路径，根据路径判断需要什么角色
    const path = to.path
    let hasPermission = false
    
    // 注意：需要先检查精确匹配和更长的前缀，再检查短前缀
    // 因为 /stations 会被 /station 误匹配
    if (path === '/warehouse' || path.startsWith('/warehouse/')) {
      // 仓库端路由（排除 /warehouses 等管理端路由）
      hasPermission = currentRole === 'WAREHOUSE_ADMIN'
      console.log('仓库端路由检查 - 角色:', currentRole, '是否匹配:', hasPermission)
    } else if (path === '/stations' || path.startsWith('/stations/') || 
               path === '/' || path === '/dashboard' || path.startsWith('/dashboard/') || 
               path.startsWith('/orders') || 
               path === '/warehouses' || path.startsWith('/warehouses/') || 
               path.startsWith('/products') || path.startsWith('/drivers') || 
               path.startsWith('/inventory') || path.startsWith('/finance') ||
               path.startsWith('/reports') || path.startsWith('/settings') || 
               path.startsWith('/policies')) {
      // 管理端路由（必须放在 /station 检查之前，因为 /stations 会被 /station 误匹配）
      hasPermission = currentRole === 'FACTORY_ADMIN'
      console.log('管理端路由检查 - 角色:', currentRole, '是否匹配:', hasPermission)
    } else if (path === '/station' || path.startsWith('/station/')) {
      // 水站老板端路由（必须放在管理端路由检查之后）
      hasPermission = currentRole === 'STATION_OWNER'
      console.log('水站老板端路由检查 - 角色:', currentRole, '是否匹配:', hasPermission)
    } else {
      // 其他路由，检查是否有任何有效角色
      hasPermission = !!currentRole
      console.log('其他路由检查 - 角色:', currentRole, '是否有角色:', hasPermission)
    }
    
    if (!hasPermission) {
      console.log('路由守卫 - 权限不足，当前角色:', currentRole, '目标路径:', path)
      next(authStore.getDefaultRoute())
    } else {
      console.log('路由守卫 - 放行')
      next()
    }
  }
})

export default router
