--#============================================================================================================
--#Referencia : stats_gather_table.sql
--#Assunto    : Estatisticas de tabelas, chamada da sqlplus 
--#Criado por : Roberto Fernandes Sobrinho 
--#Data       : 25/07/2019 
--#Ref        : https://www.oracle.com/technetwork/database/bi-datawarehousing/twp-bp-optimizer-stats-04042012-1577139.pdf
--#           : https://docs.oracle.com/cd/E18283_01/appdev.112/e16760/d_stats.htm
--#           : https://docs.oracle.com/cd/E18283_01/appdev.112/e16760/d_stats.htm#i1036461
--#           : https://www.oracle.com/technetwork/database/bi-datawarehousing/twp-optimizer-stats-concepts-110711-1354477.pdf
--#Alteracoes : 20/05/2021 - Ajustado a coleta de estatistica de particao incremental, tinha erro de sintaxe no dinamico
--#           : 23/09/2022 - Ajustado granularity = ALL, nao coletava statistica de subparticoes
--#============================================================================================================ 
ALTER SESSION ENABLE PARALLEL DDL;
ALTER SESSION SET NLS_DATE_FORMAT                 = 'DD/MM/YYYY HH24:MI:SS';
purge dba_recyclebin 
/ 
set serveroutput on 
declare  
  e_resource_busy_ora_exp exception;
  PRAGMA EXCEPTION_INIT(e_resource_busy_ora_exp, -54);
  v_msg            varchar2(500);
  v_prc            varchar2(500);  
  v_version        varchar2(20);  
  v_col_stat_type  varchar2(100);  
