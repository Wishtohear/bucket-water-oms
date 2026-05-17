-- ============================================================================
-- 水厂订货管理系统 - UUID到BIGSERIAL迁移脚本
-- 将所有UUID主键改为自增BIGSERIAL主键
-- ============================================================================

-- 注意：执行此脚本前请先备份数据库！

-- 确保从干净的事务状态开始
ROLLBACK;

-- 1. 删除所有旧表（CASCADE会自动删除所有关联的外键约束）
-- 注意：执行顺序很重要，从子表到父表
DROP TABLE IF EXISTS bucket_transaction CASCADE;
DROP TABLE IF EXISTS after_sales CASCADE;
DROP TABLE IF EXISTS order_item CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS product_inventory CASCADE;
DROP TABLE IF EXISTS station_product_price CASCADE;
DROP TABLE IF EXISTS product_tier_price CASCADE;
DROP TABLE IF EXISTS monthly_statement CASCADE;
DROP TABLE IF EXISTS driver_return CASCADE;
DROP TABLE IF EXISTS notification CASCADE;
DROP TABLE IF EXISTS water_ticket_transaction CASCADE;
DROP TABLE IF EXISTS water_ticket CASCADE;
DROP TABLE IF EXISTS warehouse_outbound_item CASCADE;
DROP TABLE IF EXISTS warehouse_outbound CASCADE;
DROP TABLE IF EXISTS warehouse_inbound_item CASCADE;
DROP TABLE IF EXISTS warehouse_inbound CASCADE;
DROP TABLE IF EXISTS driver_statement CASCADE;
DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS station_account CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS system_config CASCADE;
DROP TABLE IF EXISTS product CASCADE;
DROP TABLE IF EXISTS driver CASCADE;
DROP TABLE IF EXISTS warehouse CASCADE;
DROP TABLE IF EXISTS station CASCADE;

-- 2. 删除所有序列（如果存在）
DROP SEQUENCE IF EXISTS users_id_seq;
DROP SEQUENCE IF EXISTS station_id_seq;
DROP SEQUENCE IF EXISTS station_account_id_seq;
DROP SEQUENCE IF EXISTS warehouse_id_seq;
DROP SEQUENCE IF EXISTS driver_id_seq;
DROP SEQUENCE IF EXISTS driver_return_id_seq;
DROP SEQUENCE IF EXISTS driver_statement_id_seq;
DROP SEQUENCE IF EXISTS product_id_seq;
DROP SEQUENCE IF EXISTS product_inventory_id_seq;
DROP SEQUENCE IF EXISTS product_tier_price_id_seq;
DROP SEQUENCE IF EXISTS station_product_price_id_seq;
DROP SEQUENCE IF EXISTS orders_id_seq;
DROP SEQUENCE IF EXISTS order_item_id_seq;
DROP SEQUENCE IF EXISTS bucket_transaction_id_seq;
DROP SEQUENCE IF EXISTS monthly_statement_id_seq;
DROP SEQUENCE IF EXISTS after_sales_id_seq;
DROP SEQUENCE IF EXISTS notification_id_seq;
DROP SEQUENCE IF EXISTS system_config_id_seq;
DROP SEQUENCE IF EXISTS customer_id_seq;
DROP SEQUENCE IF EXISTS water_ticket_id_seq;
DROP SEQUENCE IF EXISTS water_ticket_transaction_id_seq;
DROP SEQUENCE IF EXISTS warehouse_inbound_id_seq;
DROP SEQUENCE IF EXISTS warehouse_inbound_item_id_seq;
DROP SEQUENCE IF EXISTS warehouse_outbound_id_seq;
DROP SEQUENCE IF EXISTS warehouse_outbound_item_id_seq;

