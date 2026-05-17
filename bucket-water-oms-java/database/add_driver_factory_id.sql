-- 添加司机表水厂关联字段
-- 执行时间: 2026-05-17

-- 添加 factory_id 字段到 driver 表（如果不存在）
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'driver' AND column_name = 'factory_id'
    ) THEN
        ALTER TABLE driver ADD COLUMN factory_id BIGINT;
        RAISE NOTICE 'factory_id column added to driver table';
    ELSE
        RAISE NOTICE 'factory_id column already exists in driver table';
    END IF;
END $$;

-- 添加注释
COMMENT ON COLUMN driver.factory_id IS '所属水厂ID，关联factory表';

-- 创建索引（如果不存在）
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes
        WHERE tablename = 'driver' AND indexname = 'idx_driver_factory_id'
    ) THEN
        CREATE INDEX idx_driver_factory_id ON driver(factory_id);
        RAISE NOTICE 'Index idx_driver_factory_id created';
    ELSE
        RAISE NOTICE 'Index idx_driver_factory_id already exists';
    END IF;
END $$;

-- 同步更新现有数据：如果司机有warehouse_id，将factory_id设置为对应仓库的factory_id
UPDATE driver
SET factory_id = (
    SELECT w.factory_id
    FROM warehouse w
    WHERE w.id = driver.warehouse_id
    LIMIT 1
)
WHERE driver.factory_id IS NULL AND driver.warehouse_id IS NOT NULL;

-- 添加外键约束（可选，如果需要严格的数据完整性）
-- 注意：只有在确认数据一致性后才可以添加外键
-- ALTER TABLE driver ADD CONSTRAINT fk_driver_factory
--     FOREIGN KEY (factory_id) REFERENCES factory(id) ON DELETE SET NULL;

-- 添加索引以优化通过warehouse_id查询factory_id的效率
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes
        WHERE tablename = 'warehouse' AND indexname = 'idx_warehouse_factory_id'
    ) THEN
        CREATE INDEX idx_warehouse_factory_id ON warehouse(factory_id);
        RAISE NOTICE 'Index idx_warehouse_factory_id created on warehouse table';
    ELSE
        RAISE NOTICE 'Index idx_warehouse_factory_id already exists';
    END IF;
END $$;
