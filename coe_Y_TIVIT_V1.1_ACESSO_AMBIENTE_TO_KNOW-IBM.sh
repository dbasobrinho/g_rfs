for db in $(ps -ef | grep pmon | grep -v grep | grep -v ASM | grep -v MGMTDB | cut -d_ -f3| sort)
do
SERVER_NAME=`hostname`
DATE=`date +%Y%m%d`
export ORACLE_SID=$db
export ORACLE_HOME=`sed /#/d /var/opt/oracle/oratab | grep -w "${ORACLE_SID}:" | awk -F: '{print $2}'`
#export ORACLE_HOME=`grep "${ORACLE_SID}:"  /etc/oratab | awk -F: '{print $2}'`
echo $ORACLE_SID
echo $ORACLE_HOME
export PATH=$ORACLE_HOME/bin:$PATH
export LIBPATH=$ORACLE_HOME/lib
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
export OUTPUT_FILE=${SERVER_NAME}_${DATE}.txt

echo " " >> $OUTPUT_FILE
$ORACLE_HOME/bin/srvctl config database -db ${db} -a >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE

sqlplus -s /nolog <<__eof__ 
connect / as sysdba

SET MARKUP HTML ON
set echo on
set linesize 200
set pages 200
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
spool report_${SERVER_NAME}_${db}.html
@coe_Y_TIVIT_V1.1_ACESSO_AMBIENTE_TO_KNOW-IBM.sql

exit

__eof__

done

ASM=`ps -ef | grep pmon | grep -v grep | grep ASM | grep -v MGMTDB | cut -d_ -f3| sort`
LISTENER=`ps -ef|grep tnsls|grep -v grep | awk -F" " '{print $9}'`
SERVER_NAME=`hostname`
DATE=`date +%Y%m%d`
export ORACLE_SID=$ASM
export GRID_HOME=`sed /#/d /var/opt/oracle/oratab | grep -w "${ORACLE_SID}:" | awk -F: '{print $2}'`
#export GRID_HOME=`grep "${ORACLE_SID}:"  /etc/oratab | awk -F: '{print $2}'`
echo $ORACLE_SID
echo $GRID_HOME
export PATH=$GRID_HOME/bin:$PATH
export LIBPATH=$GRID_HOME/lib
export LD_LIBRARY_PATH=$GRID_HOME/lib
export OUTPUT_FILE=${SERVER_NAME}_${DATE}.txt


echo " " >> $OUTPUT_FILE
echo "===============================================================================" >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE
$GRID_HOME/bin/crsctl stat res -t >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE
echo "===============================================================================" >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE
$GRID_HOME/bin/crsctl stat res -p >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE
echo "===============================================================================" >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE
$GRID_HOME/bin/crsctl query css votedisk >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE
echo "===============================================================================" >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE
$GRID_HOME/bin/ocrcheck >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE
echo "===============================================================================" >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE
$GRID_HOME/bin/oifcfg getif >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE
echo "===============================================================================" >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE
$GRID_HOME/bin/srvctl config nodeapps -a >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE
echo "===============================================================================" >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE
$GRID_HOME/bin/srvctl config scan >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE
echo "===============================================================================" >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE
$GRID_HOME/bin/srvctl config asm -a >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE
echo "===============================================================================" >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE
$GRID_HOME/bin/srvctl config listener -l ${LISTENER} -a >> $OUTPUT_FILE
echo " " >> $OUTPUT_FILE



