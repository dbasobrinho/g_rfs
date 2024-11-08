col data         for a22
col message_text for a152
prompt
promPT  **MON_DBA 2 dias**
prompt
select to_char (ORIGINATING_TIMESTAMP, 'DD/MM/YYYY HH24:MI:SS') data, message_text
                from v$alert_log
                where trunc(ORIGINATING_TIMESTAMP) >  trunc((SYSDATE) -2)
                  and message_text like '%[MON_DBA]%'
/				  
