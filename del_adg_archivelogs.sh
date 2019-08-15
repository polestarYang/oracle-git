#######################################################
# $Name: del_adg_archivelogs.sh
# $Version: v1.0
# $Author: ethan_yang
# $Create Date: 2019-08-15
# $Description: delete the archivelogs applied in standby_db about 12 hours before the current time point 
#######################################################

[oracle@bkdb ~]$ crontab -l
0 0,6,12,18 * * * /home/oracle/del_arch/del.sh > /home/oracle/del_arch/del_arch.log 2>&1
[oracle@bkdb ~]$ 
[oracle@bkdb ~]$ 
[oracle@bkdb ~]$ 
[oracle@bkdb ~]$ more /home/oracle/del_arch/del_adg_archivelogs.sh
#!/bin/bash

export ORACLE_BASE=/oracle/oracle/app/oracle
export ORACLE_HOME=/oracle/oracle/app/oracle/product/12.2/db_1
export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch:$PATH:$HOME/bin
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
export ORACLE_SID=instance_name

rman target / <<EOF >>/home/oracle/del_arch/del_arch.log

########## delete the archivelogs applied in standby_db about 12 hours before the current time point###########
delete noprompt archivelog all completed before 'sysdate - 12/24';
#delete noprompt archivelog all; 
exit
EOF
[oracle@bkdb ~]$ 
