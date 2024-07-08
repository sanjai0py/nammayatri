CREATE TABLE atlas_driver_offer_bpp.surge_pricing ();

ALTER TABLE atlas_driver_offer_bpp.surge_pricing ADD COLUMN day_of_week text NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.surge_pricing ADD COLUMN hour_of_day integer NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.surge_pricing ADD COLUMN id character varying(36) NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.surge_pricing ADD COLUMN merchant_id character varying(36) NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.surge_pricing ADD COLUMN merchant_operating_city_id character varying(36) NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.surge_pricing ADD COLUMN source_hex text NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.surge_pricing ADD COLUMN surge_multiplier double precision NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.surge_pricing ADD COLUMN created_at timestamp with time zone NOT NULL default CURRENT_TIMESTAMP;
ALTER TABLE atlas_driver_offer_bpp.surge_pricing ADD COLUMN updated_at timestamp with time zone NOT NULL default CURRENT_TIMESTAMP;
ALTER TABLE atlas_driver_offer_bpp.surge_pricing ADD PRIMARY KEY ( id);