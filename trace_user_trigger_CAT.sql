################################################################################################
##### https://dbaclass.com/article/tracing-sessions-in-oracle/                              ####
################################################################################################
##### APROVEITA QUE TA VAZI . . .                                                           ####
################################################################################################
######   create or replace trigger SYS.BEGIN_FPS_AF_TRIGGER after logon on database
######   begin
######   if ( user = 'FPS_AF' )
######   then
######       execute immediate 'alter session set tracefile_identifier= ''O_GUINA_NAO_TINHA_DO''';
######       execute immediate 'alter session set timed_statistics=true';
######       execute immediate 'alter session set max_dump_file_size=unlimited';
######       execute immediate 'alter session set events ''10046 trace name context forever, level 12''';
######   END IF;	
######   end;
######   /
######   drop trigger SYS.BEGIN_FPS_AF_TRIGGER;
######   
######   
######   create or replace trigger SYS.END_FPS_AF_TRIGGER before logoff on database
######   begin
######   if ( user = 'FPS_AF' )
######   then
######        execute immediate 'alter session set events ''10046 trace name context off''';
######   END IF;	
######   end;
######   /
######   SELECT p.tracefile FROM   v$session s  JOIN v$process p ON s.paddr = p.addr WHERE tracefile LIKE '%GUINA%'
######   /
######   drop trigger SYS.END_FPS_AF_TRIGGER;
######   
######   
######   tkprof ppauto2_ora_3503_O_GUINA_NAO_TINHA_DO.trc result.txt sys=no waits=yes sort=exeela,fchel