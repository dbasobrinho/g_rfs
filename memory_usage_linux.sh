#!/bin/bash
# Author      : Roberto Fernandes Sobrinho
# Date        : 10/10/2017
#############################################################################
echo "======================================================================="
free -g
echo "======================================================================="
echo "Free Memory"; free -m | grep -i mem | awk '{print ($4*100/$2)" " "%"}'
echo "Busy Memory"; free -m | grep -i mem | awk '{print ($3*100/$2)" " "%"}'
echo "Memory usage";free -m | grep Mem    | awk '{print ($3*100/$2)" " "%"}' ; 
echo "Swap   usage";free -m | grep Swap   | awk '{print ($3*100/$2)" " "%"}' ; 
echo "======================================================================="
date ; uname -a
echo "======================================================================="