ean-pc-dbscripts
================

Partner Connect database scripts for Partners to create relational database based on V2 downloadable files

The Partners will need to run:

1. MySQL_create_eanprod.sql - This create all of eanprod database structure from scratch, indexes and stored procedures as well.
2. MySQL_extend_eanprod_xx_XX.sql - This will add tables to support extra languages, it will need to be edited to the proper LOCALE information (like es_es for Spanish/Spain).
3. EAN_MySQL_refresh.sh - The script that updates the database, the top lines will need to be adjusted for database name, dbserver, user name, password, etc. Run this to create the database.

/Queries - Contain multiple queries that show how to relate the data in the database.

/MS-SQL - Script and database creation script. IT ONLY will do the activepropertylist - it is unfinished, but all the working parts are there, partners just need to add the other 33 tables.
/MySQL - all MySQL versions of the scripts including my Server my.cnf configuration file, as some changes will be needed to support proper UTF-8 sorting.

/doc - Documentation that I am currently working on to better explain how to use the database files.
-> How-to EAN Database files - How to create the database files (not finished yet).
-> EAN Database Working with Geography - Documentation showing how to relate tables to solve geography, or use the stored procedures to support even better (more accurate) searches. It includes the geonames table usage to solve questions like: nearby Train Stations.

/MAC - Mac adjusted versions of the scripts
 It include my compiled version of the wget utility that is REQUIRED for this scripts to work.
 
(extras) anything refering to eanextras are experimental database where I test process and data out. You can find the older V1 structures there as well as currently the geonames & ourairports data and geo-search stored procedures.

 
Please contact me with any questions / concern / suggestions.

Jon Arce
Partner Connect
Sr. Integration Manager
jarce@expedia.com
