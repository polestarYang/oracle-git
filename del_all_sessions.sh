#######################################################
# $Name: del_all_sessions.sh
# $Version: v1.0
# $Author: ethan_yang
# $Create Date: 2019-08-04
# $Description:Delete del_all_sessions of oracle
#######################################################

DECLARE
   u_sid  varchar2(50);
   u_serialnum varchar2(50);
   instance_name varchar2(50);
   u_cursid varchar2(10);
   CURSOR c1 IS select trim(s.sid),trim(s.serial#)
                              from v$session s,v$process p
                              where s.paddr = p.addr  and (s.username=u_name) and s.type != 'BACKGROUND';
BEGIN
   SELECT USERENV('SID') into u_cursid FROM DUAL;
   instance_name:='ETHANDB';
   OPEN c1; 
   LOOP
      FETCH c1 INTO u_sid,u_serialnum;
      EXIT WHEN c1%NOTFOUND;
#      if(u_sid != u_cursid) then 
      EXECUTE IMMEDIATE 'alter system kill session '||''''||trim(u_sid)||','||trim(u_serialnum)||'''';
#	  End if;
   END LOOP;
END;

### 如要删除所有会话则注释掉以下两行代码即可

if(u_sid != u_cursid) then 

End if;
