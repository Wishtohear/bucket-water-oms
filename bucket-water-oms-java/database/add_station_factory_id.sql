-- =============================================================================
-- 添加station表的factory_id字段，实现水站与水厂的关联
-- =============================================================================
-- 用途: 支持多水厂数据隔离，水站必须归属特定水厂
-- 作者: AI Assistant
-- 日期: 2026-05-17
-- =============================================================================

-- 1. 添加 factory_id 字段
ALTER TABLE station ADD COLUMN IF NOT EXISTS factory_id BIGINT;

-- 2. 添加备注说明
COMMENT ON COLUMN station.factory_id IS '所属水厂ID（平台管理员可为空，水厂管理员必填）';

-- 3. 添加外键约束（如果factory表存在）
-- 注意：如果还没有factory表，需要先创建factory表
-- ALTER TABLE station ADD CONSTRAINT fk_station_factory FOREIGN KEY (factory_id) REFERENCES factory(id);

-- 4. 添加索引优化查询
CREATE INDEX IF NOT EXISTS idx_station_factory_id ON station(factory_id);

-- 5. 将所有现有水站的factory_id设置为NULL（表示未分配水厂）
-- 注意：在实际生产环境中，应该为每个水站分配一个默认的水厂ID
-- UPDATE station SET factory_id = 1 WHERE factory_id IS NULL;

-- =============================================================================
-- 执行说明：
-- 1. 备份数据库
-- 2. 执行此脚本
-- 3. 重启应用
-- =============================================================================

-- 验证脚本
SELECT 
    'station' AS table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'station' AND column_name = 'factory_id';
