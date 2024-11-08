du -shx ./*|sort -h
##/u01/app/oracle/diag/crs/geqj032/crs/trace

##Procura Texto dentro dos arquivos 
grep -Eir oraevepd *

find ./* -type f -exec grep -l dbm0db01-vip {} \;