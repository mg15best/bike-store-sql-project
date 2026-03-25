-- =============================================================
-- 02_load_staging.sql
-- Carga de los CSV originales en las tablas staging
-- Ejecutar desde la raíz del proyecto con el CLI de SQLite:
--   sqlite3 bike_store.db < sql/02_load_staging.sql
-- O bien importar cada CSV manualmente desde DBeaver usando
-- File > Import Data apuntando a la carpeta data/.
-- =============================================================

-- Activar modo CSV (todos los ficheros de data/ tienen cabecera en la primera fila)
-- La opción --skip 1 omite esa cabecera para no cargarla como datos
.mode csv
.headers on

-- Carga de cada fichero CSV en su tabla staging correspondiente
.import --skip 1 data/brands.csv       stg_brands
.import --skip 1 data/categories.csv   stg_categories
.import --skip 1 data/customers.csv    stg_customers
.import --skip 1 data/order_items.csv  stg_order_items
.import --skip 1 data/orders.csv       stg_orders
.import --skip 1 data/products.csv     stg_products
.import --skip 1 data/staffs.csv       stg_staffs
.import --skip 1 data/stocks.csv       stg_stocks
.import --skip 1 data/stores.csv       stg_stores

-- =========================
-- Verificación rápida: número de filas cargadas
-- =========================

SELECT 'stg_brands'       AS table_name, COUNT(*) AS total_rows FROM stg_brands
UNION ALL
SELECT 'stg_categories',  COUNT(*) FROM stg_categories
UNION ALL
SELECT 'stg_customers',   COUNT(*) FROM stg_customers
UNION ALL
SELECT 'stg_order_items', COUNT(*) FROM stg_order_items
UNION ALL
SELECT 'stg_orders',      COUNT(*) FROM stg_orders
UNION ALL
SELECT 'stg_products',    COUNT(*) FROM stg_products
UNION ALL
SELECT 'stg_staffs',      COUNT(*) FROM stg_staffs
UNION ALL
SELECT 'stg_stocks',      COUNT(*) FROM stg_stocks
UNION ALL
SELECT 'stg_stores',      COUNT(*) FROM stg_stores;