-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : asm_diskgroups.sql                                              |
-- | CLASS    : Automatic Storage Management                                    |
-- | PURPOSE  : Provide a summary report of all disk groups.                    |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : ASM Size GB                                                 |
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

COLUMN group_name             FORMAT a25           HEAD 'Disk Group|Name'
COLUMN sector_size            FORMAT 99,999        HEAD 'Sector|Size'
COLUMN block_size             FORMAT 99,999        HEAD 'Block|Size'
COLUMN allocation_unit_size   FORMAT 999,999,999   HEAD 'Allocation|Unit Size'
COLUMN state                  FORMAT a11           HEAD 'State'
COLUMN type                   FORMAT a6            HEAD 'Type'
COLUMN total_mb               FORMAT 999,999,999   HEAD 'Total Size (MB)'
COLUMN used_mb                FORMAT 999,999,999   HEAD 'Used Size (MB)'
COLUMN pct_used               FORMAT 999.99        HEAD 'Pct. Used'
COLUMN pct_free               FORMAT 999.99        HEAD 'Pct. Free'

BREAK ON report ON disk_group_name SKIP 1

COMPUTE sum LABEL "Grand Total: " OF total_mb used_mb ON report

select /* EXTERNAL REDUNDANCY */
 g.name,
 sum(d.TOTAL_MB) * min(d.FREE_MB / d.total_mb) /
 decode(g.type, 'EXTERN', 1, 'NORMAL', 2, 'HIGH', 3, 1) "USABLE_FREE_MB"
  from v$asm_disk d, v$asm_diskgroup g
 where d.group_number = g.group_number
   and g.type = 'EXTERN'
 group by g.name, g.type
union
select /* NON EXTERNAL REDUNDANCY WITH SYMMETRIC FG */
 g.name,
 sum(d.TOTAL_MB) * min(d.FREE_MB / d.total_mb) /
 decode(g.type, 'EXTERN', 1, 'NORMAL', 2, 'HIGH', 3, 1) "USABLE_FREE_MB"
  from v$asm_disk d, v$asm_diskgroup g
 where d.group_number = g.group_number
   and g.group_number not in /* KEEP SYMMETRIC*/
       (select distinct (group_number)
          from (select group_number,
                       failgroup,
                       TOTAL_MB,
                       count_dsk,
                       greatest(lag(count_dsk, 1, 0)
                                over(partition by TOTAL_MB,
                                     group_number order by TOTAL_MB,
                                     FAILGROUP),
                                lead(count_dsk, 1, 0)
                                over(partition by TOTAL_MB,
                                     group_number order by TOTAL_MB,
                                     FAILGROUP)) as max_lag_lead,
                       count(distinct(failgroup)) over(partition by group_number, TOTAL_MB) as nb_fg_per_size,
                       count_fg
                  from (select group_number,
                               failgroup,
                               TOTAL_MB,
                               count(*) over(partition by group_number, failgroup, TOTAL_MB) as count_dsk,
                               count(distinct(failgroup)) over(partition by group_number) as count_fg
                          from v$asm_disk))
         where count_dsk <> max_lag_lead
            or nb_fg_per_size <> count_fg)
   and g.type <> 'EXTERNAL'
 group by g.name, g.type
