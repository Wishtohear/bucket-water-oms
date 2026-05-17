-- =============================================================================
-- 创建factory（水厂）表
-- =============================================================================
-- 用途: 支持多水厂管理，水厂是最高级别的组织单位
-- 作者: AI Assistant
-- 日期: 2026-05-17
-- =============================================================================

-- 创建factory表
CREATE TABLE IF NOT EXISTS factory (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL COMMENT '水厂名称',
    code VARCHAR(50) NOT NULL UNIQUE COMMENT '水厂编码',
    contact VARCHAR(100) COMMENT '联系人',
    phone VARCHAR(20) COMMENT '联系电话',
    address VARCHAR(500) COMMENT '地址',
    lat DECIMAL(10, 6) COMMENT '纬度',
    lng DECIMAL(10, 6) COMMENT '经度',
    status VARCHAR(20) DEFAULT 'active' COMMENT '状态: active/inactive',
    remark VARCHAR(500) COMMENT '备注',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
    create_by VARCHAR(100) COMMENT '创建人',
    update_by VARCHAR(100) COMMENT '更新人',
    deleted INTEGER DEFAULT 0 COMMENT '删除标记: 0-未删除, 1-已删除'
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_factory_code ON factory(code);
CREATE INDEX IF NOT EXISTS idx_factory_status ON factory(status);
CREATE INDEX IF NOT EXISTS idx_factory_deleted ON factory(deleted);

-- 添加注释
COMMENT ON TABLE factory IS '水厂表';
COMMENT ON COLUMN factory.id IS '水厂ID';
COMMENT ON COLUMN factory.name IS '水厂名称';
COMMENT ON COLUMN factory.code IS '水厂编码';
COMMENT ON COLUMN factory.contact IS '联系人';
COMMENT ON COLUMN factory.phone IS '联系电话';
COMMENT ON COLUMN factory.address IS '地址';
COMMENT ON COLUMN factory.lat IS '纬度';
COMMENT ON COLUMN factory.lng IS '经度';
COMMENT ON COLUMN factory.status IS '状态: active-启用, inactive-停用';
COMMENT ON COLUMN factory.remark IS '备注';
COMMENT ON COLUMN factory.create_time IS '创建时间';
COMMENT ON COLUMN factory.update_time IS '更新时间';
COMMENT ON COLUMN factory.create_by IS '创建人';
COMMENT ON COLUMN factory.update_by IS '更新人';
COMMENT ON COLUMN factory.deleted IS '删除标记: 0-未删除, 1-已删除';

-- =============================================================================
-- 执行说明：
-- 1. 备份数据库
-- 2. 执行此脚本
-- 3. 重启应用
-- =============================================================================

-- 验证脚本
\d factory