-- 3. 创建新的序列
CREATE SEQUENCE users_id_seq START 1 INCREMENT 1;
CREATE SEQUENCE station_id_seq START 1 INCREMENT 1;
CREATE SEQUENCE station_account_id_seq START 1 INCREMENT 1;
CREATE SEQUENCE warehouse_id_seq START 1 INCREMENT 1;
CREATE SEQUENCE driver_id_seq START 1 INCREMENT 1;
CREATE SEQUENCE driver_return_id_seq START 1 INCREMENT 1;
CREATE SEQUENCE driver_statement_id_seq START 1 INCREMENT 1;
CREATE SEQUENCE product_id_seq START 1 INCREMENT 1;
CREATE SEQUENCE product_inventory_id_seq START 1 INCREMENT 1;
CREATE SEQUENCE product_tier_price_id_seq START 1 INCREMENT 1;
CREATE SEQUENCE station_product_price_id_seq START 1 INCREMENT 1;
CREATE SEQUENCE orders_id_seq START 1 INCREMENT 1;
CREATE SEQUENCE order_item_id_seq START 1 INCREMENT 1;
CREATE SEQUENCE bucket_transaction_id_seq START 1 INCREMENT 1;
CREATE SEQUENCE monthly_statement_id_seq START 1 INCREMENT 1;
CREATE SEQUENCE after_sales_id_seq START 1 INCREMENT 1;
CREATE SEQUENCE notification_id_seq START 1 INCREMENT 1;
CREATE SEQUENCE system_config_id_seq START 1 INCREMENT 1;
CREATE SEQUENCE customer_id_seq START 1 INCREMENT 1;
CREATE SEQUENCE water_ticket_id_seq START 1 INCREMENT 1;
CREATE SEQUENCE water_ticket_transaction_id_seq START 1 INCREMENT 1;
CREATE SEQUENCE warehouse_inbound_id_seq START 1 INCREMENT 1;
CREATE SEQUENCE warehouse_inbound_item_id_seq START 1 INCREMENT 1;
CREATE SEQUENCE warehouse_outbound_id_seq START 1 INCREMENT 1;
CREATE SEQUENCE warehouse_outbound_item_id_seq START 1 INCREMENT 1;

-- 4. 创建新表结构（使用BIGSERIAL）- 按依赖顺序创建

