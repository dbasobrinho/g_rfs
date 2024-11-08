========      for i in $(ps -ef | grep -v grep | grep LOCAL=NO | grep pback | awk '{print $2}')
========      do
========      kill -9 $i
========      done
========      ==
========      kill -9 $(ps -ef | grep -v grep | grep 'LOCAL=NO' | grep $ORACLE_SID | awk '{print $2}')
========      ==
========      for i in $(ps -ef | grep -v grep | grep 'LOCAL=NO' | grep pback | awk '{print $2}'); do echo "$i" &>/dev/null;done
========      ==


========      SQL> ! kill -s SIGSTOP $(ps -ef | grep $ORACLE_SID |grep ckpt | awk '{print $2}')
========      SQL> ! kill -s SIGCONT $(ps -ef | grep $ORACLE_SID |grep ckpt | awk '{print $2}')
========      ==

======== for h in $(seq 490 503); do history -d 490; done; history -d $(history 1 | awk '{print $1}')



kill -9 $(ps -eo etimes,pid,lstart,etime,args,user --sort -etimes |grep apebsprd | awk '/ALECDC/ {if ($1 > 1140*60) print $0 }' | awk '{print $2}')

##GUINA_ALERT
kill -9 $(ps -eo etimes,pid,lstart,etime,args,user --sort -etimes |grep apebsprd | awk '/ALECDC/ {if ($1 > 1140*60) print $0 }' | awk '{print $2}')
##GUINA_ALERT


ps -eo etimes,pid,lstart,etime,args --sort -etimes | awk '/ALECDC/ {if ($1 > 1320*60) print $0 }' | awk '{print $2}'


ps -eo etimes,pid,lstart,etime,args --sort -etimes | awk '/ALECDC/ {if ($1 > 1140*60) print $0 }' | awk '{print $2}'

48873



#####        #!/bin/bash
#####        bash some_bash_process &
#####        pid=$!
#####        trap 'kill "$pid"' EXIT
#####        
#####        paused=false
#####        while process_still_running "$pid"; do
#####           if free_disc_space_below 100G; then
#####               if ! "$paused"; then
#####                  paused=true
#####                  kill -s SIGSTOP "$pid"
#####               fi
#####           else
#####               if "$paused"; then
#####                  paused=false
#####                  kill -s SIGCONT "$pid"
#####               fi
#####           fi
#####           sleep 1
#####        done
