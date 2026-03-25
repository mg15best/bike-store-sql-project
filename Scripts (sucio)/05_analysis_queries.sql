-- =========================================================
-- ESTUDIO 1: Ventas por mes
-- Qué hace:
-- Muestra cómo evolucionan las ventas mes a mes.
-- =========================================================
SELECT
    substr(order_date, 1, 7) AS year_month,
    ROUND(SUM(sales_amount), 2) AS total_sales
FROM vw_sales_enriched
GROUP BY substr(order_date, 1, 7)
ORDER BY year_month;

-- =========================================================
-- ESTUDIO 2: Ventas por tienda y mes
-- Qué hace:
-- Muestra cuánto vende cada tienda en cada mes.
-- Sirve para ver qué tienda vende más según el mes.
-- =========================================================
SELECT
    store_name,
    substr(order_date, 1, 7) AS year_month,
    ROUND(SUM(sales_amount), 2) AS total_sales
FROM vw_sales_enriched
GROUP BY store_name, substr(order_date, 1, 7)
ORDER BY year_month, total_sales DESC;

-- =========================================================
-- ESTUDIO 3: Top 10 productos por ingresos
-- Qué hace:
-- Muestra los 10 productos que más ingresos generan.
-- =========================================================
SELECT
    product_name,
    ROUND(SUM(sales_amount), 2) AS total_sales
FROM vw_sales_enriched
GROUP BY product_name
ORDER BY total_sales DESC
LIMIT 10;

-- =========================================================
-- ESTUDIO 4: Top 10 clientes por gasto
-- Qué hace:
-- Muestra los 10 clientes que más dinero han gastado.
-- =========================================================
SELECT
    customer_name,
    ROUND(SUM(sales_amount), 2) AS total_spent
FROM vw_sales_enriched
GROUP BY customer_name
ORDER BY total_spent DESC
LIMIT 10;

-- =========================================================
-- ESTUDIO 5: Ventas por categoría
-- Qué hace:
-- Muestra qué categorías generan más ventas.
-- =========================================================
SELECT
    category_name,
    ROUND(SUM(sales_amount), 2) AS total_sales
FROM vw_sales_enriched
GROUP BY category_name
ORDER BY total_sales DESC;

-- =========================================================
-- ESTUDIO 6: Ventas por marca
-- Qué hace:
-- Muestra qué marcas generan más ingresos.
-- =========================================================
SELECT
    brand_name,
    ROUND(SUM(sales_amount), 2) AS total_sales
FROM vw_sales_enriched
GROUP BY brand_name
ORDER BY total_sales DESC;

-- =========================================================
-- ESTUDIO 7: Ranking mensual por tienda
-- Qué hace:
-- Muestra el ranking de tiendas dentro de cada mes
-- usando DENSE_RANK(): 1ª, 2ª, 3ª, etc.
-- =========================================================
WITH monthly_store_sales AS (
    SELECT
        store_name,
        substr(order_date, 1, 7) AS year_month,
        ROUND(SUM(sales_amount), 2) AS total_sales
    FROM vw_sales_enriched
    GROUP BY store_name, substr(order_date, 1, 7)
)
SELECT
    year_month,
    store_name,
    total_sales,
    DENSE_RANK() OVER (
        PARTITION BY year_month
        ORDER BY total_sales DESC
    ) AS sales_rank
FROM monthly_store_sales
ORDER BY year_month, sales_rank;

-- =========================================================
-- ESTUDIO 8: Top 3 productos por tienda
-- Qué hace:
-- Muestra los 3 productos con más ventas dentro de cada tienda.
-- =========================================================
WITH product_store_sales AS (
    SELECT
        store_name,
        product_name,
        ROUND(SUM(sales_amount), 2) AS total_sales
    FROM vw_sales_enriched
    GROUP BY store_name, product_name
)
SELECT *
FROM (
    SELECT
        store_name,
        product_name,
        total_sales,
        ROW_NUMBER() OVER (
            PARTITION BY store_name
            ORDER BY total_sales DESC
        ) AS rn
    FROM product_store_sales
)
WHERE rn <= 3
ORDER BY store_name, rn;

-- =========================================================
-- ESTUDIO 9: Clientes con gasto por encima de la media
-- Qué hace:
-- Muestra los clientes cuyo gasto total supera
-- el gasto medio de todos los clientes.
-- =========================================================
WITH customer_sales AS (
    SELECT
        customer_name,
        SUM(sales_amount) AS total_spent
    FROM vw_sales_enriched
    GROUP BY customer_name
),
avg_sales AS (
    SELECT AVG(total_spent) AS avg_spent
    FROM customer_sales
)
SELECT
    cs.customer_name,
    ROUND(cs.total_spent, 2) AS total_spent
FROM customer_sales cs
CROSS JOIN avg_sales a
WHERE cs.total_spent > a.avg_spent
ORDER BY total_spent DESC;

-- =========================================================
-- ESTUDIO 10: Productos con mucho stock y poca venta
-- Qué hace:
-- Detecta productos que podrían estar sobrealmacenados:
-- mucho stock disponible y pocas unidades vendidas.
-- =========================================================
WITH sales_by_product AS (
    SELECT
        product_id,
        SUM(quantity) AS total_units_sold
    FROM vw_sales_enriched
    GROUP BY product_id
),
stock_by_product AS (
    SELECT
        product_id,
        SUM(quantity) AS total_units_in_stock
    FROM fct_stock
    GROUP BY product_id
)
SELECT
    p.product_name,
    COALESCE(s.total_units_sold, 0) AS total_units_sold,
    COALESCE(st.total_units_in_stock, 0) AS total_units_in_stock
FROM dim_products p
LEFT JOIN sales_by_product s
    ON p.product_id = s.product_id
LEFT JOIN stock_by_product st
    ON p.product_id = st.product_id
ORDER BY total_units_in_stock DESC, total_units_sold ASC
LIMIT 15;