#######################################################
# $Name: check_usage_tbs.sh
# $Version: v1.0
# $Author: ethan_yang
# $Create Date: 2019-08-09
# $Description:Checking tablespace usages of oracle
#######################################################

/* Formatted on 2019/8/9 15:13:21 (QP5 v5.256.13226.35538) */
SET LINESIZE 300;

  SELECT UPPER (F.TABLESPACE_NAME) "tablespace",
         D.TOT_GROOTTE_MB "tablespace size(M)",
         D.TOT_GROOTTE_MB - F.TOTAL_BYTES "used size(M)",
         TO_CHAR (
            ROUND (
               (D.TOT_GROOTTE_MB - F.TOTAL_BYTES) / D.TOT_GROOTTE_MB * 100,
               2),
            '990.99')
            "used rate ",
         F.TOTAL_BYTES "free size(M)",
         F.MAX_BYTES "max(M)"
    FROM (  SELECT TABLESPACE_NAME,
                   ROUND (SUM (BYTES) / (1024 * 1024), 2) TOTAL_BYTES,
                   ROUND (MAX (BYTES) / (1024 * 1024), 2) MAX_BYTES
              FROM SYS.DBA_FREE_SPACE
          GROUP BY TABLESPACE_NAME) F,
         (  SELECT DD.TABLESPACE_NAME,
                   ROUND (SUM (DD.BYTES) / (1024 * 1024), 2) TOT_GROOTTE_MB
              FROM SYS.DBA_DATA_FILES DD
          GROUP BY DD.TABLESPACE_NAME) D
   WHERE D.TABLESPACE_NAME = F.TABLESPACE_NAME
ORDER BY 4 DESC;
