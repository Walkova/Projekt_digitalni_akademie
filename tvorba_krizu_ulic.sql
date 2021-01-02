create or replace table complete_table_july_oct as
    (select wl.detector_id
          , to_char(wl.den, 'YYYY-MM-DD HH:MI:SS')                      as den
          , typ_measurement
          , 'count' as count_car
          , wl.count_value::int as count_value
          , 'speed' as speed_car
          , wl.speed_value::int as speed_value
          , wl.latitude
          , wl.longitude
          , wl.street
          , street ||  ' - ' || split_part(segment, '-', 1) ||', Praha' as kriz1
          , street ||  ' - ' || split_part(segment, '-', 2) ||', Praha' as kriz2
          , wl.segment
          , wea.temperature
          , wea.temp_m
          , wea.temp_max
          , wea.wind
          , wea.rain_1h
          , wea.rain_3h
     from with_location as wl
              left join
          weather as wea
          on wl.den = wea.date
    	where typ_measurement!='prumer');

create or replace table "krizovatky" as
select kriz1 as krizovatka
from complete_table_july_oct
union
select kriz2 as krizovatka
from complete_table_july_oct;

CREATE OR REPLACE TABLE USEKY AS
select distinct comp.detector_id,
                comp.street,
                comp.segment,
                REPLACE(sokr."query", ' , Praha') as kriz,
                sokr."longitude"                  as longitude,
                sokr."latitude"                   as latitude
from complete_table_july_oct as comp
         join "souradnice_krizovatek" as sokr
              on comp.kriz1 = sokr."query"
UNION
select distinct comp.detector_id,
                comp.street,
                comp.segment,
                REPLACE(sokr."query", ', Praha') as kriz2,
                sokr."longitude"                 as longitude,
                sokr."latitude"                  as latitude
from complete_table_july_oct as comp
         join "souradnice_krizovatek" as sokr
              on comp.kriz2 = sokr."query"
UNION
select distinct comp.detector_id,
                comp.street,
                comp.segment,
                street || ' - detektor' as kriz,
                comp.longitude          as longitude,
                comp.latitude           as latitude
from complete_table_july_oct as comp;

-- vytvoříme si tabulku všech původních dat, která máme pro statistiku měření měřičů
create or replace table june_oct_detector as
(select * from rijen_upper where measured_from >= '2020-10-01 00:00:00' and measured_to <= '2020-10-31 23:59:59')
union
(select * from tsk_measurments_upper where measured_to <= '2020-09-30 23:59:59');
