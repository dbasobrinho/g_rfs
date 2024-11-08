-->> #===========================================================================================================
-->> #Referencia : kill_auto_by_sqlid.sql
-->> #Assunto    : KILL AUTOMATICO
-->> #Criado por : Roberto Fernandes Sobrinho <<O DOIDO DA MOTO MALUCA>>
-->> #Data       : 06/04/2020
-->> #Ref        :
-->> #Alteracoes : 05/05/2020 >> rfsobrinho >> V2.0[CENTRALIZAR TABELA: tvtspi.tbl_auto_kill_cron]
-->> #           : 21/08/2020 >> rfsobrinho >> V2.1[INCLUIR KILL AUTOMATICO TRANSACOES ABERTAS A MAIS DE 20 MIN, ATIVAS E INATIVAS DOS USUARIOS
-->> #           :                                 ['FPS_RP','FPS_RP_MOB', 'FPS_RP_TPT','FPS_RP_PJ', 'FPS_MONITOR', 'FLEXVISION']
-->> #           :                                 [SOLICITACAO ENVIADA POR ALEXANDRE VITORIANO 20/08/2020 AS 16:44 COM A DEVIDA APROVACAO DO CLIENTE
-->> #============================================================================================================
-->>--create table tvtspi.tbl_auto_kill_cron as
SET FEEDBACK off
set time on
-- ########## ATENCAO TODAS AS REGRAS DE KILL ANTES DA MIGRAÇÃO AUTONOMIA ESTÃO COMENTADAS. UMA NOVA REGRA FOI CRIADA A PARTIR DA LINHA 321 PARA O SQL ID 0rrxfgcxhanwu
-- insert into tvtspi.tbl_auto_kill_cron  ----- INCLUDO f36knvx60mmud E ALTERADO WAIT PARA 45 SEG [INC20210218754], Incluido sql_ID 15bc72v5sftf6 (AUTONOMIA)
-- select decode(s.sql_id,'c01kv76uk7qu6','BACKOFFICE_FACADE','9v41k7bdb6axf','TRD_SESN_REQ_RES_H','f36knvx60mmud','F36_DEVOLUCAO' )   AS SERVICE   --> REMOVIDO TRD_USER - SCTASK1212804,, '6vyfa6pykp1k0','TRD_USER')  AS SERVICE
-- , s.sid || ',' || s.serial#|| case when s.inst_id is not null then ',@' || s.inst_id end  as SID_SERIAL
-- ,decode(upper(s.WAIT_CLASS),'IDLE','I','*')||' '||
--  to_char(nvl((case when e.qcsid is not null then e.qcsid || ',' || e.qcserial#|| case when e.inst_id is not null then ',@' || e.inst_id end end),substr(trim(s.WAIT_CLASS),1,13)))  as SLAVE
-- ,    to_char(p.pid)          as opid
-- ,    to_char(p.spid)         as sopid
-- ,    substr(s.username,1,10)||decode(s.username,'SYS',SUBSTR(nvl2(s.module,' [',null)||UPPER(s.module),1,6)||nvl2(s.module,']',null)) as username
-- ,    substr(s.osuser,1,10)   as osuser
-- --,    substr(s.program,1,10)  as program
-- ,    case when instr(s.program,'(J0') > 0  then substr(s.program,instr(s.program,'(J0'),10)||'-JOB' else substr(s.program,1,10) end  as program
-- ,    substr(replace(s.machine,'EMISSAO'),1,20)  as machine
-- ,    to_char(s.logon_time,'ddmmrrhh24mi') as logon_time
-- ,        to_char(s.last_call_et)              as call_et
-- ,    substr((select trim(replace(replace(substr(event,1,100),'SQL*Net'),'Streams')) from gv$session_wait j where j.sid = s.sid and j.INST_ID =  s.inst_id),1,25) as sessionwait
-- ,        s.sql_id  as sql_id
-- ,    s.blocking_session || ',' || s.blocking_instance as hold
-- ,        to_char(s.seconds_in_wait) as sc_wait
-- ,     SUBSTR(nvl2(s.module,'[',null)||UPPER(trim(s.module)),1,6)||nvl2(s.module,']',null) as module
-- ,      'alter system kill session ''' || s.sid || ',' ||s.serial# || ',@' ||s.inst_id||''' immediate ' comando
-- ,     case when s.seconds_in_wait > 30  then 'KILL' ELSE 'NO_KILL' end state
-- ,     SYSDATE DT_INCL
-- ,     null    DT_KILL
-- from gv$session s
-- ,    gv$process p
-- ,    gv$px_session e
-- Where s.paddr       = p.addr    (+)
--   and s.inst_id     = p.inst_id (+)
--   and s.status      = 'ACTIVE'
--   and s.inst_id     = e.inst_id (+)
--   and s.sid         = e.sid     (+)
--   and s.serial#     = e.serial# (+)
--   and s.WAIT_CLASS != 'Idle'
--   and s.sql_id      in ('15bc72v5sftf6', 'c01kv76uk7qu6', '9v41k7bdb6axf','f36knvx60mmud' )   --> REMOVIDO TRD_USER - SCTASK1212804, '6vyfa6pykp1k0')
--   and nvl((case when e.qcsid is not null then e.qcsid || ',' || e.qcserial#|| case when e.inst_id is not null then ',@' || e.inst_id end end),substr(trim(s.WAIT_CLASS),1,13)) != 'Idle'
--   and s.username is not null
--   and s.seconds_in_wait > 30
-- order by decode(s.username,'SYS',to_number(s.inst_id||50000000),s.inst_id) , case when instr(SLAVE,',,@') >0 then (substr(SLAVE,3,2)||'1') when instr(SLAVE,'@') >0 then  (decode(upper(s.WAIT_CLASS),'IDLE',2,1)||substr(SLAVE,3,2)||'2') else null end,
-- decode(s.username,'SYS',50000000,sc_wait), s.machine, s.last_call_et
-- /
-- COMMIT
-- /
-- insert into tvtspi.tbl_auto_kill_cron  ----- INCLUIDA A EXCECAO PARA O USUARIO FPS_BOB [INC20210337909], removemos a excecao apos a conclusao do JOB, conforme combinado em conf. 06 Abril 2021
-- select 'TRANSACTIONS_OPEN_2HRS' AS SERVICE
-- , s.sid || ',' || s.serial#|| case when s.inst_id is not null then ',@' || s.inst_id end  as SID_SERIAL
-- ,decode(upper(s.WAIT_CLASS),'IDLE','I','*')||' '||
--  to_char(nvl((case when e.qcsid is not null then e.qcsid || ',' || e.qcserial#|| case when e.inst_id is not null then ',@' || e.inst_id end end),substr(trim(s.WAIT_CLASS),1,13)))  as SLAVE
-- ,    to_char(p.pid)          as opid
-- ,    to_char(p.spid)         as sopid
-- ,    substr(s.username,1,10)||decode(s.username,'SYS',SUBSTR(nvl2(s.module,' [',null)||UPPER(s.module),1,6)||nvl2(s.module,']',null)) as username
-- ,    substr(s.osuser,1,10)   as osuser
-- --,    substr(s.program,1,10)  as program
-- ,    case when instr(s.program,'(J0') > 0  then substr(s.program,instr(s.program,'(J0'),10)||'-JOB' else substr(s.program,1,10) end  as program
-- ,    substr(replace(s.machine,'EMISSAO'),1,20)  as machine
-- ,    to_char(s.logon_time,'ddmmrrhh24mi') as logon_time
-- ,        to_char(s.last_call_et)              as call_et
-- ,    substr((select trim(replace(replace(substr(event,1,100),'SQL*Net'),'Streams')) from gv$session_wait j where j.sid = s.sid and j.INST_ID =  s.inst_id),1,25) as sessionwait
-- ,        s.sql_id  as sql_id
-- ,    s.blocking_session || ',' || s.blocking_instance as hold
-- ,        to_char(s.seconds_in_wait) as sc_wait
-- ,     SUBSTR(nvl2(s.module,'[',null)||UPPER(trim(s.module)),1,6)||nvl2(s.module,']',null) as module
-- ,      'alter system kill session ''' || s.sid || ',' ||s.serial# || ',@' ||s.inst_id||''' immediate ' comando
-- ,     case when s.seconds_in_wait > 2 then 'KILL' ELSE 'NO_KILL' end state
-- ,     SYSDATE DT_INCL
-- ,     null    DT_KILL
-- FROM   gv$transaction     t,
--        gv$session         s,
--        gv$rollstat        r,
--        dba_rollback_segs rs,
--        gv$px_session      e,
--        gv$process         p
-- WHERE  s.saddr = t.ses_addr
--   AND  s.inst_id = t.inst_id
--   AND  t.xidusn = r.usn
--   AND  t.inst_id  = r.inst_id
--   AND  rs.segment_id = t.xidusn
--   and s.inst_id     = e.inst_id (+)
--   and s.sid         = e.sid     (+)
--   and s.serial#     = e.serial# (+)
--   and s.paddr       = p.addr    (+)
--   and s.inst_id     = p.inst_id (+)
--   and s.status      = 'INACTIVE'
--   and t.START_DATE <= sysdate-2/24
--   and s.username is not null
--   --and s.username <> 'FPS_BOB'
-- ORDER BY t.START_TIME asc
-- /
-- commit
-- /
-- insert into tvtspi.tbl_auto_kill_cron
-- select 'TRANSACTIONS_OPEN_20MIN' AS SERVICE
-- , s.sid || ',' || s.serial#|| case when s.inst_id is not null then ',@' || s.inst_id end  as SID_SERIAL
-- ,decode(upper(s.WAIT_CLASS),'IDLE','I','*')||' '||
--  to_char(nvl((case when e.qcsid is not null then e.qcsid || ',' || e.qcserial#|| case when e.inst_id is not null then ',@' || e.inst_id end end),substr(trim(s.WAIT_CLASS),1,13)))  as SLAVE
-- ,    to_char(p.pid)          as opid
-- ,    to_char(p.spid)         as sopid
-- ,    substr(s.username,1,10)||decode(s.username,'SYS',SUBSTR(nvl2(s.module,' [',null)||UPPER(s.module),1,6)||nvl2(s.module,']',null)) as username
-- ,    substr(s.osuser,1,10)   as osuser
-- --,    substr(s.program,1,10)  as program
-- ,    case when instr(s.program,'(J0') > 0  then substr(s.program,instr(s.program,'(J0'),10)||'-JOB' else substr(s.program,1,10) end  as program
-- ,    substr(replace(s.machine,'EMISSAO'),1,20)  as machine
-- ,    to_char(s.logon_time,'ddmmrrhh24mi') as logon_time
-- ,        to_char(s.last_call_et)              as call_et
-- ,    substr((select trim(replace(replace(substr(event,1,100),'SQL*Net'),'Streams')) from gv$session_wait j where j.sid = s.sid and j.INST_ID =  s.inst_id),1,25) as sessionwait
-- ,        s.sql_id  as sql_id
-- ,    s.blocking_session || ',' || s.blocking_instance as hold
-- ,        to_char(s.seconds_in_wait) as sc_wait
-- ,     SUBSTR(nvl2(s.module,'[',null)||UPPER(trim(s.module)),1,6)||nvl2(s.module,']',null) as module
-- ,      'alter system kill session ''' || s.sid || ',' ||s.serial# || ',@' ||s.inst_id||''' immediate ' comando
-- ,     case when s.seconds_in_wait > 2 then 'KILL' ELSE 'NO_KILL' end state
-- ,     SYSDATE DT_INCL
-- ,     null    DT_KILL
-- FROM   gv$transaction     t,
--        gv$session         s,
--        gv$rollstat        r,
--        dba_rollback_segs rs,
--        gv$px_session      e,
--        gv$process         p
-- WHERE  s.saddr = t.ses_addr
--   AND  s.inst_id = t.inst_id
--   AND  t.xidusn = r.usn
--   AND  t.inst_id  = r.inst_id
--   AND  rs.segment_id = t.xidusn
--   and s.inst_id     = e.inst_id (+)
--   and s.sid         = e.sid     (+)
--   and s.serial#     = e.serial# (+)
--   and s.paddr       = p.addr    (+)
--   and s.inst_id     = p.inst_id (+)
--   ----and s.status      = 'INACTIVE'  --> ATIVAS e INATIVA, QUE LOUCURA, VAI DAR PROBLEMA
--   and t.START_DATE <= sysdate-20/24/60 -->20 MINUTOS
--   and s.username is not null
--   and ( (s.username in ('FPS_RP','FPS_RP_MOB', 'FPS_RP_TPT','FPS_RP_PJ','FPS_MONITOR', 'FLEXVISION')) or (s.sql_id = '7u733tf8y04n0') )
-- ORDER BY t.START_TIME asc
-- /
-- commit
-- /
-- insert into tvtspi.tbl_auto_kill_cron  ----- INCLUDO crwvjbp7s8zat E ALTERADO WAIT PARA 60 SEG [INC20210230678, em 09 de marco 2021 - Autorizado por Ricardo Silva. Nova alteracao para 40 seg]
-- select decode(s.sql_id,'crwvjbp7s8zat','GET_LIST_SPOKESMAN' )   AS SERVICE
-- , s.sid || ',' || s.serial#|| case when s.inst_id is not null then ',@' || s.inst_id end  as SID_SERIAL
-- ,decode(upper(s.WAIT_CLASS),'IDLE','I','*')||' '||
--  to_char(nvl((case when e.qcsid is not null then e.qcsid || ',' || e.qcserial#|| case when e.inst_id is not null then ',@' || e.inst_id end end),substr(trim(s.WAIT_CLASS),1,13)))  as SLAVE
-- ,    to_char(p.pid)          as opid
-- ,    to_char(p.spid)         as sopid
-- ,    substr(s.username,1,10)||decode(s.username,'SYS',SUBSTR(nvl2(s.module,' [',null)||UPPER(s.module),1,6)||nvl2(s.module,']',null)) as username
-- ,    substr(s.osuser,1,10)   as osuser
-- --,    substr(s.program,1,10)  as program
-- ,    case when instr(s.program,'(J0') > 0  then substr(s.program,instr(s.program,'(J0'),10)||'-JOB' else substr(s.program,1,10) end  as program
-- ,    substr(replace(s.machine,'EMISSAO'),1,20)  as machine
-- ,    to_char(s.logon_time,'ddmmrrhh24mi') as logon_time
-- ,        to_char(s.last_call_et)              as call_et
-- ,    substr((select trim(replace(replace(substr(event,1,100),'SQL*Net'),'Streams')) from gv$session_wait j where j.sid = s.sid and j.INST_ID =  s.inst_id),1,25) as sessionwait
-- ,        s.sql_id  as sql_id
-- ,    s.blocking_session || ',' || s.blocking_instance as hold
-- ,        to_char(s.seconds_in_wait) as sc_wait
-- ,     SUBSTR(nvl2(s.module,'[',null)||UPPER(trim(s.module)),1,6)||nvl2(s.module,']',null) as module
-- ,      'alter system kill session ''' || s.sid || ',' ||s.serial# || ',@' ||s.inst_id||''' immediate ' comando
-- ,     'KILL' state
-- ,     SYSDATE DT_INCL
-- ,     null    DT_KILL
-- from gv$session s
-- ,    gv$process p
-- ,    gv$px_session e
-- Where s.paddr       = p.addr    (+)
--   and s.inst_id     = p.inst_id (+)
--   and s.status      = 'ACTIVE'
--   and s.inst_id     = e.inst_id (+)
--   and s.sid         = e.sid     (+)
--   and s.serial#     = e.serial# (+)
--   and s.WAIT_CLASS != 'Idle'
--   and s.sql_id      = 'crwvjbp7s8zat'
--   and nvl((case when e.qcsid is not null then e.qcsid || ',' || e.qcserial#|| case when e.inst_id is not null then ',@' || e.inst_id end end),substr(trim(s.WAIT_CLASS),1,13)) != 'Idle'
--   and s.username is not null
--   and s.LAST_CALL_ET  > 40
-- order by decode(s.username,'SYS',to_number(s.inst_id||50000000),s.inst_id) , case when instr(SLAVE,',,@') >0 then (substr(SLAVE,3,2)||'1') when instr(SLAVE,'@') >0 then  (decode(upper(s.WAIT_CLASS),'IDLE',2,1)||substr(SLAVE,3,2)||'2') else null end,
-- decode(s.username,'SYS',50000000,sc_wait), s.machine, s.last_call_et
-- /
-- COMMIT
-- /
--
--
--
-- insert into tvtspi.tbl_auto_kill_cron  ----- INCLUDO  o SQL 2tbtn5qt8g16s. Kill deve ser realizado após 90 segundos de sessão ativa [INC20210270025/INC20210278214, em 22 de marco 2021 - Autorizado por Ricardo Silva durante a conferência]
-- select decode(s.sql_id,'2tbtn5qt8g16s','ACOMPANHA_PEDIDO')   AS SERVICE
-- , s.sid || ',' || s.serial#|| case when s.inst_id is not null then ',@' || s.inst_id end  as SID_SERIAL
-- ,decode(upper(s.WAIT_CLASS),'IDLE','I','*')||' '||
--  to_char(nvl((case when e.qcsid is not null then e.qcsid || ',' || e.qcserial#|| case when e.inst_id is not null then ',@' || e.inst_id end end),substr(trim(s.WAIT_CLASS),1,13)))  as SLAVE
-- ,    to_char(p.pid)          as opid
-- ,    to_char(p.spid)         as sopid
-- ,    substr(s.username,1,10)||decode(s.username,'SYS',SUBSTR(nvl2(s.module,' [',null)||UPPER(s.module),1,6)||nvl2(s.module,']',null)) as username
-- ,    substr(s.osuser,1,10)   as osuser
-- --,    substr(s.program,1,10)  as program
-- ,    case when instr(s.program,'(J0') > 0  then substr(s.program,instr(s.program,'(J0'),10)||'-JOB' else substr(s.program,1,10) end  as program
-- ,    substr(replace(s.machine,'EMISSAO'),1,20)  as machine
-- ,    to_char(s.logon_time,'ddmmrrhh24mi') as logon_time
-- ,        to_char(s.last_call_et)              as call_et
-- ,    substr((select trim(replace(replace(substr(event,1,100),'SQL*Net'),'Streams')) from gv$session_wait j where j.sid = s.sid and j.INST_ID =  s.inst_id),1,25) as sessionwait
-- ,        s.sql_id  as sql_id
-- ,    s.blocking_session || ',' || s.blocking_instance as hold
-- ,        to_char(s.seconds_in_wait) as sc_wait
-- ,     SUBSTR(nvl2(s.module,'[',null)||UPPER(trim(s.module)),1,6)||nvl2(s.module,']',null) as module
-- ,      'alter system kill session ''' || s.sid || ',' ||s.serial# || ',@' ||s.inst_id||''' immediate ' comando
-- ,     'KILL' state
-- ,     SYSDATE DT_INCL
-- ,     null    DT_KILL
-- from gv$session s
-- ,    gv$process p
-- ,    gv$px_session e
-- Where s.paddr       = p.addr    (+)
--   and s.inst_id     = p.inst_id (+)
--   and s.status      = 'ACTIVE'
--   and s.inst_id     = e.inst_id (+)
--   and s.sid         = e.sid     (+)
--   and s.serial#     = e.serial# (+)
--   and s.WAIT_CLASS != 'Idle'
--   and s.sql_id      = '2tbtn5qt8g16s'
--   and nvl((case when e.qcsid is not null then e.qcsid || ',' || e.qcserial#|| case when e.inst_id is not null then ',@' || e.inst_id end end),substr(trim(s.WAIT_CLASS),1,13)) != 'Idle'
--   and s.username is not null
--   and s.LAST_CALL_ET  > 90
-- order by decode(s.username,'SYS',to_number(s.inst_id||50000000),s.inst_id) , case when instr(SLAVE,',,@') >0 then (substr(SLAVE,3,2)||'1') when instr(SLAVE,'@') >0 then  (decode(upper(s.WAIT_CLASS),'IDLE',2,1)||substr(SLAVE,3,2)||'2') else null end,
-- decode(s.username,'SYS',50000000,sc_wait), s.machine, s.last_call_et
-- /
-- COMMIT
-- /
--
--
-- --REQ20210687410  O BLOCO ABAIXO REALIZA O KILL DAS SESSOES INATIVAS A MAIS DE 3HORAS DOS USUÁRIOS FPS_URA***
-- insert into tvtspi.tbl_auto_kill_cron
-- select 'FPS_URA_INACTIVE_3HRS' AS SERVICE
-- , s.sid || ',' || s.serial#|| case when s.inst_id is not null then ',@' || s.inst_id end  as SID_SERIAL
-- ,decode(upper(s.WAIT_CLASS),'IDLE','I','*')||' '||
--  to_char(nvl((case when e.qcsid is not null then e.qcsid || ',' || e.qcserial#|| case when e.inst_id is not null then ',@' || e.inst_id end end),substr(trim(s.WAIT_CLASS),1,13)))  as SLAVE
-- ,    to_char(p.pid)          as opid
-- ,    to_char(p.spid)         as sopid
-- ,    substr(s.username,1,10)||decode(s.username,'SYS',SUBSTR(nvl2(s.module,' [',null)||UPPER(s.module),1,6)||nvl2(s.module,']',null)) as username
-- ,    substr(s.osuser,1,10)   as osuser
-- --,    substr(s.program,1,10)  as program
-- ,    case when instr(s.program,'(J0') > 0  then substr(s.program,instr(s.program,'(J0'),10)||'-JOB' else substr(s.program,1,10) end  as program
-- ,    substr(replace(s.machine,'EMISSAO'),1,20)  as machine
-- ,    to_char(s.logon_time,'ddmmrrhh24mi') as logon_time
-- ,        to_char(s.last_call_et)              as call_et
-- ,    substr((select trim(replace(replace(substr(event,1,100),'SQL*Net'),'Streams')) from gv$session_wait j where j.sid = s.sid and j.INST_ID =  s.inst_id),1,25) as sessionwait
-- ,        s.sql_id  as sql_id
-- ,    s.blocking_session || ',' || s.blocking_instance as hold
-- ,        to_char(s.seconds_in_wait) as sc_wait
-- ,     SUBSTR(nvl2(s.module,'[',null)||UPPER(trim(s.module)),1,6)||nvl2(s.module,']',null) as module
-- ,      'alter system kill session ''' || s.sid || ',' ||s.serial# || ',@' ||s.inst_id||''' immediate ' comando
-- ,     case when s.seconds_in_wait > 2 then 'KILL' ELSE 'NO_KILL' end state
-- ,     SYSDATE DT_INCL
-- ,     null    DT_KILL
-- FROM   gv$session         s,
--        gv$px_session      e,
--        gv$process         p
-- WHERE
--   s.inst_id     = e.inst_id (+)
--   and s.sid         = e.sid     (+)
--   and s.serial#     = e.serial# (+)
--   and s.paddr       = p.addr    (+)
--   and s.inst_id     = p.inst_id (+)
--   and s.status      = 'INACTIVE'
--   and s.LAST_CALL_ET/60/60 > 3
--   and s.username in ('FPS_URA', 'FPS_URA_PJ', 'FPS_URA_TPT')
-- /
--
-- -- REALIZA KILL DOS USUÁRIOS NOMEADOS COM SESSOES ATIVAS em WAIT a MAIS DE 05 MINUTOS  >> USUARIOS = 'FPS_RP', 'FPS_RP_TPT','FPS_KZ'
-- -- APROVADO POR RICADO SILVA NO E-MAIL [FIDELITY] - ESTOURO DE TABLESPACE TEMP - BKF - PBACK – PRODUÇÃO - (USER: FPS_RP - SQLID:  b6da12d1zsptu]
-- insert into tvtspi.tbl_auto_kill_cron
-- select 'FPS_KILL_REPORTS' AS SERVICE
-- , s.sid || ',' || s.serial#|| case when s.inst_id is not null then ',@' || s.inst_id end  as SID_SERIAL
-- ,decode(upper(s.WAIT_CLASS),'IDLE','I','*')||' '||
--  to_char(nvl((case when e.qcsid is not null then e.qcsid || ',' || e.qcserial#|| case when e.inst_id is not null then ',@' || e.inst_id end end),substr(trim(s.WAIT_CLASS),1,13)))  as SLAVE
-- ,    to_char(p.pid)          as opid
-- ,    to_char(p.spid)         as sopid
-- ,    substr(s.username,1,10)||decode(s.username,'SYS',SUBSTR(nvl2(s.module,' [',null)||UPPER(s.module),1,6)||nvl2(s.module,']',null)) as username
-- ,    substr(s.osuser,1,10)   as osuser
-- --,    substr(s.program,1,10)  as program
-- ,    case when instr(s.program,'(J0') > 0  then substr(s.program,instr(s.program,'(J0'),10)||'-JOB' else substr(s.program,1,10) end  as program
-- ,    substr(replace(s.machine,'EMISSAO'),1,20)  as machine
-- ,    to_char(s.logon_time,'ddmmrrhh24mi') as logon_time
-- ,        to_char(s.last_call_et)              as call_et
-- ,    substr((select trim(replace(replace(substr(event,1,100),'SQL*Net'),'Streams')) from gv$session_wait j where j.sid = s.sid and j.INST_ID =  s.inst_id),1,25) as sessionwait
-- ,        s.sql_id  as sql_id
-- ,    s.blocking_session || ',' || s.blocking_instance as hold
-- ,        to_char(s.seconds_in_wait) as sc_wait
-- ,     SUBSTR(nvl2(s.module,'[',null)||UPPER(trim(s.module)),1,6)||nvl2(s.module,']',null) as module
-- ,      'alter system kill session ''' || s.sid || ',' ||s.serial# || ',@' ||s.inst_id||''' immediate ' comando
-- ,     case when s.seconds_in_wait >= 0 then 'KILL' ELSE 'NO_KILL' end state
-- ,     SYSDATE DT_INCL
-- ,     null    DT_KILL
-- FROM   gv$session         s,
--        gv$px_session      e,
--        gv$process         p
-- WHERE
--   s.inst_id     = e.inst_id (+)
--   and s.sid         = e.sid     (+)
--   and s.serial#     = e.serial# (+)
--   and s.paddr       = p.addr    (+)
--   and s.inst_id     = p.inst_id (+)
--   and s.LAST_CALL_ET/60 > 5
--   and s.username in ('FPS_RP', 'FPS_RP_TPT','FPS_KZ')
-- /
--
--
-- COMMIT
-- /
--
-- ########## ATENCAO TODAS AS REGRAS DE KILL ANTES DA MIGRAÇÃO AUTONOMIA ESTÃO COMENTADAS. UMA NOVA REGRA FOI CRIADA A PARTIR DA LINHA 321 PARA O SQL ID 0rrxfgcxhanwu
-- CRIADA A REGRA PARA O GET CONTRACT LIST CONFORME AUTORIZAÇÃO DO HILDEVAN E DO MONTOIA NO DIA 24/05/2022 DURANTE CONF SOBRE A CRISE NO AMBIENTE DO BACK OFFICE. A QUERY ESTAVA GERANDO UM ALTO NÍVEL DE I/O NO BANCO
-- insert into tvtspi.tbl_auto_kill_cron
-- select decode(s.sql_id,'0rrxfgcxhanwu','GET_CONTRACT_LIST')   AS SERVICE
-- , s.sid || ',' || s.serial#|| case when s.inst_id is not null then ',@' || s.inst_id end  as SID_SERIAL
-- ,decode(upper(s.WAIT_CLASS),'IDLE','I','*')||' '||
--  to_char(nvl((case when e.qcsid is not null then e.qcsid || ',' || e.qcserial#|| case when e.inst_id is not null then ',@' || e.inst_id end end),substr(trim(s.WAIT_CLASS),1,13)))  as SLAVE
-- ,    to_char(p.pid)          as opid
-- ,    to_char(p.spid)         as sopid
-- ,    substr(s.username,1,10)||decode(s.username,'SYS',SUBSTR(nvl2(s.module,' [',null)||UPPER(s.module),1,6)||nvl2(s.module,']',null)) as username
-- ,    substr(s.osuser,1,10)   as osuser
-- --,    substr(s.program,1,10)  as program
-- ,    case when instr(s.program,'(J0') > 0  then substr(s.program,instr(s.program,'(J0'),10)||'-JOB' else substr(s.program,1,10) end  as program
-- ,    substr(replace(s.machine,'EMISSAO'),1,20)  as machine
-- ,    to_char(s.logon_time,'ddmmrrhh24mi') as logon_time
-- ,        to_char(s.last_call_et)              as call_et
-- ,    substr((select trim(replace(replace(substr(event,1,100),'SQL*Net'),'Streams')) from gv$session_wait j where j.sid = s.sid and j.INST_ID =  s.inst_id),1,25) as sessionwait
-- ,        s.sql_id  as sql_id
-- ,    s.blocking_session || ',' || s.blocking_instance as hold
-- ,        to_char(s.seconds_in_wait) as sc_wait
-- ,     SUBSTR(nvl2(s.module,'[',null)||UPPER(trim(s.module)),1,6)||nvl2(s.module,']',null) as module
-- ,      'alter system kill session ''' || s.sid || ',' ||s.serial# || ',@' ||s.inst_id||''' immediate ' comando
-- ,     'KILL' state
-- ,     SYSDATE DT_INCL
-- ,     null    DT_KILL
-- from gv$session s
-- ,    gv$process p
-- ,    gv$px_session e
-- Where s.paddr       = p.addr    (+)
--   and s.inst_id     = p.inst_id (+)
--   and s.status      = 'ACTIVE'
--   and s.inst_id     = e.inst_id (+)
--   and s.sid         = e.sid     (+)
--   and s.serial#     = e.serial# (+)
--   and s.WAIT_CLASS != 'Idle'
--   and s.sql_id      = '0rrxfgcxhanwu'
--   and nvl((case when e.qcsid is not null then e.qcsid || ',' || e.qcserial#|| case when e.inst_id is not null then ',@' || e.inst_id end end),substr(trim(s.WAIT_CLASS),1,13)) != 'Idle'
--   and s.username is not null
--   and s.LAST_CALL_ET  > 6
-- order by decode(s.username,'SYS',to_number(s.inst_id||50000000),s.inst_id) , case when instr(SLAVE,',,@') >0 then (substr(SLAVE,3,2)||'1') when instr(SLAVE,'@') >0 then  (decode(upper(s.WAIT_CLASS),'IDLE',2,1)||substr(SLAVE,3,2)||'2') else null end,
-- decode(s.username,'SYS',50000000,sc_wait), s.machine, s.last_call_et
-- /
--
-- COMMIT
-- /
--


-- REALIZA KILL DOS USUÁRIOS NOMEADOS COM SESSOES ATIVAS  a MAIS DE 05 MINUTOS  >> USUARIOS = 'FPS_BOP_', 'FPS_RP', 'FPS_RP_TPT','FPS_KZ'
-- SOLICITADO POR CARLOS MONTOIA EM CONF NO DIA 26/05/2022 devido a crise no PME, suspeitas de problemas causados pelo push de alteração de senha no Meu Alelo
insert into tvtspi.tbl_auto_kill_cron
select 'FPS_KILL_REPORTS' AS SERVICE
, s.sid || ',' || s.serial#|| case when s.inst_id is not null then ',@' || s.inst_id end  as SID_SERIAL
,decode(upper(s.WAIT_CLASS),'IDLE','I','*')||' '||
 to_char(nvl((case when e.qcsid is not null then e.qcsid || ',' || e.qcserial#|| case when e.inst_id is not null then ',@' || e.inst_id end end),substr(trim(s.WAIT_CLASS),1,13)))  as SLAVE
,    to_char(p.pid)          as opid
,    to_char(p.spid)         as sopid
,    substr(s.username,1,10)||decode(s.username,'SYS',SUBSTR(nvl2(s.module,' [',null)||UPPER(s.module),1,6)||nvl2(s.module,']',null)) as username
,    substr(s.osuser,1,10)   as osuser
--,    substr(s.program,1,10)  as program
,    case when instr(s.program,'(J0') > 0  then substr(s.program,instr(s.program,'(J0'),10)||'-JOB' else substr(s.program,1,10) end  as program
,    substr(replace(s.machine,'EMISSAO'),1,20)  as machine
,    to_char(s.logon_time,'ddmmrrhh24mi') as logon_time
,        to_char(s.last_call_et)              as call_et
,    substr((select trim(replace(replace(substr(event,1,100),'SQL*Net'),'Streams')) from gv$session_wait j where j.sid = s.sid and j.INST_ID =  s.inst_id),1,25) as sessionwait
,        s.sql_id  as sql_id
,    s.blocking_session || ',' || s.blocking_instance as hold
,        to_char(s.seconds_in_wait) as sc_wait
,     SUBSTR(nvl2(s.module,'[',null)||UPPER(trim(s.module)),1,6)||nvl2(s.module,']',null) as module
,      'alter system kill session ''' || s.sid || ',' ||s.serial# || ',@' ||s.inst_id||''' immediate ' comando
,     case when s.seconds_in_wait >= 0 then 'KILL' ELSE 'NO_KILL' end state
,     SYSDATE DT_INCL
,     null    DT_KILL
FROM   gv$session         s,
       gv$px_session      e,
       gv$process         p
WHERE
  s.inst_id     = e.inst_id (+)
  and s.sid         = e.sid     (+)
  and s.serial#     = e.serial# (+)
  and s.paddr       = p.addr    (+)
  and s.inst_id     = p.inst_id (+)
and s.inst_id in (select INSTANCE_NUMBER from v$instance)
        and s.sql_id  = '&1'
order by s.seconds_in_wait desc
/


--SELECT  * FROM  TVTSPI.TBL_KILL_BACKOFFICE_FACADE;
--delete TVTSPI.TBL_KILL_BACKOFFICE_FACADE; commit;
set serveroutput on
set timing on
SET FEEDBACK off
set time on
column filename new_val filename
select to_char(sysdate, 'yyyymmddhh24miss' )||'_CRON_kill_auto.log' filename from dual;
column hostname new_val hostname
SELECT  UPPER(A.HOST_NAME) hostname FROM V$INSTANCE A;
spool $ORACLE_BASE/TVTDBA/AUTO/logs/&hostname/&filename
declare
    cursor sid is
select b.comando comando, rowid as rw, b.SID_SERIAL, b.sc_wait, b.sql_id
        from tvtspi.tbl_auto_kill_cron b
     WHERE state = 'KILL'
order by to_number(sc_wait);
       v varchar2(600);
       v_tot number  := 0;
           v_cc  integer := 0;
begin
    for a in sid
    loop
        begin
           execute immediate a.comando;
           update tvtspi.tbl_auto_kill_cron set DT_KILL = sysdate,  state = 'KILLED' where rowid = a.rw;
           --dbms_output.put_line('Killed: SID_SERIAL: '||a.SID_SERIAL||' (WAIT: '||lpad(a.sc_wait,8,'0')||') -,- (SQLID: '||a.sql_id||')  ok!');
           v_tot := v_tot +1;
                   v_cc  := v_cc + 1;
                   if v_cc > 10 then
                      commit;
                      v_cc := 0;
                   end if;
        exception
        when others then
            update tvtspi.tbl_auto_kill_cron set DT_KILL = sysdate,  state = 'KILLED*' where rowid = a.rw;
            --dbms_output.put_line('Error Kill: SID_SERIAL: '||a.SID_SERIAL||' ('||lpad(a.sc_wait,8,'0')||'');
        end;
    end loop;
        commit;
        IF v_tot > 0 THEN
                dbms_output.put_line(' ');
                dbms_output.put_line('----------------------------------------------------------------');
                dbms_output.put_line(' T O T A L   K I L L : '||LPAD(v_tot,8,'0'));
                dbms_output.put_line('----------------------------------------------------------------');
    END IF;
end;
/
spool off
