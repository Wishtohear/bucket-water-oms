-- 修复所有表的 ID 序列问题
-- 问题：之前部分实体使用 ASSIGN_ID（雪花算法）导致 ID 非常大
-- 解决方案：将所有实体改回 AUTO（数据库自增），并修复序列

-- =============================================
-- 1. 修复 driver 表
-- =============================================

-- 查看当前所有司机
SELECT 'driver 表记录:' as info;
SELECT id, name, phone FROM driver ORDER BY id;

-- 查看 users 表中与 driver 相关的记录
SELECT 'users 表中司机账号:' as info;
SELECT id, phone, role, driver_id FROM users WHERE driver_id IS NOT NULL ORDER BY id;

-- 先删除 users 表中引用了无效 driver_id 的记录
DELETE FROM users WHERE driver_id > 1000;

-- 删除 driver 表中 ID > 1000 的无效数据
DELETE FROM driver WHERE id > 1000;

-- 重置 driver 表的序列
SELECT 'driver 序列重置:' as info;
SELECT setval(
    pg_get_serial_sequence('driver', 'id'),
    (SELECT COALESCE(MAX(id), 0) + 1 FROM driver),
    false
);

-- =============================================
-- 2. 修复 users 表（如果有雪花算法生成的 ID）
-- =============================================

-- 查看 users 表中 ID > 1000 的记录
SELECT 'users 表中 ID > 1000 的记录:' as info;
SELECT id, phone, role FROM users WHERE id > 1000;

-- 先删除引用了无效 station_id 的记录
DELETE FROM users WHERE station_id > 1000;

-- 先删除引用了无效 warehouse_id 的记录
DELETE FROM users WHERE warehouse_id > 1000;

-- 删除 users 表中 ID > 1000 的无效数据
DELETE FROM users WHERE id > 1000;

-- 重置 users 表的序列（如果有的话）
SELECT 'users 序列重置:' as info;
SELECT setval(
    pg_get_serial_sequence('users', 'id'),
    (SELECT COALESCE(MAX(id), 0) + 1 FROM users),
    false
);

-- =============================================
-- 3. 修复 warehouse 表
-- =============================================

-- 查看当前所有仓库
SELECT 'warehouse 表记录:' as info;
SELECT id, name FROM warehouse ORDER BY id;

-- 查看 users 表中与 warehouse 相关的记录
SELECT 'users 表中仓库账号:' as info;
SELECT id, phone, role, warehouse_id FROM users WHERE warehouse_id IS NOT NULL ORDER BY id;

-- 先删除 users 表中引用了无效 warehouse_id 的记录
DELETE FROM users WHERE warehouse_id > 1000;

-- 删除 warehouse 表中 ID > 1000 的无效数据
DELETE FROM warehouse WHERE id > 1000;

-- 重置 warehouse 表的序列
SELECT 'warehouse 序列重置:' as info;
SELECT setval(
    pg_get_serial_sequence('warehouse', 'id'),
    (SELECT COALESCE(MAX(id), 0) + 1 FROM warehouse),
    false
);

-- =============================================
-- 4. 验证结果
-- =============================================

SELECT '=== 最终结果 ===' as info;

SELECT 'driver 表:' as info;
SELECT id, name, phone FROM driver ORDER BY id;
SELECT 'driver 序列值:' as info;
SELECT last_value FROM driver_id_seq;

SELECT 'warehouse 表:' as info;
SELECT id, name FROM warehouse ORDER BY id;
SELECT 'warehouse 序列值:' as info;
SELECT last_value FROM warehouse_id_seq;

SELECT 'users 表:' as info;
SELECT id, phone, role FROM users ORDER BY id;
SELECT 'users 序列值:' as info;
SELECT last_value FROM users_id_seq;
