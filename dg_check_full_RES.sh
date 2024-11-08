##sh /u/app/oracle/product/11.2.0/db_1/scripts/dg_check_full_DET.sh
##sh /u/app/oracle/product/11.2.0/db_1/scripts/dg_check_full_RES.sh
sqlplus -S "/ as sysdba"<<EOF
set serveroutput on
set feedback off
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
declare
  c number;
begin
  select count (0) into c from V\$ARCHIVED_LOG where RESETLOGS_CHANGE# = (SELECT MAX(RESETLOGS_CHANGE#) FROM V\$ARCHIVED_LOG) and standby_dest='YES' and APPLIED='NO';
if c > 1 then
   dbms_output.put_line('###############################');
   dbms_output.put_line('VERIFICAR O SINCRONISMO DO DATAGUARD, EXISTEM PROBLEMAS');
   dbms_output.put_line('###############################');
else
     dbms_output.put_line('###############################');
     dbms_output.put_line('O DATAGUARD ESTA SINCRONIZADO!');
     dbms_output.put_line('###############################');
  end if;

end;
/
EOF