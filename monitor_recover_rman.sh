#######################################################
# $Name: monitoring_rman.sh
# $Version: v1.0
# $Author: ethan_yang
# $Create Date: 2020-02-09
# $Description:Monitoring of Recovery process of rman recovery
/* Formatted on 2020/2/9 11:38:52 (QP5 v5.256.13226.35538) */
#######################################################

set line 9999
col opname for a35
col start_time for a19
  SELECT SID,
         SERIAL#,
         opname,
         TO_CHAR (start_time, 'yyyy-mm-dd HH24:MI:SS') start_time,
         SOFAR,
         TOTALWORK,
         ROUND (SOFAR / TOTALWORK * 100, 2) "%COMPLETE",
         CEIL (ELAPSED_SECONDS / 60) ELAPSED_MI
    FROM V$SESSION_LONGOPS
   WHERE opname LIKE 'RMAN%' AND totalwork <> 0
ORDER BY start_time ASC;

  
       SID    SERIAL# OPNAME                              START_TIME               SOFAR  TOTALWORK  %COMPLETE ELAPSED_MI
---------- ---------- ----------------------------------- ------------------- ---------- ---------- ---------- ----------
         2         13 RMAN: aggregate input               2020-02-07 14:15:06        500        500        100          1
         2         19 RMAN: aggregate input               2020-02-07 14:34:00        500        500        100          1
         2         27 RMAN: aggregate input               2020-02-07 14:56:46        500        500        100          1
         2         31 RMAN: aggregate input               2020-02-07 15:20:49        500        500        100          1
       907         13 RMAN: aggregate input               2020-02-07 15:57:03        500        500        100          1
      1811          3 RMAN: full datafile restore         2020-02-07 16:06:22   30533632   30533632        100         71
      1811          3 RMAN: full datafile restore         2020-02-07 17:16:50   30530048   30530048        100         69
       454         75 RMAN: aggregate input               2020-02-08 08:58:53  509776180 1660415518       30.7       1354
      1359         13 RMAN: full datafile restore         2020-02-08 08:58:56   30433280   30433280        100         71
      1359         13 RMAN: full datafile restore         2020-02-08 10:09:04   30425088   30425088        100         88
      1359         13 RMAN: full datafile restore         2020-02-08 11:36:25   30408704   30408704        100         74

       SID    SERIAL# OPNAME                              START_TIME               SOFAR  TOTALWORK  %COMPLETE ELAPSED_MI
---------- ---------- ----------------------------------- ------------------- ---------- ---------- ---------- ----------
      1359         13 RMAN: full datafile restore         2020-02-08 12:50:06   30408704   30408704        100         66
      1359         13 RMAN: full datafile restore         2020-02-08 13:56:15   30408704   30408704        100         73
      1359         13 RMAN: full datafile restore         2020-02-08 15:08:24   30408704   30408704        100         74
      1359         13 RMAN: full datafile restore         2020-02-08 16:21:43   30401024   30401024        100         74
      1359         13 RMAN: full datafile restore         2020-02-08 17:34:53   30388224   30388224        100         70
      1359         13 RMAN: full datafile restore         2020-02-08 18:44:02   30388224   30388224        100         70
      1359         13 RMAN: full datafile restore         2020-02-08 19:53:12   30388224   30388224        100         68
      1359         13 RMAN: full datafile restore         2020-02-08 21:01:11   30277632   30277632        100         65
      1359         13 RMAN: full datafile restore         2020-02-08 22:05:31   30388224   30388224        100         72
      1359         13 RMAN: full datafile restore         2020-02-08 23:16:59   30277632   30277632        100         76
      1359         13 RMAN: full datafile restore         2020-02-09 00:32:19   30190592   30190592        100         73

       SID    SERIAL# OPNAME                              START_TIME               SOFAR  TOTALWORK  %COMPLETE ELAPSED_MI
---------- ---------- ----------------------------------- ------------------- ---------- ---------- ---------- ----------
      1359         13 RMAN: full datafile restore         2020-02-09 01:45:19   30146560   30146560        100         75
      1359         13 RMAN: full datafile restore         2020-02-09 02:59:30   30146560   30146560        100         91
      1359         13 RMAN: full datafile restore         2020-02-09 06:26:17   30146560   30146560        100         62
      1359         13 RMAN: full datafile restore         2020-02-09 07:28:27    1989737   29638656       6.71          5

26 rows selected.

SYS@CRMPRDSDB> 
  
