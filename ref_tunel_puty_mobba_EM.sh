ssh \
-L 7802:localhost:7802 \
-L 15201:localhost:1521 \
-L 15202:lbkooraspprd01:1521 \
tvt02485@172.26.232.44

https://localhost:7802/em  
sysman
oracle123

sshpass -p SEEE#13 ssh -L 7802:localhost:7802 -L 15201:localhost:1521 -L 15202:lbkooraspprd01:1521 -t -o StrictHostKeyChecking=no "roberto.fernandes@tivit.com%tvt02485%200.185.21.4%SEEE#13"@200.185.88.55 "sshpass -p SEEE#13 ssh -t -o StrictHostKeyChecking=no 172.26.232.44"


tvt02485;roberto.fernandes;SEEE#13;RRBrowESJAIRAnnaLIZ#22;LC5577026;TimeUnix@2019;roberto.sobrinho;Tivit.123;

TERM=`export TERM=vt100`
PASS=`cut -f3 -d";" /home/mobaxterm/sec`
TVT=`cut -f1 -d";" /home/mobaxterm/sec`
LOGIN_REDE=`cut -f2 -d";" /home/mobaxterm/sec`
sshpass -p ${PASS} ssh
-L 7802:localhost:7802 \
-L 15201:localhost:1521 \
-L 15202:lbkooraspprd01:1521 \
-t -o StrictHostKeyChecking=no "${LOGIN_REDE}@tivit.com%${TVT}%200.185.21.4%${PASS}"@200.185.88.55 "sshpass -p ${PASS} ssh -t -o StrictHostKeyChecking=no 172.26.232.44"




