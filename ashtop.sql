PROMPT ============================================================================
PROMPT GV$ACTIVE_SESSION_HISTORY [1] / DBA_HIST_ACTIVE_SESS_HISTORY [2]
PROMPT ============================================================================
ACCEPT v_yes_no CHAR DEFAULT '1' PROMPT '== [1 OU 2] = '
PROMPT ============================================================================
PROMPT ===
PROMPT ==            Vamos Aproveitar, Ta Vaziii!!!!  working . . . . 
PROMPT =
COLUMN script_name NEW_VALUE v_script_name
SET termout OFF --hide this from the user
SELECT decode(lower('&v_yes_no'),'2','ashtop_hs.sql','ashtop_gv.sql') script_name
FROM dual;
SET termout ON
@&v_script_name

--@ashtop_hs.sql username,sql_id session_type='FOREGROUND' sysdate-1/24 sysdate