-- |
-- +-------------------------------------------------------------------------------------------+
-- | Objetivo   : Verificar arquivos de dados com SCN fuzzy e checkpoint                       |
-- | Criador    : Roberto Fernandes Sobrinho                                                   |
-- | Data       : 24/01/2025                                                                   |
-- | Exemplo    : @fuzzy_det.sql                                                               |  
-- | Arquivo    : fuzzy_det.sql                                                                |
-- | Referência : Baseado em x$kcvfh e v$datafile_header                                       |
-- +-------------------------------------------------------------------------------------------+
-- |                                                                https://dbasobrinho.com.br |
-- +-------------------------------------------------------------------------------------------+
-- | "O Guina não tinha dó, se reagir, BUMMM! vira pó!"                                        |
-- +-------------------------------------------------------------------------------------------+

SET TERMOUT OFF;
ALTER SESSION SET NLS_DATE_FORMAT='DD-MON-YY HH24:MI:SS';
EXEC dbms_application_info.set_module(module_name => 'fuzzy.sql', action_name => 'Fuzzy SCN Check');
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT
PROMPT +-------------------------------------------------------------------------------------------+
PROMPT | https://github.com/dbasobrinho/g_gold/blob/main/fuzzy_det.sql                             |
PROMPT +-------------------------------------------------------------------------------------------+
PROMPT | Script   : Verificar arquivos de dados com SCN fuzzy e checkpoint                         |
PROMPT | Instancia: &current_instance                                                              |
PROMPT | Versao   : 1.0                                                                            |
PROMPT +-------------------------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    10
SET HEADING     ON
SET LINES       188
SET PAGES       300


COLUMN file# FORMAT 99999 HEADING 'File#';
COLUMN name FORMAT A50 HEADING 'Name';
COLUMN checkpoint_change# FORMAT 999999999999999 HEADING 'Checkpoint|Change#';
COLUMN absolute_fuzzy_scn FORMAT 999999999999999 HEADING 'Absolute|Fuzzy SCN';
COLUMN min_pit_scn FORMAT 999999999999999 HEADING 'Min PIT SCN';


SET FEEDBACK OFF
SELECT 
    hxfil AS file#, 
    SUBSTR(hxfnm, 1, 50) AS name, 
    fhscn AS checkpoint_change#, 
    fhafs AS Absolute_Fuzzy_SCN, 
    MAX(fhafs) OVER () AS Min_PIT_SCN
FROM 
    x$kcvfh 
WHERE 
    fhafs != 0
/
SET FEEDBACK ON

COLUMN con_id FORMAT 9999 HEADING 'Container|ID';
COLUMN status FORMAT A10 HEADING 'Status';
COLUMN checkpoint_change FORMAT A20 HEADING 'Checkpoint|Change#';
COLUMN checkpoint_time FORMAT A20 HEADING 'Checkpoint|Time';
COLUMN cnt FORMAT 9999 HEADING 'Count';
COLUMN fuzzy FORMAT A6 HEADING 'Fuzzy';
COLUMN file_name FORMAT A100 HEADING 'file_name';


select  a.status,to_char(a.checkpoint_change#) checkpoint_change
      ,to_char(a.checkpoint_time, 'dd-mon-yyyy hh24:mi:ss') as checkpoint_time
      ,a.fuzzy, a.FILE#, x.file_name
  from v$datafile_header a, dba_data_files x
  where x.file_id(+) = a.FILE#
 order by a.checkpoint_change#,a.checkpoint_time, a.FILE#
/