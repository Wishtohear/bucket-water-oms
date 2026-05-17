-- ============================================================================
-- 水厂订货管理系统 - 数据补全脚本（步骤3）
-- 数据库: wateroms
-- 说明: 补充 init.sql 中缺少的字段和表
-- 执行顺序: step1 -> step2 -> step3
-- ============================================================================

-- PostgreSQL 13+ 内置 gen_random_uuid()，无需扩展

-- ============================================================================
-- 第一部分: 添加缺失字段
-- ============================================================================

-- 步骤1: 给 station 表添加经纬度字段
ALTER TABLE station ADD COLUMN IF NOT EXISTS lat DECIMAL(10,6);
ALTER TABLE station ADD COLUMN IF NOT EXISTS lng DECIMAL(10,6);
COMMENT ON COLUMN station.lat IS '纬度';
COMMENT ON COLUMN station.lng IS '经度';

-- 步骤2: 给 station_account 表添加支付类型字段
ALTER TABLE station_account ADD COLUMN IF NOT EXISTS payment_type VARCHAR(20) DEFAULT 'prepaid';
COMMENT ON COLUMN station_account.payment_type IS '支付方式: prepaid=预存金, monthly=月结';

-- 步骤3: 给 product 表添加安全库存字段
ALTER TABLE product ADD COLUMN IF NOT EXISTS safe_stock INT DEFAULT 50;
COMMENT ON COLUMN product.safe_stock IS '安全库存阈值';

-- 步骤4: 给 product_inventory 表添加安全库存字段
ALTER TABLE product_inventory ADD COLUMN IF NOT EXISTS safe_stock INT DEFAULT 50;
COMMENT ON COLUMN product_inventory.safe_stock IS '安全库存阈值';

-- 步骤5: 给 orders 表添加签收照片和配送数量字段
ALTER TABLE orders ADD COLUMN IF NOT EXISTS sign_photos JSONB;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS delivered_qty INT DEFAULT 0;
COMMENT ON COLUMN orders.sign_photos IS '签收照片(JSON数组)';
COMMENT ON COLUMN orders.delivered_qty IS '实际配送商品数量';

-- ============================================================================
-- 第二部分: 创建缺失的 notification 表
-- ============================================================================

CREATE TABLE IF NOT EXISTS notification (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    type VARCHAR(30) DEFAULT 'system',
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE notification IS '通知表 - 用户消息通知';

-- 添加 notification 表索引
CREATE INDEX IF NOT EXISTS idx_notification_user ON notification(user_id);
CREATE INDEX IF NOT EXISTS idx_notification_read ON notification(is_read);

-- ============================================================================
-- 第三部分: 创建缺失的索引
-- ============================================================================

-- 添加缺失的复合索引
CREATE INDEX IF NOT EXISTS idx_users_deleted ON users(deleted);
CREATE INDEX IF NOT EXISTS idx_users_driver ON users(driver_id);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- ============================================================================
-- 第四部分: 补充系统配置数据
-- ============================================================================

-- 检查 system_config 表的 id 字段是否有默认值，如果没有则添加
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'system_config' 
        AND column_name = 'id' 
        AND column_default IS NOT NULL
    ) THEN
        ALTER TABLE system_config ALTER COLUMN id SET DEFAULT gen_random_uuid();
    END IF;
END $$;

