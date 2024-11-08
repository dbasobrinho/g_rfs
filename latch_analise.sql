SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | REPORT   : LATCH WAITS: 10G SHOWS THE LATCHES SESSIONS ARE WAITING ON
PROMPT | INSTANCE : &CURRENT_INSTANCE                                           
PROMPT +------------------------------------------------------------------------+
SET LINES 200
SET PAGES 200
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
   
COLUMN SID_SERIAL             FORMAT a13           HEAD 'SID|SERIAL'
COLUMN username               FORMAT a10           HEAD 'USERNAME'
COLUMN addr                   FORMAT a16    
COLUMN latch                  FORMAT a08
COLUMN cchild                 FORMAT a08 
COLUMN llevel                 FORMAT a08 
COLUMN name                   FORMAT a20 
COLUMN gets                   FORMAT a11 
COLUMN hitratio               FORMAT 9999        HEAD 'HIT|RATIO'
COLUMN immed_hitratio         FORMAT 9999        HEAD 'IMMED|HIT|RATIO'
COLUMN pct_sleeps             FORMAT 9999        HEAD 'PCT|SLEEPS'
COLUMN waiters_woken          FORMAT 999999      HEAD 'WAITERS|WOKEN'
COLUMN spin_gets              FORMAT 99999999999   HEAD 'SPIN|GETS'


--BREAK ON report ON disk_group_name SKIP 1

--COMPUTE sum LABEL "Grand Total: " OF total_mb used_mb ON report

select s.sid || ',' || s.serial# || case when null is not null then ',@' || 's.inst_id' end SID_SERIAL,
       substr(s.username,1,10) username ,
       lc.addr,
       to_char(lc.latch#) latch,
       to_char(lc.child#) cchild,
       to_char(lc.level#) llevel,
       substr(lc.name,1,20) name,
       to_char(lc.gets) gets,
       decode(gets, 0, 0, round(100 * (gets - misses) / gets, 2)) hitratio,
       decode(immediate_gets,0,0,round(100 * (immediate_gets - immediate_misses) /immediate_gets,2)) immed_hitratio,
       decode(gets, 0, 0, round(100 * sleeps / gets, 2)) pct_sleeps,
       waiters_woken,
       waits_holding_latch,
       spin_gets
--  sleep1,
-- sleep2,
-- sleep3,
-- sleep4,
-- sleep5
  from v$latch_children lc, v$session_wait w, v$session s
 where lc.latch# = s.p2
   and lc.addr = s.p1raw
   and s.sid = w.sid 
/

COLUMN ADDR                   FORMAT a16         HEAD 'LATCH_ADDR'
COLUMN FFILE                  FORMAT 99999999
COLUMN BLOCK                  FORMAT 999999999
COLUMN TOUCHE                 FORMAT a20
COLUMN TOUCHE                 FORMAT a20
COLUMN owner                  FORMAT a25
COLUMN oobject                FORMAT a40       
COLUMN object_id              FORMAT 99999999   
COLUMN FREELISTS              FORMAT 99999999   
COLUMN object_type            FORMAT a20    
SET LINES 200

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | REPORT   : IDENTIFY BUFFER CHAINS W/ HIGH SLEEP COUNTS (QUERY TAKES A LONG TIME)
PROMPT | INSTANCE : &CURRENT_INSTANCE                                           
PROMPT +------------------------------------------------------------------------+

SELECT hladdr      ADDR
      ,dbarfil     FFILE
      ,dbablk      BLOCK
      ,tch         TOUCHES
      ,o.owner||'.'||o.object_name as oobject
      ,o.object_id
	  ,o.object_type
	  ,(select g.FREELISTS from dba_tables g where g.owner =o.owner and  g.TABLE_NAME = o.object_name ) as FREELISTS
  FROM x$bh b, dba_objects o
 WHERE 1 = 1
   and hladdr = '&enter_value_addr' --value of p1raw in v$session_wait
   AND b.obj = o.object_id
 ORDER BY 4 desc, 1, 2, 3
/ 

PROMPT +---------------------------------------------------------------------------------------------+
PROMPT | LATCH: CACHE BUFFERS CHAINS TABLE                                                           |
PROMPT +---------------------------------------------------------------------------------------------+
PROMPT | alter table [OWNER].[TABLE_NAME] move pctfree 50 pctused 30 storage (freelists 2);          |
PROMPT | alter table [OWNER].[TABLE_NAME] minimize records_per_block;                                |
PROMPT | alter index [OWNER].[INDEX_NAME] rebuild pctfree 50 storage (freelists 2);                  |
PROMPT | http://toolkit.rdbms-insight.com/latch.php                                                  |
PROMPT | SE FOR USAR O FREELISTS, LEIA:                                                              |
PROMPT | https://www.akadia.com/services/ora_freelists.html                                          |
PROMPT +---------------------------------------------------------------------------------------------+
PROMPT +---------------------------------------------------------------------------------------------+
PROMPT +---------------------------------------------------------------------------------------------+
PROMPT +---------------------------------------------------------------------------------------------+
@table_latch_buffers_chains_by.sql

