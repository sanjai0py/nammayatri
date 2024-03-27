CREATE TABLE atlas_driver_offer_bpp.image ();

ALTER TABLE atlas_driver_offer_bpp.image ADD COLUMN failure_reason text ;
ALTER TABLE atlas_driver_offer_bpp.image ADD COLUMN id character varying(36) NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.image ADD COLUMN image_type text NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.image ADD COLUMN is_valid boolean NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.image ADD COLUMN merchant_id character varying(36) NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.image ADD COLUMN person_id character varying(36) NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.image ADD COLUMN s3_path text NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.image ADD COLUMN created_at timestamp with time zone NOT NULL default CURRENT_TIMESTAMP;
ALTER TABLE atlas_driver_offer_bpp.image ADD COLUMN updated_at timestamp with time zone NOT NULL default CURRENT_TIMESTAMP;
ALTER TABLE atlas_driver_offer_bpp.image ADD PRIMARY KEY ( id);