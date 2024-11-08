spool ch305924_3_consulta.log;
set echo off
set pagesize 0
set linesize 30767
set trimspool on
set heading on
set arraysize 1
set feedback on
set long 1000000
set num 15
set pagesize 20000
prompt
prompt
prompt ========================
prompt User Conectado
prompt ========================
prompt
show user
set serveroutput on size 100000
col OWNER for a15
prompt ===============================
prompt ----> Instituição e data/hora do Oracle
prompt ===============================
SELECT ID_BANCO || ' - ' ||NOME_BANCO || ' - ' || to_char(sysdate, 'dd/mm/yyyy hh24:mi:ss')
FROM   BC_CONFIGURACAO BNF, BC_BANCO BCO
WHERE  BCO.ID_BANCO = BNF.INSTITUICAO;

prompt ===============================
prompt ----> SISTEMAS QUE POSSUI
prompt ===============================
select nome_sub_sis, 
       ind_possui_sistema 
  from sd_sub_sis
 order by 1;

prompt ===============================
prompt ----> ID_INSTITUICAO (SD_CONFIG)
prompt ===============================
select id_instituicao 
  from sd_config;
  
prompt ===================================
prompt == >>> show parameters  <<<
prompt ===================================
show parameters

prompt

prompt

prompt
prompt ====================================
prompt ----> Nome e versao da Base de Dados
prompt ====================================

SELECT 'BASE...: ' || GLOBAL_NAME
FROM   GLOBAL_NAME;

SELECT 'ORACLE.: ' || BANNER
FROM V$VERSION;

SELECT SYS_CONTEXT('USERENV', 'SERVER_HOST')
FROM DUAL;
--

prompt ===============================
prompt ----> Versão dos Sistemas
prompt ===============================
column versao         format a13
column data_aplicacao format a20

select id_sub_sistema,
       num_versao ||'.'|| num_patch ||'.'|| pa.num_sub_patch versao,
       data_aplicacao
from   bc_patch pa
where  data_aplicacao in (select max(data_aplicacao)
                          from bc_patch pa2
                          where pa.id_sub_sistema = pa2.id_sub_sistema)
order by data_aplicacao;

prompt

prompt ===============================
prompt ----> Data de referência do sistema
prompt ===============================
Select  ss.id_sub_sistema,
        ss.data_referencia,
        ss.situacao,
        ss.processando
from    bc_sub_sistema ss
order by ss.id_sub_sistema;



prompt ===============================
prompt == >>> OBJETOS DESCOMPILADOS  <<<
prompt ===============================
select rpad(OBJECT_NAME, 90, '-') as Objeto,
       OBJECT_TYPE as tipo
from   all_objects
where  object_type in
       ('PROCEDURE', 'FUNCTION', 'PACKAGE BODY', 'VIEW', 'TRIGGER', 'INDEX')
and    status != 'VALID'
order  by OBJECT_TYPE,
          OBJECT_NAME;

prompt ===================================
prompt == >>> sinonimos descompilados  <<<
prompt ===================================

select o.OWNER,o.OBJECT_NAME,O.OBJECT_TYPE,O.LAST_DDL_TIME,O.CREATED
from all_objects o
where o.OWNER = 'PUBLIC' and
      o.status != 'VALID' and
      o.OBJECT_TYPE = 'SYNONYM'
order by o.OWNER,o.OBJECT_NAME;
          
prompt --
prompt prompt ============================ ============================ ============================ ============================

prompt
prompt
prompt
prompt
prompt ===============================
prompt == >>> INDEXES INVALIDOS <<< ===
prompt ===============================
column INDEX_NAME   format a40
column STATUS       format a10
select i.INDEX_NAME, i.status 
from all_indexes i 
where i.TABLE_OWNER = 'SDBANCO'
AND   i.TABLE_NAME IN ('BC_CADOC_3040_OPERACAO','BC_CADOC_3040_CLIENTE','BC_CADOC_3040_ADICIONAL','BC_PESSOA','BC_RISCO_SISTEMA_EXTERNO','CC_CC','EM_VARIACAO_DIARIA_CONTRATO','EM_CONTRATO','BC_CENTRAL_RISCO_EMPRESA_PER')
and i.status != 'VALID'
order by i.INDEX_NAME, i.status;

