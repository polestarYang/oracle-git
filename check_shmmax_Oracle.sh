#######################################################
# $Name: check_shmmax_Oracle.sh
# $Version: v1.0
# $Author: ethan_yang
# $Create Date: 2020-07-24
# $Description:checking os/oracle  memory allocation  for oracle.
#######################################################

#!/bin/bash
##

## shmmax、shmall配置检查
##

memory=`awk '($1 == "MemTotal:"){print $2}' /proc/meminfo`
m1=$[$[$[memory*1024]*9]/10]
shmmax=`awk '($1 == "kernel.shmmax"){print $3}' /etc/sysctl.conf`
shmall=`awk '($1 == "kernel.shmall"){print $3}' /etc/sysctl.conf`


echo -e  "*****os memory `awk -v x=$memory -v y=1000 'BEGIN{printf "%.1f\n",x/y/y}'`  G *****\n"

##
## 判断shmmax、shmall大小是否过小
##

if [ ${shmmax} -lt ${m1} ];then
    echo -e "*****shmmax value is $shmmax,suggestion value  ${m1} *****\n "
else
    echo -e "*****shmmax value configure is right.*****\n"
fi

if [ ${shmall}  -lt $[${m1}/4096 ] ];then
    echo  -e "*****shmall value is  $shmall, suggestion value  $[${m1}/4096 ] *****\n"
else
    echo -e  "*****shmall value configure is right.*****\n"
fi


v1=$[$[$[$memory*1024]*64]/100]
v2=$[$[$[$memory*1024]*8]/10]
##
## memory_target 配置检查 
##


memory_target=`sqlplus -s / as sysdba  <<EOF
set heading off
select value  from v\\\$parameter where name='memory_target';
exit
EOF`

if [ ${memory_target} -gt  0  ];then

    if [  ${memory_target} -lt $v2  ];then
    
        echo -e  "***** memory_target value is  $memory_target,suggestion value $v2 !!!  *****\n"
    else
        echo -e  "***** memory_target value configure is right.*****\n"
    fi
   
fi

##
## sga_target 配置检查
##

if [ ${memory_target} -eq 0  ];then

  sga_target=`sqlplus -s / as sysdba  <<EOF
  set heading off
  select value  from v\\\$parameter where name='sga_target';
  exit
EOF`
  if [ ${sga_target} -lt $v1 ] ;then
#   echo  -e "***** sga_target value is ${sga_target}, suggestion value  $v1*****\n"
    echo  -e "***** sga_target value is $[$[$[$sga_target/1024]/1024]/1024] GB, suggestion value $[$[$[$v1/1024]/1024]/1024] GB *****\n"
  else
    echo  -e "***** sga_target value configure is right*****\n"
  fi

fi


v1=$[$[$[$memory*1024]*16]/100]
if [ ${memory_target} -eq 0  ];then

  pga_aggregate_target=`sqlplus -s / as sysdba  <<EOF
  set heading off
  select value  from v\\\$parameter where name='pga_aggregate_target';
  exit
EOF`
  if [ ${pga_aggregate_target} -lt $v1 ] ;then
    echo  -e "***** pga_aggregate_target  value is ${pga_aggregate_target}, suggestion value  $v1*****\n"
  else
    echo  -e "***** sga_target value configure is right*****\n"
  fi

fi
