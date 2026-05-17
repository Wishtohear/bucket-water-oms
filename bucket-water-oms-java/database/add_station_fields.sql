-- ============================================================================
-- 水站相关表字段扩展脚本
-- 问题: station 表缺少 area、station_type、remark 列
-- 问题: station_account 表缺少 prepaid_required_amount 列
-- 解决: 添加缺失的列到现有表
-- 日期: 2026-04-23
-- ============================================================================

DO $$
BEGIN
    -- ============================================================
    -- 修复 station 表 - 添加业务字段
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'station' AND column_name = 'area') THEN
        ALTER TABLE station ADD COLUMN area VARCHAR(100);
        RAISE NOTICE '已添加 station.area 列';
    ELSE
        RAISE NOTICE 'station.area 列已存在';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'station' AND column_name = 'station_type') THEN
        ALTER TABLE station ADD COLUMN station_type VARCHAR(50);
        RAISE NOTICE '已添加 station.station_type 列';
    ELSE
        RAISE NOTICE 'station.station_type 列已存在';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'station' AND column_name = 'remark') THEN
        ALTER TABLE station ADD COLUMN remark TEXT;
        RAISE NOTICE '已添加 station.remark 列';
    ELSE
        RAISE NOTICE 'station.remark 列已存在';
    END IF;

    -- ============================================================
    -- 修复 station_account 表 - 添加业务字段
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'station_account' AND column_name = 'prepaid_required_amount') THEN
        ALTER TABLE station_account ADD COLUMN prepaid_required_amount DECIMAL(12,2) DEFAULT 0.00;
        RAISE NOTICE '已添加 station_account.prepaid_required_amount 列';
    ELSE
        RAISE NOTICE 'station_account.prepaid_required_amount 列已存在';
    END IF;

    -- 检查 station_account 表是否缺少 deposit_bucket_num 列
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'station_account' AND column_name = 'deposit_bucket_num') THEN
        ALTER TABLE station_account ADD COLUMN deposit_bucket_num INT DEFAULT 0;
        RAISE NOTICE '已添加 station_account.deposit_bucket_num 列';
    ELSE
        RAISE NOTICE 'station_account.deposit_bucket_num 列已存在';
    END IF;

END $$;

-- ============================================================================
-- 验证修复结果
-- ============================================================================
SELECT '========================================' AS separator;
SELECT '水站相关表字段验证:' AS status;
SELECT '========================================' AS separator;

SELECT 'station 表结构:' AS info;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'station'
ORDER BY ordinal_position;

SELECT '----------------------------------------' AS separator;

SELECT 'station_account 表结构:' AS info;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'station_account'
ORDER BY ordinal_position;

SELECT '========================================' AS separator;
SELECT '脚本执行完成!' AS status;
SELECT '========================================' AS separator;
