#######################################################
# $Name: comments_sqlplus.sh
# $Version: v1.0
# $Author: ethan_yang
# $Create Date: 2020-06-29
# $Description:comments that indicates user and instance_name for sqlplus command 
#######################################################



[oracle@host01-EthanDB admin]$ more glogin.sql 
--
-- Copyright (c) 1988, 2005, Oracle.  All Rights Reserved.
--
-- NAME
--   glogin.sql
--
-- DESCRIPTION
--   SQL*Plus global login "site profile" file
--
--   Add any SQL*Plus commands here that are to be executed when a
--   user starts SQL*Plus, or uses the SQL*Plus CONNECT command.
--
-- USAGE
--   This script is automatically run
define _editor=vi
set sqlp "_user'@'_connect_identifier> "
