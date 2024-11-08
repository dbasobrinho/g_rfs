-- |----------------------------------------------------------------------------|
-- | Objetivo   : Identificar Profiles                                          |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 15/12/2015                                                    |
-- | Exemplo    : find_profile_by_sqlid                                         |
-- | Arquivo    : find_profile_by_sqlid.sql                                     |
-- | Modificacao: V1.0 - 27/12/2019 - rfsobrinho - [FELIZ 2020 / ZAS ]          |
-- +----------------------------------------------------------------------------+ 
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Lista Profile por SQLID             +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 1.0                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINES       10000
SET PAGES       10000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
SET COLSEP '|'
Accept DT_LAST_MODIFIED prompt 'Enter NUM. SYSDATE - :'
column name format a40 HEADING 'NAME'
column status format a10
column category format a30
column sql_id  format a14
column created format a21
column LAST_MODIFIED  format a21
select
a.name,
a.status,
to_char(a.created,'DD/MM/YYYY hh24:mi:ss')  created,
to_char(a.LAST_MODIFIED,'DD/MM/YYYY hh24:mi:ss')  LAST_MODIFIED,
a.CATEGORY,
b.sql_id
from
DBA_SQL_PROFILES a,
(select distinct sql_id,sql_profile from (select sql_id,sql_profile from DBA_HIST_SQLSTAT 
union
select sql_id,sql_profile from gv$sql)) b
where a.name=b.sql_profile
AND trunc(A.LAST_MODIFIED) > sysdate- &DT_LAST_MODIFIED
order by a.LAST_MODIFIED desc
/
SET FEEDBACK on
