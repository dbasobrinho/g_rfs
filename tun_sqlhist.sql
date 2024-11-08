-----------------------------------------------------------------------------
--
--
--  NAME 
--    sqlhist.sql
--
--  DESCRIPTON
--    Lista estatisticas em execução de um sql_id 
--
--  ATTENTION
--    A execução deste script requer licença da OPTION DIAGNOSTIC & TUNING PACK
--
--  HISTORY
--    05/04/2012 => Valter Aquino
--
-----------------------------------------------------------------------------

set verify off;
undefine sql_id

Col Beg Format A20
Col Inst Format 999
Col EXECS Format 9999999999

Select S.Snap_Id,
       To_Char(Begin_Interval_Time, 'Dd-Mon-Yy-Hh24:Mi') Beg,
       S.Instance_Number Inst, 
       S.PARSING_SCHEMA_NAME Schema, 
       S.PLAN_HASH_VALUE PHV,
       Executions_Delta EXECS,
       Rows_Processed_Delta ROWSP,
       Round(Elapsed_Time_Delta/1000000/60) "Total Delta Mins",
       Round(Elapsed_Time_Delta/(Executions_Delta+.01)) "Time per exec µs"
  From Dba_Hist_Sqlstat S, 
       Dba_Hist_Snapshot T
 Where Sql_Id = '&sql_id'
   And S.Instance_Number = T.Instance_Number
   And S.Snap_Id = T.Snap_Id
   And Executions_Delta > 1
 Order By 1;
 
 
set verify on;