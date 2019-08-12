/* Formatted on 2019/8/12 15:29:50 (QP5 v5.256.13226.35538) */
SET TERMOUT       OFF
SET ECHO          OFF
SET FEEDBACK      ON
SET HEADING       ON
SET VERIFY        OFF
SET WRAP          ON
SET TRIMSPOOL     ON
SET SERVEROUTPUT  ON
SET ESCAPE        ON
SET PAGESIZE 50000
SET LINESIZE 175
SET LONG     2000000000
SPOOL crmprdbi_check_other.log
CLEAR BUFFER COMPUTES COLUMNS BREAKS SCREEN
WHENEVER SQLERROR CONTINUE;

PROMPT +----------------------------------------------------------------------------+
PROMPT |                             - database check date -                        |
PROMPT +----------------------------------------------------------------------------+

SELECT TO_CHAR (SYSDATE, 'YYYY-MM-DD') check_date FROM DUAL;

PROMPT +----------------------------------------------------------------------------+
PROMPT |                             - Database version:-                           |
PROMPT +----------------------------------------------------------------------------+

SELECT * FROM v$version;

PROMPT
PROMPT
PROMPT +----------------------------------------------------------------------------+
PROMPT |                             -database parameter check:-                    |
PROMPT +----------------------------------------------------------------------------+
SHOW PARAMETER db_block_size

SELECT USERENV ('language') FROM DUAL;

SELECT VALUE
  FROM nls_database_parameters
 WHERE parameter = 'NLS_NCHAR_CHARACTERSET';

ARCHIVE LOG LIST
PROMPT
PROMPT
PROMPT +----------------------------------------------------------------------------+
PROMPT |                             - SGA INFORMATION -                            |
PROMPT +----------------------------------------------------------------------------+
SHOW SGA
CLEAR COLUMNS BREAKS COMPUTES
COLUMN name    FORMAT a30               HEADING 'Pool Name'
COLUMN value   FORMAT 999,999,999,999   HEADING 'Bytes'

BREAK ON REPORT
COMPUTE SUM LABEL "Total: " OF VALUE ON REPORT

SELECT name, VALUE FROM v$sga;

          PROMPT
          PROMPT Show all information from v$sgastat
          CLEAR COLUMNS BREAKS COMPUTES
          COLUMN name    FORMAT a30               HEADING 'Pool Name'
          COLUMN name    FORMAT a30               HEADING 'Component Name'
          COLUMN value   FORMAT 999,999,999,999   HEADING 'Bytes'
          BREAK ON pool

  SELECT pool, name, bytes
    FROM v$sgastat
   WHERE bytes > 1048576
ORDER BY 1 DESC, 3 DESC;

                        PROMPT
                        PROMPT
                        PROMPT +----------------------------------------------------------------------------+
                        PROMPT |                          - redo info-                                      |
                        PROMPT +----------------------------------------------------------------------------+
                        SET LINESIZE 200 PAGESIZE 1000
                        COL member FOR a80
                        SET HEADING ON

  SELECT *
    FROM v$logfile
ORDER BY group#;

SELECT * FROM v$log;

                        PROMPT
                        PROMPT
prompt-- +----------------------------------------------------------------------------+
prompt-- |                      -- tablespace storage parameter                       |
prompt-- +----------------------------------------------------------------------------+
                        SET LINESIZE 120
                        SET PAGESIZE 100
                        COL tablespace_name FOR a15

SELECT tablespace_name,
       INITIAL_EXTENT,
       NEXT_EXTENT,
       MAX_EXTENTS,
       PCT_INCREASE,
       BLOCK_SIZE,
       EXTENT_MANAGEMENT
  FROM dba_tablespaces;

                        PROMPT
                        PROMPT
prompt-- +----------------------------------------------------------------------------+
prompt-- |                      -- datafile info CHECK                                |
prompt-- +----------------------------------------------------------------------------+
                        COL file_name FOR a50

SELECT file_id,
       file_name,
       bytes / 1024 / 1024,
       AUTOEXTENSIBLE,
       STATUS
  FROM dba_data_files;

                        PROMPT
                        PROMPT
prompt-- +----------------------------------------------------------------------------+
prompt-- |                 -- appuser default tablespace not system                   |
prompt-- +----------------------------------------------------------------------------+

  SELECT username, default_tablespace, temporary_tablespace
    FROM dba_users
   WHERE default_tablespace = 'SYSTEM' OR temporary_tablespace = 'SYSTEM'
