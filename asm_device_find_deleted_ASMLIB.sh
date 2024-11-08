#!/bin/bash
GRID_HOME=`cat /etc/oratab  | grep ^+ASM | awk -F":" '{print $2}'`
for device in `ls /dev/sd*`
  do
    asmdisk=`$GRID_HOME/bin/kfed read $device | grep ORCL | tr -s ' ' | cut -f2 -d' ' | cut -c1-4`
    if [ "$asmdisk" = "ORCL" ]
      then
      echo "Disk device $device may be an ASM disk"
    fi
done