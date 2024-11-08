asm_mapping.sh
printf "\n%-15s %-14s %-11s %-7s\n" "ASM disk" "based on" "Minor,Major" "Size (Mb)"
printf "%-15s %-14s %-11s %-7s\n" "===============" "=============" "===========" "========="
export ORACLE_HOME=/u01/app/grid/11gR2
for i in `/etc/init.d/oracleasm listdisks`
do
v_asmdisk=`/etc/init.d/oracleasm querydisk -d $i | awk '{print $2}'| sed 's/\"//g'`
v_minor=`/etc/init.d/oracleasm querydisk -d  $i | awk -F[ '{print $2}'| awk -F] '{print $1}' | awk -F,  '{print $1}'`
v_major=`/etc/init.d/oracleasm querydisk -d $i | awk -F[ '{print $2}'| awk -F] '{print $1}' | awk -F, '{print $2}'`
v_device=`ls -la /dev | awk -v v_minor="$v_minor," -v v_major=$v_major '{if ( $5==v_minor ) { if ( $6==v_major ) { print $10}}}'`
v_size=`${ORACLE_HOME}/bin/kfod asm_diskstring='ORCL:*' disks=all | grep ${v_asmdisk} | awk '{print $2}'`
Total_size=`expr $Total_size + $v_size`
Formated_size=`echo $v_size | sed -e :a -e 's/\(.*[0-9]\)\([0-9]\{3\}\)/\1,\2/;ta'`
printf "%-15s %-14s %-11s %-7s\n" $v_asmdisk "/dev/$v_device" "[$v_minor $v_major]" $Formated_size
done
Formated_Total_size=`echo $Total_size | sed -e :a -e 's/\(.*[0-9]\)\([0-9]\{3\}\)/\1,\2/;ta'`
printf "\nTotal: %43s\n\n" $Formated_Total_size