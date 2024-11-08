-- |----------------------------------------------------------------------------|
-- |                                                                            |
-- |----------------------------------------------------------------------------|
-- | Objetivo   : Detalhes dos discos e diskroups no ASM                        |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 10/04/2017                                                    |
-- | Exemplo    : @asm_disks                                                    |
-- | Arquivo    : asm_disks.sql                                                 |
-- | Modificacao: V1.1 - 10/04/2017 - rfsobrinho - Ajuste COMPUTE SUM           |
-- |            : V1.2 - 19/02/2021 - rfsobrinho - Dando uma melhorada          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : ASM Disks                           +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 1.2                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
SET ECHO        OFF
SET FEEDBACK    off
SET HEADING     ON 
SET LINESIZE    190
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES  
COLUMN disk_group_name        FORMAT a20               HEAD 'Disk Group|Name'          JUSTIFY CENTER
COLUMN disk_number            FORMAT a07               HEAD 'Disk|Seq'                 JUSTIFY CENTER
COLUMN disk_file_path         FORMAT a30               HEAD 'Path|-'                   JUSTIFY CENTER
COLUMN disk_file_name_label   FORMAT a18               HEAD 'File / Label|Name'        JUSTIFY CENTER
COLUMN disk_label_name        FORMAT a21               HEAD 'Label Name|-'             JUSTIFY CENTER
COLUMN disk_file_fail_group   FORMAT a15               HEAD 'Fail|Group'               JUSTIFY CENTER
COLUMN disk_type              FORMAT a06               HEAD 'Type|-'                   JUSTIFY CENTER
COLUMN disk_vt                FORMAT a02               HEAD 'VT|-'                     JUSTIFY CENTER
COLUMN state                  FORMAT a08               HEAD 'State|-'                  JUSTIFY CENTER
COLUMN header_status          FORMAT a12               HEAD 'Header|Status'            JUSTIFY CENTER
COLUMN mount_status           FORMAT a08               HEAD 'Mount|Status'             JUSTIFY CENTER
COLUMN library                FORMAT a07               HEAD 'Lib|-'                    JUSTIFY CENTER
COLUMN mb_disk                FORMAT 999,999,999       HEAD 'Path Size|(MB)'           JUSTIFY CENTER
COLUMN total_mb               FORMAT 999,999,999,999   HEAD 'File Size|(MB)'           JUSTIFY CENTER
COLUMN used_mb                FORMAT 9,999,999,999     HEAD 'Used Size|(MB)'           JUSTIFY CENTER
COLUMN au_size_mb             FORMAT 99                HEAD 'AU|(MB)'                  JUSTIFY CENTER
COLUMN pct_used               FORMAT 999.99            HEAD 'Used|%'                   JUSTIFY CENTER
BREAK ON report ON disk_group_name SKIP 1
COMPUTE sum LABEL ""              OF total_mb used_mb ON disk_group_name
COMPUTE sum LABEL ""              OF mb_disk  mb_disk ON disk_group_name
COMPUTE sum LABEL "Grand Total: " OF total_mb used_mb ON report	
SET COLSEP '|'
SELECT
    NVL(a.name, '[CANDIDATE]')                          disk_group_name
   ,ALLOCATION_UNIT_SIZE/1024/1024                      au_size_mb
   , b.state                                            state 
   , substr(b.mount_status,1,8)                         mount_status
   , b.header_status                                    header_status
   ,TYPE                                                disk_type 
   , VOTING_FILES                                       disk_vt
   , to_char(b.disk_number)                             disk_number
   , b.path                                             disk_file_path
   , decode(b.name,b.label,b.name, b.name||nvl2( b.name,'|',null)||b.label) disk_file_name_label
   , b.failgroup                                       disk_file_fail_group
   , substr(upper(replace(b.library,' ')),1,6)                            library
 --, b.os_mb                                           mb_disk
   , b.total_mb                                        total_mb
   , (b.total_mb - b.free_mb)                          used_mb
   , case when b.total_mb > 0 then  ROUND((1- (b.free_mb / b.total_mb))*100, 2)  end    pct_used
FROM
    v$asm_diskgroup a RIGHT OUTER JOIN v$asm_disk b USING (group_number)
ORDER BY
    a.name, b.disk_number, VOTING_FILES
/

--select NAME, GROUP_NUMBER, ALLOCATION_UNIT_SIZE/1024/1024 "AU size (MB)", TYPE
--from V$ASM_DISKGROUP
--where NAME='DATA';

SET FEEDBACK    ON
PROMPT.                                                                                                              ______ _ ___
PROMPT.                                                                                                             |_  / _` / __| +-+-+-+-+-+-+-+-+-+-+
PROMPT.                                                                                                  _   _   _   / / (_| \__ \ |r|f|s|o|b|r|i|n|h|o|
PROMPT.                                                                                                 (_) (_) (_) /___\__,_|___/ +-+-+-+-+-+-+-+-+-+-+
PROMPT
