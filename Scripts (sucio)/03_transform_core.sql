-- =========================
-- DIMENSIONES
-- =========================

INSERT INTO dim_brands
SELECT * FROM stg_brands;

INSERT INTO dim_categories
SELECT * FROM stg_categories;

INSERT INTO dim_customers
SELECT * FROM stg_customers;

INSERT INTO dim_stores
SELECT * FROM stg_stores;

INSERT INTO dim_staffs
SELECT * FROM stg_staffs;

INSERT INTO dim_products
SELECT * FROM stg_products;

-- =========================
-- FACT: STOCK
-- =========================

INSERT INTO fct_stock
SELECT * FROM stg_stocks;

-- =========================
-- FACT: SALES (la clave del proyecto)
-- =========================

INSERT INTO fct_sales
SELECT
    oi.order_id,
    oi.item_id,
    o.customer_id,
    o.store_id,
    o.staff_id,
    oi.product_id,
    o.order_status,
    o.order_date,
    o.required_date,
    o.shipped_date,
    oi.quantity,
    oi.list_price,
    oi.discount,
    (oi.quantity * oi.list_price * (1 - oi.discount)) AS sales_amount
FROM stg_order_items oi
JOIN stg_orders o
    ON oi.order_id = o.order_id;