--- Author: Francisco Munoz Alvarez
--- Date  : 20/07/2008
--- Script: Checklist v.1.3


COLUMN y new_value sid NOPRINT
SELECT name||'_'||TO_CHAR(sysdate, 'ddmonyy_hh24mi') y FROM v$database;
SPOOL checklist_&sid..txt

alter system checkpoint;

alter system check datafiles;

Set Linesize 300
Set Pagesize 300 
Set SQLPROMPT 'Sql>'
Set Desc Linenum On

Set Arraysize 1
Set Long 2000
Set Serveroutput On size 800000 ;

Set Heading  Off
Set Feedback Off
Set Verify   Off

Column Var_Date new_value Var_Date noprint

Select
       To_Char(Sysdate, 'DD-MM-YYYY HH24:MI') Var_Date
  from
       v$database
;



-- Prompt ---

Select
       '   ******   &Var_Date   **************   Base : ' || Name || '   ************** '
  from
       v$database;

Set Heading  On

column sid        heading "Id"              format 9999
column spid       heading "Unix"            format A7
column username   heading "Utilis."         format A20
column terminal   heading "Terminal"        format A11
column program    heading "Programme"       format A27   word_wrapped

select
        s.sid, p.spid, substr(s.username,1,20) username, s.terminal, p.Program
  from
       v$session s, v$process p
 where
       s.paddr = p.addr
   and
       s.sid = (select sid from v$mystat where rownum=1)
;

Set Heading  Off
Set Termout  Off

Column Var_Prompt new_value Var_Prompt noprint

Select
       ''''||Rpad(Lpad(Initcap(Substr(Name,1,4)),3,'*'),4,'*')||'>''' Var_Prompt
  from
       v$database
;


Set SQLPROMPT &Var_Prompt

Set Termout  On

Prompt

-- Prompt ---


Set Heading  On
Set Feedback On


-- prompt

prompt -- ----------------------------------------------------------------------- ---

prompt --   Oracle Instance Information                                                  ---

prompt -- ----------------------------------------------------------------------- ---

Set Heading  Off
Set Feedback Off
Set Verify   Off

column status           format a120 wrap             heading "Status"

Select status_01||'    | '||status_02 status
  From
       (Select '   Host_Name     '||Lpad(Host_Name,18) status_02 from V$Instance)
     , (Select '   Cpu_Count             '||Lpad(value,8) status_01 from V$PARAMETER where name='cpu_count' and value is not null)
Union
Select status_01||'    | '||status_02 status
  From
       (Select '   Instance_Name     '||Lpad(Instance_Name,12) Status_01 from V$Instance)
     , (Select '   Database_Status     '||Lpad(Database_Status,12) Status_02 from V$Instance)
Union
Select status_01||'    | '||status_02 status
  From
       (Select '   Startup_Time    '||To_Char(Startup_Time, 'DD-MM-YYYY HH24:MI') Status_02 from V$Instance)
     , (Select '   Status            '||Lpad(Status,12) Status_01 from V$Instance)
Union
Select status_01||'    | '||status_02 status
  From
       (Select '   Version           '||Lpad(Version,12) Status_01 from V$Instance)
     , (Select '   Instance_Role   '||Lpad(Instance_Role,16) Status_02 from V$Instance)
;

select '   Database log mode            '||log_mode "Parameter" from V$DATABASE
union
select '   Archive destination          '||value    from V$PARAMETER where (name='log_archive_dest' or name = 'log_archive_dest_1') and value is not null
;

select '   Compatible Version           '||value    from V$PARAMETER where name='compatible'
;

select '   Spfile                       '||value    from V$PARAMETER where name='spfile' and value is not null
union
select '   Background Dump Dest         '||value    from V$PARAMETER where name='background_dump_dest' and value is not null
;


-- ----------------------------------------------------------------------- ---
--   Check Redo Size                                                             ---
-- ----------------------------------------------------------------------- ---

select distinct '   Redo size (Kb)    '|| Lpad(To_Char(round(bytes/1024)),'16') Status from v$log;


Prompt


Declare
  --
  Cursor Cur_Req Is
        Select distinct object_name
      from dba_objects
      where object_name='DBA_TEMP_FILES'
        ;
  --
   Cursor Cur_SGA Is
        select '   SGA (Mb)                '||Lpad(To_Char(Round(sum (value)/1024/1024)),8) status_02 from v$sga;
  --
  W_Texte               Varchar2(2000);
  Curs                  Integer;
  Return_code           Integer;
  W_Temp                Varchar2(40);
  --
  X     Varchar2(100);
  Nb_Tf         Number(8);
  SGA           Varchar2(40);
  --
Begin
  --
  X := Null;
  --
  Open Cur_Req;
    Fetch Cur_Req Into X;
  Close Cur_Req;
  --
  Open Cur_SGA;
    Fetch Cur_SGA Into SGA;
  Close Cur_SGA;
  --
  If X Is Not Null Then
    --
    W_Texte :=  'Select ''Database Space (Mb)   ''||Lpad(To_Char(Round((nb_ctl.nb * ctl_size.the_size) ';
    W_Texte :=  W_texte ||' + (rlf_size.the_size/1024) ';
    W_Texte :=  W_texte ||' + (dtf_size.the_size/1024) ';
    W_Texte :=  W_texte ||' + (nvl(dtft_size.the_size,0)/1024))),8) From  ';
    W_Texte :=  W_texte ||' (select count(1) nb from v$controlfile) nb_ctl ';
    W_Texte :=  W_texte ||' , (select round(sum(record_size)/1024) the_size from V$CONTROLFILE_RECORD_SECTION) ctl_size ';
    W_Texte :=  W_texte ||' , (select round(sum(bytes)/1024) the_size from v$log) rlf_size ';
    W_Texte :=  W_texte ||' , (select round(sum(bytes)/1024) the_size from dba_data_files) dtf_size ';
    W_Texte :=  W_texte ||' , (select round(sum(bytes)/1024) the_size from dba_temp_files) dtft_size';
    --
  Else
    --
    W_Texte :=  'Select ''Database Space (Mb)   ''||Lpad(To_Char(Round((nb_ctl.nb * ctl_size.the_size) ';
    W_Texte :=  W_texte ||' + (rlf_size.the_size/1024) ';
    W_Texte :=  W_texte ||' + (dtf_size.the_size/1024) ';
    W_Texte :=  W_texte ||' + (nvl(dtft_size.the_size,0)/1024))),8) From  ';
    W_Texte :=  W_texte ||' (select count(1) nb from v$controlfile) nb_ctl ';
    W_Texte :=  W_texte ||' , (select round(sum(record_size)/1024) the_size from V$CONTROLFILE_RECORD_SECTION) ctl_size ';
    W_Texte :=  W_texte ||' , (select round(sum(bytes)/1024) the_size from v$log) rlf_size ';
    W_Texte :=  W_texte ||' , (select round(sum(bytes)/1024) the_size from dba_data_files) dtf_size ';
    --
  End If;
  --
  Curs := Dbms_Sql.Open_Cursor;
  --
  Dbms_Sql.Parse(Curs, W_texte, Dbms_Sql.Native);
  Dbms_Sql.Define_Column(Curs, 1, W_Temp, 40);
  --
  Return_Code := Dbms_Sql.Execute(Curs);
  --
  IF dbms_sql.FETCH_ROWS(Curs)>0 THEN
    Dbms_Sql.Column_Value(Curs, 1, W_Temp);
  End If;
  --
  Dbms_OutPut.Put_Line('-- '||W_Temp||'    | '||SGA||' --');
  --
  Dbms_Sql.Close_Cursor(Curs);
  --
