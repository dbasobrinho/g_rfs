-- |----------------------------------------------------------------------------|
-- | Objetivo   : Vizualizar utilização de espaco por tablespace                |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 02/04/2018                                                    |
-- | Exemplo    : @tbs                                                          |
-- | Arquivo    : tbs.sql                                                       |
-- | Modificacao: 16/07/2019 | Inclusao da pkg: dbms_xplan.format_size          |
-- |            : 16/07/2019 | Inclusao da pkg: dbms_xplan.format_size          |
-- +----------------------------------------------------------------------------+
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : TABLESPACE USED INFO                +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 2.0                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
PROMPT
SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
CLEAR COLUMNS
COLUMN TABLESPACE           FORMAT A30                 HEADING  "TABLESPACE|NAME"   JUSTIFY CENTER
COLUMN STATUS               FORMAT A08                 HEADING  "STATUS|-"          JUSTIFY CENTER
COLUMN TOTAL_MB             FORMAT A10                 HEADING  " TOTAL|SIZE"       JUSTIFY CENTER
COLUMN USED_MB              FORMAT A10                 HEADING  "USED|SIZE"         JUSTIFY CENTER
COLUMN FREE_MB              FORMAT A10                 HEADING  "FREE|SIZE"         JUSTIFY CENTER
COLUMN TOTAL_MB_MAX         FORMAT A10                 HEADING  " TOTAL|SIZE EXT"   JUSTIFY CENTER
COLUMN USED_MB_MAX          FORMAT A10                 HEADING  "MAX USED|SIZE"     JUSTIFY CENTER
COLUMN FREE_MB_MAX          FORMAT A10                 HEADING  "FREE|SIZE EXT"     JUSTIFY CENTER
COLUMN PCT_USED             FORMAT 999.99              HEADING  " % USED|-"         JUSTIFY CENTER
COLUMN GRAPH                FORMAT A25                 HEADING  "GRAPH| (X=5%)"     JUSTIFY CENTER
COLUMN PCT_USED_MAX         FORMAT 999.99              HEADING  " % USED|EXT"       JUSTIFY CENTER
COLUMN GRAPH_MAX            FORMAT A25                 HEADING  "GRAPH| (X=5%) EXT" JUSTIFY CENTER
COLUMN GRAPH_EXTEND         FORMAT A25 HEADING "GRAPH_EXT (X=5%)"
COLUMN KB                   FORMAT A02 HEADING "KB"
COLUMN TOTAL_MB_MAX2        FORMAT A10
COLUMN USED_MB2             FORMAT A10
COMPUTE                     SUM OF TOTAL_MB     ON REPORT
COMPUTE                     SUM OF USED_MB      ON REPORT
COMPUTE                     SUM OF FREE_MB      ON REPORT
COMPUTE                     SUM OF TOTAL_MB_MAX ON REPORT
COMPUTE                     SUM OF USED_MB_MAX  ON REPORT
COMPUTE                     SUM OF FREE_MB_MAX  ON REPORT
BREAK   ON REPORT           
SET PAGESIZE            1000 
SET LINESIZE            230
SET COLSEP '|'

select z.*
from (
SELECT  /*+ PARALLEL(TOTAL,2) PARALLEL(FREE,2) */
TOTAL.TS                                                as  TABLESPACE,
(select lpad(NVL(BLOCK_SIZE/1024,0),2,'0') from DBA_TABLESPACES where TABLESPACE_NAME = TOTAL.TS)  as KB,
DECODE(TOTAL.MB,NULL,'OFFLINE',DBAT.STATUS)             as STATUS,
lpad(dbms_xplan.format_size(TOTAL.MB),10,' ')                        as TOTAL_MB,
lpad(dbms_xplan.format_size(NVL(TOTAL.MB-FREE.MB,TOTAL.MB)),10,' ')  as USED_MB,
lpad(dbms_xplan.format_size(NVL(FREE.MB,0)),10,' ')                  as FREE_MB,
DECODE(TOTAL.MB,NULL,0,NVL(ROUND((TOTAL.MB - FREE.MB)/(TOTAL.MB)*100,2),100))  as PCT_USED,
CASE WHEN (TOTAL.MB IS NULL) THEN '['||RPAD(LPAD('OFFLINE',13,'-'),20,'-')||']' 
                             ELSE '['|| DECODE(FREE.MB,NULL,'XXXXXXXXXXXXXXXXXXXX',NVL(RPAD(LPAD('X',TRUNC((100-ROUND( (FREE.MB)/(TOTAL.MB) * 100, 2))/5),'X'),20,'-'),'--------------------'))||']' END AS GRAPH,
lpad(dbms_xplan.format_size(TOTAL.MB_MAX),10,' ')                                            as TOTAL_MB_MAX,
lpad(dbms_xplan.format_size(TOTAL.MB_MAX - NVL(TOTAL.MB-FREE.MB,TOTAL.MB)),10,' ')           as FREE_MB_MAX,
DECODE(TOTAL.MB_MAX,NULL,0,ROUND(100-(((TOTAL.MB_MAX - NVL(TOTAL.MB-FREE.MB,TOTAL.MB)) *100) / TOTAL.MB_MAX),2)) as PCT_USED_MAX,
CASE WHEN (TOTAL.MB_MAX IS NULL) THEN '['||RPAD(LPAD('OFFLINE',13,'-'),20,'-')||']' 
                             ELSE '['|| DECODE((TOTAL.MB_MAX - NVL(TOTAL.MB-FREE.MB,TOTAL.MB)),NULL,'XXXXXXXXXXXXXXXXXXXX',NVL(RPAD(LPAD('X',TRUNC((100-ROUND( (TOTAL.MB_MAX - NVL(TOTAL.MB-FREE.MB,TOTAL.MB))/(TOTAL.MB_MAX) * 100, 2))/5),'X'),20,'-'),'--------------------'))||']' END AS GRAPH_MAX
FROM
      (SELECT /*+ PARALLEL(DBA_DATA_FILES,2) */ TABLESPACE_NAME TS, SUM(BYTES) MB, SUM(GREATEST(MAXBYTES, BYTES)) MB_MAX  FROM DBA_DATA_FILES GROUP BY TABLESPACE_NAME) TOTAL,
      (SELECT TABLESPACE_NAME TS, SUM(BYTES) MB FROM DBA_FREE_SPACE GROUP BY TABLESPACE_NAME) FREE,
      DBA_TABLESPACES DBAT
WHERE TOTAL.TS = FREE.TS(+) 
  AND TOTAL.TS = DBAT.TABLESPACE_NAME) z
  --and TOTAL.TS = 'SYSAUX'
order by z.PCT_USED_MAX desc 
/  
ttitle off
rem clear columns
