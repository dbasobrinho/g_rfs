sqlplus -S "/as sysdba" <<EOF
set head off pages 0 feed off echo off timing off feedback off sqlblanklines off time off
@dg_status.sql
set serveroutput on
set head off pages 0 feed off echo off timing off feedback off sqlblanklines off time off
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
declare
  c number;
begin
  SELECT distinct max(case when ((to_NUMBER(b.last_seq - a.applied_seq)) > 4) and ((b.last_timestamp-a.last_app_timestamp) > 10/(24*60)) then 2 else 0 end)  into c
  FROM (SELECT thread#, Max(sequence#) applied_seq,  Max(next_time) last_app_timestamp FROM gv\$archived_log  WHERE resetlogs_change#=(SELECT resetlogs_change# FROM v\$database) and applied = 'YES' GROUP  BY thread#) a,
       (SELECT thread#, Max(sequence#) last_seq   ,  Max(next_time) last_timestamp     FROM gv\$archived_log  WHERE resetlogs_change#=(SELECT resetlogs_change# FROM v\$database) GROUP  BY thread#) b
 WHERE  a.thread# = b.thread# ;
if c = 2 then
           dbms_output.put_line(' . . .  ');
           dbms_output.put_line('+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+ +-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+');
           dbms_output.put_line('|!|!|E|R|R|O|!|!| |D|G| |N|A|O| |E|S|T|A| |S|I|N|C|R|O|N|I|Z|A|D|O| |!|!|E|R|R|O|!|!|');
           dbms_output.put_line('+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+ +-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+');
           dbms_output.put_line(' . . .  ');
           dbms_output.put_line(' . .    ');
           dbms_output.put_line(' .      ');
else
           dbms_output.put_line(' . . .  ');
           dbms_output.put_line('----------------------------------------------------------');
           dbms_output.put_line('+-+-+ +-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+-+');
           dbms_output.put_line('|D|G| |E|S|T|A| |S|I|N|C|R|O|N|I|Z|A|D|O|!|');
           dbms_output.put_line('+-+-+ +-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+-+');
           dbms_output.put_line('----------------------------------------------------------');
           dbms_output.put_line(' . . .  ');
           dbms_output.put_line(' . .    ');
           dbms_output.put_line(' .      ');
  end if;
end;
/
begin   dbms_output.put_line(' >> SWITCH LOGFILE CURRENT (01/04) >> ESPERA 10 SEGUNDOS      '); end;
/
alter system archive log current
/
begin  DBMS_LOCK.sleep(10); end;
/
begin   dbms_output.put_line(' >> SWITCH LOGFILE CURRENT (02/04) >> ESPERA 10 SEGUNDOS      '); end;
/
alter system archive log current
/
begin  DBMS_LOCK.sleep(10); end;
/
begin   dbms_output.put_line(' >> SWITCH LOGFILE CURRENT (03/04) >> ESPERA 10 SEGUNDOS      '); end;
/
alter system archive log current
/
begin  DBMS_LOCK.sleep(10); end;
/
begin   dbms_output.put_line(' >> CHECKPOINT             (04/04) >> ESPERA 15 SEGUNDOS      '); end;
/
alter system checkpoint;
/
begin  DBMS_LOCK.sleep(15); end;
/
set head off pages 0 feed off echo off timing off feedback off sqlblanklines off time off
@dg_status.sql
set serveroutput on
set head off pages 0 feed off echo off timing off feedback off sqlblanklines off time off
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
declare
  c number;
begin
  SELECT distinct max(case when ((to_NUMBER(b.last_seq - a.applied_seq)) > 4) and ((b.last_timestamp-a.last_app_timestamp) > 10/(24*60)) then 2 else 0 end)  into c
  FROM (SELECT thread#, Max(sequence#) applied_seq,  Max(next_time) last_app_timestamp FROM gv\$archived_log  WHERE resetlogs_change#=(SELECT resetlogs_change# FROM v\$database) and applied = 'YES' GROUP  BY thread#) a,
       (SELECT thread#, Max(sequence#) last_seq   ,  Max(next_time) last_timestamp     FROM gv\$archived_log  WHERE resetlogs_change#=(SELECT resetlogs_change# FROM v\$database) GROUP  BY thread#) b
 WHERE  a.thread# = b.thread# ;
if c = 2 then
           dbms_output.put_line(' . . .  ');
           dbms_output.put_line('+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+ +-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+');
           dbms_output.put_line('|!|!|E|R|R|O|!|!| |D|G| |N|A|O| |E|S|T|A| |S|I|N|C|R|O|N|I|Z|A|D|O| |!|!|E|R|R|O|!|!|');
           dbms_output.put_line('+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+ +-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+');
           dbms_output.put_line(' . . .  ');
           dbms_output.put_line(' . .    ');
           dbms_output.put_line(' .      ');
else
           dbms_output.put_line(' . . .  ');
           dbms_output.put_line('----------------------------------------------------------');
           dbms_output.put_line('+-+-+ +-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+-+');
           dbms_output.put_line('|D|G| |E|S|T|A| |S|I|N|C|R|O|N|I|Z|A|D|O|!|');
           dbms_output.put_line('+-+-+ +-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+-+');
           dbms_output.put_line('----------------------------------------------------------');
           dbms_output.put_line('+-+-+-+-+-+-+ +-+-+-+-+ +-+ +-+-+-+-+-+-+ +-+-+-+-+');
           dbms_output.put_line('|P|R|O|N|T|O| |P|A|R|A| |O| |S|W|I|T|C|H| |O|V|E|R|');
           dbms_output.put_line('+-+-+-+-+-+-+ +-+-+-+-+ +-+ +-+-+-+-+-+-+ +-+-+-+-+');
       dbms_output.put_line('----------------------------------------------------------');
           dbms_output.put_line(' . . .  ');
           dbms_output.put_line(' . .    ');
           dbms_output.put_line(' .      ');
  end if;
end;
/
!date
EOF
