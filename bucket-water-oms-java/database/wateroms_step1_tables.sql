-- ============================================================================
-- 水厂订货管理系统 - 完整数据库初始化脚本
-- 数据库: wateroms
-- 使用 gen_random_uuid() 代替 uuid-ossp 扩展
-- ============================================================================

-- 注意：如果 PostgreSQL < 13，使用以下方式生成 UUID
-- 所有 UUID 主键改用 DEFAULT 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'::uuid
-- 但由于我们使用固定 UUID 插入数据，所以不需要 DEFAULT

-- 步骤1: 创建用户表 (users)
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone VARCHAR(20) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(50) NOT NULL,
    role VARCHAR(20) NOT NULL,
    warehouse_id UUID,
    station_id UUID,
    driver_id UUID,
    status VARCHAR(20) DEFAULT 'active',
    last_login_time TIMESTAMP,
    last_login_ip VARCHAR(50),
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    create_by VARCHAR(50),
    update_by VARCHAR(50),
    deleted INTEGER DEFAULT 0
);

-- 步骤2: 创建水站表 (station)
CREATE TABLE IF NOT EXISTS station (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    contact VARCHAR(50),
    phone VARCHAR(20),
    address TEXT,
    lat DECIMAL(10,6),
    lng DECIMAL(10,6),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 步骤3: 创建水站账户表 (station_account)
CREATE TABLE IF NOT EXISTS station_account (
    id UUID PRIMARY KEY,
    station_id UUID NOT NULL UNIQUE,
    deposit_balance DECIMAL(12,2) DEFAULT 0.00,
    credit_limit DECIMAL(12,2) DEFAULT 0.00,
    credit_used DECIMAL(12,2) DEFAULT 0.00,
    bucket_deposit_per_unit DECIMAL(10,2) DEFAULT 30.00,
    owed_bucket_num INT DEFAULT 0,
    owed_threshold INT DEFAULT 10,
    payment_type VARCHAR(20) DEFAULT 'prepaid',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 步骤4: 创建仓库表 (warehouse)
CREATE TABLE IF NOT EXISTS warehouse (
    id UUID PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address TEXT,
    contact_phone VARCHAR(20),
    lat DECIMAL(10,6),
    lng DECIMAL(10,6),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 步骤5: 创建司机表 (driver)
CREATE TABLE IF NOT EXISTS driver (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    region VARCHAR(100),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 步骤6: 创建商品表 (product)
CREATE TABLE IF NOT EXISTS product (
    id UUID PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    specification VARCHAR(100),
    price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    safe_stock INT DEFAULT 50,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 步骤7: 创建仓库库存表 (product_inventory)
CREATE TABLE IF NOT EXISTS product_inventory (
    id UUID PRIMARY KEY,
    warehouse_id UUID NOT NULL,
    product_id UUID NOT NULL,
    quantity INT DEFAULT 0,
    safe_stock INT DEFAULT 50,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(warehouse_id, product_id)
);

-- 步骤8: 创建订单表 (orders)
CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_no VARCHAR(32) NOT NULL UNIQUE,
    station_id UUID NOT NULL,
    warehouse_id UUID NOT NULL,
    driver_id UUID,
    status VARCHAR(30) DEFAULT 'pending_review',
    total_amount DECIMAL(12,2) DEFAULT 0.00,
    payment_type VARCHAR(20) DEFAULT 'prepaid',
    delivery_address TEXT,
    contact_name VARCHAR(50),
    contact_phone VARCHAR(20),
    reject_reason TEXT,
    sign_photos JSONB,
    delivered_qty INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP,
    dispatched_at TIMESTAMP,
    delivered_at TIMESTAMP
);

-- 步骤9: 创建订单商品明细表 (order_item)
CREATE TABLE IF NOT EXISTS order_item (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL,
    product_id UUID NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    actual_qty INT DEFAULT 0,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL
);

-- 步骤10: 创建空桶流水表 (bucket_transaction)
CREATE TABLE IF NOT EXISTS bucket_transaction (
    id UUID PRIMARY KEY,
    station_id UUID NOT NULL,
    order_id UUID,
    driver_id UUID,
    warehouse_id UUID,
    type VARCHAR(30) NOT NULL,
    quantity INT NOT NULL,
    balance INT DEFAULT 0,
    remark TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 步骤11: 创建司机回仓表 (driver_return)
CREATE TABLE IF NOT EXISTS driver_return (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID NOT NULL,
    warehouse_id UUID NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    bucket_returned INT DEFAULT 0,
    actual_bucket_qty INT,
    difference INT,
    difference_reason TEXT,
    replenishment JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    checked_at TIMESTAMP
);

-- 步骤12: 创建对账单表 (monthly_statement)
CREATE TABLE IF NOT EXISTS monthly_statement (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    station_id UUID NOT NULL,
    year_month VARCHAR(7) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    opening_balance DECIMAL(12,2) DEFAULT 0.00,
    total_amount DECIMAL(12,2) DEFAULT 0.00,
    payment_received DECIMAL(12,2) DEFAULT 0.00,
    closing_balance DECIMAL(12,2) DEFAULT 0.00,
    status VARCHAR(20) DEFAULT 'generated',
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    confirmed_at TIMESTAMP,
    UNIQUE(station_id, year_month)
);

-- 步骤13: 创建售后表 (after_sales)
CREATE TABLE IF NOT EXISTS after_sales (
    id UUID PRIMARY KEY,
    order_id UUID NOT NULL,
    station_id UUID NOT NULL,
    product_id UUID,
    type VARCHAR(30) NOT NULL,
    reason TEXT NOT NULL,
    photos JSONB,
    request_type VARCHAR(20) NOT NULL,
    requested_quantity INT DEFAULT 1,
    status VARCHAR(20) DEFAULT 'pending',
    new_order_id UUID,
    reject_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP
);

-- 步骤14: 创建水站商品价格表 (station_product_price)
CREATE TABLE IF NOT EXISTS station_product_price (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    station_id UUID NOT NULL,
    product_id UUID NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    discount_rate DECIMAL(5,4) DEFAULT 1.0000,
    is_enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(station_id, product_id)
);

-- 步骤15: 创建阶梯价表 (product_tier_price)
CREATE TABLE IF NOT EXISTS product_tier_price (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    station_id UUID NOT NULL,
    product_id UUID NOT NULL,
    min_quantity INT NOT NULL,
    max_quantity INT,
    tier_price DECIMAL(10,2) NOT NULL,
    is_enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(station_id, product_id, min_quantity)
);

-- 步骤16: 创建通知表 (notification)
CREATE TABLE IF NOT EXISTS notification (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    type VARCHAR(30) DEFAULT 'system',
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 步骤17: 创建索引
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_deleted ON users(deleted);
CREATE INDEX IF NOT EXISTS idx_users_warehouse ON users(warehouse_id);
CREATE INDEX IF NOT EXISTS idx_users_station ON users(station_id);
CREATE INDEX IF NOT EXISTS idx_users_driver ON users(driver_id);
CREATE INDEX IF NOT EXISTS idx_station_status ON station(status);
CREATE INDEX IF NOT EXISTS idx_warehouse_status ON warehouse(status);
CREATE INDEX IF NOT EXISTS idx_warehouse_location ON warehouse(lat, lng);
CREATE INDEX IF NOT EXISTS idx_driver_region ON driver(region);
CREATE INDEX IF NOT EXISTS idx_driver_status ON driver(status);
CREATE INDEX IF NOT EXISTS idx_product_category ON product(category);
CREATE INDEX IF NOT EXISTS idx_product_status ON product(status);
CREATE INDEX IF NOT EXISTS idx_product_inventory_warehouse_product ON product_inventory(warehouse_id, product_id);
CREATE INDEX IF NOT EXISTS idx_orders_station_created ON orders(station_id, created_at);
CREATE INDEX IF NOT EXISTS idx_orders_warehouse_status ON orders(warehouse_id, status);
CREATE INDEX IF NOT EXISTS idx_orders_driver_status ON orders(driver_id, status);
CREATE INDEX IF NOT EXISTS idx_orders_status_created ON orders(status, created_at);
CREATE INDEX IF NOT EXISTS idx_orders_order_no ON orders(order_no);
CREATE INDEX IF NOT EXISTS idx_order_item_order ON order_item(order_id);
CREATE INDEX IF NOT EXISTS idx_bucket_trans_station_created ON bucket_transaction(station_id, created_at);
CREATE INDEX IF NOT EXISTS idx_bucket_trans_order ON bucket_transaction(order_id);
CREATE INDEX IF NOT EXISTS idx_bucket_trans_driver ON bucket_transaction(driver_id);
CREATE INDEX IF NOT EXISTS idx_driver_return_driver_status ON driver_return(driver_id, status);
CREATE INDEX IF NOT EXISTS idx_driver_return_warehouse_status ON driver_return(warehouse_id, status);
CREATE INDEX IF NOT EXISTS idx_monthly_statement_station ON monthly_statement(station_id);
CREATE INDEX IF NOT EXISTS idx_after_sales_order ON after_sales(order_id);
CREATE INDEX IF NOT EXISTS idx_after_sales_station_status ON after_sales(station_id, status);
CREATE INDEX IF NOT EXISTS idx_after_sales_status_created ON after_sales(status, created_at);
CREATE INDEX IF NOT EXISTS idx_station_product_price_station ON station_product_price(station_id);
CREATE INDEX IF NOT EXISTS idx_station_product_price_product ON station_product_price(product_id);
CREATE INDEX IF NOT EXISTS idx_tier_price_station_product ON product_tier_price(station_id, product_id);
CREATE INDEX IF NOT EXISTS idx_notification_user ON notification(user_id);
CREATE INDEX IF NOT EXISTS idx_notification_read ON notification(is_read);

-- 步骤18: 创建触发器函数
DO $$
BEGIN
    DROP TRIGGER IF EXISTS trg_update_delivered_at ON orders;
    DROP TRIGGER IF EXISTS trg_update_inventory ON orders;
END $$;

CREATE OR REPLACE FUNCTION update_delivered_at()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
        NEW.delivered_at := CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_delivered_at
    BEFORE UPDATE OF status ON orders
    FOR EACH ROW
    EXECUTE FUNCTION update_delivered_at();

CREATE OR REPLACE FUNCTION update_inventory_on_delivery()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
        UPDATE product_inventory
        SET quantity = quantity - oi.actual_qty,
            updated_at = CURRENT_TIMESTAMP
        FROM order_item oi
        WHERE oi.order_id = NEW.id
          AND product_inventory.warehouse_id = NEW.warehouse_id
          AND product_inventory.product_id = oi.product_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_inventory
    BEFORE UPDATE OF status ON orders
    FOR EACH ROW
    EXECUTE FUNCTION update_inventory_on_delivery();

SELECT '表结构创建完成!' AS status;
