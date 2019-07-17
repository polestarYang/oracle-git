#######################################################
# $Name: get_envi_for_oracle.sh
# $Version: v1.0
# $Author: ethan_yang
# $Create Date: 2019-07-17
# $Description: ORACLE get the envs oracle server
#######################################################

#!/bin/ksh


DATE=`date +%F\:%T`

echo "" > env_oracle.log
echo "The Current Time is : $DATE" >> env_oracle.log
echo "" >> env_oracle.log
echo "" >> env_oracle.log

ENV=`whereis env |awk '{print $2}'` 
echo "####################################### get env information ###################################################" >> env_oracle.log
$ENV  >> env_oracle.log
echo "####################################### get ora of env information ############################################" >> env_oracle.log
$ENV |grep ORA >> env_oracle.log
echo "####################################### get hosts information #################################################" >> env_oracle.log
cat /etc/hosts >> env_oracle.log
echo "####################################### get ulimit information ################################################" >> env_oracle.log
ulimit -a >> env_oracle.log
echo "####################################### get os information ####################################################" >> env_oracle.log
case `uname` in  
AIX)
    uname -a  >> env_oracle.log
    oslevel  >> env_oracle.log
    df -g  >> env_oracle.log
    #CPU_USED_PERCENT=`vmstat 1 2| tail -n 1 | awk '{print 100-$16}'`
    prtconf >> env_oracle.log
    vmstat 1 6 >>env_oracle.log
;;
HP-UX)
    uname -a >> env_oracle.log
    bdf >> env_oracle.log
    machinfo >> env_oracle.log
    #CPU_USED_PERCENT=`vmstat 1 2| tail -n 1 | awk '{print 100-$18}'`
    top -s 3 -d 2 >> env_oracle.log
    vmstat 1 6 >>env_oracle.log
;;
SunOS)
    uname -a  >> env_oracle.log
    df -h  >> env_oracle.log
    prtdiag -v >> env_oracle.log
    uname -X >> env_oracle.log
    #CPU_USED_PERCENT=`vmstat 1 2| tail -1 | awk '{print 100-$22}'`
    vmstat 1 6 >>env_oracle.log

;;
Linux)
    uname -a >> env_oracle.log
    echo "" >> env_oracle.log	
    df -h >> env_oracle.log
    file /sbin/init >> env_oracle.log
    cat /proc/cpuinfo >> env_oracle.log
    echo "" >> env_oracle.log
    cat /etc/redhat-release  >> env_oracle.log
    FREE=`cat /proc/meminfo | grep MemFree | awk '{print$2}'`
    TOTAL=`cat /proc/meminfo | grep MemTotal | awk '{print$2}'`
    BUFFER=`cat /proc/meminfo | grep Buffers | awk '{print$2}'`
    CACHED=`cat /proc/meminfo | grep Cached | grep -v SwapCached| awk '{print$2}'`
    TMP1=`expr $TOTAL - $FREE - $BUFFER - $CACHED`
    TMP2=`expr $TMP1 \* 100`
    MEM_USED_PERCENT=`expr $TMP2 / $TOTAL`
    CPU_USED_PERCENT=`vmstat 1 2| tail -n 1 | awk '{print 100-$15}'`
    vmstat 1 6 >> env_oracle.log
    echo "" >> env_oracle.log
    free >> env_oracle.log
    echo "" >> env_oracle.log
    echo "CPU_USED_PERCENT|MEM_USED_PERCENT : ${CPU_USED_PERCENT}|${MEM_USED_PERCENT}" >> env_oracle.log
;;
esac    

echo "####################################### get oracle information ################################################" >> env_oracle.log

sqlplus "/as sysdba" >> env_oracle.log <<EOF



alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
set echo off
set linesize 260;
set long 90000;
Set numformat 99999999999999999999.09
col member for a60 
col file_name for a60 
col user_name for a20 
col owner for a15 
col grantor for a15 
col table_name for a40 
col user_name for a30 
col object_name for a50
col PATH for a50 
col name for a30 
col member for a50 
col SCHEDULE_OWNER for a20 
--set heading on
set heading off 
set pagesize 200
col tbsname for a20  
col get_time for a30 
col name for a60
col SEGMENT_NAME for a30
col member for a60
col file_name for a60
col user_name for a20
col owner for a15
col grantor for a15
set line 150

