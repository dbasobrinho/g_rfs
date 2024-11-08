--
set pages 1000
set lines 1000
column command     format a100 
SELECT 'ALTER SYSTEM ARCHIVE LOG CURRENT ;' COMMAND FROM DUAL UNION ALL
SELECT 'ALTER SYSTEM CHECKPOINT          ;' COMMAND FROM DUAL UNION ALL
SELECT 'ALTER SYSTEM ARCHIVE LOG CURRENT ;' COMMAND FROM DUAL UNION ALL
SELECT 'ALTER SYSTEM CHECKPOINT          ;' COMMAND FROM DUAL UNION ALL  
SELECT 'ALTER SYSTEM FLUSH SHARED_POOL   ;' COMMAND FROM DUAL UNION ALL
SELECT 'ALTER SYSTEM FLUSH BUFFER_CACHE  ;' COMMAND FROM DUAL UNION ALL
SELECT 'ALTER SYSTEM FLUSH GLOBAL CONTEXT;' COMMAND FROM DUAL UNION ALL
SELECT 'ALTER SYSTEM CHECKPOINT          ;' COMMAND FROM DUAL UNION ALL
SELECT 'ALTER SYSTEM ARCHIVE LOG CURRENT ;' COMMAND FROM DUAL UNION ALL
SELECT 'ALTER SYSTEM CHECKPOINT          ;' COMMAND FROM DUAL 
/

SELECT '!kill -s SIGSTOP <pid> ;' COMMAND FROM DUAL UNION ALL
SELECT '!kill -s SIGCONT <pid> ;' COMMAND FROM DUAL 
/



----#!/bin/bash
----bash some_bash_process &
----pid=$!
----trap 'kill "$pid"' EXIT
----
----paused=false
----while process_still_running "$pid"; do
----   if free_disc_space_below 100G; then
----       if ! "$paused"; then
----          paused=true
----          kill -s SIGSTOP "$pid"
----       fi
----   else
----       if "$paused"; then
----          paused=false
----          kill -s SIGCONT "$pid"
----       fi
----   fi
----   sleep 1
----done