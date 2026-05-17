-- =============================================================================
-- 添加orders表的factory_id字段，实现订单与水厂的关联
-- =============================================================================
-- 用途: 支持多水厂数据隔离，订单必须归属特定水厂
-- 作者: AI Assistant
-- 日期: 2026-05-17
-- =============================================================================

-- 1. 添加 factory_id 字段
ALTER TABLE orders ADD COLUMN IF NOT EXISTS factory_id BIGINT;

-- 2. 添加备注说明
COMMENT ON COLUMN orders.factory_id IS '所属水厂ID';

-- 3. 添加外键约束（如果factory表存在）
-- 注意：如果还没有factory表，需要先创建factory表
-- ALTER TABLE orders ADD CONSTRAINT fk_orders_factory FOREIGN KEY (factory_id) REFERENCES factory(id);

-- 4. 添加索引优化查询
CREATE INDEX IF NOT EXISTS idx_orders_factory_id ON orders(factory_id);

-- =============================================================================
-- 执行说明：
-- 1. 备份数据库
-- 2. 执行此脚本
-- 3. 重启应用
-- =============================================================================

-- 验证脚本
SELECT 
    'orders' AS table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'orders' AND column_name = 'factory_id';
