-- |----------------------------------------------------------------------------|
-- | Objetivo   : Usando o SQLPATCH para capturar info de estatisticas          |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 26/05/220 >> Aproveitando e fazendo no pelo                   |
-- | Exemplo    : coe_test_sqlid_patch                                          |
-- | Arquivo    : coe_test_sqlid_patch.sql                                      | 
-- | Modificacao:                                                               |
-- | Referencia : https://oracle-base.com/articles/11g/sql-repair-advisor-11g   | 
-- +----------------------------------------------------------------------------+
SET VERIFY      OFF
SET TERMOUT OFF;
col fn new_value banco;
SELECT 'Nome do Arquivo_'||TO_CHAR(SYSDATE, 'YYMMDD')||'.log' as fn from dual; 
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : SQLPATCH SQL ID, INPUT HINT                                 |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

PROMPT
PROMPT
ACCEPT sql_id     CHAR PROMPT 'Enter SQL ID                : ' default aknpf417xwba0
ACCEPT m_child_no CHAR PROMPT "Enter C.Number <>default=0> :"  default 0
PROMPT

SET TERMOUT OFF;
col fn new_value banco;
SELECT '&&sql_id'||'_sql_patch_apaga_depois_nao_esquece_'||TO_CHAR(SYSDATE, 'YYYYMMDD_hh24miss')||'.sql' as fn from dual;
SET TERMOUT ON;


SET FEEDBACK  OFF;
SET TIMING    OFF;
select 'GATHER_PLAN_STATISTICS' HINT_TEXT FROM DUAL UNION ALL
select 'PARALLEL'               HINT_TEXT FROM DUAL UNION ALL
select 'PARALLEL(big_table,10)' HINT_TEXT FROM DUAL UNION ALL
select 'ESCOLHE VOCE :)'        HINT_TEXT FROM DUAL UNION ALL
select ' '                      HINT_TEXT FROM DUAL 
/
SET FEEDBACK  ON;
PROMPT
ACCEPT HINT_TEXT CHAR PROMPT "HINT_TEXT | DEFAULT = GATHER_PLAN_STATISTICS  :"  default GATHER_PLAN_STATISTICS
PROMPT
set serveroutput on size 9999
set echo on;
DECLARE
    m_clob  clob;
BEGIN
    SELECT sql_fulltext into m_clob
      FROM v$sql
     WHERE sql_id = '&&sql_id'
       AND child_number = &&m_child_no ;
 
    SYS.DBMS_SQLDIAG_INTERNAL.I_CREATE_PATCH(
        sql_text    => m_clob,
        hint_text   => '&&HINT_TEXT' ,
        name        => 'GUINA_Patch_&&sql_id&&m_child_no'
        ); 
END;
/
set echo off;
set lines 200
SELECT name, created,  FORCE_MATCHING, STATUS FROM dba_sql_patches where name = 'GUINA_Patch_&&sql_id&&m_child_no'
/
select 'BEGIN sys.DBMS_SQLDIAG.drop_sql_patch(name => ''GUINA_Patch_&&sql_id&&m_child_no''); END; '||chr(10)||'/' as APAGA_DEPOIS_URGENTE from dual
/
UNDEFINE sql_id 
UNDEFINE m_child_no
UNDEFINE HINT_TEXT
SET TERMOUT OFF;
$ORACLE_HOME/sqlplus/admin/glogin.sql
SET TERMOUT ON;
PROMPT.                                                                                                                     ______ _ ___
PROMPT.                                                                                                                    |_  / _` / __| +-+-+-+-+-+-+-+-+-+-+
PROMPT.                                                                                                         _   _   _   / / (_| \__ \ |r|f|s|o|b|r|i|n|h|o|
PROMPT.                                                                                                        (_) (_) (_) /___\__,_|___/ +-+-+-+-+-+-+-+-+-+-+
PROMPT

------------------  DECLARE
------------------  	m_clob  clob;
------------------  BEGIN
------------------  	SELECT sql_fulltext 
------------------  	into m_clob
------------------  	  FROM v$sql
------------------  	 WHERE sql_id = '9m3mt6abyba9h'
------------------  	   AND child_number = 0 ;
------------------  
------------------  	SYS.DBMS_SQLDIAG_INTERNAL.I_CREATE_PATCH(
------------------  		sql_text    => m_clob,
------------------  		hint_text   => 'INDEX(SAN@SEL$1 SIVA_ADM_NOTAS_N8) ORDERED USE_HASH(SAN@SEL$1)' ,
------------------  		name        => 'GUINA_Patch_9m3mt6abyba9h_0',
------------------  		VALIDATE    => TRUE
------------------  		);
------------------  END;
------------------  /
  
  
  
  
  
  
-------set serveroutput on size 9999
-------set echo on;
-------DECLARE
-------    m_clob  clob;
-------BEGIN
-------    SELECT sql_fulltext into m_clob
-------      FROM v$sql
-------     WHERE sql_id = 'f36knvx60mmud'
-------       AND child_number = 0 ;
------- 
-------    SYS.DBMS_SQLDIAG_INTERNAL.I_CREATE_PATCH(
-------        sql_text    => m_clob,
-------        hint_text   => 'GATHER_PLAN_STATISTICS',
-------        name        => 'GUINA_Patch_f36knvx60mmud'
-------        ); 
-------END;
-------/  


------   BEGIN
------     SYS.DBMS_SQLDIAG_INTERNAL.i_create_patch(
------       sql_text  => 'SELECT * FROM big_table WHERE id >= 8000',
------       hint_text => 'PARALLEL(big_table,10)',
------       name      => 'big_table_sql_patch');
------   END;
------   /
------     
  


