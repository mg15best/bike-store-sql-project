-- =========================================================
-- 1. NULOS EN SHIPPED_DATE
-- Resultado esperado: 508 (pedidos pendientes de envío,
-- correctamente convertidos desde el literal 'NULL' del CSV)
-- =========================================================
SELECT 
    'null_shipped_date' AS check_name,
    COUNT(*) AS result
FROM fct_sales
WHERE shipped_date IS NULL;

-- =========================================================
-- 2. DESCUENTOS FUERA DE RANGO (0 - 1)
-- =========================================================
SELECT 
    'invalid_discount_rows' AS check_name,
    COUNT(*) AS result
FROM fct_sales
WHERE discount < 0 OR discount > 1;

-- =========================================================
-- 3. PRODUCTOS HUÉRFANOS EN fct_sales
-- =========================================================
SELECT 
    'orphan_product_ids' AS check_name,
    COUNT(*) AS result
FROM fct_sales fs
LEFT JOIN dim_products dp
    ON fs.product_id = dp.product_id
WHERE dp.product_id IS NULL;

-- =========================================================
-- 4. PEDIDOS RETRASADOS
-- Cuenta líneas de pedido (no pedidos distintos).
-- Para contar pedidos únicos:
--   SELECT COUNT(DISTINCT order_id) → 458 pedidos retrasados
-- =========================================================
SELECT 
    'delayed_orders' AS check_name,
    COUNT(*) AS result
FROM fct_sales
WHERE shipped_date IS NOT NULL
  AND shipped_date > required_date;

-- =========================================================
-- 5. PRODUCTOS SIN VENTAS
-- =========================================================
SELECT 
    'products_without_sales' AS check_name,
    COUNT(*) AS result
FROM dim_products dp
LEFT JOIN fct_sales fs
    ON dp.product_id = fs.product_id
WHERE fs.product_id IS NULL;
