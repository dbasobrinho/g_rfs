sqlplus "/ as sysdba" <<EOF
spool INC000008384695.log
set serveroutput on
set timing on
begin
  sptrans.prc_pesquisa_utilizacoes(qtde_minutos_log_a_processar => 30,
                                   limite_tempo_execucao        => 3600);
end;
/
spool off
EOF