prompt
prompt
prompt
prompt ===============================
prompt == >>> TRIGGERS DESATIVADAS  <<<
prompt ===============================
select distinct TRIGGER_NAME
from   all_triggers
where  STATUS = 'DISABLED'
and    OWNER = 'SDBANCO'
order by TRIGGER_NAME;

prompt
prompt
prompt
prompt ===============================
prompt == >>> FKS Sem indice  <<<
prompt ===============================
COLUMN create_index format a200

SELECT 'CREATE INDEX IDX_' || substr(dc.constraint_name,1,27) || ' on ' || dc.owner || '.' || dc.table_name || '(' || 
( select rtrim (xmlagg (xmlelement (e, COLUMN_NAME || ',')).extract ('//text()'), ',') AS colunas 
from all_cons_columns cc where cc.constraint_name = DC.CONSTRAINT_NAME group by constraint_name) || ');' create_index
FROM   all_CONSTRAINTS DC
WHERE  DC.CONSTRAINT_TYPE = 'R' 
-- TODAS AS FKS QUE POSSUEM PK NAS TABELAS ABAIXO
AND    EXISTS (SELECT 1 
               FROM  ALL_CONSTRAINTS PK
               WHERE PK.OWNER = DC.R_OWNER
               AND   PK.CONSTRAINT_NAME = DC.R_CONSTRAINT_NAME
               AND   PK.OWNER = 'SDBANCO'
               AND   PK.TABLE_NAME IN ('BC_CADOC_3040_OPERACAO','BC_CADOC_3040_CLIENTE','BC_CADOC_3040_ADICIONAL','BC_PESSOA','BC_RISCO_SISTEMA_EXTERNO','CC_CC','EM_VARIACAO_DIARIA_CONTRATO','EM_CONTRATO','BC_CENTRAL_RISCO_EMPRESA_PER'))
-- E NAO EXISTEM INDICES CRIADOS PARA AS COLUNAS DESSA FK               
AND    EXISTS (SELECT 1 FROM ALL_CONS_COLUMNS CC
               WHERE  CC.OWNER = DC.OWNER AND CC.CONSTRAINT_NAME = DC.CONSTRAINT_NAME
               AND    NOT EXISTS (SELECT 1 FROM ALL_IND_COLUMNS IC
               WHERE  IC.TABLE_OWNER = CC.OWNER 
               AND IC.TABLE_NAME = CC.TABLE_NAME 
               AND IC.COLUMN_NAME = CC.COLUMN_NAME));  

			   
			   
prompt
prompt
prompt
prompt ==============================================================================================================
prompt == >>> Analise de informacoes sobre estatisticas Lockadas das tabelas envolvidas no processo  <<<
prompt ==============================================================================================================
SELECT OWNER,
       TABLE_NAME,
       DECODE(stattype_locked,NULL, 'SEM LOCK',stattype_locked) "Type of statistics lock",
       NUM_ROWS,
       NVL(TO_CHAR(LAST_ANALYZED, 'DD-MM-YYYY HH24:MI:SS'), 'NAO COLETADO!') "ULT.COLETA ESTATISTICA"
  FROM all_tab_statistics ts
 WHERE ts.TABLE_NAME IN ('BC_CADOC_3040_OPERACAO','BC_CADOC_3040_CLIENTE','BC_CADOC_3040_ADICIONAL','BC_PESSOA','BC_RISCO_SISTEMA_EXTERNO','CC_CC','EM_VARIACAO_DIARIA_CONTRATO','EM_CONTRATO','BC_CENTRAL_RISCO_EMPRESA_PER')
 and   ts.OWNER = 'SDBANCO'
 ORDER BY OWNER, TABLE_NAME;
 
 
