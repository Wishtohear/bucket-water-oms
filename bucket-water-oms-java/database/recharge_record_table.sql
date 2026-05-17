-- 充值记录表
CREATE TABLE IF NOT EXISTS recharge_record (
    id BIGINT PRIMARY KEY,
    station_id BIGINT NOT NULL,
    station_name VARCHAR(200),
    amount DECIMAL(12, 2) NOT NULL,
    balance_after DECIMAL(12, 2),
    pay_type VARCHAR(50) DEFAULT 'wechat',
    status VARCHAR(50) DEFAULT 'pending',
    wechat_order_no VARCHAR(100),
    transaction_id VARCHAR(100),
    prepay_id VARCHAR(100),
    user_id BIGINT,
    user_name VARCHAR(100),
    remark VARCHAR(500),
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    pay_time TIMESTAMP,
    expire_time TIMESTAMP,
    operator VARCHAR(100),
    deleted INTEGER DEFAULT 0
);

-- 索引
CREATE INDEX IF NOT EXISTS idx_recharge_station ON recharge_record(station_id);
CREATE INDEX IF NOT EXISTS idx_recharge_status ON recharge_record(status);
CREATE INDEX IF NOT EXISTS idx_recharge_create_time ON recharge_record(create_time);
CREATE INDEX IF NOT EXISTS idx_recharge_wechat_order ON recharge_record(wechat_order_no);

COMMENT ON TABLE recharge_record IS '充值记录表';
COMMENT ON COLUMN recharge_record.id IS '充值记录ID';
COMMENT ON COLUMN recharge_record.station_id IS '水站ID';
COMMENT ON COLUMN recharge_record.station_name IS '水站名称';
COMMENT ON COLUMN recharge_record.amount IS '充值金额';
COMMENT ON COLUMN recharge_record.balance_after IS '充值后余额';
COMMENT ON COLUMN recharge_record.pay_type IS '支付类型: wechat/alipay/balance';
COMMENT ON COLUMN recharge_record.status IS '支付状态: pending/success/failed';
COMMENT ON COLUMN recharge_record.wechat_order_no IS '微信支付订单号';
COMMENT ON COLUMN recharge_record.transaction_id IS '微信支付交易号';
COMMENT ON COLUMN recharge_record.prepay_id IS '预支付交易会话标识';
COMMENT ON COLUMN recharge_record.user_id IS '用户ID';
COMMENT ON COLUMN recharge_record.user_name IS '用户名称';
COMMENT ON COLUMN recharge_record.remark IS '备注';
COMMENT ON COLUMN recharge_record.create_time IS '创建时间';
COMMENT ON COLUMN recharge_record.update_time IS '更新时间';
COMMENT ON COLUMN recharge_record.pay_time IS '支付完成时间';
COMMENT ON COLUMN recharge_record.expire_time IS '过期时间';
COMMENT ON COLUMN recharge_record.operator IS '操作员';
