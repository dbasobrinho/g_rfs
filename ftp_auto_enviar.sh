ftp -in 200.185.21.13 <<END
user ad/roberto.fernandes `cat sec`
binary
cd $1
mput $2
bye
END




ftp -in 200.999.21.13 <<END
user "ad/roberto.fernandes" ""
binary
cd GUINA_BKP1
mput orapwpauto
bye
END