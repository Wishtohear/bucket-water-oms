-- 订单签收功能升级脚本
-- 执行时间: 2026-04-21
-- 功能: 添加签收类型、签字数据、签收时间、打卡位置等字段

-- 1. 添加订单签收相关字段
ALTER TABLE orders ADD COLUMN IF NOT EXISTS sign_type VARCHAR(50);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS sign_data TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS sign_time TIMESTAMP;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS check_in_lat DECIMAL(10, 6);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS check_in_lng DECIMAL(10, 6);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS check_in_time TIMESTAMP;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS check_in_address VARCHAR(255);

-- 2. 添加注释
COMMENT ON COLUMN orders.sign_type IS '签收类型: signature(手机签字)/sms_code(短信验证码)/boss_confirm(老板确认)';
COMMENT ON COLUMN orders.sign_data IS '签字数据: Base64图片或签名坐标JSON或验证码';
COMMENT ON COLUMN orders.sign_time IS '签收时间';
COMMENT ON COLUMN orders.check_in_lat IS '打卡纬度';
COMMENT ON COLUMN orders.check_in_lng IS '打卡经度';
COMMENT ON COLUMN orders.check_in_time IS '打卡时间';
COMMENT ON COLUMN orders.check_in_address IS '打卡位置地址';

-- 3. 验证
SELECT id, order_no, sign_type, sign_time, check_in_lat, check_in_lng, check_in_time
FROM orders
WHERE status = 'completed'
LIMIT 10;

-- 回滚脚本（如需要回滚）
-- ALTER TABLE orders DROP COLUMN IF EXISTS sign_type;
-- ALTER TABLE orders DROP COLUMN IF EXISTS sign_data;
-- ALTER TABLE orders DROP COLUMN IF EXISTS sign_time;
-- ALTER TABLE orders DROP COLUMN IF EXISTS check_in_lat;
-- ALTER TABLE orders DROP COLUMN IF EXISTS check_in_lng;
-- ALTER TABLE orders DROP COLUMN IF EXISTS check_in_time;
-- ALTER TABLE orders DROP COLUMN IF EXISTS check_in_address;
