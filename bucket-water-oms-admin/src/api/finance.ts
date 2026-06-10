import request from '@/utils/request'

export interface StatementVO {
  id: string
  stationId: string
  stationName?: string
  periodStart: string
  periodEnd: string
  totalAmount: number
  paidAmount: number
  unpaidAmount: number
  status: string
  createTime: string
  confirmTime?: string
  disputeReason?: string
}

export interface AccountDetailVO {
  id: string
  stationId: string
  stationName?: string
  type: string
  amount: number
  balance: number
  remark?: string
  createTime: string
}

export interface FinanceSummaryVO {
  totalReceivable: number
  totalPaid: number
  totalUnpaid: number
  periodStart: string
  periodEnd: string
}

export const financeApi = {
  getStatements(params?: {
    stationId?: string
    status?: string
    startDate?: string
    endDate?: string
  }) {
    return request.get<any, any>('/admin/finance/statements', { params })
  },

  getStatementById(id: string) {
    return request.get<any, any>(`/admin/finance/statements/${id}`)
  },

  confirmStatement(id: string) {
    return request.post<any, any>(`/admin/finance/statements/${id}/confirm`)
  },

  handleDispute(id: string, resolution: string) {
    return request.post<any, any>(`/admin/finance/statements/${id}/dispute`, null, {
      params: { resolution }
    })
  },

  getReceivables(params?: {
    stationId?: string
    startDate?: string
    endDate?: string
  }) {
    return request.get<any, any>('/admin/finance/receivables', { params })
  },

  getPredeposits(params?: { stationId?: string }) {
    return request.get<any, any>('/admin/finance/predeposits', { params })
  },

  getSummary() {
    return request.get<any, any>('/admin/finance/summary')
  }
}
