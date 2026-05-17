-- ============================================
-- 空桶出入库管理模块
-- 创建时间: 2026-04-24
-- 描述: 空桶入库、出库、回仓申请管理
-- ============================================

-- ----------------------------------------------------
-- 1. 空桶入库表 (bucket_inbound)
-- 描述: 记录空桶入库信息
-- 类型: driver_return(司机回桶), clean(清洗入库), transfer_in(调拨入库)
-- 状态: pending(待核验), confirmed(已入库), rejected(已拒绝)
-- ----------------------------------------------------
CREATE TABLE IF NOT EXISTS bucket_inbound (
    id BIGSERIAL PRIMARY KEY,
    inbound_no VARCHAR(50) NOT NULL UNIQUE,
    warehouse_id BIGINT NOT NULL,
    driver_id BIGINT,
    type VARCHAR(50) NOT NULL,
    bucket_type VARCHAR(50) DEFAULT '18.9L标准桶',
    quantity INT NOT NULL DEFAULT 0,
    status VARCHAR(50) DEFAULT 'pending',
    source VARCHAR(100),
    remark VARCHAR(500),
    creator VARCHAR(100),
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    checker VARCHAR(100),
    check_time TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE bucket_inbound IS '空桶入库表';
COMMENT ON COLUMN bucket_inbound.inbound_no IS '入库单号';
COMMENT ON COLUMN bucket_inbound.warehouse_id IS '仓库ID';
COMMENT ON COLUMN bucket_inbound.driver_id IS '司机ID';
COMMENT ON COLUMN bucket_inbound.type IS '入库类型: driver_return/clean/transfer_in';
COMMENT ON COLUMN bucket_inbound.bucket_type IS '桶类型: 18.9L标准桶/11.3L迷你桶等';
COMMENT ON COLUMN bucket_inbound.quantity IS '入库数量';
COMMENT ON COLUMN bucket_inbound.status IS '状态: pending/confirmed/rejected';
COMMENT ON COLUMN bucket_inbound.source IS '来源描述';
COMMENT ON COLUMN bucket_inbound.remark IS '备注';
COMMENT ON COLUMN bucket_inbound.creator IS '创建人';
COMMENT ON COLUMN bucket_inbound.create_time IS '创建时间';
COMMENT ON COLUMN bucket_inbound.checker IS '核验人';
COMMENT ON COLUMN bucket_inbound.check_time IS '核验时间';
COMMENT ON COLUMN bucket_inbound.update_time IS '更新时间';

CREATE INDEX IF NOT EXISTS idx_bucket_inbound_warehouse ON bucket_inbound(warehouse_id);
CREATE INDEX IF NOT EXISTS idx_bucket_inbound_driver ON bucket_inbound(driver_id);
CREATE INDEX IF NOT EXISTS idx_bucket_inbound_status ON bucket_inbound(status);
CREATE INDEX IF NOT EXISTS idx_bucket_inbound_type ON bucket_inbound(type);
CREATE INDEX IF NOT EXISTS idx_bucket_inbound_create_time ON bucket_inbound(create_time);

-- ----------------------------------------------------
-- 2. 空桶出库表 (bucket_outbound)
-- 描述: 记录空桶出库信息
-- 类型: driver_pickup(司机领用), transfer_out(调拨出库), damage(损耗出库)
-- 状态: pending(待出库), confirmed(已出库), rejected(已拒绝)
-- ----------------------------------------------------
CREATE TABLE IF NOT EXISTS bucket_outbound (
    id BIGSERIAL PRIMARY KEY,
    outbound_no VARCHAR(50) NOT NULL UNIQUE,
    warehouse_id BIGINT NOT NULL,
    driver_id BIGINT,
    type VARCHAR(50) NOT NULL,
    bucket_type VARCHAR(50) DEFAULT '18.9L标准桶',
    quantity INT NOT NULL DEFAULT 0,
    status VARCHAR(50) DEFAULT 'pending',
    destination VARCHAR(100),
    remark VARCHAR(500),
    creator VARCHAR(100),
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    confirmer VARCHAR(100),
    confirm_time TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE bucket_outbound IS '空桶出库表';
COMMENT ON COLUMN bucket_outbound.outbound_no IS '出库单号';
COMMENT ON COLUMN bucket_outbound.warehouse_id IS '仓库ID';
COMMENT ON COLUMN bucket_outbound.driver_id IS '司机ID';
COMMENT ON COLUMN bucket_outbound.type IS '出库类型: driver_pickup/transfer_out/damage';
COMMENT ON COLUMN bucket_outbound.bucket_type IS '桶类型: 18.9L标准桶/11.3L迷你桶等';
COMMENT ON COLUMN bucket_outbound.quantity IS '出库数量';
COMMENT ON COLUMN bucket_outbound.status IS '状态: pending/confirmed/rejected';
COMMENT ON COLUMN bucket_outbound.destination IS '去向描述';
COMMENT ON COLUMN bucket_outbound.remark IS '备注';
COMMENT ON COLUMN bucket_outbound.creator IS '创建人';
COMMENT ON COLUMN bucket_outbound.create_time IS '创建时间';
COMMENT ON COLUMN bucket_outbound.confirmer IS '确认人';
COMMENT ON COLUMN bucket_outbound.confirm_time IS '确认时间';
COMMENT ON COLUMN bucket_outbound.update_time IS '更新时间';

CREATE INDEX IF NOT EXISTS idx_bucket_outbound_warehouse ON bucket_outbound(warehouse_id);
CREATE INDEX IF NOT EXISTS idx_bucket_outbound_driver ON bucket_outbound(driver_id);
CREATE INDEX IF NOT EXISTS idx_bucket_outbound_status ON bucket_outbound(status);
CREATE INDEX IF NOT EXISTS idx_bucket_outbound_type ON bucket_outbound(type);
CREATE INDEX IF NOT EXISTS idx_bucket_outbound_create_time ON bucket_outbound(create_time);

-- ----------------------------------------------------
-- 3. 为 orders 表添加拒单相关字段 (如果不存在)
-- ----------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'reject_reason') THEN
        ALTER TABLE orders ADD COLUMN reject_reason VARCHAR(500);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'stock_details') THEN
        ALTER TABLE orders ADD COLUMN stock_details TEXT;
    END IF;
