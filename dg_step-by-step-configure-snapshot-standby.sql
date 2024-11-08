prompt ========================================================================================
PROMPT PROCEDIMENTO SNAPSHOT STANDBY DATABASE
prompt ========================================================================================
prompt . . .
prompt ========================================================================================
PROMPT PASSO 01 >> VERIFIQUE A FUNÇÃO PRIMARY E STANDBY
prompt select status,instance_name,database_role,open_mode from v$database,v$Instance;
prompt ========================================================================================
prompt . . .
prompt ========================================================================================
PROMPT PASSO 02 >> VERIFIQUE A SEQUÊNCIA ARQUIVADA NO PRIMARY E STANDBY,
prompt select thread#,max(sequence#), max(FIRST_TIME) from v$archived_log group by thread#;
prompt @dg.sql
prompt @dg_status.sql
prompt ========================================================================================
prompt . . .
prompt ========================================================================================
PROMPT PASSO 03 >> VERIFIQUE O STATUS DO FLASHBACK E A LOCALIZAÇÃO DO DB_RECOVERY_FILE_SET
prompt select flashback_on from v$database;
prompt show parameter db_recovery_file_dest
prompt @ver_archive
prompt @flashback_db_info.sql
prompt ========================================================================================
prompt . . .
prompt ========================================================================================
PROMPT PASSO 04 >> NO STANDBY, PARE O PROCESSO DE MRP.
prompt alter database recover managed standby database cancel;
prompt ========================================================================================
prompt . . .
prompt ========================================================================================
PROMPT PASSO 05 >> BAIXAR O BANCO DE DADOS E EM SEGUIDA DEIXAR EM ESTADO DE MOUNT
prompt shut immediate <GUINA>;
prompt startup mount
prompt ========================================================================================
prompt . . .
prompt ========================================================================================
PROMPT PASSO 06 >> CONVERTER PARA BANCO DE DADOS PARA SNAPSHOT STANDBY DATABASE
prompt alter database convert to snapshot standby
prompt ========================================================================================
prompt . . .
prompt ========================================================================================
PROMPT PASSO 07 >> ABRIR O BANCO DE DADOS STANDBY NO MODO READ/WRITE
prompt alter database open
prompt ========================================================================================
prompt . . .
prompt ========================================================================================
PROMPT PASSO 08 >> VERIFIQUE O DATABASE_ROLE E OPEN_MODE
prompt select status,instance_name,database_role,open_mode from v$database,v$Instance;
prompt @db_status
prompt ========================================================================================
prompt . . .
prompt ========================================================================================
PROMPT PASSO 09 >> TESTE NO BANCO DE DADOS SNAPSHOT STANDBY DATABASE
prompt CREATE TABLE TB_GUINA AS SELECT * FROM DBA_OBJECTS;
prompt ========================================================================================
prompt . . .
prompt ========================================================================================
PROMPT VOLTANDO PARA STANDBY
prompt ========================================================================================
prompt . . .
prompt ========================================================================================
PROMPT PASSO 10 >> BAIXAR O BANCO DE DADOS E EM SEGUIDA DEIXAR EM ESTADO DE MOUNT
prompt shut immediate <GUINA>;
prompt startup mount
prompt ========================================================================================
prompt . . .
prompt ========================================================================================
PROMPT PASSO 11 >> CONVERTER O BANCO DE SNAPSHOT STANDBY PARA  PHYSICAL STANDBY 
prompt alter database convert to physical standby;
prompt ========================================================================================
prompt . . .
prompt ========================================================================================
PROMPT PASSO 12 >>  VERIFIQUE O BANCO DE DADOS STANDBY DATABASE_ROLE E MODE
prompt select status,instance_name,database_role,open_mode from v$database,v$Instance;
prompt ========================================================================================
prompt . . .
prompt ========================================================================================
PROMPT PASSO 13 >> Habilitar o processo MRP
prompt ALTER DATABASE RECOVER MANAGED STANDBY DATABASE  THROUGH ALL SWITCHOVER DISCONNECT  USING CURRENT LOGFILE;
prompt ========================================================================================
prompt . . .
PROMPT.                                                                                                                     ______ _ ___
PROMPT.                                                                                                                    |_  / _` / __| +-+-+-+-+-+-+-+-+-+-+
PROMPT.                                                                                                         _   _   _   / / (_| \__ \ |r|f|s|o|b|r|i|n|h|o|
PROMPT.                                                                                                        (_) (_) (_) /___\__,_|___/ +-+-+-+-+-+-+-+-+-+-+
PROMPT     O GUINA NAO TINHA DÓ, SE REGIR, BUMMM! VIRA PÓ . . . 



