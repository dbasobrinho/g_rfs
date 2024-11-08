SET LINES 800
SET PAGESIZE 10000
BREAK ON REPORT
COMPUTE SUM LABEL TOTAL OF GAP ON REPORT
select primary.thread#,
       primary.maxsequence primaryseq,
       standby.maxsequence standbyseq,
       primary.maxsequence - standby.maxsequence gap
from ( select thread#, max(sequence#) maxsequence
       from v$archived_log
       where archived = 'YES'
         and resetlogs_change# = ( select d.resetlogs_change# from v$database d )
       group by thread# order by thread# ) primary,
     ( select thread#, max(sequence#) maxsequence
       from v$archived_log
       where applied = 'YES'
         and resetlogs_change# = ( select d.resetlogs_change# from v$database d )
       group by thread# order by thread# ) standby
where primary.thread# = standby.thread#
/


----->>>    253890 UNTIL SEQUENCE 253947
----->>>    
----->>>       THREAD#|PRIMARYSEQ|STANDBYSEQ|       GAP
----->>>   ----------|----------|----------|---------- 
----->>>            1|    192318|    192156|       162  
----->>>            2|    254085|    253889|       196
----->>>             |          |          |----------
----->>>   TOTAL     |          |          |       358
