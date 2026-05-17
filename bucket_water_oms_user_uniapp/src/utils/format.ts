// 格式化工具函数
import dayjs from 'dayjs'

export const format = {
  // 格式化金额
  money(amount: number | string, prefix: string = '¥'): string {
    const num = typeof amount === 'string' ? parseFloat(amount) : amount
    return `${prefix}${num.toFixed(2)}`
  },

  // 格式化日期
  date(date: string | Date, formatStr: string = 'YYYY-MM-DD'): string {
    return dayjs(date).format(formatStr)
  },

  // 格式化日期时间
  datetime(date: string | Date, formatStr: string = 'YYYY-MM-DD HH:mm'): string {
    return dayjs(date).format(formatStr)
  },

  // 相对时间
  relativeTime(date: string | Date): string {
    const now = dayjs()
    const target = dayjs(date)
    const diffMinutes = now.diff(target, 'minute')

    if (diffMinutes < 1) return '刚刚'
    if (diffMinutes < 60) return `${diffMinutes}分钟前`

    const diffHours = now.diff(target, 'hour')
    if (diffHours < 24) return `${diffHours}小时前`

    const diffDays = now.diff(target, 'day')
    if (diffDays < 7) return `${diffDays}天前`

    return target.format('YYYY-MM-DD')
  },

  // 手机号脱敏
  phone(phone: string): string {
    if (!phone || phone.length !== 11) return phone
    return phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2')
  },

  // 隐藏姓名
  name(name: string): string {
    if (!name || name.length < 2) return name
    return name[0] + '*'.repeat(name.length - 1)
  },

  // 格式化订单状态
  orderStatus(status: string): string {
    const statusMap: Record<string, string> = {
      'pending_pay': '待支付',
      'paid': '已支付',
      'processing': '处理中',
      'delivering': '配送中',
      'completed': '已完成',
      'cancelled': '已取消',
      'refunded': '已退款',
      'pending_dispatch': '待派单',
      'pending_accept': '待接单'
    }
    return statusMap[status] || status
  }
}
