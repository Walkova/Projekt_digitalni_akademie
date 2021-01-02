
--- mereni fixed - určíme si validitu měření, s kterou pak pracujeme dál
create or replace table mereni_fixed as
select case
           when n_row in (11, 12) then 0
           when n_row in (8, 9, 10) then 1
           when n_row < 8 then 2
           else 2
           end                                                 as validity,
       cc.den,
       cc.detector_id,
       cc.typ_measurement,
       -- zahodime validity 2(dame null) - tu pak nahrazujeme typickým dnem
       iff(validity < 2, speed_value, NULL)                    as speed_value,
       case
           when validity = 0 then count_value
           when validity = 1 then count_value * 12 / n_row 
           end as count_value,
       mph.count_value as orig_pocet, 
       mph.speed_value as orig_rychlost
from calendar_category cc
         left join mereni_po_hodinach mph
                   on mph.hour_from = cc.den
                       and mph.typ_measurement = cc.typ_measurement
                       and mph.detector_id = cc.detector_id
;

-- tento řádek mph.count_value as orig_pocet, mph.speed_value as orig_rychlost si dočasně necháváme z původní tabulky
-- , abychom letmo porovnaly výsledky


--- typicky den pro doplneni za srpen, září, říjen, měsícema dle zadaného kritéria
-- v prvním unionu nahrazujeme srpnové hodnoty srpnem a zářím, v druhém unionu nahrazujeme září a říjen zářím a říjnem
create or replace table typical_day as
select dayname(den)                                                                     as weekday
     , hour(den)                                                                        as hour
     , 8                                                                                as month
     , detector_id
     , typ_measurement
     , avg(count_value)                                                                 as count_value
     , DIV0(SUM(speed_value * mereni_fixed.count_value), sum(mereni_fixed.count_value)) as speed_value
from mereni_fixed
where validity in (0, 1)
  and month(den) in (8, 9)
group by dayname(den), hour(den), month, detector_id, typ_measurement

union

select dayname(den)                                                                     as weekday
     , hour(den)                                                                        as hour
     , month(den)                                                                       as month
     , detector_id
     , typ_measurement
     , avg(count_value)                                                                 as count_value
     , DIV0(SUM(speed_value * mereni_fixed.count_value), sum(mereni_fixed.count_value)) as speed_value
from mereni_fixed
where validity in (0, 1)
  and month(den) in (9, 10)
group by dayname(den), hour(den),month(den), detector_id, typ_measurement
;

-- nahradíme ve validity 2 chybějící hodnoty podle typickeho dne
UPDATE mereni_fixed mf
set mf.speed_value =td.speed_value,
    mf.count_value=td.count_value
from typical_day td
where dayname(mf.den) = td.weekday
  and mf.detector_id = td.detector_id
  and HOUR(mf.den) = td.hour
  and month(mf.den) = td.month
  and mf.typ_measurement = td.typ_measurement
  and mf.validity = 2
;
