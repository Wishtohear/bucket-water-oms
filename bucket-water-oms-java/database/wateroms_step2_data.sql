-- ============================================================================
-- 水厂订货管理系统 - 数据初始化脚本（步骤2）
-- 数据库: wateroms
-- ============================================================================

-- 步骤1: 插入水站
INSERT INTO station (id, name, contact, phone, address, lat, lng, status) VALUES
    ('00000001-0000-0000-0000-000000000001', '朝阳区第一水站', '张三', '13800000001', '北京市朝阳区建国路88号', 39.908, 116.404, 'active'),
    ('00000001-0000-0000-0000-000000000002', '海淀区桶装水站', '李四', '13800000002', '北京市海淀区中关村大街100号', 39.989, 116.306, 'active'),
    ('00000001-0000-0000-0000-000000000003', '东城区净水站', '王五', '13800000003', '北京市东城区王府井大街50号', 39.914, 116.407, 'active')
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    contact = EXCLUDED.contact,
    phone = EXCLUDED.phone,
    address = EXCLUDED.address,
    lat = EXCLUDED.lat,
    lng = EXCLUDED.lng,
    status = EXCLUDED.status;

-- 步骤2: 插入水站账户
INSERT INTO station_account (id, station_id, deposit_balance, credit_limit, credit_used, bucket_deposit_per_unit, owed_bucket_num, owed_threshold, payment_type) VALUES
    ('00000010-0000-0000-0000-000000000001', '00000001-0000-0000-0000-000000000001', 5000.00, 10000.00, 0.00, 30.00, 5, 10, 'prepaid'),
    ('00000010-0000-0000-0000-000000000002', '00000001-0000-0000-0000-000000000002', 3000.00, 5000.00, 0.00, 30.00, 3, 8, 'monthly'),
    ('00000010-0000-0000-0000-000000000003', '00000001-0000-0000-0000-000000000003', 10000.00, 20000.00, 0.00, 30.00, 0, 15, 'prepaid')
ON CONFLICT (station_id) DO UPDATE SET
    deposit_balance = EXCLUDED.deposit_balance,
    credit_limit = EXCLUDED.credit_limit,
    credit_used = EXCLUDED.credit_used,
    bucket_deposit_per_unit = EXCLUDED.bucket_deposit_per_unit,
    owed_bucket_num = EXCLUDED.owed_bucket_num,
    owed_threshold = EXCLUDED.owed_threshold,
    payment_type = EXCLUDED.payment_type;

-- 步骤3: 插入仓库
INSERT INTO warehouse (id, name, address, contact_phone, lat, lng, status) VALUES
    ('00000020-0000-0000-0000-000000000001', '北京中央仓库', '北京市顺义区首都机场路100号', '010-88888801', 40.0795, 116.652, 'active'),
    ('00000020-0000-0000-0000-000000000002', '朝阳配送中心', '北京市朝阳区东四环中路80号', '010-88888802', 39.9285, 116.449, 'active'),
    ('00000020-0000-0000-0000-000000000003', '海淀配送站', '北京市海淀区上地信息路50号', '010-88888803', 40.026, 116.312, 'active')
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    address = EXCLUDED.address,
    contact_phone = EXCLUDED.contact_phone,
    lat = EXCLUDED.lat,
    lng = EXCLUDED.lng,
    status = EXCLUDED.status;

-- 步骤4: 插入司机
INSERT INTO driver (id, name, phone, region, status) VALUES
    ('00000030-0000-0000-0000-000000000001', '赵师傅', '13900000001', '朝阳区', 'active'),
    ('00000030-0000-0000-0000-000000000002', '钱师傅', '13900000002', '海淀区', 'active'),
    ('00000030-0000-0000-0000-000000000003', '孙师傅', '13900000003', '东城区', 'active'),
    ('00000030-0000-0000-0000-000000000004', '李师傅', '13900000004', '朝阳区/海淀区', 'active')
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    phone = EXCLUDED.phone,
    region = EXCLUDED.region,
    status = EXCLUDED.status;

