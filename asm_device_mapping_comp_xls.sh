#!/bin/bash
## ASMLIB_DISK  -- disk name in ASMLIB
## ASM_DISK -- disk name in ASM
## DEVICE -- physical disk name
GRID_HOME=`cat /etc/oratab  | grep ^+ASM | awk -F":" '{print $2}'`
for ASMLIB_DISK in `ls /dev/oracleasm/disks/*`
  do
    ASM_DISK=`$GRID_HOME/bin/kfed read $ASMLIB_DISK | grep dskname | tr -s ' '| cut -f2 -d' '`
    majorminor=`ls -l $ASMLIB_DISK | tr -s ' ' | cut -f5,6 -d' '`
    device=`ls -l /dev/ | tr -s ' ' | grep -w "$majorminor" | cut -f10 -d' '`
	echo "$ASM_DISK ;$ASMLIB_DISK;/dev/$device;"
done