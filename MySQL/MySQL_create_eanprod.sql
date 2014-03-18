########################################################
## MySQL_create_eanprod.sql                      v3.1 ##
## SCRIPT TO GENERATE EAN DATABASE IN MYSQL ENGINE    ##
## BE CAREFUL AS IT WILL ERASE THE EXISTING DATABASE  ##
## YOU CAN USE SECTIONS OF IT TO RE-CREATE TABLES     ##
## WILL CREATE USER: eanuser / expedia                ##
## table names are lowercase so it will work  in all  ## 
## platforms the same.                                ##
########################################################

DROP DATABASE IF EXISTS eanprod;
## specify utf8 / ut8_unicode_ci to manage all languages properly
## updated from files contain those characters
CREATE DATABASE eanprod CHARACTER SET utf8 COLLATE utf8_unicode_ci;

## users permisions
GRANT ALL ON eanprod.* TO 'eanuser'@'%' IDENTIFIED BY 'Passw@rd1';
GRANT ALL ON eanprod.* TO 'eanuser'@'localhost' IDENTIFIED BY 'Passw@rd1';

## REQUIRED IN WINDOWS as we do not use STRICT_TRANS_TABLE for the upload process
SET @@global.sql_mode= '';
SET GLOBAL sql_mode='';

USE eanprod;

########################################################
##                                                    ##
## TABLES CREATED FROM THE EAN RELATIONAL DOWNLOADED  ##
## FILES.                                             ##
##                                                    ##
########################################################

