while true
do
r=`ps -ef |grep "racgmain check" |grep -v grep|wc -l`
if [ ${r} -gt 1 ]
then
        echo "`date +"%d/%m/%y %H:%M:%S"` - PROCESS = "${r}"  ####### BUG - Many Orphaned Or Hanging (racgmain) Processes Running (Doc ID 732086.1) #######" >> /tmp/scr/bug_racgmain_10g_Doc_Id_732086.1.out
        ps -ef|awk '/[r]acgmain check/ {print $2,$5}'
else
    echo "`date +"%d/%m/%y %H:%M:%S"` - PROCESS = "${r}"  ** RACGMAIN CHECK OK **" >> /tmp/scr/bug_racgmain_10g_Doc_Id_732086.1.out
fi
sleep 30
done
##BUG - Many Orphaned Or Hanging (racgmain) Processes Running (Doc ID 732086.1)
##BUG - Bug 8572205 : CHILDCRASH, OS ERROR: 0, OTHER: ABNORMAL TERMINATION OF CHILD
##BUG - Patch 6196746: LNX070704 - HUGE AND GROWING LIST OF RACG CHECK VIP PROCESSES, TIMEOUT
##BUG - Bug 6196746 - Orphaned racgmain processes remain (Doc ID 6196746.8)
##while true; do ps -ef|grep "racgmain check"|wc -l; sleep 2; done;
======================================================================================
##/home/oracle/dba/monitor_racg
NOW=`date +%Y-%m-%d:%H:%M:%S`
echo ' '>>/home/oracle/dba/monitor_racg/saida_monitor_racg.log
echo $NOW >>/home/oracle/dba/monitor_racg/saida_monitor_racg.log
echo ' '>>/home/oracle/dba/monitor_racg/saida_monitor_racg.log
ps -ef|grep "racgmain check" |grep -v grep>>/home/oracle/dba/monitor_racg/saida_monitor_racg.log
ps -ef|grep "racgmain check"|grep -v grep|wc -l >>/home/oracle/dba/monitor_racg/saida_monitor_racg.log
echo ' '>>/home/oracle/dba/monitor_racg/saida_monitor_racg.log
echo ' '>>/home/oracle/dba/monitor_racg/saida_monitor_racg.log
=======================================================================================



while true
do
r=`ps -ef |grep "racgmain check" |grep -v grep|wc -l`
if [ ${r} -gt -1 ]
then
        echo "`date +"%d/%m/%y %H:%M:%S"` - PROCESS = "${r}"  ####### BUG - Many Orphaned Or Hanging (racgmain) Processes Running (Doc ID 732086.1) #######" ##>> /tmp/scr/bug_racgmain_10g_Doc_Id_732086.1.out
        ps -ef|awk '/[p]mon/ {print $2,$5}'
else
    echo "`date +"%d/%m/%y %H:%M:%S"` - PROCESS = "${r}"  ** RACGMAIN CHECK OK **" ##>> /tmp/scr/bug_racgmain_10g_Doc_Id_732086.1.out
fi
sleep 2
done
##BUG - Many Orphaned Or Hanging (racgmain) Processes Running (Doc ID 732086.1)
##BUG - Bug 8572205 : CHILDCRASH, OS ERROR: 0, OTHER: ABNORMAL TERMINATION OF CHILD
##BUG - Patch 6196746: LNX070704 - HUGE AND GROWING LIST OF RACG CHECK VIP PROCESSES, TIMEOUT
##BUG - Bug 6196746 - Orphaned racgmain processes remain (Doc ID 6196746.8)
##while true; do ps -ef|grep "racgmain check"|wc -l; sleep 2; done;
================================================================================
while true 
do 
r=`ps -ef |grep "racgmain check" |grep -v grep|wc -l`
if [ ${r} -gt -1 ]
then
echo "`date +"%d/%m/%y %H:%M:%S"` - PROCESS = "${r}"  ####### BUG - Many Orphaned Or Hanging (racgmain) Processes Running (Doc ID 732086.1) #######" ##>> /tmp/scr/bug_racgmain_10g_Doc_Id_732086.1.out 
for i in `ps -ef|grep "pmon" |grep -v grep |awk '{print $2 $5}'`
do
x=${i} 
echo ${x}
done
else
    echo "`date +"%d/%m/%y %H:%M:%S"` - PROCESS = "${r}"  ** RACGMAIN CHECK OK **" ##>> /tmp/scr/bug_racgmain_10g_Doc_Id_732086.1.out
fi
sleep 2
done 
##BUG - Many Orphaned Or Hanging (racgmain) Processes Running (Doc ID 732086.1)
##BUG - Bug 8572205 : CHILDCRASH, OS ERROR: 0, OTHER: ABNORMAL TERMINATION OF CHILD
##BUG - Patch 6196746: LNX070704 - HUGE AND GROWING LIST OF RACG CHECK VIP PROCESSES, TIMEOUT
##BUG - Bug 6196746 - Orphaned racgmain processes remain (Doc ID 6196746.8)
##while true; do ps -ef|grep "racgmain check"|wc -l; sleep 2; done;


while true; do ps -ef|grep "racgmain check" |grep -v grep |awk '{print $2,$5}'; sleep 2; done;


for i in `ps -ef|grep "pmon" |grep -v x |awk '{print $2,$5}'`
do
x=${i} 
echo ${x}
done


for i in `ps -ef|grep "pmon" |grep -v x |awk '{print $2}'`
do
x=${i} 
	for y in `ps -ef|grep "pmon" |grep -v x |awk '{print $5}'`
	do
	z=${y}"  "${x} 
	done
	echo ${z}
done



ps -ef|grep "pmon" |grep -v x |awk '{print $2,$5}'