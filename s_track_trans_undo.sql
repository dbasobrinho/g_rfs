PROMPT ============================================================================
PROMPT CAPIVARA DA TRANSAÇÃO
PROMPT ============================================================================
PROMPT 1 = Resumido  (Default)
PROMPT 2 = Detalhado 
ACCEPT v_yes_no CHAR DEFAULT '1' PROMPT '== [1 OU 2] = '
PROMPT ============================================================================
PROMPT ===
PROMPT ==            Vamos Aproveitar, Ta Vaziii!!!!  working . . . . 
PROMPT =
COLUMN script_name NEW_VALUE v_script_name
SET termout OFF --hide this from the user
SELECT decode(lower('&v_yes_no'),'2','s_track_transaction_det.sql','s_track_transaction.sql') script_name
FROM dual;
SET termout ON
@&v_script_name

--@ashtop_hs.sql username,sql_id session_type='FOREGROUND' sysdate-1/24 sysdate