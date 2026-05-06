SET client_encoding = 'UTF8';

INSERT INTO dim_country (country_name)
SELECT DISTINCT country_name
FROM (
    SELECT customer_country AS country_name FROM mock_data
    UNION
    SELECT seller_country FROM mock_data
    UNION
    SELECT store_country FROM mock_data
    UNION
    SELECT supplier_country FROM mock_data
) source_countries
WHERE country_name IS NOT NULL
ORDER BY country_name;

INSERT INTO dim_city (city_name, state_name, country_id)
SELECT DISTINCT ON (
    LOWER(source_cities.city_name),
    COALESCE(LOWER(source_cities.state_name), ''),
    country.country_id
)
    source_cities.city_name,
    source_cities.state_name,
    country.country_id
FROM (
    SELECT
        store_city AS city_name,
        store_state AS state_name,
        store_country AS country_name
    FROM mock_data
    WHERE store_city IS NOT NULL
      AND store_country IS NOT NULL

    UNION

    SELECT
        supplier_city,
        NULL::TEXT,
        supplier_country
    FROM mock_data
    WHERE supplier_city IS NOT NULL
      AND supplier_country IS NOT NULL
) source_cities
JOIN dim_country country
    ON country.country_name = source_cities.country_name
ORDER BY
    LOWER(source_cities.city_name),
    COALESCE(LOWER(source_cities.state_name), ''),
    country.country_id,
    source_cities.city_name,
    source_cities.state_name;

INSERT INTO dim_date (
    date_id,
    full_date,
    day_number,
    month_number,
    month_name,
    quarter_number,
    year_number,
    iso_day_of_week,
    day_name
)
SELECT
    TO_CHAR(source_dates.full_date, 'YYYYMMDD')::INTEGER AS date_id,
    source_dates.full_date,
    EXTRACT(DAY FROM source_dates.full_date)::SMALLINT AS day_number,
    EXTRACT(MONTH FROM source_dates.full_date)::SMALLINT AS month_number,
    TRIM(TO_CHAR(source_dates.full_date, 'Month')) AS month_name,
    EXTRACT(QUARTER FROM source_dates.full_date)::SMALLINT AS quarter_number,
    EXTRACT(YEAR FROM source_dates.full_date)::SMALLINT AS year_number,
    EXTRACT(ISODOW FROM source_dates.full_date)::SMALLINT AS iso_day_of_week,
    TRIM(TO_CHAR(source_dates.full_date, 'Day')) AS day_name
FROM (
    SELECT sale_dt AS full_date FROM vw_mock_data_prepared WHERE sale_dt IS NOT NULL
    UNION
    SELECT product_release_dt FROM vw_mock_data_prepared WHERE product_release_dt IS NOT NULL
    UNION
    SELECT product_expiry_dt FROM vw_mock_data_prepared WHERE product_expiry_dt IS NOT NULL
) source_dates
ORDER BY source_dates.full_date;

INSERT INTO dim_product_category (category_name)
SELECT DISTINCT product_category
FROM mock_data
WHERE product_category IS NOT NULL
ORDER BY product_category;

INSERT INTO dim_pet_category (category_name)
SELECT DISTINCT pet_category
FROM mock_data
WHERE pet_category IS NOT NULL
ORDER BY pet_category;

INSERT INTO dim_pet_type (pet_type_name)
SELECT DISTINCT customer_pet_type
FROM mock_data
WHERE customer_pet_type IS NOT NULL
ORDER BY customer_pet_type;

INSERT INTO dim_pet_breed (pet_breed_name)
SELECT DISTINCT customer_pet_breed
FROM mock_data
WHERE customer_pet_breed IS NOT NULL
ORDER BY customer_pet_breed;

INSERT INTO dim_brand (brand_name)
SELECT DISTINCT product_brand
FROM mock_data
WHERE product_brand IS NOT NULL
ORDER BY product_brand;

INSERT INTO dim_material (material_name)
SELECT DISTINCT product_material
FROM mock_data
WHERE product_material IS NOT NULL
ORDER BY product_material;

INSERT INTO dim_color (color_name)
SELECT DISTINCT product_color
FROM mock_data
WHERE product_color IS NOT NULL
ORDER BY product_color;

INSERT INTO dim_size (size_name)
SELECT DISTINCT product_size
FROM mock_data
WHERE product_size IS NOT NULL
ORDER BY product_size;

