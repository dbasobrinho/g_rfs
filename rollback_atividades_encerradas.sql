--Script: ROLLBACK_ATIVIDADES_ENCERRADAS
--Data:   15/04/2012
--Autor: Marcio Guimaraes
--Finalidade: Listar atividades de UNDO encerradas (Kernel Transaction Undo)
--Versão: 1.0 


 select ktuxeusn, to_char(sysdate,'DD-MON-YYYY HH24:MI:SS') "Time", ktuxesiz, ktuxesta
   from x$ktuxe
   where ktuxecfl = 'DEAD'
   and ktuxesiz > 0