SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    180
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

column DATA           format  a13
column DY             format  a6
column H00            format  999
column H01            format  999
column H02            format  999
column H03            format  999
column H04            format  999
column H05            format  999
column H06            format  999
column H07            format  999
column H08            format  999
column H09            format  999
column H10            format  999
column H11            format  999
column H12            format  999
column H13            format  999
column H14            format  999
column H15            format  999
column H16            format  999
column H17            format  999
column H18            format  999
column H19            format  999
column H20            format  999
column H21            format  999
column H22            format  999
column H23            format  999
column H24            format  999
column TOTAL          format  99999999


SELECT
    trunc(first_time) as DATA, to_char(first_time,'DY') DY
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'dd/mm/yy HH24:MI:SS'),10,2),'00',1,0)) H00
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'dd/mm/yy HH24:MI:SS'),10,2),'01',1,0)) H01
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'dd/mm/yy HH24:MI:SS'),10,2),'02',1,0)) H02
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'dd/mm/yy HH24:MI:SS'),10,2),'03',1,0)) H03
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'dd/mm/yy HH24:MI:SS'),10,2),'04',1,0)) H04
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'dd/mm/yy HH24:MI:SS'),10,2),'05',1,0)) H05
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'dd/mm/yy HH24:MI:SS'),10,2),'06',1,0)) H06
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'dd/mm/yy HH24:MI:SS'),10,2),'07',1,0)) H07
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'dd/mm/yy HH24:MI:SS'),10,2),'08',1,0)) H08
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'dd/mm/yy HH24:MI:SS'),10,2),'09',1,0)) H09
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'dd/mm/yy HH24:MI:SS'),10,2),'10',1,0)) H10
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'dd/mm/yy HH24:MI:SS'),10,2),'11',1,0)) H11
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'dd/mm/yy HH24:MI:SS'),10,2),'12',1,0)) H12
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'dd/mm/yy HH24:MI:SS'),10,2),'13',1,0)) H13
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'dd/mm/yy HH24:MI:SS'),10,2),'14',1,0)) H14
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'dd/mm/yy HH24:MI:SS'),10,2),'15',1,0)) H15
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'dd/mm/yy HH24:MI:SS'),10,2),'16',1,0)) H16
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'dd/mm/yy HH24:MI:SS'),10,2),'17',1,0)) H17
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'dd/mm/yy HH24:MI:SS'),10,2),'18',1,0)) H18
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'dd/mm/yy HH24:MI:SS'),10,2),'19',1,0)) H19
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'dd/mm/yy HH24:MI:SS'),10,2),'20',1,0)) H20
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'dd/mm/yy HH24:MI:SS'),10,2),'21',1,0)) H21
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'dd/mm/yy HH24:MI:SS'),10,2),'22',1,0)) H22
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'dd/mm/yy HH24:MI:SS'),10,2),'23',1,0)) H23
  , COUNT(*)                                                                      TOTAL
FROM
  v$log_history  a
--WHERE
--    (TO_DATE(SUBSTR(TO_CHAR(first_time, 'dd/mm/yy HH:MI:SS'), 1,8), 'dd/mm/yy')
--     >= --startDate
--     --TO_DATE('startDate', 'dd/mm/yyyy')
--     )
--     AND
--    (TO_DATE(substr(TO_CHAR(first_time, 'dd/mm/yy HH:MI:SS'), 1,8), 'dd/mm/yy')
--     <= --endDate
--     --TO_DATE('endDate', 'dd/mm/yyyy')
--     )
GROUP BY trunc(first_time) , to_char(first_time,'DY')
ORDER BY 1;