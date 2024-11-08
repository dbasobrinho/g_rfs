alter session set nls_date_format='dd/mm/yyyy HH24:MI:SS';
alter session set nls_timestamp_format='dd/mm/yyyy HH24:MI:SS'; 
PROMPT
PROMPT +-----------------------------------------------------------------------------+
PROMPT | HISTORICO UTILIZACAO DA UNDO POR QTD DE DIAS [DBA_HIST_UNDOSTAT]            |
PROMPT +-----------------------------------------------------------------------------+
PROMPT
ACCEPT days    number PROMPT 'Dias Atras (SYSDATE - ) = '
PROMPT
COL used_GB              FOR 9999999999;
COL time                 FOR A09;
COL TUNED_UNDORETENTION  FOR 9999999999;

set pages 300
set lines 5000

select substr(time, 1, 8) time, sum(used_GB) used_GB, sum(TUNED_UNDORETENTION) TUNED_UNDORETENTION
  from (select to_char(begin_time, 'yyyymmdd hh24') time,
               round(max(UNDOBLKS + EXPIREDBLKS + UNEXPIREDBLKS + ACTIVEBLKS) * 8192 /
                     (1024 * 1024 * 1024),2) USED_GB,
               TUNED_UNDORETENTION
          from dba_hist_undostat
         where trunc(begin_time) >= trunc(sysdate)-&days
         group by to_char(begin_time, 'yyyymmdd hh24'), TUNED_UNDORETENTION
         order by to_char(begin_time, 'yyyymmdd hh24')) a
 group by substr(time, 1, 8)
 order by 1;

CLEAR BREAKS
CLEAR COLUMNS
TTITLE OFF
UNDEF days
