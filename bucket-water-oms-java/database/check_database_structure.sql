-- ============================================================================
-- 数据库状态诊断脚本
-- ============================================================================

-- 1. 查看所有表
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- 2. 查看 orders 表结构（使用双引号以防表名是大写）
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'orders' OR table_name = '"orders"'
ORDER BY ordinal_position;

-- 3. 如果 orders 表不存在，显示所有包含 'order' 的表
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND (table_name ILIKE '%order%' OR table_name ILIKE '%Orders%')
ORDER BY table_name;

-- 4. 检查表是否存在（使用不同的大小写）
SELECT EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'orders'
) AS orders_exists;

SELECT EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'Orders'
) AS Orders_exists;

SELECT EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'ORDERS'
) AS ORDERS_exists;

-- 5. 如果 orders 表已存在，添加 remark 列
DO $$
BEGIN
    -- 检查表是否存在
    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'orders'
    ) THEN
        -- 检查 remark 列是否已存在
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_schema = 'public' AND table_name = 'orders' AND column_name = 'remark'
        ) THEN
            ALTER TABLE orders ADD COLUMN remark TEXT;
            RAISE NOTICE '✓ 已添加 remark 列到 orders 表';
        ELSE
            RAISE NOTICE '✓ orders 表已有 remark 列';
        END IF;
    ELSE
        RAISE NOTICE '✗ orders 表不存在！请先运行 wateroms_init.sql 初始化数据库';
    END IF;
END $$;

-- 6. 显示最终的 orders 表结构
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'orders'
ORDER BY ordinal_position;
