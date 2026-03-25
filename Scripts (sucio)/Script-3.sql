SELECT 'dim_brands', COUNT(*) FROM dim_brands
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