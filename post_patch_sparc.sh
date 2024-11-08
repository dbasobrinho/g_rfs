INSTANCE_RUNNING=`ps -ef | grep -i pmon | egrep -iv "asm|grep|awk" | awk -F"_pmon_" '{print$3}'`
## Executa um loop de parametrizacao para cada instancia
for inst in `echo $INSTANCE_RUNNING | sed -e 's/+ASM//g'`
do
export ORACLE_SID=$inst
sqlplus / as sysdba <<EOF
SPO /tmp/$inst.txt
@$ORACLE_HOME/rdbms/adsfsdmin/catbundle.sql psu apply
$ORACLE_HOME/rdbms/admin/utlrp.sql
COLUMN comp_id    FORMAT a9    HEADING 'Component|ID'
COLUMN comp_name  FORMAT a35   HEADING 'Component|Name'
COLUMN version    FORMAT a13   HEADING 'Version'
COLUMN status     FORMAT a11   HEADING 'Status'
COLUMN modified                HEADING 'Modified'
COLUMN Schema     FORMAT a15   HEADING 'Schema'
COLUMN procedure  FORMAT a45   HEADING 'Procedure'
SELECT
    comp_id
  , comp_name
  , version
  , status
  , modified
  , schema
  , procedure
FROM
    dba_registry
ORDER BY
    comp_id;
exit
EOF
done

ps -ef | grep -i pmon | egrep -iv "asm|grep|awk" | awk -F"_pmon_" '{print$3}'