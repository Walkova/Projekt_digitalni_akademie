create or replace table with_location as
select mf.validity
     , mf.den
     , mf.detector_id
     , mf.typ_measurement
     , mf.speed_value
     , mf.count_value
     , std."latitude"  as LATITUDE
     , std."longitude" as LONGITUDE
     , std."street"    as STREET
     , std."segment"   as SEGMENT
from mereni_fixed mf
         left join "std_whole_list" as std
                   on mf.detector_id = std."id";

create or replace table weather AS
		SELECT "dt" AS dt
  				, LEFT("dt_iso", 20)::timestamp_ntz AS date
  				, "temp" as temperature
  				, "temp_min" as temp_m
  				, "temp_max" as temp_max
 				  , "wind_speed" as wind
  				, "rain_1h" as rain_1h
 					, "rain_3h" as rain_3h

		from pocasi_praha;