-- =========================================================
-- 1. TRANSACCIÓN EXPLÍCITA
-- Objetivo: insertar una fila de prueba en fct_stock
-- y confirmar la transacción
-- =========================================================
BEGIN TRANSACTION;

INSERT INTO fct_stock (store_id, product_id, quantity)
VALUES (1, 1, 999);

COMMIT;

-- =========================================================
-- 2. TRIGGER DE CALIDAD DE DATOS
-- Objetivo: impedir descuentos inválidos en fct_sales.
-- SQLite no soporta FUNCTION/PROCEDURE en SQL puro,
-- por lo que se usa un TRIGGER como alternativa equivalente.
-- =========================================================
DROP TRIGGER IF EXISTS trg_validate_discount;

CREATE TRIGGER trg_validate_discount
BEFORE INSERT ON fct_sales
FOR EACH ROW
WHEN NEW.discount < 0 OR NEW.discount > 1
BEGIN
    SELECT RAISE(FAIL, 'Invalid discount: must be between 0 and 1');
END;

-- =========================================================
-- 3. ANÁLISIS DE TENDENCIA MES A MES (LAG)
-- Objetivo: detectar meses con caída o subida notable
-- de ventas respecto al mes anterior.
-- Usa LAG() para acceder al valor del periodo previo.
-- =========================================================
WITH monthly_sales AS (
    SELECT
        substr(order_date, 1, 7)          AS year_month,
        ROUND(SUM(sales_amount), 2)       AS total_sales
    FROM vw_sales_enriched
    GROUP BY substr(order_date, 1, 7)
)
SELECT
    year_month,
    total_sales,
    LAG(total_sales) OVER (ORDER BY year_month) AS prev_month_sales,
    ROUND(
        100.0 * (total_sales - LAG(total_sales) OVER (ORDER BY year_month))
              / LAG(total_sales) OVER (ORDER BY year_month),
        1
    ) AS pct_change
FROM monthly_sales
ORDER BY year_month;

-- =========================================================
-- 4. PERCENTILES DE GASTO POR CLIENTE (NTILE)
-- Objetivo: clasificar clientes en cuartiles de gasto
-- para segmentación (Q4 = clientes premium).
-- =========================================================
WITH customer_totals AS (
    SELECT
        customer_id,
        customer_name,
        ROUND(SUM(sales_amount), 2) AS total_spent
    FROM vw_sales_enriched
    GROUP BY customer_id, customer_name
)
SELECT
    customer_name,
    total_spent,
    NTILE(4) OVER (ORDER BY total_spent) AS spending_quartile
FROM customer_totals
ORDER BY total_spent DESC
LIMIT 20;