ORDER BY username;

                                PROMPT
                                PROMPT
prompt-- +----------------------------------------------------------------------------+
prompt-- |                      -- redo log switch info CHECK                         |
prompt-- +----------------------------------------------------------------------------+

  SELECT TO_CHAR (FIRST_TIME, 'yyyymmdd') DATETIME, COUNT (*) CNT
    FROM V$LOG_HISTORY
   WHERE TO_CHAR (FIRST_TIME, 'yyyymmdd') IN ('20130114',
                                              '20130115',
                                              '2013016',
                                              '20130117',
                                              '20130118')
GROUP BY TO_CHAR (FIRST_TIME, 'yyyymmdd')
ORDER BY TO_CHAR (FIRST_TIME, 'yyyymmdd') DESC;

                                              PROMPT
                                              PROMPT
                                              PROMPT +----------------------------------------------------------------------------+
                                              PROMPT |        - are there some jobs(run failed and status=broken)?                |
                                              PROMPT +----------------------------------------------------------------------------+
                                              COL what FOR a80
                                              COL job FOR 9999
                                              COL broken FOR a6

SELECT job, what, broken
  FROM dba_jobs
 WHERE broken = 'Y' AND failures > 0;

                                              PROMPT
                                              PROMPT
prompt-- +----------------------------------------------------------------------------+
prompt-- |                      -- resource_limit output CHECK                        |
prompt-- +----------------------------------------------------------------------------+
                                              SET LINESIZE 200 PAGESIZE 1000
                                              SET HEADING ON

SELECT *
  FROM v$resource_limit
 WHERE resource_name = 'processes';

                                              PROMPT
                                              PROMPT
prompt-- +----------------------------------------------------------------------------+
prompt-- |                      -- tablespace status                                  |
prompt-- +----------------------------------------------------------------------------+
                                              SET PAGESIZE 300
                                              SET LINESIZE 120
                                              COL file_name FOR a50

SELECT file_name,
       tablespace_name,
       status,
       AUTOEXTENSIBLE
  FROM dba_data_files;

                                              PROMPT
                                              PROMPT
                                              PROMPT +----------------------------------------------------------------------------+
                                              PROMPT |                         - TABLESPACES USAGE-                               |
                                              PROMPT +----------------------------------------------------------------------------+
                                              CLEAR COLUMNS BREAKS COMPUTES

  SELECT df.tablespace_name,
         COUNT (*) datafile_count,
         ROUND (SUM (df.BYTES) / 1048576) size_mb,
         ROUND (SUM (free.BYTES) / 1048576, 2) free_mb,
         ROUND (SUM (df.BYTES) / 1048576 - SUM (free.BYTES) / 1048576, 2)
            used_mb,
         ROUND (MAX (free.maxbytes) / 1048576, 2) maxfree,
         100 - ROUND (100.0 * SUM (free.BYTES) / SUM (df.BYTES), 2) pct_used,
         ROUND (100.0 * SUM (free.BYTES) / SUM (df.BYTES), 2) pct_free
    FROM dba_data_files df,
         (  SELECT tablespace_name,
                   file_id,
                   SUM (BYTES) BYTES,
                   MAX (BYTES) maxbytes
              FROM dba_free_space
          GROUP BY tablespace_name, file_id) free
   WHERE     df.tablespace_name = free.tablespace_name(+)
         AND df.file_id = free.file_id(+)
GROUP BY df.tablespace_name
ORDER BY 8;

                                              PROMPT
                                              PROMPT
prompt-- +----------------------------------------------------------------------------+
prompt-- |                              index status CHECK                            |
prompt-- +----------------------------------------------------------------------------+
                                              SET HEADING OFF
                                              CLEAR COLUMNS BREAKS COMPUTES
                                              COLUMN check_item   FORMAT a35             HEADING 'jianchaxiang'
                                              COLUMN check_result FORMAT a20             HEADING 'jiancha jieguo'
SELECT OWNER, INDEX_NAME
  FROM dba_indexes
 WHERE status <> 'VALID' AND partitioned <> 'YES'
UNION ALL
SELECT INDEX_OWNER, INDEX_NAME
  FROM dba_ind_partitions
 WHERE status <> 'USABLE'
UNION ALL
SELECT INDEX_OWNER, INDEX_NAME
  FROM dba_ind_subpartitions
 WHERE status <> 'USABLE';

                                                                                              SET HEADING ON
                                                                                              PROMPT
                                                                                              PROMPT
