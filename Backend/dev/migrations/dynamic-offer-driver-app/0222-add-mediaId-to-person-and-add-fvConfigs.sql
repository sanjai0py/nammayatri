INSERT INTO atlas_driver_offer_bpp.merchant_service_config
VALUES ('favorit0-0000-0000-0000-00000favorit', 'Verification_InternalScripts', '{"url":"http://localhost:5000/"}');

ALTER TABLE atlas_driver_offer_bpp.merchant_service_usage_config
ADD COLUMN face_verification_service character varying(30);

UPDATE atlas_driver_offer_bpp.merchant_service_usage_config SET face_verification_service ='InternalScripts';