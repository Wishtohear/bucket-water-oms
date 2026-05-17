-- 为 warehouse 表添加缺失的字段
-- 执行命令: psql -h 192.168.31.251 -p 5432 -U wateroms -d wateroms -f "add_warehouse_fields.sql"

-- 添加 contact 列（联系人）
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'warehouse' AND column_name = 'contact') THEN
        ALTER TABLE warehouse ADD COLUMN contact VARCHAR(100);
        RAISE NOTICE '已添加 contact 列';
    ELSE
        RAISE NOTICE 'contact 列已存在';
    END IF;
END $$;

-- 添加 coverage_area 列（覆盖区域）
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'warehouse' AND column_name = 'coverage_area') THEN
        ALTER TABLE warehouse ADD COLUMN coverage_area VARCHAR(200);
        RAISE NOTICE '已添加 coverage_area 列';
    ELSE
        RAISE NOTICE 'coverage_area 列已存在';
    END IF;
END $$;

-- 添加 type 列（仓库类型）
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'warehouse' AND column_name = 'type') THEN
        ALTER TABLE warehouse ADD COLUMN type VARCHAR(20) DEFAULT 'branch';
        RAISE NOTICE '已添加 type 列';
    ELSE
        RAISE NOTICE 'type 列已存在';
    END IF;
END $$;

-- 验证表结构
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'warehouse'
ORDER BY ordinal_position;
