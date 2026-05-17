-- 地域区域表
CREATE TABLE IF NOT EXISTS region (
    id VARCHAR(36) PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    parent_code VARCHAR(50) DEFAULT NULL,
    level INT NOT NULL,
    sort INT DEFAULT 0,
    status VARCHAR(20) DEFAULT 'active',
    remark VARCHAR(500) DEFAULT NULL,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted INTEGER DEFAULT 0
);

-- 添加表注释
COMMENT ON TABLE region IS '地域区域表';

-- 添加列注释
COMMENT ON COLUMN region.id IS '主键ID';
COMMENT ON COLUMN region.code IS '区域编码';
COMMENT ON COLUMN region.name IS '区域名称';
COMMENT ON COLUMN region.parent_code IS '上级区域编码';
COMMENT ON COLUMN region.level IS '层级: 1-省/直辖市, 2-市/区, 3-县/街道';
COMMENT ON COLUMN region.sort IS '排序值';
COMMENT ON COLUMN region.status IS '状态: active-启用, inactive-停用';
COMMENT ON COLUMN region.remark IS '备注';
COMMENT ON COLUMN region.create_time IS '创建时间';
COMMENT ON COLUMN region.update_time IS '更新时间';
COMMENT ON COLUMN region.deleted IS '逻辑删除标记: 0-未删除, 1-已删除';

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_parent_code ON region(parent_code);
CREATE INDEX IF NOT EXISTS idx_status ON region(status);
CREATE INDEX IF NOT EXISTS idx_level ON region(level);
CREATE INDEX IF NOT EXISTS idx_deleted ON region(deleted);

-- 创建自动更新 update_time 的触发器函数
CREATE OR REPLACE FUNCTION update_timestamp_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.update_time = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 创建触发器 (只在表不存在时)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_region_timestamp') THEN
        CREATE TRIGGER update_region_timestamp
            BEFORE UPDATE ON region
            FOR EACH ROW
            EXECUTE FUNCTION update_timestamp_column();
    END IF;
END $$;

-- 添加缺失列的修复脚本 (如果表已存在)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'region' AND column_name = 'deleted'
    ) THEN
        ALTER TABLE region ADD COLUMN deleted INTEGER DEFAULT 0;
    END IF;
END $$;

-- 插入浙江省及下属城市和区县
INSERT INTO region (id, code, name, parent_code, level, sort, status) VALUES
('550e8400-e29b-41d4-a716-446655440001', '330000', '浙江省', NULL, 1, 1, 'active'),
('550e8400-e29b-41d4-a716-446655440002', '330100', '杭州市', '330000', 2, 1, 'active'),
('550e8400-e29b-41d4-a716-446655440003', '330105', '拱墅区', '330100', 3, 1, 'active'),
('550e8400-e29b-41d4-a716-446655440004', '330106', '西湖区', '330100', 3, 2, 'active'),
('550e8400-e29b-41d4-a716-446655440005', '330108', '滨江区', '330100', 3, 3, 'active'),
('550e8400-e29b-41d4-a716-446655440006', '330109', '萧山区', '330100', 3, 4, 'active'),
('550e8400-e29b-41d4-a716-446655440007', '330110', '余杭区', '330100', 3, 5, 'active'),
('550e8400-e29b-41d4-a716-446655440008', '330111', '临安区', '330100', 3, 6, 'active'),
('550e8400-e29b-41d4-a716-446655440009', '330200', '宁波市', '330000', 2, 2, 'active'),
('550e8400-e29b-41d4-a716-446655440010', '330203', '海曙区', '330200', 3, 1, 'active'),
('550e8400-e29b-41d4-a716-446655440011', '330206', '北仑区', '330200', 3, 2, 'active'),
('550e8400-e29b-41d4-a716-446655440012', '330300', '温州市', '330000', 2, 3, 'active'),
('550e8400-e29b-41d4-a716-446655440013', '330302', '鹿城区', '330300', 3, 1, 'active'),
('550e8400-e29b-41d4-a716-446655440014', '310000', '上海市', NULL, 1, 2, 'active'),
('550e8400-e29b-41d4-a716-446655440015', '310100', '黄浦区', '310000', 2, 1, 'active'),
('550e8400-e29b-41d4-a716-446655440016', '310110', '杨浦区', '310000', 2, 2, 'active')
ON CONFLICT (id) DO NOTHING;