prompt
prompt
prompt
prompt ==========================================
prompt == >>> Listando index(es) das tabelas  <<<
prompt ==========================================
col "Nome da Tabela" for a35
col "Nome do index" for a35
col "Nome da Coluna" for a35
col "Nome da Owner" for a35
select TABLE_OWNER "Nome do Owner", 
       table_name "Nome da Tabela", 
       index_name "Nome do index", 
       column_name "Nome da Coluna", 
       to_char(column_position) "Posicao" 
from all_ind_columns i
where i.TABLE_OWNER = 'SDBANCO'
AND   i.table_name in ('BC_CADOC_3040_OPERACAO','BC_CADOC_3040_CLIENTE','BC_CADOC_3040_ADICIONAL','BC_PESSOA','BC_RISCO_SISTEMA_EXTERNO','CC_CC','EM_VARIACAO_DIARIA_CONTRATO','EM_CONTRATO','BC_CENTRAL_RISCO_EMPRESA_PER')
order by table_name,index_name,column_position;


prompt
prompt
prompt
prompt ================================================
prompt == >>> Verificando Estatisticas das Tabelas  <<<
prompt ================================================
select a.OWNER, a.TABLE_NAME,a.NUM_ROWS,a.LAST_ANALYZED 
from all_tables a 
where a.OWNER = 'SDBANCO'
AND a.TABLE_NAME in ('BC_CADOC_3040_OPERACAO','BC_CADOC_3040_CLIENTE','BC_CADOC_3040_ADICIONAL','BC_PESSOA','BC_RISCO_SISTEMA_EXTERNO','CC_CC','EM_VARIACAO_DIARIA_CONTRATO','EM_CONTRATO','BC_CENTRAL_RISCO_EMPRESA_PER')
order by a.OWNER, a.TABLE_NAME;


prompt
prompt
prompt
prompt ============================================
prompt == >>> Verificando situacao dos indices  <<<
prompt ============================================
select a.TABLE_NAME,a.INDEX_NAME,a.UNIQUENESS,a.DISTINCT_KEYS,a.num_rows,a.status,a.LAST_ANALYZED 
from   all_indexes a 
where a.OWNER = 'SDBANCO'
AND   a.TABLE_NAME in ('BC_CADOC_3040_OPERACAO','BC_CADOC_3040_CLIENTE','BC_CADOC_3040_ADICIONAL','BC_PESSOA','BC_RISCO_SISTEMA_EXTERNO','CC_CC','EM_VARIACAO_DIARIA_CONTRATO','EM_CONTRATO','BC_CENTRAL_RISCO_EMPRESA_PER');



prompt
prompt
prompt
prompt ==============================================================================================================
prompt == >>> Analise de informacoes sobre coleta de estatisticas e histogram das tabelas envolvidas no processo  <<<
prompt ==============================================================================================================


set lines 900 pages 900 
col column_name for a30
col INDEX_TYPE for a10
BREAK ON TABLE_NAME SKIP PAGE ON JOB_ID SKIP 1
SELECT OWNER,
       TABLE_NAME,
       COLUMN_NAME,
       NUM_DISTINCT,
       DECODE(HISTOGRAM, 'NONE', 'NAO COLETADO!', HISTOGRAM) "HISTOGRAM",
       NUM_BUCKETS BUCKETS,
       NVL(TO_CHAR(LAST_ANALYZED, 'DD-MM-YYYY HH24:MI:SS'), 'NAO COLETADO!') "ULT.COLETA ESTATISTICA"
  FROM all_TAB_COLUMNS
 WHERE TABLE_NAME IN ('BC_CADOC_3040_OPERACAO','BC_CADOC_3040_CLIENTE','BC_CADOC_3040_ADICIONAL','BC_PESSOA','BC_RISCO_SISTEMA_EXTERNO','CC_CC','EM_VARIACAO_DIARIA_CONTRATO','EM_CONTRATO','BC_CENTRAL_RISCO_EMPRESA_PER')
 and   OWNER = 'SDBANCO'  
 ORDER BY OWNER, TABLE_NAME, COLUMN_ID;

 
