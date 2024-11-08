###https://www.linkedin.com/pulse/adrci-e-limpeza-de-filesystems-luis-fontes-nqd8e/
### O QUE TEM SOMENTE NO /
find / -xdev -type f -exec du -sm {} \; | sort -n | tail -n <numero de linhas>
##>> Quem faz a "mágica" de limitar a arquivos que pertencem somente ao filesystem indicado é a flag -xdev.

##quando não temos outros filesystems dentro da pasta em que estamos, basicamente lista os maiores arquivos/pastas
cd  /u01 
du -xmS * | sort -n | tail -n <numero de linhas>


##E quando simplesmente não acha algum arquivo que esteja consumindo o tanto que aparece no df -h? Você compara o espaço que aparece no du com o df, e tem uma diferença considerável?

lsof +L1 
ou
lsof | grep deleted

############################



du -shx ./*|sort -h
du -sh * | grep G
##/u01/app/oracle/diag/crs/geqj032/crs/trace

find . -type f ! -newermt $(date +%Y-%m-%d) -size +100M -delete

##Procura Texto dentro dos arquivos LESSA
grep -Eir oraevepd *
find ./* -type f -exec grep -l dbm0db01-vip {} \;



##Apaga Tudao
find /u01/app/oracle/admin/tcprd/adump -name "*.aud*" -mtime +0 | xargs sudo rm -f;

find /u01/soaprd/domain/domain_soa_p2/servers/AdminServer_SOA_P2/logs -name "domain_soa_p2.log*" -mtime +2 | xargs sudo rm -f;


##Procura Arquivo 
find /u01/app/oracle -type f -size +1G
find /u01/ -type f -name tnsnames.ora > /dev/null
echo `find /u01/app/oracle -type f -name listener.ora 2>&1 | grep -v 'Permission denied'`
find /u01/app/oracle -type f -name listener.ora 2>&1 | grep -v 'Permission denied'

cat `find $ORACLE_HOME -type f -name tnsnames.ora 2> /dev/null`

cat `find /u01 -type f -name *. 2> /dev/null |grep USAGE_TRACKING` |  sed -n -e '/'${1}'/{=;x;1!p;g;$!N;p;D;}' -e h 

cat `find /u01 -type f -name NQSConfig.INI 2> /dev/null` |  sed -n -e '/USAGE_TRACKING/{=;x;2!p;g;$!N;p;D;}' -e h

cat `find /u01 -type f -name NQSConfig.INI 2> /dev/null |grep USAGE_TRACKING` |  sed -n -e '/'${1}'/{=;x;1!p;g;$!N;p;D;}' -e h 

cat `find /u01 -type f -name NQSConfig.INI 2> /dev/null` |  sed -n -e '/USAGE_TRACKING/{=;x;2!p;g;$!N;p;D;}' -e h



for h in $(seq 992 1024); do history -d 992; done; history -d $(history 1 | awk '{print $1}')