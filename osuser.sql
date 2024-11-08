undef osuser
accept osuser prompt 'Qual o nome do usuário no S.O? '
set lines 200
SELECT P.TRACEFILE FROM V$SESSION S, V$PROCESS P WHERE S.PADDR = P.ADDR AND S.OSUSER = '&&osuser';

