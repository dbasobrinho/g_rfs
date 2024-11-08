---http://www.1001111.com/weekly_script.html

REM Monitoring and tuning script for Oracle databases all versions
REM This script has no adverse affects. There are no DML or DDL actions taken
REM Parts will not work in all versions but useful info should be returned from other parts
REM Uses anonymous procedures to avoid storing objects in the SYS schema
REM therefore this script must be run as sys 
REM calls to v$parameter need to be moved into subblocks to prevent NO_DATA_FOUND exceptions
REM parameter numbers are different between Oracle Versions
REM
REM The database device report substr call needs t be edited to match the 
REM directories the Oracle datafiles are on
REM
REM For nicer formatting run the following in vi: %s/  *$//
REM This strips the trailing whitespace returned from oracle
REM
REM To map datafile I/O onto physical devices the substr call on line 658 should be 
REM edited. The substr function is used to map to unique mount points, therefore, 
REM the number of characters chosen should equal the length of the directory path to
REM the mount point. Note that if more than one database uses the mount point these 
REM numbers must be summed across instances. Note the GROUP BY clause on line 666 uses 
REM the same substr clause. 
REM
REM These scripts have been collected from many sources and I am sure there are
REM acknowledgements missing from below. Among those are Steve Adams, Rachel Carmichael,
REM Jared Still and other members of the oracle-l mailing list
REM
REM
REM	Unknown authors 	1990 - 1995
REM	Oracle Corporation	1990 - 
REM	Bill Beaton, QC Data		1995
REM	D. Morgan, QC Data		1997
REM	Hari Krishnamoorthy, QC Data	1999
REM	J. J. Wang, Bartertrust		2000
REM	D. Morgan, 1001111 Alberta Ltd.	2002
REM

set pause off
set verify off
set echo off
set term off
set heading off

REM Set up dynamic spool filename
spool tmp7_spool.sql
	select 'spool '||name||'_'||'report'||'_'||to_char(sysdate,'yymondd')||'.dat'
	from sys.v_$database;
spool off

set heading on
set verify on
set term on
set serveroutput on size 1000000
set wrap on
set linesize 200
set pagesize 1000

/**************************************** START REPORT ****************************************************/

/* Run dynamic spool output name */
@tmp7_spool.sql

set feedback off
set heading off

select 'Report Date: '||to_char(sysdate,'Monthdd, yyyy hh:mi')
from dual;

set heading on
prompt =================================================================================================
prompt .                      DATABASE (V$DATABASE) (V$VERSION)
prompt =================================================================================================
select	NAME "Database Name",
	CREATED "Created",
	LOG_MODE "Status"
  from	sys.v_$database;

select	banner "Current Versions"
  from	sys.v_$version;

prompt =================================================================================================
prompt .                      UPTIME (V$DATABASE) (V$INSTANCE)
prompt =================================================================================================

set heading off
column sttime format A30

SELECT NAME, ' Database Started on ',TO_CHAR(STARTUP_TIME,'DD-MON-YYYY "at" HH24:MI')
FROM V$INSTANCE, v$database;
set heading on


prompt .
prompt =================================================================================================
prompt .                      SGA SIZE (V$SGA) (V$SGASTAT)
prompt =================================================================================================
column Size	format 99,999,999,999
select	decode(name,	'Database Buffers',
		'Database Buffers (DB_BLOCK_SIZE*DB_BLOCK_BUFFERS)',
		'Redo Buffers',
		'Redo Buffers     (LOG_BUFFER)', name) "Memory",
		value		"Size"
	from sys.v_$sga
UNION ALL
	select	'------------------------------------------------------'	"Memory",
		to_number(null)		"Size"
  	from	dual
UNION ALL
	select	'Total Memory' "Memory",
		sum(value)	"Size"
  	from	sys.v_$sga;

prompt .
prompt .
prompt Current Break Down of (SGA) Variable Size
prompt ------------------------------------------

column Bytes		format 999,999,999
column "% Used"		format 999.99
column "Var. Size"	format 999,999,999

select	a.name			"Name",
	bytes			"Bytes",
	(bytes / b.value) * 100	"% Used",
	b.value			"Var. Size"
from	sys.v_$sgastat a,
	sys.v_$sga b
where	a.name not in ('db_block_buffers','fixed_sga','log_buffer')
and	b.name='Variable Size'
order by 3 desc;

