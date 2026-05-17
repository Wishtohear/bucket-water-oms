-- ============================================================================
-- 水厂订货管理系统 - 订单桶数字段修复
-- 数据库: wateroms
-- 说明: 为 orders 表添加 order_buckets 字段存储订单下单桶数
-- ============================================================================

-- 添加 order_buckets 字段（如果不存在）
ALTER TABLE orders ADD COLUMN IF NOT EXISTS order_buckets INTEGER DEFAULT 0;
COMMENT ON COLUMN orders.order_buckets IS '订单下单桶数';

-- 更新所有现有订单的 order_buckets（从 order_item 累加）
UPDATE orders o SET order_buckets = (
    SELECT COALESCE(SUM(quantity), 0)
    FROM order_item oi
    WHERE oi.order_id = o.id
)
WHERE order_buckets IS NULL OR order_buckets = 0;

-- 验证更新结果
SELECT 'orders 表 order_buckets 字段更新完成!' AS status;
SELECT id, order_no, total_amount, order_buckets, delivered_qty
FROM orders
WHERE total_amount > 0
ORDER BY create_time DESC
LIMIT 20;
