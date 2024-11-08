--
set pages 5000
set lines 5000
column date_scn     format a20
column current_scn  format a20
 select to_char(scn_to_timestamp(a.current_scn),'dd/mm/yyyy hh24:mi:ss') as date_scn 
      , to_char(a.current_scn) current_scn
 from v$database a
/