prompt .

set feedback ON

declare
        h_char          varchar2(100);
        h_char2         varchar(50);
        h_num1          number(25);
        result1         varchar2(50);
        result2         varchar2(50);

        cursor c1 is
        select lpad(namespace,17)||': gets(pins)='||rpad(to_char(pins),9)||
                                     ' misses(reloads)='||rpad(reloads,9)||
               ' Ratio='||decode(reloads,0,0,to_char((reloads/pins)*100,999.999))||'%'
        from v$librarycache;

begin
    dbms_output.put_line
        ('=================================================================================================');
    dbms_output.put_line('.                      SHARED POOL: LIBRARY CACHE (V$LIBRARYCACHE)');
    dbms_output.put_line
        ('=================================================================================================');
    dbms_output.put_line('.');
    dbms_output.put_line('.         Goal: The library cache ratio < 1%' );
    dbms_output.put_line('.');
    
    Begin
        SELECT 'Current setting: '||substr(value,1,30) INTO result1
        FROM V$PARAMETER        
        WHERE NUM = 23;
        SELECT 'Current setting: '||substr(value,1,30) INTO result2
        FROM V$PARAMETER        
        WHERE NUM = 325;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN 
                h_num1 :=1;
    END;
    dbms_output.put_line('Recommendation: Increase SHARED_POOL_SIZE '||rtrim(result1));
    dbms_output.put_line('.                        OPEN_CURSORS '    ||rtrim(result2));
    dbms_output.put_line('.               Also write identical sql statements.');
    dbms_output.put_line('.');
        
    open c1;
    loop
        fetch c1 into h_char;
        exit when c1%notfound;
        
        dbms_output.put_line('.'||h_char);
    end loop;
    close c1;

    dbms_output.put_line('.');

    select lpad('Total',17)||': gets(pins)='||rpad(to_char(sum(pins)),9)||
                                 ' misses(reloads)='||rpad(sum(reloads),9),
               ' Your library cache ratio is '||
                decode(sum(reloads),0,0,to_char((sum(reloads)/sum(pins))*100,999.999))||'%'
    into h_char,h_char2
    from v$librarycache;
    dbms_output.put_line('.'||h_char);
    dbms_output.put_line('.           ..............................................');
    dbms_output.put_line('.           '||h_char2);

    dbms_output.put_line('.');
end;
/

declare
        h_num1          number(25);
        h_num2          number(25);
        h_num3          number(25);
        result1         varchar2(50);

begin
    dbms_output.put_line
        ('=================================================================================================');
        dbms_output.put_line('.                      SHARED POOL: DATA DICTIONARY (V$ROWCACHE)');
    dbms_output.put_line
        ('=================================================================================================');
        dbms_output.put_line('.');
        dbms_output.put_line('.         Goal: The row cache ratio should be < 10% or 15%' );
        dbms_output.put_line('.');
        dbms_output.put_line('.         Recommendation: Increase SHARED_POOL_SIZE '||result1);
        dbms_output.put_line('.');

        select sum(gets) "gets", sum(getmisses) "misses", round((sum(getmisses)/sum(gets))*100 ,3)
        into h_num1,h_num2,h_num3
        from v$rowcache;

        dbms_output.put_line('.');
        dbms_output.put_line('.             Gets sum: '||h_num1);
        dbms_output.put_line('.        Getmisses sum: '||h_num2);

        dbms_output.put_line('         .......................................');
        dbms_output.put_line('.        Your row cache ratio is '||h_num3||'%');

end;
/

declare
        h_char          varchar2(100);
        h_num1          number(25);
        h_num2          number(25);
        h_num3          number(25);
        h_num4          number(25);
        result1         varchar2(50);
