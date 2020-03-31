#######################################################
# $Name: create_dblink.sh
# $Version: v1.0
# $Author: ethan_yang
# $Create Date: 2020-03-31
# $Description:How to create database link 
#######################################################

create public database link MIS 
connect to missms identified by "sys"
using '(DESCRIPTION =
(ADDRESS_LIST =
(ADDRESS = (PROTOCOL = TCP)(HOST = 10.9.202.67)(PORT = 1521))
)
(CONNECT_DATA =
(SERVICE_NAME =orcl)
)
)';
