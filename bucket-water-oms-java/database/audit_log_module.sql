-- 审计日志表
-- 用于记录所有管理员的关键操作

CREATE TABLE IF NOT EXISTS audit_log (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT,
    username VARCHAR(100),
    user_role VARCHAR(50),
    action VARCHAR(100) NOT NULL COMMENT '操作类型: CREATE, UPDATE, DELETE, QUERY, LOGIN, LOGOUT, EXPORT, IMPORT',
    module VARCHAR(100) NOT NULL COMMENT '操作模块: station, driver, warehouse, product, order, policy, system',
    entity_type VARCHAR(100) COMMENT '操作实体类型: Station, Driver, Warehouse, Product, Order',
    entity_id VARCHAR(100) COMMENT '操作实体ID',
    entity_name VARCHAR(200) COMMENT '操作实体名称',
    method VARCHAR(200) COMMENT '请求方法',
    request_url VARCHAR(500) COMMENT '请求URL',
    request_method VARCHAR(10) COMMENT 'HTTP方法',
    ip_address VARCHAR(50) COMMENT 'IP地址',
    user_agent VARCHAR(500) COMMENT '用户代理',
    request_params TEXT COMMENT '请求参数(JSON)',
    response_status INTEGER COMMENT '响应状态码',
    error_message TEXT COMMENT '错误信息',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted INTEGER DEFAULT 0
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_audit_log_user_id ON audit_log(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_action ON audit_log(action);
CREATE INDEX IF NOT EXISTS idx_audit_log_module ON audit_log(module);
CREATE INDEX IF NOT EXISTS idx_audit_log_entity ON audit_log(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_create_time ON audit_log(create_time DESC);
CREATE INDEX IF NOT EXISTS idx_audit_log_deleted ON audit_log(deleted);

COMMENT ON TABLE audit_log IS '审计日志表';
COMMENT ON COLUMN audit_log.action IS '操作类型: CREATE, UPDATE, DELETE, QUERY, LOGIN, LOGOUT, EXPORT, IMPORT';
COMMENT ON COLUMN audit_log.module IS '操作模块: station, driver, warehouse, product, order, policy, system, region';
