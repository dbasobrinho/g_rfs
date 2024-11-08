SET PAGESIZE 1000
SET LINESIZE 220
SET TIMING ON
SET TIME ON
COLUMN pass_create_time       FORMAT A22
COLUMN pass_change_time       FORMAT A22
COLUMN pass_hist_change_time  FORMAT A22
COLUMN name                   FORMAT A40
PROMPT 
ACCEPT USERNAME CHAR PROMPT 'USERNAME = '
PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Historico de Alteração de Senha                             |
PROMPT +------------------------------------------------------------------------+
PROMPT 
SELECT  name
       ,to_char(ctime,'dd/mm/yyyy hh24:mi:ss') pass_create_time
       ,to_char(ptime,'dd/mm/yyyy hh24:mi:ss') pass_change_time
       ,to_char(password_date,'dd/mm/yyyy hh24:mi:ss')  pass_hist_change_time
 FROM sys.user$
     ,sys.user_history$
WHERE user$.user# = user_history$.user#(+)
  AND user$.name = '&USERNAME'
/


