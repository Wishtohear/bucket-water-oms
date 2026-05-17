-- 司机仓库关联表 - 支持一个司机绑定多个仓库
-- 用于存储司机与仓库的多对多关系

-- 创建司机仓库关联表
CREATE TABLE IF NOT EXISTS driver_warehouse (
    id BIGSERIAL PRIMARY KEY,
    driver_id BIGINT NOT NULL,
    warehouse_id BIGINT NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,  -- 是否主仓库
    status VARCHAR(20) DEFAULT 'active',  -- active/inactive
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    create_by VARCHAR(100),
    update_by VARCHAR(100),
    deleted SMALLINT DEFAULT 0
);

-- 添加注释
COMMENT ON TABLE driver_warehouse IS '司机仓库关联表';
COMMENT ON COLUMN driver_warehouse.id IS '主键ID';
COMMENT ON COLUMN driver_warehouse.driver_id IS '司机ID';
COMMENT ON COLUMN driver_warehouse.warehouse_id IS '仓库ID';
COMMENT ON COLUMN driver_warehouse.is_primary IS '是否主仓库';
COMMENT ON COLUMN driver_warehouse.status IS '状态: active-生效, inactive-失效';
COMMENT ON COLUMN driver_warehouse.create_time IS '创建时间';
COMMENT ON COLUMN driver_warehouse.update_time IS '更新时间';
COMMENT ON COLUMN driver_warehouse.deleted IS '逻辑删除标记';

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_driver_warehouse_driver ON driver_warehouse(driver_id);
CREATE INDEX IF NOT EXISTS idx_driver_warehouse_warehouse ON driver_warehouse(warehouse_id);
CREATE INDEX IF NOT EXISTS idx_driver_warehouse_deleted ON driver_warehouse(deleted);

-- 创建唯一约束：同一司机同一仓库只能有一条记录
CREATE UNIQUE INDEX IF NOT EXISTS idx_driver_warehouse_unique
ON driver_warehouse(driver_id, warehouse_id) WHERE deleted = 0;

-- 触发器函数：更新update_time
CREATE OR REPLACE FUNCTION update_driver_warehouse_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.update_time = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 创建触发器
DROP TRIGGER IF EXISTS update_driver_warehouse_timestamp ON driver_warehouse;
CREATE TRIGGER update_driver_warehouse_timestamp
    BEFORE UPDATE ON driver_warehouse
    FOR EACH ROW
    EXECUTE FUNCTION update_driver_warehouse_timestamp();

-- 数据迁移：将现有的 driver.warehouse_id 数据迁移到 driver_warehouse 表
-- 注意：此迁移脚本只执行一次，需要先检查是否已有迁移数据
DO $$
DECLARE
    v_count INTEGER;
BEGIN
    -- 检查是否已有迁移数据
    SELECT COUNT(*) INTO v_count FROM driver_warehouse WHERE deleted = 0;

    -- 如果表已有数据且驱动表也有warehouse_id，则进行迁移
    IF v_count = 0 THEN
        -- 从 driver 表迁移数据到 driver_warehouse 表
        INSERT INTO driver_warehouse (driver_id, warehouse_id, is_primary, create_time, update_time)
        SELECT id, warehouse_id, TRUE, create_time, update_time
        FROM driver
        WHERE warehouse_id IS NOT NULL AND warehouse_id > 0
        ON CONFLICT (driver_id, warehouse_id) WHERE deleted = 0 DO NOTHING;

        RAISE NOTICE '数据迁移完成';
    ELSE
        RAISE NOTICE 'driver_warehouse 表已有数据，跳过迁移';
    END IF;
END $$;
