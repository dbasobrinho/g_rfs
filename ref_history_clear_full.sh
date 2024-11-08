passwd##rm -f ~/.bash_history; history -c; exit

##Limpar somente conjunto de linhas e o proprio comando de deletação 
for h in $(seq 930 970); do history -d 930; done; history -d $(history 1 | awk '{print $1}')


## Comando HISTORY com Data e Hora

vim /root/.bashrc
export HISTTIMEFORMAT="%F-%T "