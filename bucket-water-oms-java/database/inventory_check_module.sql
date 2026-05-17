-- 库存盘点模块
-- 包含库存盘点主表和明细表

-- 1. 库存盘点主表
CREATE TABLE IF NOT EXISTS inventory_check (
    id BIGSERIAL PRIMARY KEY,
    warehouse_id BIGINT NOT NULL,
    warehouse_name VARCHAR(100),
    check_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    checker VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    summary TEXT,
    total_products INTEGER DEFAULT 0,
    matched_products INTEGER DEFAULT 0,
    discrepancy_products INTEGER DEFAULT 0,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    create_by VARCHAR(50),
    update_by VARCHAR(50),
    deleted INTEGER DEFAULT 0
);

COMMENT ON TABLE inventory_check IS '库存盘点主表';
COMMENT ON COLUMN inventory_check.id IS '盘点ID';
COMMENT ON COLUMN inventory_check.warehouse_id IS '仓库ID';
COMMENT ON COLUMN inventory_check.warehouse_name IS '仓库名称';
COMMENT ON COLUMN inventory_check.check_date IS '盘点日期';
COMMENT ON COLUMN inventory_check.checker IS '盘点人';
COMMENT ON COLUMN inventory_check.status IS '状态: pending-待确认, confirmed-已确认';
COMMENT ON COLUMN inventory_check.summary IS '盘点总结';
COMMENT ON COLUMN inventory_check.total_products IS '商品总数';
COMMENT ON COLUMN inventory_check.matched_products IS '一致商品数';
COMMENT ON COLUMN inventory_check.discrepancy_products IS '差异商品数';

-- 2. 库存盘点明细表
CREATE TABLE IF NOT EXISTS inventory_check_item (
    id BIGSERIAL PRIMARY KEY,
    check_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    product_name VARCHAR(100),
    category VARCHAR(50),
    system_quantity INTEGER NOT NULL DEFAULT 0,
    actual_quantity INTEGER NOT NULL DEFAULT 0,
    discrepancy INTEGER DEFAULT 0,
    remark TEXT,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted INTEGER DEFAULT 0
);

COMMENT ON TABLE inventory_check_item IS '库存盘点明细表';
COMMENT ON COLUMN inventory_check_item.id IS '明细ID';
COMMENT ON COLUMN inventory_check_item.check_id IS '盘点ID';
COMMENT ON COLUMN inventory_check_item.product_id IS '商品ID';
COMMENT ON COLUMN inventory_check_item.product_name IS '商品名称';
COMMENT ON COLUMN inventory_check_item.category IS '商品分类';
COMMENT ON COLUMN inventory_check_item.system_quantity IS '系统库存';
COMMENT ON COLUMN inventory_check_item.actual_quantity IS '实际库存';
COMMENT ON COLUMN inventory_check_item.discrepancy IS '差异数量';
COMMENT ON COLUMN inventory_check_item.remark IS '备注说明';

-- 3. 创建索引
CREATE INDEX IF NOT EXISTS idx_inventory_check_warehouse ON inventory_check(warehouse_id);
CREATE INDEX IF NOT EXISTS idx_inventory_check_date ON inventory_check(check_date);
CREATE INDEX IF NOT EXISTS idx_inventory_check_status ON inventory_check(status);
CREATE INDEX IF NOT EXISTS idx_inventory_check_item_check ON inventory_check_item(check_id);
CREATE INDEX IF NOT EXISTS idx_inventory_check_item_product ON inventory_check_item(product_id);

-- 4. 条件创建外键约束（如果不存在则添加）
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'fk_inventory_check_item_check'
    ) THEN
        ALTER TABLE inventory_check_item ADD CONSTRAINT fk_inventory_check_item_check
            FOREIGN KEY (check_id) REFERENCES inventory_check(id) ON DELETE CASCADE;
    END IF;
END $$;

-- 5. 创建更新时间触发器函数
CREATE OR REPLACE FUNCTION update_inventory_check_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.update_time = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 6. 条件创建触发器
DROP TRIGGER IF EXISTS update_inventory_check_timestamp ON inventory_check;
CREATE TRIGGER update_inventory_check_timestamp
    BEFORE UPDATE ON inventory_check
    FOR EACH ROW
    EXECUTE FUNCTION update_inventory_check_timestamp();

DROP TRIGGER IF EXISTS update_inventory_check_item_timestamp ON inventory_check_item;
CREATE TRIGGER update_inventory_check_item_timestamp
    BEFORE UPDATE ON inventory_check_item
    FOR EACH ROW
    EXECUTE FUNCTION update_inventory_check_timestamp();