-- 插入系统配置数据（使用 gen_random_uuid() 确保 UUID 生成）
INSERT INTO system_config (id, config_key, config_value, config_type, config_group, description, is_system)
SELECT gen_random_uuid(), 'statement.day', '1', 'integer', 'statement', '每月对账日', false
WHERE NOT EXISTS (SELECT 1 FROM system_config WHERE config_key = 'statement.day')
UNION ALL
SELECT gen_random_uuid(), 'statement.auto_generate', 'true', 'boolean', 'statement', '自动生成对账单', false
WHERE NOT EXISTS (SELECT 1 FROM system_config WHERE config_key = 'statement.auto_generate')
UNION ALL
SELECT gen_random_uuid(), 'statement.generate_hour', '2', 'integer', 'statement', '对账单生成时间（小时）', false
WHERE NOT EXISTS (SELECT 1 FROM system_config WHERE config_key = 'statement.generate_hour')
UNION ALL
SELECT gen_random_uuid(), 'order.timeout_hours', '2', 'integer', 'order', '订单超时时间（小时）', false
WHERE NOT EXISTS (SELECT 1 FROM system_config WHERE config_key = 'order.timeout_hours')
UNION ALL
SELECT gen_random_uuid(), 'bucket.default_deposit', '30', 'decimal', 'bucket', '默认每桶押金金额', false
WHERE NOT EXISTS (SELECT 1 FROM system_config WHERE config_key = 'bucket.default_deposit')
UNION ALL
SELECT gen_random_uuid(), 'bucket.default_threshold', '10', 'integer', 'bucket', '默认欠桶阈值', false
WHERE NOT EXISTS (SELECT 1 FROM system_config WHERE config_key = 'bucket.default_threshold');

-- ============================================================================
-- 第五部分: 更新现有数据（补充字段值）
-- ============================================================================

-- 更新水站经纬度
UPDATE station SET lat = 39.908, lng = 116.404 WHERE phone = '13800000001';
UPDATE station SET lat = 39.989, lng = 116.306 WHERE phone = '13800000002';
UPDATE station SET lat = 39.914, lng = 116.407 WHERE phone = '13800000003';

-- 更新水站账户支付类型
UPDATE station_account SET payment_type = 'prepaid' WHERE station_id IN (
    SELECT id FROM station WHERE phone IN ('13800000001', '13800000003')
);
UPDATE station_account SET payment_type = 'monthly' WHERE station_id IN (
    SELECT id FROM station WHERE phone = '13800000002'
);

-- 更新商品安全库存
UPDATE product SET safe_stock = 50 WHERE category = 'bucket_water';
UPDATE product SET safe_stock = 30 WHERE category = 'bottled_water';
UPDATE product SET safe_stock = 10 WHERE category = 'equipment';

-- 更新仓库库存安全库存
UPDATE product_inventory SET safe_stock = 50 WHERE product_id IN (
    SELECT id FROM product WHERE category = 'bucket_water'
);
UPDATE product_inventory SET safe_stock = 30 WHERE product_id IN (
    SELECT id FROM product WHERE category = 'bottled_water'
);
UPDATE product_inventory SET safe_stock = 10 WHERE product_id IN (
    SELECT id FROM product WHERE category = 'equipment'
);

-- ============================================================================
-- 第六部分: 验证数据
-- ============================================================================

SELECT '=== 字段补充验证 ===' AS info;

SELECT 'station' AS table_name, 
       COUNT(*) AS total_rows,
       SUM(CASE WHEN lat IS NOT NULL AND lng IS NOT NULL THEN 1 ELSE 0 END) AS with_coords
FROM station
UNION ALL
SELECT 'station_account', COUNT(*), 
       SUM(CASE WHEN payment_type IS NOT NULL THEN 1 ELSE 0 END)
FROM station_account
UNION ALL
SELECT 'product', COUNT(*),
       SUM(CASE WHEN safe_stock IS NOT NULL THEN 1 ELSE 0 END)
FROM product
UNION ALL
SELECT 'product_inventory', COUNT(*),
       SUM(CASE WHEN safe_stock IS NOT NULL THEN 1 ELSE 0 END)
FROM product_inventory
UNION ALL
SELECT 'orders', COUNT(*),
       SUM(CASE WHEN sign_photos IS NOT NULL THEN 1 ELSE 0 END)
FROM orders
UNION ALL
SELECT 'notification', COUNT(*), 0 FROM notification;

SELECT '字段补充完成!' AS status;
