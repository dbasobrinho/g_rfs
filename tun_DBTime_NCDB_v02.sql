-----------------------------------------------------------------------------
--
--
--  NAME
--    DBTime_NCDB.sql
--
--  DESCRIPTON
--    Relatorio DBTime diario para base não CDB
--
--  HISTORY
--    05/07/2022 => Valter Aquino 
--
-----------------------------------------------------------------------------

SET serveroutput ON SIZE 999999 
DECLARE
   cursor c_instance is
      SELECT instance_number, instance_name
        FROM v$instance
       ORDER BY 1;
   v_reg        VARCHAR2(120);
   v_hora_beg   VARCHAR2(2) := '08';
   v_hora_end   VARCHAR2(2) := '20';
BEGIN
 

   FOR v_instance IN c_instance LOOP
      DBMS_OUTPUT.PUT_LINE('==============================================================');
      DBMS_OUTPUT.PUT_LINE('= Instance_name: '||v_instance.instance_name||'      Instance_number: '||v_instance.instance_number||'            =');
      DBMS_OUTPUT.PUT_LINE('==============================================================');
      FOR l_counter IN 1..30 LOOP
         -- get dbtime day
         SELECT 'BEGIN_TIME: '||BEGIN_TIME||' END_TIME: '||END_TIME||' DBTIME_SEC: '||ROUND((DBTIME_SEC_END-DBTIME_SEC_BEG)/1000000) INTO v_reg
           FROM (SELECT to_char(s.begin_interval_time,'YYMMDD_HH24') BEGIN_TIME,
                        t.value AS DBTIME_SEC_BEG
                   FROM dba_hist_sys_time_model t,
                        dba_hist_snapshot s
                  WHERE t.snap_id=s.snap_id
				    and s.snap_id in (select min(z.snap_id) from dba_hist_snapshot z where to_char(z.begin_interval_time,'YYMMDD_HH24') = to_char(sysdate-l_counter,'YYMMDD_')||v_hora_beg)
                    AND t.instance_number=s.instance_number
                    AND t.instance_number = v_instance.instance_number
                    AND t.stat_name = 'DB time'
                    AND to_char(s.begin_interval_time,'YYMMDD_HH24') = to_char(sysdate-l_counter,'YYMMDD_')||v_hora_beg) dbi,
                (SELECT to_char(s.begin_interval_time,'YYMMDD_HH24') END_TIME,
                        t.value AS DBTIME_SEC_END
                   FROM dba_hist_sys_time_model t,
                        dba_hist_snapshot s
                  WHERE t.snap_id=s.snap_id
				  and s.snap_id in (select max(z.snap_id) from dba_hist_snapshot z where to_char(z.begin_interval_time,'YYMMDD_HH24') = to_char(sysdate-l_counter,'YYMMDD_')||v_hora_end)
                    AND t.instance_number=s.instance_number
                    AND t.instance_number = v_instance.instance_number
                    AND t.stat_name = 'DB time'
                 AND to_char(s.begin_interval_time,'YYMMDD_HH24') = to_char(sysdate-l_counter,'YYMMDD_')||v_hora_end) dbf;
         DBMS_OUTPUT.PUT_LINE(v_reg);
      END LOOP;
   END LOOP;
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/