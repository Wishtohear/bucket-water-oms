-- ============================================================================
-- 水厂订货管理系统 - 完整数据库初始化脚本
-- 数据库: wateroms
-- 版本: 1.0.1 (安全模式 - 兼容已有数据库)
-- 更新日期: 2026-04-20
-- 说明: 如果表已存在则只插入数据，如果表不存在则创建
-- ============================================================================

-- ============================================================================
-- 第一部分: 检查并创建序列 (用于BIGSERIAL主键)
-- ============================================================================
DO $$
DECLARE
    seq_name TEXT;
BEGIN
    FOREACH seq_name IN ARRAY ARRAY[
        'users_id_seq', 'station_id_seq', 'station_account_id_seq',
        'warehouse_id_seq', 'driver_id_seq', 'driver_return_id_seq',
        'driver_statement_id_seq', 'product_id_seq', 'product_inventory_id_seq',
        'product_tier_price_id_seq', 'station_product_price_id_seq',
        'orders_id_seq', 'order_item_id_seq', 'bucket_transaction_id_seq',
        'monthly_statement_id_seq', 'after_sales_id_seq', 'notification_id_seq',
        'system_config_id_seq', 'customer_id_seq', 'water_ticket_id_seq',
        'water_ticket_transaction_id_seq', 'warehouse_inbound_id_seq',
        'warehouse_inbound_item_id_seq', 'warehouse_outbound_id_seq',
        'warehouse_outbound_item_id_seq'
    ]
    LOOP
        EXECUTE format('CREATE SEQUENCE IF NOT EXISTS %I START 1 INCREMENT 1', seq_name);
    END LOOP;
END $$;

-- ============================================================================
-- 第二部分: 创建表结构 (如果不存在)
-- ============================================================================

-- 1. 水站表 (station)
CREATE TABLE IF NOT EXISTS station (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact VARCHAR(50),
    phone VARCHAR(20),
    address TEXT,
    lat DECIMAL(10,6),
    lng DECIMAL(10,6),
    status VARCHAR(20) DEFAULT 'active',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    create_by VARCHAR(50),
    update_by VARCHAR(50),
    deleted INTEGER DEFAULT 0
);

-- 2. 仓库表 (warehouse)
CREATE TABLE IF NOT EXISTS warehouse (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address TEXT,
    contact_phone VARCHAR(20),
    lat DECIMAL(10,6),
    lng DECIMAL(10,6),
    status VARCHAR(20) DEFAULT 'active',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    create_by VARCHAR(50),
    update_by VARCHAR(50),
    deleted INTEGER DEFAULT 0
);

-- 3. 司机表 (driver)
CREATE TABLE IF NOT EXISTS driver (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    region VARCHAR(100),
    status VARCHAR(20) DEFAULT 'active',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    create_by VARCHAR(50),
    update_by VARCHAR(50),
    deleted INTEGER DEFAULT 0
);

-- 4. 商品表 (product)
CREATE TABLE IF NOT EXISTS product (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    specification VARCHAR(100),
    price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    safe_stock INT DEFAULT 50,
    status VARCHAR(20) DEFAULT 'active',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    create_by VARCHAR(50),
    update_by VARCHAR(50),
    deleted INTEGER DEFAULT 0
);

-- 5. 用户表 (users)
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    phone VARCHAR(20) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(50) NOT NULL,
    role VARCHAR(20) NOT NULL,
    warehouse_id BIGINT,
    station_id BIGINT,
    driver_id BIGINT,
    status VARCHAR(20) DEFAULT 'active',
    last_login_time TIMESTAMP,
    last_login_ip VARCHAR(50),
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    create_by VARCHAR(50),
    update_by VARCHAR(50),
    deleted INTEGER DEFAULT 0
);

-- 6. 系统配置表 (system_config)
CREATE TABLE IF NOT EXISTS system_config (
    id BIGSERIAL PRIMARY KEY,
    config_key VARCHAR(100) NOT NULL UNIQUE,
    config_value TEXT,
    config_type VARCHAR(20) DEFAULT 'string',
    config_group VARCHAR(50),
    description VARCHAR(255),
    is_system BOOLEAN DEFAULT false,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    create_by VARCHAR(50),
    update_by VARCHAR(50),
    deleted INTEGER DEFAULT 0
);