begin
    dbms_output.put_line('.');
    dbms_output.put_line
        ('=================================================================================================');
        dbms_output.put_line('.                      BUFFER CACHE (V$SYSSTAT)');
    dbms_output.put_line
        ('=================================================================================================');
        dbms_output.put_line('.');
        dbms_output.put_line('.         Goal: The buffer cache ratio should be > 70% ');
        dbms_output.put_line('.');
        Begin
                SELECT 'Current setting: '||substr(value,1,30) INTO result1
                FROM V$PARAMETER        
                WHERE NUM = 125;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN 
                result1 := 'Unknown parameter';
        END;
        dbms_output.put_line('.          Recommendation: Increase DB_BLOCK_BUFFERS '||result1);
        dbms_output.put_line('.');

        select lpad(name,15)  ,value
        into h_char,h_num1
        from v$sysstat
        where name ='db block gets';
        dbms_output.put_line('.         '||h_char||': '||h_num1);

        select lpad(name,15)  ,value
        into h_char,h_num2
        from v$sysstat
        where name ='consistent gets';
        dbms_output.put_line('.         '||h_char||': '||h_num2);

        select lpad(name,15)  ,value
        into h_char,h_num3
        from v$sysstat
        where name ='physical reads';
        dbms_output.put_line('.         '||h_char||': '||h_num3);

        h_num4:=round(((1-(h_num3/(h_num1+h_num2))))*100,3);

        dbms_output.put_line('.          .......................................');
        dbms_output.put_line('.          Your buffer cache ratio is '||h_num4||'%');

    dbms_output.put_line('.');
end;
/

declare
        h_char          varchar2(100);
        h_num1          number(25);
        h_num2          number(25);
        h_num3          number(25);

        cursor buff2 is
        SELECT name
                ,consistent_gets+db_block_gets, physical_reads
                ,DECODE(consistent_gets+db_block_gets,0,TO_NUMBER(null)
                ,to_char((1-physical_reads/(consistent_gets+db_block_gets))*100, 999.999))
        FROM v$buffer_pool_statistics;
begin
     dbms_output.put_line
        ('=================================================================================================');
        dbms_output.put_line('.                      BUFFER CACHE (V$buffer_pool_statistics)');
    dbms_output.put_line
        ('=================================================================================================');

        dbms_output.put_line('.');
        dbms_output.put_line('.');
        dbms_output.put_line('Buffer Pool:         Logical_Reads     Physical_Reads        HIT_RATIO');
        dbms_output.put_line('.');

        open buff2;
        loop
            fetch buff2 into h_char, h_num1, h_num2, h_num3;
            exit when buff2%notfound;

            dbms_output.put_line(rpad(h_char, 15, '.')||'         '||lpad(h_num1, 10, ' ')||'         '||
                lpad(h_num2, 10, ' ')||'       '||lpad(h_num3, 10, ' '));

        end loop;
        close buff2;

    dbms_output.put_line('.');
end;
/

declare
        h_char          varchar2(100);
        h_num1          number(25);
        result1         varchar2(50);

        cursor c2 is
        select name,value
        from v$sysstat
        where name in ('sorts (memory)','sorts (disk)')
        order by 1 desc;

begin
        dbms_output.put_line
                ('=================================================================================================');
        dbms_output.put_line('.                      SORT STATUS (V$SYSSTAT)');
        dbms_output.put_line
                ('=================================================================================================');
        dbms_output.put_line('.');
        dbms_output.put_line('.         Goal: Very low sort (disk)' );
        dbms_output.put_line('.');
        BEGIN
                SELECT 'Current setting: '||substr(value,1,30) INTO result1
                FROM V$PARAMETER        
                WHERE NUM = 320;
        EXCEPTION
                WHEN NO_DATA_FOUND THEN 
                        result1 := 'Unknown parameter';
        END;
        dbms_output.put_line('           Recommendation: Increase SORT_AREA_SIZE '||result1);
        dbms_output.put_line('.');
        dbms_output.put_line('.');
        dbms_output.put_line(rpad('Name',30)||'Count');
        dbms_output.put_line(rpad('-',25,'-')||'     -----------');

        open c2;
        loop
        fetch c2 into h_char,h_num1;
        exit when c2%notfound;
                dbms_output.put_line(rpad(h_char,30)||h_num1);
        end loop;
        close c2;
end;
/

prompt .
prompt =================================================================================================
prompt .               DATA DICTIONARY CACHE RATIO REPORT (v$rowcache)
prompt =================================================================================================

rem ttitle  'Data Dictionary Getmisses' skip
column getmiss_ratio format 999.99 heading 'Ratio(%)'
select cache#, PARAMETER, count, usage, GETS, 
GETMISSES, GETMISSES*100/(GETS+1) getmiss_ratio
from v$rowcache
order by getmisses desc;
rem ttitle off

