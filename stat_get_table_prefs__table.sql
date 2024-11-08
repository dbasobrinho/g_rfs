rem
rem     Script: get_table_prefs.sql
rem     Dated:  ???
rem     Author: Jonathan Lewis
rem
rem     Last tested
rem             19.11.0.0
rem
rem     Notes
rem     Report the table preferences for a given
rem     owner and table.
rem
rem     Needs to find a list of all legal preferences.
rem             Global prefs are in:    optstat_hist_control$ (sname, spare4)
rem             Table prefs are in:     optstat_user_prefs$ (valchar / valnum)
rem
rem     The public view is dba_tab_stat_prefs / user_tab_stat_prefs.
rem     But if a table has no prefs set there are no rows in the view
rem
rem     This script currently has to be run by sys or a user with 
rem     the select privileges on sys.optstat_hist_control$ (and
rem     execute on dbms_stats).
rem
 
define m_owner = '&enter_schema'
define m_table = '&enter_tablename'
 
 
<<anon_block>>
declare
        pref_count      number(2,0) := 0;
begin
        dbms_output.new_line;
        dbms_output.put_line(
                        rpad('Preference',32) || ' ' ||
                        rpad('Table value',32) || ' ' ||
                        '[Global value]'
        );
        dbms_output.put_line(
                        rpad('=',32,'=') || ' ' ||
                        rpad('=',32,'=') || ' ' ||
                        '================================'
        );
 
        <<optstat_loop>>
        for c1 in (
                select  sname, spare4 
                from    sys.optstat_hist_control$
                where   spare4 is not null
        ) loop
                anon_block.pref_count := anon_block.pref_count + 1;
                 
                dbms_output.put_line(
                        rpad(c1.sname,32) || ' ' ||
                        rpad(dbms_stats.get_prefs(c1.sname,'&m_owner','&m_table'),32) || ' ' 
                        || '[' || c1.spare4 || ']'
                );      
        end loop optstat_loop;
 
        dbms_output.new_line;
        dbms_output.put_line('Preferences reported: ' || anon_block.pref_count);
end;
/