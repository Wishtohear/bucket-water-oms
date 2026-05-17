-- ============================================================================
-- 数据库列名修复脚本
-- 问题: 旧版表结构使用 created_at/updated_at，新版使用 create_time/update_time
-- 解决: 添加缺失的列到现有表
-- ============================================================================

DO $$
BEGIN
    -- ============================================================
    -- 修复 station 表
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'station' AND column_name = 'create_time') THEN
        ALTER TABLE station ADD COLUMN create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'station' AND column_name = 'update_time') THEN
        ALTER TABLE station ADD COLUMN update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'station' AND column_name = 'create_by') THEN
        ALTER TABLE station ADD COLUMN create_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'station' AND column_name = 'update_by') THEN
        ALTER TABLE station ADD COLUMN update_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'station' AND column_name = 'deleted') THEN
        ALTER TABLE station ADD COLUMN deleted INTEGER DEFAULT 0;
    END IF;

    -- 将 created_at 数据迁移到 create_time（如果 created_at 存在且 create_time 为空）
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'station' AND column_name = 'created_at')
       AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'station' AND column_name = 'create_time') THEN
        EXECUTE 'UPDATE station SET create_time = created_at WHERE create_time IS NULL AND created_at IS NOT NULL';
    END IF;

    -- ============================================================
    -- 修复 warehouse 表
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'warehouse' AND column_name = 'create_time') THEN
        ALTER TABLE warehouse ADD COLUMN create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'warehouse' AND column_name = 'update_time') THEN
        ALTER TABLE warehouse ADD COLUMN update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'warehouse' AND column_name = 'create_by') THEN
        ALTER TABLE warehouse ADD COLUMN create_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'warehouse' AND column_name = 'update_by') THEN
        ALTER TABLE warehouse ADD COLUMN update_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'warehouse' AND column_name = 'deleted') THEN
        ALTER TABLE warehouse ADD COLUMN deleted INTEGER DEFAULT 0;
    END IF;

    -- ============================================================
    -- 修复 driver 表
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'driver' AND column_name = 'create_time') THEN
        ALTER TABLE driver ADD COLUMN create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'driver' AND column_name = 'update_time') THEN
        ALTER TABLE driver ADD COLUMN update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'driver' AND column_name = 'create_by') THEN
        ALTER TABLE driver ADD COLUMN create_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'driver' AND column_name = 'update_by') THEN
        ALTER TABLE driver ADD COLUMN update_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'driver' AND column_name = 'deleted') THEN
        ALTER TABLE driver ADD COLUMN deleted INTEGER DEFAULT 0;
    END IF;

    -- ============================================================
    -- 修复 product 表
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'product' AND column_name = 'create_time') THEN
        ALTER TABLE product ADD COLUMN create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'product' AND column_name = 'update_time') THEN
        ALTER TABLE product ADD COLUMN update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'product' AND column_name = 'create_by') THEN
        ALTER TABLE product ADD COLUMN create_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'product' AND column_name = 'update_by') THEN
        ALTER TABLE product ADD COLUMN update_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'product' AND column_name = 'deleted') THEN
        ALTER TABLE product ADD COLUMN deleted INTEGER DEFAULT 0;
    END IF;

    -- ============================================================
    -- 修复 product_inventory 表
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'product_inventory' AND column_name = 'create_time') THEN
        ALTER TABLE product_inventory ADD COLUMN create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'product_inventory' AND column_name = 'update_time') THEN
        ALTER TABLE product_inventory ADD COLUMN update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'product_inventory' AND column_name = 'create_by') THEN
        ALTER TABLE product_inventory ADD COLUMN create_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'product_inventory' AND column_name = 'update_by') THEN
        ALTER TABLE product_inventory ADD COLUMN update_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'product_inventory' AND column_name = 'deleted') THEN
        ALTER TABLE product_inventory ADD COLUMN deleted INTEGER DEFAULT 0;
    END IF;

    -- 将 updated_at 数据迁移到 update_time（如果 updated_at 存在且 update_time 为空）
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'product_inventory' AND column_name = 'updated_at')
       AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'product_inventory' AND column_name = 'update_time') THEN
        EXECUTE 'UPDATE product_inventory SET update_time = updated_at WHERE update_time IS NULL AND updated_at IS NOT NULL';
    END IF;

    -- ============================================================
    -- 修复 orders 表
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'create_time') THEN
        ALTER TABLE orders ADD COLUMN create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'update_time') THEN
        ALTER TABLE orders ADD COLUMN update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'create_by') THEN
        ALTER TABLE orders ADD COLUMN create_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'update_by') THEN
        ALTER TABLE orders ADD COLUMN update_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'deleted') THEN
        ALTER TABLE orders ADD COLUMN deleted INTEGER DEFAULT 0;
    END IF;

    -- ============================================================
    -- 修复 order_item 表
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'order_item' AND column_name = 'create_time') THEN
        ALTER TABLE order_item ADD COLUMN create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'order_item' AND column_name = 'update_time') THEN
        ALTER TABLE order_item ADD COLUMN update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'order_item' AND column_name = 'create_by') THEN
        ALTER TABLE order_item ADD COLUMN create_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'order_item' AND column_name = 'update_by') THEN
        ALTER TABLE order_item ADD COLUMN update_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'order_item' AND column_name = 'deleted') THEN
        ALTER TABLE order_item ADD COLUMN deleted INTEGER DEFAULT 0;
    END IF;

    -- ============================================================
    -- 修复 bucket_transaction 表
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'bucket_transaction' AND column_name = 'create_time') THEN
        ALTER TABLE bucket_transaction ADD COLUMN create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'bucket_transaction' AND column_name = 'create_by') THEN
        ALTER TABLE bucket_transaction ADD COLUMN create_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'bucket_transaction' AND column_name = 'update_by') THEN
        ALTER TABLE bucket_transaction ADD COLUMN update_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'bucket_transaction' AND column_name = 'deleted') THEN
        ALTER TABLE bucket_transaction ADD COLUMN deleted INTEGER DEFAULT 0;
    END IF;

    -- ============================================================
    -- 修复 driver_return 表
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'driver_return' AND column_name = 'create_time') THEN
        ALTER TABLE driver_return ADD COLUMN create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'driver_return' AND column_name = 'update_time') THEN
        ALTER TABLE driver_return ADD COLUMN update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'driver_return' AND column_name = 'create_by') THEN
        ALTER TABLE driver_return ADD COLUMN create_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'driver_return' AND column_name = 'update_by') THEN
        ALTER TABLE driver_return ADD COLUMN update_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'driver_return' AND column_name = 'deleted') THEN
        ALTER TABLE driver_return ADD COLUMN deleted INTEGER DEFAULT 0;
    END IF;

    -- ============================================================
    -- 修复 monthly_statement 表
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'monthly_statement' AND column_name = 'create_time') THEN
        ALTER TABLE monthly_statement ADD COLUMN create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'monthly_statement' AND column_name = 'update_time') THEN
        ALTER TABLE monthly_statement ADD COLUMN update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'monthly_statement' AND column_name = 'create_by') THEN
        ALTER TABLE monthly_statement ADD COLUMN create_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'monthly_statement' AND column_name = 'update_by') THEN
        ALTER TABLE monthly_statement ADD COLUMN update_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'monthly_statement' AND column_name = 'deleted') THEN
        ALTER TABLE monthly_statement ADD COLUMN deleted INTEGER DEFAULT 0;
    END IF;

    -- ============================================================
    -- 修复 after_sales 表
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'after_sales' AND column_name = 'create_time') THEN
        ALTER TABLE after_sales ADD COLUMN create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'after_sales' AND column_name = 'update_time') THEN
        ALTER TABLE after_sales ADD COLUMN update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'after_sales' AND column_name = 'create_by') THEN
        ALTER TABLE after_sales ADD COLUMN create_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'after_sales' AND column_name = 'update_by') THEN
        ALTER TABLE after_sales ADD COLUMN update_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'after_sales' AND column_name = 'deleted') THEN
        ALTER TABLE after_sales ADD COLUMN deleted INTEGER DEFAULT 0;
    END IF;

    -- ============================================================
    -- 修复 users 表
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'create_time') THEN
        ALTER TABLE users ADD COLUMN create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'update_time') THEN
        ALTER TABLE users ADD COLUMN update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'create_by') THEN
        ALTER TABLE users ADD COLUMN create_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'update_by') THEN
        ALTER TABLE users ADD COLUMN update_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'deleted') THEN
        ALTER TABLE users ADD COLUMN deleted INTEGER DEFAULT 0;
    END IF;

    -- 将 created_at 数据迁移到 create_time（如果 created_at 存在且 create_time 为空）
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'created_at')
       AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'create_time') THEN
        EXECUTE 'UPDATE users SET create_time = created_at WHERE create_time IS NULL AND created_at IS NOT NULL';
    END IF;

    -- ============================================================
    -- 修复 notification 表
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'notification' AND column_name = 'create_time') THEN
        ALTER TABLE notification ADD COLUMN create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'notification' AND column_name = 'update_time') THEN
        ALTER TABLE notification ADD COLUMN update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'notification' AND column_name = 'create_by') THEN
        ALTER TABLE notification ADD COLUMN create_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'notification' AND column_name = 'update_by') THEN
        ALTER TABLE notification ADD COLUMN update_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'notification' AND column_name = 'deleted') THEN
        ALTER TABLE notification ADD COLUMN deleted INTEGER DEFAULT 0;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'notification' AND column_name = 'related_id') THEN
        ALTER TABLE notification ADD COLUMN related_id VARCHAR(100);
    END IF;

    -- 将 created_at 数据迁移到 create_time（如果 created_at 存在且 create_time 为空）
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'notification' AND column_name = 'created_at')
       AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'notification' AND column_name = 'create_time') THEN
        EXECUTE 'UPDATE notification SET create_time = created_at WHERE create_time IS NULL AND created_at IS NOT NULL';
    END IF;

    -- ============================================================
    -- 修复 station_product_price 表
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'station_product_price' AND column_name = 'create_by') THEN
        ALTER TABLE station_product_price ADD COLUMN create_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'station_product_price' AND column_name = 'update_by') THEN
        ALTER TABLE station_product_price ADD COLUMN update_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'station_product_price' AND column_name = 'deleted') THEN
        ALTER TABLE station_product_price ADD COLUMN deleted INTEGER DEFAULT 0;
    END IF;

    -- ============================================================
    -- 修复 product_tier_price 表
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'product_tier_price' AND column_name = 'create_by') THEN
        ALTER TABLE product_tier_price ADD COLUMN create_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'product_tier_price' AND column_name = 'update_by') THEN
        ALTER TABLE product_tier_price ADD COLUMN update_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'product_tier_price' AND column_name = 'deleted') THEN
        ALTER TABLE product_tier_price ADD COLUMN deleted INTEGER DEFAULT 0;
    END IF;

    -- ============================================================
    -- 修复 customer 表
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'customer' AND column_name = 'create_time') THEN
        ALTER TABLE customer ADD COLUMN create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'customer' AND column_name = 'update_time') THEN
        ALTER TABLE customer ADD COLUMN update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'customer' AND column_name = 'create_by') THEN
        ALTER TABLE customer ADD COLUMN create_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'customer' AND column_name = 'update_by') THEN
        ALTER TABLE customer ADD COLUMN update_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'customer' AND column_name = 'deleted') THEN
        ALTER TABLE customer ADD COLUMN deleted INTEGER DEFAULT 0;
    END IF;

    -- ============================================================
    -- 修复 water_ticket 表
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'water_ticket' AND column_name = 'create_by') THEN
        ALTER TABLE water_ticket ADD COLUMN create_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'water_ticket' AND column_name = 'update_by') THEN
        ALTER TABLE water_ticket ADD COLUMN update_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'water_ticket' AND column_name = 'deleted') THEN
        ALTER TABLE water_ticket ADD COLUMN deleted INTEGER DEFAULT 0;
    END IF;

    -- ============================================================
    -- 修复 water_ticket_transaction 表
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'water_ticket_transaction' AND column_name = 'create_by') THEN
        ALTER TABLE water_ticket_transaction ADD COLUMN create_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'water_ticket_transaction' AND column_name = 'update_by') THEN
        ALTER TABLE water_ticket_transaction ADD COLUMN update_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'water_ticket_transaction' AND column_name = 'deleted') THEN
        ALTER TABLE water_ticket_transaction ADD COLUMN deleted INTEGER DEFAULT 0;
    END IF;

    -- ============================================================
    -- 修复 warehouse_inbound 表
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'warehouse_inbound' AND column_name = 'create_by') THEN
        ALTER TABLE warehouse_inbound ADD COLUMN create_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'warehouse_inbound' AND column_name = 'update_by') THEN
        ALTER TABLE warehouse_inbound ADD COLUMN update_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'warehouse_inbound' AND column_name = 'deleted') THEN
        ALTER TABLE warehouse_inbound ADD COLUMN deleted INTEGER DEFAULT 0;
    END IF;

    -- ============================================================
    -- 修复 warehouse_inbound_item 表
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'warehouse_inbound_item' AND column_name = 'create_by') THEN
        ALTER TABLE warehouse_inbound_item ADD COLUMN create_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'warehouse_inbound_item' AND column_name = 'update_by') THEN
        ALTER TABLE warehouse_inbound_item ADD COLUMN update_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'warehouse_inbound_item' AND column_name = 'deleted') THEN
        ALTER TABLE warehouse_inbound_item ADD COLUMN deleted INTEGER DEFAULT 0;
    END IF;

    -- ============================================================
    -- 修复 warehouse_outbound 表
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'warehouse_outbound' AND column_name = 'create_by') THEN
        ALTER TABLE warehouse_outbound ADD COLUMN create_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'warehouse_outbound' AND column_name = 'update_by') THEN
        ALTER TABLE warehouse_outbound ADD COLUMN update_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'warehouse_outbound' AND column_name = 'deleted') THEN
        ALTER TABLE warehouse_outbound ADD COLUMN deleted INTEGER DEFAULT 0;
    END IF;

    -- ============================================================
    -- 修复 warehouse_outbound_item 表
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'warehouse_outbound_item' AND column_name = 'create_by') THEN
        ALTER TABLE warehouse_outbound_item ADD COLUMN create_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'warehouse_outbound_item' AND column_name = 'update_by') THEN
        ALTER TABLE warehouse_outbound_item ADD COLUMN update_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'warehouse_outbound_item' AND column_name = 'deleted') THEN
        ALTER TABLE warehouse_outbound_item ADD COLUMN deleted INTEGER DEFAULT 0;
    END IF;

    -- ============================================================
    -- 修复 driver_statement 表
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'driver_statement' AND column_name = 'create_by') THEN
        ALTER TABLE driver_statement ADD COLUMN create_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'driver_statement' AND column_name = 'update_by') THEN
        ALTER TABLE driver_statement ADD COLUMN update_by VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'driver_statement' AND column_name = 'deleted') THEN
        ALTER TABLE driver_statement ADD COLUMN deleted INTEGER DEFAULT 0;
    END IF;

END $$;

-- ============================================================================
-- 验证修复结果
-- ============================================================================
SELECT '========================================' AS separator;
SELECT '修复完成! 各表列验证:' AS status;
SELECT '========================================' AS separator;

SELECT 'station' AS table_name, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'station'
ORDER BY ordinal_position;

SELECT '----------------------------------------' AS separator;

SELECT 'warehouse' AS table_name, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'warehouse'
ORDER BY ordinal_position;

SELECT '----------------------------------------' AS separator;

SELECT 'driver' AS table_name, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'driver'
ORDER BY ordinal_position;

SELECT '----------------------------------------' AS separator;

SELECT 'product' AS table_name, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'product'
ORDER BY ordinal_position;

SELECT '----------------------------------------' AS separator;

SELECT 'users' AS table_name, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'users'
ORDER BY ordinal_position;

SELECT '========================================' AS separator;
SELECT '修复脚本执行完成!' AS status;
SELECT '========================================' AS separator;
