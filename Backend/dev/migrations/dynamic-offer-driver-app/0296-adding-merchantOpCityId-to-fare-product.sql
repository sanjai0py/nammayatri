UPDATE atlas_driver_offer_bpp.fare_product
SET merchant_operating_city_id = merchant_operating_city.id
FROM atlas_driver_offer_bpp.merchant_operating_city
WHERE atlas_driver_offer_bpp.fare_product.merchant_id = merchant_operating_city.merchant_id;

ALTER TABLE atlas_driver_offer_bpp.fare_product
ALTER COLUMN merchant_operating_city_id SET NOT NULL;