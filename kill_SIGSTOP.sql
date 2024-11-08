
========      SQL> ! kill -s SIGSTOP $(ps -ef | grep $ORACLE_SID |grep ckpt | awk '{print $2}')
========      SQL> ! kill -s SIGCONT $(ps -ef | grep $ORACLE_SID |grep ckpt | awk '{print $2}')
========      ==




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
