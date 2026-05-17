-- 仓库库存预警配置升级脚本
-- 添加仓库级库存预警配置字段
-- 执行时间: 2026-05-16

-- 添加默认安全库存字段
ALTER TABLE warehouse ADD COLUMN IF NOT EXISTS default_safe_stock INTEGER DEFAULT 10;

-- 添加库存预警开关字段
ALTER TABLE warehouse ADD COLUMN IF NOT EXISTS inventory_alert_enabled BOOLEAN DEFAULT true;

-- 添加低库存预警阈值百分比字段
ALTER TABLE warehouse ADD COLUMN IF NOT EXISTS low_stock_alert_percent INTEGER DEFAULT 20;

-- 为现有仓库设置默认值
UPDATE warehouse SET default_safe_stock = 10 WHERE default_safe_stock IS NULL;
UPDATE warehouse SET inventory_alert_enabled = true WHERE inventory_alert_enabled IS NULL;
UPDATE warehouse SET low_stock_alert_percent = 20 WHERE low_stock_alert_percent IS NULL;

-- 添加注释（如果数据库支持）
COMMENT ON COLUMN warehouse.default_safe_stock IS '默认安全库存数量';
COMMENT ON COLUMN warehouse.inventory_alert_enabled IS '库存预警开关';
COMMENT ON COLUMN warehouse.low_stock_alert_percent IS '低库存预警阈值百分比(当库存低于安全库存的此百分比时触发预警)';

-- 验证
SELECT column_name, data_type, column_default 
FROM information_schema.columns 
WHERE table_name = 'warehouse' 
AND column_name IN ('default_safe_stock', 'inventory_alert_enabled', 'low_stock_alert_percent');