End;
/





Declare
  --
  Cursor Cur_Req Is
        Select distinct object_name
      from dba_objects
      where object_name='DBA_TEMP_FILES'
        ;
  --
  Cursor Cur_Df Is
        Select Count(*)
      From dba_data_files
        ;
  --
  W_Texte               Varchar2(2000);
  Curs                  Integer;
  Return_code           Integer;
  W_Temp                Varchar2(20);
  --
  X     Varchar2(100);
  Nb_Tf         Number(8);
  Nb_Df         Number(8);
  --
Begin
  --
  X := Null;
  --
  Open Cur_Req;
    Fetch Cur_Req Into X;
  Close Cur_Req;
  --
  Open Cur_Df;
    Fetch Cur_Df Into Nb_Df;
  Close Cur_Df;
  --
  If X Is Not Null Then
    --
    W_Texte :=  'Select To_Char(Count(*)) From dba_temp_files';
    --
    Curs := Dbms_Sql.Open_Cursor;
    --
    Dbms_Sql.Parse(Curs, W_texte, Dbms_Sql.Native);
    Dbms_Sql.Define_Column(Curs, 1, W_Temp, 20);
    --
    Return_Code := Dbms_Sql.Execute(Curs);
    --
    IF dbms_sql.FETCH_ROWS(Curs)>0 THEN
      Dbms_Sql.Column_Value(Curs, 1, W_Temp);
    End If;
    --
    Dbms_OutPut.Put_Line('-- Nb. Datafiles            '||Lpad(To_Char(Nb_Df),5)||'    |    Nb. Tempfiles              '||Lpad(W_Temp,5)||' --' );
    --
    Dbms_Sql.Close_Cursor(Curs);
    --
  Else
    Dbms_OutPut.Put_Line('-- Nb. Datafiles            '||Lpad(To_Char(Nb_Df),5));
  End If;
  --
End;
/


prompt
prompt


prompt -- ----------------------------------------------------------------------- ---

prompt --    Instance CheckList                                                   ---

prompt -- ----------------------------------------------------------------------- ---



Select status_01||'    | '||status_02 status
  From
       (Select '     Instance Status     '||Lpad('OK',12) Status_01 from V$Instance)
     , (Select '   Listener Status   '||Lpad('OK',12) Status_02 from V$Instance);


prompt
prompt


prompt -- ----------------------------------------------------------------------- ---

prompt --   Performance Memory CheckList                                          ---

prompt -- ----------------------------------------------------------------------- ---

prompt ---


declare
  cursor c1 is
         select count(*)
         from v$session
         where serial# != 1
         and osuser is not null;
  ---
  cursor c2 is
         select count(*)
         from v$session
         where SERIAL# != 1
         and osuser is not null
         and status='ACTIVE';
  ---
  cursor c3 is
         select ((1-a.value/(b.value+c.value))*100)
         from v$sysstat a, v$sysstat b , v$sysstat c
         where a.name = 'physical reads'
         and b.name = 'db block gets'
         and c.name = 'consistent gets';
  ---
  cursor c4 is
         select ((sum(pins)/(sum(pins)+sum(reloads))*100))
         from v$librarycache;
  ---
  cursor c5 is
         select ((1-(sum(getmisses)/sum(gets)))*100)
         from v$rowcache;
  ---
  cursor c6 is
         select (count(*)/24)
         from sys.v_$log_history
         where first_time > sysdate - 1;
  ---
  cursor c7 is
         select count(*)
         From dba_jobs Where broken != 'N';
  ---
  cursor c8 is
         select count(*)
         From v$shared_pool_reserved where request_failures != 0;
  ---
  cursor c9 is
         select round(100*retries.value/entries.value,4)
         from gv$sysstat retries, gv$sysstat entries
         where retries.name = 'redo buffer allocation retries' AND
         entries.name = 'redo entries' and
         entries.inst_id = retries.inst_id;

  ---
  cursor c10 is
         select nvl(total_waits,0)
         from gv$system_event
         where event like '%log buffer space%';
  ---
  cursor c11 is
         select round(100*SUM(getmisses)/SUM(gets),3)
         from gv$rowcache;
  ---
  A         Number(8);
  B         Number(8);
  C         Number(8);
  D         Number(8);
  E         Number(8);
  F         Number(8);
  G         Number(8);
  H         Number(8);
  I         Number(8,4);
  J         Number(8);
  K         Number(8,3);
  ---
  AA        Varchar2(5);
  BB        Varchar2(5);
  CC        Varchar2(5);
  DD        Varchar2(5);
  EE        Varchar2(5);
  FF        Varchar2(5);
  GG        Varchar2(5);
  HH        Varchar2(5);
  II        Varchar2(5);
  JJ        Varchar2(5);
  KK        Varchar2(5);
  ---
begin
  Open c1;
    Fetch c1 Into A;
  Close c1;
  Open c2;
    Fetch c2 Into B;
  Close c2;
  Open c3;
    Fetch c3 Into C;
  Close c3;
  Open c4;
    Fetch c4 Into D;
  Close c4;
  Open c5;
    Fetch c5 Into E;
  Close c5;
  Open c6;
    Fetch c6 Into F;
  Close c6;
  Open c7;
    Fetch c7 Into G;
  Close c7;
  Open c8;
    Fetch c8 Into H;
  Close c8;
  Open c9;
    Fetch c9 Into I;
  Close c9;
  Open c10;
    Fetch c10 Into J;
  Close c10;
  Open c11;
    Fetch c11 Into K;
  Close c11;
  if A <= 700 then
       AA := 'OK';
  else
       AA := 'NO';
  end if;
  if B <= 15 then
     BB := 'OK';
  else
     BB := 'NO';
  end if;
  if C >= 80 then
     CC := 'OK';
  else
     CC := 'NO';
  end if;
  if D >= 99 then
     DD := 'OK';
  else
     DD := 'NO';
  end if;
  if E >= 80 then
     EE := 'OK';
  else
     EE := 'NO';
  end if;
  if F <= 5 then
    FF := 'OK';
  else
    FF := 'NO';
  end if;
  if G = 0 then
    GG := 'OK';
  else
    GG := 'NO';
  end if;
  if H = 0 then
    HH := 'OK';
  else
    HH := 'NO';
  end if;
  if I <= 0.0010 then
    II := 'OK';
  else
    II := 'NO';
  end if;
  if J = 0 then
    JJ := 'OK';
  elsif J is  null then
    JJ := 'OK';
     J := 0;
  else
    JJ := 'NO';
  end if;
  if K <= 0.015 then
    KK := 'OK';
  else
    KK := 'NO';
  end if;
  dbms_OutPut.Put_Line('--   '||'Total Sessions < 700          '||Lpad(AA,5)||' - '||Lpad(To_Char(A),5));
  dbms_OutPut.Put_Line('--   '||'Active sessions number <15    '||Lpad(BB,5)||' - '||Lpad(To_Char(B),5));
  dbms_OutPut.Put_Line('--   '||'Data Buffer Hit Ratio > 80    '||Lpad(CC,5)||' - '||Lpad(To_Char(C),5));
  dbms_OutPut.Put_Line('--   '||'L.Buffer Reload Pin Ratio > 99'||Lpad(DD,5)||' - '||Lpad(To_Char(D),5));
  dbms_OutPut.Put_Line('--   '||'Row Cache Miss Ratio < 0.015  '||Lpad(KK,5)||' - '||Lpad(To_Char(K),5));
  dbms_OutPut.Put_Line('--   '||'Dict.Buffer Hit Ratio > 80    '||Lpad(EE,5)||' - '||Lpad(To_Char(E),5));
  dbms_OutPut.Put_Line('--   '||'Log Buffer Waits = 0          '||Lpad(JJ,5)||' - '||Lpad(To_Char(J),5));
  dbms_OutPut.Put_Line('--   '||'Log Buffer Retries < 0.0010   '||Lpad(II,5)||' - '||Lpad(To_Char(I),5));
  dbms_OutPut.Put_Line('--   '||'Switch number (Daily Avg) < 5 '||Lpad(FF,5)||' - '||Lpad(To_Char(F),5));
  dbms_OutPut.Put_Line('--   '||'Jobs Broken = 0               '||Lpad(GG,5)||' - '||Lpad(To_Char(G),5));
  dbms_OutPut.Put_Line('--   '||'Shared_Pool Failure  = 0      '||Lpad(HH,5)||' - '||Lpad(To_Char(H),5));
