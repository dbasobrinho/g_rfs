set feedback off
set timing on
begin
------dbms_trace.set_plsql_trace(dbms_trace.trace_all_sql);
 
RTDBM.prc_nba_motor_ofertas--_25AGO21--_11AGO21 -- 38/69304815 CONTRATO COM MAIS DE 1MIL OFERTAS EM DEV
(
P_NUM_CONTRATO      => 396740531, --14890359 / 72658237 / 67283977 / 3 _ 392020305 / 684 _ 421077920
P_COD_OPERADORA     => 3,
P_CD_LOGIN          => 'Z041217',  -- 'Z076566' / 'T1322182'(RETENCAO) -- 'Z020232' / 'Z140799' (RENTAB)
P_QTD_OFERTAS       => -1, --default 5
P_MOTIVO_EVENTO     =>'AA',  
P_FLG_PROD_ATD_TV   =>'TRUE',
P_FLG_PROD_ATD_BL   =>'TRUE',
P_FLG_PROD_ATD_FX   =>'TRUE',
P_FLG_PROD_ATD_MV   =>'TRUE',
P_CANAL_ATENDIMENTO =>'Salesforce',  -- Web ou Salesforce
P_CD_LOGIN_MOVEL    =>'TRUE',
P_DAT_INICIO_SAS    => SYSDATE,
P_CASE_ID           => 'TESTE',
P_SUBMOTIVO_EVENTO  => null, --default NULL,
P_DISP_TV           => '1',
P_DISP_DIG          => '1',
P_DISP_BL           => '1',
P_DISP_FX           => '1',
p_DISP_GPON         => '0',
p_DSC_NODE          => 'xxx', --VMTBA
p_EVENTO            => 'Claro_NBA_Rentab_Ativo', -- Claro_NBA_Rentab_Receptivo - Claro_NBA_Retencao - Claro_NBA_Rentab_Ativo -
p_FLG_AQUIS_MOVEL   => '0'-- NÃO UTILIZADO 
);
----dbms_trace.clear_plsql_trace;
end;
/
--PROMPT .
---PROMPT [ SELECT * FROM SYS.VW_PLSQL_TRACE_EVENTS order by id; ]
--PROMPT . . .
--PROMPT . .
--PROMPT . 
--SELECT * FROM SYS.VW_PLSQL_TRACE_EVENTS order by id
--SELECT * FROM RTDBM.NBA_GTT_OFERTAS
