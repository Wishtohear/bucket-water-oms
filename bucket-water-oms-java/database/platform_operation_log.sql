-- =============================================================================
-- 创建platform_operation_log（平台操作日志）表
-- =============================================================================
-- 用途: 记录平台管理员的所有操作日志，用于审计和追踪
-- 作者: AI Assistant
-- 日期: 2026-05-17
-- =============================================================================

-- 创建platform_operation_log表
CREATE TABLE IF NOT EXISTS platform_operation_log (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT COMMENT '操作用户ID',
    user_name VARCHAR(100) COMMENT '操作用户名称',
    user_role VARCHAR(50) COMMENT '操作用户角色',
    module VARCHAR(50) COMMENT '操作模块',
    action VARCHAR(50) COMMENT '操作类型: CREATE/UPDATE/DELETE/QUERY/LOGIN/LOGOUT',
    target_type VARCHAR(50) COMMENT '操作对象类型',
    target_id BIGINT COMMENT '操作对象ID',
    target_name VARCHAR(200) COMMENT '操作对象名称',
    description VARCHAR(500) COMMENT '操作描述',
    request_method VARCHAR(10) COMMENT '请求方法',
    request_url VARCHAR(500) COMMENT '请求URL',
    request_params TEXT COMMENT '请求参数',
    response_status VARCHAR(20) COMMENT '响应状态',
    error_message TEXT COMMENT '错误信息',
    ip_address VARCHAR(50) COMMENT 'IP地址',
    user_agent VARCHAR(500) COMMENT '用户代理',
    duration BIGINT COMMENT '执行时长(毫秒)',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间'
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_platform_log_user_id ON platform_operation_log(user_id);
CREATE INDEX IF NOT EXISTS idx_platform_log_module ON platform_operation_log(module);
CREATE INDEX IF NOT EXISTS idx_platform_log_action ON platform_operation_log(action);
CREATE INDEX IF NOT EXISTS idx_platform_log_target_type ON platform_operation_log(target_type);
CREATE INDEX IF NOT EXISTS idx_platform_log_create_time ON platform_operation_log(create_time);

-- 添加注释
COMMENT ON TABLE platform_operation_log IS '平台操作日志表';
COMMENT ON COLUMN platform_operation_log.id IS '日志ID';
COMMENT ON COLUMN platform_operation_log.user_id IS '操作用户ID';
COMMENT ON COLUMN platform_operation_log.user_name IS '操作用户名称';
COMMENT ON COLUMN platform_operation_log.user_role IS '操作用户角色';
COMMENT ON COLUMN platform_operation_log.module IS '操作模块';
COMMENT ON COLUMN platform_operation_log.action IS '操作类型';
COMMENT ON COLUMN platform_operation_log.target_type IS '操作对象类型';
COMMENT ON COLUMN platform_operation_log.target_id IS '操作对象ID';
COMMENT ON COLUMN platform_operation_log.target_name IS '操作对象名称';
COMMENT ON COLUMN platform_operation_log.description IS '操作描述';
COMMENT ON COLUMN platform_operation_log.request_method IS '请求方法';
COMMENT ON COLUMN platform_operation_log.request_url IS '请求URL';
COMMENT ON COLUMN platform_operation_log.request_params IS '请求参数';
COMMENT ON COLUMN platform_operation_log.response_status IS '响应状态';
COMMENT ON COLUMN platform_operation_log.error_message IS '错误信息';
COMMENT ON COLUMN platform_operation_log.ip_address IS 'IP地址';
COMMENT ON COLUMN platform_operation_log.user_agent IS '用户代理';
COMMENT ON COLUMN platform_operation_log.duration IS '执行时长(毫秒)';
COMMENT ON COLUMN platform_operation_log.create_time IS '创建时间';

-- =============================================================================
-- 执行说明：
-- 1. 备份数据库
-- 2. 执行此脚本
-- 3. 重启应用
-- =============================================================================

-- 验证脚本
\d platform_operation_log