-- 步骤5: 插入商品
INSERT INTO product (id, name, category, specification, price, safe_stock, status) VALUES
    ('00000040-0000-0000-0000-000000000001', '纯净水18.9L', 'bucket_water', '18.9L/桶', 15.00, 50, 'active'),
    ('00000040-0000-0000-0000-000000000002', '矿泉水18.9L', 'bucket_water', '18.9L/桶', 18.00, 50, 'active'),
    ('00000040-0000-0000-0000-000000000003', '纯净水11.3L', 'bucket_water', '11.3L/桶', 10.00, 50, 'active'),
    ('00000040-0000-0000-0000-000000000004', '矿泉水550ml', 'bottled_water', '550ml*24瓶/箱', 36.00, 30, 'active'),
    ('00000040-0000-0000-0000-000000000005', '饮水机 JD-01', 'equipment', '温热型', 299.00, 10, 'active'),
    ('00000040-0000-0000-0000-000000000006', '桶装水抽水器', 'equipment', '手动按压式', 25.00, 20, 'active')
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    category = EXCLUDED.category,
    specification = EXCLUDED.specification,
    price = EXCLUDED.price,
    safe_stock = EXCLUDED.safe_stock,
    status = EXCLUDED.status;

-- 步骤6: 插入仓库库存
INSERT INTO product_inventory (id, warehouse_id, product_id, quantity, safe_stock) VALUES
    ('00000050-0000-0000-0000-000000000001', '00000020-0000-0000-0000-000000000001', '00000040-0000-0000-0000-000000000001', 500, 50),
    ('00000050-0000-0000-0000-000000000002', '00000020-0000-0000-0000-000000000001', '00000040-0000-0000-0000-000000000002', 300, 50),
    ('00000050-0000-0000-0000-000000000003', '00000020-0000-0000-0000-000000000001', '00000040-0000-0000-0000-000000000003', 200, 50),
    ('00000050-0000-0000-0000-000000000004', '00000020-0000-0000-0000-000000000001', '00000040-0000-0000-0000-000000000004', 100, 30),
    ('00000050-0000-0000-0000-000000000005', '00000020-0000-0000-0000-000000000002', '00000040-0000-0000-0000-000000000001', 400, 50),
    ('00000050-0000-0000-0000-000000000006', '00000020-0000-0000-0000-000000000002', '00000040-0000-0000-0000-000000000002', 250, 50),
    ('00000050-0000-0000-0000-000000000007', '00000020-0000-0000-0000-000000000003', '00000040-0000-0000-0000-000000000001', 350, 50),
    ('00000050-0000-0000-0000-000000000008', '00000020-0000-0000-0000-000000000003', '00000040-0000-0000-0000-000000000003', 150, 50)
ON CONFLICT (warehouse_id, product_id) DO UPDATE SET
    quantity = EXCLUDED.quantity,
    safe_stock = EXCLUDED.safe_stock;

