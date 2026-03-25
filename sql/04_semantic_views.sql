DROP VIEW IF EXISTS vw_sales_enriched;
DROP VIEW IF EXISTS vw_store_monthly_kpis;

CREATE VIEW vw_sales_enriched AS
SELECT
    fs.order_id,
    fs.item_id,
    fs.order_date,
    fs.required_date,
    fs.shipped_date,
    fs.order_status,
    fs.quantity,
    fs.list_price,
    fs.discount,
    fs.sales_amount,
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.city AS customer_city,
    c.state AS customer_state,
    p.product_id,
    p.product_name,
    p.model_year,
    b.brand_name,
    cat.category_name,
    s.store_id,
    s.store_name,
    s.city AS store_city,
    s.state AS store_state,
    st.staff_id,
    st.first_name || ' ' || st.last_name AS staff_name
FROM fct_sales fs
LEFT JOIN dim_customers c
    ON fs.customer_id = c.customer_id
LEFT JOIN dim_products p
    ON fs.product_id = p.product_id
LEFT JOIN dim_brands b
    ON p.brand_id = b.brand_id
LEFT JOIN dim_categories cat
    ON p.category_id = cat.category_id
LEFT JOIN dim_stores s
    ON fs.store_id = s.store_id
LEFT JOIN dim_staffs st
    ON fs.staff_id = st.staff_id;

CREATE VIEW vw_store_monthly_kpis AS
SELECT
    store_id,
    store_name,
    substr(order_date, 1, 7) AS year_month,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS total_units,
    ROUND(SUM(sales_amount), 2) AS total_sales,
    ROUND(AVG(sales_amount), 2) AS avg_line_sales,
    ROUND(AVG(discount), 4) AS avg_discount
FROM vw_sales_enriched
GROUP BY
    store_id,
    store_name,
    substr(order_date, 1, 7);