--spool get_envi_sql.log
set heading off 
select '--------------------------------------------get parameter-------------------------------------------' from dual;
set heading on;

show parameter;

select name,value,display_value,isdefault,ISSES_MODIFIABLE,ISSYS_MODIFIABLE,ISINSTANCE_MODIFIABLE
,ISMODIFIED,ISDEPRECATED
from v$parameter
where ISDEPRECATED='TRUE'
and ISDEFAULT<>'TRUE';

set heading off 
select '--------------------------------------------get instance status--------------------------------------------' from dual;
set heading on;
--select instance_name,status from gv\$instance;
--Select version from v\$instance;
Select * from gv\$instance;

set heading off 
select '--------------------------------------------get thread status--------------------------------------------' from dual;
set heading on;

select * from gv\$thread;

set heading off
select '--------------------------------------------get database status--------------------------------------------' from dual;
set heading on;

archive log list;


SELECT log_mode,force_logging, SUPPLEMENTAL_LOG_DATA_MIN LOG_MIN, SUPPLEMENTAL_LOG_DATA_PK  LPK, SUPPLEMENTAL_LOG_DATA_UI  LUK, SUPPLEMENTAL_LOG_DATA_FK  LFK, SUPPLEMENTAL_LOG_DATA_ALL LALL FROM V\$DATABASE; 

set heading off
select '--------------------------------------------get log information--------------------------------------------' from dual;
set heading on;

Select * from v\$log;

set heading off
select '--------------------------------------------get logfile information--------------------------------------------' from dual;
set heading on;

Select * from v\$logfile;

set heading off
select '--------------------------------------------get log_history switch  information--------------------------------------------' from dual;
set heading on;

column	day	format a15	heading 'Day'
column	d_0	format a2	heading '00'
column	d_1	format a2	heading '01'
column	d_2	format a2	heading '02'
column	d_3	format a2	heading '03'
column	d_4	format a2	heading '04'
column	d_5	format a2	heading '05'
column	d_6	format a2	heading '06'
column	d_7	format a2	heading '07'
column	d_8	format a2	heading '08'
column	d_9	format a2	heading '09'
column	d_10	format a2	heading '10'
column	d_11	format a2	heading '11'
column	d_12	format a2	heading '12'
column	d_13	format a2	heading '13'
column	d_14	format a2	heading '14'
column	d_15	format a2	heading '15'
column	d_16	format a2	heading '16'
column	d_17	format a2	heading '17'
column	d_18	format a2	heading '18'
column	d_19	format a2	heading '19'
column	d_20	format a2	heading '20'
column	d_21	format a2	heading '21'
column	d_22	format a2	heading '22'
column	d_23	format a2	heading '23'
select * from 
(select   
substr(to_char(FIRST_TIME,'YYYY/MM/DD,DY'),1,15) day,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'00',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'00',1,0))) d_0,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'01',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'01',1,0))) d_1,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'02',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'02',1,0))) d_2,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'03',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'03',1,0))) d_3,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'04',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'04',1,0))) d_4,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'05',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'05',1,0))) d_5,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'06',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'06',1,0))) d_6,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'07',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'07',1,0))) d_7,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'08',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'08',1,0))) d_8,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'09',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'09',1,0))) d_9,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'10',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'10',1,0))) d_10,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'11',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'11',1,0))) d_11,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'12',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'12',1,0))) d_12,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'13',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'13',1,0))) d_13,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'14',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'14',1,0))) d_14,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'15',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'15',1,0))) d_15,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'16',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'16',1,0))) d_16,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'17',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'17',1,0))) d_17,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'18',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'18',1,0))) d_18,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'19',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'19',1,0))) d_19,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'20',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'20',1,0))) d_20,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'21',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'21',1,0))) d_21,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'22',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'22',1,0))) d_22,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'23',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'23',1,0))) d_23
from    
v\$log_history
group by
substr(to_char(FIRST_TIME,'YYYY/MM/DD,DY'),1,15)
order by
substr(to_char(FIRST_TIME,'YYYY/MM/DD,DY'),1,15) ) a 
union 
select * from 
(select 'Day            ','00','01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23' from dual) b;

