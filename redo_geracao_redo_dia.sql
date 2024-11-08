--Script: REDO_GERACAO_REDO_DIA
--Data:   20/01/2016
--Autor: Marcio Guimaraes
--Finalidade: Lista o numero de Redos gerados por dia
--Versão: 1.0 

   select
   Start_Date,
   Num_Logs,
   Round(Num_Logs * (Vl.Bytes / (1024 * 1024)), 2) AS Mbytes,
   Vdb.NAME AS Dbname
FROM 
   (SELECT To_Char(Vlh.First_Time, 'YYYY-MM-DD') AS Start_Date, 
   COUNT(Vlh.Thread#) Num_Logs
FROM 
   V$log_History Vlh
GROUP BY 
   To_Char(Vlh.First_Time, 'YYYY-MM-DD')) LOG_HIST,
   V$log Vl,
   V$database Vdb
WHERE 
   Vl.Group# = 1
ORDER BY 
   Log_Hist.Start_Date