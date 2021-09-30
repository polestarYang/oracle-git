set linesize 300;
SELECT R1.*,R2.MAX_SIZE_GB FROM
(SELECT  /*+ ORDERED */
A.TABLESPACE_NAME TABLESPACE_NAME,
       ROUND(A.BYTES / 1024 / 1024 / 1024, 2) CURRENT_SIZE_GB,
       ROUND((A.BYTES - B.BYTES) / 1024 / 1024 / 1024, 2) USED_SIZE_GB,
       ROUND(B.BYTES / 1024 / 1024 / 1024, 2) FREE_SIZE_GB,
       ROUND(((A.BYTES - B.BYTES) / A.BYTES) * 100, 2) PERCENT_USED_RATE
  FROM (SELECT TABLESPACE_NAME, SUM(BYTES) BYTES
          FROM DBA_DATA_FILES
         GROUP BY TABLESPACE_NAME) A,
       (SELECT TABLESPACE_NAME, SUM(BYTES) BYTES, MAX(BYTES) LARGEST
          FROM DBA_FREE_SPACE
         GROUP BY TABLESPACE_NAME) B
 WHERE A.TABLESPACE_NAME = B.TABLESPACE_NAME
 ORDER BY A.TABLESPACE_NAME) R1,
 (SELECT /*+ ORDERED */
 D.TABLESPACE_NAME TABLESPACE_NAME,
 ROUND(SUM(D.BYTES) / 1024 / 1024 / 1024, 2) CURRENT_SIZE_GB,
 ROUND(SUM(D.MAXBYTES) / 1024 / 1024 / 1024, 2) MAX_SIZE_GB
  FROM SYS.DBA_DATA_FILES D,
       V$DATAFILE V,
       (SELECT VALUE FROM V$PARAMETER WHERE NAME = 'db_block_size') E
 WHERE (D.FILE_NAME = V.NAME)
 GROUP BY D.TABLESPACE_NAME) R2
 WHERE R1.TABLESPACE_NAME = R2.TABLESPACE_NAME;
 