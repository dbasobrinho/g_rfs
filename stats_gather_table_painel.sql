--#============================================================================================================
--#Referencia : stats_gather_table_painel.sql
--#Assunto    : Painel informativo sobre dados de estatistica, chamada da sqlplus
--#Criado por : Roberto Fernandes Sobrinho 
--#Data       : 25/07/2019 
--#Ref        : N/A
--#Alteracoes :    
--#           : 
--#============================================================================================================
set serveroutput on 
DECLARE
v_stale     CONSTANT      INTEGER :=10;  
v_staleB    CONSTANT      INTEGER :=4;  
v_ins VARCHAR2(100);
v00   INTEGER; --t_stat_null 
v01   INTEGER; --t_stat_null 
v02   INTEGER; --t_stat_stale_maior
v02B  INTEGER; --t_stat_stale_maior BIG
v03   INTEGER; --t_stat_stale_menor 
v03B  INTEGER; --t_stat_stale_menor BIG
v04   INTEGER; --p_stat_null
v05   INTEGER; --p_stat_stale_maior
v06   INTEGER; --p_stat_stale_menor 
v07   INTEGER; --tot_stat_locked     I
v08   INTEGER; --tot_external_tables
v09   INTEGER; --tot_recyclebin
vtt   INTEGER;
BEGIN
   dbms_application_info.set_module( module_name => 'STAT! WORKING [GATHER_TABLE]. . . [CRONTAB]', action_name =>  'STAT! WORKING [GATHER_TABLE]. . . [CRONTAB]');
	--
	dbms_stats.flush_database_monitoring_info;
	--
	v_ins := UPPER(SYS_CONTEXT('USERENV', 'INSTANCE_NAME')) ;
	--
	select count(1) INTO v00
	from dba_tables t
	where t.last_analyzed is not null
	and t.owner not in ('SYS', 'SYSTEM')
	and not exists (select 1 FROM dba_tab_statistics    j where j.OWNER = t.owner and j.TABLE_NAME  = t.TABLE_NAME and  j.stattype_locked = 'ALL'
		    union all select 1 FROM dba_external_tables   j where j.OWNER = t.owner and j.TABLE_NAME  = t.TABLE_NAME 
		    union all select 1 FROM dba_recyclebin        j where j.OWNER = t.owner and j.OBJECT_NAME = t.TABLE_NAME
		    union all select 1 FROM dba_tab_modifications j where j.table_owner = t.owner and j.table_name = t.TABLE_NAME
		    union all select 1 FROM dba_tab_partitions    j where j.table_owner = t.owner and j.table_name = t.TABLE_NAME
            union all select 1 FROM sys.dba_mviews        j where j.OWNER = t.owner and j.MVIEW_NAME  = t.TABLE_NAME and REFRESH_METHOD != 'FAST'
			union all select 1 FROM dba_tables            j where j.OWNER = t.owner and j.table_name  = t.TABLE_NAME and IOT_TYPE != 'IOT_OVERFLOW');		  
	--
	select count(1) INTO v01
	from dba_tables t
	where t.last_analyzed is null
	and t.owner not in ('SYS', 'SYSTEM')
	and not exists (select 1 FROM dba_tab_statistics  j where j.OWNER       = t.owner and j.TABLE_NAME  = t.TABLE_NAME and  j.stattype_locked = 'ALL'
		    union all select 1 FROM dba_external_tables j where j.OWNER       = t.owner and j.TABLE_NAME  = t.TABLE_NAME 
		    union all select 1 FROM dba_recyclebin      j where j.OWNER       = t.owner and j.OBJECT_NAME = t.TABLE_NAME
		    union all select 1 FROM dba_tab_partitions  j where j.table_owner = t.owner and j.table_name  = t.TABLE_NAME
            union all select 1 FROM sys.dba_mviews      j where j.OWNER = t.owner and j.MVIEW_NAME  = t.TABLE_NAME and REFRESH_METHOD != 'FAST'
			union all select 1 FROM dba_tables          j where j.OWNER = t.owner and j.table_name  = t.TABLE_NAME and IOT_TYPE != 'IOT_OVERFLOW');		  
    --
	select sum(case when (m.inserts+m.updates+m.deletes)*100/NULLIF(t.num_rows,0) >   NVL(v_stale,10) then 1 else 0 end) maior_stale, 
	       sum(case when (m.inserts+m.updates+m.deletes)*100/NULLIF(t.num_rows,0) <=  NVL(v_stale,10) then 1 else 0 end) menor_stale
      INTO v02, v03
	 from dba_tab_modifications m, dba_tables t
	where m.table_owner = t.owner  
	  and m.table_name = t.table_name
	  and m.table_owner not in ('SYS', 'SYSTEM')
	  and NVL(t.num_rows,0) < 250000
	  and not exists (select 1 FROM dba_tab_statistics  j where j.OWNER       = t.owner and j.TABLE_NAME  = t.TABLE_NAME and  j.stattype_locked = 'ALL'
			union all select 1 FROM dba_external_tables j where j.OWNER       = t.owner and j.TABLE_NAME  = t.TABLE_NAME 
			union all select 1 FROM dba_recyclebin      j where j.OWNER       = t.owner and j.OBJECT_NAME = t.TABLE_NAME
	    	union all select 1 FROM dba_tab_partitions  j where j.table_owner = t.owner and j.table_name  = t.TABLE_NAME
            union all select 1 FROM sys.dba_mviews      j where j.OWNER = t.owner and j.MVIEW_NAME  = t.TABLE_NAME and REFRESH_METHOD != 'FAST'
			union all select 1 FROM dba_tables          j where j.OWNER = t.owner and j.table_name  = t.TABLE_NAME and IOT_TYPE != 'IOT_OVERFLOW');			
			
	select sum(case when (m.inserts+m.updates+m.deletes)*100/NULLIF(t.num_rows,0) >   NVL(v_staleB,4) then 1 else 0 end) maior_stale, 
	       sum(case when (m.inserts+m.updates+m.deletes)*100/NULLIF(t.num_rows,0) <=  NVL(v_staleB,4) then 1 else 0 end) menor_stale
      INTO v02B, v03B
	 from dba_tab_modifications m, dba_tables t
	where m.table_owner = t.owner  
	  and m.table_name = t.table_name
	  and m.table_owner not in ('SYS', 'SYSTEM')
	  and NVL(t.num_rows,0) >= 250000
	  and not exists (select 1 FROM dba_tab_statistics  j where j.OWNER       = t.owner and j.TABLE_NAME  = t.TABLE_NAME and  j.stattype_locked = 'ALL'
			union all select 1 FROM dba_external_tables j where j.OWNER       = t.owner and j.TABLE_NAME  = t.TABLE_NAME 
			union all select 1 FROM dba_recyclebin      j where j.OWNER       = t.owner and j.OBJECT_NAME = t.TABLE_NAME
	    	union all select 1 FROM dba_tab_partitions  j where j.table_owner = t.owner and j.table_name  = t.TABLE_NAME
            union all select 1 FROM sys.dba_mviews      j where j.OWNER = t.owner and j.MVIEW_NAME  = t.TABLE_NAME and REFRESH_METHOD != 'FAST'
			union all select 1 FROM dba_tables          j where j.OWNER = t.owner and j.table_name  = t.TABLE_NAME and IOT_TYPE != 'IOT_OVERFLOW');			
			
    --
	select count(1) total_sub2 into v04
     from dba_tab_partitions t
    where t.last_analyzed is null 
     and t.table_owner not in ('SYS', 'SYSTEM')
     and not exists (select 1 FROM dba_tab_statistics  j where j.OWNER = t.table_owner and j.TABLE_NAME  = t.TABLE_NAME and  j.stattype_locked = 'ALL'
           union all select 1 FROM dba_external_tables j where j.OWNER = t.table_owner and j.TABLE_NAME  = t.TABLE_NAME 
           union all select 1 FROM dba_recyclebin      j where j.OWNER = t.table_owner and j.OBJECT_NAME = t.TABLE_NAME
           union all select 1 FROM sys.dba_mviews      j where j.OWNER = t.table_owner and j.MVIEW_NAME  = t.TABLE_NAME and REFRESH_METHOD != 'FAST'
		   union all select 1 FROM dba_tables          j where j.OWNER = t.table_owner and j.table_name  = t.TABLE_NAME and IOT_TYPE != 'IOT_OVERFLOW');			   
    --
	select COUNT(case when (m.inserts+m.updates+m.deletes)*100/NULLIF(t.num_rows,0) >   NVL(v_stale,10) then 1 else NULL end) maior_stale2,
	       COUNT(case when (m.inserts+m.updates+m.deletes)*100/NULLIF(t.num_rows,0) <=  NVL(v_stale,10) then 1 else NULL end) menor_stale2
	  into v05, v06
	 from dba_tab_modifications m, dba_tab_partitions t
	where m.table_owner      = t.table_owner
	  and m.table_name       = t.table_name 
	   and m.partition_name  = t.partition_name 
	  and m.table_owner not in ('SYS', 'SYSTEM')
	  and not exists (select 1 FROM dba_tab_statistics  j where j.OWNER = t.table_owner and j.TABLE_NAME  = t.TABLE_NAME and  j.stattype_locked = 'ALL'
			union all select 1 FROM dba_external_tables j where j.OWNER = t.table_owner and j.TABLE_NAME  = t.TABLE_NAME 
			union all select 1 FROM dba_recyclebin      j where j.OWNER = t.table_owner and j.OBJECT_NAME = t.TABLE_NAME
            union all select 1 FROM sys.dba_mviews      j where j.OWNER = t.table_owner and j.MVIEW_NAME  = t.TABLE_NAME and  REFRESH_METHOD != 'FAST'
			union all select 1 FROM dba_tables          j where j.OWNER = t.table_owner and j.table_name  = t.TABLE_NAME and IOT_TYPE != 'IOT_OVERFLOW');
    -- 
   select COUNT(1) TOT_STAT_LOCKED into v07      FROM dba_tab_statistics  j where j.OWNER not in ('SYS', 'SYSTEM') and  j.stattype_locked = 'ALL';
   --
   select COUNT(1) TOT_EXTERNAL_TABLES into v08  FROM dba_external_tables j where j.OWNER not in ('SYS', 'SYSTEM');
   --
   select COUNT(1) TOT_RECYCLEBIN into v09  FROM dba_recyclebin;
   --
   vtt :=nvl(v00,0)+nvl(v01,0)+nvl(v02,0)+nvl(v02B,0)+nvl(v03,0)+nvl(v03B,0)+nvl(v04,0)+nvl(v05,0)+nvl(v06,0)+nvl(v07,0)+nvl(v08,0)+nvl(v09,0);
   --
   dbms_output.put_line('==========================================================================');
   dbms_output.put_line('REPORT   : ESTATISTICAS DE BANCO DE DADOS                                 ');
   dbms_output.put_line('INSTANCE : '||v_ins||'                                                    ');
   dbms_output.put_line('==========================================================================');
   dbms_output.put_line('PARAMETRO STAT STALE [< 250K] : '||lpad(v_stale ,2,' ')||' %'||'          ');
   dbms_output.put_line('PARAMETRO STAT STALE [>=250K] : '||lpad(v_staleB,2,' ')||' %'||'          ');   
   dbms_output.put_line('==========================================================================');
   dbms_output.put_line('[N] TABLE STATS UNCHANGED         : '||replace(to_char(nvl(v00, 0),'9999999999'),' ','.')||'  ['||to_char((nvl(v00, 0)*100)/(vtt),'FM900D00')||' %]');
   dbms_output.put_line('[S] TABLE STATS NULL              : '||replace(to_char(nvl(v01, 0),'9999999999'),' ','.')||'  ['||to_char((nvl(v01, 0)*100)/(vtt),'FM900D00')||' %]');
   dbms_output.put_line('[S] TABLE STATS STALE(Y) [< 250K] : '||replace(to_char(nvl(v02, 0),'9999999999'),' ','.')||'  ['||to_char((nvl(v02, 0)*100)/(vtt),'FM900D00')||' %]');
   dbms_output.put_line('[N] TABLE STATS STALE(N) [< 250K] : '||replace(to_char(nvl(v03, 0),'9999999999'),' ','.')||'  ['||to_char((nvl(v03, 0)*100)/(vtt),'FM900D00')||' %]');
   dbms_output.put_line('[S] TABLE STATS STALE(Y) [>=250K] : '||replace(to_char(nvl(v02b,0),'9999999999'),' ','.')||'  ['||to_char((nvl(v02b,0)*100)/(vtt),'FM900D00')||' %]');
   dbms_output.put_line('[N] TABLE STATS STALE(N) [>=250K] : '||replace(to_char(nvl(v03b,0),'9999999999'),' ','.')||'  ['||to_char((nvl(v03b,0)*100)/(vtt),'FM900D00')||' %]');
   dbms_output.put_line('[S] PART. STATS NULL              : '||replace(to_char(nvl(v04, 0),'9999999999'),' ','.')||'  ['||to_char((nvl(v04, 0)*100)/(vtt),'FM900D00')||' %]');
   dbms_output.put_line('[S] PART. STATS STALE(Y)          : '||replace(to_char(nvl(v05, 0),'9999999999'),' ','.')||'  ['||to_char((nvl(v05, 0)*100)/(vtt),'FM900D00')||' %]');
   dbms_output.put_line('[N] PART. STATS STALE(N)          : '||replace(to_char(nvl(v06, 0),'9999999999'),' ','.')||'  ['||to_char((nvl(v06, 0)*100)/(vtt),'FM900D00')||' %]');
   dbms_output.put_line('[N] TABLE STATS LOCKED            : '||replace(to_char(nvl(v07, 0),'9999999999'),' ','.')||'  ['||to_char((nvl(v07, 0)*100)/(vtt),'FM900D00')||' %]');
   dbms_output.put_line('[N] TABLE EXTERNAL                : '||replace(to_char(nvl(v08, 0),'9999999999'),' ','.')||'  ['||to_char((nvl(v08, 0)*100)/(vtt),'FM900D00')||' %]');
   dbms_output.put_line('[N] TABLE RECYCLEBIN              : '||replace(to_char(nvl(v09, 0),'9999999999'),' ','.')||'  ['||to_char((nvl(v09, 0)*100)/(vtt),'FM900D00')||' %]');
   dbms_output.put_line('==========================================================================');  
   dbms_output.put_line('TOTAL OBJETOS                     : '||replace(to_char( vtt,'9999999999'),' ','.')||' ');
   dbms_output.put_line('==========================================================================');    
   dbms_output.put_line('[S] = ESTATISTCA PENDENTE                                                 ');
   dbms_output.put_line('[N] = ESTATISTCA OK                                                       ');
   dbms_output.put_line('==========================================================================');       
END;
/