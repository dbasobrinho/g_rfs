--
set pages 5000
set lines 5000
column scn     format a20

select to_char(timestamp_to_scn(to_timestamp(&SYSDATE))) as scn from dual
/
