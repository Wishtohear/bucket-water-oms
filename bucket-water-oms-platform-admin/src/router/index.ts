import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/Login.vue')
  },
  {
    path: '/',
    component: () => import('../views/Layout.vue'),
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('../views/Dashboard.vue'),
        meta: { title: '数据概览' }
      },
      {
        path: 'factories',
        name: 'Factories',
        component: () => import('../views/factory/FactoryList.vue'),
        meta: { title: '水厂管理' }
      },
      {
        path: 'factories/:id',
        name: 'FactoryDetail',
        component: () => import('../views/factory/FactoryDetail.vue'),
        meta: { title: '水厂详情' }
      },
      {
        path: 'reports',
        name: 'Reports',
        component: () => import('../views/report/GlobalReports.vue'),
        meta: { title: '全局报表' }
      },
      {
        path: 'logs',
        name: 'Logs',
        component: () => import('../views/log/OperationLogs.vue'),
        meta: { title: '操作日志' }
      },
      {
        path: 'config',
        name: 'Config',
        component: () => import('../views/config/PlatformConfig.vue'),
        meta: { title: '平台配置' }
      },
      {
        path: 'admins',
        name: 'Admins',
        component: () => import('../views/admin/PlatformAdmins.vue'),
        meta: { title: '管理员管理' }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  if (to.path !== '/login') {
    const token = localStorage.getItem('platform_token')
    if (!token) {
      next('/login')
      return
    }
  }
  next()
})

export default router
