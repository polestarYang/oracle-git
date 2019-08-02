#######################################################
# $Name: del_external_sessions.sh
# $Version: v1.0
# $Author: ethan_yang
# $Create Date: 2019-08-02
# $Description:Delete external connection sessions from users except for sys in bul
#######################################################

SET LINESIZE 100
COLUMN spid FORMAT A10
COLUMN username FORMAT A10
COLUMN program FORMAT A45

declare cursor mycur is   
SELECT s.inst_id,
       s.sid,
       s.serial#,
       p.spid,
       s.username,
       s.program
FROM   gv$session s
       JOIN gv$process p ON p.addr = s.paddr AND p.inst_id = s.inst_id
WHERE  s.type != 'BACKGROUND' and s.username not like '%SYS%';

begin  
  for cur in mycur  
    loop    
     execute immediate ( 'alter system  kill session  '''||cur.sid || ','|| cur.SERIAL# ||''' ');  
     end loop;  
end; 
/
