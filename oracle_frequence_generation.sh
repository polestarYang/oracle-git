#######################################################
# $Name: oracle_frequence_generation.sh
# $Version: v1.0
# $Author: ethan_yang
# $Create Date: 2019-07-122
# $Description: checking the Frequency of archivelog generation Within a month for oracle 
#######################################################

$ sqlplus / as sysdba
set linesize 999
col 00 for '999'
col 01 for '999'
col 02 for '999'
col 03 for '999'
col 04 for '999'
col 05 for '999'
col 06 for '999'
col 07 for '999'
col 08 for '999'
col 09 for '999'
col 10 for '999'
col 11 for '999'
col 12 for '999'
col 13 for '999'
col 14 for '999'
col 15 for '999'
col 16 for '999'
col 17 for '999'
col 18 for '999'
col 19 for '999'
col 20 for '999'
col 21 for '999'
col 22 for '999'
col 23 for '999'
SELECT   thread#, a.ttime, SUM (c8) "08", SUM (c9) "09", SUM (c10) "10",
         SUM (c11) "11", SUM (c12) "12", SUM (c13) "13", SUM (c14) "14",
         SUM (c15) "15", SUM (c16) "16", SUM (c17) "17", SUM (c18) "18",
         SUM (c0) "00", SUM (c1) "01", SUM (c2) "02", SUM (c3) "03",
         SUM (c4) "04", SUM (c5) "05", SUM (c6) "06", SUM (c7) "07",
         SUM (c19) "19", SUM (c20) "20", SUM (c21) "21", SUM (c22) "22",
         SUM (c23) "23"
    FROM (SELECT thread#, ttime, DECODE (tthour, '00', 1, 0) c0,
                 DECODE (tthour, '01', 1, 0) c1,
                 DECODE (tthour, '02', 1, 0) c2,
                 DECODE (tthour, '03', 1, 0) c3,
                 DECODE (tthour, '04', 1, 0) c4,
                 DECODE (tthour, '05', 1, 0) c5,
                 DECODE (tthour, '06', 1, 0) c6,
                 DECODE (tthour, '07', 1, 0) c7,
                 DECODE (tthour, '08', 1, 0) c8,
                 DECODE (tthour, '09', 1, 0) c9,
                 DECODE (tthour, '10', 1, 0) c10,
                 DECODE (tthour, '11', 1, 0) c11,
                 DECODE (tthour, '12', 1, 0) c12,
                 DECODE (tthour, '13', 1, 0) c13,
                 DECODE (tthour, '14', 1, 0) c14,
                 DECODE (tthour, '15', 1, 0) c15,
                 DECODE (tthour, '16', 1, 0) c16,
                 DECODE (tthour, '17', 1, 0) c17,
                 DECODE (tthour, '18', 1, 0) c18,
                 DECODE (tthour, '19', 1, 0) c19,
                 DECODE (tthour, '20', 1, 0) c20,
                 DECODE (tthour, '21', 1, 0) c21,
                 DECODE (tthour, '22', 1, 0) c22,
                 DECODE (tthour, '23', 1, 0) c23
            FROM (SELECT thread#, TO_CHAR (first_time, 'yyyy-mm-dd') ttime,
                         TO_CHAR (first_time, 'hh24') tthour
                    FROM v$log_history
                   WHERE (SYSDATE - first_time < 30))) a
GROUP BY thread#, ttime order by a.ttime;
