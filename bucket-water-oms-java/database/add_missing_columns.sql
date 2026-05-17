-- 添加 orders 表缺失的 remark 列
-- 执行前请先备份数据库

-- 检查列是否存在，如果不存在则添加
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'orders' AND column_name = 'remark'
    ) THEN
        ALTER TABLE orders ADD COLUMN remark TEXT;
        RAISE NOTICE 'Column remark added to orders table';
    ELSE
        RAISE NOTICE 'Column remark already exists in orders table';
    END IF;
END $$;

-- 验证表结构
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'orders'
ORDER BY ordinal_position;
