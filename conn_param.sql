set numformat 	999,999,999,999,999

set serveroutput on size unlimited

set echo            off
set heading         on
set linesize        250
set pagesize        50000
set termout         on
set timing          off
set time            on
set trimout         on
set trimspool       on
set truncate        on
set verify          off
set feed            off
set wrap            on
set heading         on
set verify			    off
set tab 			      off
set long            10000000
set longchunksize	  10000000
set arraysize 		  500

clear columns
clear breaks
clear computes
----------------------------------------------------------------------------------------------------------------------------------------------------------
set term off echo off feed off timing off

set describe depth 1 indent on

-- this must be here to avoid logon problems when SQLPATH env variable is unset
def SQLPATH=""


-- set SQLPATH variable to either Unix or Windows format

def SQLLOG=$SQLLOG -- (Unix/Mac OSX)
def SQLPATH=$SQLPATH -- (Unix/Mac OSX)
--def SQLPATH=%SQLPATH% -- (Windows)
--def SQLLOG=%SQLLOG% -- (Windows)


--def _start=start   -- Windows
--def _start=firefox -- Unix/Linux
def _start=open -- MacOS

def _delete="rm -f" -- Unix/MacOSX
--def _delete="del" -- Windows

def _tpt_tempdir=&SQLPATH/tmp
--def _tpt_tempdir=&SQLPATH\tmp


-- set seminar logging file

DEF _tpt_tempfile=sqlplus_tmpfile

col seminar_logfile new_value seminar_logfile
col tpt_tempfile new_value _tpt_tempfile

select
    to_char(sysdate, 'YYYYMMDD-HH24MISS') seminar_logfile
  , instance_name||'-'||to_char(sysdate, 'YYYYMMDD')||'-'||sys_context ('userenv','OS_USER')||'-'||sys_context ('userenv','TERMINAL') tpt_tempfile
from v$instance;

--def seminar_logfile=&SQLLOG/&_tpt_tempfile..log
def seminar_logfile=&SQLLOG\&_tpt_tempfile..log


spool sqlplus output
--spool &seminar_logfile append

-- some internal variables required for TPT scripts
define _ti_sequence=0
define _tptmode=normal
define _xt_seq=0

define _editor="vi -c 'set notitle'"
--define _external_editor="/Applications/Terminator.app/Contents/MacOS/Terminator vi "

-- assign the tracefile name to trc variable
def trc=unknown
column tracefile new_value trc format a80
select value ||'/'||(select instance_name from v$instance) ||'_ora_'||
       (select spid||case when traceid is not null then '_'||traceid else null end
            from v$process where addr = (select paddr from v$session
                                         where sid = (select sid from v$mystat
                                                    where rownum = 1
                                               )
                                    )
       ) || '.trc' tracefile
from v$parameter where name = 'user_dump_dest';

-- include username and connect identifier in prompt
COLUMN X NEW_VALUE Y
SELECT sys_context('userenv','INSTANCE_NAME')||'('||sys_context('userenv','SERVER_HOST')||') '||sys_context('userenv','SESSION_USER')||'('||sys_context('userenv','SID')||') ' as X
  from v$session where audsid = userenv('SESSIONID') ;
SET SQLPROMPT '&Y> '

--SET SQLPROMPT "_USER'@'_CONNECT_IDENTIFIER _DATE> "

-- format some more columns for common DBA queries
col first_change# for 99999999999999999
col next_change# for 99999999999999999
col checkpoint_change# for 99999999999999999
col resetlogs_change# for 99999999999999999

set editfile afiedit.sql

ALTER SESSION SET NLS_DATE_FORMAT='DD-MM-YYYY HH24:MI:SS';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT='DD-MM-YYYY HH24:MI:SS.FF';

prompt tracefile => &trc

-- Used by Trusted Oracle
COLUMN ROWLABEL FORMAT A15

-- Used for the SHOW ERRORS command
COLUMN LINE/COL FORMAT A8
COLUMN ERROR    FORMAT A65  WORD_WRAPPED

-- Used for the SHOW SGA command
COLUMN name_col_plus_show_sga FORMAT a24
COLUMN units_col_plus_show_sga FORMAT a15
-- Defaults for SHOW PARAMETERS
COLUMN name_col_plus_show_param FORMAT a50 HEADING NAME
COLUMN value_col_plus_show_param FORMAT a130 HEADING VALUE WORD_WRAPPED
COLUMN TYPE FORMAT a15 HEADING TYPE WORD_WRAPPED

COLUMN PARAMETER FORMAT a40 HEADING PARAMETER
COLUMN VALUE FORMAT a130 HEADING VALUE WORD_WRAPPED

-- Defaults for SHOW RECYCLEBIN
COLUMN origname_plus_show_recyc   FORMAT a16 HEADING 'ORIGINAL NAME'
COLUMN objectname_plus_show_recyc FORMAT a30 HEADING 'RECYCLEBIN NAME'
COLUMN objtype_plus_show_recyc    FORMAT a12 HEADING 'OBJECT TYPE'
COLUMN droptime_plus_show_recyc   FORMAT a19 HEADING 'DROP TIME'

-- Defaults for SET AUTOTRACE EXPLAIN report
-- These column definitions are only used when SQL*Plus
-- is connected to Oracle 9.2 or earlier.
COLUMN id_plus_exp FORMAT 990 HEADING i
COLUMN parent_id_plus_exp FORMAT 990 HEADING p
COLUMN plan_plus_exp FORMAT a60
COLUMN object_node_plus_exp FORMAT a8
COLUMN other_tag_plus_exp FORMAT a29
COLUMN other_plus_exp FORMAT a44

-- Default for XQUERY
COLUMN result_plus_xquery HEADING 'Result Sequence'

-- Outros
COLUMN CURRENT_SCN for 999999999999999
COLUMN USERNAME    for a30
COLUMN ACCOUNT_STATUS for a20
COLUMN PROFILE for a30

-- describe
COLUMN "Name" FORMAT a30
----------------------------------------------------------------------------------------------
set term on echo off feed on timing on time on