DROP TABLE IF EXISTS airportcoordinateslist;
CREATE TABLE airportcoordinateslist
(
	AirportID INT NOT NULL,
	AirportCode VARCHAR(3) NOT NULL,
	AirportName VARCHAR(70),
	Latitude numeric(9,6),
	Longitude numeric(9,6),
	MainCityID INT,
	CountryCode VARCHAR(2),
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (AirportCode)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;

## index by Airport Name to use for text searches
CREATE INDEX idx_airportcoordinatelist_airportname ON airportcoordinateslist(AirportName);
## index by MainCityID to use as relational key
CREATE INDEX idx_airportcoordinatelist_maincityid ON airportcoordinateslist(MainCityID);
## index by Latitude, Longitude to use for geosearches
CREATE INDEX airportcoordinate_geoloc ON airportcoordinateslist(Latitude, Longitude);

DROP TABLE IF EXISTS activepropertylist;
CREATE TABLE activepropertylist
(
	EANHotelID INT NOT NULL,
	SequenceNumber INT,
	Name VARCHAR(70),
	Address1 VARCHAR(50),
	Address2 VARCHAR(50),
	City VARCHAR(50),
	StateProvince VARCHAR(2),
	PostalCode VARCHAR(15),
	Country VARCHAR(2),
	Latitude numeric(8,5),
	Longitude numeric(8,5),
	AirportCode VARCHAR(3),
	PropertyCategory INT,
	PropertyCurrency VARCHAR(3),
	StarRating numeric(2,1),
	Confidence INT,
	SupplierType VARCHAR(3),
	Location VARCHAR(80),
	ChainCodeID VARCHAR(5),
	RegionID INT,
	HighRate numeric(19,4),
	LowRate numeric(19,4),
	CheckInTime VARCHAR(10),
	CheckOutTime VARCHAR(10),
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (EANHotelID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;

## index by Latitude, Longitude to use for geosearches
CREATE INDEX activeproperties_geoloc ON activepropertylist(Latitude, Longitude);
## index by RegionID to use for Regions searches
CREATE INDEX activeproperties_regionid ON activepropertylist(RegionID);

DROP TABLE IF EXISTS pointsofinterestcoordinateslist;
CREATE TABLE pointsofinterestcoordinateslist
(
	RegionID INT NOT NULL,
	RegionName VARCHAR(255),
## as it will be the key need to be less than 767 bytes (767 / 4 = 191.75)  
	RegionNameLong VARCHAR(191),
	Latitude numeric(9,6),
	Longitude numeric(9,6),
	SubClassification VARCHAR(20),
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (RegionNameLong)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;

## index by RegionID to use as relational key
CREATE INDEX idx_pointsofinterestcoordinateslist_regionid ON pointsofinterestcoordinateslist(RegionID);


DROP TABLE IF EXISTS countrylist;
CREATE TABLE countrylist
(
	CountryID INT NOT NULL,
	LanguageCode VARCHAR(5),
	CountryName VARCHAR(250),
	CountryCode VARCHAR(2) NOT NULL,
	Transliteration VARCHAR(256),
	ContinentID INT,
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (CountryID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;

## add indexes by country code & country name
CREATE INDEX idx_countrylist_countrycode ON countrylist(CountryCode);
CREATE INDEX idx_countrylist_countryname ON countrylist(CountryName);


DROP TABLE IF EXISTS propertytypelist;
CREATE TABLE propertytypelist
(
	PropertyCategory INT NOT NULL,
	LanguageCode VARCHAR(5),
	PropertyCategoryDesc VARCHAR(256),
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (PropertyCategory)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;


DROP TABLE IF EXISTS chainlist;
CREATE TABLE chainlist
(
	ChainCodeID INT NOT NULL,
	ChainName VARCHAR(30),
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (ChainCodeID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;


DROP TABLE IF EXISTS propertydescriptionlist;
CREATE TABLE propertydescriptionlist
(
	EANHotelID INT NOT NULL,
	LanguageCode VARCHAR(5),
	PropertyDescription TEXT,
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (EANHotelID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;


DROP TABLE IF EXISTS policydescriptionlist;
CREATE TABLE policydescriptionlist
(
	EANHotelID INT NOT NULL,
	LanguageCode VARCHAR(5),
	PolicyDescription TEXT,
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (EANHotelID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;


DROP TABLE IF EXISTS recreationdescriptionlist;
CREATE TABLE recreationdescriptionlist
(
	EANHotelID INT NOT NULL,
	LanguageCode VARCHAR(5),
	RecreationDescription TEXT,
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (EANHotelID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;


DROP TABLE IF EXISTS areaattractionslist;
CREATE TABLE areaattractionslist
(
	EANHotelID INT NOT NULL,
	LanguageCode VARCHAR(5),
	AreaAttractions TEXT,
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (EANHotelID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;


DROP TABLE IF EXISTS diningdescriptionlist;
CREATE TABLE diningdescriptionlist
(
	EANHotelID INT NOT NULL,
	LanguageCode VARCHAR(5),
	DiningDescription TEXT,
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (EANHotelID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;

DROP TABLE IF EXISTS spadescriptionlist;
CREATE TABLE spadescriptionlist
(
	EANHotelID INT NOT NULL,
	LanguageCode VARCHAR(5),
	SpaDescription TEXT,
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (EANHotelID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;


DROP TABLE IF EXISTS whattoexpectlist;
CREATE TABLE whattoexpectlist
(
	EANHotelID INT NOT NULL,
	LanguageCode VARCHAR(5),
	WhatToExpect TEXT,
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (EANHotelID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;


## Multiple rooms per each hotel - so a compound primary key
DROP TABLE IF EXISTS roomtypelist;
CREATE TABLE roomtypelist
(
	EANHotelID INT NOT NULL,
	RoomTypeID INT NOT NULL,
	LanguageCode VARCHAR(5),
	RoomTypeImage VARCHAR(256),
	RoomTypeName VARCHAR(200),
	RoomTypeDescription TEXT,
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (EANHotelID, RoomTypeID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;


DROP TABLE IF EXISTS attributelist;
CREATE TABLE attributelist
(
	AttributeID INT NOT NULL,
	LanguageCode VARCHAR(5),
	AttributeDesc VARCHAR(255),
	Type VARCHAR(15),
	SubType VARCHAR(15),
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (AttributeID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;


DROP TABLE IF EXISTS propertyattributelink;
CREATE TABLE propertyattributelink
(
	EANHotelID INT NOT NULL,
	AttributeID INT NOT NULL,
	LanguageCode VARCHAR(5),
	AppendTxt VARCHAR(191),
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
## table so far do not present the same problem as GDSpropertyattributelink
	PRIMARY KEY (EANHotelID, AttributeID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;
## add reverse index to speed up reversed join queries
CREATE INDEX idx_propertyattributelink_reverse ON propertyattributelink(AttributeID,EANHotelID);



DROP TABLE IF EXISTS gdsattributelist;
CREATE TABLE gdsattributelist
(
	AttributeID INT NOT NULL,
	LanguageCode VARCHAR(5),
	AttributeDesc VARCHAR(255),
	Type VARCHAR(15),
	SubType VARCHAR(15),
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (AttributeID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;

DROP TABLE IF EXISTS gdspropertyattributelink;
CREATE TABLE gdspropertyattributelink
(
	EANHotelID INT NOT NULL,
	AttributeID INT NOT NULL,
	LanguageCode VARCHAR(5),
	AppendTxt VARCHAR(191),
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
## need all those fields to make a uniquekey
	PRIMARY KEY (EANHotelID, AttributeID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;
## add reverse index to speed up reversed join queries
CREATE INDEX idx_gdsattributelink_reverse ON propertyattributelink(AttributeID,EANHotelID);


########### Image Data ####################
## there are multiple images for an hotel 
## even with the same caption
## to make a unique index we need to use
## the URL instead

DROP TABLE IF EXISTS hotelimagelist;
CREATE TABLE hotelimagelist
(
	EANHotelID INT NOT NULL,
	Caption VARCHAR(70),
## URLs are now max 80 chars
	URL VARCHAR(150) NOT NULL,
	Width INT,
	Height INT,
	ByteSize INT,
	ThumbnailURL VARCHAR(300),
	DefaultImage bit,
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (URL)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;
CREATE INDEX idx_hotelimagelist_eanhotelid ON hotelimagelist(EANHotelID);

########## Geography Data ###################

DROP TABLE IF EXISTS citycoordinateslist;
CREATE TABLE citycoordinateslist
(
	RegionID INT NOT NULL,
	RegionName VARCHAR(255),
	Coordinates TEXT,
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (RegionID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;


## table to correct search term for a region
## notice there are NO spaces between words
DROP TABLE IF EXISTS aliasregionlist;
CREATE TABLE aliasregionlist
(
	RegionID INT NOT NULL,
	LanguageCode VARCHAR(5),
	AliasString VARCHAR(255),
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
##	PRIMARY KEY (RegionID, AliasString)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;
CREATE INDEX idx_aliasregionid_regionid ON aliasregionlist(RegionID);


DROP TABLE IF EXISTS parentregionlist;
CREATE TABLE parentregionlist
(
	RegionID INT NOT NULL,
	RegionType VARCHAR(50),
	RelativeSignificance VARCHAR(3),
	SubClass VARCHAR(50),
	RegionName VARCHAR(255),
	RegionNameLong VARCHAR(510),
	ParentRegionID INT,
	ParentRegionType VARCHAR(50),
	ParentRegionName VARCHAR(255),
	ParentRegionNameLong VARCHAR(510),
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (RegionID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;
CREATE INDEX idx_parentregionlist_parentid ON parentregionlist(ParentRegionID);

DROP TABLE IF EXISTS neighborhoodcoordinateslist;
CREATE TABLE neighborhoodcoordinateslist
(
	RegionID INT NOT NULL,
	RegionName VARCHAR(255),
	Coordinates TEXT,
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (RegionID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;


DROP TABLE IF EXISTS regioncentercoordinateslist;
CREATE TABLE regioncentercoordinateslist
(
	RegionID INT NOT NULL,
	RegionName VARCHAR(255),
	CenterLatitude numeric(9,6),
	CenterLongitude numeric(9,6),
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (RegionID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;


DROP TABLE IF EXISTS regioneanhotelidmapping;
CREATE TABLE regioneanhotelidmapping
(
	RegionID INT NOT NULL,
	EANHotelID INT NOT NULL,
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (RegionID, EANHotelID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;
CREATE INDEX idx_hotelidmapping_reverse ON regioneanhotelidmapping(EANHotelID,RegionID);

##
## added tables for minorRev=24+
##
DROP TABLE IF EXISTS propertylocationlist;
CREATE TABLE propertylocationlist
(
	EANHotelID INT NOT NULL,
	LanguageCode VARCHAR(5),
	PropertyLocationDescription TEXT,
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (EANHotelID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;

DROP TABLE IF EXISTS propertyamenitieslist;
CREATE TABLE propertyamenitieslist
(
	EANHotelID INT NOT NULL,
	LanguageCode VARCHAR(5),
	PropertyAmenitiesDescription TEXT,
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (EANHotelID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;

DROP TABLE IF EXISTS propertyroomslist;
CREATE TABLE propertyroomslist
(
	EANHotelID INT NOT NULL,
	LanguageCode VARCHAR(5),
	PropertyRoomsDescription TEXT,
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (EANHotelID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;

DROP TABLE IF EXISTS propertybusinessamenitieslist;
CREATE TABLE propertybusinessamenitieslist
(
	EANHotelID INT NOT NULL,
	LanguageCode VARCHAR(5),
	PropertyBusinessAmenitiesDescription TEXT,
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (EANHotelID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;

DROP TABLE IF EXISTS propertynationalratingslist;
CREATE TABLE propertynationalratingslist
(
	EANHotelID INT NOT NULL,
	LanguageCode VARCHAR(5),
	PropertyNationalRatingsDescription TEXT,
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (EANHotelID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;

DROP TABLE IF EXISTS propertyfeeslist;
CREATE TABLE propertyfeeslist
(
	EANHotelID INT NOT NULL,
	LanguageCode VARCHAR(5),
	PropertyFeesDescription TEXT,
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (EANHotelID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;

DROP TABLE IF EXISTS propertymandatoryfeeslist;
CREATE TABLE propertymandatoryfeeslist
(
	EANHotelID INT NOT NULL,
	LanguageCode VARCHAR(5),
	PropertyMandatoryFeesDescription TEXT,
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (EANHotelID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;

DROP TABLE IF EXISTS propertyrenovationslist;
CREATE TABLE propertyrenovationslist
(
	EANHotelID INT NOT NULL,
	LanguageCode VARCHAR(5),
	PropertyRenovationsDescription TEXT,
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (EANHotelID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;


##################################################################
## STORED PROCEDURE sp_hotels_from_point
##
## to be used as geosearch, but it does NOT uses the Spatial features
## just a simple compound index added to activepropertylist
##
## Parameters:
## lat 	- latitude
## lon 	- longitude
## maxdist	- distance
## maxcount - amount of records (if available)
## CALL sp_hotels_from_point(40.740984,-74.007500,5); ## meat-packing district
##
## Some Cities Coordinates (http://gael-varoquaux.info/blog/wp-content/uploads/2008/12/cities.txt)
## Cape Town	-33.93	18.46	
## Sao Paulo	-23.53	-46.63	
## Moscow		55.75	37.62	
## Seoul		37.56	126.99	
## Tokyo		35.67	139.77	
## Mexico City	19.43	-99.14	
## New York		40.67	-73.94	
## Las Vegas	36.21	-115.22	
## Los Angeles	34.11	-118.41	
##
## Santiago Bernabeu Stadium 40.451585,-3.690375
##
##################################################################
DROP PROCEDURE IF EXISTS sp_hotels_from_point;
DELIMITER $$
CREATE PROCEDURE sp_hotels_from_point(IN lat double,lon double, maxdist int)
BEGIN
SELECT EanHotelID,Name,Address1,Address2,City,StateProvince,
	   PostalCode,Country,StarRating,LowRate,HighRate,Latitude,Longitude,
# this calculate the distance from the given longitude, latitude
    round( sqrt( 
        (POW(a.Latitude - lat, 2)* 68.1 * 68.1) + 
        (POW(a.Longitude - lon, 2) * 53.1 * 53.1) 
     )) AS distance
FROM activepropertylist AS a 
WHERE 1=1
HAVING distance < maxdist
ORDER BY distance ASC;
# to use LIMIT you need to use a prepared statement to avoid errors
END 
$$
DELIMITER ;
##################################################################
##this version will allow you to restrict the results:
##stay in an Specific Country
##stay in an Specific City
##################################################################
DROP PROCEDURE IF EXISTS sp_hotels_from_point_restrict;
DELIMITER $$
CREATE PROCEDURE sp_hotels_from_point_restrict(IN lat double,lon double, maxdist int, country varchar(200), city varchar(200))
BEGIN
SET @s = CONCAT('SELECT EanHotelID,Name,Address1,Address2,City,StateProvince,PostalCode,Country,StarRating,LowRate,HighRate,Latitude,Longitude,',
                ' round( sqrt((POW(a.Latitude-',lat,',2)*68.1*68.1)+(POW(a.Longitude-',lon,',2)*53.1* 53.1))) AS distance', 
				 ' FROM activepropertylist AS a ',
                ' WHERE Country=\'',country,'\' AND City=\'',city,
                '\' HAVING distance < ',maxdist,
                ' ORDER BY distance ASC;');
PREPARE stmt1 FROM @s; 
EXECUTE stmt1; 
DEALLOCATE PREPARE stmt1;
END 
$$
DELIMITER ;

##################################################################
##this version will allow you to restrict the results:
##stay in an Specific PostalCode
##################################################################
DROP PROCEDURE IF EXISTS sp_hotels_from_point_restrict_postal;
DELIMITER $$
CREATE PROCEDURE sp_hotels_from_point_restrict_postal(IN lat double,lon double, maxdist int, postalcode varchar(60))
BEGIN
SET @s = CONCAT('SELECT EanHotelID,Name,Address1,Address2,City,StateProvince,PostalCode,Country,StarRating,LowRate,HighRate,Latitude,Longitude,',
                ' round( sqrt((POW(a.Latitude-',lat,',2)*68.1*68.1)+(POW(a.Longitude-',lon,',2)*53.1* 53.1))) AS distance', 
				 ' FROM activepropertylist AS a ',
                ' WHERE REPLACE(PostalCode," ","")=\'',postalcode,
                '\' HAVING distance < ',maxdist,
                ' ORDER BY distance ASC;');
PREPARE stmt1 FROM @s; 
EXECUTE stmt1; 
DEALLOCATE PREPARE stmt1;
END 
$$
DELIMITER ;

##################################################################
##this Stored Procedure will use the Airport table to find the closest Airport code
## use like: CALL sp_airport_from_point(40.451585,-3.690375,'ES',2);
## if you need more results just change the LIMIT number or create a parameter for it
## NO Heliport or Train Stations Included
## MAXREC - how many to return (usefull when too close to a large regional to get the international also)
##################################################################
DROP PROCEDURE IF EXISTS sp_airport_from_point;
DELIMITER $$
CREATE PROCEDURE sp_airport_from_point(IN lat double,lon double,countrycode VARCHAR(2),maxrec INT)
BEGIN
SET @s = CONCAT('SELECT AirportID,AirportCode,AirportName,CountryCode,Latitude,Longitude,',
                ' round( sqrt((POW(a.Latitude-',lat,',2)*68.1*68.1)+(POW(a.Longitude-',lon,',2)*53.1* 53.1))) AS distance', 
				 ' FROM airportcoordinateslist AS a ',
				 ' WHERE CountryCode=','\'',countrycode,'\'',' AND AirportName NOT LIKE \'%Heliport%\' AND AirportName NOT LIKE \'%Train%\'',
                ' ORDER BY distance ASC LIMIT ',maxrec,';');
PREPARE stmt1 FROM @s; 
EXECUTE stmt1; 
DEALLOCATE PREPARE stmt1;
END 
$$
DELIMITER ;
##################################################################
## Stored Procedure & structures to create a log of changes
## for the activepropertylist Table
## looking to detect:
## 1. new records
## 2. deleted records
## 3. EANHotelID name changes
## 4. EANHotelID new record for an old existing hotel
###################################################################

## table used to log the changes that happens to activepropertylist
DROP TABLE IF EXISTS log_activeproperty_changes;
CREATE TABLE log_activeproperty_changes
(
	EANHotelID INT NOT NULL,
	FieldName VARCHAR(30),
	FieldType VARCHAR(30),
	FieldValueOld VARCHAR(80),
	FieldValueNew VARCHAR(80),
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;

## index by ChangeDate + Hotel ID + Field Changed to use for changelog searches
CREATE INDEX log_activeproperties ON log_activeproperty_changes(TimeStamp, EANHotelID, FieldName);


##################################################################
## STEP 1 - Save Old records
## must be called BEFORE refreshing activepropertylist
## will create a copy of activepropertylist 
## that we later use to analize what has changed
##################################################################
DROP PROCEDURE IF EXISTS sp_log_createcopy;
DELIMITER $$
CREATE PROCEDURE sp_log_createcopy()
BEGIN
DROP TABLE IF EXISTS oldactivepropertylist;
CREATE TABLE oldactivepropertylist LIKE eanprod.activepropertylist;
INSERT oldactivepropertylist SELECT * FROM eanprod.activepropertylist;
END 
$$
DELIMITER ;

##################################################################
## STEP 2 - add Added Records to log table
## must be called AFTER refreshing activepropertylist
## will classify as added / reactivated
##################################################################
DROP PROCEDURE IF EXISTS sp_log_addedrecords;
DELIMITER $$
CREATE PROCEDURE sp_log_addedrecords()
BEGIN
## save maximum EANHotelID from last run
## to identify if records are NEW ADDED or REACTIVATIONS
SELECT @max_eanid:=MAX(EANHotelID) FROM oldactivepropertylist;
#DECLARE mymaxid INT;
#SELECT MAX(EANHotelID)INTO mymaxid FROM oldactivepropertylist LIMIT 1,1;

## Identify Reactivated Records
## those that are NOT in the old-table
## 	EANHotelID,FieldName,FieldType,FieldValue,TimeStamp
INSERT INTO log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
SELECT NOW.EANHotelID,'EANHotelID' AS FieldName,'int' AS FieldType, NULL as FieldValueOld, 'reactivated record' as FieldValueNew
FROM oldactivepropertylist AS OLD
RIGHT JOIN activepropertylist AS NOW
ON OLD.EANHotelID=NOW.EANHotelID
WHERE OLD.EANHotelID IS NULL AND NOW.EANHotelID <= @max_eanid;

## Identify Newly Added Records
## those that are NOT in the old-table
## 	EANHotelID,FieldName,FieldType,FieldValue,TimeStamp
INSERT INTO log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
SELECT NOW.EANHotelID,'EANHotelID' AS FieldName,'int' AS FieldType, NULL as FieldValueOld, 'added record' as FieldValueNew
FROM oldactivepropertylist AS OLD
RIGHT JOIN activepropertylist AS NOW
ON OLD.EANHotelID=NOW.EANHotelID
WHERE OLD.EANHotelID IS NULL AND NOW.EANHotelID > @max_eanid;

END 
$$
DELIMITER ;

##################################################################
## STEP 3 - add Erased Records to log table
## must be called AFTER refreshing activepropertylist
##################################################################
DROP PROCEDURE IF EXISTS sp_log_erasedrecords;
DELIMITER $$
CREATE PROCEDURE sp_log_erasedrecords()
BEGIN
## Identify Deleted Records
## because they used to be in the old-table
## 	EANHotelID,FieldName,FieldType,FieldValue,TimeStamp
INSERT INTO log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
SELECT OLD.EANHotelID,'EANHotelID' AS FieldName,'int' AS FieldType, NULL as FieldValueOld, 'erased record' as FieldValueNew
FROM oldactivepropertylist AS OLD
LEFT JOIN activepropertylist AS NOW
ON OLD.EANHotelID=NOW.EANHotelID
WHERE NOW.EANHotelID IS NULL;
END 
$$
DELIMITER ;

##################################################################
## STEP 4 - Erase common records
## must be called AFTER refreshing activepropertylist
## will erase all records that are the same (based on an specific field list)
##################################################################
DROP PROCEDURE IF EXISTS sp_log_erase_common;
DELIMITER $$
CREATE PROCEDURE sp_log_erase_common()
BEGIN
DELETE oldactivepropertylist
FROM oldactivepropertylist
JOIN activepropertylist
USING (EANHotelID,Name,Address1,Address2,City,StateProvince,PostalCode,Country,
		Latitude,Longitude,AirportCode,PropertyCategory,PropertyCurrency,
		SupplierType,Location,ChainCodeID,CheckInTime,CheckOutTime);
END
$$
DELIMITER ;

##################################################################
## STEP 5 - Erase deleted records (after logging them)
## must be called AFTER refreshing activepropertylist, and sp_log_erasedrecords
## will erase all records in old-table
##################################################################
DROP PROCEDURE IF EXISTS sp_log_erase_deleted;
DELIMITER $$
CREATE PROCEDURE sp_log_erase_deleted()
BEGIN
DELETE oldactivepropertylist
FROM oldactivepropertylist
LEFT JOIN activepropertylist
ON oldactivepropertylist.EANHotelID=activepropertylist.EANHotelID
WHERE activepropertylist.EANHotelID IS NULL;
END
$$
DELIMITER ;

##################################################################
## STEP 6 - Work with the changed records
## must be called AFTER refreshing activepropertylist
## analize the changed data, looping thru the available records
##################################################################
DROP PROCEDURE IF EXISTS sp_log_changedrecords;
DELIMITER $$
CREATE PROCEDURE sp_log_changedrecords()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE oEANHotelID,oPropertyCategory INT;
  DECLARE oName VARCHAR(70);
  DECLARE oAddress1,oAddress2,oCity VARCHAR(50);
  DECLARE oStateProvince,oCountry VARCHAR(2);
  DECLARE oPostalCode VARCHAR(15);
  DECLARE oLatitude,oLongitude NUMERIC(8,5);
  DECLARE oAirportCode,oPropertyCurrency,oSupplierType VARCHAR(3);
  DECLARE oLocation VARCHAR(80);
  DECLARE oChainCodeID VARCHAR(5);
  DECLARE oCheckInTime,oCheckOutTime VARCHAR(10);
  
  DECLARE nEANHotelID,nPropertyCategory INT;
  DECLARE nName VARCHAR(70);
  DECLARE nAddress1,nAddress2,nCity VARCHAR(50);
  DECLARE nStateProvince,nCountry VARCHAR(2);
  DECLARE nPostalCode VARCHAR(15);
  DECLARE nLatitude,nLongitude NUMERIC(8,5);
  DECLARE nAirportCode,nPropertyCurrency,nSupplierType VARCHAR(3);
  DECLARE nLocation VARCHAR(80);
  DECLARE nChainCodeID VARCHAR(5);
  DECLARE nCheckInTime,nCheckOutTime VARCHAR(10);
  
  DECLARE cur CURSOR FOR SELECT o.EANHotelID,o.Name,o.Address1,o.Address2,o.City,o.StateProvince,o.PostalCode,o.Country,
		o.Latitude,o.Longitude,o.AirportCode,o.PropertyCategory,o.PropertyCurrency,
		o.SupplierType,o.Location,o.ChainCodeID,o.CheckInTime,o.CheckOutTime,
	    n.EANHotelID,n.Name,n.Address1,n.Address2,n.City,n.StateProvince,n.PostalCode,n.Country,
		n.Latitude,n.Longitude,n.AirportCode,n.PropertyCategory,n.PropertyCurrency,
		n.SupplierType,n.Location,n.ChainCodeID,n.CheckInTime,n.CheckOutTime FROM eanprod.oldactivepropertylist AS o
		LEFT JOIN activepropertylist AS n ON o.EANHotelID=n.EANHotelID;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur;
  read_loop: LOOP
    FETCH cur INTO oEANHotelID,oName,oAddress1,oAddress2,oCity,oStateProvince,oPostalCode,oCountry,
		oLatitude,oLongitude,oAirportCode,oPropertyCategory,oPropertyCurrency,
		oSupplierType,oLocation,oChainCodeID,oCheckInTime,oCheckOutTime,
    	nEANHotelID,nName,nAddress1,nAddress2,nCity,nStateProvince,nPostalCode,nCountry,
		nLatitude,nLongitude,nAirportCode,nPropertyCategory,nPropertyCurrency,
		nSupplierType,nLocation,nChainCodeID,nCheckInTime,nCheckOutTime;
    IF done THEN
      LEAVE read_loop;
    END IF;
    IF oName != nName THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew) 
      VALUES (nEANHotelID,'Name','VARCHAR(70)',oName,nName);
    END IF;
    IF oAddress1 != nAddress1 THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew) 
      VALUES (nEANHotelID,'Address1','VARCHAR(50)',oAddress1,nAddress1);
    END IF;
    IF oAddress2 != nAddress2 THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'Address2','VARCHAR(50)',oAddress2,nAddress2);
    END IF;
    IF oCity != nCity THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'City','VARCHAR(50)',oCity,nCity);
    END IF;
    IF oStateProvince != nStateProvince THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'StateProvince','VARCHAR(2)',oStateProvince,nStateProvince);
    END IF;
    IF oPostalCode != nPostalCode THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'PostalCode','VARCHAR(15)',oPostalCode,nPostalCode);
    END IF;
    IF oCountry != nCountry THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'Country','VARCHAR(2)',oCountry,nCountry);
    END IF;
    IF oLatitude != nLatitude THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'Latitude','NUMERIC(8,2)',oLatitude,nLatitude);
    END IF;
    IF oLongitude != nLongitude THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'Longitude','NUMERIC(8,2)',oLongitude,nLongitude);
    END IF;
    IF oAirportCode != nAirportCode THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'AirportCode','VARCHAR(3)',oAirportCode,nAirportCode);
    END IF;
    IF oPropertyCategory != nPropertyCategory THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'PropertyCategory','INT',oPropertyCategory,nPropertyCategory);
    END IF;
    IF oPropertyCurrency != nPropertyCurrency THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'PropertyCurrency','VARCHAR(3)',oPropertyCurrency,nPropertyCurrency);
    END IF;
    IF oSupplierType != nSupplierType THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'SupplierType','VARCHAR(3)',oSupplierType,nSupplierType);
    END IF;
    IF oLocation != nLocation THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'Location','VARCHAR(80)',oLocation,nLocation);
    END IF; 
    IF oChainCodeID != nChainCodeID THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'ChainCodeID','VARCHAR(5)',oChainCodeID,nChainCodeID);
    END IF;
    IF oCheckInTime != nCheckInTime THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'CheckInTime','VARCHAR(10)',oCheckInTime,nCheckInTime);
    END IF;
    IF oCheckOutTime != nCheckOutTime THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'CheckOutTime','VARCHAR(10)',oCheckOutTime,nCheckOutTime);
    END IF;

  END LOOP;
  CLOSE cur;
END
$$
DELIMITER ;


##################################################################
## LEVENSHTEIN Formula - calculate the amt. of characters that diff
## from 2 given strings
## EXAMPLE
## usage: WHERE (LEVENSHTEIN(a.name, b.name) <= 2)
##
DROP FUNCTION IF EXISTS LEVENSHTEIN;
DELIMITER $$
CREATE FUNCTION LEVENSHTEIN (s1 VARCHAR(255), s2 VARCHAR(255))
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE s1_len, s2_len, i, j, c, c_temp, cost INT;
  DECLARE s1_char CHAR;
  DECLARE cv0, cv1 VARBINARY(256);
  SET s1_len = CHAR_LENGTH(s1), s2_len = CHAR_LENGTH(s2), cv1 = 0x00, j = 1, i = 1, c = 0;
  IF s1 = s2 THEN
    RETURN 0;
  ELSEIF s1_len = 0 THEN
    RETURN s2_len;
  ELSEIF s2_len = 0 THEN
    RETURN s1_len;
  ELSE
    WHILE j <= s2_len DO
      SET cv1 = CONCAT(cv1, UNHEX(HEX(j))), j = j + 1;
    END WHILE;
    WHILE i <= s1_len DO
      SET s1_char = SUBSTRING(s1, i, 1), c = i, cv0 = UNHEX(HEX(i)), j = 1;
      WHILE j <= s2_len DO
        SET c = c + 1;
        IF s1_char = SUBSTRING(s2, j, 1) THEN SET cost = 0; ELSE SET cost = 1; END IF;
        SET c_temp = CONV(HEX(SUBSTRING(cv1, j, 1)), 16, 10) + cost;
        IF c > c_temp THEN SET c = c_temp; END IF;
        SET c_temp = CONV(HEX(SUBSTRING(cv1, j+1, 1)), 16, 10) + 1;
        IF c > c_temp THEN SET c = c_temp; END IF;
        SET cv0 = CONCAT(cv0, UNHEX(HEX(c))), j = j + 1;
      END WHILE;
      SET cv1 = cv0, i = i + 1;
    END WHILE;
  END IF;
  RETURN c;
END 
$$
DELIMITER ;
