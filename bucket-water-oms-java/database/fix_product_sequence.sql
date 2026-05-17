-- =============================================
-- 修复 product 表主键序列不同步问题
-- 执行时间: 2026-04-24
-- 问题: duplicate key value violates unique constraint "product_pkey"
--       Key (id)=(5) already exists.
-- =============================================

-- 查看当前 product 表的数据
SELECT '=== product 表当前数据 ===' AS info;
SELECT id, code, name FROM product ORDER BY id;

-- 查看当前序列值
SELECT '=== product_id_seq 当前序列值 ===' AS info;
SELECT last_value FROM product_id_seq;

-- 重置 product 序列
SELECT '=== 开始重置 product_id_seq ===' AS info;
SELECT setval(
    (SELECT pg_get_serial_sequence('product', 'id')),
    (SELECT COALESCE(MAX(id), 0) + 1 FROM product),
    false
);

-- 验证重置后的序列值
SELECT '=== 重置后 product_id_seq 序列值 ===' AS info;
SELECT last_value FROM product_id_seq;

-- =============================================
-- 同时重置其他可能有问题的序列
-- =============================================

-- 重置 users 序列
SELECT setval(
    (SELECT pg_get_serial_sequence('users', 'id')),
    (SELECT COALESCE(MAX(id), 0) + 1 FROM users),
    false
);
SELECT '已重置 users_id_seq' AS info, last_value FROM users_id_seq;

-- 重置 orders 序列
SELECT setval(
    (SELECT pg_get_serial_sequence('orders', 'id')),
    (SELECT COALESCE(MAX(id), 0) + 1 FROM orders),
    false
);
SELECT '已重置 orders_id_seq' AS info, last_value FROM orders_id_seq;

-- 重置 driver 序列
SELECT setval(
    (SELECT pg_get_serial_sequence('driver', 'id')),
    (SELECT COALESCE(MAX(id), 0) + 1 FROM driver),
    false
);
SELECT '已重置 driver_id_seq' AS info, last_value FROM driver_id_seq;

-- 重置 warehouse 序列
SELECT setval(
    (SELECT pg_get_serial_sequence('warehouse', 'id')),
    (SELECT COALESCE(MAX(id), 0) + 1 FROM warehouse),
    false
);
SELECT '已重置 warehouse_id_seq' AS info, last_value FROM warehouse_id_seq;

-- 重置 station 序列
SELECT setval(
    (SELECT pg_get_serial_sequence('station', 'id')),
    (SELECT COALESCE(MAX(id), 0) + 1 FROM station),
    false
);
SELECT '已重置 station_id_seq' AS info, last_value FROM station_id_seq;

SELECT '=== 测试完成 ===' AS info;
