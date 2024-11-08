set echo off;
set timing off;
set feedback off;
set verify off 
--
--
--  NAME
--    help.sql
--
--  DESCRIPTION
--    Lista os scripts disponiveis neste pacote
--
--  HISTORY
--    13/12/2011 => Valter J. de Aquino
--
-----------------------------------------------------------------------------

set serveroutput on

begin
  dbms_output.enable(65536);

  dbms_output.put(chr(10));  
  dbms_output.put_line('Script      Objetivo do script');
  dbms_output.put_line('----------- -----------------------------------------------------------------');
  dbms_output.put_line('dplan       Plano de execucao de um determinado sql_id.');     
  dbms_output.put_line('dplana      Plano de execucao de um determinado sql_id do repositorio AWR.'); 
  dbms_output.put_line('fsxr        Tempo medio de execucao por SQL_ID e Child number.');
  dbms_output.put_line('plan_stat   Tempo medio de execucao de cada plan_hash de um SQL_ID.');
  dbms_output.put_line('plan_stata  Tempo medio de execucao de cada plan_hash de um SQL_ID usando AWR.');
  dbms_output.put_line('idx_cols    Colunas de todos os indices de uma determinada tabela.');
  dbms_output.put_line('idx_size    Tamanho dos indices de uma determinada tabela.');
  dbms_output.put_line('idx_stat    Estatisticas de Indices de uma tabela.');
  dbms_output.put_line('ext_stat    Estatisticas de grupo de colunas de uma tabela.');   
  dbms_output.put_line('tab_stat    Estatisticas das colunas de uma tabela.');    
  dbms_output.put_line('sys_stat    Estatisticas de sistema da Base.');
  dbms_output.put_line('mtcs        Gerar um script para execuçao de testes do sql_id.');
  dbms_output.put_line('mtcsa       Gerar um script para execuçao de testes do sql_id usando AWR.');
  dbms_output.put_line('sqlhist     Informacoes historicas da execucao de um determinado SQL-ID.');
  dbms_output.put_line('----------- -----------------------------------------------------------------');
  dbms_output.put(chr(10));
end;
/

--
-- Fim
--
set feedback on ;
set verify on