END $$;

-- ----------------------------------------------------
-- 4. 创建触发器函数用于自动更新 update_time
-- ----------------------------------------------------
CREATE OR REPLACE FUNCTION update_bucket_inbound_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.update_time = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_bucket_inbound_timestamp ON bucket_inbound;
CREATE TRIGGER update_bucket_inbound_timestamp
    BEFORE UPDATE ON bucket_inbound
    FOR EACH ROW
    EXECUTE FUNCTION update_bucket_inbound_timestamp();

CREATE OR REPLACE FUNCTION update_bucket_outbound_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.update_time = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_bucket_outbound_timestamp ON bucket_outbound;
CREATE TRIGGER update_bucket_outbound_timestamp
    BEFORE UPDATE ON bucket_outbound
    FOR EACH ROW
    EXECUTE FUNCTION update_bucket_outbound_timestamp();

-- ----------------------------------------------------
-- 5. 插入测试数据 (可选，用于开发测试)
-- ----------------------------------------------------
-- INSERT INTO bucket_inbound (inbound_no, warehouse_id, driver_id, type, bucket_type, quantity, status, source)
-- VALUES ('IN202604240001', 1, 1, 'driver_return', '18.9L标准桶', 50, 'pending', '司机回桶-订单ORD202604010001');
--
-- INSERT INTO bucket_outbound (outbound_no, warehouse_id, driver_id, type, bucket_type, quantity, status, destination)
-- VALUES ('OUT202604240001', 1, 1, 'driver_pickup', '18.9L标准桶', 30, 'pending', '司机领用配送');