-- 7. 水站账户表 (station_account)
CREATE TABLE IF NOT EXISTS station_account (
    id BIGSERIAL PRIMARY KEY,
    station_id BIGINT NOT NULL UNIQUE,
    deposit_balance DECIMAL(12,2) DEFAULT 0.00,
    credit_limit DECIMAL(12,2) DEFAULT 0.00,
    credit_used DECIMAL(12,2) DEFAULT 0.00,
    bucket_deposit_per_unit DECIMAL(10,2) DEFAULT 30.00,
    owed_bucket_num INT DEFAULT 0,
    owed_threshold INT DEFAULT 10,
    payment_type VARCHAR(20) DEFAULT 'prepaid',
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 8. 客户表 (customer)
CREATE TABLE IF NOT EXISTS customer (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    contact VARCHAR(50),
    status VARCHAR(20) DEFAULT 'active',
    station_id BIGINT,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    create_by VARCHAR(50),
    update_by VARCHAR(50),
    deleted INTEGER DEFAULT 0
);

-- 9. 水票表 (water_ticket)
CREATE TABLE IF NOT EXISTS water_ticket (
    id BIGSERIAL PRIMARY KEY,
    ticket_no VARCHAR(50) NOT NULL UNIQUE,
    station_id BIGINT,
    total_count INT DEFAULT 0,
    used_count INT DEFAULT 0,
    amount DECIMAL(12,2) DEFAULT 0.00,
    status VARCHAR(20) DEFAULT 'active',
    expire_date TIMESTAMP,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    create_by VARCHAR(50),
    update_by VARCHAR(50),
    deleted INTEGER DEFAULT 0
);

-- 10. 水票流水表 (water_ticket_transaction)
CREATE TABLE IF NOT EXISTS water_ticket_transaction (
    id BIGSERIAL PRIMARY KEY,
    ticket_id BIGINT NOT NULL,
    order_id BIGINT,
    used_count INT DEFAULT 0,
    deduct_amount DECIMAL(12,2) DEFAULT 0.00,
    type VARCHAR(20) NOT NULL,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    create_by VARCHAR(50),
    update_by VARCHAR(50),
    deleted INTEGER DEFAULT 0
);

-- 11. 仓库库存表 (product_inventory)
CREATE TABLE IF NOT EXISTS product_inventory (
    id BIGSERIAL PRIMARY KEY,
    warehouse_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT DEFAULT 0,
    safe_stock INT DEFAULT 50,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    create_by VARCHAR(50),
    update_by VARCHAR(50),
    deleted INTEGER DEFAULT 0,
    UNIQUE(warehouse_id, product_id)
);

-- 12. 水站商品价格表 (station_product_price)
CREATE TABLE IF NOT EXISTS station_product_price (
    id BIGSERIAL PRIMARY KEY,
    station_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    discount_rate DECIMAL(5,4) DEFAULT 1.0000,
    is_enabled BOOLEAN DEFAULT true,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    create_by VARCHAR(50),
    update_by VARCHAR(50),
    deleted INTEGER DEFAULT 0,
    UNIQUE(station_id, product_id)
);

-- 13. 阶梯价表 (product_tier_price)
CREATE TABLE IF NOT EXISTS product_tier_price (
    id BIGSERIAL PRIMARY KEY,
    station_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    min_quantity INT NOT NULL,
    max_quantity INT,
    tier_price DECIMAL(10,2) NOT NULL,
    is_enabled BOOLEAN DEFAULT true,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    create_by VARCHAR(50),
    update_by VARCHAR(50),
    deleted INTEGER DEFAULT 0,
    UNIQUE(station_id, product_id, min_quantity)
);

-- 14. 订单表 (orders)
CREATE TABLE IF NOT EXISTS orders (
    id BIGSERIAL PRIMARY KEY,
    order_no VARCHAR(32) NOT NULL UNIQUE,
    station_id BIGINT NOT NULL,
    warehouse_id BIGINT NOT NULL,
    driver_id BIGINT,
    status VARCHAR(30) DEFAULT 'pending_review',
    total_amount DECIMAL(12,2) DEFAULT 0.00,
    payment_type VARCHAR(20) DEFAULT 'prepaid',
    delivery_address TEXT,
    contact_name VARCHAR(50),
    contact_phone VARCHAR(20),
    reject_reason TEXT,
    remark TEXT,
    sign_photos TEXT,
    delivered_qty INT DEFAULT 0,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP,
    dispatched_at TIMESTAMP,
    delivered_at TIMESTAMP,
    create_by VARCHAR(50),
    update_by VARCHAR(50),
    deleted INTEGER DEFAULT 0
);

-- 15. 订单商品明细表 (order_item)
CREATE TABLE IF NOT EXISTS order_item (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    actual_qty INT DEFAULT 0,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    create_by VARCHAR(50),
    update_by VARCHAR(50),
    deleted INTEGER DEFAULT 0
);

-- 16. 售后表 (after_sales)
CREATE TABLE IF NOT EXISTS after_sales (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    station_id BIGINT NOT NULL,
    product_id BIGINT,
    type VARCHAR(30) NOT NULL,
    reason TEXT NOT NULL,
    photos TEXT,
    request_type VARCHAR(20) NOT NULL,
    requested_quantity INT DEFAULT 1,
    status VARCHAR(20) DEFAULT 'pending',
    new_order_id BIGINT,
    reject_reason TEXT,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP,
    create_by VARCHAR(50),
    update_by VARCHAR(50),
    deleted INTEGER DEFAULT 0
);

-- 17. 空桶流水表 (bucket_transaction)
CREATE TABLE IF NOT EXISTS bucket_transaction (
    id BIGSERIAL PRIMARY KEY,
    station_id BIGINT NOT NULL,
    order_id BIGINT,
    driver_id BIGINT,
    warehouse_id BIGINT,
    type VARCHAR(30) NOT NULL,
    quantity INT NOT NULL,
    balance INT DEFAULT 0,
    remark TEXT,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    create_by VARCHAR(50),
    update_by VARCHAR(50),
    deleted INTEGER DEFAULT 0
);

-- 18. 司机回仓表 (driver_return)
CREATE TABLE IF NOT EXISTS driver_return (
    id BIGSERIAL PRIMARY KEY,
    driver_id BIGINT NOT NULL,
    warehouse_id BIGINT NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    bucket_returned INT DEFAULT 0,
    actual_bucket_qty INT,
    difference INT,
    difference_reason TEXT,
    replenishment TEXT,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    checked_at TIMESTAMP,
    create_by VARCHAR(50),
    update_by VARCHAR(50),
    deleted INTEGER DEFAULT 0
);

-- 19. 对账单表 (monthly_statement)
CREATE TABLE IF NOT EXISTS monthly_statement (
    id BIGSERIAL PRIMARY KEY,
    station_id BIGINT NOT NULL,
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
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    create_by VARCHAR(50),
    update_by VARCHAR(50),
    deleted INTEGER DEFAULT 0,
    UNIQUE(station_id, year_month)
);

-- 20. 消息通知表 (notification)
CREATE TABLE IF NOT EXISTS notification (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    type VARCHAR(30) DEFAULT 'system',
    title VARCHAR(200) NOT NULL,
    content TEXT,
    is_read BOOLEAN DEFAULT false,
    read_time TIMESTAMP,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    related_id VARCHAR(100)
);

-- 21. 司机对账单表 (driver_statement)
CREATE TABLE IF NOT EXISTS driver_statement (
    id BIGSERIAL PRIMARY KEY,
    statement_no VARCHAR(50) NOT NULL UNIQUE,
    driver_id BIGINT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_orders INT DEFAULT 0,
    total_buckets INT DEFAULT 0,
    total_amount DECIMAL(12,2) DEFAULT 0.00,
    status VARCHAR(20) DEFAULT 'generated',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    confirmed_at TIMESTAMP,
    create_by VARCHAR(50),
    update_by VARCHAR(50),
    deleted INTEGER DEFAULT 0
);

-- 22. 仓库入库表 (warehouse_inbound)
CREATE TABLE IF NOT EXISTS warehouse_inbound (
    id BIGSERIAL PRIMARY KEY,
    inbound_no VARCHAR(50) NOT NULL UNIQUE,
    warehouse_id BIGINT,
    type VARCHAR(20) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    operator VARCHAR(50),
    checker VARCHAR(50),
    checked_at TIMESTAMP,
    remark TEXT,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    create_by VARCHAR(50),
    update_by VARCHAR(50),
    deleted INTEGER DEFAULT 0
);

-- 23. 仓库入库明细表 (warehouse_inbound_item)
CREATE TABLE IF NOT EXISTS warehouse_inbound_item (
    id BIGSERIAL PRIMARY KEY,
    inbound_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT DEFAULT 0,
    remark TEXT,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    create_by VARCHAR(50),
    update_by VARCHAR(50),
    deleted INTEGER DEFAULT 0
);

-- 24. 仓库出库表 (warehouse_outbound)
CREATE TABLE IF NOT EXISTS warehouse_outbound (
    id BIGSERIAL PRIMARY KEY,
    outbound_no VARCHAR(50) NOT NULL UNIQUE,
    warehouse_id BIGINT,
    type VARCHAR(20) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    order_id BIGINT,
    driver_id BIGINT,
    operator VARCHAR(50),
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    create_by VARCHAR(50),
    update_by VARCHAR(50),
    deleted INTEGER DEFAULT 0
);

-- 25. 仓库出库明细表 (warehouse_outbound_item)
CREATE TABLE IF NOT EXISTS warehouse_outbound_item (
    id BIGSERIAL PRIMARY KEY,
    outbound_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT DEFAULT 0,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    create_by VARCHAR(50),
    update_by VARCHAR(50),
    deleted INTEGER DEFAULT 0
);

-- ============================================================================
-- 第三部分: 创建外键约束 (检查是否存在后添加)
-- ============================================================================

DO $$
DECLARE
    constraint_exists BOOLEAN;
BEGIN
    -- 用户表外键
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_users_warehouse') THEN
        ALTER TABLE users ADD CONSTRAINT fk_users_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouse(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_users_station') THEN
        ALTER TABLE users ADD CONSTRAINT fk_users_station FOREIGN KEY (station_id) REFERENCES station(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_users_driver') THEN
        ALTER TABLE users ADD CONSTRAINT fk_users_driver FOREIGN KEY (driver_id) REFERENCES driver(id);
    END IF;

    -- 水站账户表外键
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_station_account_station') THEN
        ALTER TABLE station_account ADD CONSTRAINT fk_station_account_station FOREIGN KEY (station_id) REFERENCES station(id);
    END IF;

    -- 客户表外键
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_customer_station') THEN
        ALTER TABLE customer ADD CONSTRAINT fk_customer_station FOREIGN KEY (station_id) REFERENCES station(id);
    END IF;

    -- 水票表外键
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_water_ticket_station') THEN
        ALTER TABLE water_ticket ADD CONSTRAINT fk_water_ticket_station FOREIGN KEY (station_id) REFERENCES station(id);
    END IF;

    -- 水票流水表外键
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_water_ticket_transaction_ticket') THEN
        ALTER TABLE water_ticket_transaction ADD CONSTRAINT fk_water_ticket_transaction_ticket FOREIGN KEY (ticket_id) REFERENCES water_ticket(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_water_ticket_transaction_order') THEN
        ALTER TABLE water_ticket_transaction ADD CONSTRAINT fk_water_ticket_transaction_order FOREIGN KEY (order_id) REFERENCES orders(id);
    END IF;

    -- 仓库库存表外键
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_product_inventory_warehouse') THEN
        ALTER TABLE product_inventory ADD CONSTRAINT fk_product_inventory_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouse(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_product_inventory_product') THEN
        ALTER TABLE product_inventory ADD CONSTRAINT fk_product_inventory_product FOREIGN KEY (product_id) REFERENCES product(id);
    END IF;

    -- 水站商品价格表外键
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_station_product_price_station') THEN
        ALTER TABLE station_product_price ADD CONSTRAINT fk_station_product_price_station FOREIGN KEY (station_id) REFERENCES station(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_station_product_price_product') THEN
        ALTER TABLE station_product_price ADD CONSTRAINT fk_station_product_price_product FOREIGN KEY (product_id) REFERENCES product(id);
    END IF;

    -- 阶梯价表外键
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_product_tier_price_station') THEN
        ALTER TABLE product_tier_price ADD CONSTRAINT fk_product_tier_price_station FOREIGN KEY (station_id) REFERENCES station(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_product_tier_price_product') THEN
        ALTER TABLE product_tier_price ADD CONSTRAINT fk_product_tier_price_product FOREIGN KEY (product_id) REFERENCES product(id);
    END IF;

    -- 订单表外键
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_orders_station') THEN
        ALTER TABLE orders ADD CONSTRAINT fk_orders_station FOREIGN KEY (station_id) REFERENCES station(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_orders_warehouse') THEN
        ALTER TABLE orders ADD CONSTRAINT fk_orders_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouse(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_orders_driver') THEN
        ALTER TABLE orders ADD CONSTRAINT fk_orders_driver FOREIGN KEY (driver_id) REFERENCES driver(id);
    END IF;

    -- 订单商品明细表外键
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_order_item_order') THEN
        ALTER TABLE order_item ADD CONSTRAINT fk_order_item_order FOREIGN KEY (order_id) REFERENCES orders(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_order_item_product') THEN
        ALTER TABLE order_item ADD CONSTRAINT fk_order_item_product FOREIGN KEY (product_id) REFERENCES product(id);
    END IF;

    -- 售后表外键
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_after_sales_order') THEN
        ALTER TABLE after_sales ADD CONSTRAINT fk_after_sales_order FOREIGN KEY (order_id) REFERENCES orders(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_after_sales_station') THEN
        ALTER TABLE after_sales ADD CONSTRAINT fk_after_sales_station FOREIGN KEY (station_id) REFERENCES station(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_after_sales_product') THEN
        ALTER TABLE after_sales ADD CONSTRAINT fk_after_sales_product FOREIGN KEY (product_id) REFERENCES product(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_after_sales_new_order') THEN
        ALTER TABLE after_sales ADD CONSTRAINT fk_after_sales_new_order FOREIGN KEY (new_order_id) REFERENCES orders(id);
    END IF;

    -- 空桶流水表外键
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_bucket_transaction_station') THEN
        ALTER TABLE bucket_transaction ADD CONSTRAINT fk_bucket_transaction_station FOREIGN KEY (station_id) REFERENCES station(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_bucket_transaction_order') THEN
        ALTER TABLE bucket_transaction ADD CONSTRAINT fk_bucket_transaction_order FOREIGN KEY (order_id) REFERENCES orders(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_bucket_transaction_driver') THEN
        ALTER TABLE bucket_transaction ADD CONSTRAINT fk_bucket_transaction_driver FOREIGN KEY (driver_id) REFERENCES driver(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_bucket_transaction_warehouse') THEN
        ALTER TABLE bucket_transaction ADD CONSTRAINT fk_bucket_transaction_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouse(id);
    END IF;

    -- 司机回仓表外键
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_driver_return_driver') THEN
        ALTER TABLE driver_return ADD CONSTRAINT fk_driver_return_driver FOREIGN KEY (driver_id) REFERENCES driver(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_driver_return_warehouse') THEN
        ALTER TABLE driver_return ADD CONSTRAINT fk_driver_return_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouse(id);
    END IF;

    -- 对账单表外键
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_monthly_statement_station') THEN
        ALTER TABLE monthly_statement ADD CONSTRAINT fk_monthly_statement_station FOREIGN KEY (station_id) REFERENCES station(id);
    END IF;

    -- 消息通知表外键
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_notification_user') THEN
        ALTER TABLE notification ADD CONSTRAINT fk_notification_user FOREIGN KEY (user_id) REFERENCES users(id);
    END IF;

    -- 司机对账单表外键
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_driver_statement_driver') THEN
        ALTER TABLE driver_statement ADD CONSTRAINT fk_driver_statement_driver FOREIGN KEY (driver_id) REFERENCES driver(id);
    END IF;

    -- 仓库入库表外键
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_warehouse_inbound_warehouse') THEN
        ALTER TABLE warehouse_inbound ADD CONSTRAINT fk_warehouse_inbound_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouse(id);
    END IF;

    -- 仓库入库明细表外键
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_warehouse_inbound_item_inbound') THEN
        ALTER TABLE warehouse_inbound_item ADD CONSTRAINT fk_warehouse_inbound_item_inbound FOREIGN KEY (inbound_id) REFERENCES warehouse_inbound(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_warehouse_inbound_item_product') THEN
        ALTER TABLE warehouse_inbound_item ADD CONSTRAINT fk_warehouse_inbound_item_product FOREIGN KEY (product_id) REFERENCES product(id);
    END IF;

    -- 仓库出库表外键
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_warehouse_outbound_warehouse') THEN
        ALTER TABLE warehouse_outbound ADD CONSTRAINT fk_warehouse_outbound_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouse(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_warehouse_outbound_order') THEN
        ALTER TABLE warehouse_outbound ADD CONSTRAINT fk_warehouse_outbound_order FOREIGN KEY (order_id) REFERENCES orders(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_warehouse_outbound_driver') THEN
        ALTER TABLE warehouse_outbound ADD CONSTRAINT fk_warehouse_outbound_driver FOREIGN KEY (driver_id) REFERENCES driver(id);
    END IF;

    -- 仓库出库明细表外键
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_warehouse_outbound_item_outbound') THEN
        ALTER TABLE warehouse_outbound_item ADD CONSTRAINT fk_warehouse_outbound_item_outbound FOREIGN KEY (outbound_id) REFERENCES warehouse_outbound(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_warehouse_outbound_item_product') THEN
        ALTER TABLE warehouse_outbound_item ADD CONSTRAINT fk_warehouse_outbound_item_product FOREIGN KEY (product_id) REFERENCES product(id);
    END IF;
END $$;

-- ============================================================================
-- 第四部分: 创建索引 (检查是否存在后添加)
-- ============================================================================

DO $$
DECLARE
    index_exists BOOLEAN;
BEGIN
    -- 用户表索引
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_users_phone') THEN
        CREATE INDEX idx_users_phone ON users(phone);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_users_role') THEN
        CREATE INDEX idx_users_role ON users(role);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_users_deleted') THEN
        CREATE INDEX idx_users_deleted ON users(deleted);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_users_warehouse') THEN
        CREATE INDEX idx_users_warehouse ON users(warehouse_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_users_station') THEN
        CREATE INDEX idx_users_station ON users(station_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_users_driver') THEN
        CREATE INDEX idx_users_driver ON users(driver_id);
    END IF;

    -- 水站表索引
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_station_status') THEN
        CREATE INDEX idx_station_status ON station(status);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_station_phone') THEN
        CREATE INDEX idx_station_phone ON station(phone);
    END IF;

    -- 仓库表索引
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_warehouse_status') THEN
        CREATE INDEX idx_warehouse_status ON warehouse(status);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_warehouse_location') THEN
        CREATE INDEX idx_warehouse_location ON warehouse(lat, lng);
    END IF;

    -- 司机表索引
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_driver_region') THEN
        CREATE INDEX idx_driver_region ON driver(region);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_driver_status') THEN
        CREATE INDEX idx_driver_status ON driver(status);
    END IF;

    -- 商品表索引
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_product_category') THEN
        CREATE INDEX idx_product_category ON product(category);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_product_status') THEN
        CREATE INDEX idx_product_status ON product(status);
    END IF;

    -- 仓库库存表索引
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_product_inventory_warehouse_product') THEN
        CREATE INDEX idx_product_inventory_warehouse_product ON product_inventory(warehouse_id, product_id);
    END IF;

    -- 订单表索引
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_orders_station_created') THEN
        CREATE INDEX idx_orders_station_created ON orders(station_id, create_time);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_orders_warehouse_status') THEN
        CREATE INDEX idx_orders_warehouse_status ON orders(warehouse_id, status);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_orders_driver_status') THEN
        CREATE INDEX idx_orders_driver_status ON orders(driver_id, status);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_orders_status_created') THEN
        CREATE INDEX idx_orders_status_created ON orders(status, create_time);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_orders_order_no') THEN
        CREATE INDEX idx_orders_order_no ON orders(order_no);
    END IF;

    -- 订单商品明细表索引
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_order_item_order') THEN
        CREATE INDEX idx_order_item_order ON order_item(order_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_order_item_product') THEN
        CREATE INDEX idx_order_item_product ON order_item(product_id);
    END IF;

    -- 空桶流水表索引
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_bucket_trans_station_created') THEN
        CREATE INDEX idx_bucket_trans_station_created ON bucket_transaction(station_id, create_time);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_bucket_trans_order') THEN
        CREATE INDEX idx_bucket_trans_order ON bucket_transaction(order_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_bucket_trans_driver') THEN
        CREATE INDEX idx_bucket_trans_driver ON bucket_transaction(driver_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_bucket_trans_type') THEN
        CREATE INDEX idx_bucket_trans_type ON bucket_transaction(type);
    END IF;

    -- 司机回仓表索引
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_driver_return_driver_status') THEN
        CREATE INDEX idx_driver_return_driver_status ON driver_return(driver_id, status);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_driver_return_warehouse_status') THEN
        CREATE INDEX idx_driver_return_warehouse_status ON driver_return(warehouse_id, status);
    END IF;

    -- 对账单表索引
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_monthly_statement_station') THEN
        CREATE INDEX idx_monthly_statement_station ON monthly_statement(station_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_monthly_statement_year_month') THEN
        CREATE INDEX idx_monthly_statement_year_month ON monthly_statement(year_month);
    END IF;

    -- 售后表索引
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_after_sales_order') THEN
        CREATE INDEX idx_after_sales_order ON after_sales(order_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_after_sales_station_status') THEN
        CREATE INDEX idx_after_sales_station_status ON after_sales(station_id, status);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_after_sales_status_created') THEN
        CREATE INDEX idx_after_sales_status_created ON after_sales(status, create_time);
    END IF;

    -- 水站商品价格表索引
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_station_product_price_station') THEN
        CREATE INDEX idx_station_product_price_station ON station_product_price(station_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_station_product_price_product') THEN
        CREATE INDEX idx_station_product_price_product ON station_product_price(product_id);
    END IF;

    -- 阶梯价表索引
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_tier_price_station_product') THEN
        CREATE INDEX idx_tier_price_station_product ON product_tier_price(station_id, product_id);
    END IF;

    -- 消息通知表索引
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_notification_user') THEN
        CREATE INDEX idx_notification_user ON notification(user_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_notification_read') THEN
        CREATE INDEX idx_notification_read ON notification(is_read);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_notification_type') THEN
        CREATE INDEX idx_notification_type ON notification(type);
    END IF;

    -- 水票表索引
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_water_ticket_station') THEN
        CREATE INDEX idx_water_ticket_station ON water_ticket(station_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_water_ticket_status') THEN
        CREATE INDEX idx_water_ticket_status ON water_ticket(status);
    END IF;

    -- 水票流水表索引
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_water_ticket_transaction_ticket') THEN
        CREATE INDEX idx_water_ticket_transaction_ticket ON water_ticket_transaction(ticket_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_water_ticket_transaction_order') THEN
        CREATE INDEX idx_water_ticket_transaction_order ON water_ticket_transaction(order_id);
    END IF;

    -- 司机对账单表索引
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_driver_statement_driver') THEN
        CREATE INDEX idx_driver_statement_driver ON driver_statement(driver_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_driver_statement_status') THEN
        CREATE INDEX idx_driver_statement_status ON driver_statement(status);
    END IF;

    -- 仓库入库表索引
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_warehouse_inbound_warehouse') THEN
        CREATE INDEX idx_warehouse_inbound_warehouse ON warehouse_inbound(warehouse_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_warehouse_inbound_status') THEN
        CREATE INDEX idx_warehouse_inbound_status ON warehouse_inbound(status);
    END IF;

    -- 仓库入库明细表索引
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_warehouse_inbound_item_inbound') THEN
        CREATE INDEX idx_warehouse_inbound_item_inbound ON warehouse_inbound_item(inbound_id);
    END IF;

    -- 仓库出库表索引
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_warehouse_outbound_warehouse') THEN
        CREATE INDEX idx_warehouse_outbound_warehouse ON warehouse_outbound(warehouse_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_warehouse_outbound_status') THEN
        CREATE INDEX idx_warehouse_outbound_status ON warehouse_outbound(status);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_warehouse_outbound_order') THEN
        CREATE INDEX idx_warehouse_outbound_order ON warehouse_outbound(order_id);
    END IF;

    -- 仓库出库明细表索引
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_warehouse_outbound_item_outbound') THEN
        CREATE INDEX idx_warehouse_outbound_item_outbound ON warehouse_outbound_item(outbound_id);
    END IF;

    -- 客户表索引
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_customer_station') THEN
        CREATE INDEX idx_customer_station ON customer(station_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_customer_status') THEN
        CREATE INDEX idx_customer_status ON customer(status);
    END IF;
END $$;

-- ============================================================================
-- 第五部分: 创建触发器 (检查是否存在后添加)
-- ============================================================================

DO $$
BEGIN
    -- 检查触发器函数是否存在，如果不存在则创建
    IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'update_delivered_at') THEN
        CREATE FUNCTION update_delivered_at()
        RETURNS TRIGGER AS $BODY$
        BEGIN
            IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
                NEW.delivered_at := CURRENT_TIMESTAMP;
            END IF;
            RETURN NEW;
        END;
        $BODY$ LANGUAGE plpgsql;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'update_inventory_on_delivery') THEN
        CREATE FUNCTION update_inventory_on_delivery()
        RETURNS TRIGGER AS $BODY$
        BEGIN
            IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
                UPDATE product_inventory
                SET quantity = quantity - oi.actual_qty,
                    update_time = CURRENT_TIMESTAMP
                FROM order_item oi
                WHERE oi.order_id = NEW.id
                  AND product_inventory.warehouse_id = NEW.warehouse_id
                  AND product_inventory.product_id = oi.product_id;
            END IF;
            RETURN NEW;
        END;
        $BODY$ LANGUAGE plpgsql;
    END IF;

    -- 创建触发器（如果不存在）
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_update_delivered_at') THEN
        CREATE TRIGGER trg_update_delivered_at
            BEFORE UPDATE OF status ON orders
            FOR EACH ROW
            EXECUTE FUNCTION update_delivered_at();
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_update_inventory') THEN
        CREATE TRIGGER trg_update_inventory
            BEFORE UPDATE OF status ON orders
            FOR EACH ROW
            EXECUTE FUNCTION update_inventory_on_delivery();
    END IF;
END $$;

-- ============================================================================
-- 第六部分: 初始化数据 (使用 ON CONFLICT 确保幂等性)
-- ============================================================================

-- 1. 插入水站数据
INSERT INTO station (id, name, contact, phone, address, lat, lng, status) VALUES
    (1, '朝阳区第一水站', '张三', '13800000001', '北京市朝阳区建国路88号', 39.908, 116.404, 'active'),
    (2, '海淀区桶装水站', '李四', '13800000002', '北京市海淀区中关村大街100号', 39.989, 116.306, 'active'),
    (3, '东城区净水站', '王五', '13800000003', '北京市东城区王府井大街50号', 39.914, 116.407, 'active')
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    contact = EXCLUDED.contact,
    phone = EXCLUDED.phone,
    address = EXCLUDED.address,
    lat = EXCLUDED.lat,
    lng = EXCLUDED.lng,
    status = EXCLUDED.status;

-- 2. 插入水站账户数据
INSERT INTO station_account (id, station_id, deposit_balance, credit_limit, credit_used, bucket_deposit_per_unit, owed_bucket_num, owed_threshold, payment_type) VALUES
    (1, 1, 5000.00, 10000.00, 0.00, 30.00, 5, 10, 'prepaid'),
    (2, 2, 3000.00, 5000.00, 0.00, 30.00, 3, 8, 'monthly'),
    (3, 3, 10000.00, 20000.00, 0.00, 30.00, 0, 15, 'prepaid')
ON CONFLICT (station_id) DO UPDATE SET
    deposit_balance = EXCLUDED.deposit_balance,
    credit_limit = EXCLUDED.credit_limit,
    credit_used = EXCLUDED.credit_used,
    bucket_deposit_per_unit = EXCLUDED.bucket_deposit_per_unit,
    owed_bucket_num = EXCLUDED.owed_bucket_num,
    owed_threshold = EXCLUDED.owed_threshold,
    payment_type = EXCLUDED.payment_type;

-- 3. 插入仓库数据
INSERT INTO warehouse (id, name, address, contact_phone, lat, lng, status) VALUES
    (1, '北京中央仓库', '北京市顺义区首都机场路100号', '010-88888801', 40.0795, 116.652, 'active'),
    (2, '朝阳配送中心', '北京市朝阳区东四环中路80号', '010-88888802', 39.9285, 116.449, 'active'),
    (3, '海淀配送站', '北京市海淀区上地信息路50号', '010-88888803', 40.026, 116.312, 'active')
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    address = EXCLUDED.address,
    contact_phone = EXCLUDED.contact_phone,
    lat = EXCLUDED.lat,
    lng = EXCLUDED.lng,
    status = EXCLUDED.status;

-- 4. 插入司机数据
INSERT INTO driver (id, name, phone, region, status) VALUES
    (1, '赵师傅', '13900000001', '朝阳区', 'active'),
    (2, '钱师傅', '13900000002', '海淀区', 'active'),
    (3, '孙师傅', '13900000003', '东城区', 'active'),
    (4, '李师傅', '13900000004', '朝阳区/海淀区', 'active')
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    phone = EXCLUDED.phone,
    region = EXCLUDED.region,
    status = EXCLUDED.status;

-- 5. 插入商品数据
INSERT INTO product (id, name, category, specification, price, safe_stock, status) VALUES
    (1, '纯净水18.9L', 'bucket_water', '18.9L/桶', 15.00, 50, 'active'),
    (2, '矿泉水18.9L', 'bucket_water', '18.9L/桶', 18.00, 50, 'active'),
    (3, '纯净水11.3L', 'bucket_water', '11.3L/桶', 10.00, 50, 'active'),
    (4, '矿泉水550ml', 'bottled_water', '550ml*24瓶/箱', 36.00, 30, 'active'),
    (5, '饮水机 JD-01', 'equipment', '温热型', 299.00, 10, 'active'),
    (6, '桶装水抽水器', 'equipment', '手动按压式', 25.00, 20, 'active')
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    category = EXCLUDED.category,
    specification = EXCLUDED.specification,
    price = EXCLUDED.price,
    safe_stock = EXCLUDED.safe_stock,
    status = EXCLUDED.status;

-- 6. 插入仓库库存数据
INSERT INTO product_inventory (id, warehouse_id, product_id, quantity, safe_stock) VALUES
    (1, 1, 1, 500, 50),
    (2, 1, 2, 300, 50),
    (3, 1, 3, 200, 50),
    (4, 1, 4, 100, 30),
    (5, 2, 1, 400, 50),
    (6, 2, 2, 250, 50),
    (7, 3, 1, 350, 50),
    (8, 3, 3, 150, 50)
ON CONFLICT (warehouse_id, product_id) DO UPDATE SET
    quantity = EXCLUDED.quantity,
    safe_stock = EXCLUDED.safe_stock;

-- 7. 插入用户数据 (密码: 123456, BCrypt加密)
INSERT INTO users (id, phone, password, name, role, warehouse_id, station_id, driver_id, status) VALUES
    (1, '13800138000', '$2a$10$bAb.reCeaavLQXH2Yi.ZYe6y2jKZPyvFVhgRno723sh20zpDdd6Fy', '超级管理员', 'admin', NULL, NULL, NULL, 'active'),
    (2, '13700000001', '$2a$10$bAb.reCeaavLQXH2Yi.ZYe6y2jKZPyvFVhgRno723sh20zpDdd6Fy', '系统管理员', 'admin', NULL, NULL, NULL, 'active'),
    (3, '13700000002', '$2a$10$bAb.reCeaavLQXH2Yi.ZYe6y2jKZPyvFVhgRno723sh20zpDdd6Fy', '仓库管理员A', 'warehouse', 1, NULL, NULL, 'active'),
    (4, '13700000003', '$2a$10$bAb.reCeaavLQXH2Yi.ZYe6y2jKZPyvFVhgRno723sh20zpDdd6Fy', '仓库管理员B', 'warehouse', 2, NULL, NULL, 'active'),
    (5, '13700000004', '$2a$10$bAb.reCeaavLQXH2Yi.ZYe6y2jKZPyvFVhgRno723sh20zpDdd6Fy', '赵师傅', 'driver', NULL, NULL, 1, 'active'),
    (6, '13700000005', '$2a$10$bAb.reCeaavLQXH2Yi.ZYe6y2jKZPyvFVhgRno723sh20zpDdd6Fy', '钱师傅', 'driver', NULL, NULL, 2, 'active'),
    (7, '13700000006', '$2a$10$bAb.reCeaavLQXH2Yi.ZYe6y2jKZPyvFVhgRno723sh20zpDdd6Fy', '张三（水站老板）', 'station', NULL, 1, NULL, 'active'),
    (8, '13700000007', '$2a$10$bAb.reCeaavLQXH2Yi.ZYe6y2jKZPyvFVhgRno723sh20zpDdd6Fy', '李四（水站老板）', 'station', NULL, 2, NULL, 'active'),
    (9, '13700000008', '$2a$10$bAb.reCeaavLQXH2Yi.ZYe6y2jKZPyvFVhgRno723sh20zpDdd6Fy', '王五（水站老板）', 'station', NULL, 3, NULL, 'active'),
    (10, '13700000009', '$2a$10$bAb.reCeaavLQXH2Yi.ZYe6y2jKZPyvFVhgRno723sh20zpDdd6Fy', '店员-小张', 'staff', NULL, 1, NULL, 'active')
ON CONFLICT (phone) DO UPDATE SET
    password = EXCLUDED.password,
    name = EXCLUDED.name,
    role = EXCLUDED.role,
    warehouse_id = EXCLUDED.warehouse_id,
    station_id = EXCLUDED.station_id,
    driver_id = EXCLUDED.driver_id,
    status = EXCLUDED.status;

-- 8. 插入系统配置数据
INSERT INTO system_config (config_key, config_value, config_type, config_group, description, is_system) VALUES
    ('statement.day', '1', 'integer', 'statement', '每月对账日', false),
    ('statement.auto_generate', 'true', 'boolean', 'statement', '自动生成对账单', false),
    ('statement.generate_hour', '2', 'integer', 'statement', '对账单生成时间（小时）', false),
    ('order.timeout_hours', '2', 'integer', 'order', '订单超时时间（小时）', false),
    ('bucket.default_deposit', '30', 'decimal', 'bucket', '默认每桶押金金额', false),
    ('bucket.default_threshold', '10', 'integer', 'bucket', '默认欠桶阈值', false),
    ('sms.enabled', 'false', 'boolean', 'sms', '是否启用短信服务', false),
    ('sms.provider', 'aliyun', 'string', 'sms', '短信服务商', false),
    ('map.provider', 'amap', 'string', 'map', '地图服务商', false),
    ('map.mock_mode', 'true', 'boolean', 'map', '地图模拟模式', false),
    ('wechat.pay.enabled', 'false', 'boolean', 'payment', '是否启用微信支付', false)
ON CONFLICT (config_key) DO UPDATE SET
    config_value = EXCLUDED.config_value,
    config_type = EXCLUDED.config_type,
    config_group = EXCLUDED.config_group,
    description = EXCLUDED.description,
    is_system = EXCLUDED.is_system;

-- ============================================================================
-- 第七部分: 验证数据
-- ============================================================================

SELECT '========================================' AS separator;
SELECT '数据库初始化完成!' AS message;
SELECT '========================================' AS separator;

SELECT '数据验证结果:' AS info;
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
SELECT 'product_inventory', COUNT(*) FROM product_inventory
UNION ALL
SELECT 'system_config', COUNT(*) FROM system_config;

SELECT '========================================' AS separator;
SELECT '初始化数据包括:' AS info;
SELECT '1. 3个水站 (station)' AS data;
SELECT '2. 3个仓库 (warehouse)' AS data;
SELECT '3. 4个司机 (driver)' AS data;
SELECT '4. 6个商品 (product)' AS data;
SELECT '5. 8条仓库库存记录 (product_inventory)' AS data;
SELECT '6. 10个用户账户 (users)' AS data;
SELECT '7. 11条系统配置 (system_config)' AS data;
SELECT '========================================' AS separator;