prompt
prompt
prompt
prompt ===================================================================================
prompt == >>> Analise de informacoes sobre indices das tabelas envolvidas no processo  <<<
prompt ===================================================================================
col column_name for a30
col INDEX_TYPE for a10
SELECT T.OWNER,
t.table_name,
t.index_name,
c.COLUMN_POSITION "Pos",
c.COLUMN_NAME,
t.index_type,
t.status,
t.distinct_keys,
t.num_rows,
case
when tt.BLOCKS > 0 then
trunc(T.clustering_factor / tT.blocks, 2)
else 0
End "CF/Blocks = 1",
decode(t.uniqueness, 'NONUNIQUE', 'NON', t.uniqueness) "Unique",
NVL(TO_CHAR(T.LAST_ANALYZED, 'YYYY-DD-MM HH24:MI:SS'),
       'NAO COLETADO!') "Ult.Coleta Estatistica"
FROM dba_indexes t, dba_ind_columns c, dba_tables tt
where T.TABLE_OWNER = 'SDBANCO'
AND t.TABLE_NAME IN ('BC_CADOC_3040_OPERACAO','BC_CADOC_3040_CLIENTE','BC_CADOC_3040_ADICIONAL','BC_PESSOA','BC_RISCO_SISTEMA_EXTERNO','CC_CC','EM_VARIACAO_DIARIA_CONTRATO','EM_CONTRATO','BC_CENTRAL_RISCO_EMPRESA_PER')
and c.INDEX_OWNER = t.owner
and c.INDEX_NAME = t.index_name
and tt.OWNER = t.TABLE_OWNER
and tt.table_NAME = t.table_name
order by T.OWNER, t.table_name, t.index_name, c.COLUMN_POSITION; 
 
 
 
 
prompt
prompt
prompt
prompt =========================================================================
prompt == >>> Analise do Percentual da Amostragem da Coleta de Estatisticas  <<<
prompt ========================================================================= 
COL OWNER FOR A10
COL table_name FOR A30
SELECT owner,table_name,
trunc(sample_size/num_rows*100) "Amostragem %",
TO_CHAR(last_analyzed,'dd/mm/yyyy hh:mi'),
num_rows,
sample_size
FROM sys.dba_tab_statistics
where owner = 'SDBANCO'
and object_type = 'TABLE'
AND TABLE_NAME IN ('BC_CADOC_3040_OPERACAO','BC_CADOC_3040_CLIENTE','BC_CADOC_3040_ADICIONAL','BC_PESSOA','BC_RISCO_SISTEMA_EXTERNO','CC_CC','EM_VARIACAO_DIARIA_CONTRATO','EM_CONTRATO','BC_CENTRAL_RISCO_EMPRESA_PER')
and num_rows > 0
and trunc(sample_size/num_rows*100) < 98
ORDER BY owner, table_name DESC;
 
prompt
prompt
prompt
prompt ======================================== 
prompt == >>> Plano de Execucao do 1 Union  <<<
prompt ======================================== 
explain plan SET STATEMENT_ID='CONSULTA_T1' for 
SELECT CC.PRIMEIRO_TITULAR ID_PESSOA,
       PES.INSCRICAO,
       SBCRETORNARAIZCNPJ(PES.INSCRICAO, PES.TIPO_PESSOA) RAIZ_CNPJ,
       PES.TIPO_PESSOA TIPO_PESSOA
  FROM BC_PESSOA PES, CC_CC CC
 WHERE CC.SITUACAO_CC IN ('L', 'B')
   AND PES.ID_PESSOA = CC.PRIMEIRO_TITULAR
   AND :B1 = 'N';   
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(null,'CONSULTA_T1','ALL'));

prompt
prompt
prompt
prompt ======================================== 
prompt == >>> Plano de Execucao do 2 Union  <<<
prompt ========================================   
explain plan SET STATEMENT_ID='CONSULTA_T2' for 
SELECT PES.ID_PESSOA,
       PES.INSCRICAO,
       SBCRETORNARAIZCNPJ(PES.INSCRICAO, PES.TIPO_PESSOA) RAIZ_CNPJ,
       PES.TIPO_PESSOA TIPO_PESSOA
  FROM BC_PESSOA PES, EM_VARIACAO_DIARIA_CONTRATO VC, EM_CONTRATO CO
 WHERE CO.CLIENTE = PES.ID_PESSOA
   AND VC.CONTRATO = CO.ID_CONTRATO
   AND VC.DATA = :B2
   AND :B1 = 'N';   
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(null,'CONSULTA_T2','ALL'));

