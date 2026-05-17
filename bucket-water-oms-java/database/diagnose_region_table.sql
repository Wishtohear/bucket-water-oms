-- ============================================================================
-- Region 表诊断脚本
-- 用途: 检查 region 表是否存在，结构是否正确
-- ============================================================================

-- 1. 检查 region 表是否存在
SELECT EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'region'
) AS region_table_exists;

-- 2. 查看 region 表结构
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'region'
ORDER BY ordinal_position;

-- 3. 检查 region 表是否有 deleted 列
SELECT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'region' AND column_name = 'deleted'
) AS has_deleted_column;

-- 4. 检查 region 表是否有 create_time/update_time 列
SELECT
    column_name,
    EXISTS (
        SELECT 1 FROM information_schema.columns c2
        WHERE c2.table_name = 'region' AND c2.column_name = 'create_time'
    ) AS has_create_time,
    EXISTS (
        SELECT 1 FROM information_schema.columns c3
        WHERE c3.table_name = 'region' AND c3.column_name = 'update_time'
    ) AS has_update_time
FROM information_schema.columns
WHERE table_name = 'region'
LIMIT 1;

-- 5. 如果 region 表不存在，输出提示
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'region'
    ) THEN
        RAISE NOTICE '========================================';
        RAISE NOTICE 'ERROR: region 表不存在!';
        RAISE NOTICE '请执行 database/region_module.sql 脚本来创建表';
        RAISE NOTICE '========================================';
    ELSE
        -- 检查并添加缺失的列
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_name = 'region' AND column_name = 'deleted'
        ) THEN
            ALTER TABLE region ADD COLUMN deleted INTEGER DEFAULT 0;
            RAISE NOTICE '已添加 deleted 列到 region 表';
        END IF;

        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_name = 'region' AND column_name = 'create_time'
        ) THEN
            ALTER TABLE region ADD COLUMN create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
            RAISE NOTICE '已添加 create_time 列到 region 表';
        END IF;

        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_name = 'region' AND column_name = 'update_time'
        ) THEN
            ALTER TABLE region ADD COLUMN update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
            RAISE NOTICE '已添加 update_time 列到 region 表';
        END IF;

        RAISE NOTICE 'region 表结构已修复!';
    END IF;
END $$;

-- 6. 显示 region 表最终结构
SELECT 'region 表结构:' AS info;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'region'
ORDER BY ordinal_position;

-- 7. 显示 region 表数据
SELECT 'region 表数据:' AS info;
SELECT * FROM region LIMIT 10;