prompt .
prompt =================================================================================================
prompt .               NON-SYS/SYSTEM OBJECTS > 25K SHARE MEM (v$db_object_cache)
prompt =================================================================================================
  
       column total_bytes format 9999999 heading 'Total|Bytes'
       column "OBJECT" format A25
       column type format A15

       select    owner || '.' || name OBJECT,
                  type, 
                  to_char(sharable_mem/1024,'9,999.9') "SPACE(K)",
                  loads, 
                  executions execs,
                  kept
       from      v$db_object_cache
      where       owner not in ('SYS','SYSTEM')
       and       kept = 'NO'
       and       sharable_mem > 25000
       and       (executions > 0 or loads >0)
       order by owner, name;

set feedback ON

prompt .
prompt =================================================================================================
prompt .               SYSTEM WAIT EVENTS REPORT (v$system_event)
prompt =================================================================================================


rem ttitle 'High water marks report' skip
       col event format a37 heading 'Event'  
       col total_waits format 99999999 heading 'Total|Waits'  
       col time_waited format 9999999999 heading 'Time Wait|In Hndrds'  
       col total_timeouts format 999999 heading 'Timeout'  
       col average_wait heading 'Average|Time' format 999999.999  
  
       select *  
       from   v$system_event order by total_waits desc;
rem ttitle off



prompt .
prompt =================================================================================================
prompt .               LATCH CONTENTION RPT 1 (v$latchname, v$latch)
prompt =================================================================================================

       column name heading "Latch Type" format a35
       column pct_miss heading "Misses/Gets (%)" format 999.99999
       column pct_immed heading "Immediate Misses/Gets (%)" format 999.99999

rem ttitle  'Misses, Immediate_Misses'

       select  n.name,
                misses*100/(gets+1) pct_miss,
                immediate_misses*100/(immediate_gets+1) pct_immed
       from    v$latchname n,v$latch l
       where   n.latch# = l.latch#
       and     (misses*100/(gets+1) > 0
       or      immediate_misses*100/(immediate_gets+1) > 0);
rem ttitle off
prompt .
prompt =================================================================================================
prompt .               LATCH CONTENTION RPT 2 (v$latch)
prompt =================================================================================================

 column name format a30 heading "LATCH TYPE" 
 column sleep_rate format a10 heading "SLEEP RATE" 
 column impact format 9999999999 heading "IMPACT" 

rem ttitle  'Analysis Report: Misses, Sleeps, Spin_gets' skip

 select 
 name, 
 sleeps * sleeps / (misses - spin_gets) impact, 
 lpad(to_char(100 * sleeps / gets, '990.00') || '%', 10) sleep_rate, 
 waits_holding_latch waits, 
 level# 
 from 
 sys.v_$latch
 where 
 sleeps > 0 
 order by 
 3 desc; 
rem ttitle off

prompt .
prompt =================================================================================================
prompt .               ROLLBACK REPORT (v$rollstat) (v$rollname)
prompt =================================================================================================


rem ttitle 'GET WAIT RATIO ROLLBACK REPORT'
       column "Ratio" format 999.9999
       column name format A15
       column "PERCENT" format 999.9999
       select  name, 
               waits, 
               gets, 
               100-(waits/gets) "Ratio",
               (waits/gets)*100 "PERCENT"
       from    v$rollstat a, v$rollname b  
       where   a.usn = b.usn;  
rem ttitle off



prompt .
prompt =================================================================================================
prompt .               ROLLBACK GENERAL INFORMATION (v$rollstat)
prompt =================================================================================================
rem ttitle 'SHRINKS WRAPS EXTENDS INFORMATION' skip 
       select   rssize,
                optsize,
                hwmsize,
                shrinks,
                wraps,  
                extends,
                aveactive  
       from   v$rollstat  
       order  by rownum;
rem ttitle off


set feedback off

prompt .
prompt =================================================================================================
prompt .               REDO LOG FILE REPORT (v$log)
prompt =================================================================================================

select * from v$log;

prompt .

declare
cursor c3 is
	select a.name,gets,misses,immediate_gets,immediate_misses
	from v$latch a, v$latchname b
	where b.name in ('redo allocation','redo copy')
	and a.latch#=b.latch#;

	h_char	varchar2(100);
	result1	varchar2(50);
	h_num1	INTEGER;
	h_num2  INTEGER;
	h_num3  INTEGER;
	h_num4  INTEGER;
	h_num5  INTEGER;
	h_num6  INTEGER;

