SET SERVEROUTPUT ON
COL "SID/SERIAL@I" FORMAT A15 HEADING "SID/SERIAL@I"

DECLARE
   v_total_pga_inuse_mb      NUMBER;
   v_pga_aggregate_limit_mb  NUMBER;
   v_percentage_used         NUMBER;
BEGIN
   -- Consulta o total de PGA em uso (em MB)
   SELECT ROUND(SUM(VALUE) / (1024 * 1024), 2)
   INTO v_total_pga_inuse_mb
   FROM GV$PGASTAT
   WHERE NAME = 'total PGA inuse';

   -- Consulta o limite de PGA configurado (em MB)
   SELECT ROUND(VALUE / (1024 * 1024), 2)
   INTO v_pga_aggregate_limit_mb
   FROM GV$PARAMETER
   WHERE NAME = 'pga_aggregate_limit';

   -- Calcula o percentual de uso
   v_percentage_used := ROUND((v_total_pga_inuse_mb / v_pga_aggregate_limit_mb) * 100, 2);

   -- Exibe métricas gerais de PGA
   DBMS_OUTPUT.PUT_LINE('+---------------------------+---------------------+');
   DBMS_OUTPUT.PUT_LINE('| Métrica                  | Valor (MB)           |');
   DBMS_OUTPUT.PUT_LINE('+---------------------------+---------------------+');
   DBMS_OUTPUT.PUT_LINE('| Total PGA em uso         | ' || LPAD(TO_CHAR(v_total_pga_inuse_mb, 'FM999999990.00'), 19) || '  |');
   DBMS_OUTPUT.PUT_LINE('| PGA_AGGREGATE_LIMIT      | ' || LPAD(TO_CHAR(v_pga_aggregate_limit_mb, 'FM999999990.00'), 19) || '  |');
   DBMS_OUTPUT.PUT_LINE('| Percentual de uso        | ' || LPAD(TO_CHAR(v_percentage_used, 'FM990.00') || '%', 19) || '  |');
   DBMS_OUTPUT.PUT_LINE('+---------------------------+---------------------+');

   DBMS_OUTPUT.PUT_LINE('-');
   DBMS_OUTPUT.PUT_LINE('As 5 sessões que mais estão utilizando PGA:');
    DBMS_OUTPUT.PUT_LINE('-');
   FOR rec IN (
      SELECT 
         x."SID/SERIAL@I",
         x.PGA_USED_MB
      FROM (
         SELECT 
            s.sid || ',' || s.serial# || CASE WHEN s.inst_id IS NOT NULL THEN ',@' || s.inst_id END AS "SID/SERIAL@I",
            ROUND(p.PGA_USED_MEM / (1024 * 1024), 2) AS PGA_USED_MB
         FROM 
            GV$PROCESS p
         JOIN 
            GV$SESSION s
         ON 
            p.ADDR = s.PADDR
         ORDER BY 
            p.PGA_USED_MEM DESC
      ) x
      WHERE ROWNUM <= 5
   ) LOOP
      DBMS_OUTPUT.PUT_LINE(rec."SID/SERIAL@I" || ' - PGA Usada: ' || rec.PGA_USED_MB || ' MB');
   END LOOP;
END;
/
