SET client_encoding = 'UTF8';

DROP VIEW IF EXISTS vw_mock_data_prepared;

DROP TABLE IF EXISTS fact_sale CASCADE;
DROP TABLE IF EXISTS dim_product CASCADE;
DROP TABLE IF EXISTS dim_pet CASCADE;
DROP TABLE IF EXISTS dim_supplier CASCADE;
DROP TABLE IF EXISTS dim_store CASCADE;
DROP TABLE IF EXISTS dim_seller CASCADE;
DROP TABLE IF EXISTS dim_customer CASCADE;
DROP TABLE IF EXISTS dim_date CASCADE;
DROP TABLE IF EXISTS dim_product_category CASCADE;
DROP TABLE IF EXISTS dim_pet_category CASCADE;
DROP TABLE IF EXISTS dim_pet_type CASCADE;
DROP TABLE IF EXISTS dim_pet_breed CASCADE;
DROP TABLE IF EXISTS dim_brand CASCADE;
DROP TABLE IF EXISTS dim_material CASCADE;
DROP TABLE IF EXISTS dim_color CASCADE;
DROP TABLE IF EXISTS dim_size CASCADE;
DROP TABLE IF EXISTS dim_city CASCADE;
DROP TABLE IF EXISTS dim_country CASCADE;

