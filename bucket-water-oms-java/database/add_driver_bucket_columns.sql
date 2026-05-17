-- 修复 driver 表缺少的所有字段
-- 执行时间: 2026-04-21
-- 问题: Driver 实体类中的字段与数据库表不一致

-- 1. 在途空桶数量列
ALTER TABLE driver ADD COLUMN IF NOT EXISTS bucket_on_way INTEGER DEFAULT 0;
COMMENT ON COLUMN driver.bucket_on_way IS '在途空桶数量';

-- 2. 欠桶数量列
ALTER TABLE driver ADD COLUMN IF NOT EXISTS owed_buckets INTEGER DEFAULT 0;
COMMENT ON COLUMN driver.owed_buckets IS '欠桶数量';

-- 3. 在线状态列
ALTER TABLE driver ADD COLUMN IF NOT EXISTS online_status VARCHAR(20) DEFAULT 'offline';
COMMENT ON COLUMN driver.online_status IS '在线状态: online/offline/break';

-- 4. 最后在线时间列
ALTER TABLE driver ADD COLUMN IF NOT EXISTS last_online_time TIMESTAMP;
COMMENT ON COLUMN driver.last_online_time IS '最后在线时间（心跳时间）';

-- 5. 当前纬度列
ALTER TABLE driver ADD COLUMN IF NOT EXISTS current_lat DECIMAL(10, 6);
COMMENT ON COLUMN driver.current_lat IS '当前纬度';

-- 6. 当前经度列
ALTER TABLE driver ADD COLUMN IF NOT EXISTS current_lng DECIMAL(10, 6);
COMMENT ON COLUMN driver.current_lng IS '当前经度';

-- 7. 最后位置更新时间列
ALTER TABLE driver ADD COLUMN IF NOT EXISTS last_location_time TIMESTAMP;
COMMENT ON COLUMN driver.last_location_time IS '最后位置更新时间';

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_driver_online_status ON driver(online_status);
CREATE INDEX IF NOT EXISTS idx_driver_last_online ON driver(last_online_time);

-- 验证
SELECT id, name, phone, bucket_on_way, owed_buckets, online_status, last_online_time
FROM driver
LIMIT 5;

-- 回滚脚本
-- ALTER TABLE driver DROP COLUMN IF EXISTS bucket_on_way;
-- ALTER TABLE driver DROP COLUMN IF EXISTS owed_buckets;
-- ALTER TABLE driver DROP COLUMN IF EXISTS online_status;
-- ALTER TABLE driver DROP COLUMN IF EXISTS last_online_time;
-- ALTER TABLE driver DROP COLUMN IF EXISTS current_lat;
-- ALTER TABLE driver DROP COLUMN IF EXISTS current_lng;
-- ALTER TABLE driver DROP COLUMN IF EXISTS last_location_time;
-- DROP INDEX IF EXISTS idx_driver_online_status;
-- DROP INDEX IF EXISTS idx_driver_last_online;
