while true;do
sqlplus -s / as sysasm  <<EOF
set echo off termout on heading on feedback off timing off
@asmd.sql
exit
EOF
echo ==================================================================
date
sleep 20
done

SET LINESIZE    180
SET PAGESIZE    50000

COLUMN dt                   FORMAT a20
COLUMN group_number         FORMAT 000
COLUMN operation            FORMAT a15
COLUMN state                FORMAT a10

select to_char(sysdate, 'dd/mm/yyyy hh24:mi:ss') data_hrs
      ,group_number
      ,operation
      ,state
      ,power
      ,actual
      ,sofar
      ,est_work
      ,est_rate
      ,est_minutes
  from v$asm_operation where STATE = 'RUN';


while true;do
df -h |egrep '/oracle/QUBIT/e|Size'
sleep 5
done

while true;do
nc -tvz dbasobrinho.ddns.net 8250
sleep 15
done

while true;do
free -m; date;
sleep 15
done


while true;do
sqlplus -s / as sysdba  <<EOF
set echo off termout on heading on feedback off timing off
@/tmp/.g/x.sql
exit
EOF
echo ==================================================================
tail /u01/app/oracle/diag/rdbms/ebsgold/ebsgold/trace/alert_ebsgold.log
echo ==================================================================
sleep 20
done

while true;do
sqlplus -s / as sysdba  <<EOF
set echo off termout on heading on feedback off timing off
@asmd.sql
@asm_operation.sql
exit
EOF
echo ==================================================================
du -hs /oracle/export/RMAN_BKP/JDA
echo ==================================================================
tail /oracle/export/RMAN_BKP/JDA/backup_database_FULL_JDA_2403152118.log
echo ==================================================================
date
echo ==================================================================
echo ==================================================================
sleep 20
done



while true;do
##sqlplus / as sysdba <<EOF
###set echo off termout on heading on feedback off timing off
##@/tmp/.g/rman_mon.sql
##exit
##EOF
echo ' '
echo ================================================ `date`
sh /tmp/.g/asmdu.sh -d DATA2/otmdsvdp |egrep 'DATAFILE|controlfile|Subdir'
echo ' '
echo ================================================ `date`
tail -10 /home/oracle/clone/otmdsv/script_rman_tempo_otmdsv_commvoult_16.log
sleep 15
echo ' '
echo ================================================ `date`
sqlplus -s / as sysdba  <<EOF
set echo off termout on heading on feedback off timing off
@/tmp/.g/x.sql
exit
EOF
sleep 20
done


while true;do
##sqlplus / as sysdba <<EOF
###set echo off termout on heading on feedback off timing off
##@/tmp/.g/rman_mon.sql
##exit
##EOF
echo ' '
echo ================================================ `date`
sh /tmp/.g/asmdu.sh -d DATA2/ebsdev |egrep 'DATAFILE|controlfile|Subdir'
echo ' '
echo ================================================ `date`
tail -10 /home/oracle/clone/ebsdev/duplicate_from_active_ebsdev.log
sleep 15
echo ' '
echo ================================================ `date`
sqlplus -s / as sysdba  <<EOF
set echo off termout on heading on feedback off timing off
@/tmp/.g/x.sql
exit
EOF
sleep 20
done

set timing on

while true;do
sqlplus / as sysdba <<EOF
@derruba.sql
exit
EOF
sleep 5
done


set echo off termout off heading off


LOAD AUTORIZADOR 
UNXORASP03: 02.45
UNXORASP04: 03.80

LOAD BKF 
LNXORASP10: 06.61
LNXORASP11: 08.30

while true;do
kill -9 `ps -ef | grep LOCAL=NO | grep $ORACLE_SID | grep -v grep | awk '{print $2}'`
sleep 1
done


sqlplus apps/cqljuaa33J5M <<EOF
@db_recompile_all.sql
@dba_invalid_objects.sql
exit
EOF


cat /home/oracle/dgmgrl_standby_lag.sh

#!/bin/bash
export ORACLE_HOME=/oracle/app/oracle/product/12.1.0/dbhome_1
export ORACLE_SID=primdb
export PATH=$ORACLE_HOME/bin:$PATH
echo -e “show database stydb”|${ORACLE_HOME}/bin/dgmgrl / > DB_DG_DATABASE.log
cat /home/oracle/DB_DG_DATABASE.log  | grep “Apply Lag”  > FILTERED_DB_DG_DATABASE.log
time_value=`cut -d ” ” -f 14 FILTERED_DB_DG_DATABASE.log`
time_param=`cut -d ” ” -f 15 FILTERED_DB_DG_DATABASE.log`




cat /home/oracle/dgmgrl_standby_lag.sh

#!/bin/bash
export ORACLE_HOME=/oracle/app/oracle/product/12.1.0/dbhome_1
export ORACLE_SID=primdb
export PATH=$ORACLE_HOME/bin:$PATH
echo -e "show database '"EBSPRD_STD"'"|${ORACLE_HOME}/bin/dgmgrl / > ~/DB_DG_DATABASE.log
cat /home/oracle/DB_DG_DATABASE.log  | grep "Apply Lag"  > ~/DB_DG_DATABASE_FILTERED.log
time_value=`cut -d " " -f 14 ~/DB_DG_DATABASE_FILTERED.log`
time_param=`cut -d " " -f 15 ~/DB_DG_DATABASE_FILTERED.log`




while true;do 
echo ============ `date`
echo -e "show database '"EBSPRD_STD"'"|${ORACLE_HOME}/bin/dgmgrl / > ~/DB_DG_DATABASE.log
cat /home/oracle/DB_DG_DATABASE.log  | egrep "Apply Lag|Transport Lag"
sleep 10
done




set echo on
declare
    cursor sid is
      select b.sid sid, b.serial# serial, '@'||B.inst_id inst_id,
      'alter system kill session ''' || b.sid || ',' ||b.serial# || ',@' ||b.inst_id||''' immediate ' comando
        from gv$session b
     WHERE username in ('FPS_AS', 'FPS_AF') and B.inst_id = 1
       order by b.sid desc;
       v varchar2(600);
       v_tot number;
begin
    WHILE 1 = 1
        loop
    v_tot :=0;
    for a in sid
    loop
        begin
           execute immediate a.comando;
           dbms_output.put_line('Killed: sid: '||lpad(a.sid,4,'0')||' serial#: '||lpad(a.serial,6,'0')|| ' ok!');
           v_tot := v_tot +1;
        exception
        when others then
            dbms_output.put_line('Error Kill: sid: '||lpad(a.sid,4,'0')||' serial#: '||lpad(a.serial,6,'0'));
        end;
    end loop;
    dbms_output.put_line(' ');
    dbms_output.put_line('----------------------------------------------------------------');
    dbms_output.put_line(' T O T A L   K I L L : '||LPAD(v_tot,8,'0'));
    dbms_output.put_line('----------------------------------------------------------------');
        end loop;
end;
/
