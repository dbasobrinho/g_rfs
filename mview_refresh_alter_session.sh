  ORACLE_BASE=/u/app/oracle; export ORACLE_BASE
  ORACLE_HOME=/u/app/oracle/product/11.2.0/db_1; export ORACLE_HOME
  ORACLE_TERM=xterm; export ORACLE_TERM
  PATH=$ORACLE_HOME/bin:$PATH; export PATH
  ORACLE_OWNER=oracle; export ORACLE_OWNER
  ORACLE_SID=pback1; export ORACLE_SID
  ORACLE_UNQNAME=pback; export ORACLE_UNQNAME
  LD_LIBRARY_PATH=$ORACLE_HOME/lib; export LD_LIBRARY_PATH
  CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
  CLASSPATH=$CLASSPATH:$ORACLE_HOME/network/jlib; export CLASSPATH
  NLS_LANG=AMERICAN_AMERICA.WE8MSWIN1252; export NLS_LANG
  TMP=/tmp; export TMP
  TMPDIR=$TMP; export TMPDIR


sqlplus / as sysdba << EOF

set timing on
alter session set db_file_multiblock_read_count=128 ;
alter session set workarea_size_policy=MANUAL ;
alter session set hash_area_size=9131072 ;
alter session set sort_area_size=655360 ;
alter session set commit_logging='BATCH' ;
alter session set commit_wait='NOWAIT' ;
begin 
   --atomic_refresh = false diz ao Oracle para truncar os dados em vez de excluir as linhas
   DBMS_MVIEW.REFRESH(LIST => '<OWNER>.<MVIEW_NAME>', METHOD => 'C', ATOMIC_REFRESH => TRUE);
end;
/
EOF
