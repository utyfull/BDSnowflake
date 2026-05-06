SET client_encoding = 'UTF8';

CREATE OR REPLACE PROCEDURE load_mock_data(p_file_name TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_last_stage_id BIGINT;
BEGIN
    SELECT COALESCE(MAX(stage_id), 0)
    INTO v_last_stage_id
    FROM mock_data;

    EXECUTE format(
        $copy$
        COPY mock_data (
            id,
            customer_first_name,
            customer_last_name,
            customer_age,
            customer_email,
            customer_country,
            customer_postal_code,
            customer_pet_type,
            customer_pet_name,
            customer_pet_breed,
            seller_first_name,
            seller_last_name,
            seller_email,
            seller_country,
            seller_postal_code,
            product_name,
            product_category,
            product_price,
            product_quantity,
            sale_date,
            sale_customer_id,
            sale_seller_id,
            sale_product_id,
            sale_quantity,
            sale_total_price,
            store_name,
            store_location,
            store_city,
            store_state,
            store_country,
            store_phone,
            store_email,
            pet_category,
            product_weight,
            product_color,
            product_size,
            product_brand,
            product_material,
            product_description,
            product_rating,
            product_reviews,
            product_release_date,
            product_expiry_date,
            supplier_name,
            supplier_contact,
            supplier_email,
            supplier_phone,
            supplier_address,
            supplier_city,
            supplier_country
        )
        FROM %L
        WITH (
            FORMAT CSV,
            HEADER TRUE,
            DELIMITER ',',
            NULL ''
        )
        $copy$,
        '/mock_data/' || p_file_name
    );

    UPDATE mock_data
    SET source_file = p_file_name
    WHERE stage_id > v_last_stage_id
      AND source_file IS NULL;
END;
$$;

CALL load_mock_data('MOCK_DATA.csv');
CALL load_mock_data('MOCK_DATA (1).csv');
CALL load_mock_data('MOCK_DATA (2).csv');
CALL load_mock_data('MOCK_DATA (3).csv');
CALL load_mock_data('MOCK_DATA (4).csv');
CALL load_mock_data('MOCK_DATA (5).csv');
CALL load_mock_data('MOCK_DATA (6).csv');
CALL load_mock_data('MOCK_DATA (7).csv');
CALL load_mock_data('MOCK_DATA (8).csv');
CALL load_mock_data('MOCK_DATA (9).csv');

DO $$
DECLARE
    v_row_count BIGINT;
BEGIN
    SELECT COUNT(*) INTO v_row_count FROM mock_data;

    IF v_row_count <> 10000 THEN
        RAISE EXCEPTION 'Expected 10000 rows in mock_data, got %', v_row_count;
    END IF;
END;
$$;
