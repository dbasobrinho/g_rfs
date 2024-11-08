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

column Start_Date        format  a13
column Start_Time        format  a10
column Num_Logs          format  99999999
column Mbytes            format  99999999
column Dbname            format  a13

select
   Start_Date,
   Start_Time,
   Num_Logs,
   Round(Num_Logs * (Vl.Bytes / (1024 * 1024)), 2) AS Mbytes,
   Vdb.NAME AS Dbname
FROM 
   (SELECT To_Char(Vlh.First_Time, 'dd/mm/yyyy') AS Start_Date, To_Char(Vlh.First_Time, 'HH24:MI')  AS Start_Time,
   COUNT(Vlh.Thread#) Num_Logs
FROM 
   V$log_History Vlh
GROUP BY 
   To_Char(Vlh.First_Time, 'dd/mm/yyyy'),
   To_Char(Vlh.First_Time, 'HH24:MI')) Log_Hist,
   V$log Vl,
   V$database Vdb
WHERE 
   Vl.Group# = 1
   and Num_Logs > &maior_que_qtde
ORDER BY 
   Log_Hist.Start_Date,
   Log_Hist.Start_Time;