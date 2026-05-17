-- 添加 API 缺失字段修复脚本
-- 修复前后端字段不匹配问题

-- 1. 为 product 表添加缺失的字段
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'product' AND column_name = 'code') THEN
        ALTER TABLE product ADD COLUMN code VARCHAR(50);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'product' AND column_name = 'spec') THEN
        ALTER TABLE product ADD COLUMN spec VARCHAR(100);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'product' AND column_name = 'factory_price') THEN
        ALTER TABLE product ADD COLUMN factory_price DECIMAL(10,2);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'product' AND column_name = 'guide_price_min') THEN
        ALTER TABLE product ADD COLUMN guide_price_min DECIMAL(10,2);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'product' AND column_name = 'guide_price_max') THEN
        ALTER TABLE product ADD COLUMN guide_price_max DECIMAL(10,2);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'product' AND column_name = 'unit') THEN
        ALTER TABLE product ADD COLUMN unit VARCHAR(20);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'product' AND column_name = 'min_stock') THEN
        ALTER TABLE product ADD COLUMN min_stock INTEGER;
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'product' AND column_name = 'stock') THEN
        ALTER TABLE product ADD COLUMN stock INTEGER DEFAULT 0;
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'product' AND column_name = 'image') THEN
        ALTER TABLE product ADD COLUMN image VARCHAR(500);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'product' AND column_name = 'description') THEN
        ALTER TABLE product ADD COLUMN description TEXT;
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'product' AND column_name = 'remark') THEN
        ALTER TABLE product ADD COLUMN remark TEXT;
    END IF;
END $$;

-- 2. 为 driver 表添加缺失的字段
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'driver' AND column_name = 'code') THEN
        ALTER TABLE driver ADD COLUMN code VARCHAR(50);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'driver' AND column_name = 'area') THEN
        ALTER TABLE driver ADD COLUMN area VARCHAR(200);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'driver' AND column_name = 'avatar') THEN
        ALTER TABLE driver ADD COLUMN avatar VARCHAR(500);
    END IF;
END $$;

-- 3. 为 warehouse 表添加缺失的字段
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'warehouse' AND column_name = 'phone') THEN
        ALTER TABLE warehouse ADD COLUMN phone VARCHAR(20);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'warehouse' AND column_name = 'remark') THEN
        ALTER TABLE warehouse ADD COLUMN remark TEXT;
    END IF;
END $$;

-- 4. 添加索引以提高查询性能
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE tablename = 'product' AND indexname = 'idx_product_code') THEN
        CREATE INDEX idx_product_code ON product(code);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE tablename = 'product' AND indexname = 'idx_product_category') THEN
        CREATE INDEX idx_product_category ON product(category);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE tablename = 'driver' AND indexname = 'idx_driver_code') THEN
        CREATE INDEX idx_driver_code ON driver(code);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE tablename = 'warehouse' AND indexname = 'idx_warehouse_type') THEN
        CREATE INDEX idx_warehouse_type ON warehouse(type);
    END IF;
END $$;

-- 显示修复结果
SELECT 'Product 表字段修复完成' AS status;
SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'product' ORDER BY ordinal_position;

SELECT 'Driver 表字段修复完成' AS status;
SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'driver' ORDER BY ordinal_position;

SELECT 'Warehouse 表字段修复完成' AS status;
SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'warehouse' ORDER BY ordinal_position;
