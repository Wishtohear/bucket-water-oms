-- ============================================================================
-- 添加 station_account 表的 deposit_bucket_num 字段
-- ============================================================================

-- 检查字段是否已存在
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'station_account' AND column_name = 'deposit_bucket_num'
    ) THEN
        ALTER TABLE station_account ADD COLUMN deposit_bucket_num INTEGER DEFAULT 0;
        RAISE NOTICE '成功添加 deposit_bucket_num 字段到 station_account 表';
    ELSE
        RAISE NOTICE 'deposit_bucket_num 字段已存在，跳过';
    END IF;
END $$;

-- 显示结果
SELECT 'station_account 表当前结构:' AS info;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'station_account'
ORDER BY ordinal_position;
