CREATE TABLE atlas_app.search_request ();

ALTER TABLE atlas_app.search_request ADD COLUMN auto_assign_enabled boolean ;
ALTER TABLE atlas_app.search_request ADD COLUMN auto_assign_enabled_v2 boolean ;
ALTER TABLE atlas_app.search_request ADD COLUMN available_payment_methods character(36) [] NOT NULL;
ALTER TABLE atlas_app.search_request ADD COLUMN bundle_version text ;
ALTER TABLE atlas_app.search_request ADD COLUMN client_id character varying(36) ;
ALTER TABLE atlas_app.search_request ADD COLUMN client_version text ;
ALTER TABLE atlas_app.search_request ADD COLUMN created_at timestamp with time zone NOT NULL default CURRENT_TIMESTAMP;
ALTER TABLE atlas_app.search_request ADD COLUMN currency character varying(255) ;
ALTER TABLE atlas_app.search_request ADD COLUMN customer_extra_fee integer ;
ALTER TABLE atlas_app.search_request ADD COLUMN customer_extra_fee_amount double precision ;
ALTER TABLE atlas_app.search_request ADD COLUMN device text ;
ALTER TABLE atlas_app.search_request ADD COLUMN disability_tag character(255) ;
ALTER TABLE atlas_app.search_request ADD COLUMN distance numeric(30,2) ;
ALTER TABLE atlas_app.search_request ADD COLUMN estimated_ride_duration integer ;
ALTER TABLE atlas_app.search_request ADD COLUMN from_location_id character varying(36) ;
ALTER TABLE atlas_app.search_request ADD COLUMN id character varying(36) NOT NULL;
ALTER TABLE atlas_app.search_request ADD COLUMN language character varying(255) ;
ALTER TABLE atlas_app.search_request ADD COLUMN max_distance double precision ;
ALTER TABLE atlas_app.search_request ADD COLUMN merchant_id character varying(36) NOT NULL;
ALTER TABLE atlas_app.search_request ADD COLUMN merchant_operating_city_id character varying(36) NOT NULL;
ALTER TABLE atlas_app.search_request ADD COLUMN rider_id character varying(36) NOT NULL;
ALTER TABLE atlas_app.search_request ADD COLUMN rider_preferred_option text NOT NULL;
ALTER TABLE atlas_app.search_request ADD COLUMN selected_payment_method_id character varying(36) ;
ALTER TABLE atlas_app.search_request ADD COLUMN start_time timestamp with time zone NOT NULL;
ALTER TABLE atlas_app.search_request ADD COLUMN to_location_id character varying(36) ;
ALTER TABLE atlas_app.search_request ADD COLUMN valid_till timestamp with time zone NOT NULL;
ALTER TABLE atlas_app.search_request ADD PRIMARY KEY ( id);


------- SQL updates -------

ALTER TABLE atlas_app.search_request ALTER COLUMN rider_preferred_option DROP NOT NULL;
ALTER TABLE atlas_app.search_request ALTER COLUMN merchant_operating_city_id DROP NOT NULL;


------- SQL updates -------

ALTER TABLE atlas_app.search_request ADD COLUMN max_distance_value double precision ;
ALTER TABLE atlas_app.search_request ADD COLUMN distance_value double precision ;
ALTER TABLE atlas_app.search_request ADD COLUMN distance_unit character varying(255) ;


------- SQL updates -------

ALTER TABLE atlas_app.search_request ADD COLUMN client_sdk_version text ;
ALTER TABLE atlas_app.search_request ADD COLUMN client_os_version text ;
ALTER TABLE atlas_app.search_request ADD COLUMN client_os_type text ;
ALTER TABLE atlas_app.search_request ADD COLUMN client_config_version text ;
ALTER TABLE atlas_app.search_request ADD COLUMN client_bundle_version text ;
ALTER TABLE atlas_app.search_request ADD COLUMN backend_config_version text ;
ALTER TABLE atlas_app.search_request ADD COLUMN backend_app_version text ;
ALTER TABLE atlas_app.search_request DROP COLUMN client_version;
ALTER TABLE atlas_app.search_request DROP COLUMN bundle_version;


------- SQL updates -------

ALTER TABLE atlas_app.search_request ADD COLUMN return_time timestamp with time zone ;