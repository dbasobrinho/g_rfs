# /bin/bash

export servername=`hostname`
export datahora=`date +%Y%m%d_%H%M`
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
   oratab='/etc/oratab'
elif [[ "$unamestr" == 'AIX' ]]; then
   oratab='/etc/oratab'
elif [[ "$unamestr" == 'SunOS' ]]; then
   oratab='/var/opt/oracle/oratab'
fi

export ORACLE_SID=`ps -ef | grep pmon | grep -v grep | grep ASM | cut -d_ -f3| sort`
export GRID_HOME=`sed /^#/d ${oratab} | grep -w "${ORACLE_SID}:" | awk -F: '{print $2}'`
export OUTPUT_FILE=${servername}_${datahora}.txt

echo 'Server: '$servername > ${OUTPUT_FILE}
echo '####################################################################################################################' >> ${OUTPUT_FILE}
echo 'netstat -rn'  >> ${OUTPUT_FILE}
netstat -rn >> ${OUTPUT_FILE}
echo '####################################################################################################################' >> ${OUTPUT_FILE}
echo 'df -k '  >> ${OUTPUT_FILE}
df -k  >> ${OUTPUT_FILE}
echo '####################################################################################################################' >> ${OUTPUT_FILE}
echo 'uname -a'  >> ${OUTPUT_FILE}
uname -a  >> ${OUTPUT_FILE}
echo '####################################################################################################################' >> ${OUTPUT_FILE}
echo 'ifconfig -a'  >> ${OUTPUT_FILE}
ifconfig -a  >> ${OUTPUT_FILE}
echo '####################################################################################################################' >> ${OUTPUT_FILE}
echo 'nslookup' >> ${OUTPUT_FILE}
#nslookup  >> ${OUTPUT_FILE}
echo '####################################################################################################################' >> ${OUTPUT_FILE}
echo 'ps -ef |grep tnslsnr'  >> ${OUTPUT_FILE}
ps -ef |grep tnslsnr  >> ${OUTPUT_FILE}
echo '####################################################################################################################' >> ${OUTPUT_FILE}
echo 'ps -er |grep pmon'  >> ${OUTPUT_FILE}
ps -ef |grep pmon  >> ${OUTPUT_FILE}
echo '####################################################################################################################' >> ${OUTPUT_FILE}
echo 'cat /etc/oratab'  >> ${OUTPUT_FILE}
cat /etc/oratab  >> ${OUTPUT_FILE}
echo '####################################################################################################################' >> ${OUTPUT_FILE}
echo 'cat /etc/oraInst.loc'  >> ${OUTPUT_FILE}
cat /etc/oraInst.loc  >> ${OUTPUT_FILE}
echo '####################################################################################################################' >> ${OUTPUT_FILE}
echo 'cat /etc/hosts'  >> ${OUTPUT_FILE}
cat /etc/hosts  >> ${OUTPUT_FILE}
echo '####################################################################################################################' >> ${OUTPUT_FILE}
echo 'lsinventory '  >> ${OUTPUT_FILE}

if [ -n "$GRID_HOME"   ] ; then
  export ORACLE_HOME=$GRID_HOME
  $ORACLE_HOME/OPatch/opatch lsinventory  >> ${OUTPUT_FILE}
fi 

for db in $(ps -ef | grep pmon | grep -v grep | grep -v ASM | grep -v MGMTDB | cut -d_ -f3| sort)
do
  export ORACLE_SID=$db
  if [[ "$unamestr" == 'Linux' ]]; then
     export ORACLE_HOME=`sed /^#/d ${oratab} | grep -w "${ORACLE_SID}:" | awk -F: '{print $2}'`
  elif [[ "$unamestr" == 'AIX' ]]; then
     export ORACLE_HOME=`sed /^#/d ${oratab} | grep -w "${ORACLE_SID}:" | awk -F: '{print $2}'`
  elif [[ "$unamestr" == 'SunOS' ]]; then
     export ORACLE_HOME=`grep "${ORACLE_SID}:"  "${oratab}" | awk -F: '{print $2}'`
  fi
  export NEW_HOME=no_home
  if [ "$NEW_HOME"  != "$ORACLE_HOME" ] ; then
    $ORACLE_HOME/OPatch/opatch lsinventory  >> ${OUTPUT_FILE}
    export NEW_HOME=$ORACLE_HOME
  fi 