end;
/


prompt ---

prompt -- ----------------------------------------------------------------------- ---

prompt --   Storage  CheckList                                                    ---

prompt -- ----------------------------------------------------------------------- ---

prompt ---

Select status_01||'    | '||status_02 status
  From
       (select distinct
       decode (status
                     , 'ONLINE', '     V$Datafile Status '||Lpad('OK',12)
                     , 'SYSTEM', '     V$Datafile Status '||Lpad('OK',12)
                               , '     V$Datafile Status '||Lpad('NO',12)
              ) STATUS_01 from v$datafile)
     , (select distinct
       decode (status
                     , 'ONLINE', '   V$Tempfile Status '||Lpad('OK',14)
                     , 'SYSTEM', '   V$Tempfile Status '||Lpad('OK',14)
                               , '   V$Tempfile Status '||Lpad('NO',14)
              ) STATUS_02 from v$tempfile)
Union
Select status_01||'    | '||status_02 status
  From
      (select distinct
       decode (status
                     , 'ONLINE',    '     Dba_Tablespaces Status '||Lpad('OK',7)
                     , 'READ ONLY', '     Dba_Tablespaces Status '||Lpad('OK',7)
                                  , '     Dba_Tablespaces Status '||Lpad('NO',7)
              ) STATUS_01 from dba_tablespaces)
     , (select distinct
       decode (status
                     , 'CURRENT',  '   V$Log Status '||Lpad('OK',19)
                     , 'ACTIVE',   '   V$Log Status '||Lpad('OK',19)
                     , 'INACTIVE', '   V$Log Status '||Lpad('OK',19)
                                 , '   V$Log Status '||Lpad('NO',19)
              ) STATUS_02 from v$log)
union
Select status_01||'    | '||status_02 status
  From
      (select
       distinct
       decode (count(1)
                       , 0, '     V$Recover_File '||Lpad('OK',15)
                          , '     V$Recover_File '||Lpad('NO',15)
              ) STATUS_01 from v$recover_file)
     , (select
       distinct
       decode (count(1)
                       , 0, '   V$Recovery_Log '||Lpad('OK',17)
                          , '   V$Recovery_Log '||Lpad('NO',17)
              ) STATUS_02 from v$recovery_log)
;


prompt


declare
  cursor c1 is
         select count(*)
         from v$backup where status  !=  'NOT ACTIVE';

  ---
  cursor c2 is
         select count(*)
         from ( select sum (bytes)/1048576 free, max (bytes)/1048576 fragmax, tablespace_name from  sys.dba_free_space group  by tablespace_name ) fsp,  ( select sum(bytes)/1048576 alloc, tablespace_name from sys.dba_data_files group by tablespace_name) df, dba_tablespaces dt where fsp.tablespace_name (+)   =   df.tablespace_name and df.tablespace_name = dt.tablespace_name and dt.status = 'ONLINE' and (((alloc - nvl (free, 0)) / alloc) * 100 > 95);
  ---
  cursor c3 is
         select count(*)
         From dba_objects where status != 'VALID'
         and  owner not in ('PUBLIC','WKSYS','MDSYS','TSMSYS','CTXSYS','OLAPSYS','EXFSYS','ORDSYS','SYSMAN','SYS','WMSYS','SYSTEM','OUTLN','DBSNMP');
  ---
  cursor c4 is
         select count(*)
         from dba_indexes where status = 'UNUSABLE';
  ---
  cursor c5 is
         select count(*)
         from dba_triggers where status != 'ENABLED'
         and owner not in ('PUBLIC','WKSYS','MDSYS','TSMSYS','CTXSYS','OLAPSYS','EXFSYS','ORDSYS','SYSMAN','SYS','WMSYS','SYSTEM','OUTLN','DBSNMP');
  ---
  cursor c6 is
         select count(*)
         From dba_constraints where status != 'ENABLED'
         and owner not in ('PUBLIC','WKSYS','MDSYS','TSMSYS','CTXSYS','OLAPSYS','EXFSYS','ORDSYS','SYSMAN','SYS','WMSYS','SYSTEM','OUTLN','DBSNMP') and constraint_type!='S';
  ---
  A         Number(8);
  B         Number(8);
  C         Number(8);
  D         Number(8);
  E         Number(8);
  F         Number(8);
  ---
  AA        Varchar2(5);
  BB        Varchar2(5);
  CC        Varchar2(5);
  DD        Varchar2(5);
  EE        Varchar2(5);
  FF        Varchar2(5);
  ---
begin
  Open c1;
    Fetch c1 Into A;
  Close c1;
  Open c2;
    Fetch c2 Into B;
  Close c2;
  Open c3;
    Fetch c3 Into C;
  Close c3;
  Open c4;
    Fetch c4 Into D;
  Close c4;
  Open c5;
    Fetch c5 Into E;
  Close c5;
  Open c6;
    Fetch c6 Into F;
  Close c6;
  if A = 0 then
       AA := 'OK';
  else
       AA := 'NO';
  end if;
  if B = 0 then
     BB := 'OK';
  else
     BB := 'NO';
  end if;
  if C = 0 then
     CC := 'OK';
  else
     CC := 'NO';
  end if;
  if D = 0 then
     DD := 'OK';
  else
     DD := 'NO';
  end if;
  if E = 0 then
     EE := 'OK';
  else
     EE := 'NO';
  end if;
  if F = 0 then
    FF := 'OK';
  else
    FF := 'NO';
  end if;
  dbms_OutPut.Put_Line('--   '||'Tablespace in Backup Mode = 0 '||Lpad(AA,5)||' - '||Lpad(To_Char(A),5));
  dbms_OutPut.Put_Line('--   '||'Tablespace > 95%              '||Lpad(BB,5)||' - '||Lpad(To_Char(B),5));
  dbms_OutPut.Put_Line('--   '||'Objects Invalid = 0           '||Lpad(CC,5)||' - '||Lpad(To_Char(C),5));
  dbms_OutPut.Put_Line('--   '||'Indexes unusable = 0          '||Lpad(DD,5)||' - '||Lpad(To_Char(D),5));
  dbms_OutPut.Put_Line('--   '||'Trigger Disabled = 0          '||Lpad(EE,5)||' - '||Lpad(To_Char(E),5));
  dbms_OutPut.Put_Line('--   '||'Constraint Disabled = 0       '||Lpad(FF,5)||' - '||Lpad(To_Char(F),5));
