create or replace table rijen_upper as
with
cleaning1 as
 		(select to_timestamp("measured_from"/1000) as m_from,
            to_timestamp("measured_to"/1000) as m_to,
     				* from rijen),
conv as
    (select convert_timezone('Europe/Prague', m_from) as measured_from,
        		convert_timezone('Europe/Prague', m_to) as measured_to,
      			* from cleaning1 ),
cleaning2 as
		(select "detector_id" as detector_id,
        measured_from,
        measured_to,
     		"measurement_type" as measurement_type,
     		"class_id" as class_id, "value" as VALUE  from conv )
select * from cleaning2 ;

--spojeni puvodnich dat a rijnovych dat, abysme tam neměly duplikace

create or replace table july_oct as
	(select detector_id, measured_from, measured_to, measurement_type, class_id, value
     from rijen_upper
   		where measured_from>='2020-10-01 00:00:00'
   		and measured_to<='2020-10-31 23:59:59')
union
	(select detector_id, measured_from, measured_to, measurement_type, class_id, value
     from tsk_measurments_upper
   		where measured_from>='2020-08-01 00:00:00'
   		and measured_to<='2020-09-30 23:59:59');
		
--- Vybereme jen merice, ktere potrebujeme
create or replace table filtered_measurements AS
select detector_id
               , measured_from::TIMESTAMP_NTZ as measured_from
               , measurement_type
               , class_id
               , value
          from july_oct
          where measured_from::TIMESTAMP_NTZ >= '2020-08-01 00:00:00'
            and measured_to::TIMESTAMP_NTZ <= '2020-10-31 23:59:59'
            and ((measurement_type = 'count' and VALUE <= 160)
              or (measurement_type = 'speed' and VALUE <= 130))
            and measurement_type != 'occupancy'
            and detector_id in (select distinct detector_id from selected_detector)
;
