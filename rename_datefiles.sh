#######################################################
# $Name: rename_datefiles.sh
# $Version: v1.0
# $Author: ethan_yang
# $Create Date: 2020-06-24
# $Description:How do I rename datafiles when doing data recovery on another server
#######################################################


SELECT    'set newname for datafile '''
         || name
         || ''' to ''<new_location>'
         || SUBSTR (name, INSTR (name, '/', -1) + 1)
         || ''';'
    FROM v$datafile
ORDER BY file#;
