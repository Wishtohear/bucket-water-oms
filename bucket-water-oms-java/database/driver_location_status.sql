-- 司机在线状态和GPS位置功能升级脚本
-- 执行时间: 2026-04-21
-- 功能: 添加司机在线状态、最后在线时间、当前GPS坐标、最后位置更新时间
-- 说明:
--   - onlineStatus: 在线状态 (online/offline/break)
--   - lastOnlineTime: 最后在线时间，用于心跳检测
--   - lastLocationTime: 最后位置更新时间
--   - 自动离线规则: 司机超过10分钟未更新位置，自动设为离线

-- 1. 添加司机在线状态和GPS位置相关字段
ALTER TABLE driver ADD COLUMN IF NOT EXISTS online_status VARCHAR(20) DEFAULT 'offline';
ALTER TABLE driver ADD COLUMN IF NOT EXISTS last_online_time TIMESTAMP;
ALTER TABLE driver ADD COLUMN IF NOT EXISTS current_lat DECIMAL(10, 6);
ALTER TABLE driver ADD COLUMN IF NOT EXISTS current_lng DECIMAL(10, 6);
ALTER TABLE driver ADD COLUMN IF NOT EXISTS last_location_time TIMESTAMP;

-- 2. 创建索引以优化位置查询和状态检查
CREATE INDEX IF NOT EXISTS idx_driver_online_status ON driver(online_status);
CREATE INDEX IF NOT EXISTS idx_driver_last_online ON driver(last_online_time);
CREATE INDEX IF NOT EXISTS idx_driver_location ON driver(current_lat, current_lng);

-- 3. 添加注释
COMMENT ON COLUMN driver.online_status IS '在线状态: online/offline/break';
COMMENT ON COLUMN driver.last_online_time IS '最后在线时间（心跳时间），超过10分钟未更新将自动设为离线';
COMMENT ON COLUMN driver.current_lat IS '当前纬度';
COMMENT ON COLUMN driver.current_lng IS '当前经度';
COMMENT ON COLUMN driver.last_location_time IS '最后位置更新时间';

-- 验证
SELECT id, name, phone, online_status, last_online_time, current_lat, current_lng, last_location_time
FROM driver
LIMIT 5;

-- 回滚脚本（如需要回滚）
-- ALTER TABLE driver DROP COLUMN IF EXISTS online_status;
-- ALTER TABLE driver DROP COLUMN IF EXISTS last_online_time;
-- ALTER TABLE driver DROP COLUMN IF EXISTS current_lat;
-- ALTER TABLE driver DROP COLUMN IF EXISTS current_lng;
-- ALTER TABLE driver DROP COLUMN IF EXISTS last_location_time;
-- DROP INDEX IF EXISTS idx_driver_online_status;
-- DROP INDEX IF EXISTS idx_driver_last_online;
-- DROP INDEX IF EXISTS idx_driver_location;
