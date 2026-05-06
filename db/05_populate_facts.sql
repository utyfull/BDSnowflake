SET client_encoding = 'UTF8';

INSERT INTO fact_sale (
    source_stage_id,
    source_sale_id,
    sale_date_id,
    customer_id,
    seller_id,
    store_id,
    product_id,
    pet_id,
    sale_quantity,
    sale_total_price
)
SELECT
    v.stage_id,
    v.id,
    sale_date.date_id,
    customer.customer_id,
    seller.seller_id,
    store.store_id,
    product.product_id,
    pet.pet_id,
    v.sale_quantity,
    v.sale_total_price
FROM vw_mock_data_prepared v
JOIN dim_date sale_date
    ON sale_date.full_date = v.sale_dt
JOIN dim_customer customer
    ON customer.email = v.customer_email
JOIN dim_seller seller
    ON seller.email = v.seller_email
JOIN dim_store store
    ON store.email = v.store_email
JOIN dim_product product
    ON product.product_natural_key = v.product_natural_key
JOIN dim_pet_type pet_type
    ON pet_type.pet_type_name = v.customer_pet_type
JOIN dim_pet_breed pet_breed
    ON pet_breed.pet_breed_name = v.customer_pet_breed
JOIN dim_pet pet
    ON pet.customer_id = customer.customer_id
   AND pet.pet_name = v.customer_pet_name
   AND pet.pet_type_id = pet_type.pet_type_id
   AND pet.pet_breed_id = pet_breed.pet_breed_id
ORDER BY v.stage_id;
