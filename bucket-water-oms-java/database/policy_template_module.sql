-- ============================================
-- 销售政策模板表 - policy_template
-- 用于存储销售政策的配置信息
-- ============================================

-- 创建政策模板表
CREATE TABLE IF NOT EXISTS policy_template (
    id VARCHAR(100) PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    type VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    remark TEXT,

    bucket_water_price DECIMAL(10, 2),
    min_order_quantity INTEGER DEFAULT 0,
    credit_limit DECIMAL(12, 2) DEFAULT 0,

    payment_type VARCHAR(20) DEFAULT 'immediate',
    pre_deposit DECIMAL(12, 2) DEFAULT 0,
    bucket_threshold INTEGER DEFAULT 0,

    coverage_count INTEGER DEFAULT 0,

    start_date DATE,
    end_date DATE,
    gift_ratio VARCHAR(20),

    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    create_by VARCHAR(100),
    update_by VARCHAR(100),
    deleted INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_policy_template_type ON policy_template(type);
CREATE INDEX IF NOT EXISTS idx_policy_template_status ON policy_template(status);
CREATE INDEX IF NOT EXISTS idx_policy_template_deleted ON policy_template(deleted);

-- ============================================
-- 政策定价规则表 - policy_pricing_rule
-- 用于存储每个政策的详细定价规则
-- ============================================

CREATE TABLE IF NOT EXISTS policy_pricing_rule (
    id VARCHAR(100) PRIMARY KEY,
    policy_id VARCHAR(100) NOT NULL,

    product_id VARCHAR(100) NOT NULL,
    product_name VARCHAR(200),
    category VARCHAR(50),

    price DECIMAL(10, 2) NOT NULL,
    min_quantity INTEGER DEFAULT 0,

    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_policy_pricing_rule_policy_id ON policy_pricing_rule(policy_id);
CREATE INDEX IF NOT EXISTS idx_policy_pricing_rule_product_id ON policy_pricing_rule(product_id);
CREATE INDEX IF NOT EXISTS idx_policy_pricing_rule_deleted ON policy_pricing_rule(deleted);

ALTER TABLE policy_pricing_rule ADD CONSTRAINT fk_policy_pricing_rule_policy
    FOREIGN KEY (policy_id) REFERENCES policy_template(id) ON DELETE CASCADE;

-- ============================================
-- 添加注释 (PostgreSQL 语法)
-- ============================================

COMMENT ON TABLE policy_template IS '政策模板表';
COMMENT ON COLUMN policy_template.id IS '政策模板ID';
COMMENT ON COLUMN policy_template.name IS '政策名称';
COMMENT ON COLUMN policy_template.type IS '政策类型: default/vip/promotion';
COMMENT ON COLUMN policy_template.status IS '状态: active/inactive';
COMMENT ON COLUMN policy_template.remark IS '政策描述';
COMMENT ON COLUMN policy_template.bucket_water_price IS '桶装水单价';
COMMENT ON COLUMN policy_template.min_order_quantity IS '最低起订量';
COMMENT ON COLUMN policy_template.credit_limit IS '信用额度';
COMMENT ON COLUMN policy_template.payment_type IS '账期类型: immediate/monthly/quarterly';
COMMENT ON COLUMN policy_template.pre_deposit IS '预存金要求';
COMMENT ON COLUMN policy_template.bucket_threshold IS '欠桶阈值';
COMMENT ON COLUMN policy_template.coverage_count IS '覆盖水站数量';
COMMENT ON COLUMN policy_template.start_date IS '促销开始日期';
COMMENT ON COLUMN policy_template.end_date IS '促销结束日期';
COMMENT ON COLUMN policy_template.gift_ratio IS '赠送比例，如: 10:1';
COMMENT ON COLUMN policy_template.create_time IS '创建时间';
COMMENT ON COLUMN policy_template.update_time IS '更新时间';
COMMENT ON COLUMN policy_template.create_by IS '创建人';
COMMENT ON COLUMN policy_template.update_by IS '更新人';
COMMENT ON COLUMN policy_template.deleted IS '删除标记: 0-未删除, 1-已删除';

COMMENT ON TABLE policy_pricing_rule IS '政策定价规则表';
COMMENT ON COLUMN policy_pricing_rule.id IS '定价规则ID';
COMMENT ON COLUMN policy_pricing_rule.policy_id IS '政策模板ID';
COMMENT ON COLUMN policy_pricing_rule.product_id IS '产品ID';
COMMENT ON COLUMN policy_pricing_rule.product_name IS '产品名称';
COMMENT ON COLUMN policy_pricing_rule.category IS '产品分类';
COMMENT ON COLUMN policy_pricing_rule.price IS '单价';
COMMENT ON COLUMN policy_pricing_rule.min_quantity IS '最低起订量';
COMMENT ON COLUMN policy_pricing_rule.create_time IS '创建时间';
COMMENT ON COLUMN policy_pricing_rule.update_time IS '更新时间';
COMMENT ON COLUMN policy_pricing_rule.deleted IS '删除标记: 0-未删除, 1-已删除';

-- ============================================
-- 创建更新时间触发器函数（PostgreSQL）
-- 注意：必须先创建函数，再创建触发器
-- ============================================

CREATE OR REPLACE FUNCTION update_timestamp_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.update_time = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 创建触发器
-- ============================================

DROP TRIGGER IF EXISTS update_policy_template_timestamp ON policy_template;
CREATE TRIGGER update_policy_template_timestamp
    BEFORE UPDATE ON policy_template
    FOR EACH ROW
    EXECUTE FUNCTION update_timestamp_column();

DROP TRIGGER IF EXISTS update_policy_pricing_rule_timestamp ON policy_pricing_rule;
CREATE TRIGGER update_policy_pricing_rule_timestamp
    BEFORE UPDATE ON policy_pricing_rule
    FOR EACH ROW
    EXECUTE FUNCTION update_timestamp_column();

-- ============================================
-- 插入初始测试数据
-- ============================================

INSERT INTO policy_template (id, name, type, status, remark, bucket_water_price, min_order_quantity,
    credit_limit, payment_type, pre_deposit, bucket_threshold, coverage_count)
VALUES (
    'standard',
    '标准经销政策',
    'default',
    'active',
    '适用于大多数常规合作水站，包含基础水票价格与起订量要求。',
    8.00,
    50,
    0,
    'immediate',
    0,
    10,
    0
) ON CONFLICT (id) DO NOTHING;

INSERT INTO policy_template (id, name, type, status, remark, bucket_water_price, min_order_quantity,
    credit_limit, payment_type, pre_deposit, bucket_threshold, coverage_count)
VALUES (
    'vip',
    '战略伙伴政策',
    'vip',
    'active',
    '针对核心区域大型水站，提供更具竞争力的价格支持。满足月销2000桶以上。',
    7.20,
    100,
    50000,
    'monthly',
    5000,
    20,
    0
) ON CONFLICT (id) DO NOTHING;

INSERT INTO policy_template (id, name, type, status, remark, bucket_water_price, min_order_quantity,
    credit_limit, payment_type, pre_deposit, bucket_threshold, coverage_count,
    start_date, end_date, gift_ratio)
VALUES (
    'promotion',
    '春季订货优惠',
    'promotion',
    'active',
    '2026年4月期间生效。每订购100桶赠送10桶，或赠送空桶5个。',
    7.50,
    30,
    0,
    'immediate',
    0,
    15,
    0,
    '2026-04-01',
    '2026-04-30',
    '10:1'
) ON CONFLICT (id) DO NOTHING;

INSERT INTO policy_pricing_rule (id, policy_id, product_id, product_name, category, price, min_quantity)
VALUES (
    'standard_rule_1',
    'standard',
    '1',
    '18.9L 桶装水',
    'bucket_water',
    8.00,
    50
) ON CONFLICT (id) DO NOTHING;

INSERT INTO policy_pricing_rule (id, policy_id, product_id, product_name, category, price, min_quantity)
VALUES (
    'vip_rule_1',
    'vip',
    '1',
    '18.9L 桶装水',
    'bucket_water',
    7.20,
    100
) ON CONFLICT (id) DO NOTHING;

INSERT INTO policy_pricing_rule (id, policy_id, product_id, product_name, category, price, min_quantity)
VALUES (
    'promotion_rule_1',
    'promotion',
    '1',
    '18.9L 桶装水',
    'bucket_water',
    7.50,
    30
) ON CONFLICT (id) DO NOTHING;