Select to_char(first_time,'YYYY-MM-DD'),count(sequence#) from v\$log_history
group by to_char(first_time,'YYYY-MM-DD')  order by 2;

Select to_char(first_time,'YYYY-MM-DD'),count(sequence#) from v\$log_history
group by to_char(first_time,'YYYY-MM-DD')  order by 1;

Select thread#,sequence#,to_char(first_time,'YYYY-MM-DD hh24:mi:dd') from v\$log_history;



set heading off
select '--------------------------------------------get Backup information --------------------------------------------' from dual;
set heading on;

col "Type LV" for a10
SELECT A.RECID "BACKUP SET",
         A.SET_STAMP,
         DECODE (B.INCREMENTAL_LEVEL,
                 '', DECODE (BACKUP_TYPE, 'L', 'Archivelog', 'Full'),
                 1, 'Incr-1',
                 0, 'Incr-0',
                 B.INCREMENTAL_LEVEL)
            "Type LV",
         B.CONTROLFILE_INCLUDED "CTL",
         DECODE (A.STATUS,
                 'A', 'AVAILABLE',
                 'D', 'DELETED',
                 'X', 'EXPIRED',
                 'ERROR')
            "STATUS",
         A.DEVICE_TYPE "Device Type",
         A.START_TIME "Start Time",
         A.ELAPSED_SECONDS "Elapsed Seconds",
 		 A.BYTES/1024/1024 SIZE_MB,
         A.TAG "Tag"
    FROM GV\$BACKUP_PIECE A, GV\$BACKUP_SET B
   WHERE A.SET_STAMP = B.SET_STAMP AND A.DELETED = 'NO'
ORDER BY 1 ;


set heading off
select '--------------------------------------------get nls information --------------------------------------------' from dual;
set heading on;

select * from v\$nls_parameters where parameter in ('NLS_LANGUAGE','NLS_DATE_LANGUAGE','NLS_CHARACTERSET');

set heading off
select '--------------------------------------------get object_type information --------------------------------------------' from dual;
set heading on;

select distinct object_type from dba_objects where owner not like('SYS%') and owner not in ('XDB','OUTLN','DBSNMP','DIP','SCOTT','MGMT_VIEW','ANONYMOUS','ORDPLUGINS','SI_INFORMTN_SCHEMA','APEX_030200','CTXSYS','EXFSYS','MDSYS','WMSYS');

select distinct owner,object_type from dba_objects where owner not like('SYS%') and owner not in ('XDB','OUTLN','DBSNMP','DIP','SCOTT','MGMT_VIEW','ANONYMOUS','ORDPLUGINS','SI_INFORMTN_SCHEMA','APEX_030200','CTXSYS','EXFSYS','MDSYS','WMSYS') order by 1,2;

set heading off
select '--------------------------------------------get data_type information --------------------------------------------' from dual;
set heading on;

select distinct data_type from dba_tab_columns where owner not like 'SYS%' and owner not in ('XDB','OUTLN','DBSNMP','DIP','SCOTT','MGMT_VIEW','ANONYMOUS','ORDPLUGINS','SI_INFORMTN_SCHEMA','APEX_030200','CTXSYS','EXFSYS','MDSYS','WMSYS') order by 1;

select distinct owner,data_type from dba_tab_columns where owner not like 'SYS%' and owner not in ('XDB','OUTLN','DBSNMP','DIP','SCOTT','MGMT_VIEW','ANONYMOUS','ORDPLUGINS','SI_INFORMTN_SCHEMA','APEX_030200','CTXSYS','EXFSYS','MDSYS','WMSYS') order by 1,2;


set heading off
select '--------------------------------------------get iot information --------------------------------------------' from dual;
set heading on;


Select owner,table_name ,iot_type from dba_tables where iot_type like '%IOT%' and owner not like 'SYS%' and owner not in ('XDB','OUTLN','DBSNMP','DIP','SCOTT','MGMT_VIEW','ANONYMOUS','ORDPLUGINS','SI_INFORMTN_SCHEMA','APEX_030200','CTXSYS','EXFSYS','MDSYS','WMSYS');

set heading off
select '--------------------------------------------get compress information --------------------------------------------' from dual;
set heading on;

select owner,table_name,COMPRESSION from dba_tables where COMPRESSION='ENABLED';
select distinct table_owner,table_name as "P_TABLE_NAME" from dba_tab_partitions where COMPRESSION='ENABLED' order by 1,2;

set heading off
select '--------------------------------------------get lob information --------------------------------------------' from dual;
set heading on;

select * from (
select a.owner,b.table_name,sum(a.bytes/1024/1024/1024) 
from dba_segments a,dba_lobs b 
where a.segment_name=b.segment_name and a.owner not like 'SYS%' and a.owner not in ('XDB','OUTLN','DBSNMP','DIP','SCOTT','MGMT_VIEW','ANONYMOUS','ORDPLUGINS','SI_INFORMTN_SCHEMA','APEX_030200','CTXSYS','EXFSYS','MDSYS','WMSYS')
group by a.owner,b.table_name order by 3 desc )
where rownum<=501 order by 3;


set heading off
select '--------------------------------------------get max number of partition information --------------------------------------------' from dual;
set heading on;

select * from (select table_owner,table_name,count(partition_name)
from dba_tab_partitions
where table_owner  not like 'SYS%' and table_owner not in ('XDB','OUTLN','DBSNMP','DIP','SCOTT','MGMT_VIEW','ANONYMOUS','ORDPLUGINS','SI_INFORMTN_SCHEMA','APEX_030200','CTXSYS','EXFSYS','MDSYS','WMSYS')
group by table_owner,table_name
order by 3 desc ) where rownum<=50;

set heading off
select '--------------------------------------------get db data size information --------------------------------------------' from dual;
set heading on;

Select sum(bytes)/1024/1024/1024 from dba_data_files;

set heading off
select '--------------------------------------------get db segments size information --------------------------------------------' from dual;
set heading on;

Select sum(bytes)/1024/1024/1024 from dba_segments;

set heading off
select '--------------------------------------------get tablespace information --------------------------------------------' from dual;
set heading on;

SET PAGESIZE 400
SET LINES 300
COL D.TABLESPACE_NAME FORMAT A15
COL D.TOT_GROOTTE_MB FORMAT A10
COL TS-PER FORMAT A15
SELECT UPPER(D.TABLESPACE_NAME) "TS-NAME",
       D.TOT_GROOTTE_MB "TS-BYTES(M)",
       D.TOT_GROOTTE_MB - NVL(F.TOTAL_BYTES,0) "TS-USED (M)",
       NVL(F.TOTAL_BYTES,0) "TS-FREE(M)",
       TO_CHAR(ROUND((D.TOT_GROOTTE_MB - NVL(F.TOTAL_BYTES,0)) / D.TOT_GROOTTE_MB * 100,
                     2),
               '990.99') "TS-PER",to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') "Get_time"
         FROM (SELECT TABLESPACE_NAME,
               ROUND(SUM(BYTES) / (1024 * 1024), 2) TOTAL_BYTES
          FROM SYS.DBA_FREE_SPACE
         GROUP BY TABLESPACE_NAME) F RIGHT JOIN 
       (SELECT DD.TABLESPACE_NAME,
               ROUND(SUM(DD.BYTES) / (1024 * 1024), 2) TOT_GROOTTE_MB
          FROM SYS.DBA_DATA_FILES DD
         GROUP BY DD.TABLESPACE_NAME) D
ON D.TABLESPACE_NAME = F.TABLESPACE_NAME
ORDER BY 2 DESC;

set heading off
select '--------------------------------------------get datafile information --------------------------------------------' from dual;
set heading on;

select tablespace_name,file_name,bytes/1024/1024/1024 GB,status, AUTOEXTENSIBLE from dba_data_files order by 1,2;

set heading off;
select '--------------------------------------------get tempfile--------------------------------------------' from dual;
set heading on;
select file_name,tablespace_name,bytes,blocks from dba_temp_files order by file_name;

SELECT a.tablespace_name, a.BYTES total, a.bytes - nvl(b.bytes, 0) free
  FROM (SELECT   tablespace_name, SUM (bytes) bytes FROM dba_temp_files GROUP BY tablespace_name) a,
       (SELECT   tablespace_name, SUM (bytes_cached) bytes FROM v\$temp_extent_pool GROUP BY tablespace_name) b
WHERE a.tablespace_name = b.tablespace_name(+);

set heading off
select '--------------------------------------------get all table size information --------------------------------------------' from dual;
set heading on;

Select sum(bytes)/1024/1024/1024 
from dba_segments
where segment_type like  ('TABLE%') and owner not in ('XDB','OUTLN','DBSNMP','DIP','SCOTT','MGMT_VIEW','ANONYMOUS','ORDPLUGINS','SI_INFORMTN_SCHEMA','APEX_030200','CTXSYS','EXFSYS','MDSYS','WMSYS')
;


select dt.owner,dt.table_name,dt.num_rows,dt.avg_row_len,dt.sample_size,dt.last_analyzed,dt.NUM_ROWS*AVG_ROW_LEN/1024/1024 ACT_MB,ds.seg_MB,ds.extents, ds.seg_MB-dt.NUM_ROWS*AVG_ROW_LEN/1024/1024 save_mb
from dba_tables dt right join 
(select owner,segment_name,sum(bytes)/1024/1024 seg_MB,sum(extents) extents from  dba_segments where owner not in ('SYS','SYSTEM','SYSMAN') group by owner,segment_name) ds 
on dt.owner=ds.owner and dt.table_name=ds.segment_name
where dt.owner is not null and ds.seg_MB-dt.NUM_ROWS*AVG_ROW_LEN/1024/1024  > 100
order by 10 desc;

set heading off
select '--------------------------------------------get owner,segments information --------------------------------------------' from dual;
set heading on;

Select owner, sum(bytes)/1024/1024/1024 
from dba_segments 
where segment_type like  ('TABLE%') 
group by owner 
order by 2;

set heading off
select '--------------------------------------------get number of columns  information --------------------------------------------' from dual;
set heading on;

select table_name,count(column_name) from dba_tab_columns 
where owner not like 'SYS%' and owner not in ('XDB','OUTLN','DBSNMP','DIP','SCOTT','MGMT_VIEW','ANONYMOUS','ORDPLUGINS','SI_INFORMTN_SCHEMA','APEX_030200','CTXSYS','EXFSYS','MDSYS','WMSYS') group by table_name having count(column_name) > 255 order by 2 ;


set heading off
select '--------------------------------------------get table size information --------------------------------------------' from dual;
set heading on;

select owner,sum(bytes/1024/1024/1024) from dba_segments 
where owner not in ('SYS','SYSTEM')  and owner not in ('XDB','OUTLN','DBSNMP','DIP','SCOTT','MGMT_VIEW','ANONYMOUS','ORDPLUGINS','SI_INFORMTN_SCHEMA','APEX_030200','CTXSYS','EXFSYS','MDSYS','WMSYS')
and  segment_type in ('TABLE','TABLE PARTITION','TABLE SUBPARTITION')
group by  owner  order by 2;

select owner,segment_name,sum(bytes/1024/1024/1024) from dba_segments 
where owner not in ('SYS','SYSTEM')  and owner not in ('XDB','OUTLN','DBSNMP','DIP','SCOTT','MGMT_VIEW','ANONYMOUS','ORDPLUGINS','SI_INFORMTN_SCHEMA','APEX_030200','CTXSYS','EXFSYS','MDSYS','WMSYS')
and  segment_type in ('TABLE','TABLE PARTITION','TABLE SUBPARTITION')
group by  owner,segment_name  order by 3;


set heading off;
select '--------------------------------------------get users--------------------------------------------' from dual;
set heading on;
set line 140
col username for a15
col account_status for a15
col TEMPORARY_TABLESPACE for a20
select username,account_status,DEFAULT_TABLESPACE,TEMPORARY_TABLESPACE,PROFILE from dba_users 
where username not in
('MDDATA','TSMSYS','DIP','ORACLE_OCM','DBSNMP','SYSMAN','WMSYS','ORDSYS','EXFSYS','XDB','DMSYS','OLAPSYS','SI_INFORMTN_SCHEMA','ORDPLUGINS','MDSYS','CTXSYS','ANONYMOUS','MGMT_VIEW','SYS','SYSTEM','OUTLN');

-- If the instance is ASM execute the following statement

set heading off;
select '--------------------------------------------get asm_disks--------------------------------------------' from dual;
set heading on;
--select path from v$asm_disk;
select * from gv\$asm_disk;

set heading off;
select '--------------------------------------------get asm_diskgroups--------------------------------------------' from dual;
set heading on;
--select group_number,name,state,total_mb from v\$asm_diskgroup;
select * from v\$asm_diskgroup;

set heading off;
select '--------------------------------------------get asm_instances--------------------------------------------' from dual;
set heading on;
select * from GV\$ASM_CLIENT;

--set heading off;
--select '--------------------------------------------get instance parameter--------------------------------------------' from dual;
--set heading on;
--set line 150
--show parameter

--set heading off;
--select '--------------------------------------------get check archive log mode--------------------------------------------' from dual;
--set heading on;
--archive log list

exit

EOF

