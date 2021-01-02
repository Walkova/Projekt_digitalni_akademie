-- přidáme vteřiny do kalendáře
UPDATE "kalendar" set HOUR=HOUR||':00';

-- vytvoříme tabulku, aby byla velkým písmem a nemusely jsme psát ""
CREATE OR REPLACE TABLE tsk_measurments_upper AS
SELECT
    "detector_id" AS detector_id
  , "measured_from" AS measured_from
  , "measured_to" AS measured_to
  , "measurement_type" AS measurement_type
  , "class_id" AS class_id
  , "value" AS value
FROM "tsk_std_mesurments";

---rozdeleni svetovych stran, pruhu a typu vozidel a vyřadíme záznamy occupancy
CREATE OR REPLACE TABLE measurments AS
SELECT
    detector_id
  , right(split_part(detector_id, '-', 2), 1) AS jizdni_pruh
  , left(split_part(detector_id, '-', 2), 1)  AS svetova_strana
  , measured_from                  AS measured_from
  , measured_to                    AS measured_to
  , measurement_type
  , CASE class_id
        WHEN 1
            THEN 'soucet/prumer'
        WHEN 2
            THEN 'osobni'
        WHEN 3
            THEN 'nakladni'
        ELSE 'N/A' END                          AS typ_measurment
  ,  cast(value as int) as value_int
FROM tsk_measurments_upper
WHERE
    measurement_type != 'occupancy';