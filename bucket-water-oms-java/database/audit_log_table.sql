-- 审计日志表
-- 用于记录管理员操作日志

CREATE TABLE IF NOT EXISTS audit_log (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT,
    username VARCHAR(100),
    user_role VARCHAR(50),
    action VARCHAR(50),
    module VARCHAR(50),
    entity_type VARCHAR(100),
    entity_id VARCHAR(100),
    entity_name VARCHAR(200),
    method VARCHAR(200),
    request_url VARCHAR(500),
    request_method VARCHAR(10),
    ip_address VARCHAR(50),
    user_agent VARCHAR(500),
    request_params TEXT,
    response_status INTEGER,
    error_message TEXT,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted INTEGER DEFAULT 0
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_audit_log_user_id ON audit_log(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_create_time ON audit_log(create_time);
CREATE INDEX IF NOT EXISTS idx_audit_log_module ON audit_log(module);
CREATE INDEX IF NOT EXISTS idx_audit_log_action ON audit_log(action);
CREATE INDEX IF NOT EXISTS idx_audit_log_deleted ON audit_log(deleted);

COMMENT ON TABLE audit_log IS '审计日志表';
COMMENT ON COLUMN audit_log.id IS '主键ID';
COMMENT ON COLUMN audit_log.user_id IS '用户ID';
COMMENT ON COLUMN audit_log.username IS '用户名';
COMMENT ON COLUMN audit_log.user_role IS '用户角色';
COMMENT ON COLUMN audit_log.action IS '操作类型：CREATE/UPDATE/DELETE/QUERY等';
COMMENT ON COLUMN audit_log.module IS '操作模块';
COMMENT ON COLUMN audit_log.entity_type IS '实体类型';
COMMENT ON COLUMN audit_log.entity_id IS '实体ID';
COMMENT ON COLUMN audit_log.entity_name IS '实体名称';
COMMENT ON COLUMN audit_log.method IS '方法名';
COMMENT ON COLUMN audit_log.request_url IS '请求URL';
COMMENT ON COLUMN audit_log.request_method IS '请求方法';
COMMENT ON COLUMN audit_log.ip_address IS 'IP地址';
COMMENT ON COLUMN audit_log.user_agent IS '用户代理';
COMMENT ON COLUMN audit_log.request_params IS '请求参数';
COMMENT ON COLUMN audit_log.response_status IS '响应状态';
COMMENT ON COLUMN audit_log.error_message IS '错误信息';
COMMENT ON COLUMN audit_log.create_time IS '创建时间';
COMMENT ON COLUMN audit_log.deleted IS '逻辑删除标记';