union
select /* NON EXTERNAL REDUNDANCY WITH NON SYMMETRIC FG
AND DOES EXIST AT LEAST ONE DISK WITH PARTNERS OF DIFFERENT SIZE*/
 name,
 min(free) / decode(type, 'EXTERN', 1, 'NORMAL', 2, 'HIGH', 3, 1) "USABLE_FREE_MB"
  from (select name,
               disk_number,
               free_mb / (factor / sum(factor) over(partition by name)) as free,
               type
          from (select name,
                       disk_number,
                       avg(free_mb) as free_mb,
                       avg(total_mb) as total_mb,
                       sum(factor_disk + factor_partner) as factor,
                       type
                  from (SELECT g.name,
                               g.type,
                               d.group_number      as group_number,
                               d.disk_number       disk_number,
                               d.total_mb          as total_mb,
                               d.free_mb           as free_mb,
                               p.number_kfdpartner "Partner disk#",
                               f.factor            as factor_disk,
                               fp.factor           as factor_partner
                          FROM x$kfdpartner p,
                               v$asm_disk d,
                               v$asm_diskgroup g,
                               (select disk_number,
                                       group_number,
                                       TOTAL_MB / min(total_mb) over(partition by group_number) as factor
                                  from v$asm_disk
                                 where state = 'NORMAL'
                                   and mount_status = 'CACHED') f,
                               (select disk_number,
                                       group_number,
                                       TOTAL_MB / min(total_mb) over(partition by group_number) as factor
                                  from v$asm_disk
                                 where state = 'NORMAL'
                                   and mount_status = 'CACHED') fp
                         WHERE p.disk = d.disk_number
                           and p.grp = d.group_number
                           and f.disk_number = d.disk_number
                           and f.group_number = d.group_number
                           and fp.disk_number = p.number_kfdpartner
                           and fp.group_number = p.grp
                           and d.group_number = g.group_number
                           and g.type <> 'EXTERN'
                           and g.group_number in /* KEEP NON SYMMETRIC */
                               (select distinct (group_number)
                                  from (select group_number,
                                               failgroup,
                                               TOTAL_MB,
                                               count_dsk,
                                               greatest(lag(count_dsk, 1, 0)
                                                        over(partition by
                                                             TOTAL_MB,
                                                             group_number order by
                                                             TOTAL_MB,
                                                             FAILGROUP),
                                                        lead(count_dsk, 1, 0)
                                                        over(partition by
                                                             TOTAL_MB,
                                                             group_number order by
                                                             TOTAL_MB,
                                                             FAILGROUP)) as max_lag_lead,
                                               count(distinct(failgroup)) over(partition by group_number, TOTAL_MB) as nb_fg_per_size,
                                               count_fg
                                          from (select group_number,
                                                       failgroup,
                                                       TOTAL_MB,
                                                       count(*) over(partition by group_number, failgroup, TOTAL_MB) as count_dsk,
                                                       count(distinct(failgroup)) over(partition by group_number) as count_fg
                                                  from v$asm_disk))
                                 where count_dsk <> max_lag_lead
                                    or nb_fg_per_size <> count_fg)
                           and d.group_number not in /* KEEP DG THAT DOES NOT CONTAIN AT LEAST ONE DISK HAVING PARTNERS OF DIFFERENT SIZE*/
                               (select distinct (group_number)
                                  from (select d.group_number as group_number,
                                               d.disk_number disk_number,
                                               p.number_kfdpartner "Partner disk#",
                                               f.factor as factor_disk,
                                               fp.factor as factor_partner,
                                               greatest(lag(fp.factor, 1, 0)
                                                        over(partition by
                                                             d.group_number,
                                                             d.disk_number order by
                                                             d.group_number,
                                                             d.disk_number),
                                                        lead(fp.factor, 1, 0)
                                                        over(partition by
                                                             d.group_number,
                                                             d.disk_number order by
                                                             d.group_number,
                                                             d.disk_number)) as max_lag_lead,
                                               count(p.number_kfdpartner) over(partition by d.group_number, d.disk_number) as nb_partner
                                          FROM x$kfdpartner p,
                                               v$asm_disk d,
                                               v$asm_diskgroup g,
                                               (select disk_number,
                                                       group_number,
                                                       TOTAL_MB / min(total_mb) over(partition by group_number) as factor
                                                  from v$asm_disk
                                                 where state = 'NORMAL'
                                                   and mount_status = 'CACHED') f,
                                               (select disk_number,
                                                       group_number,
                                                       TOTAL_MB / min(total_mb) over(partition by group_number) as factor
                                                  from v$asm_disk
                                                 where state = 'NORMAL'
                                                   and mount_status = 'CACHED') fp
                                         WHERE p.disk = d.disk_number
                                           and p.grp = d.group_number
                                           and f.disk_number = d.disk_number
                                           and f.group_number = d.group_number
                                           and fp.disk_number =
                                               p.number_kfdpartner
                                           and fp.group_number = p.grp
                                           and d.group_number = g.group_number
                                           and g.type <> 'EXTERN')
                                 where factor_partner <> max_lag_lead
                                   and nb_partner > 1))
                 group by name, disk_number, type))
 group by name, type
/