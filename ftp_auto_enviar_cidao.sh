#!/bin/bash
DIR_ORIGEM=/backup/oracle/filesystem/archives_teste
DIR_ENVIAR=/backup/oracle/filesystem/archives_enviar
DIR_ENVIADO=/backup/oracle/filesystem/archives_enviado
FTP_DIR=asilva
STRING_ARQUIVO="BACKUP_arch*"
STRING_ARQ_FTP="./${STRING_ARQUIVO}"
cd ${DIR_ENVIAR}
find ${DIR_ORIGEM} -type f -name ${STRING_ARQUIVO} -mmin +15 -print -exec mv {} ${DIR_ENVIAR} \;
ftp -in 200.185.21.13 <<END
user ad/aparecido.asilva `cat sec`
binary
cd ${FTP_DIR}
mput ${STRING_ARQ_FTP}
bye
END
mv BACKUP* ${DIR_ENVIADO}