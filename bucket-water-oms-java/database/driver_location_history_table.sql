-- 司机位置历史轨迹表
-- 用于存储司机的历史GPS位置记录，用于轨迹回放和分析
-- 执行时间: 2026-05-16

-- 创建司机位置历史表
CREATE TABLE IF NOT EXISTS driver_location_history (
    id BIGSERIAL PRIMARY KEY,
    driver_id BIGINT NOT NULL COMMENT '司机ID',
    lat DECIMAL(10, 7) NOT NULL COMMENT '纬度',
    lng DECIMAL(10, 7) NOT NULL COMMENT '经度',
    speed DECIMAL(6, 2) COMMENT '速度(km/h)',
    heading INTEGER COMMENT '方向角度',
    address VARCHAR(500) COMMENT '当前位置地址',
    record_time TIMESTAMP NOT NULL COMMENT '记录时间',
    order_id VARCHAR(100) COMMENT '关联订单ID(可选)',
    location_type VARCHAR(50) DEFAULT 'normal' COMMENT '位置类型: location_check_in/delivery/normal',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间'
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_driver_location_history_driver_id ON driver_location_history(driver_id);
CREATE INDEX IF NOT EXISTS idx_driver_location_history_record_time ON driver_location_history(record_time);
CREATE INDEX IF NOT EXISTS idx_driver_location_history_driver_time ON driver_location_history(driver_id, record_time);
CREATE INDEX IF NOT EXISTS idx_driver_location_history_order_id ON driver_location_history(order_id);

-- 添加注释
COMMENT ON TABLE driver_location_history IS '司机位置历史记录表';
COMMENT ON COLUMN driver_location_history.driver_id IS '司机ID';
COMMENT ON COLUMN driver_location_history.lat IS '纬度';
COMMENT ON COLUMN driver_location_history.lng IS '经度';
COMMENT ON COLUMN driver_location_history.speed IS '速度(km/h)';
COMMENT ON COLUMN driver_location_history.heading IS '方向角度';
COMMENT ON COLUMN driver_location_history.address IS '当前位置地址';
COMMENT ON COLUMN driver_location_history.record_time IS '记录时间';
COMMENT ON COLUMN driver_location_history.order_id IS '关联订单ID(可选)';
COMMENT ON COLUMN driver_location_history.location_type IS '位置类型: location_check_in-打卡, delivery-配送中, normal-普通位置更新';

-- 验证表结构
\d driver_location_history
