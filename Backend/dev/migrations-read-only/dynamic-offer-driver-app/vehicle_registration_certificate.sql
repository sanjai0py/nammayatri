CREATE TABLE atlas_driver_offer_bpp.vehicle_registration_certificate ();

ALTER TABLE atlas_driver_offer_bpp.vehicle_registration_certificate ADD COLUMN certificate_number text NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.vehicle_registration_certificate ADD COLUMN document_image_id character varying(36) NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.vehicle_registration_certificate ADD COLUMN fitness_expiry timestamp with time zone NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.vehicle_registration_certificate ADD COLUMN fleet_owner_id text ;
ALTER TABLE atlas_driver_offer_bpp.vehicle_registration_certificate ADD COLUMN id character varying(36) NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.vehicle_registration_certificate ADD COLUMN insurance_validity timestamp with time zone ;
ALTER TABLE atlas_driver_offer_bpp.vehicle_registration_certificate ADD COLUMN manufacturer_model text ;
ALTER TABLE atlas_driver_offer_bpp.vehicle_registration_certificate ADD COLUMN permit_expiry timestamp with time zone ;
ALTER TABLE atlas_driver_offer_bpp.vehicle_registration_certificate ADD COLUMN puc_expiry timestamp with time zone ;
ALTER TABLE atlas_driver_offer_bpp.vehicle_registration_certificate ADD COLUMN review_required boolean ;
ALTER TABLE atlas_driver_offer_bpp.vehicle_registration_certificate ADD COLUMN reviewed_at timestamp with time zone ;
ALTER TABLE atlas_driver_offer_bpp.vehicle_registration_certificate ADD COLUMN vehicle_capacity integer ;
ALTER TABLE atlas_driver_offer_bpp.vehicle_registration_certificate ADD COLUMN vehicle_class text ;
ALTER TABLE atlas_driver_offer_bpp.vehicle_registration_certificate ADD COLUMN vehicle_color text ;
ALTER TABLE atlas_driver_offer_bpp.vehicle_registration_certificate ADD COLUMN vehicle_energy_type text ;
ALTER TABLE atlas_driver_offer_bpp.vehicle_registration_certificate ADD COLUMN vehicle_manufacturer text ;
ALTER TABLE atlas_driver_offer_bpp.vehicle_registration_certificate ADD COLUMN vehicle_model text ;
ALTER TABLE atlas_driver_offer_bpp.vehicle_registration_certificate ADD COLUMN vehicle_variant text ;
ALTER TABLE atlas_driver_offer_bpp.vehicle_registration_certificate ADD COLUMN verification_status text NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.vehicle_registration_certificate ADD COLUMN merchant_id character varying(36) ;
ALTER TABLE atlas_driver_offer_bpp.vehicle_registration_certificate ADD COLUMN merchant_operating_city_id character varying(36) ;
ALTER TABLE atlas_driver_offer_bpp.vehicle_registration_certificate ADD COLUMN created_at timestamp with time zone NOT NULL default CURRENT_TIMESTAMP;
ALTER TABLE atlas_driver_offer_bpp.vehicle_registration_certificate ADD COLUMN updated_at timestamp with time zone NOT NULL default CURRENT_TIMESTAMP;
ALTER TABLE atlas_driver_offer_bpp.vehicle_registration_certificate ADD PRIMARY KEY ( id);


------- SQL updates -------

ALTER TABLE atlas_driver_offer_bpp.vehicle_registration_certificate ADD COLUMN certificate_number_hash bytea NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.vehicle_registration_certificate ADD COLUMN certificate_number_encrypted character varying(255) NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.vehicle_registration_certificate DROP COLUMN certificate_number;


------- SQL updates -------

ALTER TABLE atlas_driver_offer_bpp.vehicle_registration_certificate ADD COLUMN failed_rules text[] NOT NULL;