-- 添加司机回仓新水站派送相关字段
-- 执行方式: psql -h 192.168.31.251 -p 5432 -U wateroms -d wateroms -f "add_driver_return_station_delivery.sql"

-- 添加是否为新水站派送字段
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'driver_return' AND column_name = 'is_new_station_delivery') THEN
        ALTER TABLE driver_return ADD COLUMN is_new_station_delivery BOOLEAN DEFAULT FALSE;
        COMMENT ON COLUMN driver_return.is_new_station_delivery IS '是否为新水站派送';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '添加字段失败或字段已存在: %', SQLERRM;
END $$;

-- 添加新水站派送明细JSON字段
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'driver_return' AND column_name = 'station_deliveries') THEN
        ALTER TABLE driver_return ADD COLUMN station_deliveries TEXT;
        COMMENT ON COLUMN driver_return.station_deliveries IS '新水站派送明细JSON，格式：[{\"stationId\": 1, \"bucketCount\": 10}]';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '添加字段失败或字段已存在: %', SQLERRM;
END $$;

-- 验证修改（修复 PostgreSQL 列注释查询语法）
SELECT 
    a.attname AS column_name,
    pg_catalog.format_type(a.atttypid, a.atttypmod) AS data_type,
    COALESCE(pg_get_expr(d.adbin, d.adrelid), '') AS column_default,
    col_description(a.attrelid, a.attnum) AS col_description
FROM pg_catalog.pg_attribute a
JOIN pg_catalog.pg_class c ON a.attrelid = c.oid
LEFT JOIN pg_catalog.pg_attrdef d ON (a.attrelid = d.adrelid AND a.attnum = d.adnum)
WHERE c.relname = 'driver_return'
  AND a.attnum > 0
  AND NOT a.attisdropped
ORDER BY a.attnum;
