set echo on
set timing on
begin
	DBMS_STATS.GATHER_TABLE_STATS(ownname          => '&1',
                                  tabname          => '&2', 
                                  estimate_percent => dbms_stats.auto_sample_size,
                                  method_opt       => 'FOR ALL COLUMNS SIZE SKEWONLY',   
                                  cascade          => TRUE,
                                  degree           => DBMS_STATS.AUTO_DEGREE,
                                  no_invalidate    => FALSE); --FALSE INVALIDA SQL DEPENDENTES
end;
/

set echo off
set timing off

 --execute dbms_stats.gather_table_stats(ownname => 'GEQ_ODIRUN', tabname =>'C$_TMP_VAT_TAX_ACCOUNT', estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE, method_opt => 'FOR ALL COLUMNS SIZE AUTO');

