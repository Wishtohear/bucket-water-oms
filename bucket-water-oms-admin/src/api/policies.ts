import request from '@/utils/request'

export interface PolicyTemplateDTO {
  id?: string
  name: string
  type: string
  status?: string
  remark?: string
  description?: string
  paymentType?: string
  creditLimit?: number
  preDeposit?: number
  bucketThreshold?: number
  productPrices?: ProductPrice[]
  pricingRules?: PricingRule[]
}

export interface PricingRule {
  productId: string
  productName?: string
  price: number
  minQuantity?: number
  guidePriceMin?: number
  guidePriceMax?: number
}

export interface ProductPrice {
  productId: string
  productName?: string
  category?: string
  factoryPrice?: number
  guidePriceMin?: number
  guidePriceMax?: number
  price: number
  minQuantity: number
}

export interface PolicyTemplateVO {
  id: string
  name: string
  type: string
  status: string
  createTime: string
  remark?: string
  pricingRules: PricingRule[]
}

export const policiesApi = {
  getTemplates(params?: { status?: string }) {
    return request.get<any, any>('/admin/policies/templates', { params })
  },

  getTemplateById(id: string) {
    return request.get<any, any>(`/admin/policies/templates/${id}`)
  },

  createTemplate(data: PolicyTemplateDTO) {
    return request.post<any, any>('/admin/policies/templates', data)
  },

  updateTemplate(id: string, data: PolicyTemplateDTO) {
    return request.put<any, any>(`/admin/policies/templates/${id}`, data)
  },

  deleteTemplate(id: string) {
    return request.delete<any, any>(`/admin/policies/templates/${id}`)
  },

  copyTemplate(id: string) {
    return request.post<any, any>(`/admin/policies/templates/${id}/copy`)
  },

  enableTemplate(id: string) {
    return request.post<any, any>(`/admin/policies/templates/${id}/enable`)
  },

  disableTemplate(id: string) {
    return request.post<any, any>(`/admin/policies/templates/${id}/disable`)
  }
}
