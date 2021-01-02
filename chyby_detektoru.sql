create or replace table chyby_detector as
select detector_id
     , jizdni_pruh
     , svetova_strana
     , to_char(measured_from::timestamp_ntz, 'YYYY-MM-DD HH:MI:SS') as measured_from
     , to_char(measured_to::timestamp_ntz, 'YYYY-MM-DD HH:MI:SS')   as measured_to
     , rozdil_od_predch_mereni_m
from gaps_in_measurements_detector
where measurement_type = 'count'
  and typ_measurment = 'soucet/prumer'
order by measured_from;

create or replace table mereni_do_hodin as
select date_trunc('hour', measured_from::datetime) as hour_from
     , detector_id
     , jizdni_pruh
     , svetova_strana
     , count(*)                                    as n_row
     , avg(ROZDIL_OD_PREDCH_MERENI_M)              as avg_rozdil
from chyby_detector
group by date_trunc('hour', measured_from::datetime), detector_id, jizdni_pruh, svetova_strana;