prompt-- +----------------------------------------------------------------------------+
prompt-- |                               not extend objects                           |
prompt-- +----------------------------------------------------------------------------+
                                                                                              SET HEADING OFF

SELECT *
  FROM dba_segments ds,
       (  SELECT MAX (bytes) / 1024 / 1024 MAX,
                 SUM (bytes) / 1024 / 1024 SUM,
                 tablespace_name
            FROM dba_free_space
        GROUP BY tablespace_name) dfs
 WHERE     (   ds.next_extent / 1024 / 1024 > NVL (dfs.MAX, 0)
            OR ds.extents >= ds.max_extents)
       AND ds.tablespace_name = dfs.tablespace_name(+)
       AND ds.owner NOT IN ('SYS', 'SYSTEM');

                                                                                                                                                                                   SET HEADING ON
                                                                                                                                                                                   PROMPT
                                                                                                                                                                                   PROMPT
prompt-- +----------------------------------------------------------------------------+
prompt-- |                             suipian > 25% tables                           |
prompt-- +----------------------------------------------------------------------------+
                                                                                                                                                                                   COL owner FOR a10
                                                                                                                                                                                   COL segment_type FOR a10
                                                                                                                                                                                   COL table_name FOR a15

  SELECT OWNER,
         SEGMENT_NAME TABLE_NAME,
         SEGMENT_TYPE,
         GREATEST (
            ROUND (
                 100
               * (NVL (HWM - AVG_USED_BLOCKS, 0) / GREATEST (NVL (HWM, 1), 1)),
               2),
            0)
            WASTE_PER,
         ROUND (BYTES / 1024, 2) TABLE_KB,
         NUM_ROWS,
         BLOCKS,
         HWM HIGHWATER_MARK,
         MAX_EXTENTS,
         DECODE (GREATEST (MAX_FREE_SPACE - NEXT_EXTENT, 0), 0, 'N', 'Y')
            CAN_EXTEND_SPACE
    FROM (SELECT A.OWNER OWNER,
                 A.SEGMENT_NAME,
                 A.SEGMENT_TYPE,
                 A.BYTES,
                 B.NUM_ROWS,
                 A.BLOCKS BLOCKS,
                 B.EMPTY_BLOCKS EMPTY_BLOCKS,
                 A.BLOCKS - B.EMPTY_BLOCKS - 1 HWM,
                   DECODE (
                      ROUND (
                           (B.AVG_ROW_LEN * NUM_ROWS * (1 + (PCT_FREE / 100)))
                         / C.BLOCKSIZE,
                         0),
                      0, 1,
                      ROUND (
                           (B.AVG_ROW_LEN * NUM_ROWS * (1 + (PCT_FREE / 100)))
                         / C.BLOCKSIZE,
                         0))
                 + 2
                    AVG_USED_BLOCKS,
                 ROUND (
                      100
                    * (NVL (B.CHAIN_CNT, 0) / GREATEST (NVL (B.NUM_ROWS, 1), 1)),
                    2)
                    CHAIN_PER,
                 ROUND (100 * (A.EXTENTS / A.MAX_EXTENTS), 2) ALLO_EXTENT_PER,
                 A.EXTENTS EXTENTS,
                 A.MAX_EXTENTS MAX_EXTENTS,
                 B.NEXT_EXTENT NEXT_EXTENT,
                 B.TABLESPACE_NAME O_TABLESPACE_NAME
            FROM SYS.DBA_SEGMENTS A, SYS.DBA_TABLES B, SYS.TS$ C
           WHERE     A.OWNER = B.OWNER
                 AND SEGMENT_NAME = TABLE_NAME
                 AND SEGMENT_TYPE = 'TABLE'
                 AND B.TABLESPACE_NAME = C.NAME
          UNION ALL
          SELECT A.OWNER OWNER,
                 SEGMENT_NAME || '.' || B.PARTITION_NAME,
                 SEGMENT_TYPE,
                 BYTES,
                 B.NUM_ROWS,
                 A.BLOCKS BLOCKS,
                 B.EMPTY_BLOCKS EMPTY_BLOCKS,
                 A.BLOCKS - B.EMPTY_BLOCKS - 1 HWM,
                   DECODE (
                      ROUND (
                           (  B.AVG_ROW_LEN
                            * B.NUM_ROWS
                            * (1 + (B.PCT_FREE / 100)))
                         / C.BLOCKSIZE,
                         0),
                      0, 1,
                      ROUND (
                           (  B.AVG_ROW_LEN
                            * B.NUM_ROWS
                            * (1 + (B.PCT_FREE / 100)))
                         / C.BLOCKSIZE,
                         0))
                 + 2
                    AVG_USED_BLOCKS,
                 ROUND (
                      100
                    * (NVL (B.CHAIN_CNT, 0) / GREATEST (NVL (B.NUM_ROWS, 1), 1)),
                    2)
                    CHAIN_PER,
                 ROUND (100 * (A.EXTENTS / A.MAX_EXTENTS), 2) ALLO_EXTENT_PER,
                 A.EXTENTS EXTENTS,
                 A.MAX_EXTENTS MAX_EXTENTS,
                 B.NEXT_EXTENT,
                 B.TABLESPACE_NAME O_TABLESPACE_NAME
            FROM SYS.DBA_SEGMENTS A,
                 SYS.DBA_TAB_PARTITIONS B,
                 SYS.TS$ C,
                 SYS.DBA_TABLES D
           WHERE     A.OWNER = B.TABLE_OWNER
                 AND SEGMENT_NAME = B.TABLE_NAME
                 AND SEGMENT_TYPE = 'TABLE PARTITION'
                 AND B.TABLESPACE_NAME = C.NAME
                 AND D.OWNER = B.TABLE_OWNER
                 AND D.TABLE_NAME = B.TABLE_NAME
                 AND A.PARTITION_NAME = B.PARTITION_NAME),
         (  SELECT TABLESPACE_NAME F_TABLESPACE_NAME, MAX (BYTES) MAX_FREE_SPACE
              FROM SYS.DBA_FREE_SPACE
          GROUP BY TABLESPACE_NAME)
   WHERE     F_TABLESPACE_NAME = O_TABLESPACE_NAME
         AND GREATEST (
                ROUND (
                     100
                   * (  NVL (HWM - AVG_USED_BLOCKS, 0)
                      / GREATEST (NVL (HWM, 1), 1)),
                   2),
                0) > 25
         AND OWNER = 'SYS'
         AND BLOCKS > 128