prompt
prompt
prompt
prompt ======================================== 
prompt == >>> Plano de Execucao do 3 Union  <<<
prompt ========================================   
explain plan SET STATEMENT_ID='CONSULTA_T3' for 
SELECT PES.ID_PESSOA,
       TO_NUMBER(RSE.CNPJ_CPF) INSCRICAO,
       RSE.RAIZ_CNPJ,
       RSE.TIPO_PESSOA
  FROM BC_PESSOA PES, BC_RISCO_SISTEMA_EXTERNO RSE
 WHERE RSE.DATA_RATING_SDBANCO = :B2
   AND PES.INSCRICAO(+) = TO_NUMBER(RSE.CNPJ_CPF)
   AND :B1 = 'N'
   AND ((:B3 IS NULL AND RSE.NUM_EMPRESA_COLIGADA IS NULL) OR
       (:B3 IS NOT NULL AND (RSE.NUM_EMPRESA_COLIGADA IS NULL OR
       (RSE.NUM_EMPRESA_COLIGADA IS NOT NULL AND
       RSE.NUM_EMPRESA_COLIGADA = :B3))));   
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(null,'CONSULTA_T3','ALL'));


prompt
prompt
prompt
prompt ======================================== 
prompt == >>> Plano de Execucao do 4 Union  <<<
prompt ========================================   
explain plan SET STATEMENT_ID='CONSULTA_T4' for 
SELECT DISTINCT PES.ID_PESSOA,
                TO_NUMBER(OPER.CNPJ_CPF) INSCRICAO,
                CLI.CNPJ_CPF RAIZ_CNPJ,
                DECODE(CLI.ID_TIPO_CLIENTE, 1, 'F', 3, 'F', 5, 'F', 'J') TIPO_PESSOA
  FROM BC_PESSOA                    PES,
       BC_CADOC_3040_CLIENTE        CLI,
       BC_CADOC_3040_OPERACAO       OPER,
       BC_CENTRAL_RISCO_EMPRESA_PER PER
 WHERE PER.DATA_BASE = :B2
   AND PER.ID_EMPRESA_PERIODO = CLI.ID_EMPRESA_PERIODO
   AND CLI.ID_EMPRESA_PERIODO = OPER.ID_EMPRESA_PERIODO
   AND CLI.ID_CADOC_3040_CLIENTE = OPER.ID_CADOC_3040_CLIENTE
   AND PES.INSCRICAO(+) = TO_NUMBER(OPER.CNPJ_CPF)
   AND :B1 = 'S'
   AND (:B3 IS NULL OR :B3 = PER.NUM_EMPRESA_COLIGADA)
   AND NOT EXISTS
 (SELECT 1
          FROM BC_CADOC_3040_ADICIONAL ADIC
         WHERE ADIC.ID_EMPRESA_PERIODO = OPER.ID_EMPRESA_PERIODO
           AND ADIC.ID_CADOC_3040_OPERACAO = OPER.ID_CADOC_3040_OPERACAO
           AND ADIC.ID_INFORMACAO_ADIC BETWEEN 301 AND 399);   
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(null,'CONSULTA_T4','ALL'));
 

