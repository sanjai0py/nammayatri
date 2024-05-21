CREATE TABLE atlas_driver_offer_bpp.go_home_config ();

ALTER TABLE atlas_driver_offer_bpp.go_home_config ADD COLUMN active_time integer NOT NULL default 1800;
ALTER TABLE atlas_driver_offer_bpp.go_home_config ADD COLUMN add_start_waypoint_at integer NOT NULL default 3000;
ALTER TABLE atlas_driver_offer_bpp.go_home_config ADD COLUMN cancellation_cnt integer NOT NULL default 2;
ALTER TABLE atlas_driver_offer_bpp.go_home_config ADD COLUMN created_at timestamp with time zone NOT NULL default CURRENT_TIMESTAMP;
ALTER TABLE atlas_driver_offer_bpp.go_home_config ADD COLUMN dest_radius_meters integer NOT NULL default 3000;
ALTER TABLE atlas_driver_offer_bpp.go_home_config ADD COLUMN distance_unit character varying(255) ;
ALTER TABLE atlas_driver_offer_bpp.go_home_config ADD COLUMN enable_go_home boolean NOT NULL default true;
ALTER TABLE atlas_driver_offer_bpp.go_home_config ADD COLUMN go_home_batch_delay integer NOT NULL default 4;
ALTER TABLE atlas_driver_offer_bpp.go_home_config ADD COLUMN go_home_from_location_radius integer NOT NULL default 7000;
ALTER TABLE atlas_driver_offer_bpp.go_home_config ADD COLUMN go_home_way_point_radius integer NOT NULL default 2000;
ALTER TABLE atlas_driver_offer_bpp.go_home_config ADD COLUMN ignore_waypoints_till integer NOT NULL default 3000;
ALTER TABLE atlas_driver_offer_bpp.go_home_config ADD COLUMN merchant_id character varying(36) NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.go_home_config ADD COLUMN merchant_operating_city_id character varying(36) NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.go_home_config ADD COLUMN new_loc_allowed_radius integer NOT NULL default 20;
ALTER TABLE atlas_driver_offer_bpp.go_home_config ADD COLUMN num_drivers_for_dir_check integer NOT NULL default 5;
ALTER TABLE atlas_driver_offer_bpp.go_home_config ADD COLUMN num_home_locations integer NOT NULL default 5;
ALTER TABLE atlas_driver_offer_bpp.go_home_config ADD COLUMN start_cnt integer NOT NULL default 2;
ALTER TABLE atlas_driver_offer_bpp.go_home_config ADD COLUMN update_home_location_after_sec integer NOT NULL default 2592000;
ALTER TABLE atlas_driver_offer_bpp.go_home_config ADD COLUMN updated_at timestamp with time zone NOT NULL default CURRENT_TIMESTAMP;
ALTER TABLE atlas_driver_offer_bpp.go_home_config ADD PRIMARY KEY ( merchant_operating_city_id);