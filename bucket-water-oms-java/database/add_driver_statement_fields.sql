-- 司机对账单扩展字段升级脚本
-- 添加提成和里程补助相关字段
-- 执行时间: 2026-05-16

-- 添加配送提成相关字段
ALTER TABLE driver_statement ADD COLUMN IF NOT EXISTS delivery_commission DECIMAL(12, 2) DEFAULT 0 COMMENT '配送提成';
ALTER TABLE driver_statement ADD COLUMN IF NOT EXISTS commission_rate DECIMAL(5, 2) DEFAULT 10 COMMENT '配送提成率(%)';
ALTER TABLE driver_statement ADD COLUMN IF NOT EXISTS mileage_subsidy DECIMAL(12, 2) DEFAULT 0 COMMENT '里程补助';
ALTER TABLE driver_statement ADD COLUMN IF NOT EXISTS total_distance DECIMAL(10, 2) DEFAULT 0 COMMENT '总里程(km)';
ALTER TABLE driver_statement ADD COLUMN IF NOT EXISTS actual_amount DECIMAL(12, 2) DEFAULT 0 COMMENT '实际应发金额';

-- 为现有记录设置默认值
UPDATE driver_statement SET delivery_commission = 0 WHERE delivery_commission IS NULL;
UPDATE driver_statement SET commission_rate = 10 WHERE commission_rate IS NULL;
UPDATE driver_statement SET mileage_subsidy = 0 WHERE mileage_subsidy IS NULL;
UPDATE driver_statement SET total_distance = 0 WHERE total_distance IS NULL;
UPDATE driver_statement SET actual_amount = 0 WHERE actual_amount IS NULL;

-- 添加注释
COMMENT ON COLUMN driver_statement.delivery_commission IS '配送提成金额';
COMMENT ON COLUMN driver_statement.commission_rate IS '配送提成率(%)';
COMMENT ON COLUMN driver_statement.mileage_subsidy IS '里程补助金额';
COMMENT ON COLUMN driver_statement.total_distance IS '总行驶里程(km)';
COMMENT ON COLUMN driver_statement.actual_amount IS '实际应发金额(提成+补助)';

-- 验证
\d driver_statement
