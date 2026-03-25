-- =========================
-- CHECK: número de filas
-- =========================

SELECT 'stg_brands' AS table_name, COUNT(*) AS total_rows FROM stg_brands;
SELECT 'stg_categories', COUNT(*) FROM stg_categories;
SELECT 'stg_customers', COUNT(*) FROM stg_customers;
SELECT 'stg_order_items', COUNT(*) FROM stg_order_items;
SELECT 'stg_orders', COUNT(*) FROM stg_orders;
SELECT 'stg_products', COUNT(*) FROM stg_products;
SELECT 'stg_staffs', COUNT(*) FROM stg_staffs;
SELECT 'stg_stocks', COUNT(*) FROM stg_stocks;
SELECT 'stg_stores', COUNT(*) FROM stg_stores;

-- =========================
-- SAMPLE DATA (ver ejemplos)
-- =========================

SELECT * FROM stg_orders LIMIT 5;
SELECT * FROM stg_order_items LIMIT 5;
SELECT * FROM stg_customers LIMIT 5;

-- =========================
-- CHECK: valores nulos importantes
-- =========================

SELECT COUNT(*) AS null_phone_customers
FROM stg_customers
WHERE phone IS NULL;

SELECT COUNT(*) AS null_shipped_orders
FROM stg_orders
WHERE shipped_date IS NULL;

-- =========================
-- CHECK: duplicados (por si acaso)
-- =========================

SELECT order_id, COUNT(*)
FROM stg_orders
GROUP BY order_id
HAVING COUNT(*) > 1;