--Script: REDO_TAXA_OCUPACAO_REDO_ATUAL
--Data:   06/04/2013
--Autor: Marcio Guimaraes
--Finalidade: Lista o percentual ocupado pelo redo log file atualmente preenchido


SELECT ROUND((CPODR_BNO/LESIZ),2)* 100 || '%' PCTLOGFULL
FROM x$kcccp a , x$kccle b
WHERE a.cpodr_seq = leseq
/