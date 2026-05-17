-- ============================================
-- 产品入库管理模块
-- 创建时间: 2026-04-24
-- 描述: 产品入库（生产入库、采购入库等）管理
-- ============================================

-- ----------------------------------------------------
-- 1. 产品入库表 (product_inbound)
-- 描述: 记录产品入库信息
-- 类型: production(生产入库), purchase(采购入库), transfer_in(调拨入库), return(退货入库)
-- 状态: pending(待确认), confirmed(已入库), rejected(已拒绝)
-- ----------------------------------------------------
CREATE TABLE IF NOT EXISTS product_inbound (
    id BIGSERIAL PRIMARY KEY,
    inbound_no VARCHAR(50) NOT NULL UNIQUE,
    warehouse_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    type VARCHAR(50) NOT NULL DEFAULT 'production',
    quantity INT NOT NULL DEFAULT 0,
    status VARCHAR(50) DEFAULT 'pending',
    source VARCHAR(100),
    remark VARCHAR(500),
    creator VARCHAR(100),
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    confirmer VARCHAR(100),
    confirm_time TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE product_inbound IS '产品入库表';
COMMENT ON COLUMN product_inbound.inbound_no IS '入库单号';
COMMENT ON COLUMN product_inbound.warehouse_id IS '仓库ID';
COMMENT ON COLUMN product_inbound.product_id IS '产品ID';
COMMENT ON COLUMN product_inbound.type IS '入库类型: production/purchase/transfer_in/return';
COMMENT ON COLUMN product_inbound.quantity IS '入库数量';
COMMENT ON COLUMN product_inbound.status IS '状态: pending/confirmed/rejected';
COMMENT ON COLUMN product_inbound.source IS '来源描述';
COMMENT ON COLUMN product_inbound.remark IS '备注';
COMMENT ON COLUMN product_inbound.creator IS '创建人';
COMMENT ON COLUMN product_inbound.create_time IS '创建时间';
COMMENT ON COLUMN product_inbound.confirmer IS '确认人';
COMMENT ON COLUMN product_inbound.confirm_time IS '确认时间';
COMMENT ON COLUMN product_inbound.update_time IS '更新时间';

CREATE INDEX IF NOT EXISTS idx_product_inbound_warehouse ON product_inbound(warehouse_id);
CREATE INDEX IF NOT EXISTS idx_product_inbound_product ON product_inbound(product_id);
CREATE INDEX IF NOT EXISTS idx_product_inbound_status ON product_inbound(status);
CREATE INDEX IF NOT EXISTS idx_product_inbound_type ON product_inbound(type);
CREATE INDEX IF NOT EXISTS idx_product_inbound_create_time ON product_inbound(create_time);

-- ----------------------------------------------------
-- 2. 库存报损表 (inventory_damage)
-- 描述: 记录库存报损信息
-- 类型: damage(损坏), expired(过期), lost(丢失), other(其他)
-- ----------------------------------------------------
CREATE TABLE IF NOT EXISTS inventory_damage (
    id BIGSERIAL PRIMARY KEY,
    damage_no VARCHAR(50) NOT NULL UNIQUE,
    warehouse_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    type VARCHAR(50) NOT NULL DEFAULT 'damage',
    quantity INT NOT NULL DEFAULT 0,
    reason VARCHAR(500),
    reporter VARCHAR(100),
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    handler VARCHAR(100),
    handle_time TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE inventory_damage IS '库存报损表';
COMMENT ON COLUMN inventory_damage.damage_no IS '报损单号';
COMMENT ON COLUMN inventory_damage.warehouse_id IS '仓库ID';
COMMENT ON COLUMN inventory_damage.product_id IS '产品ID';
COMMENT ON COLUMN inventory_damage.type IS '报损类型: damage/expired/lost/other';
COMMENT ON COLUMN inventory_damage.quantity IS '报损数量';
COMMENT ON COLUMN inventory_damage.reason IS '报损原因';
COMMENT ON COLUMN inventory_damage.reporter IS '上报人';
COMMENT ON COLUMN inventory_damage.create_time IS '上报时间';
COMMENT ON COLUMN inventory_damage.handler IS '处理人';
COMMENT ON COLUMN inventory_damage.handle_time IS '处理时间';
COMMENT ON COLUMN inventory_damage.update_time IS '更新时间';

CREATE INDEX IF NOT EXISTS idx_inventory_damage_warehouse ON inventory_damage(warehouse_id);
CREATE INDEX IF NOT EXISTS idx_inventory_damage_product ON inventory_damage(product_id);
CREATE INDEX IF NOT EXISTS idx_inventory_damage_type ON inventory_damage(type);
CREATE INDEX IF NOT EXISTS idx_inventory_damage_create_time ON inventory_damage(create_time);

-- ----------------------------------------------------
-- 3. 创建触发器函数用于自动更新 update_time
-- ----------------------------------------------------
CREATE OR REPLACE FUNCTION update_product_inbound_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.update_time = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_product_inbound_timestamp ON product_inbound;
CREATE TRIGGER update_product_inbound_timestamp
    BEFORE UPDATE ON product_inbound
    FOR EACH ROW
    EXECUTE FUNCTION update_product_inbound_timestamp();

CREATE OR REPLACE FUNCTION update_inventory_damage_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.update_time = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_inventory_damage_timestamp ON inventory_damage;
CREATE TRIGGER update_inventory_damage_timestamp
    BEFORE UPDATE ON inventory_damage
    FOR EACH ROW
    EXECUTE FUNCTION update_inventory_damage_timestamp();

-- ----------------------------------------------------
-- 4. 插入测试数据 (可选，用于开发测试)
-- ----------------------------------------------------
-- INSERT INTO product_inbound (inbound_no, warehouse_id, product_id, type, quantity, status, source, creator)
-- VALUES ('PI202604240001', 1, 1, 'production', 500, 'confirmed', '一号车间', '管理员');
--
-- INSERT INTO inventory_damage (damage_no, warehouse_id, product_id, type, quantity, reason, reporter)
-- VALUES ('DMG202604240001', 1, 2, 'damage', 12, '运输途损', '李小龙');
