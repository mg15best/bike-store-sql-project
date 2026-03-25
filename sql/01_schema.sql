DROP TABLE IF EXISTS dim_brands;
DROP TABLE IF EXISTS dim_categories;
DROP TABLE IF EXISTS dim_customers;
DROP TABLE IF EXISTS dim_products;
DROP TABLE IF EXISTS dim_stores;
DROP TABLE IF EXISTS dim_staffs;
DROP TABLE IF EXISTS fct_sales;
DROP TABLE IF EXISTS fct_stock;

CREATE TABLE dim_brands (
    brand_id INTEGER,
    brand_name TEXT
);

CREATE TABLE dim_categories (
    category_id INTEGER,
    category_name TEXT
);

CREATE TABLE dim_customers (
    customer_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    phone TEXT,
    email TEXT,
    street TEXT,
    city TEXT,
    state TEXT,
    zip_code TEXT
);

CREATE TABLE dim_stores (
    store_id INTEGER,
    store_name TEXT,
    phone TEXT,
    email TEXT,
    street TEXT,
    city TEXT,
    state TEXT,
    zip_code TEXT
);

CREATE TABLE dim_staffs (
    staff_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    phone TEXT,
    active INTEGER,
    store_id INTEGER,
    manager_id INTEGER
);

CREATE TABLE dim_products (
    product_id INTEGER,
    product_name TEXT,
    brand_id INTEGER,
    category_id INTEGER,
    model_year INTEGER,
    list_price REAL
);

CREATE TABLE fct_sales (
    order_id INTEGER,
    item_id INTEGER,
    customer_id INTEGER,
    store_id INTEGER,
    staff_id INTEGER,
    product_id INTEGER,
    order_status INTEGER,
    order_date TEXT,
    required_date TEXT,
    shipped_date TEXT,
    quantity INTEGER,
    list_price REAL,
    discount REAL,
    sales_amount REAL
);

CREATE TABLE fct_stock (
    store_id INTEGER,
    product_id INTEGER,
    quantity INTEGER
);