begin
    dbms_output.put_line
    	('=================================================================================================');
	dbms_output.put_line('.                      REDO LOG BUFFER LATCHES (V$LATCH, V$SYSSTAT)');
    dbms_output.put_line
    	('=================================================================================================');
	dbms_output.put_line('.');
	dbms_output.put_line('.         Goal: Redo log space request should be near 0' );
	SELECT 'Current setting: '||substr(value,1,30) INTO result1
	FROM V$PARAMETER
	WHERE NUM = 195;
	dbms_output.put_line('.          Recommendation: Increase LOG_BUFFER (5% increments) '||result1);
	dbms_output.put_line('.');
	select value into h_num1
	from sys.v_$sysstat
	where name ='redo log space requests';

	dbms_output.put_line('.');
	dbms_output.put_line('.            Redo log space request: '||h_num1);
	dbms_output.put_line('.');
	open c3;
	loop
		fetch c3 into h_char,h_num1,h_num2,h_num3,h_num4;
		exit when c3%notfound;

		dbms_output.put_line('--------------------------------------------------------------------');
		dbms_output.put_line('.           '||upper(h_char));
		dbms_output.put_line('.');
		dbms_output.put_line('.         Goal: Ratio < 1%' );
		dbms_output.put_line('.         Recommendation: Check Oracle tuning book for more detail ');
		dbms_output.put_line('.');
		dbms_output.put_line('.');
		dbms_output.put_line('.                              gets: '||h_num1);
		dbms_output.put_line('.                            misses: '||h_num2);
		dbms_output.put_line('.                    immediate_gets: '||h_num3);
		dbms_output.put_line('.                  immediate_misses: '||h_num4);
		dbms_output.put_line('.');

		if h_num1 =0 or h_num2 =0 then
			h_num5:=0;
		else
			h_num5:=round((h_num2/h_num1)*100,4);
		end if;

		if h_num4=0 or (h_num3+h_num4)=0 then
			h_num6:=0;
		else
			h_num6:=round((h_num4/(h_num3+h_num4))*100,4);
		end if;

                dbms_output.put_line('.           Ratio (miss)/(gets): '||h_num5||'%');
		dbms_output.put_line('.           Ratio (imm_miss)/(imm_get+imm_miss): '||h_num6||'%');
		dbms_output.put_line('.');
	end loop;
	close c3;
end;
/

prompt .
prompt =================================================================================================
prompt .               REDO LOG SPACE REQUEST RATIO RPT (v$sysstat)
prompt =================================================================================================

rem ttitle  'Redo Log Space Request' skip
column ratio format 9999.9999 heading '.           Ratio: Redo Log Space Request To Redo Entries'

select (req.value*5000)/entries.value ratio
from v$sysstat req, v$sysstat entries
where req.name = 'redo log space requests'
and entries.name = 'redo entries';
rem ttitle off


prompt .
prompt =================================================================================================
prompt .                      DATABASE STATISTIC (DBA_DATA_FILES)
prompt =================================================================================================
column Tablespaces		format 9,999
column "Datafiles added"	format 9,999
column "Total Size"		format 999,999,999,999
column "Total Used"		format 999,999,999,999
column "Total Free"		format 999,999,999,999
column "% Used"			format 999.99
select	count(distinct ddf.tablespace_name)				"Tablespaces",
	count(ddf.tablespace_name) - count(distinct ddf.tablespace_name) "Datafiles added",
	sum(ddf.bytes)							"Total Size",
	sum(ddf.bytes) - dfs.free					"Total Used",
	dfs.free							"Total Free",
	((sum(ddf.bytes) - dfs.free) / sum(ddf.bytes)) * 100	"% Used"
from	sys.dba_data_files ddf,
	(select sum(bytes) free from sys.dba_free_space) dfs
group by dfs.free;

prompt .
prompt =================================================================================================
prompt .                      DATABASE FILE - READ AND WRITE STATUS (V$DATAFILE, V$FILESTAT)
prompt =================================================================================================
column Datafile		format a50
column phyrds		format 999,999,999,999 
column phyblkrd		format 999,999,999,999 
column phywrts		format 999,999,999,999 
column phyblkwrt	format 999,999,999,999 
select	name		"Datafile",
	phyrds,
	phyblkrd,
	phywrts,
	phyblkwrt
  from	v$datafile a,
	v$filestat b
 where	a.file#=b.file#
 order by name;

