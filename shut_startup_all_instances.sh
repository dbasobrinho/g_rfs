ps -ef | grep pmon | grep -v grep | grep -iv asm | awk '{print$9}' | cut -d '_' -f3 > instancias.txt
**** dependendo do S.O o "awk '{print$" pode ser 8 ou 9 ****






#!/bin/bash
cat instancias.txt | while read LINE; do
export ORACLE_SID=$LINE
sqlplus / as sysdba<<EOF
spool start_memoria.log append;
set lines 400 pages 99
col name for a35
col db_name for a15
col value for a20
col value for a20
SET LINESIZE 200
SET PAGESIZE 50000
SET VERIFY   OFF;
SET FEEDBACK OFF;
SET TERMOUT  OFF; 
SET ECHO     OFF; 
SET FEEDBACK OFF; 
SET HEADING  OFF; 
SET NEWPAGE 0;
SELECT upper((select NAME as_db_name from v$database)) as db_name,
       DECODE(UPPER(NAME),'SGA_TARGET',VALUE/1024/1024,
	                      'PGA_AGGREGATE_TARGET',VALUE/1024/1024,
						  'SGA_MAX_SIZE', VALUE/1024/1024,
						  'MEMORY_MAX_TARGET', VALUE/1024/1024,
						  'MEMORY_TARGET', VALUE/1024/1024
						  ) AS VALUE_MB,        UPPER(NAME) AS NAME, 
	   VALUE
from v$parameter where UPPER(name) like UPPER('%SGA%') OR UPPER(name) like UPPER('%PGA%')
or UPPER(NAME) = 'MEMORY_MAX_TARGET' or UPPER(NAME) = 'MEMORY_TARGET'
ORDER BY value desc
/
spool off
exit
EOF


INSTANCE_RUNNING=`ps -ef | grep -i pmon | egrep -iv "asm|grep|awk" | awk -F"_pmon_" '{print$3}'`
for inst in `echo $INSTANCE_RUNNING | sed -e 's/+ASM//g'`
do
export ORACLE_SID=$inst
sqlplus / as sysdba <<EOF
@x.sql
exit
EOF
done



[oracle@lnxorarjh05] [~] $ cat instancias.txt 
preppgbk1
hback1
hics1
ppvtm1
ppmfs1
hmfs1
ppstxkm1
HPPGBK1
hvtm1
stxppbk1
partppbk1
ppback1
shback1 

[oracle@lnxorarjh05] [~] $ cat shutdownall.sh
#!/bin/bash
cat instancias.txt | while read LINE; do
export ORACLE_SID=$LINE
sqlplus / as sysdba<<EOF
spool start_$instance;
sssssssssssssssshutdown immediate
exit
EOF
done


[oracle@lnxorarjh05] [~] $ cat startupall.sh
#!/bin/bash
cat instancias.txt | while read LINE; do
export ORACLE_SID=$LINE
sqlplus / as sysdba<<EOF
spool start_$instance;
startupppppppppppp
exit
EOF
done
