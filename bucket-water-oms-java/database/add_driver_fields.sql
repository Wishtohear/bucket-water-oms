-- 添加 driver 表缺失的字段
-- 执行时间: 2026-04-24
-- 说明: 为 driver 表添加 license_plate, vehicle_type, emergency_contact 列

-- 添加 license_plate 列（车牌号）
ALTER TABLE driver ADD COLUMN IF NOT EXISTS license_plate VARCHAR(50);

-- 添加 vehicle_type 列（车辆类型）
ALTER TABLE driver ADD COLUMN IF NOT EXISTS vehicle_type VARCHAR(50);

-- 添加 emergency_contact 列（紧急联系人）
ALTER TABLE driver ADD COLUMN IF NOT EXISTS emergency_contact VARCHAR(100);

-- 为新列添加注释
COMMENT ON COLUMN driver.license_plate IS '车牌号';
COMMENT ON COLUMN driver.vehicle_type IS '车辆类型';
COMMENT ON COLUMN driver.emergency_contact IS '紧急联系人';

-- 验证修复结果
SELECT column_name, data_type, character_maximum_length
FROM information_schema.columns
WHERE table_name = 'driver'
AND column_name IN ('license_plate', 'vehicle_type', 'emergency_contact');
