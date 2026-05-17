-- ============================================================================
-- 添加 driver 表的 warehouse_id 字段
-- ============================================================================

-- 检查字段是否已存在
DO $$
BEGIN
    -- 添加 warehouse_id 字段
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'driver' AND column_name = 'warehouse_id'
    ) THEN
        ALTER TABLE driver ADD COLUMN warehouse_id BIGINT;
        RAISE NOTICE '成功添加 warehouse_id 字段到 driver 表';
    ELSE
        RAISE NOTICE 'warehouse_id 字段已存在，跳过';
    END IF;
END $$;

-- 添加索引
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes
        WHERE tablename = 'driver' AND indexname = 'idx_driver_warehouse_id'
    ) THEN
        CREATE INDEX idx_driver_warehouse_id ON driver(warehouse_id);
        RAISE NOTICE '成功创建仓库ID索引';
    ELSE
        RAISE NOTICE '索引 idx_driver_warehouse_id 已存在，跳过';
    END IF;
END $$;

-- 显示结果
SELECT 'driver 表当前结构:' AS info;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'driver'
ORDER BY ordinal_position;
