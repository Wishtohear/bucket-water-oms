// 水票状态管理 Store
import { ref, computed } from 'vue'
import { ticketService, UserTicket } from '@/services/ticketService'

interface TicketUsage {
  ticket: UserTicket
  quantity: number
}

const tickets = ref<UserTicket[]>([])
const selectedTickets = ref<TicketUsage[]>([])
const loading = ref(false)

export const useTicketStore = () => {
  const availableTickets = computed(() => {
    return tickets.value.filter(t => t.status === 'available' && t.remainingBucketCount > 0)
  })

  const usedTickets = computed(() => {
    return tickets.value.filter(t => t.status === 'used')
  })

  const expiredTickets = computed(() => {
    return tickets.value.filter(t => t.status === 'expired')
  })

  const totalAvailableBuckets = computed(() => {
    return availableTickets.value.reduce((sum, t) => sum + t.remainingBucketCount, 0)
  })

  const selectedBucketCount = computed(() => {
    return selectedTickets.value.reduce((sum, item) => sum + item.quantity, 0)
  })

  const loadMyTickets = async (status?: string) => {
    loading.value = true
    try {
      const result = await ticketService.getMyTickets({ status })
      if (result && result.list) {
        if (status) {
          tickets.value = result.list
        } else {
          tickets.value = result.list
        }
      }
    } catch (error) {
      console.error('加载水票列表失败:', error)
      uni.showToast({ title: '加载失败', icon: 'error' })
    } finally {
      loading.value = false
    }
  }

  const selectTicket = (ticket: UserTicket, quantity: number = 1) => {
    const existing = selectedTickets.value.find(item => item.ticket.id === ticket.id)
    if (existing) {
      existing.quantity = quantity
    } else {
      selectedTickets.value.push({ ticket, quantity })
    }
  }

  const deselectTicket = (ticketId: string) => {
    const index = selectedTickets.value.findIndex(item => item.ticket.id === ticketId)
    if (index > -1) {
      selectedTickets.value.splice(index, 1)
    }
  }

  const updateTicketQuantity = (ticketId: string, quantity: number) => {
    const item = selectedTickets.value.find(item => item.ticket.id === ticketId)
    if (item) {
      if (quantity <= 0) {
        deselectTicket(ticketId)
      } else {
        item.quantity = Math.min(quantity, item.ticket.remainingBucketCount)
      }
    }
  }

  const clearSelectedTickets = () => {
    selectedTickets.value = []
  }

  const isTicketSelected = (ticketId: string) => {
    return selectedTickets.value.some(item => item.ticket.id === ticketId)
  }

  const getSelectedQuantity = (ticketId: string) => {
    const item = selectedTickets.value.find(item => item.ticket.id === ticketId)
    return item?.quantity || 0
  }

  return {
    tickets,
    selectedTickets,
    loading,
    availableTickets,
    usedTickets,
    expiredTickets,
    totalAvailableBuckets,
    selectedBucketCount,
    loadMyTickets,
    selectTicket,
    deselectTicket,
    updateTicketQuantity,
    clearSelectedTickets,
    isTicketSelected,
    getSelectedQuantity
  }
}

export const ticketStore = useTicketStore()
