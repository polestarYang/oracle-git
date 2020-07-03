/* Formatted on 2020/7/3 11:17:37 (QP5 v5.256.13226.35538) */

SELECT S.SID SESSION_ID,
       S.USERNAME,
       DECODE (LMODE,
               0, ' None ',
               1, ' Null ',
               2, ' Row-S(SS) ',
               3, ' Row-X(SX) ',
               4, ' Share',
               5, 'S/Row-X (SSX) ',
               6, 'Exclusive ',
               TO_CHAR (LMODE))
          MODE_HELD,
       DECODE (REQUEST,
               0, ' None ',
               1, ' Null ',
               2, ' Row-S(SS) ',
               3, ' Row-X(SX) ',
               4, ' Share',
               5, 'S/Row-X (SSX) ',
               6, 'Exclusive ',
               TO_CHAR (REQUEST))
          MODE_REQUESTED,
       O.OWNER || ' . ' || O.OBJECT_NAME || ' ( ' || O.OBJECT_TYPE || ' ) '
          AS OBJECT_NAME,
       S.TYPE LOCK_TYPE,
       L.ID1 LOCK_ID1,
       L.ID2 LOCK_ID2
  FROM V$LOCK L, SYS.DBA_OBJECTS O, V$SESSION S
 WHERE     L.SID = S.SID
       AND L.ID1 = O.OBJECT_ID
       AND object_name = 'TABLE_NAME';
