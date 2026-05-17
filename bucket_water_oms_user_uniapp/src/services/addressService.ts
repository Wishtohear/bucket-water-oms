// 地址服务
import { get, post, put, del } from '@/utils/request'
import type { Address } from '@/types/order'

export const addressService = {
  // 获取地址列表
  async getAddressList() {
    return get<Address[]>('/users/addresses')
  },

  // 获取单个地址
  async getAddress(id: string) {
    return get<Address>(`/users/addresses/${id}`)
  },

  // 添加地址
  async addAddress(data: Omit<Address, 'id'>) {
    return post<Address>('/users/addresses', data)
  },

  // 更新地址
  async updateAddress(id: string, data: Partial<Omit<Address, 'id'>>) {
    return put<Address>(`/users/addresses/${id}`, data)
  },

  // 删除地址
  async deleteAddress(id: string) {
    return del(`/users/addresses/${id}`)
  },

  // 设置默认地址
  async setDefaultAddress(id: string) {
    return put(`/users/addresses/${id}/default`)
  }
}
