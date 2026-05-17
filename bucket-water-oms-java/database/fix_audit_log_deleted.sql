-- 修复审计日志表的 deleted 字段
-- 将所有 deleted 为 NULL 的记录设置为 0

UPDATE audit_log SET deleted = 0 WHERE deleted IS NULL;

-- 验证修复结果
SELECT 
    COUNT(*) as total_count,
    COUNT(CASE WHEN deleted = 0 THEN 1 END) as active_count,
    COUNT(CASE WHEN deleted = 1 THEN 1 END) as deleted_count,
    COUNT(CASE WHEN deleted IS NULL THEN 1 END) as null_count
FROM audit_log;
