#!/bin/bash 
##TOP1 Ver consumo de Memoria por processo
echo "Consumo de Memória : " && free -m | grep -i mem | awk '{print ($3*100/$2)" " "%"}' && echo "Processo que estão consumindo a memória: $(ps -eo vsz,args |awk '{ x+=$1; print $1, $2} END {print x,"total "}' | sort -nr | head -10)" && echo "Nome do Servidor: $(uname -n)" && echo "Uptime do Servidor: $(uptime)" && echo "Data Atual: $(date)"

##########################################
##TOP1 Ver consumo de Memoria programa
#!/bin/bash
ps axo rss,comm,pid \
| awk '{ proc_list[$2]++; proc_list[$2 "," 1] += $1; } \
END { for (proc in proc_list) { printf("%d\t%s\n", \
proc_list[proc "," 1],proc); }}' \
| sort -n \
| tail -n 10 \
| sort -rn \
| awk '{$1/=1024;printf "%.0fMB\t",$1}{print $2}'

##########################################
##TOP1 Lista Top 10 CPU Consuming Processes
#!/bin/bash
ps -eo pid,comm,%cpu | sort -rk 3 | head






Outras modernidades 
sysctl -w vm.swappiness=5

vm.swappiness=4
vm.swappiness = 0


ps -eo pmem,pcpu,rss,vsize,args | sort -k 1 -n -r | sort -nr | head -10