prompt .
prompt =================================================================================================
prompt .                    DATABASE DEVICE - READ AND WRITE STATUS (V$DATAFILE, V$FILESTAT)
prompt =================================================================================================
column Device		format a40
column phyrds		format 999,999,999,999 
column phyblkrd		format 999,999,999,999 
column phywrts		format 999,999,999,999 
column phyblkwrt	format 999,999,999,999 
select	substr(name,1,21)        "Device",
	sum(phyrds) phyrds,
	sum(phyblkrd) phyblkrd,
	sum(phywrts) phywrts,
	sum(phyblkwrt) phyblkwrt
  from	v$datafile a,
	v$filestat b
 where	a.file#=b.file#
 group by substr(name,1,21);


prompt .
prompt =================================================================================================
prompt .                      TABLESPACE USAGE (DBA_DATA_FILES, DBA_FREE_SPACE)
prompt =================================================================================================
column Tablespace	format a30
column Size		format 999,999,999,999
column Used		format 999,999,999,999
column Free		format 999,999,999,999
column "% Used"		format 999.99
select	tablespace_name		"Tablesapce",
        bytes			"Size",
       	nvl(bytes-free,bytes)	"Used",
       	nvl(free,0)		"Free",
       	nvl(100*(bytes-free)/bytes,100)	"% Used"
  from(
	select ddf.tablespace_name, sum(dfs.bytes) free, ddf.bytes bytes
	FROM (select tablespace_name, sum(bytes) bytes
	from dba_data_files group by tablespace_name) ddf, dba_free_space dfs
	where ddf.tablespace_name = dfs.tablespace_name(+)
	group by ddf.tablespace_name, ddf.bytes)
  order by 5 desc;

set feedback off
set heading off
select	rpad('Total',30,'.')		"Tablespace",
  	sum(bytes)			"Size",
       	sum(nvl(bytes-free,bytes))	"Used",
       	sum(nvl(free,0))		"Free",
       	(100*(sum(bytes)-sum(free))/sum(bytes))	"% Used"
  from(
	select ddf.tablespace_name, sum(dfs.bytes) free, ddf.bytes bytes
	FROM (select tablespace_name, sum(bytes) bytes
	from dba_data_files group by tablespace_name) ddf, dba_free_space dfs
	where ddf.tablespace_name = dfs.tablespace_name(+)
	group by ddf.tablespace_name, ddf.bytes);

set feedback on
set heading on

prompt .
prompt =================================================================================================
prompt .                      TABLESPACE FRAGMENTATION (DBA_SEGMENTS)
prompt =================================================================================================
column Tablespace	format a30
column Segments		format 99,999
column Extents		format 99,999
column Total		format 99,999
column "% Growth"	format 99,999

select	a.tablespace_name	"Tablespace",
	count(*)		"Segments",
	sum(extents) - count(*)	"Extents",
	sum(extents)		"Total",
	(decode(sum(extents)-count(*),0,0,(sum(extents)-count(*))/count(*)))*100 "% Growth"
  from	sys.dba_segments a
 group by a.tablespace_name
 order by 3 desc;

prompt .
prompt =================================================================================================
prompt .                      FREE SPACE FRAGMENTATION (DBA_FREE_SPACE)
prompt =================================================================================================
column Tablespace	format a30
column "Available Size"	format 99,999,999,999
column "Fragmentation"	format 99,999
column "Average Size"	format 9,999,999,999
column "   Max"		format 9,999,999,999
column "   Min"		format 9,999,999,999
select tablespace_name Tablespace, 
	count(*) Fragmentation, 
	sum(bytes) "Available Size",
	avg(bytes) "Average size",
	max(bytes) Max, 
	min(bytes) Min
from dba_free_space
group by tablespace_name
order by 3 desc ;

set feedback off
prompt =================================================================================================
prompt .                      SUMMARY OF OBJECTS (excluding SYS and SYSTEM) (DBA_OBJECTS)
prompt =================================================================================================

column Objects	format a35
column Count	format 9,999,999

select	rpad(obj_name,35,'.') "Objects",
	obj_count "Count"
