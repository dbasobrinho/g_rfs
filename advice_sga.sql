 
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : sga advice                          +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 1.0                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+ 
SET ECHO        OFF
SET FEEDBACK    OFF
SET HEADING     ON
SET LINES       600
SET PAGES       500
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
set pagesize 1000
set lines 1000 
SELECT round(SGA_SIZE) target_mb,        
       SGA_SIZE_FACTOR SGA_SIZE_FACTOR,        
       ESTD_DB_TIME,
	   --ESTD_DB_TIME_FACTOR,
       (select decode ( round(SGA_SIZE),(value/1024/1024),'Valor atual','')
       FROM V$PARAMETER WHERE NAME = 'sga_target') Tamanho_atual
  FROM   v$sga_target_advice
/  
SET FEEDBACK    ON