CREATE INDEX idx_aadhaar_verification_aadhaar_number_hash ON atlas_driver_offer_bpp.aadhaar_verification  USING btree (aadhaar_number_hash);