from (select  0 col1, 'Oracle Users' obj_name,
		to_char(count(*) ,'999,999') obj_count
      from  sys.dba_users
      where  username not in ('SYS','SYSTEM')
      group by 'Oracle Users'
UNION
      select  decode(object_type, 'TABLE', 1,'INDEX', 2,'TRIGGER', 3,
		'VIEW',5,'SYNONYM',6,'PACKAGE',7,'PACKAGE BODY',8,
                'PROCEDURE',9,'FUNCTION',10, 100),
	      decode(object_type,     'INDEX','     INDEX',
        	'TRIGGER','     TRIGGER', object_type),
              to_char(count(*) ,'999,999')
       from  sys.dba_objects
       where  owner not in ('SYS','SYSTEM')
       and  object_name != 'TUNE_OBJECT'
       and  object_name not like 'TEMPRPT_%'
       group by object_type
UNION
       select  4, '     CONSTRAINT('||decode(constraint_type, 'C','Check)',
                                                'P','Primary)',
                                                'U','Unique)',
                                                'R','Referential)',
                                                'V','Check View)',
                                                constraint_type||'(' ),
               to_char(count(*) ,'999,999')
        from sys.dba_constraints
        where owner not in ('SYS','SYSTEM')
        group by constraint_type)
 order by col1;

prompt .
prompt ============================================================================================
prompt .                   SUMMARY OF INVALID OBJECTS (DBA_OBJECTS)
prompt ============================================================================================

select owner, object_type, substr(object_name,1,30) object_name, status
from dba_objects
where status='INVALID'
order by object_type;

prompt .
prompt ============================================================================================
prompt .                   LAST REFRESH OF SNAPSHOTS (DBA_SNAPSHOTS)
prompt ============================================================================================

select owner, name, last_refresh 
from dba_snapshots 
where last_refresh < (SYSDATE - 1);


prompt .
prompt ============================================================================================
prompt .                   LAST JOBS SCHEDULED (DBA_JOBS)
prompt ============================================================================================

set arraysize 10
set linesize 65
col what format a65
col log_user format a10
col job format 9999
select job, log_user, last_date, last_sec, next_date, next_sec,
failures, what 
from dba_jobs
where failures > 0;

set linesize 100

prompt .
prompt =================================================================================================
prompt .                      ERROR- These segments will fail during NEXT EXTENT (DBA_SEGMENTS)
prompt =================================================================================================
column Tablespaces	format a30
column Segment		format a40
column "NEXT Needed"	format 999,999,999
column "MAX Available"	format 999,999,999
select	a.tablespace_name	"Tablespaces",
	a.owner			"Owner",
	a.segment_name		"Segment",
	a.next_extent		"NEXT Needed",
	b.next_ext		"MAX Available"
  from	sys.dba_segments a,
	(select tablespace_name,max(bytes) next_ext
	from sys.dba_free_space 
	group by tablespace_name) b
 where	a.tablespace_name=b.tablespace_name(+)
   and	b.next_ext < a.next_extent;

prompt =================================================================================================
prompt .                      WARNING- These segments > 70% of MAX EXTENT (DBA_SEGMENTS)
prompt =================================================================================================
column Tablespace	format a30
column Segment		format a40
column Used		format 9999
column Max		format 9999
select	tablespace_name	"Tablespace",
	owner		"Owner",
	segment_name	"Segment",
	extents		"Used",
	max_extents	"Max"
  from	sys.dba_segments
 where	(extents/decode(max_extents,0,1,max_extents))*100 > 70
   and	max_extents >0;

prompt =================================================================================================
prompt .                      LIST OF OBJECTS HAVING > 12 EXTENTS (DBA_EXTENTS)
prompt =================================================================================================
column Tablespace_ext	format a30
column Segment		format a40
column Count		format 9999
break on "Tablespace_ext" skip 1
select	tablespace_name "Tablespace_ext" ,
	owner		"Owner",
	segment_name    "Segment",
	count(*)        "Count"
  from	sys.dba_extents
 group by tablespace_name,owner,segment_name
 having count(*)>12
 order by 1,3 desc;

prompt .
prompt =================================================================================================
prompt .                      LIST OF INIT PARAMETER SETTING (V$PARAMETER)
prompt =================================================================================================
column Parameter format a41
column Value format a40
column Default format a7
column ID format 999
select  NAME            "Parameter",
        VALUE           "Value",
        ISDEFAULT       "Default",
        NUM             "ID"
  from  sys.v_$parameter
 order by 1;

prompt =================================================================================================
prompt End of Report

spool off

/* Remove temp spool scripts */
# host rm tmp7_*.sql

exit;