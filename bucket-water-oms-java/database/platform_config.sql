-- =============================================================================
-- 创建platform_config（平台配置）表
-- =============================================================================
-- 用途: 存储平台配置信息，支持分组管理
-- 作者: AI Assistant
-- 日期: 2026-05-17
-- =============================================================================

-- 创建platform_config表
CREATE TABLE IF NOT EXISTS platform_config (
    id BIGSERIAL PRIMARY KEY,
    config_group VARCHAR(50) NOT NULL COMMENT '配置分组',
    config_key VARCHAR(100) NOT NULL COMMENT '配置键',
    config_value TEXT COMMENT '配置值',
    config_type VARCHAR(20) DEFAULT 'STRING' COMMENT '配置类型: STRING/INT/BOOLEAN/JSON',
    config_name VARCHAR(100) COMMENT '配置名称',
    description VARCHAR(500) COMMENT '配置描述',
    enabled INTEGER DEFAULT 1 COMMENT '是否启用: 0-禁用, 1-启用',
    sort_order INTEGER DEFAULT 0 COMMENT '排序',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
    create_by VARCHAR(100) COMMENT '创建人',
    update_by VARCHAR(100) COMMENT '更新人'
);

-- 创建唯一索引
CREATE UNIQUE INDEX IF NOT EXISTS uk_platform_config_key ON platform_config(config_key);

-- 创建普通索引
CREATE INDEX IF NOT EXISTS idx_platform_config_group ON platform_config(config_group);
CREATE INDEX IF NOT EXISTS idx_platform_config_enabled ON platform_config(enabled);

-- 添加注释
COMMENT ON TABLE platform_config IS '平台配置表';
COMMENT ON COLUMN platform_config.id IS '配置ID';
COMMENT ON COLUMN platform_config.config_group IS '配置分组';
COMMENT ON COLUMN platform_config.config_key IS '配置键';
COMMENT ON COLUMN platform_config.config_value IS '配置值';
COMMENT ON COLUMN platform_config.config_type IS '配置类型';
COMMENT ON COLUMN platform_config.config_name IS '配置名称';
COMMENT ON COLUMN platform_config.description IS '配置描述';
COMMENT ON COLUMN platform_config.enabled IS '是否启用';
COMMENT ON COLUMN platform_config.sort_order IS '排序';
COMMENT ON COLUMN platform_config.create_time IS '创建时间';
COMMENT ON COLUMN platform_config.update_time IS '更新时间';
COMMENT ON COLUMN platform_config.create_by IS '创建人';
COMMENT ON COLUMN platform_config.update_by IS '更新人';

-- =============================================================================
-- 初始化默认配置数据
-- =============================================================================

-- 基础配置
INSERT INTO platform_config (config_group, config_key, config_value, config_type, config_name, description, sort_order) VALUES
('basic', 'platform_name', '水厂订货管理系统', 'STRING', '平台名称', '系统名称', 1),
('basic', 'platform_logo', '', 'STRING', '平台Logo', '平台Logo URL', 2),
('basic', 'maintenance_mode', 'false', 'BOOLEAN', '维护模式', '开启后用户将无法登录', 3),
('basic', 'customer_service_phone', '', 'STRING', '客服电话', '客服联系电话', 4);

-- 支付配置
INSERT INTO platform_config (config_group, config_key, config_value, config_type, config_name, description, sort_order) VALUES
('payment', 'wechat_enabled', 'true', 'BOOLEAN', '启用微信支付', '是否启用微信支付', 1),
('payment', 'wechat_app_id', '', 'STRING', '微信AppID', '微信应用ID', 2),
('payment', 'wechat_mch_id', '', 'STRING', '微信商户号', '微信支付商户号', 3),
('payment', 'wechat_api_key', '', 'STRING', '微信API密钥', '微信支付API密钥', 4);

-- 短信配置
INSERT INTO platform_config (config_group, config_key, config_value, config_type, config_name, description, sort_order) VALUES
('sms', 'aliyun_enabled', 'true', 'BOOLEAN', '启用阿里云短信', '是否启用阿里云短信', 1),
('sms', 'access_key_id', '', 'STRING', 'AccessKey ID', '阿里云AccessKey ID', 2),
('sms', 'access_key_secret', '', 'STRING', 'AccessKey Secret', '阿里云AccessKey Secret', 3),
('sms', 'sign_name', '', 'STRING', '短信签名', '短信签名', 4);

-- 地图配置
INSERT INTO platform_config (config_group, config_key, config_value, config_type, config_name, description, sort_order) VALUES
('map', 'map_provider', 'amap', 'STRING', '地图服务商', '地图服务商: amap(高德)/baidu(百度)', 1),
('map', 'web_key', '', 'STRING', 'Web服务Key', '地图Web服务Key', 2),
('map', 'mock_mode', 'false', 'BOOLEAN', '模拟模式', '开发环境使用模拟数据', 3);

-- =============================================================================
-- 执行说明：
-- 1. 备份数据库
-- 2. 执行此脚本
-- 3. 重启应用
-- =============================================================================

-- 验证脚本
\d platform_config
SELECT config_group, config_key, config_value FROM platform_config ORDER BY config_group, sort_order;
