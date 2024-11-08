--Script: REDO_GERACAO_REDO_HORA
--Data:   20/01/2016
--Autor: Marcio Guimaraes
--Finalidade: Lista o numero de Redos gerados por dia e hora
--Versão: 1.0 

select
   Start_Date,
   Start_Time,
   Num_Logs,
   Round(Num_Logs * (Vl.Bytes / (1024 * 1024)), 2) AS Mbytes,
   Vdb.NAME AS Dbname
FROM 
   (SELECT To_Char(Vlh.First_Time, 'YYYY-MM-DD') AS Start_Date, To_Char(Vlh.First_Time, 'HH24') || ':00' AS Start_Time,
   COUNT(Vlh.Thread#) Num_Logs
FROM 
   V$log_History Vlh
GROUP BY 
   To_Char(Vlh.First_Time, 'YYYY-MM-DD'),
   To_Char(Vlh.First_Time, 'HH24') || ':00') Log_Hist,
   V$log Vl,
   V$database Vdb
WHERE 
   Vl.Group# = 1
ORDER BY 
   Log_Hist.Start_Date,
   Log_Hist.Start_Time;