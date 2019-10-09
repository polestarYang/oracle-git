#######################################################
# $Name: linux_oracle_ha.sh
# $Version: v1.0
# $Author: ethan_yang
# $Create Date: 2019-10-09
# $Description:the script about ha of oracle in linux enviroment.
#######################################################

#!/bin/sh 
lsnr_port=1521
dbuser=oracle
sid_name=instance_name

# 
# Start oracle 
#
start()
{
        lsnrnum=`netstat -ltnp 2>/dev/null | grep tnslsnr | grep $lsnr_port | wc -l`
        if [ $lsnrnum -eq 0 ]
        then
                echo "Starting listener..."
                su - $dbuser -c "lsnrctl start"
        else
                echo "The listener is already running."
        fi

 
        echo "Starting ORACLE_SID: $sid_name..."
        su - $dbuser -c "
                        export ORACLE_SID=$sid_name;sqlplus /nolog << EOF
                        connect / as sysdba
                        startup
                        quit
                        EOF
                        "
  
        if [ $? -ne 0 ]
        then
                echo "Error: starting ORACLE_SID: $sid_name..."
                return 1
        fi
}

#
# Stop oracle
#
stop()
{
        echo "Stoping ORACLE_SID: $sid_name..."
        su - $dbuser -c "
                        export ORACLE_SID=$sid_name;sqlplus /nolog << EOF
                        connect / as sysdba 
                        shutdown immediate 
                        quit 
                        EOF
                        "
  
        if [ $? -ne 0 ]
        then
                chk_sid=$(ps axw| \grep $sid_name | 
                \grep -E "(ora_pmon_$sid_name|\ora_lgwr_$sid_name|\ora_dbw[0-9]_$sid_name|\ora_ckpt_$sid_name|\ora_smon_$sid_name|\ora_reco_$sid_name)"|
                \grep -v  grep |wc -l)

                if [ $chk_sid -eq 0 ]
                then
                        return 0
                else
                        echo "Error: stoping ORACLE_SID: $sid_name..."
                        return 1
                fi
        fi
 
        echo "Stopping Oracle listener..."
        su - $dbuser -c "lsnrctl stop"
        exit 0
}

#
# Status oracle
#
status()
{
        chk_lsnr=`netstat -ltnp 2>/dev/null | grep tnslsnr | grep $lsnr_port | wc -l`
        if [ $chk_lsnr -eq 0 ]
        then
                echo -e "Oracle listener is not running!"
                return 1
        else
                echo -e "Oracle listener is  running..."
        fi

        PROCESSESS=6
        chk_sid=$(ps axw| \grep $sid_name | 
        \grep -E "(ora_pmon_$sid_name|\ora_lgwr_$sid_name|\ora_dbw[0-9]_$sid_name|\ora_ckpt_$sid_name|\ora_smon_$sid_name|\ora_reco_$sid_name)"|
        \grep -v  grep |wc -l)

        if [ $chk_sid -lt $PROCESSESS ]
        then
                echo "Oracle SID chk_sid=$chk_sid,processess=$PROCESSESS : $sid_name is checked by ERROR!"
                return 1
        else
                echo "$sid_name is running..."
                return 0
        fi
}

case "$1" in
        start)
                start
        ;;
        stop)
                stop
        ;;
        status)
                status
        ;;
        *)
                echo "Usage : `basename $0` {start | stop | status}"
        ;;
esac