-- 步骤7: 插入用户（密码 123456 的BCrypt加密）
-- 超级管理员: 13800138000 / 123456 / admin
-- 系统管理员: 13700000001 / 123456 / admin
-- 仓库管理员: 13700000002 / 123456 / warehouse
-- 司机: 13700000004 / 123456 / driver
-- 水站老板: 13700000006 / 123456 / station
-- BCrypt加密后: $2a$10$bAb.reCeaavLQXH2Yi.ZYe6y2jKZPyvFVhgRno723sh20zpDdd6Fy
-- 注意: id 使用数据库默认值 gen_random_uuid() 自动生成
INSERT INTO users (phone, password, name, role, warehouse_id, station_id, driver_id, status) VALUES
    -- 超级管理员
    ('13800138000', '$2a$10$bAb.reCeaavLQXH2Yi.ZYe6y2jKZPyvFVhgRno723sh20zpDdd6Fy', '超级管理员', 'admin', NULL, NULL, NULL, 'active'),
    -- 系统管理员
    ('13700000001', '$2a$10$bAb.reCeaavLQXH2Yi.ZYe6y2jKZPyvFVhgRno723sh20zpDdd6Fy', '系统管理员', 'admin', NULL, NULL, NULL, 'active'),
    -- 仓库管理员A
    ('13700000002', '$2a$10$bAb.reCeaavLQXH2Yi.ZYe6y2jKZPyvFVhgRno723sh20zpDdd6Fy', '仓库管理员A', 'warehouse', '00000020-0000-0000-0000-000000000001', NULL, NULL, 'active'),
    -- 仓库管理员B
    ('13700000003', '$2a$10$bAb.reCeaavLQXH2Yi.ZYe6y2jKZPyvFVhgRno723sh20zpDdd6Fy', '仓库管理员B', 'warehouse', '00000020-0000-0000-0000-000000000002', NULL, NULL, 'active'),
    -- 赵师傅
    ('13700000004', '$2a$10$bAb.reCeaavLQXH2Yi.ZYe6y2jKZPyvFVhgRno723sh20zpDdd6Fy', '赵师傅', 'driver', NULL, NULL, '00000030-0000-0000-0000-000000000001', 'active'),
    -- 钱师傅
    ('13700000005', '$2a$10$bAb.reCeaavLQXH2Yi.ZYe6y2jKZPyvFVhgRno723sh20zpDdd6Fy', '钱师傅', 'driver', NULL, NULL, '00000030-0000-0000-0000-000000000002', 'active'),
    -- 张三（水站老板）
    ('13700000006', '$2a$10$bAb.reCeaavLQXH2Yi.ZYe6y2jKZPyvFVhgRno723sh20zpDdd6Fy', '张三（水站老板）', 'station', NULL, '00000001-0000-0000-0000-000000000001', NULL, 'active'),
    -- 李四（水站老板）
    ('13700000007', '$2a$10$bAb.reCeaavLQXH2Yi.ZYe6y2jKZPyvFVhgRno723sh20zpDdd6Fy', '李四（水站老板）', 'station', NULL, '00000001-0000-0000-0000-000000000002', NULL, 'active'),
    -- 王五（水站老板）
    ('13700000008', '$2a$10$bAb.reCeaavLQXH2Yi.ZYe6y2jKZPyvFVhgRno723sh20zpDdd6Fy', '王五（水站老板）', 'station', NULL, '00000001-0000-0000-0000-000000000003', NULL, 'active'),
    -- 店员-小张
    ('13700000009', '$2a$10$bAb.reCeaavLQXH2Yi.ZYe6y2jKZPyvFVhgRno723sh20zpDdd6Fy', '店员-小张', 'staff', NULL, '00000001-0000-0000-0000-000000000001', NULL, 'active')
ON CONFLICT (phone) DO UPDATE SET
    password = EXCLUDED.password,
    name = EXCLUDED.name,
    role = EXCLUDED.role,
    warehouse_id = EXCLUDED.warehouse_id,
    station_id = EXCLUDED.station_id,
    driver_id = EXCLUDED.driver_id,
    status = EXCLUDED.status;

-- 步骤8: 验证数据
SELECT '验证结果:' AS info;
SELECT 'users' AS table_name, COUNT(*) AS row_count FROM users
UNION ALL
SELECT 'station', COUNT(*) FROM station
UNION ALL
SELECT 'station_account', COUNT(*) FROM station_account
UNION ALL
SELECT 'warehouse', COUNT(*) FROM warehouse
UNION ALL
SELECT 'driver', COUNT(*) FROM driver
UNION ALL
SELECT 'product', COUNT(*) FROM product
UNION ALL
SELECT 'product_inventory', COUNT(*) FROM product_inventory;

SELECT '数据插入完成!' AS status;
