#!/bin/bash 
#
# ./check_asm_dsk.sh >CHECK_ASM_DSK.OUT 2>&1; cat  CHECK_ASM_DSK.OUT
#https://www.hhutzler.de/blog/troubleshooting-asm-disk-related-issues-using-kfed-and-kfod/
ASM_DISK_STRING="/dev/asmdisk* /dev/oracleasm/disks/*"    #  ASM Disk Discovery String  <--------- needs editing
ASM_OWNER=oracle                                            #  <asm_home sfw owner here>  <--------- needs editing
DB_OWNER=oracle                                           #  <db_home sfw owner here>   <--------- needs editing
ASM_OH=/u01/app/11.2.0/grid                                # ASM ORACLE_HOME             <--------- needs editing
DB_OH=/u01/app/oracle/product/11.2.0/db_1                # DB ORACLE_HOME              <--------- needs editing

 echo $ id 
 id 
 echo $ id $ASM_OWNER  
 id  $ASM_OWNER                                                   #  <asm_home sfw owner here>   <--------- needs editing
 echo $ id $DB_OWNER 
 id   $DB_OWNER                                                  #  <db_home sfw owner here>   <--------- needs editin
 echo $ ls -ltra $ASM_OH/bin/oracle 
 ls -ltra $ASM_OH/bin/oracle                   # <asm_home>/bin/oracle   # <--------- needs editing
 echo $  -ltra $DB_OH/bin/oracle
 ls -ltra $DB_OH/bin/oracle   #  <oracle_home>/bin/oracle <--------- needs editing
 echo $ cat /etc/*-release
 cat /etc/*-release
 echo $ cat /etc/issue
 cat /etc/issue
 echo $ cat /proc/version
 cat /proc/version
 echo $ lsb_release -id
 lsb_release -id
 echo $ uname -a
 uname -a
 echo $  rpm -qa|grep oracleasm
 rpm -qa|grep oracleasm
 echo $ /etc/init.d/oracleasm status 
 /etc/init.d/oracleasm status
 echo $ /sbin/lsmod | grep oracleasm
 /sbin/lsmod | grep oracleasm
 echo $ df -ha
 df -ha
 date
 echo $ ls -ltra  $ASM_DISK_STRING 
 ls -ltra  $ASM_DISK_STRING 
 for i in `ls  $ASM_DISK_STRING`   
   do
   echo "$ dd if=$i of=/dev/null bs=1048576 count=5"
   dd if=$i of=/dev/null bs=1048576 count=5         #<----- the following command only attempts to read a devie (it does not write anything)
   echo  ""
 done

 echo $ cat /proc/partitions
 cat /proc/partitions
 echo "-> ASMLIB disks discover"
 /etc/init.d/oracleasm querydisk -d  `/etc/init.d/oracleasm listdisks -d` |
 cut -f2,10,11 -d" " | perl -pe 's/"(.*)".*\[(.*), *(.*)\]/$1 $2 $3/g;' |
 while read v_asmdisk v_minor v_major
 do
 v_device=`ls -la /dev | grep " $v_minor, *$v_major " | awk '{print $10}'`
 echo "ASM disk $v_asmdisk based on /dev/$v_device [$v_minor, $v_major]"
 done

 echo $ /etc/init.d/oracleasm listdisks    # (either from /usr/sbin or /etc/init.d directories)
 /etc/init.d/oracleasm listdisks           # (either from /usr/sbin or /etc/init.d directories)
 echo $ /usr/sbin/./oracleasm-discover
 /usr/sbin/./oracleasm-discover
 cd $ASM_OH/bin                # (ASM Oracle Home)     <--------- needs editing
 echo $ ./kfod asm_diskstring=$ASM_DISK_STRING disks=all
 ./kfod asm_diskstring=$ASM_DISK_STRING" disks=all
# Display ASMLIB managed Diks only 
    # Use /dev/oracleasm/disks/* instead of ORCL:* to avoid user and grop are reported as unknown 
 echo $ ./kfod asm_diskstring="/dev/oracleasm/disks/*" disks=all
 ./kfod asm_diskstring="/dev/oracleasm/disks/*" disks=all"
 echo $ ./kfod disks=all
 ./kfod disks=all
 echo $ cat /etc/sysconfig/oracleasm
 cat /etc/sysconfig/oracleasm
 exit