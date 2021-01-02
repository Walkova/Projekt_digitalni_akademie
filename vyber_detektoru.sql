CREATE OR REPLACE TABLE gaps_in_measurements AS
SELECT
    CONCAT_WS('|', detector_id
        , jizdni_pruh
        , svetova_strana
        , measurement_type
        , typ_measurment)                                                            AS um_klic
  , detector_id
  , jizdni_pruh
  , svetova_strana
  , measurement_type
  , typ_measurment
  , measured_from
  , measured_to
    --- window funkce, ktera mi vrati predchozi measured_to z groupy um_klic
  , LAG(measured_to) OVER (PARTITION BY um_klic ORDER BY measured_from::TIMESTAMP) AS previous_to
  , DATEDIFF(MINUTE, previous_to, measured_from)                                     AS rozdil_od_predch_mereni_m
  , value_int
FROM measurments
;

----vytvorime tabulku jen vybranych detektoru, kterým chybí max. cca 10 % měření
CREATE OR REPLACE TABLE selected_detector AS
select
	sum(rozdil_od_predch_mereni_m) as time_differences
    , min(TO_DATE(measured_from)) as min_date_from
    , MAX(TO_DATE(measured_to)) as max_date_to, detector_id
    , count (distinct(to_date(measured_from))) as measure_days
from gaps_in_measurements
	where measurement_type = 'count'
  	and measured_from>='2020-08-01 00:00:00'
    and measured_to<='2020-09-30 23:59:59'
    and typ_measurment = 'osobni'
    and detector_id!='R800048-V1'
group by detector_id
having count (distinct(to_date(measured_from)))> 55
order by sum(rozdil_od_predch_mereni_m) asc
LIMIT 150;

-- přidáme detektory, které sice splňují podmínku výše, ale nevešly se do limitu a jsou druhým pruhem či protisměrem z vybraných viz výše
insert into selected_detector
select sum(rozdil_od_predch_mereni_m) as time_differences
			, min(TO_DATE(measured_from)) as min_date_from
      , MAX(TO_DATE(measured_to)) as max_date_to
      , gm.detector_id,
			count (distinct(to_date(measured_from))) as measure_days
from gaps_in_measurements gm
left join selected_detector sd on gm.detector_id = sd.detector_id
where measurement_type = 'count'
			and measured_from>='2020-08-01 00:00:00'
      and measured_to<='2020-09-30 23:59:59'
      and typ_measurment = 'osobni'
and sd.detector_id is null
			and gm.detector_id in ('R510311-V1', 'R904181-J1', 'R510311-Z1', 'R510311-V2', 'R919696-V1', 'R001694-J2', 'R904181-S2', 'R921214-Z1',
                    'R908067-S2', 'R908067-S1', 'R503289-V1', 'R600693-V2')
group by gm.detector_id
having count (distinct(to_date(measured_from)))> 55
order by sum(rozdil_od_predch_mereni_m) asc
;
