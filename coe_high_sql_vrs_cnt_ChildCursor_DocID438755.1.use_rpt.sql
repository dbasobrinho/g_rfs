-------Troubleshooting: High Version Count Issues (Doc ID 296377.1)
-------https://blogs.oracle.com/performancediagnosis/diagnosis-of-a-high-version-count
-------https://blogs.oracle.com/optimizer/
-------
------start version_rpt3_25.sql
------INSTRUCTIONS
------Generate reports for all cursors with more than 100 versions using SQL_ID (10g and up)
------set pages 2000 lines 100
------SELECT b.*
------FROM v$sqlarea a ,
------  TABLE(version_rpt(a.sql_id)) b
------WHERE loaded_versions >=100;                  /* Set to 30 in 11.2.0.3 and in versions where fix of bug 10187168 was initially introduced */
------Generate reports for all cursors with more than 100 versions using HASH_VALUE
------set pages 2000 lines 100
------SELECT b.*
------FROM v$sqlarea a ,
------  TABLE(version_rpt(NULL,a.hash_value)) b
------WHERE loaded_versions>=100;                   /* Set to 30 in 11.2.0.3 and in versions where fix of bug 10187168 was initially introduced */
------Generate the report for cursor with sql_id cyzznbykb509s
------set pages 2000 lines 100
------SELECT * FROM TABLE(version_rpt('cyzznbykb509s'));
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Como Instalar e Usar                +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 2.1                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
PROMPT ==========================================================================
PROMPT +------------------------------------------------------------------------+
PROMPT | Install Tool                                                           |
PROMPT +------------------------------------------------------------------------+
PROMPT @version_rpt3_25.sql
PROMPT ===
PROMPT OU APROVEITA QUE TA VAZI....
PROMPT ===
PROMPT @coe_high_sql_vrs_cnt_ChildCursor_DocID438755.1.install.sql
PROMPT ==========================================================================
PROMPT +------------------------------------------------------------------------+
PROMPT | Reports for all cursors with more than 100 versions using SQL_ID       |
PROMPT +------------------------------------------------------------------------+
PROMPT   set pages 2000 lines 100
PROMPT   SELECT b.*
PROMPT     FROM v$sqlarea a ,TABLE(version_rpt(a.sql_id)) b
PROMPT    WHERE loaded_versions >=100;     
PROMPT ==========================================================================
PROMPT +------------------------------------------------------------------------+
PROMPT | Reports for all cursors with more than 100 versions using HASH_VALUE   |
PROMPT +------------------------------------------------------------------------+
PROMPT   set pages 2000 lines 100
PROMPT   SELECT b.*
PROMPT     FROM v$sqlarea a ,TABLE(version_rpt(NULL,a.hash_value)) b
PROMPT    WHERE loaded_versions >=100;  
PROMPT ==========================================================================
PROMPT +------------------------------------------------------------------------+
PROMPT | Generate the report for cursor with sql_id                             |
PROMPT +------------------------------------------------------------------------+
PROMPT   set pages 2000 lines 100
PROMPT   SELECT * FROM TABLE(version_rpt('cyzznbykb509s'));
PROMPT ==========================================================================
PROMPT.                                                                                                                     ______ _ ___
PROMPT.                                                                                                                    |_  / _` / __| +-+-+-+-+-+-+-+-+-+-+
PROMPT.                                                                                                         _   _   _   / / (_| \__ \ |r|f|s|o|b|r|i|n|h|o|
PROMPT.                                                                                                        (_) (_) (_) /___\__,_|___/ +-+-+-+-+-+-+-+-+-+-+
PROMPT


