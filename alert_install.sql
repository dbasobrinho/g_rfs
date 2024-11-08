CREATE or replace VIEW v_alert_log AS SELECT * FROM x$dbgalertext;
CREATE or replace  PUBLIC SYNONYM v_alert_log FOR sys.v_alert_log; 
-- 1 = Trace, 2 = Alert, 3 Ambos
-- EXEC dbms_system.ksdwrt(3, 'ORA-00600: internal error code, arguments: Where is the malboro?'); 