CREATE TABLE dim_country (
    country_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_city (
    city_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    city_name TEXT NOT NULL,
    state_name TEXT,
    country_id BIGINT NOT NULL REFERENCES dim_country (country_id)
);

CREATE UNIQUE INDEX uq_dim_city_natural_key
    ON dim_city (LOWER(city_name), COALESCE(LOWER(state_name), ''), country_id);

CREATE TABLE dim_date (
    date_id INTEGER PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    day_number SMALLINT NOT NULL,
    month_number SMALLINT NOT NULL,
    month_name TEXT NOT NULL,
    quarter_number SMALLINT NOT NULL,
    year_number SMALLINT NOT NULL,
    iso_day_of_week SMALLINT NOT NULL,
    day_name TEXT NOT NULL
);

CREATE TABLE dim_product_category (
    product_category_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_pet_category (
    pet_category_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_pet_type (
    pet_type_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pet_type_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_pet_breed (
    pet_breed_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pet_breed_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_brand (
    brand_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    brand_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_material (
    material_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    material_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_color (
    color_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    color_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_size (
    size_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    size_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_customer (
    customer_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    age INTEGER NOT NULL CHECK (age >= 0),
    email TEXT NOT NULL UNIQUE,
    country_id BIGINT NOT NULL REFERENCES dim_country (country_id),
    postal_code TEXT
);

CREATE TABLE dim_seller (
    seller_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    country_id BIGINT NOT NULL REFERENCES dim_country (country_id),
    postal_code TEXT
);

CREATE TABLE dim_store (
    store_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    store_name TEXT NOT NULL,
    store_location TEXT NOT NULL,
    city_id BIGINT NOT NULL REFERENCES dim_city (city_id),
    phone TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_supplier (
    supplier_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    supplier_name TEXT NOT NULL,
    contact_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT NOT NULL,
    address TEXT NOT NULL,
    city_id BIGINT NOT NULL REFERENCES dim_city (city_id)
);

CREATE TABLE dim_pet (
    pet_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pet_name TEXT NOT NULL,
    pet_type_id BIGINT NOT NULL REFERENCES dim_pet_type (pet_type_id),
    pet_breed_id BIGINT NOT NULL REFERENCES dim_pet_breed (pet_breed_id),
    customer_id BIGINT NOT NULL REFERENCES dim_customer (customer_id),
    UNIQUE (pet_name, pet_type_id, pet_breed_id, customer_id)
);

CREATE TABLE dim_product (
    product_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_natural_key TEXT NOT NULL UNIQUE,
    product_name TEXT NOT NULL,
    product_category_id BIGINT NOT NULL REFERENCES dim_product_category (product_category_id),
    pet_category_id BIGINT NOT NULL REFERENCES dim_pet_category (pet_category_id),
    supplier_id BIGINT NOT NULL REFERENCES dim_supplier (supplier_id),
    brand_id BIGINT NOT NULL REFERENCES dim_brand (brand_id),
    material_id BIGINT NOT NULL REFERENCES dim_material (material_id),
    color_id BIGINT NOT NULL REFERENCES dim_color (color_id),
    size_id BIGINT NOT NULL REFERENCES dim_size (size_id),
    product_price NUMERIC(10, 2) NOT NULL CHECK (product_price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0),
    product_weight NUMERIC(10, 2) NOT NULL CHECK (product_weight >= 0),
    product_description TEXT NOT NULL,
    product_rating NUMERIC(3, 2) NOT NULL CHECK (product_rating >= 0 AND product_rating <= 5),
    product_reviews INTEGER NOT NULL CHECK (product_reviews >= 0),
    release_date_id INTEGER NOT NULL REFERENCES dim_date (date_id),
    expiry_date_id INTEGER NOT NULL REFERENCES dim_date (date_id)
);

CREATE TABLE fact_sale (
    sale_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_stage_id BIGINT NOT NULL UNIQUE REFERENCES mock_data (stage_id),
    source_sale_id INTEGER NOT NULL,
    sale_date_id INTEGER NOT NULL REFERENCES dim_date (date_id),
    customer_id BIGINT NOT NULL REFERENCES dim_customer (customer_id),
    seller_id BIGINT NOT NULL REFERENCES dim_seller (seller_id),
    store_id BIGINT NOT NULL REFERENCES dim_store (store_id),
    product_id BIGINT NOT NULL REFERENCES dim_product (product_id),
    pet_id BIGINT NOT NULL REFERENCES dim_pet (pet_id),
    sale_quantity INTEGER NOT NULL CHECK (sale_quantity >= 0),
    sale_total_price NUMERIC(12, 2) NOT NULL CHECK (sale_total_price >= 0)
);

CREATE INDEX idx_dim_city_country_id ON dim_city (country_id);
CREATE INDEX idx_dim_customer_country_id ON dim_customer (country_id);
CREATE INDEX idx_dim_seller_country_id ON dim_seller (country_id);
CREATE INDEX idx_dim_store_city_id ON dim_store (city_id);
CREATE INDEX idx_dim_supplier_city_id ON dim_supplier (city_id);
CREATE INDEX idx_dim_pet_customer_id ON dim_pet (customer_id);
CREATE INDEX idx_dim_product_supplier_id ON dim_product (supplier_id);
CREATE INDEX idx_fact_sale_date_id ON fact_sale (sale_date_id);
CREATE INDEX idx_fact_sale_customer_id ON fact_sale (customer_id);
CREATE INDEX idx_fact_sale_seller_id ON fact_sale (seller_id);
CREATE INDEX idx_fact_sale_store_id ON fact_sale (store_id);
CREATE INDEX idx_fact_sale_product_id ON fact_sale (product_id);
CREATE INDEX idx_fact_sale_pet_id ON fact_sale (pet_id);

CREATE VIEW vw_mock_data_prepared AS
SELECT
    md.*,
    TO_DATE(md.sale_date, 'MM/DD/YYYY') AS sale_dt,
    TO_DATE(md.product_release_date, 'MM/DD/YYYY') AS product_release_dt,
    TO_DATE(md.product_expiry_date, 'MM/DD/YYYY') AS product_expiry_dt,
    MD5(CONCAT_WS(
        '|',
        COALESCE(md.product_name, '<NULL>'),
        COALESCE(md.product_category, '<NULL>'),
        COALESCE(md.pet_category, '<NULL>'),
        COALESCE(md.supplier_email, '<NULL>'),
        COALESCE(md.product_price::TEXT, '<NULL>'),
        COALESCE(md.product_quantity::TEXT, '<NULL>'),
        COALESCE(md.product_weight::TEXT, '<NULL>'),
        COALESCE(md.product_color, '<NULL>'),
        COALESCE(md.product_size, '<NULL>'),
        COALESCE(md.product_brand, '<NULL>'),
        COALESCE(md.product_material, '<NULL>'),
        COALESCE(md.product_description, '<NULL>'),
        COALESCE(md.product_rating::TEXT, '<NULL>'),
        COALESCE(md.product_reviews::TEXT, '<NULL>'),
        COALESCE(md.product_release_date, '<NULL>'),
        COALESCE(md.product_expiry_date, '<NULL>')
    )) AS product_natural_key
FROM mock_data md;
