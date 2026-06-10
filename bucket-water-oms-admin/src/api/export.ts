import request from '@/utils/request'

export interface ExportReceivablesParams {
  stationId?: string
  startDate?: string
  endDate?: string
}

export interface ExportPredepositsParams {
  stationId?: string
}

export interface ExportDriverDeliveryParams {
  startDate?: string
  endDate?: string
  driverId?: string
}

export interface ExportStationPurchaseParams {
  startDate?: string
  endDate?: string
  stationId?: string
  area?: string
}

export const exportApi = {
  exportReceivables(params: ExportReceivablesParams) {
    return request.get<Blob>('/admin/finance/export/receivables', {
      params,
      responseType: 'blob'
    })
  },

  exportPredeposits(params: ExportPredepositsParams) {
    return request.get<Blob>('/admin/finance/export/predeposits', {
      params,
      responseType: 'blob'
    })
  },

  exportDriverDeliveryReport(params: ExportDriverDeliveryParams) {
    return request.get<Blob>('/admin/reports/driver-delivery/export', {
      params,
      responseType: 'blob'
    })
  },

  exportStationPurchaseReport(params: ExportStationPurchaseParams) {
    return request.get<Blob>('/admin/reports/station-purchase/export', {
      params,
      responseType: 'blob'
    })
  },

  exportInTransitBuckets() {
    return request.get<Blob>('/admin/reports/in-transit-buckets/export', {
      responseType: 'blob'
    })
  }
}

export function downloadBlob(blob: Blob, filename: string) {
  const url = window.URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = filename
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  window.URL.revokeObjectURL(url)
}