INSERT INTO dim_customer (
    first_name,
    last_name,
    age,
    email,
    country_id,
    postal_code
)
SELECT DISTINCT ON (md.customer_email)
    md.customer_first_name,
    md.customer_last_name,
    md.customer_age,
    md.customer_email,
    country.country_id,
    md.customer_postal_code
FROM mock_data md
JOIN dim_country country
    ON country.country_name = md.customer_country
WHERE md.customer_email IS NOT NULL
ORDER BY md.customer_email, md.stage_id;

INSERT INTO dim_seller (
    first_name,
    last_name,
    email,
    country_id,
    postal_code
)
SELECT DISTINCT ON (md.seller_email)
    md.seller_first_name,
    md.seller_last_name,
    md.seller_email,
    country.country_id,
    md.seller_postal_code
FROM mock_data md
JOIN dim_country country
    ON country.country_name = md.seller_country
WHERE md.seller_email IS NOT NULL
ORDER BY md.seller_email, md.stage_id;

INSERT INTO dim_store (
    store_name,
    store_location,
    city_id,
    phone,
    email
)
SELECT DISTINCT ON (md.store_email)
    md.store_name,
    md.store_location,
    city.city_id,
    md.store_phone,
    md.store_email
FROM mock_data md
JOIN dim_country country
    ON country.country_name = md.store_country
JOIN dim_city city
    ON city.country_id = country.country_id
   AND city.city_name = md.store_city
   AND city.state_name IS NOT DISTINCT FROM md.store_state
WHERE md.store_email IS NOT NULL
ORDER BY md.store_email, md.stage_id;

INSERT INTO dim_supplier (
    supplier_name,
    contact_name,
    email,
    phone,
    address,
    city_id
)
SELECT DISTINCT ON (md.supplier_email)
    md.supplier_name,
    md.supplier_contact,
    md.supplier_email,
    md.supplier_phone,
    md.supplier_address,
    city.city_id
FROM mock_data md
JOIN dim_country country
    ON country.country_name = md.supplier_country
JOIN dim_city city
    ON city.country_id = country.country_id
   AND city.city_name = md.supplier_city
   AND city.state_name IS NULL
WHERE md.supplier_email IS NOT NULL
ORDER BY md.supplier_email, md.stage_id;

INSERT INTO dim_pet (
    pet_name,
    pet_type_id,
    pet_breed_id,
    customer_id
)
SELECT DISTINCT
    md.customer_pet_name,
    pet_type.pet_type_id,
    pet_breed.pet_breed_id,
    customer.customer_id
FROM mock_data md
JOIN dim_customer customer
    ON customer.email = md.customer_email
JOIN dim_pet_type pet_type
    ON pet_type.pet_type_name = md.customer_pet_type
JOIN dim_pet_breed pet_breed
    ON pet_breed.pet_breed_name = md.customer_pet_breed
WHERE md.customer_pet_name IS NOT NULL;

INSERT INTO dim_product (
    product_natural_key,
    product_name,
    product_category_id,
    pet_category_id,
    supplier_id,
    brand_id,
    material_id,
    color_id,
    size_id,
    product_price,
    stock_quantity,
    product_weight,
    product_description,
    product_rating,
    product_reviews,
    release_date_id,
    expiry_date_id
)
SELECT DISTINCT ON (v.product_natural_key)
    v.product_natural_key,
    v.product_name,
    product_category.product_category_id,
    pet_category.pet_category_id,
    supplier.supplier_id,
    brand.brand_id,
    material.material_id,
    color.color_id,
    size.size_id,
    v.product_price,
    v.product_quantity,
    v.product_weight,
    v.product_description,
    v.product_rating,
    v.product_reviews,
    release_date.date_id,
    expiry_date.date_id
FROM vw_mock_data_prepared v
JOIN dim_product_category product_category
    ON product_category.category_name = v.product_category
JOIN dim_pet_category pet_category
    ON pet_category.category_name = v.pet_category
JOIN dim_supplier supplier
    ON supplier.email = v.supplier_email
JOIN dim_brand brand
    ON brand.brand_name = v.product_brand
JOIN dim_material material
    ON material.material_name = v.product_material
JOIN dim_color color
    ON color.color_name = v.product_color
JOIN dim_size size
    ON size.size_name = v.product_size
JOIN dim_date release_date
    ON release_date.full_date = v.product_release_dt
JOIN dim_date expiry_date
    ON expiry_date.full_date = v.product_expiry_dt
WHERE v.product_natural_key IS NOT NULL
ORDER BY v.product_natural_key, v.stage_id;
