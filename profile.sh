#!/bin/bash
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi
alias sql='sqlplus / as sysdba'
alias "vim"='vi'
stty erase ^h
alias lu='ls -lrt'
alias "ll"='ls -lartg'
alias pmon='ps -ef |grep pmon'
scr=/manobra/db/scr; export scr
alias go='cd $scr'

PATH=/usr/bin:/etc:/usr/sbin:/usr/ucb:$HOME/bin:/usr/bin/X11:/sbin:/u01/app/oracle/product/11.2.0/db_1/OPatch:.

export PATH

if [ -s "$MAIL" ]           # This is at Shell startup.  In normal
then echo "$MAILMSG"        # operation, the Shell checks
fi                          # periodically.

export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1
export PATH=$PATH:$ORACLE_HOME/bin


# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
#fi

# User specific environment and startup programs

#PATH=$PATH:$HOME/bin
B

#export PATH

fi

# User specific environment and startup programs
clear
echo "  Voce esta logado na Maquina : `tput smso` `uname -n` `tput rmso`"
echo "  Seu usuario                 : `tput smso` `id -u -n ` `tput rmso`"
echo "  Seu ID                      : `tput smso` `id -u` `tput rmso`"
echo "  Versao do `uname`               : `tput smso` `uname -r` `tput rmso`"
echo "  Maquina Modelo              : `tput smso` `uname -m` `tput rmso`"
echo " "
echo "########################################################## "
echo "#                                                        # "
echo "########################################################## "
echo "################## AMBINTE NAO PRODUTIVO ################# "
echo "########################################################## "
echo "#                                                        # "
echo "########### COORACPRD02 - AMBIENTE PRODUCAO   ############ "
echo "#                                                        # "
echo "#               #    #   ####   ######                   # "
echo "#               #    #  #       #                        # "
echo "#               #    #   ####   #####                    # "
echo "#               #    #       #  #                        # "
echo "#               #    #  #    #  #                        # "
echo "#                ####    ####   #                        # "
echo "#                                                        # "
echo "############ RDBMS ###############                       # "
echo "#                                                        # "
echo "#         1) JAKE (COPIA PNPE)                           # "
echo "#         2) LUKE                                        # "
echo "#                                                        # "
echo "###### Grid Infrastructure #######                       # "
echo "#                                                        # "
echo "#       Acessar com usuario GRID                         # "
echo "#                                                        # "
echo "########### Digite MENU para setar as variaves ########### "
echo " "
echo " "
echo " "
echo " "

menu ()
{
clear
echo "  Voce esta logado na Maquina : `tput smso` `uname -n` `tput rmso`"
echo "  Seu usuario                 : `tput smso` `id -u -n ` `tput rmso`"
echo "  Seu ID                      : `tput smso` `id -u` `tput rmso`"
echo "  Versao do `uname`               : `tput smso` `uname -r` `tput rmso`"
echo "  Maquina Modelo              : `tput smso` `uname -m` `tput rmso`"
echo " "
echo "########################################################## "
echo "#                                                        # "
echo "########################################################## "
echo "################## AMBINTE NAO PRODUTIVO ################# "
echo "########################################################## "
echo "#                                                        # "
echo "########### COORACPRD02 - AMBIENTE PRODUCAO   ############ "
echo "#                                                        # "
echo "#               #    #   ####   ######                   # "
echo "#               #    #  #       #                        # "
echo "#               #    #   ####   #####                    # "
echo "#               #    #       #  #                        # "
echo "#               #    #  #    #  #                        # "
echo "#                ####    ####   #                        # "
echo "#                                                        # "
echo "############ RDBMS ###############                       # "
echo "#                                                        # "
echo "#         1) JAKE (COPIA PNPE)                           # "
echo "#         2) LUKE                                        # "
echo "#                                                        # "
echo "###### Grid Infrastructure #######                       # "
echo "#                                                        # "
echo "#       Acessar com usuario GRID                         # "
echo "#                                                        # "
echo "########### Digite MENU para setar as variaves ########### "
echo " "
echo " "
echo " "
echo " "

read opt


case $opt in

  1)

     PATH=$PATH:$HOME/bin

     export PATH

#Oracle
  # Oracle
  ORACLE_BASE=/u01/app/oracle; export ORACLE_BASE
  ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1; export ORACLE_HOME
  ORACLE_TERM=xterm; export ORACLE_TERM
  PATH=$ORACLE_HOME/bin:$PATH; export PATH
  ORACLE_OWNER=oracle; export ORACLE_OWNER
  ORACLE_SID=jake; export ORACLE_SID
  NLS_LANG=AMERICAN_AMERICA.WE8MSWIN1252; export NLS_LANG
  TMP=/tmp; export TMP
  TMPDIR=$TMP; export TMPDIR
  echo "INSTANCIA ESCOLHIDA: JAKE "
  alias alert="tail -f400 /u01/app/oracle/diag/rdbms/jake/jake/trace/alert_jake.log"
  alias ssql='sqlplus -s / as sysdba'
  alias sql='sqlplus / as sysdba'
  alias tns="cd $ORACLE_HOME/network/admin"
  echo "sql='sqlplus / as sysdba'"
  echo "alert='alert_jake.log'"
  echo "tns="cd $ORACLE_HOME/network/admin""
    ;;

  2)

     PATH=$PATH:$HOME/bin

     export PATH

#Oracle
  # Oracle
  ORACLE_BASE=/u01/app/oracle; export ORACLE_BASE
  ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1; export ORACLE_HOME
  ORACLE_TERM=xterm; export ORACLE_TERM
  PATH=$ORACLE_HOME/bin:$PATH; export PATH
  ORACLE_OWNER=oracle; export ORACLE_OWNER
  ORACLE_SID=luke; export ORACLE_SID
  NLS_LANG=AMERICAN_AMERICA.WE8MSWIN1252; export NLS_LANG
  TMP=/tmp; export TMP
  TMPDIR=$TMP; export TMPDIR
  echo "INSTANCIA ESCOLHIDA: LUKE "
  alias alert='tail -f400 /u01/app/oracle/diag/rdbms/luke/luke/trace/alert_luke.log'
  alias ssql='sqlplus -s / as sysdba'
  alias sql='sqlplus / as sysdba'
  alias tns="cd $ORACLE_HOME/network/admin"
  echo "sql='sqlplus / as sysdba'"
  echo "alert='alert_jake.log'"
  echo "tns="cd $ORACLE_HOME/network/admin""
    ;;

 *)
    echo "ATENCAO: NENHUM VALOR DEFINIDO PARA ORACLE_SID."
    ;;
esac

}

export NLS_LANG="BRAZILIAN PORTUGUESE_BRAZIL.WE8MSWIN1252"
unset ORACLE_SGA_PGSZ