end;
/



declare
  cursor c1 is
         select count(*)
         from dba_segments
         where max_extents-extents < 10 AND
         segment_type <> 'CACHE';
  ---
  cursor c2 is
         select count(*)
         from sys.dba_segments a
         where a.tablespace_name not like 'T%MP%'
         and next_extent * 2 > (
                  select max(b.bytes)
                  from dba_free_space b
                  where a.tablespace_name = b.tablespace_name);
  ---
  cursor c3 is
         select count(*)
         from sys.dba_segments
         where owner not in ('PUBLIC','WKSYS','MDSYS','TSMSYS','CTXSYS','OLAPSYS','EXFSYS','ORDSYS','SYSMAN','SYS','WMSYS','SYSTEM','OUTLN','DBSNMP')
         and tablespace_name = 'SYSTEM';
  ---
  cursor c4 is
select count(*)
from
( select substr(a.table_name,1,30) table_name,
                 substr(a.constraint_name,1,30) constraint_name,
             max(decode(position, 1,     substr(column_name,1,30),NULL)) ||
             max(decode(position, 2,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position, 3,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position, 4,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position, 5,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position, 6,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position, 7,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position, 8,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position, 9,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position,10,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position,11,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position,12,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position,13,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position,14,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position,15,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position,16,', '||substr(column_name,1,30),NULL)) columnsx
    from dba_cons_columns a, dba_constraints b
   where a.constraint_name = b.constraint_name
     and b.constraint_type = 'R'
     and b.owner not in ('PUBLIC','WKSYS','MDSYS','TSMSYS','CTXSYS','OLAPSYS','EXFSYS','ORDSYS','SYSMAN','SYS','WMSYS','SYSTEM','OUTLN','DBSNMP')
   group by substr(a.table_name,1,30), substr(a.constraint_name,1,30) ) a,
( select substr(table_name,1,30) table_name, substr(index_name,1,30) index_name,
             max(decode(column_position, 1,     substr(column_name,1,30),NULL)) ||
             max(decode(column_position, 2,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position, 3,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position, 4,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position, 5,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position, 6,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position, 7,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position, 8,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position, 9,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position,10,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position,11,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position,12,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position,13,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position,14,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position,15,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position,16,', '||substr(column_name,1,30),NULL)) columnsx
    from dba_ind_columns
   group by substr(table_name,1,30), substr(index_name,1,30) ) b
where a.table_name = b.table_name (+)
  and b.columnsx (+) like a.columnsx || '%'
  and b.table_name is null;
  A         Number(8);
  B         Number(8);
  C         Number(8);
  D         Number(8);
  ---
  AA        Varchar2(5);
  BB        Varchar2(5);
  CC        Varchar2(5);
  DD        Varchar2(5);
  ---
begin
  Open c1;
    Fetch c1 Into A;
  Close c1;
  Open c2;
    Fetch c2 Into B;
  Close c2;
  Open c3;
    Fetch c3 Into C;
  Close c3;
  Open c4;
    Fetch c4 Into D;
  Close c4;
  if A = 0 then
       AA := 'OK';
  else
       AA := 'NO';
  end if;
  if B = 0 then
     BB := 'OK';
  else
     BB := 'NO';
  end if;
  if C = 0 then
     CC := 'OK';
  else
     CC := 'NO';
  end if;
  if D = 0 then
     DD := 'OK';
  else
     DD := 'NO';
  end if;
  dbms_OutPut.Put_Line('--   '||'Objects close max extents = 0 '||Lpad(AA,5)||' - '||Lpad(To_Char(A),5));
  dbms_OutPut.Put_Line('--   '||'Objects can not extent = 0    '||Lpad(BB,5)||' - '||Lpad(To_Char(B),5));
  dbms_OutPut.Put_Line('--   '||'User Objects on Systems = 0   '||Lpad(CC,5)||' - '||Lpad(To_Char(C),5));
  dbms_OutPut.Put_Line('--   '||'FK Without Index = 0          '||Lpad(DD,5)||' - '||Lpad(To_Char(D),5));
end;
/


prompt ---

prompt -- ----------------------------------------------------------------------- ---

prompt --   Datagard  CheckList                                                   ---

prompt -- ----------------------------------------------------------------------- ---

prompt ---


