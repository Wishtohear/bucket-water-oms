// 地址状态管理
import { defineStore } from 'pinia'
import { addressService } from '@/services/addressService'
import type { Address } from '@/types/order'

export const useAddressStore = defineStore('address', {
  state: () => ({
    addresses: [] as Address[],
    defaultAddress: null as Address | null,
    loading: false
  }),

  getters: {
    getAddressList: (state) => state.addresses,
    getDefaultAddress: (state) => state.defaultAddress,
    hasAddress: (state) => state.addresses.length > 0
  },

  actions: {
    // 获取地址列表
    async fetchAddresses() {
      this.loading = true
      try {
        const list = await addressService.getAddressList()
        this.addresses = list || []

        this.defaultAddress = this.addresses.find(addr => addr.isDefault) || null

        if (!this.defaultAddress && this.addresses.length > 0) {
          this.defaultAddress = this.addresses[0]
        }
      } catch (error) {
        console.error('获取地址列表失败:', error)
      } finally {
        this.loading = false
      }
    },

    // 添加地址
    async addAddress(data: Omit<Address, 'id'>) {
      try {
        const result = await addressService.addAddress(data)
        if (result) {
          await this.fetchAddresses()
          return true
        }
        return false
      } catch (error) {
        console.error('添加地址失败:', error)
        return false
      }
    },

    // 更新地址
    async updateAddress(id: string, data: Partial<Omit<Address, 'id'>>) {
      try {
        const result = await addressService.updateAddress(id, data)
        if (result) {
          await this.fetchAddresses()
          return true
        }
        return false
      } catch (error) {
        console.error('更新地址失败:', error)
        return false
      }
    },

    // 删除地址
    async deleteAddress(id: string) {
      try {
        await addressService.deleteAddress(id)
        await this.fetchAddresses()
        return true
      } catch (error) {
        console.error('删除地址失败:', error)
        return false
      }
    },

    // 设置默认地址
    async setDefaultAddress(id: string) {
      try {
        await addressService.setDefaultAddress(id)
        await this.fetchAddresses()
        return true
      } catch (error) {
        console.error('设置默认地址失败:', error)
        return false
      }
    }
  }
})
