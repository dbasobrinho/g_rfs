PROMPT .
PROMPT ========================================================================
PROMPT 00 - CRIANDO OBJETOS PARA O NOMONITORING INDEX [working. . .]
PROMPT ========================================================================
PROMPT .
create or replace view SYS.V$ALL_OBJECT_USAGE
(OWNER,
INDEX_NAME,
TABLE_NAME,
MONITORING,
USED,
START_MONITORING,
END_MONITORING
)
as
select u.name, io.name, t.name,
decode(bitand(i.flags, 65536), 0, 'NO', 'YES'),
decode(bitand(ou.flags, 1), 0, 'NO', 'YES'),
TO_DATE(ou.start_monitoring,'MM/DD/YYYY HH24:MI:SS') start_monitoring,
TO_DATE(ou.end_monitoring,'MM/DD/YYYY HH24:MI:SS') end_monitoring
from sys.user$ u, sys.obj$ io, sys.obj$ t, sys.ind$ i, sys.object_usage ou
where i.obj# = ou.obj#
and io.obj# = ou.obj#
and t.obj# = i.bo#
and u.user# = io.owner#
/
create or replace public synonym V$ALL_OBJECT_USAGE for V$ALL_OBJECT_USAGE
/
PROMPT .
PROMPT ========================================================================
PROMPT 00 - OBJETOS PARA O NOMONITORING INDEX [OK]
PROMPT ========================================================================
PROMPT .
PROMPT =====T O T A I S =======================================================
PROMPT .
select count(1) tot, MONITORING from V$ALL_OBJECT_USAGE group by MONITORING
/
PROMPT ========================================================================
