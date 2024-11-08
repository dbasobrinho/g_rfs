--
set pages 5000
set lines 5000
col total_arch    format 999999
col THREAD#       for 99  head 'Thread'
col SEQUENCE#     for a9  head 'Sequence#'
col first_time    for a20 head 'First Time'
col name          for a20 head 'Name'

column autoextensible  format  a10       heading 'EXTENSIBLE' 
alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';

select trunc(COMPLETION_TIME,'DD') Day, thread#, 
round(sum(BLOCKS*BLOCK_SIZE)/1024/1024/1024) GB,
count(*) Archives_Generated from v$archived_log 
group by trunc(COMPLETION_TIME,'DD'),thread# order by 1
/

pause

set pages 1000

select trunc(COMPLETION_TIME,'HH') Hour,thread# , 
round(sum(BLOCKS*BLOCK_SIZE)/1024/1024/1024) GB,
count(*) Archives from v$archived_log 
group by trunc(COMPLETION_TIME,'HH'),thread#  order by 1
/

pause

select trunc(COMPLETION_TIME,'DD') Day, thread#, 
round(sum(BLOCKS*BLOCK_SIZE)/1024/1024/1024) GB,
count(*) Archives_Generated from v$archived_log 
group by trunc(COMPLETION_TIME,'DD'),thread# order by 1
/

