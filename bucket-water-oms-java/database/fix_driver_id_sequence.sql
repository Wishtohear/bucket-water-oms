-- 修复 driver 表的 ID 序列问题
-- 问题：之前使用 ASSIGN_ID（雪花算法）导致 ID 非常大
-- 解决方案：先删除 users 表中的无效引用，再删除 driver 表中的无效数据

-- 1. 查看当前所有司机
SELECT id, name, phone FROM driver;

-- 2. 查看 users 表中与 driver 相关的记录
SELECT id, phone, role, driver_id FROM users WHERE driver_id IS NOT NULL;

-- 3. 先删除 users 表中引用了无效 driver_id 的记录（ID > 1000 的通常是雪花算法生成的）
DELETE FROM users WHERE driver_id > 1000;

-- 4. 删除 driver 表中 ID > 1000 的无效数据
DELETE FROM driver WHERE id > 1000;

-- 5. 重置 driver 表的序列
SELECT setval(
    pg_get_serial_sequence('driver', 'id'),
    (SELECT COALESCE(MAX(id), 0) + 1 FROM driver),
    false
);

-- 6. 重置 users 表的序列（如果有的话）
-- SELECT setval(
--     pg_get_serial_sequence('users', 'id'),
--     (SELECT COALESCE(MAX(id), 0) + 1 FROM users),
--     false
-- );

-- 7. 验证结果
SELECT 'driver 表当前记录:' as info;
SELECT id, name, phone FROM driver;

SELECT 'driver 序列当前值:' as info;
SELECT last_value FROM driver_id_seq;

SELECT 'users 表中司机账号:' as info;
SELECT id, phone, role, driver_id FROM users WHERE driver_id IS NOT NULL;