prompt
prompt
prompt
prompt ======================================== 
prompt == >>> Plano de Execucao 5 SQL Ajustado  <<<
prompt ========================================   
explain plan SET STATEMENT_ID='CONSULTA_T5' for 
select      (select id_pessoa 
              from   bc_pessoa pes
              where  pes.inscricao         = to_number(oper.cnpj_cpf)   ) id_pessoa,
             to_number(oper.cnpj_cpf) inscricao, -- na tabela de operacoes sempre tem o CPF/CNPJ completo
             cli.cnpj_cpf             raiz_cnpj, -- na tabela de clientes ja temos a raiz
             -- Tipo pessoa da BC_CADOC_3040_TIPO_CLIENTE
             decode( cli.id_tipo_cliente,
                            1, 'F',
                            3, 'F',
                            5, 'F',
                               'J' ) tipo_pessoa
      from   bc_cadoc_3040_cliente cli,
             bc_cadoc_3040_operacao oper,
             bc_central_risco_empresa_per per
      where  per.data_base             = :vDataCursor                                  and
             per.id_empresa_periodo    = cli.id_empresa_periodo                        and
             cli.id_empresa_periodo    = oper.id_empresa_periodo                       and
             cli.id_cadoc_3040_cliente = oper.id_cadoc_3040_cliente                    and
             'S'    = 'S'                                           and
             ( 1 is null or
               1 = per.num_empresa_coligada )                      and
             --
             -- operações de saída não sensibilizam a classificação de risco
             --
             not exists ( select /*+ INDEX (adic IBC_CADOC3040_ADC_BC_EMPPER) */ 1
                          from   bc_cadoc_3040_adicional adic
                          where  adic.id_empresa_periodo     = oper.id_empresa_periodo     and
                                 adic.id_cadoc_3040_operacao = oper.id_cadoc_3040_operacao and
                                 adic.id_informacao_adic between 301 and 399 )
    group by id_pessoa, oper.cnpj_cpf, cli.cnpj_cpf, cli.id_tipo_cliente;   
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(null,'CONSULTA_T5','ALL')); 
 


prompt
prompt
prompt
prompt =============================================== 
prompt == >>> Plano de Execucao 6 SQL Atual Lento  <<<
prompt ===============================================   
explain plan SET STATEMENT_ID='CONSULTA_T6' for 
SELECT DISTINCT PES.ID_PESSOA,
                TO_NUMBER(OPER.CNPJ_CPF) INSCRICAO,
                CLI.CNPJ_CPF RAIZ_CNPJ,
                DECODE(CLI.ID_TIPO_CLIENTE, 1, 'F', 3, 'F', 5, 'F', 'J') TIPO_PESSOA
  FROM BC_PESSOA                    PES,
       BC_CADOC_3040_CLIENTE        CLI,
       BC_CADOC_3040_OPERACAO       OPER,
       BC_CENTRAL_RISCO_EMPRESA_PER PER
 WHERE PER.DATA_BASE = :B2
   AND PER.ID_EMPRESA_PERIODO = CLI.ID_EMPRESA_PERIODO
   AND CLI.ID_EMPRESA_PERIODO = OPER.ID_EMPRESA_PERIODO
   AND CLI.ID_CADOC_3040_CLIENTE = OPER.ID_CADOC_3040_CLIENTE
   AND PES.INSCRICAO(+) = TO_NUMBER(OPER.CNPJ_CPF)
   AND :B1 = 'S'
   AND (:B3 IS NULL OR :B3 = PER.NUM_EMPRESA_COLIGADA)
   AND NOT EXISTS
 (SELECT 1
          FROM BC_CADOC_3040_ADICIONAL ADIC
         WHERE ADIC.ID_EMPRESA_PERIODO = OPER.ID_EMPRESA_PERIODO
           AND ADIC.ID_CADOC_3040_OPERACAO = OPER.ID_CADOC_3040_OPERACAO
           AND ADIC.ID_INFORMACAO_ADIC BETWEEN 301 AND 399);  
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(null,'CONSULTA_T6','ALL'));  


 
 
prompt prompt ============================ ============================ ============================ ============================
prompt --

prompt Finalizando script
prompt
-- Buscando informacoes sobre a instituicao, data/hora para calcular o tempo de aplicacao
-- do script
set heading off
SELECT NOME_BANCO || ' - ' || to_char(sysdate, 'dd/mm/yyyy hh24:mi:ss')
FROM   BC_CONFIGURACAO BNF, BC_BANCO BCO
WHERE  BCO.ID_BANCO = BNF.INSTITUICAO;

prompt
prompt *****************************************************
prompt *                                                   *
prompt *      FAVOR ENVIAR LOG DA EXECUÇÃO DESTE SCRIPT    *
prompt *                                                   *
prompt *****************************************************
prompt

set heading on

set timing off
spool off;
