-- plocha tabulka - rychlost a počet si dáme vedle sebe zvlášť za osobní, nákladní a průměry (původní clas_id 1)
create or replace table mereni_union as
-- osobní;
select sp.detector_id,
       sp.measured_from,
       sp.class_id,
       'osobni' AS typ_measurement,
       sp.value as speed_value,
       cnt.value as count_value
from filtered_measurements sp
left join filtered_measurements cnt
on sp.detector_id=cnt.detector_id and sp.measured_from=cnt.measured_from
       and cnt.measurement_type='count'
where sp.class_id=2 and cnt.class_id=2
and sp.measurement_type='speed'

union
-- nakladni auta
select sp.detector_id,
       sp.measured_from,
       sp.class_id,
       'nakladni' AS typ_measurement,
       sp.value as speed_value,
       cnt.value as count_value
from filtered_measurements sp
left join filtered_measurements cnt
on sp.detector_id=cnt.detector_id and sp.measured_from=cnt.measured_from
       and cnt.measurement_type='count'
where sp.class_id=3 and cnt.class_id=3
and sp.measurement_type='speed'

union
-- prumery
select sp.detector_id,
       sp.measured_from,
       sp.class_id,
       'prumer' AS typ_measurement,
       sp.value as speed_value,
       cnt.value as count_value
from filtered_measurements sp
left join filtered_measurements cnt
on sp.detector_id=cnt.detector_id and sp.measured_from=cnt.measured_from
       and cnt.measurement_type='count'
where sp.class_id=1 and cnt.class_id=1
and sp.measurement_type='speed'
;

--- groupy po hodinach a vazeny prumer  - funkce 'div nula' zajišťuje, že nebuddeme dělit nulou, což nejde a tak nám to nevyhodí chybu
create or replace table mereni_po_hodinach as
select date_trunc('hour', measured_from)                 as hour_from
     , detector_id
     , typ_measurement
     , DIV0(sum(speed_value * count_value), sum(count_value)) as speed_value
     , sum(count_value)                                  as count_value
     , count(*) as n_row
from mereni_union
group by date_trunc('hour', measured_from), detector_id, typ_measurement;

--- uplny kalendar vsech kombinaci časů detektorů (kartézský součin)
create or replace table calendar_category as
select detector_id, typ_measurement, "kalendar".hour::TIMESTAMP_NTZ as den
from "kalendar"
         left join
         (select distinct detector_id, typ_measurement from mereni_po_hodinach) as c2
         on 1 = 1
;
