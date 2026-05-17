-- ============================================
-- 产品库存变动流水模块
-- 创建时间: 2026-04-25
-- 描述: 统一记录每个产品的出入库流水，支持查询每个产品的所有出入库记录
-- ============================================

-- ----------------------------------------------------
-- 1. 产品库存变动流水表 (product_inventory_transaction)
-- 描述: 记录每个产品的所有库存变动，包括入库和出库
-- 变动类型: INBOUND(入库), OUTBOUND(出库)
-- 入库类型: production(生产入库), purchase(采购入库), transfer_in(调拨入库), return(退货入库), check_in(盘盈入库)
-- 出库类型: order(订单出库), damage(报损出库), transfer_out(调拨出库), check_out(盘亏出库), return_to_supplier(退货给供应商)
-- ----------------------------------------------------
CREATE TABLE IF NOT EXISTS product_inventory_transaction (
    id BIGSERIAL PRIMARY KEY,
    transaction_no VARCHAR(50) NOT NULL UNIQUE,
    warehouse_id BIGINT NOT NULL,
    warehouse_name VARCHAR(100),
    product_id BIGINT NOT NULL,
    product_name VARCHAR(100),
    product_category VARCHAR(50),
    transaction_type VARCHAR(20) NOT NULL,
    detail_type VARCHAR(50) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(12, 2) DEFAULT 0,
    total_amount DECIMAL(12, 2) DEFAULT 0,
    balance_before INT NOT NULL DEFAULT 0,
    balance_after INT NOT NULL DEFAULT 0,
    related_order_no VARCHAR(50),
    related_business_no VARCHAR(50),
    source VARCHAR(100),
    destination VARCHAR(100),
    remark VARCHAR(500),
    operator VARCHAR(100),
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE product_inventory_transaction IS '产品库存变动流水表';
COMMENT ON COLUMN product_inventory_transaction.transaction_no IS '流水单号';
COMMENT ON COLUMN product_inventory_transaction.warehouse_id IS '仓库ID';
COMMENT ON COLUMN product_inventory_transaction.warehouse_name IS '仓库名称';
COMMENT ON COLUMN product_inventory_transaction.product_id IS '产品ID';
COMMENT ON COLUMN product_inventory_transaction.product_name IS '产品名称';
COMMENT ON COLUMN product_inventory_transaction.product_category IS '产品分类';
COMMENT ON COLUMN product_inventory_transaction.transaction_type IS '变动类型: INBOUND-入库, OUTBOUND-出库';
COMMENT ON COLUMN product_inventory_transaction.detail_type IS '明细类型: production/purchase/transfer_in/return/check_in/order/damage/transfer_out/check_out';
COMMENT ON COLUMN product_inventory_transaction.quantity IS '变动数量(正数)';
COMMENT ON COLUMN product_inventory_transaction.unit_price IS '单价';
COMMENT ON COLUMN product_inventory_transaction.total_amount IS '总金额';
COMMENT ON COLUMN product_inventory_transaction.balance_before IS '变动前库存';
COMMENT ON COLUMN product_inventory_transaction.balance_after IS '变动后库存';
COMMENT ON COLUMN product_inventory_transaction.related_order_no IS '关联订单号';
COMMENT ON COLUMN product_inventory_transaction.related_business_no IS '关联业务单号(如入库单号、出库单号)';
COMMENT ON COLUMN product_inventory_transaction.source IS '来源(入库来源/出库原因)';
COMMENT ON COLUMN product_inventory_transaction.destination IS '目的地';
COMMENT ON COLUMN product_inventory_transaction.remark IS '备注';
COMMENT ON COLUMN product_inventory_transaction.operator IS '操作人';

-- 索引
CREATE INDEX IF NOT EXISTS idx_inventory_transaction_warehouse ON product_inventory_transaction(warehouse_id);
CREATE INDEX IF NOT EXISTS idx_inventory_transaction_product ON product_inventory_transaction(product_id);
CREATE INDEX IF NOT EXISTS idx_inventory_transaction_type ON product_inventory_transaction(transaction_type);
CREATE INDEX IF NOT EXISTS idx_inventory_transaction_detail_type ON product_inventory_transaction(detail_type);
CREATE INDEX IF NOT EXISTS idx_inventory_transaction_order ON product_inventory_transaction(related_order_no);
CREATE INDEX IF NOT EXISTS idx_inventory_transaction_business ON product_inventory_transaction(related_business_no);
CREATE INDEX IF NOT EXISTS idx_inventory_transaction_create_time ON product_inventory_transaction(create_time);

-- ----------------------------------------------------
-- 2. 产品库存盘点记录表 (product_inventory_check)
-- 描述: 记录库存盘点结果，每个产品一条记录
-- 状态: pending(待确认), confirmed(已确认)
-- ----------------------------------------------------
CREATE TABLE IF NOT EXISTS product_inventory_check (
    id BIGSERIAL PRIMARY KEY,
    check_no VARCHAR(50) NOT NULL UNIQUE,
    warehouse_id BIGINT NOT NULL,
    warehouse_name VARCHAR(100),
    product_id BIGINT NOT NULL,
    product_name VARCHAR(100),
    product_category VARCHAR(50),
    system_quantity INT NOT NULL DEFAULT 0,
    actual_quantity INT NOT NULL DEFAULT 0,
    discrepancy INT NOT NULL DEFAULT 0,
    discrepancy_type VARCHAR(20),
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    checker VARCHAR(100),
    check_time TIMESTAMP,
    remark VARCHAR(500),
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE product_inventory_check IS '产品库存盘点记录表';
COMMENT ON COLUMN product_inventory_check.check_no IS '盘点单号';
COMMENT ON COLUMN product_inventory_check.warehouse_id IS '仓库ID';
COMMENT ON COLUMN product_inventory_check.warehouse_name IS '仓库名称';
COMMENT ON COLUMN product_inventory_check.product_id IS '产品ID';
COMMENT ON COLUMN product_inventory_check.product_name IS '产品名称';
COMMENT ON COLUMN product_inventory_check.product_category IS '产品分类';
COMMENT ON COLUMN product_inventory_check.system_quantity IS '系统库存';
COMMENT ON COLUMN product_inventory_check.actual_quantity IS '实际库存';
COMMENT ON COLUMN product_inventory_check.discrepancy IS '差异数量(正数为盘盈,负数为盘亏)';
COMMENT ON COLUMN product_inventory_check.discrepancy_type IS '差异类型: surplus-盘盈, loss-盘亏, matched-无差异';
COMMENT ON COLUMN product_inventory_check.status IS '状态: pending-待确认, confirmed-已确认';
COMMENT ON COLUMN product_inventory_check.checker IS '盘点人';
COMMENT ON COLUMN product_inventory_check.check_time IS '盘点时间';
COMMENT ON COLUMN product_inventory_check.remark IS '备注';

-- 索引
CREATE INDEX IF NOT EXISTS idx_product_inventory_check_warehouse ON product_inventory_check(warehouse_id);
CREATE INDEX IF NOT EXISTS idx_product_inventory_check_product ON product_inventory_check(product_id);
CREATE INDEX IF NOT EXISTS idx_product_inventory_check_status ON product_inventory_check(status);
CREATE INDEX IF NOT EXISTS idx_product_inventory_check_create_time ON product_inventory_check(create_time);

-- ----------------------------------------------------
-- 3. 库存盘点任务表 (inventory_check_task)
-- 描述: 记录盘点任务，一个任务可以包含多个产品
-- 状态: in_progress(盘点中), completed(已完成), cancelled(已取消)
-- ----------------------------------------------------
CREATE TABLE IF NOT EXISTS inventory_check_task (
    id BIGSERIAL PRIMARY KEY,
    task_no VARCHAR(50) NOT NULL UNIQUE,
    warehouse_id BIGINT NOT NULL,
    warehouse_name VARCHAR(100),
    status VARCHAR(20) NOT NULL DEFAULT 'in_progress',
    total_products INT DEFAULT 0,
    checked_products INT DEFAULT 0,
    surplus_count INT DEFAULT 0,
    loss_count INT DEFAULT 0,
    matched_count INT DEFAULT 0,
    summary TEXT,
    creator VARCHAR(100),
    checker VARCHAR(100),
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE inventory_check_task IS '库存盘点任务表';
COMMENT ON COLUMN inventory_check_task.task_no IS '任务单号';
COMMENT ON COLUMN inventory_check_task.warehouse_id IS '仓库ID';
COMMENT ON COLUMN inventory_check_task.warehouse_name IS '仓库名称';
COMMENT ON COLUMN inventory_check_task.status IS '状态: in_progress-盘点中, completed-已完成, cancelled-已取消';
COMMENT ON COLUMN inventory_check_task.total_products IS '总产品数';
COMMENT ON COLUMN inventory_check_task.checked_products IS '已盘点产品数';
COMMENT ON COLUMN inventory_check_task.surplus_count IS '盘盈产品数';
COMMENT ON COLUMN inventory_check_task.loss_count IS '盘亏产品数';
COMMENT ON COLUMN inventory_check_task.matched_count IS '无差异产品数';
COMMENT ON COLUMN inventory_check_task.summary IS '盘点总结';
COMMENT ON COLUMN inventory_check_task.creator IS '创建人';
COMMENT ON COLUMN inventory_check_task.checker IS '确认人';
COMMENT ON COLUMN inventory_check_task.start_time IS '开始时间';
COMMENT ON COLUMN inventory_check_task.end_time IS '结束时间';

-- 索引
CREATE INDEX IF NOT EXISTS idx_inventory_check_task_warehouse ON inventory_check_task(warehouse_id);
CREATE INDEX IF NOT EXISTS idx_inventory_check_task_status ON inventory_check_task(status);
CREATE INDEX IF NOT EXISTS idx_inventory_check_task_create_time ON inventory_check_task(create_time);

-- ----------------------------------------------------
-- 4. 库存盘点任务明细表 (inventory_check_task_item)
-- 描述: 记录盘点任务中的每个产品盘点结果
-- ----------------------------------------------------
CREATE TABLE IF NOT EXISTS inventory_check_task_item (
    id BIGSERIAL PRIMARY KEY,
    task_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    product_name VARCHAR(100),
    product_category VARCHAR(50),
    system_quantity INT NOT NULL DEFAULT 0,
    actual_quantity INT DEFAULT 0,
    discrepancy INT DEFAULT 0,
    discrepancy_type VARCHAR(20),
    remark VARCHAR(500),
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE inventory_check_task_item IS '库存盘点任务明细表';
COMMENT ON COLUMN inventory_check_task_item.task_id IS '任务ID';
COMMENT ON COLUMN inventory_check_task_item.product_id IS '产品ID';
COMMENT ON COLUMN inventory_check_task_item.product_name IS '产品名称';
COMMENT ON COLUMN inventory_check_task_item.product_category IS '产品分类';
COMMENT ON COLUMN inventory_check_task_item.system_quantity IS '系统库存';
COMMENT ON COLUMN inventory_check_task_item.actual_quantity IS '实际库存';
COMMENT ON COLUMN inventory_check_task_item.discrepancy IS '差异数量';
COMMENT ON COLUMN inventory_check_task_item.discrepancy_type IS '差异类型: surplus-盘盈, loss-盘亏, matched-无差异';

-- 索引
CREATE INDEX IF NOT EXISTS idx_inventory_check_task_item_task ON inventory_check_task_item(task_id);
CREATE INDEX IF NOT EXISTS idx_inventory_check_task_item_product ON inventory_check_task_item(product_id);

-- 外键约束
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE constraint_name = 'fk_inventory_check_task_item_task'
    ) THEN
        ALTER TABLE inventory_check_task_item ADD CONSTRAINT fk_inventory_check_task_item_task
            FOREIGN KEY (task_id) REFERENCES inventory_check_task(id) ON DELETE CASCADE;
    END IF;
END $$;

-- ----------------------------------------------------
-- 5. 创建触发器函数用于自动更新 update_time
-- ----------------------------------------------------
CREATE OR REPLACE FUNCTION update_product_inventory_transaction_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.update_time = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_product_inventory_transaction_timestamp ON product_inventory_transaction;
CREATE TRIGGER update_product_inventory_transaction_timestamp
    BEFORE UPDATE ON product_inventory_transaction
    FOR EACH ROW
    EXECUTE FUNCTION update_product_inventory_transaction_timestamp();

CREATE OR REPLACE FUNCTION update_product_inventory_check_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.update_time = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_product_inventory_check_timestamp ON product_inventory_check;
CREATE TRIGGER update_product_inventory_check_timestamp
    BEFORE UPDATE ON product_inventory_check
    FOR EACH ROW
    EXECUTE FUNCTION update_product_inventory_check_timestamp();

CREATE OR REPLACE FUNCTION update_inventory_check_task_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.update_time = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_inventory_check_task_timestamp ON inventory_check_task;
CREATE TRIGGER update_inventory_check_task_timestamp
    BEFORE UPDATE ON inventory_check_task
    FOR EACH ROW
    EXECUTE FUNCTION update_inventory_check_task_timestamp();

CREATE OR REPLACE FUNCTION update_inventory_check_task_item_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.update_time = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_inventory_check_task_item_timestamp ON inventory_check_task_item;
CREATE TRIGGER update_inventory_check_task_item_timestamp
    BEFORE UPDATE ON inventory_check_task_item
    FOR EACH ROW
    EXECUTE FUNCTION update_inventory_check_task_item_timestamp();
