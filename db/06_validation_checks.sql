SET client_encoding = 'UTF8';

DO $$
DECLARE
    v_stage_rows BIGINT;
    v_fact_rows BIGINT;
    v_missing_fact_rows BIGINT;
BEGIN
    SELECT COUNT(*) INTO v_stage_rows FROM mock_data;
    SELECT COUNT(*) INTO v_fact_rows FROM fact_sale;

    IF v_stage_rows <> 10000 THEN
        RAISE EXCEPTION 'Expected 10000 rows in mock_data, got %', v_stage_rows;
    END IF;

    IF v_fact_rows <> v_stage_rows THEN
        RAISE EXCEPTION 'fact_sale row count (%) does not match mock_data row count (%)', v_fact_rows, v_stage_rows;
    END IF;

    SELECT COUNT(*)
    INTO v_missing_fact_rows
    FROM mock_data md
    LEFT JOIN fact_sale sale
        ON sale.source_stage_id = md.stage_id
    WHERE sale.sale_id IS NULL;

    IF v_missing_fact_rows <> 0 THEN
        RAISE EXCEPTION 'Found % source rows without matching fact_sale rows', v_missing_fact_rows;
    END IF;

    RAISE NOTICE 'Snowflake validation passed: % source rows, % fact rows', v_stage_rows, v_fact_rows;
END;
$$;

SELECT 'mock_data' AS object_name, COUNT(*) AS row_count FROM mock_data
UNION ALL SELECT 'dim_country', COUNT(*) FROM dim_country
UNION ALL SELECT 'dim_city', COUNT(*) FROM dim_city
UNION ALL SELECT 'dim_date', COUNT(*) FROM dim_date
UNION ALL SELECT 'dim_product_category', COUNT(*) FROM dim_product_category
UNION ALL SELECT 'dim_pet_category', COUNT(*) FROM dim_pet_category
UNION ALL SELECT 'dim_pet_type', COUNT(*) FROM dim_pet_type
UNION ALL SELECT 'dim_pet_breed', COUNT(*) FROM dim_pet_breed
UNION ALL SELECT 'dim_brand', COUNT(*) FROM dim_brand
UNION ALL SELECT 'dim_material', COUNT(*) FROM dim_material
UNION ALL SELECT 'dim_color', COUNT(*) FROM dim_color
UNION ALL SELECT 'dim_size', COUNT(*) FROM dim_size
UNION ALL SELECT 'dim_customer', COUNT(*) FROM dim_customer
UNION ALL SELECT 'dim_seller', COUNT(*) FROM dim_seller
UNION ALL SELECT 'dim_store', COUNT(*) FROM dim_store
UNION ALL SELECT 'dim_supplier', COUNT(*) FROM dim_supplier
UNION ALL SELECT 'dim_pet', COUNT(*) FROM dim_pet
UNION ALL SELECT 'dim_product', COUNT(*) FROM dim_product
UNION ALL SELECT 'fact_sale', COUNT(*) FROM fact_sale
ORDER BY object_name;

SELECT
    product_category.category_name AS product_category,
    customer_country.country_name AS customer_country,
    COUNT(*) AS sale_count,
    SUM(sale.sale_quantity) AS sold_items,
    SUM(sale.sale_total_price) AS total_sales
FROM fact_sale sale
JOIN dim_product product
    ON product.product_id = sale.product_id
JOIN dim_product_category product_category
    ON product_category.product_category_id = product.product_category_id
JOIN dim_customer customer
    ON customer.customer_id = sale.customer_id
JOIN dim_country customer_country
    ON customer_country.country_id = customer.country_id
GROUP BY product_category.category_name, customer_country.country_name
ORDER BY total_sales DESC
LIMIT 10;

SELECT
    sale_date.year_number,
    sale_date.month_number,
    sale_date.month_name,
    COUNT(*) AS sale_count,
    SUM(sale.sale_total_price) AS total_sales
FROM fact_sale sale
JOIN dim_date sale_date
    ON sale_date.date_id = sale.sale_date_id
GROUP BY sale_date.year_number, sale_date.month_number, sale_date.month_name
ORDER BY sale_date.year_number, sale_date.month_number;
