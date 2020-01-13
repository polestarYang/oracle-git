#######################################################
# $Name: update_statistics.sh.sh
# $Version: v1.0
# $Author: ethan_yang
# $Create Date: 2019-01-13
# $Description:update statistics for schema
#######################################################

/* Formatted on 2020/1/13 15:28:55 */
-- connect to the user ETHANDB
SQL>CONNECT ETHANDB/ETHANDB

-- This step is important ，grant the privileges create any table to the user ETHANDB
SQL>GRANT CREATE ANY TABLE TO ETHANDB;

-- build the procedure  ANALYZE_TB in user ETHANdb to analyze ths statistics
SQL>CREATE OR REPLACE PROCEDURE ANALYZE_TB AS
  OWNER_NAME  VARCHAR2(100);
  V_LOG       INTEGER;
  V_SQL1      VARCHAR2(800);
  V_TABLENAME VARCHAR2(50);
  CURSOR CUR_LOG IS

SELECT COUNT (*)
  FROM USER_TABLES
 WHERE TABLE_NAME = 'ANALYZE_LOG';

  --1

BEGIN
   --DBMS_OUTPUT.ENABLE (buffer_size=>100000);
   --1.1
   BEGIN
      OPEN CUR_LOG;

      FETCH CUR_LOG INTO V_LOG;

      IF V_LOG = 0
      THEN
         EXECUTE IMMEDIATE
            'CREATE TABLE ANALYZE_LOG (USER_NAME VARCHAR(20),OP_TIME CHAR(19) DEFAULT to_char(sysdate,''yyyy-mm-dd hh24:mi:ss''),ERROR_TEXT VARCHAR(200),TABLE_NAME VARCHAR(40))';
      END IF;
   END;

   SELECT USER INTO OWNER_NAME FROM DUAL;

   V_SQL1 :=
         'INSERT INTO ANALYZE_LOG (USER_NAME,ERROR_TEXT,TABLE_NAME) VALUES ('''
      || OWNER_NAME
      || ''',''ANALYZE BEGIN'',''ALL'')';

   EXECUTE IMMEDIATE V_SQL1;

   sys.DBMS_STATS.gather_schema_stats (
      ownname            => UPPER (OWNER_NAME),
      estimate_percent   => 100,
      method_opt         => 'FOR ALL INDEXED COLUMNS',
      cascade            => TRUE);
   V_SQL1 :=
         'INSERT INTO ANALYZE_LOG (USER_NAME,ERROR_TEXT,TABLE_NAME) VALUES ('''
      || OWNER_NAME
      || ''',''ANALYZE END'',''ALL'')';

   EXECUTE IMMEDIATE V_SQL1;

   COMMIT;

   --1.2 delete tmptbstatitics and lock statistics
   BEGIN
      FOR x
         IN (SELECT a.table_name, a.last_analyzed, b.stattype_locked
               FROM user_tables a, user_tab_statistics b
              WHERE     a.temporary = 'Y'
                    AND a.table_name = b.table_name
                    AND (   b.STATTYPE_LOCKED IS NULL
                         OR a.last_analyzed IS NOT NULL))
      LOOP
         IF x.last_analyzed IS NOT NULL
         THEN
            --delete stats
            DBMS_STATS.delete_table_stats (ownname   => USER,
                                           tabname   => x.table_name,
                                           force     => TRUE);
         END IF;

         IF x.stattype_locked IS NULL
         THEN
            --lock stats
            DBMS_STATS.lock_table_stats (ownname   => USER,
                                         tabname   => x.table_name);
         END IF;
      END LOOP;
   END;
EXCEPTION
   WHEN OTHERS
   THEN
      IF CUR_LOG%ISOPEN
      THEN
         CLOSE CUR_LOG;
      END IF;

      COMMIT;
END;
/

--execute the procedure ANALYZE_TB
SQL>exec ANALYZE_TB;