done

if [ -n "$GRID_HOME"   ] ; then
  export ORACLE_HOME=$GRID_HOME
  echo '####################################################################################################################' >> ${OUTPUT_FILE}
  echo '$GRID_HOME/bin/crsctl stat res -t'                                                                                    >> ${OUTPUT_FILE}
  $GRID_HOME/bin/crsctl stat res -t                                                                                           >> ${OUTPUT_FILE}
  echo '####################################################################################################################' >> ${OUTPUT_FILE}
  echo '$GRID_HOME/bin/crsctl stat res -p'                                                                                    >> ${OUTPUT_FILE}
  $GRID_HOME/bin/crsctl stat res -p                                                                                           >> ${OUTPUT_FILE}
  echo '####################################################################################################################' >> ${OUTPUT_FILE}
  echo '$GRID_HOME/bin/crsctl query css votedisk'                                                                             >> ${OUTPUT_FILE}
  $GRID_HOME/bin/crsctl query css votedisk                                                                                    >> ${OUTPUT_FILE}
  echo '####################################################################################################################' >> ${OUTPUT_FILE}
  echo '$GRID_HOME/bin/ocrcheck'                                                                                              >> ${OUTPUT_FILE}
  $GRID_HOME/bin/ocrcheck                                                                                                     >> ${OUTPUT_FILE}
  echo '####################################################################################################################' >> ${OUTPUT_FILE}
  echo '$GRID_HOME/bin/oifcfg getif'                                                                                          >> ${OUTPUT_FILE}
  $GRID_HOME/bin/oifcfg getif                                                                                                 >> ${OUTPUT_FILE}
  echo '####################################################################################################################' >> ${OUTPUT_FILE}
  echo '$GRID_HOME/bin/srvctl config nodeapps -a'                                                                             >> ${OUTPUT_FILE}
  $GRID_HOME/bin/srvctl config nodeapps -a                                                                                    >> ${OUTPUT_FILE}
  echo '####################################################################################################################' >> ${OUTPUT_FILE}
  echo '$GRID_HOME/bin/srvctl config scan -a'                                                                                 >> ${OUTPUT_FILE}
  $GRID_HOME/bin/srvctl config scan                                                                                           >> ${OUTPUT_FILE}
  export scn_name=`$GRID_HOME/bin/srvctl config scan |grep "SCAN name" | grep -v grep | awk '{print $3}' |cut -f 1,15 -d ,`
  if [ -n "$scn_name" ] ; then
    echo '####################################################################################################################' >> ${OUTPUT_FILE}
    echo 'nslookup scan name'                                                                                                   >> ${OUTPUT_FILE}
    nslookup $scn_name                                                                                                        >> ${OUTPUT_FILE}
  fi
  echo '####################################################################################################################' >> ${OUTPUT_FILE}
  echo '$GRID_HOME/bin/srvctl config asm -a'                                                                                  >> ${OUTPUT_FILE}
  $GRID_HOME/bin/srvctl config asm -a                                                                                         >> ${OUTPUT_FILE}
  echo '####################################################################################################################' >> ${OUTPUT_FILE}
  echo 'listener status'                                                                                                      >> ${OUTPUT_FILE}
  for lsnr in $(ps -ef | grep tnslsnr | grep -v grep | awk '{print $8 "-" $9}')
  do
    export ORACLE_HOME=`echo ${lsnr%bin*}`
    export LSN_NAME=`echo ${lsnr#*-}`
    $ORACLE_HOME/bin/lsnrctl status $LSN_NAME                                                                                 >> ${OUTPUT_FILE}
    $ORACLE_HOME/bin/lsnrctl services $LSN_NAME                                                                                 >> ${OUTPUT_FILE}
  done
  echo '####################################################################################################################' >> ${OUTPUT_FILE}
  echo "$GRID_HOME/bin/srvctl config listener -a"  >> ${OUTPUT_FILE}
  for lsnr in $(ps -ef | grep tnslsnr | grep -v grep | awk '{print $8 "-" $9}')
  do
    export ORACLE_HOME=`echo ${lsnr%bin*}`
    export LSN_NAME=`echo ${lsnr#*-}`
    echo '$GRID_HOME/bin/srvctl config listener -l' $LSN_NAME   >> ${OUTPUT_FILE}
    $GRID_HOME/bin/srvctl config listener -l $LSN_NAME  -a  >> ${OUTPUT_FILE}
  done
  echo '####################################################################################################################' >> ${OUTPUT_FILE}
  for db in $(ps -ef | grep pmon | grep -v grep | grep -v ASM | grep -v MGMTDB | cut -d_ -f3| sort)
  do
    export ORACLE_SID=$db
    echo $GRID_HOME/bin/srvctl config database -d $ORACLE_SID -a                                                              >> ${OUTPUT_FILE}
    $GRID_HOME/bin/srvctl config database -d $ORACLE_SID -a                                                                   >> ${OUTPUT_FILE} 
  done
  echo '####################################################################################################################' >> ${OUTPUT_FILE}

  for db in $(ps -ef | grep pmon | grep -v grep | grep ASM | cut -d_ -f3| sort)
  do
    export ORACLE_SID=$db
    if [[ "$unamestr" == 'Linux' ]]; then
       export ORACLE_HOME=`sed /^#/d ${oratab} | grep -w "${ORACLE_SID}:" | awk -F: '{print $2}'`
    elif [[ "$unamestr" == 'AIX' ]]; then
       export ORACLE_HOME=`sed /^#/d ${oratab} | grep -w "${ORACLE_SID}:" | awk -F: '{print $2}'`
    elif [[ "$unamestr" == 'SunOS' ]]; then
       export ORACLE_HOME=`grep "${ORACLE_SID}:"  "${oratab}" | awk -F: '{print $2}'`
    fi
    export NEW_HOME=no_home
    $ORACLE_HOME/bin/sqlplus -s /nolog <<__eof__
      connect / as sysdba
      set echo on
      set linesize 200
      set pages 200
      alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
      spool report_${db}.txt
      select * from v\$version;

      prompt
      prompt ASM Disk Groups
      prompt ===============
      set wrap off
      set line 200
      set pages 200
      col host_name format a35
      col name format a30
      col instance_name format a10
      col state for a15
      col type for a10
      select  host_name
      ,       instance_name
      ,       name
      ,       STATE
      ,       type
      ,       total_mb
      ,       free_mb
      ,       round(decode(free_mb,0,1,free_mb)/decode(free_mb,0,1,total_mb)*100,2) free_pct
      ,       100-round((decode(free_mb,0,1,free_mb)/decode(free_mb,0,1,total_mb))*100,2) used_pct
      ,       round((FREE_MB - REQUIRED_MIRROR_FREE_MB ) / (decode(type,'EXTERNAL',3,'NORMAL',2,1))) FREE_USABLE_MB
      ,       round((TOTAL_MB - REQUIRED_MIRROR_FREE_MB ) / (decode(type,'EXTERNAL',3,'NORMAL',2,1))) TOTAL_USABLE_MB
      ,       round(((FREE_MB - REQUIRED_MIRROR_FREE_MB ) / (decode(type,'EXTERNAL',3,'NORMAL',2,1)))/
              (round((TOTAL_MB - REQUIRED_MIRROR_FREE_MB ) / (decode(type,'EXTERNAL',3,'NORMAL',2,1))))*100,2) FREE_USABLE_PCT
      from    v\$asm_diskgroup, v\$instance
      where total_mb>0
      order by name;


      set line 1000
      set pages 300
      col "Group"          form 999
      col "Disk"           form 999
      col "Header"         form a15
      col "Mode"           form a8
      col "Redundancy"     form a10
      col "Failure Group"  form a30
      col "Path"           form a80
      select group_number  "Group"
      ,      disk_number   "Disk"
      ,      header_status "Header"
      ,      mode_status   "Mode"
      ,      state         "State"
      ,      redundancy    "Redundancy"
      ,      total_mb      "Total MB"
      ,      free_mb       "Free MB"
      ,      name          "Disk Name"
      ,      failgroup     "Failure Group"
      ,      path          "Path"
      from   v\$asm_disk
      order by group_number,path, name;
      
      exit;
__eof__

    cat report_${db}.txt >> ${OUTPUT_FILE}
  done
fi 
