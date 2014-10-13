ean-pc-dbscripts
================

Partner Connect database scripts for Partners to create relational database based on V2 downloadable files.
-----------------------------------------------------------------------------------------------------------


The Partners will need to run:

1. MySQL_create_eanprod.sql - This create all of eanprod database structure from scratch, indexes and stored procedures as well.
2. MySQL_extend_eanprod_xx_XX.sql - This will add tables to support extra languages, it will need to be edited to the proper LOCALE information (like es_es for Spanish/Spain).
3. EAN_MySQL_refresh.sh - The script that updates the database, the top lines will need to be adjusted for database name, dbserver, user name, password, etc. Run this to create the database.

 MySQL Version 5.6+ changed the security model, you need to FIRST use:
 mysql_config_editor set --login-path=local --host=localhost --user=localuser –password
 then uncomment the lines with the remarks that will use --login-path parameter instead of --user, --password and --host .

/Queries - Contain multiple queries that show how to relate the data in the database.

/MS-SQL - Script and database creation script. Only English files are covered by this script. Translated files and the extra functions supplied in the MySQL script set are not yet supported.

/MySQL - all MySQL versions of the scripts including my Server my.cnf configuration file, as some changes will be needed to support proper UTF-8 sorting.

/doc - Documentation that I am currently working on to better explain how to use the database files.
-> How-to EAN Database files - How to create the database files (not finished yet).
-> EAN Database Working with Geography - Documentation showing how to relate tables to solve geography, using the stored procedures to support even better (more accurate) searches. 
-> Using external data to add geography information. It includes the geonames table usage to solve questions like: nearby Train Stations.

/perl - Perl scripts that we have created as simple solutions to verify data, reformat data, etc.
-> extract_pet_fee.pl - Extract the information from the database into a new file that is easier to use.
-> validate_hotel_image_links.pl - Test the hotel images links are valid.
-> validate_room_image_links.pl - Test the hotel rooms images links are valid.
-> train_stations.pl - Use the eanextras database with the geonames table to find train stations close to hotels. Not-working yet.

New Geography correct information:
Our data lack the proper StateProvince for a lot of countries, we created the script:
-> get_real_address.pl - use the Nominatim API from OpenStreetMap.org to discover the real address of a given GPS point. Currently wired to the activepropertylist but you could use it for any of the tables with latitude & longitude information. 

/MAC - Mac adjusted versions of the scripts
 It include my compiled version of the wget utility that is REQUIRED for this scripts to work.
 
  
(extras) anything refering to eanextras are experimental database where I test process and data out. You can find the older V1 structures there as well as currently the geonames & ourairports data and geo-search stored procedures.

** Use of these scripts are at your own risk. The scripts are provided “as is” without any warranty of any kind and Expedia disclaims any and all liability regarding any use of the scripts. **

Please contact us with any questions / concern / suggestions.

Partner:Connect Team
apihelp@expedia.com
