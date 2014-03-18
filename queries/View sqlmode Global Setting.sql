## For the scripts to work you need to change:
# changed so we could insert without errors of the EAN load script
#sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
# TO:
#sql_mode=NO_ENGINE_SUBSTITUTION
# you could add it in [mysqld] section tof your my.cnf configuration file
#
#MySQL for OS X from Oracle ships with a /usr/local/mysql/my.cnf which is loaded on startup. 
#
use eanprod;
SELECT @@GLOBAL.sql_mode;