rem -----------------------------------------------------------------------
rem Filename:   ver.sql
rem Purpose:    Show database version with options intalled
rem             (handy for your HELP/ABOUT menu)
rem Date:       12-Nov-1999
rem Author:     Frank Naude (frank@ibi.co.za)
rem -----------------------------------------------------------------------

set head off feed off pages 0 serveroutput on

col banner format a72 wrap

select banner
from   sys.v_$version;

select '   With the '||parameter||' option'
from   sys.v_$option
where  value = 'TRUE';

select '   The '||parameter||' option is not installed'
from   sys.v_$option
where  value <> 'TRUE';

begin
    dbms_output.put_line('Port String: '||dbms_utility.port_string);
end;
/
