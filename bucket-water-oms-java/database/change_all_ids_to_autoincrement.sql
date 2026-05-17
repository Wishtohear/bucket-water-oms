-- 将所有表的主键 ID 从 VARCHAR/UUID 改为 BIGSERIAL 自增
-- 执行时间: 2026-04-24

-- =============================================
-- 1. 修改 policy_template 表
-- =============================================

-- 备份原数据
CREATE TABLE IF NOT EXISTS policy_template_backup AS SELECT * FROM policy_template;

-- 删除原表并重建（PostgreSQL 不支持直接修改列类型）
DROP TABLE IF EXISTS policy_template CASCADE;

CREATE TABLE policy_template (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) DEFAULT 'default',
    status VARCHAR(20) DEFAULT 'active',
    remark TEXT,
    bucket_water_price DECIMAL(10,2) DEFAULT 0,
    min_order_quantity INT DEFAULT 50,
    credit_limit DECIMAL(10,2) DEFAULT 0,
    payment_type VARCHAR(20) DEFAULT 'immediate',
    pre_deposit DECIMAL(10,2) DEFAULT 0,
    bucket_threshold INT DEFAULT 10,
    coverage_count INT DEFAULT 0,
    start_date DATE,
    end_date DATE,
    gift_ratio VARCHAR(50),
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    create_by VARCHAR(64),
    update_by VARCHAR(64),
    deleted INT DEFAULT 0
);

-- 恢复数据（将字符串 ID 转为序列值）
INSERT INTO policy_template (name, type, status, remark, bucket_water_price, min_order_quantity, credit_limit, payment_type, pre_deposit, bucket_threshold, coverage_count, start_date, end_date, gift_ratio, create_time, update_time, create_by, update_by, deleted)
SELECT name, type, status, remark, bucket_water_price, min_order_quantity, credit_limit, payment_type, pre_deposit, bucket_threshold, coverage_count, start_date, end_date, gift_ratio, create_time, update_time, create_by, update_by, deleted
FROM policy_template_backup;

DROP TABLE policy_template_backup;

-- =============================================
-- 2. 修改 policy_pricing_rule 表
-- =============================================

-- 备份原数据
CREATE TABLE IF NOT EXISTS policy_pricing_rule_backup AS SELECT * FROM policy_pricing_rule;

-- 删除原表并重建
DROP TABLE IF EXISTS policy_pricing_rule CASCADE;

CREATE TABLE policy_pricing_rule (
    id BIGSERIAL PRIMARY KEY,
    policy_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2) DEFAULT 0,
    min_quantity INT DEFAULT 0,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted INT DEFAULT 0
);

-- 恢复数据（将 policy_id 和 product_id 从字符串转为数字）
-- 注意：需要确保原数据中的 policy_id 和 product_id 可以转换为数字
-- 如果原数据中包含非数字值，需要先处理
INSERT INTO policy_pricing_rule (policy_id, product_id, product_name, category, price, min_quantity, create_time, update_time, deleted)
SELECT
    CAST(NULLIF(regexp_replace(policy_id, '[^0-9]', '', 'g'), '') AS BIGINT),
    CAST(NULLIF(regexp_replace(product_id, '[^0-9]', '', 'g'), '') AS BIGINT),
    product_name,
    category,
    price,
    min_quantity,
    create_time,
    update_time,
    deleted
FROM policy_pricing_rule_backup
WHERE regexp_replace(policy_id, '[^0-9]', '', 'g') ~ '^[0-9]+$'
  AND regexp_replace(product_id, '[^0-9]', '', 'g') ~ '^[0-9]+$';

DROP TABLE policy_pricing_rule_backup;

-- =============================================
-- 3. 修改 region 表
-- =============================================

-- 备份原数据
CREATE TABLE IF NOT EXISTS region_backup AS SELECT * FROM region;

-- 删除原表并重建
DROP TABLE IF EXISTS region CASCADE;

CREATE TABLE region (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    parent_code VARCHAR(20),
    level INT DEFAULT 1,
    sort INT DEFAULT 0,
    status VARCHAR(20) DEFAULT 'active',
    remark TEXT,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted INT DEFAULT 0
);

-- 恢复数据
INSERT INTO region (code, name, parent_code, level, sort, status, remark, create_time, update_time, deleted)
SELECT code, name, parent_code, level, sort, status, remark, create_time, update_time, deleted
FROM region_backup;

DROP TABLE region_backup;

-- =============================================
-- 4. 重置所有序列
-- =============================================

-- 重置 policy_template 序列
SELECT setval(
    (SELECT pg_get_serial_sequence('policy_template', 'id')),
    (SELECT COALESCE(MAX(id), 0) + 1 FROM policy_template),
    false
);

-- 重置 policy_pricing_rule 序列
SELECT setval(
    (SELECT pg_get_serial_sequence('policy_pricing_rule', 'id')),
    (SELECT COALESCE(MAX(id), 0) + 1 FROM policy_pricing_rule),
    false
);

-- 重置 region 序列
SELECT setval(
    (SELECT pg_get_serial_sequence('region', 'id')),
    (SELECT COALESCE(MAX(id), 0) + 1 FROM region),
    false
);

-- =============================================
-- 5. 重置 product 表序列
-- =============================================

SELECT '开始重置 product 表序列...' AS info;

SELECT setval(
    (SELECT pg_get_serial_sequence('product', 'id')),
    (SELECT COALESCE(MAX(id), 0) + 1 FROM product),
    false
);

-- =============================================
-- 6. 验证结果
-- =============================================

SELECT '=== 验证结果 ===' AS info;

SELECT 'policy_template 表:' AS info;
SELECT id, name FROM policy_template ORDER BY id;
SELECT '序列值:' AS info;
SELECT last_value FROM policy_template_id_seq;

SELECT 'policy_pricing_rule 表:' AS info;
SELECT id, policy_id, product_id FROM policy_pricing_rule ORDER BY id;
SELECT '序列值:' AS info;
SELECT last_value FROM policy_pricing_rule_id_seq;

SELECT 'region 表:' AS info;
SELECT id, code, name FROM region ORDER BY id;
SELECT '序列值:' AS info;
SELECT last_value FROM region_id_seq;

SELECT 'product 表:' AS info;
SELECT id, code, name FROM product ORDER BY id;
SELECT '序列值:' AS info;
SELECT last_value FROM product_id_seq;
