-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : sess_lock.sql                                                   |
-- | CLASS    :                                                                 |
-- | PURPOSE  :                                                                 |
-- | NOTE     :                                                                 |
-- |                                                                            |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Sessoes em locked                                           |
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

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

set lines 400
set pages 100
SET LINESIZE 500
SET PAGESIZE 1000
col sess format A12
col username format a10
col DSLMODE format A15
col DSREQUEST format A15
col status format A6
col client_info format A15
col client_ident format A15
col "SID/SERIAL" format a13 

select a.*, b.sid || ',' || b.serial#|| case when b.inst_id is not null then ',@' || b.inst_id end  "SID/SERIAL"
, b.username, decode(b.status,'ACTIVE','A','I') status, client_info, client_identifier client_ident
  from (
SELECT   DECODE (request, 0, 'Holder: ', 'Waiter: ') || SID sess,
       --  id1,
        -- id2,
         lmode,
         DECODE (lmode,
                 0, 'None',
                 1, 'Null',
                 2, 'Row Share',
                 3, 'Row Exlusive',
                 4, 'Share',
                 5, 'Sh/Row Exlusive',
                 6, 'Exclusive'
                ) dslmode,
         request,
         DECODE (request,
                 0, 'None',
                 1, 'Null',
                 2, 'Row Share',
                 3, 'Row Exlusive',
                 4, 'Share',
                 5, 'Sh/Row Exlusive',
                 6, 'Exclusive'
                ) dsrequest,
         TYPE, sid
    FROM gv$lock
   WHERE (id1, id2, TYPE) IN (SELECT id1,
                                     id2,
                                     TYPE
                                FROM gv$lock a
                               WHERE a.request > 0)) a,
gv$session b
where a.sid = b.sid
order by  request
/


