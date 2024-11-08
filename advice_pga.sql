SET TERMOUT OFF; 
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : pga advice                          +-+-+-+-+-+-+-+-+-+-+   |
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
SELECT round(PGA_TARGET_FOR_ESTIMATE/1024/1024) target_mb,        
       ESTD_PGA_CACHE_HIT_PERCENTAGE cache_hit_perc,        
       ESTD_OVERALLOC_COUNT,
       (select decode ( round(PGA_TARGET_FOR_ESTIMATE/1024/1024),(value/1024/1024),'Valor atual','')
       FROM V$PARAMETER WHERE NAME = 'pga_aggregate_target') Tamanho_atual
  FROM   v$pga_target_advice
/  
SET FEEDBACK    ON