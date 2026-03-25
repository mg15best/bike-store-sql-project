-- =========================
-- DIMENSIONES
-- Conversión de 'NULL' literal (texto) a NULL real donde sea necesario.
-- Los CSV de origen codifican los nulos como el texto 'NULL',
-- que SQLite no convierte automáticamente salvo cuando el tipo destino
-- es INTEGER (por afinidad de tipos). Para columnas TEXT usamos NULLIF.
-- =========================

INSERT INTO dim_brands
SELECT brand_id, brand_name FROM stg_brands;

INSERT INTO dim_categories
SELECT category_id, category_name FROM stg_categories;

INSERT INTO dim_customers
SELECT
    customer_id,
    first_name,
    last_name,
    NULLIF(phone, 'NULL'),   -- los CSV usan 'NULL' literal para teléfonos vacíos
    email,
    street,
    city,
    state,
    zip_code
FROM stg_customers;

INSERT INTO dim_stores
SELECT store_id, store_name, phone, email, street, city, state, zip_code
FROM stg_stores;

INSERT INTO dim_staffs
SELECT
    staff_id,
    first_name,
    last_name,
    email,
    phone,
    active,
    store_id,
    NULLIF(manager_id, 'NULL')  -- manager_id del empleado raíz viene como 'NULL' en el CSV
FROM stg_staffs;

INSERT INTO dim_products
SELECT product_id, product_name, brand_id, category_id, model_year, list_price
FROM stg_products;

-- =========================
-- FACT: STOCK
-- =========================

INSERT INTO fct_stock
SELECT store_id, product_id, quantity FROM stg_stocks;

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
    NULLIF(o.shipped_date, 'NULL'),  -- pedidos no enviados tienen 'NULL' literal en el CSV
    oi.quantity,
    oi.list_price,
    oi.discount,
    (oi.quantity * oi.list_price * (1 - oi.discount)) AS sales_amount
FROM stg_order_items oi
JOIN stg_orders o
    ON oi.order_id = o.order_id;