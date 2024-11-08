#!/bin/bash
# Author      : Roberto Fernandes Sobrinho
# Date        : 10/10/2019
#########################################################################
echo 'ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10'
ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10