ORDER BY 10 DESC, 1 ASC, 2 ASC;

                                                                                                                                                                                   PROMPT
                                                                                                                                                                                   PROMPT
prompt-- +----------------------------------------------------------------------------+
prompt-- |                               index suipian info                           |
prompt-- +----------------------------------------------------------------------------+

SELECT height,
       name,
       blocks,
       lf_blks,
       lf_rows,
       br_blks,
       br_rows,
       del_lf_rows,
       del_lf_rows / lf_rows
  FROM index_stats;

                                                                                                                                                                                   PROMPT
                                                                                                                                                                                   PROMPT
prompt-- +----------------------------------------------------------------------------+
prompt-- |                           invalid database objects                         |
prompt-- +----------------------------------------------------------------------------+
                                                                                                                                                                                   CLEAR COLUMNS BREAKS COMPUTES
                                                                                                                                                                                   COLUMN owner           FORMAT a20         HEADING 'Owner'
                                                                                                                                                                                   COLUMN object_name     FORMAT a30         HEADING 'Object Name'
                                                                                                                                                                                   COLUMN object_type     FORMAT a20         HEADING 'Object Type'
                                                                                                                                                                                   COLUMN status          FORMAT a15         HEADING 'Status'

                                                                                                                                                                                   BREAK ON owner ON object_type ON REPORT
                                                                                                                                                                                   COMPUTE COUNT LABEL "Grand Total: " OF object_name ON REPORT

  SELECT owner,
         object_type,
         object_name,
         status
    FROM dba_objects
   WHERE     status <> 'VALID'
         AND owner NOT IN ('SYS',
                           'SYSTEM',
                           'OUTLN',
                           'MDSYS',
                           'ORDSYS',
                           'ANONYMOUS',
                           'EXFSYS',
                           'DBSNMP',
                           'WMSYS',
                           'XDB',
                           'DIP',
                           'TSMSYS',
                           'ORDPLUGINS',
                           'SI_INFORMTN_SCHEMA',
                           'PUBLIC')
ORDER BY owner, object_type, object_name;

                                                                                                                                                                                   PROMPT
                                                                                                                                                                                   PROMPT
prompt-- +----------------------------------------------------------------------------+
prompt-- |                              CHECK END!!!!!!!!!                            |
prompt-- +----------------------------------------------------------------------------+
