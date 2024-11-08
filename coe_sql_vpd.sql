alter session set nls_date_format='dd/mm/yyyy HH24:MI:SS';
alter session set nls_timestamp_format='dd/mm/yyyy HH24:MI:SS';
set lines 200
set pages 200
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Identifica se o SQLID utiliza VPD                                      |
PROMPT +------------------------------------------------------------------------+
PROMPT
ACCEPT sql_idxx char   PROMPT 'SQL ID = '
PROMPT
COL sql_id               FOR A16;
COL predicate            FOR A70;
COL object_owner         FOR A21;
COL object_name          FOR A35;
COL policy_group         FOR A21


select nvl(a.VPD,b.VPD) status, a.predicate, a.object_owner, a.object_name, a.policy_group
from
      (select 1 t, 'VPD [ON]' VPD, substr(predicate,1,50) predicate, object_owner, object_name, policy_group  from gv$vpd_policy  a where sql_id = '&&sql_idxx') A
     ,(select 1 t, 'VPD [OFF]' VPD FROM DUAL) B
where a.t(+)  = b.t
/