declare
  cursor c1 is
       select count(*)
       FROM gv$dataguard_status
       WHERE severity IN ('Error','Fatal');
  ---
  cursor c2 is
       select count(*)
       FROM v$archive_gap;
  ---
  cursor c3 is
       select max(sequence#) from v$archived_log  where applied = 'YES';
  ---
  cursor c4 is
       select max(sequence#) from v$archived_log;
  ---
  cursor c5 is
       select value from v$parameter where name = 'log_archive_dest_1';
  ---
  cursor c6 is
       select to_number(substr(version,1,3)) from v$instance;
  ---
  A         Number(8);
  B         Number(8);
  C         Number(10);
  D         Number(10);
  E         Number(10);
  F         Number(8,2);
  ---
  AA        Varchar2(5);
  BB        Varchar2(5);
  CC        Varchar2(5);
  DD        Varchar2(5);
  EE        Varchar2(500);
  ---
begin
  Open c1;
    Fetch c1 Into A;
  Close c1;
  Open c2;
    Fetch c2 Into B;
  Close c2;
  Open c3;
    Fetch c3 Into C;
  Close c3;
  Open c4;
    Fetch c4 Into D;
  Close c4;
  Open c5;
    Fetch c5 Into EE;
  Close c5;
  Open c6;
    Fetch c6 Into F;
  Close c6;
  if A = 0 then
       AA := 'OK';
  elsif A is null then
       AA := 'OK';
       A  := 0;
  else
       AA := 'NO';
  end if;
  if B = 0 then
     BB := 'OK';
  elsif B is null then
     BB := 'OK';
     B  := 0;
  else
     BB := 'NO';
  end if;
  if D is null then
     D := 0;
  end if;
  if C is null then
     C := 0;
  end if;
  E := ( D - C);
  if E <= 5 then
     CC := 'OK';
  else
     CC := 'NO';
  end if;
  if EE is not null and F >= 9 then
     dbms_OutPut.Put_Line('--   '||'Datagard Errors = 0           '||Lpad(AA,5)||' - '||Lpad(To_Char(A),5));
     dbms_OutPut.Put_Line('--   '||'Datagard Gap = 0              '||Lpad(BB,5)||' - '||Lpad(To_Char(B),5));
     dbms_OutPut.Put_Line('--   '||'Archives not Aplied < 5       '||Lpad(CC,5)||' - '||Lpad(To_Char(E),5));
     dbms_OutPut.Put_Line('--   '||'Last Archive Aplied              '||to_char(C));
     dbms_OutPut.Put_Line('--   '||'Last Archive Generated           '||to_char(D));
  else
     dbms_OutPut.Put_Line('--   '||'No Datagard Available or Database version is not supported for this check!');     
  end if;
end;
/

prompt

prompt -- ---------------------------------------------------------------------- ---

prompt --   Oracle Components Status :

prompt -- ---------------------------------------------------------------------- ---

column comp_id        heading "Id"              format A12
column status         heading "status"          format A12
column version        heading "version"         format A10
column comp_name      heading "Component"       format A40

select substr(comp_id,1,12) comp_id, status, substr(version,1,10) version, substr(comp_name,1,40) comp_name 
from dba_registry order by 1;


prompt

prompt -- ---------------------------------------------------------------------- ---

prompt --   Installed options :

prompt -- ---------------------------------------------------------------------- ---


select
       '    - ' || parameter || ' option'
  from
       sys.v_$option
 where
       value = 'TRUE'
;


set head on

Prompt

set feedback on


-- ----------------------------------------------------------------------- ---
--   V$Recovery_Log Status                                                 ---
-- ----------------------------------------------------------------------- ---

column Thread#         format 9999999    heading  "Thread"
column Sequence#       format 9999999    heading  "Sequence"
column archive_name    format A60 wrap   heading  "Archive|Name"
column Time                              heading  "Time"

select
       *
  from
       v$recovery_log
 order
    by thread#
;


-- ----------------------------------------------------------------------- ---
--   V$Recover_File Status                                                 ---
-- ----------------------------------------------------------------------- ---

column file#           format 9999999    heading  "File#"
column online          format A10        heading  "Online"
column online_status   format A10        heading  "Online|Status"
column error           format A20 wrap   heading  "Error"
column change          format 99999      heading  "Change"
column Time                              heading  "Time"

select
       *
  from
       v$recover_file
 order
    by file#
;


-- ----------------------------------------------------------------------- ---
--   V$Log Status                                                          ---
-- ----------------------------------------------------------------------- ---

Declare
  --
  Cursor Cur_Req Is
     select
            'X'
       from
            v$log
      where
            status not in ('ACTIVE', 'CURRENT', 'INACTIVE')
     ;
  --
  X   Varchar2(1);
  --
Begin
  --
  X := Null;
  --
  Open Cur_Req;
    Fetch Cur_Req Into X;
  Close Cur_Req;
  --
  If X Is Not Null Then
    Dbms_OutPut.Put_Line('--                                                                         ---');
    Dbms_OutPut.Put_Line('-- ----------------------------------------------------------------------- ---');
    Dbms_OutPut.Put_Line('--   V$Log Status                                                          ---');
    Dbms_OutPut.Put_Line('-- ----------------------------------------------------------------------- ---');
  End If;
  --
End;
/

clear breaks
break on redogroup -
skip 1

column redogroup       format 99999      heading  "Group"
column redothread      format 99999      heading  "Thread"
column redosequence    format 999999     heading  "Sequence"
column file_name       format A55        heading  "RedoLog Name"
column KB              format 99999999B  heading  "Size|(Kb)"
column status          format A5         heading  "Stat."        Trunc

select
       lf.group#     redogroup
     , l.thread#     redothread
     , l.sequence#   redosequence
     , lf.member     file_name
     , l.bytes/1024  Kb
     , l.status      status
  from
       v$logfile lf
     , v$log     l
 where
       l.group#  =  lf.group#
   and
       l.status not in ('ACTIVE', 'CURRENT', 'INACTIVE')
 order
    by lf.group#
     , l.thread#
     , l.sequence#
     , lf.member
;

clear breaks


-- ----------------------------------------------------------------------- ---
--   V$Tempfile Status                                                     ---
-- ----------------------------------------------------------------------- ---

Declare
  --
  Cursor Cur_Req Is
     select
            'X'
       from
            v$tempfile
      where
            status not in ('ONLINE', 'SYSTEM')
     ;
  --
  X   Varchar2(1);
  --
Begin
  --
  X := Null;
  --
  Open Cur_Req;
    Fetch Cur_Req Into X;
  Close Cur_Req;
  --
  If X Is Not Null Then
    Dbms_OutPut.Put_Line('--                                                                         ---');
    Dbms_OutPut.Put_Line('-- ----------------------------------------------------------------------- ---');
    Dbms_OutPut.Put_Line('--   V$Tempfile Status                                                     ---');
    Dbms_OutPut.Put_Line('-- ----------------------------------------------------------------------- ---');
  End If;
  --
End;
/

clear breaks
break on status skip 1


column name        format a60 wrap          heading "DataFile Name"

select
       name
     , status
  from
       V$tempfile
 where
       status not in ('ONLINE', 'SYSTEM')
 Order
    By Status
     , Name
;

clear breaks


-- ----------------------------------------------------------------------- ---
--   V$Datafile Status                                                     ---
-- ----------------------------------------------------------------------- ---

Declare
  --
  Cursor Cur_Req Is
     select
            'X'
       from
            v$datafile
      where
            status not in ('ONLINE', 'SYSTEM')
     ;
  --
  X   Varchar2(1);
  --
Begin
  --
  X := Null;
  --
  Open Cur_Req;
    Fetch Cur_Req Into X;
  Close Cur_Req;
  --
  If X Is Not Null Then
    Dbms_OutPut.Put_Line('--                                                                         ---');
    Dbms_OutPut.Put_Line('-- ----------------------------------------------------------------------- ---');
    Dbms_OutPut.Put_Line('--   V$Datafile Status                                                     ---');
    Dbms_OutPut.Put_Line('-- ----------------------------------------------------------------------- ---');
  End If;
  --
End;
/

clear breaks
break on status skip 1


column name        format a60 wrap          heading "DataFile Name"

select
       name
     , status
  from
       V$datafile
 where
       status not in ('ONLINE', 'SYSTEM')
 Order
    By Status
     , Name
;

clear breaks


-- ----------------------------------------------------------------------- ---
--   Dba_Tablespaces Status                                                ---
-- ----------------------------------------------------------------------- ---

Declare
  --
  Cursor Cur_Req Is
     select
            'X'
       from
            dba_tablespaces
      where
            status not in ('ONLINE', 'READ ONLY')
     ;
  --
  X   Varchar2(1);
  --
Begin
  --
  X := Null;
  --
  Open Cur_Req;
    Fetch Cur_Req Into X;
  Close Cur_Req;
  --
  If X Is Not Null Then
    Dbms_OutPut.Put_Line('--                                                                         ---');
    Dbms_OutPut.Put_Line('-- ----------------------------------------------------------------------- ---');
    Dbms_OutPut.Put_Line('--   Dba_Tablespaces Status                                                ---');
    Dbms_OutPut.Put_Line('-- ----------------------------------------------------------------------- ---');
  End If;
  --
End;
/

column tblsp         format a20 wrap          heading  "Tablespace Name"
column contents      format a10               heading  "Content"

clear breaks
break on contents -
skip 1

select
       contents
     , tablespace_name tblsp
     , status
  from
       dba_tablespaces
 where
       status not in ('ONLINE', 'READ ONLY')
 order
    by contents
;


-- ----------------------------------------------------------------------- ---
--   Tablespaces Backup Mode                                               ---
-- ----------------------------------------------------------------------- ---

Declare
  --
  Cursor Cur_Req Is
     select
            'X'
       from
            v$backup bck
          , dba_data_files df
      where
            bck.file# = df.file_id
        and
            bck.status  !=  'NOT ACTIVE'
        and
            'ARCHIVELOG' = (select log_mode from v$database);
  --
  X   Varchar2(1);
  --
Begin
  --
  X := Null;
  --
  Open Cur_Req;
    Fetch Cur_Req Into X;
  Close Cur_Req;
  --
  If X Is Not Null Then
    Dbms_OutPut.Put_Line('--                                                                         ---');
    Dbms_OutPut.Put_Line('-- ----------------------------------------------------------------------- ---');
    Dbms_OutPut.Put_Line('-- Tablespaces in Backup Mode                                              ---');
    Dbms_OutPut.Put_Line('-- ----------------------------------------------------------------------- ---');
  End If;
  --
End;
/

column tablespace_name  format a18 wrap             heading "Tablespace Name"
column file_name        format a50 wrap             heading "DataFile Name"
column status           format a12 wrap             heading "Status"
column change#          format 999999999999         heading "Change"
column time             format a18 wrap             heading "Time"

select
       df.tablespace_name
     , df.file_name
     , bck.status
     , bck.change#
     , To_Char(bck.time,'DD-MM-YYYY HH24:MI') time
  from
       v$backup bck
     , dba_data_files df
 where
       bck.file# = df.file_id
   and
       bck.status  !=  'NOT ACTIVE'
   and
       'ARCHIVELOG' = (select log_mode from v$database)
 order
    by df.tablespace_name
     , df.file_name
;


-- ----------------------------------------------------------------------- ---
--   Lock list                                                             ---
-- ----------------------------------------------------------------------- ---

Declare
  --
  Cursor Cur_Req Is
     select
            'X'
       from
            v$session s
          , v$process p
          , v$lock l
          , dba_objects o
      where
            s.paddr = p.addr
        And
            l.sid=s.sid
        And
            l.id1 = o.object_id
        And
            s.username is NOT NULL
        And
            l.ctime > 60
     ;
  --
  X   Varchar2(1);
  --
Begin
  --
  X := Null;
  --
  Open Cur_Req;
    Fetch Cur_Req Into X;
  Close Cur_Req;
  --
  If X Is Not Null Then
    Dbms_OutPut.Put_Line('--                                                                         ---');
    Dbms_OutPut.Put_Line('-- ----------------------------------------------------------------------- ---');
    Dbms_OutPut.Put_Line('-- Lock list                                                               ---');
    Dbms_OutPut.Put_Line('-- ----------------------------------------------------------------------- ---');
  End If;
  --
End;
/

column username    heading "Utilis."         format A15
column sid         heading "Id"              format 9999
column spid        heading "Unix"            format A7
column state       heading "Etat"            format A15
column Lmode_H     heading "Lock mode"       format A15
column terminal    heading "Terminal"        format A10
column command     heading "C"               format 99
Column serial#     heading "Serial#"         format 99999
column ctime       heading "Duration"        format 999999
column logon       heading "Date Connexion"  format A16
column object_name heading "Object Name"     format A18

select
       s.sid
     , s.serial#
     , p.spid
     , substr(s.username,1,15) username
     , s.terminal
     , l.type
     , to_char(s.logon_time,'DD-MM-YYYY HH24:MI') logon
     , decode(l.lmode, 1,'null'                 , 2,'Row share'
                     , 3,'Row Exclusive'                , 4,'Share'
                     , 5,'Share Row Excl.'      , 6,'Exclusive') Lmode_H
     , o.object_name
     , Round(ctime/60) ctime
  from
       v$session s
     , v$process p
     , v$lock l
     , dba_objects o
 where
       s.paddr = p.addr
   And
       l.sid=s.sid
   And
       l.id1 = o.object_id
   And
       s.username is NOT NULL
   And
       l.ctime > 60
;


prompt

prompt -- ----------------------------------------------------------------------- ---

prompt --   Tablespaces                                                           ---

prompt -- ----------------------------------------------------------------------- ---



-- Set Heading  Off
-- Set Termout  Off

-- Column Var_DB_BLOCK_SIZE new_value Var_DB_BLOCK_SIZE noprint

-- Select
--       value Var_DB_BLOCK_SIZE
--  from
--      v$parameter
-- where
--       Upper(name) = Upper ('db_block_size')
--;

--Set Termout  On
--Set Heading  On



--clear breaks
--break on contents -
--skip 1
--compute Sum of alloc used free nbfrag on contents


--column tblsp         format a20 wrap          heading  "Tablespace Name"
--column Alloc         format 999,999           heading  "Alloc|(Mb)"
--column Free          format 999,999           heading  "Free|(Mb)"
--column used          format 999,999           heading  "Used|(Mb)"
--column pused         format 990.9             heading  "%|Used|Space"
--column fragmax       format 99,999.9          heading  "Largest|Free|Ext.(Mb)"
--column nbfrag        format 99999             heading  "Nb|frag"
--column contents      format a10               heading  "Content"
--column pct_ext_coal  format 999                     heading  "% Ext.|Coal."
--column ext_manage    format a7 wrap           heading  "Ext.|M."
--column autoext       format a7 wrap           heading  "Auto|Ext."


--select
--       contents
--     , nvl (dt.tablespace_name, nvl (fsp.tablespace_name, 'Unknown')) tblsp
--     , alloc
--     , alloc - nvl (free, 0)       Used
--     , nvl (free, 0)               Free
--     , ((alloc - nvl (free, 0)) / alloc) * 100  pused
--     , nbfrag
--     , fragmax
--     , dfsc.pct_ext_coal pct_ext_coal
--     , dt.ext_manage
--     , df.inc                           autoext
--  from
--       ( select sum (bytes)/1048576     free
--              , max (bytes)/1048576     fragmax
--              , tablespace_name
--              , count(*)                nbfrag
--          from  sys.dba_free_space
--         group  by tablespace_name
--       ) fsp
--    ,  ( select sum(bytes)/1048576      alloc
--              , tablespace_name
--              , Decode(((inc * &Var_DB_BLOCK_SIZE)/1024), Null, 'No', 'Yes')     inc
--           from sys.dba_data_files sddf
--              , sys.filext$        aut
--          where sddf.file_id       =  aut.file#   (+)
--          group by tablespace_name
--                 , Decode(((inc * &Var_DB_BLOCK_SIZE)/1024), Null, 'No', 'Yes')
--          Union
--          select sum(bytes)/1048576      alloc
--               , tablespace_name
--               , Decode(((increment_by * &Var_DB_BLOCK_SIZE)/1024), Null, 'No', 'Yes')    inc
--            from sys.dba_temp_files sddf
--           group by tablespace_name
--                  , Decode(((increment_by * &Var_DB_BLOCK_SIZE)/1024), Null, 'No', 'Yes')
--       ) df
--    ,  ( select contents
--              , tablespace_name
--              , initial_extent/1024     initial_ext
--              , next_extent/1024        next_ext
--              , pct_increase
--              , max_extents
--              , min_extents
--              , Substr(extent_management,1,5)       ext_manage
--           from dba_tablespaces
--       ) dt
--     , ( select percent_extents_coalesced    pct_ext_coal
--              , tablespace_name
--           from dba_free_space_coalesced
--       ) dfsc
-- where
--       fsp.tablespace_name  (+)   =   dt.tablespace_name
--   and
--       df.tablespace_name   (+)   =   dt.tablespace_name
--   and
--       dfsc.tablespace_name (+)   =   dt.tablespace_name
-- order
--    by contents
--     , pused desc
--;


Prompt

PROMPT
PROMPT ******************************************** INVALID OBJECTS BY TYPE

BREAK ON REPORT
COMPUTE SUM LABEL TOTAL of quantity ON REPORT

SELECT object_type, COUNT(*) quantity
FROM dba_objects
WHERE status = 'INVALID'
GROUP BY object_type;

CLEAR BREAKS
CLEAR COMPUTES

PROMPT
PROMPT ******************************************** INVALID OBJECTS BY TYPE AND OWNER

SELECT owner, object_type, COUNT(*) quantity
FROM dba_objects
WHERE status = 'INVALID'
GROUP BY owner, object_type;

PROMPT
PROMPT ******************************************** MODIFIED OBJECTS IN THE LAST 7 DAYS

SELECT owner||'.'||object_name objet, object_type, created, last_ddl_time modified, ROUND(sysdate - last_ddl_time,2) days
FROM dba_objects
WHERE sysdate - last_ddl_time < 7 AND
      subobject_name IS NULL
ORDER BY created DESC;

PROMPT
PROMPT ******************************************** UNUSABLE INDEXES

SELECT owner||'.'||index_name indice
FROM dba_indexes
WHERE status = 'UNUSABLE'
ORDER BY 1;

SELECT index_owner||'.'||index_name||'.'||partition_name partition
FROM dba_ind_partitions
WHERE status = 'UNUSABLE'
ORDER BY 1;

PROMPT
PROMPT ******************************************** DISABLED TRIGGERS

SELECT owner||'.'||trigger_name "TRIGGER", triggering_event, table_owner||'.'||table_name, status
FROM dba_triggers
WHERE status = 'DISABLED';

PROMPT
PROMPT ******************************************** DISABLED CONSTRAINTS

SELECT constraint_name constraint, constraint_type, owner||'.'||table_name, status
FROM dba_constraints
WHERE status = 'DISABLED' and constraint_type<>'S';

PROMPT
PROMPT ******************************************** ANALIZED TABLES

SELECT owner, NVL(TO_CHAR(TRUNC(last_analyzed),'dd-mm-yyyy'), 'Never Analyzed') last_analyzed, COUNT(*) quantity
FROM dba_tables
GROUP BY owner, TRUNC(last_analyzed)
ORDER BY 1,2;

PROMPT
PROMPT ******************************************** ANALYZED INDEXES

SELECT owner, NVL(TO_CHAR(TRUNC(last_analyzed),'dd-mm-yyyy'), 'Never Analyzed') last_analyzed, COUNT(*) quantity
FROM dba_indexes
GROUP BY owner, TRUNC(last_analyzed)
ORDER BY 1,2;

PROMPT
PROMPT ******************************************** TABLESPACES WITH LESS THAN 15% FREE

SELECT a.tblspc tablespace, a.fbytes TOTAL, NVL(u.ebytes,0) RESERVED, a.fbytes-NVL(u.ebytes,0) FREE, 100*NVL(u.ebytes,0)/a.fbytes "% RESERVED"
FROM (SELECT tablespace_name tblspc, SUM(bytes)/1024/1024 ebytes FROM dba_segments GROUP BY tablespace_name) u,
     (SELECT tablespace_name tblspc, SUM(bytes)/1024/1024 fbytes FROM dba_data_files GROUP BY tablespace_name) a
WHERE u.tblspc(+) = a.tblspc AND
      100*NVL(u.ebytes,0)/a.fbytes > 85.00
ORDER BY tablespace;

PROMPT
PROMPT ******************************************** OBJECTS CLOSE TO MAX EXTENTS

SELECT tablespace_name tablespace, segment_type tipo, owner||'.'||segment_name segment, extents, bytes/1024/1024 mb,
       max_extents
FROM dba_segments
WHERE max_extents-extents < 10 AND
      segment_type <> 'CACHE'
ORDER BY 1,2,3,4;

PROMPT
PROMPT ******************************************** OBJECTS THAT CAN.T EXTENT

prompt Objects that cannot extend (no space in TS)

column Sname form a40    heading 'Object Name'
column Stype form a15    heading 'Type'
column Size  form 9,999  heading 'Size'
column Next  form 99,999 heading 'Next'
column Tname form a15    heading 'TsName'

select a.owner||'.'||a.segment_name "Sname",
       a.segment_type               "Stype",
       a.bytes/1024/1024            "Size",
       a.next_extent/1024/1024 "Next",
       a.tablespace_name "TName"
  from sys.dba_segments a
 where a.tablespace_name not like 'T%MP%'   -- Exclude TEMP tablespaces
   and next_extent * 2 > (                  -- Cannot extend 1x, can change to 2x...
                           select max(b.bytes)
                             from dba_free_space b
                            where a.tablespace_name = b.tablespace_name)
order by 3 desc
/

PROMPT
PROMPT ******************************************** OBJECTS IN THE SYSTEM TABLESPACE

select owner, substr(segment_name,1,25) segment , substr(partition_name,1,25) partition, segment_type
from sys.dba_segments
where owner not in ('PUBLIC','WKSYS','MDSYS','TSMSYS','CTXSYS','OLAPSYS','EXFSYS','ORDSYS','SYSMAN','SYS','WMSYS','SYSTEM','OUTLN','DBSNMP')
and tablespace_name = 'SYSTEM';

PROMPT
PROMPT ******************************************** FOREIGN KEYS WITHOUT INDEXES

column columns format a20 word_wrapped
column table_name format a30 word_wrapped

select decode( b.table_name, NULL, '****', 'ok' ) Status,
           a.table_name table_name, a.columns, b.columns
from
( select substr(a.table_name,1,30) table_name,
                 substr(a.constraint_name,1,30) constraint_name,
             max(decode(position, 1,     substr(column_name,1,30),NULL)) ||
             max(decode(position, 2,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position, 3,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position, 4,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position, 5,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position, 6,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position, 7,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position, 8,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position, 9,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position,10,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position,11,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position,12,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position,13,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position,14,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position,15,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position,16,', '||substr(column_name,1,30),NULL)) columns
    from dba_cons_columns a, dba_constraints b
   where a.constraint_name = b.constraint_name
     and b.constraint_type = 'R'
     and b.owner not in ('PUBLIC','WKSYS','MDSYS','TSMSYS','CTXSYS','OLAPSYS','EXFSYS','ORDSYS','SYSMAN','SYS','WMSYS','SYSTEM','OUTLN','DBSNMP')
   group by substr(a.table_name,1,30), substr(a.constraint_name,1,30) ) a,
( select substr(table_name,1,30) table_name, substr(index_name,1,30) index_name,
             max(decode(column_position, 1,     substr(column_name,1,30),NULL)) ||
             max(decode(column_position, 2,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position, 3,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position, 4,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position, 5,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position, 6,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position, 7,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position, 8,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position, 9,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position,10,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position,11,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position,12,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position,13,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position,14,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position,15,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position,16,', '||substr(column_name,1,30),NULL)) columns
    from dba_ind_columns
   group by substr(table_name,1,30), substr(index_name,1,30) ) b
where a.table_name = b.table_name (+)
  and b.columns (+) like a.columns || '%'
  and b.table_name is null
order by 1 desc
/

PROMPT
PROMPT ******************************************** DATAGUARD STATE (CRITICAL MESSAGES)

SELECT inst_id, facility, severity, dest_id, error_code, callout, timestamp, message
FROM gv$dataguard_status
WHERE severity IN ('Error','Fatal')
ORDER BY timestamp;

PROMPT
PROMPT ******************************************** NO APLIED ARCHIVELOGS

selecT sequence#,substr(a.name,1,46) archivelog, a.blocks, a.archived, a.applied, a.status, a.end_of_redo eor, a.standby_dest, a.first_time, a.completion_time completion, SYSDATE time
From    v$archived_log a
WHERE   a.sequence# between (select max(b.sequence#) from v$archived_log b where b.applied = 'YES') and (select max(c.sequence#) from v$archived_log c)
/

PROMPT
PROMPT ******************************************** GAP SEQUENCE

SELECT * FROM v$archive_gap;

PROMPT
PROMPT ******************************************** DIFERENCE ON RECEPTION

SELECT thread#, MAX(next_time) next_time, SYSDATE time, ROUND((SYSDATE - MAX(next_time))*24,2) horas, ROUND((SYSDATE - MAX(next_time))*24*60,0) minutos
FROM v$archived_log
GROUP BY thread#;

PROMPT
PROMPT ******************************************** DIFERENCE TO APPLY

SELECT thread#, MAX(next_time) next_time, SYSDATE time, ROUND((SYSDATE - MAX(next_time))*24,2) horas, ROUND((SYSDATE - MAX(next_time))*24*60,0) minutos
FROM v$archived_log
WHERE applied='YES'
GROUP BY thread#;

PROMPT
PROMPT ******************************************** PROCESSES

SELECT inst_id, process, pid, status, substr(to_char(group#),1,8) group#, thread#, sequence#, block#, blocks, delay_mins, known_agents, active_agents, client_process
FROM gv$managed_standby;

PROMPT



set heading on
set echo off
set linesize 150
set pagesize 500
column day format a16  heading 'Day'
column d_0 format a3  heading '00'
column d_1 format a3  heading '01'
column d_2 format a3  heading '02'
column d_3 format a3  heading '03'
column d_4 format a3  heading '04'
column d_5 format a3  heading '05'
column d_6 format a3  heading '06'
column d_7 format a3  heading '07'
column d_8 format a3  heading '08'
column d_9 format a3  heading '09'
column d_10 format a3  heading '10'
column d_11 format a3  heading '11'
column d_12 format a3  heading '12'
column d_13 format a3  heading '13'
column d_14 format a3  heading '14'
column d_15 format a3  heading '15'
column d_16 format a3  heading '16'
column d_17 format a3  heading '17'
column d_18 format a3  heading '18'
column d_19 format a3  heading '19'
column d_20 format a3  heading '20'
column d_21 format a3  heading '21'
column d_22 format a3  heading '22'
column d_23 format a3  heading '23'
column  Total   format 9999
column status  format a8
column member  format a40
column archived heading 'Archived' format a8
column bytes heading 'Bytes|(MB)' format 9999
Ttitle  'Log Info'  skip 2
select l.group#,f.member,l.archived,l.bytes/1078576 bytes,l.status,f.type
  from v$log l, v$logfile f
 where l.group# = f.group#
/
Ttitle off
prompt =========================================================================================================================
Ttitle  'Log Switch on hour basis'  skip 2

select to_char(FIRST_TIME,'DY, DD-MON-YYYY') day,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'00',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'00',1,0))) d_0,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'01',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'01',1,0))) d_1,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'02',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'02',1,0))) d_2,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'03',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'03',1,0))) d_3,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'04',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'04',1,0))) d_4,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'05',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'05',1,0))) d_5,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'06',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'06',1,0))) d_6,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'07',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'07',1,0))) d_7,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'08',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'08',1,0))) d_5,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'09',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'09',1,0))) d_9,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'10',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'10',1,0))) d_10,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'11',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'11',1,0))) d_11,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'12',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'12',1,0))) d_12,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'13',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'13',1,0))) d_13,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'14',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'14',1,0))) d_14,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'15',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'15',1,0))) d_15,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'16',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'16',1,0))) d_16,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'17',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'17',1,0))) d_17,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'18',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'18',1,0))) d_18,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'19',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'19',1,0))) d_19,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'20',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'20',1,0))) d_20,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'21',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'21',1,0))) d_21,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'22',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'22',1,0))) d_22,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'23',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'23',1,0))) d_23,
       count(trunc(FIRST_TIME)) Total
 from v$log_history
 group by to_char(FIRST_TIME,'DY, DD-MON-YYYY')
 order by to_date(substr(to_char(FIRST_TIME,'DY, DD-MON-YYYY'),5,15) )