begin
	begin execute immediate 'ALTER SESSION SET DDL_LOCK_TIMEOUT=300'; exception when others then null; end;
	begin execute immediate 'ALTER SESSION SET DB_FILE_MULTIBLOCK_READ_COUNT=128'; exception when others then null; end;
	begin execute immediate 'ALTER SESSION SET COMMIT_LOGGING=BATCH'; exception when others then null; end; 
	begin execute immediate 'ALTER SESSION SET COMMIT_WAIT=NOWAIT'; exception when others then null; end; 
	begin execute immediate 'ALTER SESSION SET "_OPTIMIZER_JOIN_FACTORIZATION"=FALSE'; exception when others then null; end; 
	--/
	v_msg := 'STAT! WORKING [GATHER_TABLE]. . . [CRONTAB]';
	dbms_application_info.set_module( module_name => v_msg, action_name =>  v_msg);
	dbms_stats.flush_database_monitoring_info;
	--/
	SELECT substr(version,1,2) INTO v_version FROM v$instance;
    --/	
	v_prc := '[GATHER_TABLE_STATS]';
	dbms_system.ksdwrt (2, 'ORA-00444 -> INICIO  : '||TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS')||' -> '||v_msg||' -> '||v_prc);	
	--/
	for y in 
	(
	select 'N' TIPO, z.*
	from(
	select t.owner table_owner, t.table_name, null as partition_name, to_char(t.last_analyzed,'dd/mm/yyyy hh24:mi:ss') last_analyzed, nvl(t.num_rows, 0) num_rows
	from dba_tables t
	where t.last_analyzed is null
	and t.owner not in ('SYS', 'SYSTEM')
	union
	select m.table_owner, m.table_name as table_name,null as partition_name,  to_char(t.last_analyzed,'dd/mm/yyyy hh24:mi:ss') last_analyzed, nvl(t.num_rows, 0) num_rows
		from dba_tab_modifications m, dba_tables t
	where m.table_owner = t.owner
		and m.table_name = t.table_name 
		and m.table_owner not in ('SYS', 'SYSTEM')
		and ((m.inserts + m.updates + m.deletes) * 100 / nullif(t.num_rows, 0) > case when nvl(t.num_rows, 0) < 250000 then 10 else 4 end)) z
	where not exists (select 1 FROM dba_tab_statistics  j where j.OWNER       = z.table_owner and j.TABLE_NAME  = z.TABLE_NAME and  j.stattype_locked = 'ALL'
			union all select 1 FROM dba_external_tables j where j.OWNER       = z.table_owner and j.TABLE_NAME  = z.TABLE_NAME 
			union all select 1 FROM dba_recyclebin      j where j.OWNER       = z.table_owner and j.OBJECT_NAME = z.TABLE_NAME
			union all select 1 FROM dba_tab_partitions  j where j.table_owner = z.table_owner and j.table_name  = z.TABLE_NAME
            union all select 1 FROM sys.dba_mviews      j where j.OWNER       = z.table_owner and j.MVIEW_NAME  = z.TABLE_NAME and REFRESH_METHOD != 'FAST'
			union all select 1 FROM dba_tables          j where j.OWNER       = z.table_owner and j.table_name  = z.TABLE_NAME and IOT_TYPE != 'IOT_OVERFLOW')			
	UNION ALL
	select 'P' TIPO, y.*
	from(	
	select h.table_owner, h.table_name, h.partition_name , to_char(h.last_analyzed,'dd/mm/yyyy hh24:mi:ss') last_analyzed, nvl(h.num_rows, 0) num_rows
	from dba_tab_partitions h
	where h.last_analyzed is null
	and h.table_owner not in ('SYS', 'SYSTEM')
	union
	select m.table_owner , m.table_name, m.partition_name , to_char(p.last_analyzed,'dd/mm/yyyy hh24:mi:ss') last_analyzed,  nvl(p.num_rows, 0) num_rows
	from dba_tab_modifications m, dba_tab_partitions p
	where m.table_owner  = p.table_owner
	and m.table_name     = p.table_name
	and m.partition_name = p.partition_name
	and m.table_owner not in ('SYS', 'SYSTEM')
	and ((m.inserts + m.updates + m.deletes) * 100 / nullif(p.num_rows, 0) > case when nvl(p.num_rows, 0) < 250000 then 10 else 4 end))y
	where not exists (select 1 FROM dba_tab_statistics  j where j.OWNER = y.table_owner and j.TABLE_NAME  = y.TABLE_NAME and  j.stattype_locked = 'ALL'
			union all select 1 FROM dba_external_tables j where j.OWNER = y.table_owner and j.TABLE_NAME  = y.TABLE_NAME 
			union all select 1 FROM dba_recyclebin      j where j.OWNER = y.table_owner and j.OBJECT_NAME = y.TABLE_NAME
            union all select 1 FROM sys.dba_mviews      j where j.OWNER = y.table_owner and j.MVIEW_NAME  = y.TABLE_NAME and REFRESH_METHOD != 'FAST'
			union all select 1 FROM dba_tables          j where j.OWNER = y.table_owner and j.table_name  = y.TABLE_NAME and IOT_TYPE != 'IOT_OVERFLOW')				
    order by TIPO, 5 NULLS FIRST		
	) 
	loop
	IF  y.TIPO = 'N' THEN
		BEGIN
			BEGIN
			    --[FOR ALL COLUMNS SIZE SKEWONLY] = FAZ MESMO SE NAO TIVER NA SHARED POOL  
				--[FOR ALL COLUMNS SIZE AUTO    ] = SOMENTE QUE ESTA NA SHERED POOL
				DBMS_STATS.GATHER_TABLE_STATS(ownname          => y.table_owner,
                                              tabname          => y.table_name,
                                              estimate_percent => dbms_stats.auto_sample_size,
                                              method_opt       => 'FOR ALL COLUMNS SIZE SKEWONLY',   
                                              cascade          => TRUE,
                                              degree           => DBMS_STATS.AUTO_DEGREE,
                                              no_invalidate    => FALSE); --FALSE INVALIDA SQL DEPENDENTES
			END;
			--
		    DECLARE
			    v_sqlx varchar2(7000);			
			BEGIN
				for y1 in (select c.owner, c.table_name, c.column_name
							from DBA_TAB_COL_STATISTICS c
							WHERE c.histogram = 'HEIGHT BALANCED'
							AND c.owner      = y.table_owner
							and c.table_name = y.table_name
							and round((c.num_buckets / c.num_distinct) * 100) <= 60)
				loop
					       select decode(v_version,'10',null, ', col_stat_type=>''HISTOGRAM''') into v_col_stat_type from dual;
                           v_sqlx :=  'begin dbms_stats.delete_column_stats(  ownname=>  '''   ||y1.owner       ||''''||
                                                                                  ', tabname=>  '''  ||y1.table_name  ||''''||
																		   	      ', colname=>  '''  ||'"'||y1.column_name  ||'"'||''''|| --', colname=>  '''  ||y1.column_name ||''''||						   
                                                                                  ''||v_col_stat_type||');  '         || 
                                                                                  ' end;';		
						   --dbms_output.put_line('INSTANCE : '||v_sqlx); 																				  
                           EXECUTE IMMEDIATE 	v_sqlx;		
				end loop;
			END;	
		EXCEPTION  
		WHEN e_resource_busy_ora_exp THEN	
			NULL;		   
		END;	
        --/		
		ELSIF y.TIPO = 'P' THEN
		    DECLARE
			    v_sqlx varchar2(7000);
			BEGIN
			    if v_version <> '10' then
                    v_sqlx := 'begin dbms_stats.SET_TABLE_PREFS(  ownname => '''  ||y.table_owner  ||''''||
                                                               ', tabname => '''  ||y.table_name   ||''''||
                                                               ', pname   => '''  ||'INCREMENTAL'  ||''''||						   
                                                               ', pvalue  => '''  ||'TRUE'         ||''''||
                                                               ' ); end;';		
					 --dbms_output.put_line('INSTANCE : '||v_sqlx); 																				  
                    EXECUTE IMMEDIATE 	v_sqlx;							
				end if;	 
				BEGIN
				   --/granularity >>  https://docs.oracle.com/cd/E18283_01/appdev.112/e16760/d_stats.htm
				   --/            >> 'ALL'  - gathers all (subpartition, partition, and global) statistics
                   --/            >> 'AUTO '- determines the granularity based on the partitioning type. This is the default value.
					DBMS_STATS.GATHER_TABLE_STATS(ownname          => y.TABLE_OWNER,
                                                  tabname          => y.table_name, 
                                                  partname         => y.partition_name,
                                                  estimate_percent => dbms_stats.auto_sample_size,
                                                  method_opt       => 'FOR ALL COLUMNS SIZE SKEWONLY',
												  granularity      => 'ALL',      --/old: 'PARTITION',
                                                  cascade          => TRUE,
                                                  degree           => DBMS_STATS.AUTO_DEGREE,
                                                  no_invalidate    => FALSE);   --FALSE INVALIDA SQL DEPENDENTES					  
				END;
				--/ 
				BEGIN
					for y1 in (select c.owner, c.table_name, c.column_name,  c.partition_name
								from DBA_PART_COL_STATISTICS c
								WHERE c.histogram = 'HEIGHT BALANCED'
								AND c.owner          = y.table_owner
								and c.table_name     = y.table_name
								and c.partition_name = y.partition_name
							    and round((c.num_buckets / c.num_distinct) * 100) <= 60)								
					loop
					     
					   
					       select decode(v_version,'10',null, ', col_stat_type=>''HISTOGRAM''') into v_col_stat_type from dual;
							
                           v_sqlx := 'begin dbms_stats.delete_column_stats( ownname=>  '''   ||y1.owner          ||''''||
                                                                         ', tabname=>  '''   ||y1.table_name     ||''''||
																	     ', colname=>  '''  ||'"'||y1.column_name  ||'"'||''''||  --', colname=>  '''   ||y1.column_name    ||''''||	
                                                                         ', partname=> '''  ||y1.partition_name ||''''||																				  
                                                                         ''||v_col_stat_type||');  ' || ' end;';	
                           --dbms_output.put_line('INSTANCE : '||v_sqlx); 																				  
                           EXECUTE IMMEDIATE 	v_sqlx;																			  
					end loop;
				END;	
			EXCEPTION  
			WHEN e_resource_busy_ora_exp THEN	
				NULL;		  
			END;				  
		END IF;	
        --/
	end loop;
	--/
	dbms_system.ksdwrt (2, 'ORA-00444 -> FIM     : '||TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS')||' -> '||v_msg||' -> '||v_prc);
EXCEPTION 
WHEN OTHERS THEN
    dbms_system.ksdwrt (2, 'ORA-00900 -> ERROR(1): '||TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS')||' -> '||v_msg||' -> '||v_prc||' -> SQLERRM: '||substr(sqlerrm, 1, 300)||' -> '||dbms_utility.format_error_backtrace); 	
END;
/		
							