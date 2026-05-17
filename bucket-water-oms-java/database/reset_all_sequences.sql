-- =============================================
-- 重置数据库中所有 BIGSERIAL 序列
-- 执行时间: 2026-04-24
-- 安全版本：跳过不存在的表
-- =============================================

DO $$
DECLARE
    table_rec RECORD;
    seq_name TEXT;
    max_id BIGINT;
BEGIN
    FOR table_rec IN 
        SELECT table_name FROM information_schema.tables 
        WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
        ORDER BY table_name
    LOOP
        IF EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = 'public' 
              AND table_name = table_rec.table_name 
              AND column_name = 'id'
        ) THEN
            seq_name := table_rec.table_name || '_id_seq';
            
            IF EXISTS (
                SELECT 1 FROM pg_class WHERE relname = seq_name
            ) THEN
                EXECUTE format('SELECT COALESCE(MAX(id), 0) + 1 FROM %I', table_rec.table_name) INTO max_id;
                EXECUTE format('SELECT setval(%L, %L, false)', seq_name, max_id);
                RAISE NOTICE '已重置 % 序列，设置为 %', seq_name, max_id;
            END IF;
        END IF;
    END LOOP;
END $$;

-- =============================================
-- 验证：查看所有序列的当前值
-- =============================================

SELECT '=== 所有序列当前值 ===' AS info;

SELECT 
    c.relname AS sequence_name,
    seq.last_value AS seq_last_value
FROM pg_class c
JOIN pg_sequence seq ON seq.seqrelid = c.oid
WHERE c.relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
  AND c.relkind = 'S'
ORDER BY c.relname;

SELECT '=== 重置完成 ===' AS info;
