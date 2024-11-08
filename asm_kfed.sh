
#! /bin/sh
#
# You many need to change ASM_DISK_PATH to pick up  all availabe ASM disks
#
#   /dev/mapper/grac41_disk*p1   for MULTTPATH devices 
#   /dev/asmdisk_OF-disk*        for UDEV configuration or
#   dev/oracleasm/disks/*        for ASMLIB managed disks
# https://www.hhutzler.de/blog/troubleshooting-asm-disk-related-issues-using-kfed-and-kfod/
#   

rm /tmp/kfed*out
ASM_DISK_PATH='/dev/oracleasm/disks/*' # <--------- needs editing
ASM_OWNER=oracle                                            #  <asm_home sfw owner here>  <--------- needs editing
DB_OWNER=oracle                                           #  <db_home sfw owner here>   <--------- needs editing
ASM_OH=/u01/app/11.2.0/grid                                # ASM ORACLE_HOME             <--------- needs editing
DB_OH=/u01/app/oracle/product/11.2.0/db_1                # DB ORACLE_HOME              <--------- needs editing
ls -l $ASM_DISK_PATH
cd $ASM_OH                      # <asm_home>   # <--------- needs editing
for i in `ls  $ASM_DISK_PATH`
   do
   echo "./kfed read $i  >> /tmp/kfed_DH.out "
   $ASM_OH/bin/kfed read $i >> /tmp/kfed_DH.out
   echo "./kfed read $i blkn=1  >> /tmp/kfed_FS.out"
   $ASM_OH/bin/kfed read $i blkn=1  >> /tmp/kfed_FS.out
   echo  "./kfed read $i  aun=1 blkn=254 >> /tmp/kfed_BK.out"
   $ASM_OH/bin/kfed read $i  aun=1 blkn=254 >> /tmp/kfed_BK.out
   echo  "./kfed read $i aun=2 blkn=1 >> /tmp/kfed_FD.out"
   $ASM_OH/bin/kfed read $i aun=2 blkn=1 >> /tmp/kfed_FD.out
   echo   "./kfed read $i aun=2 blkn=2   >> /tmp/kfed_DD.out"
   $ASM_OH/bin/kfed read $i aun=2 blkn=2 >> /tmp/kfed_DD.out
done
cat /tmp/kfed_DH.out | egrep 'type|name|kfed|block.blk'
echo " -> Further details can be found in files listed by  : ls -l /tmp/kfed*out "