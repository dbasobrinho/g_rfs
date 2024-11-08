ALTER SESSION SET NLS_DATE_FORMAT = 'dd/mm/yyyy hh24:mi:ss';
---- Mostrar instance(s) do banco
set lines 350
set pages 50000
set time on
set timing on
col HOST_NAME format a15
col VERSION format a10
col status format a10
col instance_name format a10
col name format a15
col logins format a10
col open_mode format a10
col database_role format a15
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : TPS ABAIXO 10 NOS ULTIMOS 60 MINUTOS  +-+-+-+-+-+-+-+-+-+-+ |
PROMPT | Instance : &current_instance                     |r|f|s|o|b|r|i|n|h|o| |
PROMPT | Version  : 1.0                                   +-+-+-+-+-+-+-+-+-+-+ |
PROMPT +------------------------------------------------------------------------+
select *  from
(SELECT TO_CHAR(TRANSACTION_BEGIN_TIME, 'YYYY/MM/DD HH24:MI') AS DT_HORARIO,
       COUNT(*) AS TPS
        FROM AU_OPEN_TRANSACTION AU
       WHERE ID_TRANSACTION >=
             ((SELECT MAX(ID_TRANSACTION) - 1000000
                 FROM AU_OPEN_TRANSACTION AUOT))
         AND AU.TRANSACTION_PAN NOT IN ('4058801720859010')
         AND AU.TRANSACTION_BEGIN_TIME >= SYSDATE-1/24
         AND AU.TRANSACTION_BEGIN_TIME < sysdate
       GROUP BY TO_CHAR(TRANSACTION_BEGIN_TIME,'YYYY/MM/DD HH24:MI')
       ORDER BY to_char(TRANSACTION_BEGIN_TIME,'YYYY/MM/DD HH24:MI')) where TPS < 10
/