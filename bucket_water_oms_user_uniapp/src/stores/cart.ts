// 购物车状态管理
import { defineStore } from 'pinia'
import { storage } from '@/utils/storage'
import type { CartItem } from '@/types/order'

export const useCartStore = defineStore('cart', {
  state: () => ({
    items: [] as CartItem[]
  }),

  getters: {
    totalAmount: (state) => {
      return state.items.reduce((sum, item) => sum + item.price * item.quantity, 0)
    },

    totalCount: (state) => {
      return state.items.reduce((sum, item) => sum + item.quantity, 0)
    },

    isEmpty: (state) => state.items.length === 0,

    getItemsByStation: (state) => {
      const map = new Map<string, CartItem[]>()
      state.items.forEach(item => {
        const list = map.get(item.stationId) || []
        list.push(item)
        map.set(item.stationId, list)
      })
      return map
    }
  },

  actions: {
    // 初始化购物车
    initCart() {
      const savedCart = storage.get<CartItem[]>('cart')
      if (savedCart) {
        this.items = savedCart
      }
    },

    // 保存购物车
    saveCart() {
      storage.set('cart', this.items)
    },

    // 添加商品到购物车
    addToCart(item: Omit<CartItem, 'id'>) {
      const existingIndex = this.items.findIndex(
        i => i.stationId === item.stationId && i.productId === item.productId
      )

      if (existingIndex > -1) {
        this.items[existingIndex].quantity += item.quantity
      } else {
        this.items.push({
          ...item,
          id: `cart_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
        })
      }

      this.saveCart()
    },

    // 更新商品数量
    updateQuantity(cartId: string, quantity: number) {
      const index = this.items.findIndex(item => item.id === cartId)
      if (index > -1) {
        if (quantity <= 0) {
          this.removeFromCart(cartId)
        } else {
          this.items[index].quantity = quantity
          this.saveCart()
        }
      }
    },

    // 从购物车移除商品
    removeFromCart(cartId: string) {
      const index = this.items.findIndex(item => item.id === cartId)
      if (index > -1) {
        this.items.splice(index, 1)
        this.saveCart()
      }
    },

    // 清空购物车
    clearCart() {
      this.items = []
      this.saveCart()
    },

    // 清空指定水站的商品
    clearStationCart(stationId: string) {
      this.items = this.items.filter(item => item.stationId !== stationId)
      this.saveCart()
    },

    // 获取指定水站的商品
    getStationItems(stationId: string) {
      return this.items.filter(item => item.stationId === stationId)
    }
  }
})