-- 创建基础表（无外键依赖）
CREATE TABLE station (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact VARCHAR(50),
    phone VARCHAR(20),
    address TEXT,
    lat DECIMAL(10,6),
    lng DECIMAL(10,6),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE warehouse (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address TEXT,
    contact_phone VARCHAR(20),
    lat DECIMAL(10,6),
    lng DECIMAL(10,6),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE driver (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    region VARCHAR(100),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE product (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    specification VARCHAR(100),
    price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    safe_stock INT DEFAULT 50,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users (
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

CREATE TABLE system_config (
    id BIGSERIAL PRIMARY KEY,
    config_key VARCHAR(100) NOT NULL UNIQUE,
    config_value TEXT,
    config_type VARCHAR(20) DEFAULT 'string',
    config_group VARCHAR(50),
    description VARCHAR(255),
    is_system BOOLEAN DEFAULT false,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted INTEGER DEFAULT 0
);

-- 创建依赖station的表
CREATE TABLE station_account (
    id BIGSERIAL PRIMARY KEY,
    station_id BIGINT NOT NULL UNIQUE,
    deposit_balance DECIMAL(12,2) DEFAULT 0.00,
    credit_limit DECIMAL(12,2) DEFAULT 0.00,
    credit_used DECIMAL(12,2) DEFAULT 0.00,
    bucket_deposit_per_unit DECIMAL(10,2) DEFAULT 30.00,
    owed_bucket_num INT DEFAULT 0,
    owed_threshold INT DEFAULT 10,
    payment_type VARCHAR(20) DEFAULT 'prepaid',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE customer (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    contact VARCHAR(50),
    status VARCHAR(20) DEFAULT 'active',
    station_id BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE water_ticket (
    id BIGSERIAL PRIMARY KEY,
    ticket_no VARCHAR(50) NOT NULL UNIQUE,
    station_id BIGINT,
    total_count INT DEFAULT 0,
    used_count INT DEFAULT 0,
    amount DECIMAL(12,2) DEFAULT 0.00,
    status VARCHAR(20) DEFAULT 'active',
    expire_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 创建依赖product的表
CREATE TABLE product_inventory (
    id BIGSERIAL PRIMARY KEY,
    warehouse_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT DEFAULT 0,
    safe_stock INT DEFAULT 50,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(warehouse_id, product_id)
);

CREATE TABLE station_product_price (
    id BIGSERIAL PRIMARY KEY,
    station_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    discount_rate DECIMAL(5,4) DEFAULT 1.0000,
    is_enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(station_id, product_id)
);

CREATE TABLE product_tier_price (
    id BIGSERIAL PRIMARY KEY,
    station_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    min_quantity INT NOT NULL,
    max_quantity INT,
    tier_price DECIMAL(10,2) NOT NULL,
    is_enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(station_id, product_id, min_quantity)
);

-- 创建依赖orders的表（orders必须在order_item之前创建）
CREATE TABLE orders (
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
    sign_photos JSONB,
    delivered_qty INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP,
    dispatched_at TIMESTAMP,
    delivered_at TIMESTAMP
);

CREATE TABLE order_item (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    actual_qty INT DEFAULT 0,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL
);

CREATE TABLE after_sales (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    station_id BIGINT NOT NULL,
    product_id BIGINT,
    type VARCHAR(30) NOT NULL,
    reason TEXT NOT NULL,
    photos JSONB,
    request_type VARCHAR(20) NOT NULL,
    requested_quantity INT DEFAULT 1,
    status VARCHAR(20) DEFAULT 'pending',
    new_order_id BIGINT,
    reject_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP
);

-- 创建依赖其他表的事务表
CREATE TABLE bucket_transaction (
    id BIGSERIAL PRIMARY KEY,
    station_id BIGINT NOT NULL,
    order_id BIGINT,
    driver_id BIGINT,
    warehouse_id BIGINT,
    type VARCHAR(30) NOT NULL,
    quantity INT NOT NULL,
    balance INT DEFAULT 0,
    remark TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE driver_return (
    id BIGSERIAL PRIMARY KEY,
    driver_id BIGINT NOT NULL,
    warehouse_id BIGINT NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    bucket_returned INT DEFAULT 0,
    actual_bucket_qty INT,
    difference INT,
    difference_reason TEXT,
    replenishment JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    checked_at TIMESTAMP
);

CREATE TABLE monthly_statement (
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
    UNIQUE(station_id, year_month)
);

CREATE TABLE notification (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    type VARCHAR(30) DEFAULT 'system',
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE water_ticket_transaction (
    id BIGSERIAL PRIMARY KEY,
    ticket_id BIGINT NOT NULL,
    order_id BIGINT,
    used_count INT DEFAULT 0,
    deduct_amount DECIMAL(12,2) DEFAULT 0.00,
    type VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE driver_statement (
    id BIGSERIAL PRIMARY KEY,
    statement_no VARCHAR(50) NOT NULL UNIQUE,
    driver_id BIGINT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_orders INT DEFAULT 0,
    total_buckets INT DEFAULT 0,
    total_amount DECIMAL(12,2) DEFAULT 0.00,
    status VARCHAR(20) DEFAULT 'generated',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    confirmed_at TIMESTAMP
);

CREATE TABLE warehouse_inbound (
    id BIGSERIAL PRIMARY KEY,
    inbound_no VARCHAR(50) NOT NULL UNIQUE,
    warehouse_id BIGINT,
    type VARCHAR(20) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    operator VARCHAR(50),
    checker VARCHAR(50),
    checked_at TIMESTAMP,
    remark TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE warehouse_inbound_item (
    id BIGSERIAL PRIMARY KEY,
    inbound_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT DEFAULT 0,
    remark TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE warehouse_outbound (
    id BIGSERIAL PRIMARY KEY,
    outbound_no VARCHAR(50) NOT NULL UNIQUE,
    warehouse_id BIGINT,
    type VARCHAR(20) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    order_id BIGINT,
    driver_id BIGINT,
    operator VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE warehouse_outbound_item (
    id BIGSERIAL PRIMARY KEY,
    outbound_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. 重建外键约束
ALTER TABLE users ADD CONSTRAINT users_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES warehouse(id);
ALTER TABLE users ADD CONSTRAINT users_station_id_fkey FOREIGN KEY (station_id) REFERENCES station(id);
ALTER TABLE users ADD CONSTRAINT users_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES driver(id);

ALTER TABLE station_account ADD CONSTRAINT station_account_station_id_fkey FOREIGN KEY (station_id) REFERENCES station(id);

ALTER TABLE orders ADD CONSTRAINT orders_station_id_fkey FOREIGN KEY (station_id) REFERENCES station(id);
ALTER TABLE orders ADD CONSTRAINT orders_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES warehouse(id);
ALTER TABLE orders ADD CONSTRAINT orders_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES driver(id);

ALTER TABLE order_item ADD CONSTRAINT order_item_order_id_fkey FOREIGN KEY (order_id) REFERENCES orders(id);
ALTER TABLE order_item ADD CONSTRAINT order_item_product_id_fkey FOREIGN KEY (product_id) REFERENCES product(id);

ALTER TABLE product_inventory ADD CONSTRAINT product_inventory_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES warehouse(id);
ALTER TABLE product_inventory ADD CONSTRAINT product_inventory_product_id_fkey FOREIGN KEY (product_id) REFERENCES product(id);

ALTER TABLE station_product_price ADD CONSTRAINT station_product_price_station_id_fkey FOREIGN KEY (station_id) REFERENCES station(id);
ALTER TABLE station_product_price ADD CONSTRAINT station_product_price_product_id_fkey FOREIGN KEY (product_id) REFERENCES product(id);

ALTER TABLE product_tier_price ADD CONSTRAINT product_tier_price_station_id_fkey FOREIGN KEY (station_id) REFERENCES station(id);
ALTER TABLE product_tier_price ADD CONSTRAINT product_tier_price_product_id_fkey FOREIGN KEY (product_id) REFERENCES product(id);

ALTER TABLE bucket_transaction ADD CONSTRAINT bucket_transaction_station_id_fkey FOREIGN KEY (station_id) REFERENCES station(id);
ALTER TABLE bucket_transaction ADD CONSTRAINT bucket_transaction_order_id_fkey FOREIGN KEY (order_id) REFERENCES orders(id);
ALTER TABLE bucket_transaction ADD CONSTRAINT bucket_transaction_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES driver(id);
ALTER TABLE bucket_transaction ADD CONSTRAINT bucket_transaction_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES warehouse(id);

ALTER TABLE driver_return ADD CONSTRAINT driver_return_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES driver(id);
ALTER TABLE driver_return ADD CONSTRAINT driver_return_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES warehouse(id);

ALTER TABLE monthly_statement ADD CONSTRAINT monthly_statement_station_id_fkey FOREIGN KEY (station_id) REFERENCES station(id);

ALTER TABLE after_sales ADD CONSTRAINT after_sales_order_id_fkey FOREIGN KEY (order_id) REFERENCES orders(id);
ALTER TABLE after_sales ADD CONSTRAINT after_sales_station_id_fkey FOREIGN KEY (station_id) REFERENCES station(id);
ALTER TABLE after_sales ADD CONSTRAINT after_sales_product_id_fkey FOREIGN KEY (product_id) REFERENCES product(id);
ALTER TABLE after_sales ADD CONSTRAINT after_sales_new_order_id_fkey FOREIGN KEY (new_order_id) REFERENCES orders(id);

ALTER TABLE notification ADD CONSTRAINT notification_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE customer ADD CONSTRAINT customer_station_id_fkey FOREIGN KEY (station_id) REFERENCES station(id);

ALTER TABLE water_ticket ADD CONSTRAINT water_ticket_station_id_fkey FOREIGN KEY (station_id) REFERENCES station(id);

ALTER TABLE water_ticket_transaction ADD CONSTRAINT water_ticket_transaction_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES water_ticket(id);
ALTER TABLE water_ticket_transaction ADD CONSTRAINT water_ticket_transaction_order_id_fkey FOREIGN KEY (order_id) REFERENCES orders(id);

ALTER TABLE driver_statement ADD CONSTRAINT driver_statement_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES driver(id);

ALTER TABLE warehouse_inbound ADD CONSTRAINT warehouse_inbound_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES warehouse(id);

ALTER TABLE warehouse_inbound_item ADD CONSTRAINT warehouse_inbound_item_inbound_id_fkey FOREIGN KEY (inbound_id) REFERENCES warehouse_inbound(id);
ALTER TABLE warehouse_inbound_item ADD CONSTRAINT warehouse_inbound_item_product_id_fkey FOREIGN KEY (product_id) REFERENCES product(id);

ALTER TABLE warehouse_outbound ADD CONSTRAINT warehouse_outbound_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES warehouse(id);
ALTER TABLE warehouse_outbound ADD CONSTRAINT warehouse_outbound_order_id_fkey FOREIGN KEY (order_id) REFERENCES orders(id);
ALTER TABLE warehouse_outbound ADD CONSTRAINT warehouse_outbound_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES driver(id);

ALTER TABLE warehouse_outbound_item ADD CONSTRAINT warehouse_outbound_item_outbound_id_fkey FOREIGN KEY (outbound_id) REFERENCES warehouse_outbound(id);
ALTER TABLE warehouse_outbound_item ADD CONSTRAINT warehouse_outbound_item_product_id_fkey FOREIGN KEY (product_id) REFERENCES product(id);

-- 6. 重建索引
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_deleted ON users(deleted);
CREATE INDEX idx_users_warehouse ON users(warehouse_id);
CREATE INDEX idx_users_station ON users(station_id);
CREATE INDEX idx_users_driver ON users(driver_id);
CREATE INDEX idx_station_status ON station(status);
CREATE INDEX idx_warehouse_status ON warehouse(status);
CREATE INDEX idx_warehouse_location ON warehouse(lat, lng);
CREATE INDEX idx_driver_region ON driver(region);
CREATE INDEX idx_driver_status ON driver(status);
CREATE INDEX idx_product_category ON product(category);
CREATE INDEX idx_product_status ON product(status);
CREATE INDEX idx_product_inventory_warehouse_product ON product_inventory(warehouse_id, product_id);
CREATE INDEX idx_orders_station_created ON orders(station_id, created_at);
CREATE INDEX idx_orders_warehouse_status ON orders(warehouse_id, status);
CREATE INDEX idx_orders_driver_status ON orders(driver_id, status);
CREATE INDEX idx_orders_status_created ON orders(status, created_at);
CREATE INDEX idx_orders_order_no ON orders(order_no);
CREATE INDEX idx_order_item_order ON order_item(order_id);
CREATE INDEX idx_bucket_trans_station_created ON bucket_transaction(station_id, created_at);
CREATE INDEX idx_bucket_trans_order ON bucket_transaction(order_id);
CREATE INDEX idx_bucket_trans_driver ON bucket_transaction(driver_id);
CREATE INDEX idx_driver_return_driver_status ON driver_return(driver_id, status);
CREATE INDEX idx_driver_return_warehouse_status ON driver_return(warehouse_id, status);
CREATE INDEX idx_monthly_statement_station ON monthly_statement(station_id);
CREATE INDEX idx_after_sales_order ON after_sales(order_id);
CREATE INDEX idx_after_sales_station_status ON after_sales(station_id, status);
CREATE INDEX idx_after_sales_status_created ON after_sales(status, created_at);
CREATE INDEX idx_station_product_price_station ON station_product_price(station_id);
CREATE INDEX idx_station_product_price_product ON station_product_price(product_id);
CREATE INDEX idx_tier_price_station_product ON product_tier_price(station_id, product_id);
CREATE INDEX idx_notification_user ON notification(user_id);
CREATE INDEX idx_notification_read ON notification(is_read);

SELECT 'UUID到BIGSERIAL迁移完成!' AS status;
