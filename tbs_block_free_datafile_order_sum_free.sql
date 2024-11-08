-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : tbs_block_free_datafile_order_sum_free                          |
-- | CREATOR  : Roberto Fernandes Sobrinho                                      |
-- | DATE     : 25/10/2019                                                      |
-- +----------------------------------------------------------------------------+
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : BLOCOS LIVRES SUM                                           |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON 
SET LINESIZE    180
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
PROMPT .
PROMPT . .
PROMPT . . .
ACCEPT ts char   PROMPT 'TABLESPACE_NAME = '
col owner             for a20
col OBJECT            for a32
col file_id           for 99999
COL block_id          for 99999999999
COL MB                for 9999999

BREAK ON file_id SKIP 2 ON REPORT 
COMPUTE SUM OF  MB  ON file_id
COMPUTE SUM OF  MB   ON report
-----COMPUTE SUM OF  total_blocks  ON report

SELECT   'free space' owner, '      ' OBJECT, e.file_id, e.block_id, (e.blocks*(b.block_size/1024)/1024) MB
    FROM dba_free_space e, dba_tablespaces b
   WHERE  e.tablespace_name = b.TABLESPACE_NAME
   and e.tablespace_name = UPPER ('&ts')
--UNION
--SELECT   SUBSTR (e.owner, 1, 20) AS OWNER, SUBSTR (e.segment_name, 1, 32) OBJECT, e.file_id, e.block_id, (e.blocks*(b.block_size/1024)/1024) MB
--    FROM dba_extents e, dba_tablespaces b
--   WHERE  e.tablespace_name = b.TABLESPACE_NAME
--     and e.tablespace_name = UPPER ('&ts')
--ORDER BY file_id, block_id
/

UNDEF ts
set FEED on;
set HEAD on;
set time on;
SET FEEDBACK on                                                                                         
PROMPT.                                                                                                                     ______ _ ___ 
PROMPT.                                                                                                                    |_  / _` / __| +-+-+-+-+-+-+-+-+-+-+
PROMPT.                                                                                                         _   _   _   / / (_| \__ \ |r|f|s|o|b|r|i|n|h|o|
PROMPT.                                                                                                        (_) (_) (_) /___\__,_|___/ +-+-+-+-+-+-+-+-+-+-+
PROMPT 