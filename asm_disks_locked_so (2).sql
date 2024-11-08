SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : ASM Disks Locked SO                                         |
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

COLUMN command_locked_LSPV    FORMAT a60           
COLUMN command_unlocked_LSPV  FORMAT a60           
COLUMN disk_file_path         FORMAT a20           HEAD 'Path'
COLUMN disk_file_name         FORMAT a20           HEAD 'File Name'
COLUMN disk_file_fail_group   FORMAT a20           HEAD 'Fail Group'
COLUMN mb_disk                FORMAT 999,999,999   HEAD 'Path Size (MB)'
COLUMN total_mb               FORMAT 999,999,999   HEAD 'File Size (MB)'
COLUMN used_mb                FORMAT 999,999,999   HEAD 'Used Size (MB)'
COLUMN pct_used               FORMAT 999.99        HEAD 'Pct. Used'

BREAK ON report ON disk_group_name SKIP 1

COMPUTE sum LABEL ""              OF total_mb used_mb ON disk_group_name
COMPUTE sum LABEL ""              OF mb_disk  mb_disk ON disk_group_name
COMPUTE sum LABEL "Grand Total: " OF total_mb used_mb ON report

 SELECT 'lkdev -l '||replace(b.path,'/dev/r')||' -a -c '||b.name command_locked_LSPV,
        'lkdev -l '||replace(b.path,'/dev/r')||' -d ' command_unlocked_LSPV
 FROM v$asm_diskgroup a RIGHT OUTER JOIN v$asm_disk b USING (group_number)
	 where b.name is not null
 ORDER BY a.name
/