/

select * from v$license;
select banner from v$version where BANNER like '%Edition%';
select decode(count(*), 0, 'No', 'Yes') Partitioning
from ( select 1 
       from dba_part_tables
       where owner not in ('SYSMAN', 'SH', 'SYS', 'SYSTEM')
         and rownum = 1 );
select decode(count(*), 0, 'No', 'Yes') Spatial
from ( select 1
       from all_sdo_geom_metadata 
       where rownum = 1 );
select decode(count(*), 0, 'No', 'Yes') RAC
from ( select 1 
       from v$active_instances 
       where rownum = 1 );
Set feedback off
Set linesize 122
Col name             format a45     heading "Feature"
Col version          format a10     heading "Version"
Col detected_usages  format 999,990 heading "Detected|usages"
Col currently_used   format a06     heading "Curr.|used?"
Col first_usage_date format a10     heading "First use"
Col last_usage_date  format a10     heading "Last use"
Col nop noprint
Break on nop skip 1 on name
Select decode(detected_usages,0,2,1) nop,
       name, version, detected_usages, currently_used,
       to_char(first_usage_date,'DD/MM/YYYY') first_usage_date, 
       to_char(last_usage_date,'DD/MM/YYYY') last_usage_date
from dba_feature_usage_statistics
order by nop, 1, 2
/
select comp_name,status,version from dba_registry;
!cat /proc/version >> checklist_&sid..txt
!cat /proc/cpuinfo >> checklist_&sid..txt
!cat /etc/redhat-release >> checklist_&sid..txt
Ttitle off
prompt
spool off
exit
