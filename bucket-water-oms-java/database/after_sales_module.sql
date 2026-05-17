-- =============================================
-- 售后模块数据库表结构
-- 用于水站老板端的售后申请管理
-- =============================================

-- 售后主表
CREATE TABLE IF NOT EXISTS after_sales (
    id BIGSERIAL PRIMARY KEY,
    after_sales_no VARCHAR(50) UNIQUE NOT NULL,
    station_id BIGINT NOT NULL,
    order_id BIGINT NOT NULL,
    type VARCHAR(20) NOT NULL,
    reason TEXT,
    status VARCHAR(20) DEFAULT 'pending',
    handle_result TEXT,
    handle_time TIMESTAMP,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 售后商品明细表
CREATE TABLE IF NOT EXISTS after_sales_item (
    id BIGSERIAL PRIMARY KEY,
    after_sales_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 售后图片表
CREATE TABLE IF NOT EXISTS after_sales_image (
    id BIGSERIAL PRIMARY KEY,
    after_sales_id BIGINT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 索引
CREATE INDEX IF NOT EXISTS idx_after_sales_station_id ON after_sales(station_id);
CREATE INDEX IF NOT EXISTS idx_after_sales_order_id ON after_sales(order_id);
CREATE INDEX IF NOT EXISTS idx_after_sales_status ON after_sales(status);
CREATE INDEX IF NOT EXISTS idx_after_sales_create_time ON after_sales(create_time DESC);
CREATE INDEX IF NOT EXISTS idx_after_sales_item_after_sales_id ON after_sales_item(after_sales_id);
CREATE INDEX IF NOT EXISTS idx_after_sales_image_after_sales_id ON after_sales_image(after_sales_id);

-- 售后单号序列（用于生成唯一序号）
CREATE SEQUENCE IF NOT EXISTS after_sales_no_seq START WITH 1;

-- 添加外键约束
ALTER TABLE after_sales_item
    ADD CONSTRAINT fk_after_sales_item_after_sales
    FOREIGN KEY (after_sales_id) REFERENCES after_sales(id) ON DELETE CASCADE;

ALTER TABLE after_sales_image
    ADD CONSTRAINT fk_after_sales_image_after_sales
    FOREIGN KEY (after_sales_id) REFERENCES after_sales(id) ON DELETE CASCADE;

-- 注释
COMMENT ON TABLE after_sales IS '售后主表';
COMMENT ON COLUMN after_sales.after_sales_no IS '售后单号';
COMMENT ON COLUMN after_sales.station_id IS '水站ID';
COMMENT ON COLUMN after_sales.order_id IS '关联订单ID';
COMMENT ON COLUMN after_sales.type IS '售后类型: replenishment-补货, refund-退款, return-退货';
COMMENT ON COLUMN after_sales.reason IS '售后原因';
COMMENT ON COLUMN after_sales.status IS '状态: pending-待处理, processing-处理中, completed-已完成, rejected-已拒绝';
COMMENT ON COLUMN after_sales.handle_result IS '处理结果';
COMMENT ON COLUMN after_sales.handle_time IS '处理时间';

COMMENT ON TABLE after_sales_item IS '售后商品明细表';
COMMENT ON COLUMN after_sales_item.after_sales_id IS '售后ID';
COMMENT ON COLUMN after_sales_item.product_id IS '商品ID';
COMMENT ON COLUMN after_sales_item.quantity IS '售后数量';

COMMENT ON TABLE after_sales_image IS '售后图片表';
COMMENT ON COLUMN after_sales_image.after_sales_id IS '售后ID';
COMMENT ON COLUMN after_sales_image.image_url IS '图片URL';

-- 创建更新时间触发器函数
CREATE OR REPLACE FUNCTION update_after_sales_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.update_time = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 创建触发器
DROP TRIGGER IF EXISTS update_after_sales_timestamp ON after_sales;
CREATE TRIGGER update_after_sales_timestamp
    BEFORE UPDATE ON after_sales
    FOR EACH ROW
    EXECUTE FUNCTION update_after_sales_timestamp();
