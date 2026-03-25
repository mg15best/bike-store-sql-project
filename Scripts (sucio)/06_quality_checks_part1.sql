-- =========================================================
-- 1. Conteo de filas en tablas core
-- =========================================================
SELECT 'dim_brands' AS table_name, COUNT(*) AS total_rows FROM dim_brands
UNION ALL
SELECT 'dim_categories', COUNT(*) FROM dim_categories
UNION ALL
SELECT 'dim_customers', COUNT(*) FROM dim_customers
UNION ALL
SELECT 'dim_products', COUNT(*) FROM dim_products
UNION ALL
SELECT 'dim_stores', COUNT(*) FROM dim_stores
UNION ALL
SELECT 'dim_staffs', COUNT(*) FROM dim_staffs
UNION ALL
SELECT 'fct_stock', COUNT(*) FROM fct_stock
UNION ALL
SELECT 'fct_sales', COUNT(*) FROM fct_sales;

-- =========================================================
-- 2. Nulos en campos importantes de dimensiones
-- =========================================================
SELECT COUNT(*) AS null_customer_phone
FROM dim_customers
WHERE phone IS NULL;

SELECT COUNT(*) AS null_staff_manager_id
FROM dim_staffs
WHERE manager_id IS NULL;

-- =========================================================
-- 3. Nulos en campos importantes de ventas
-- =========================================================
SELECT COUNT(*) AS null_shipped_date
FROM fct_sales
WHERE shipped_date IS NULL;

SELECT COUNT(*) AS null_order_date
FROM fct_sales
WHERE order_date IS NULL;

SELECT COUNT(*) AS null_product_id
FROM fct_sales
WHERE product_id IS NULL;

-- =========================================================
-- 4. Duplicados en dimensiones (por clave)
-- =========================================================
SELECT brand_id, COUNT(*) AS total_duplicates
FROM dim_brands
GROUP BY brand_id
HAVING COUNT(*) > 1;

SELECT category_id, COUNT(*) AS total_duplicates
FROM dim_categories
GROUP BY category_id
HAVING COUNT(*) > 1;

SELECT customer_id, COUNT(*) AS total_duplicates
FROM dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT product_id, COUNT(*) AS total_duplicates
FROM dim_products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT store_id, COUNT(*) AS total_duplicates
FROM dim_stores
GROUP BY store_id
HAVING COUNT(*) > 1;

SELECT staff_id, COUNT(*) AS total_duplicates
FROM dim_staffs
GROUP BY staff_id
HAVING COUNT(*) > 1;

-- =========================================================
-- 5. Duplicados en fact_sales por combinación natural
-- =========================================================
SELECT
    order_id,
    item_id,
    product_id,
    COUNT(*) AS total_duplicates
FROM fct_sales
GROUP BY order_id, item_id, product_id
HAVING COUNT(*) > 1;

-- =========================================================
-- 6. Claves huérfanas en fct_sales
-- =========================================================
SELECT COUNT(*) AS orphan_customer_ids
FROM fct_sales fs
LEFT JOIN dim_customers dc
    ON fs.customer_id = dc.customer_id
WHERE dc.customer_id IS NULL;

SELECT COUNT(*) AS orphan_product_ids
FROM fct_sales fs
LEFT JOIN dim_products dp
    ON fs.product_id = dp.product_id
WHERE dp.product_id IS NULL;

SELECT COUNT(*) AS orphan_store_ids
FROM fct_sales fs
LEFT JOIN dim_stores ds
    ON fs.store_id = ds.store_id
WHERE ds.store_id IS NULL;

SELECT COUNT(*) AS orphan_staff_ids
FROM fct_sales fs
LEFT JOIN dim_staffs dst
    ON fs.staff_id = dst.staff_id
WHERE dst.staff_id IS NULL;

-- =========================================================
-- 7. Rango lógico de descuentos
-- =========================================================
SELECT COUNT(*) AS invalid_discount_rows
FROM fct_sales
WHERE discount < 0 OR discount > 1;

-- =========================================================
-- 8. Cantidades o precios no válidos
-- =========================================================
SELECT COUNT(*) AS invalid_quantity_rows
FROM fct_sales
WHERE quantity <= 0;

SELECT COUNT(*) AS invalid_price_rows
FROM fct_sales
WHERE list_price <= 0;

SELECT COUNT(*) AS invalid_sales_amount_rows
FROM fct_sales
WHERE sales_amount <= 0;

-- =========================================================
-- 9. Pedidos enviados después de la fecha requerida
-- =========================================================
SELECT COUNT(*) AS delayed_orders
FROM fct_sales
WHERE shipped_date IS NOT NULL
  AND shipped_date > required_date;

-- =========================================================
-- 10. Productos sin ventas
-- =========================================================
SELECT COUNT(*) AS products_without_sales
FROM dim_products dp
LEFT JOIN fct_sales fs
    ON dp.product_id = fs.product_id
WHERE fs.product_id IS NULL;

-- =========================================================
-- 11. Productos sin stock
-- =========================================================
SELECT COUNT(*) AS products_without_stock
FROM dim_products dp
LEFT JOIN fct_stock fs
    ON dp.product_id = fs.product_id
WHERE fs.product_id IS NULL;