echo off
set NLS_LANG=AMERICAN_AMERICA.AL32UTF8
cd ..\..\
echo exit | sqlplus test/oracle@localhost:1521/xe @install.sql
cd test\simple
