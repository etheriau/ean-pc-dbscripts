########################################################
## EAN Extras - additional custom tables & examples   ##
## SCRIPT TO GENERATE EAN DATABASE IN MYSQL ENGINE    ##
## BE CAREFUL AS IT WILL ERASE THE EXISTING DATABASE  ##
## YOU CAN USE SECTIONS OF IT TO RE-CREATE TABLES     ##
## WILL CREATE USER: eanuser / expedia                ##
## table names are lowercase so it will work  in all  ## 
## platforms the same.                                ##
########################################################

DROP DATABASE IF EXISTS eanextras;
## specify utf8 / ut8_unicode_ci to manage all languages properly
## updated from files contain those characters
CREATE DATABASE eanextras CHARACTER SET utf8 COLLATE utf8_unicode_ci;

## users permisions
GRANT ALL ON eanextras.* TO 'eanuser'@'%' IDENTIFIED BY 'Passw@rd1';
GRANT ALL ON eanextras.* TO 'eanuser'@'localhost' IDENTIFIED BY 'Passw@rd1';

## REQUIRED IN WINDOWS as we do not use STRICT_TRANS_TABLE for the upload process
SET @@global.sql_mode= '';

USE eanextras;


########################################################
##                                                    ##
## TABLES & STORED PROCEDURES CREATED TO ENHANCE THE  ##
## SYSTEM FUNCTIONALITY                               ##
##                                                    ##
########################################################

########################################################
## Full Text Search
## We keep it as a separate table for efficiency
## as we move this table to RAM for faster processing
## DEFINITION:
## Name - fast text search name to use
## SearchBy - what to pass to the API for searching (Name,GPS,HotelID)
## Type - 1=Cities, 2=Landmarks, 3=Airports, 4=HotelId
## GPS are comma separated (123.434336,-54443.767445)
DROP TABLE IF EXISTS fasttextsearch;
CREATE TABLE fasttextsearch
(
	Name VARCHAR(510),
	SearchBy VARCHAR(510),
	Type CHAR(1),
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = MYISAM CHARACTER SET utf8 COLLATE utf8_unicode_ci;

CREATE FULLTEXT INDEX ft_name ON fasttextsearch(Name);


##################################################################
## STORED PROCEDURE fill_fasttextsearch
##
## to be called after the database refresh process ends

DROP PROCEDURE IF EXISTS sp_fill_fasttextsearch;
DELIMITER $$
CREATE PROCEDURE sp_fill_fasttextsearch()
BEGIN
 TRUNCATE TABLE fasttextsearch;
## TYPE 'C'=Cities
## short down 'United States of America' for 'USA'
 	INSERT INTO fasttextsearch (Name, SearchBy, Type) 
  	SELECT REPLACE(RegionName,'United States of America', 'USA') AS Name, RegionName AS SearchBy, 'C' AS Type 
  	FROM eanprod.citycoordinateslist;


## TYPE 'A'=Airport
	INSERT INTO fasttextsearch (Name, SearchBy, Type)
	SELECT AirportName AS Name, IF(LOCATE('(',RegionNameLong)>0,
		CONCAT(LEFT(RegionNameLong,LOCATE('(',RegionNameLong)-2),RIGHT(RegionNameLong,LENGTH(RegionNameLong)-LOCATE(')',RegionNameLong))),
		RegionNameLong) AS SearchBy,  'A' AS Type
	FROM eanprod.airportcoordinateslist
	JOIN eanprod.parentregionlist
	ON eanprod.airportcoordinateslist.MainCityID = eanprod.parentregionlist.RegionID;

## TYPE 'L'=Landmarks  
INSERT INTO fasttextsearch (Name, SearchBy, Type) 
  SELECT RegionNameLong AS Name, CONCAT(Latitude, "," , Longitude) AS SearchBy, 'L' AS Type 
  FROM eanprod.pointsofinterestcoordinateslist;

## TYPE 'P'=HotelID
 INSERT INTO fasttextsearch (Name, SearchBy, Type) 
  SELECT Name, EANHotelID AS SearchBy,'P' AS Type FROM eanprod.activepropertylist;

END
$$
DELIMITER ;

## using the World eanextras.airports
## if you filter to only include type_large and _medium, result set is similar to EAN
##INSERT INTO fasttextsearch (Name, SearchBy, Type) 
##  SELECT AirportName AS Name, CONCAT(Latitude, "," , Longitude) AS SearchBy, "3" AS Type FROM eanextras.airports where AirportType = 'large_airport' or AirportType = 'medium_airport';

########################################################
## airports
## This data comes from http://www.ourairports.com/data/
## using the file: airports.csv
## it is about 25K records long
## This file could be joined to the regular EAN Airports
## using the IATACode file, the normal 3x letters code
## 
## This table include Small, Medium and Large Airports
## it includes the ISO Country, Region and also Municipality
DROP TABLE IF EXISTS airports;
CREATE TABLE airports
(
	ID INT,
	AirportCode VARCHAR(10) NOT NULL,
	AirportType VARCHAR(14),
	AirportName VARCHAR(80),
	Latitude NUMERIC(9,6),
	Longitude NUMERIC(9,6),
	Elevation INT,
	ContinentCode VARCHAR(2),
	ISOCountry VARCHAR(2),
	ISORegion VARCHAR(8),
	Municipality VARCHAR(65),
	ScheduledService VARCHAR(3),
	GPSCode VARCHAR(10),
	IATACode VARCHAR(3),
	LocalCode VARCHAR(10),
	HomeLink VARCHAR(128),
	WikipediaLink VARCHAR(128),
	Keywords VARCHAR(255),
    TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (AirportCode)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;

## index by Latitude, Longitude to use for geosearches
CREATE INDEX ourairportscoordinate_geoloc ON airports(Latitude, Longitude);

##################################################################
##this Stored Procedure will use the Airport table to find the closest Airport code
## use like: CALL sp_airport_from_point(40.451585,-3.690375,'ES');
## if you need more results just change the LIMIT number or create a parameter for it
## NO Heliport or Train Stations Included
##################################################################
DROP PROCEDURE IF EXISTS sp_airport_from_ourairports;
DELIMITER $$
CREATE PROCEDURE sp_airport_from_ourairports(IN lat double,lon double,countrycode VARCHAR(2),maxrec INT)
BEGIN
SET @s = CONCAT('SELECT IATACode,AirportName,ISOCountry,Latitude,Longitude,',
                ' round( sqrt((POW(a.Latitude-',lat,',2)*68.1*68.1)+(POW(a.Longitude-',lon,',2)*53.1* 53.1))) AS distance', 
				' FROM eanextras.airports AS a ',
				' WHERE ISOCountry=','\'',countrycode,'\'',' AND AirportType=\'large_airport\' AND IATACode<>\'\' AND ScheduledService=\'yes\'',
                ' ORDER BY distance ASC LIMIT ',maxrec,';');
PREPARE stmt1 FROM @s; 
EXECUTE stmt1; 
DEALLOCATE PREPARE stmt1;
END 
$$
DELIMITER ;

## ISO list of Countries
DROP TABLE IF EXISTS countries;
CREATE TABLE countries
(
	ID INT,
	CountryCode VARCHAR(2) NOT NULL,
	CountryName VARCHAR(50),
	ContinentCode VARCHAR(2),
	WikipediaLink VARCHAR(128),
	Keywords VARCHAR(255),
    TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (CountryCode)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;


DROP TABLE IF EXISTS regions;
CREATE TABLE regions
(
	ID INT,
	RegionCode VARCHAR(8) NOT NULL,
	RegionLocalCode VARCHAR(4),
	RegionName VARCHAR(50),
	ContinentCode VARCHAR(2),
	ISOCountry VARCHAR(2),
	WikipediaLink VARCHAR(128),
	Keywords VARCHAR(255),
    TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (RegionCode)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;


## New ChainList Link table that will include the info for GDS and EEM (Venere) types
## it is created by running the stored procedure: 
DROP TABLE IF EXISTS chainlistlink;
CREATE TABLE chainlistlink (
  EANHotelID int(11) NOT NULL,
  ChainCodeID int(11) NOT NULL,
  TimeStamp timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (EANHotelID)
) CHARACTER SET utf8 COLLATE=utf8_unicode_ci;

##########################################################################
## Airport Data from: http://openflights.org/data.html#airport
##########################################################################
## Airport ID 	Unique OpenFlights identifier for this airport.
## Name 	Name of airport. May or may not contain the City name.
## City 	Main city served by airport. May be spelled differently from Name.
## Country 	Country or territory where airport is located.
## IATA/FAA 	3-letter FAA code, for airports located in Country "United States of America".
## 3-letter IATA code, for all other airports. Blank if not assigned.
## ICAO 	4-letter ICAO code. Blank if not assigned.
## Latitude 	Decimal degrees, usually to six significant digits. Negative is South, positive is North.
## Longitude 	Decimal degrees, usually to six significant digits. Negative is West, positive is East.
## Altitude 	In feet.
## Timezone 	Hours offset from UTC. Fractional hours are expressed as decimals, eg. India is 5.5.
## DST 	Daylight savings time. One of E (Europe), A (US/Canada), S (South America), O (Australia), Z (New Zealand), N (None) or U (Unknown). See also: Help: Time
## The data is ISO 8859-1 (Latin-1) encoded, with no special characters

DROP TABLE IF EXISTS openflightsairports;
CREATE TABLE openflightsairports
(
	AirportID INT NOT NULL,
	Name VARCHAR(80),
	City VARCHAR(80),
    Country VARCHAR(80),
    IATA VARCHAR(3),
	ICAO VARCHAR(4),
	Latitude NUMERIC(9,6),
	Longitude NUMERIC(9,6),
	Altitude INT,
	Timezone VARCHAR(20),
	DST VARCHAR(20),
    TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (AirportID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;


##################################################################
## STORED PROCEDURE fill_chainlistlink
##
## to be called after the database refresh process ends
## is just EMPTY THE TABLE, copy the info from chainlist and
## create new entries for EEM and GDS properties

DROP PROCEDURE IF EXISTS sp_fill_chainlistlink;
DELIMITER $$
CREATE PROCEDURE sp_fill_chainlistlink()
BEGIN
 TRUNCATE TABLE chainlistlink;
## insert the ones we allready got
 INSERT INTO chainlistlink (EANHotelID, ChainCodeID) 
	SELECT EANHotelID, ChainCodeID FROM eanprod.activepropertylist 
	WHERE TRIM(IFNULL(ChainCodeID,''));
 INSERT INTO chainlistlink (EANHotelID, ChainCodeID) 
	SELECT activepropertylist.EANHotelID, chainlist.ChainCodeID
	FROM eanprod.activepropertylist 
	INNER JOIN eanprod.chainlist ON CONCAT(' ',LOWER(activepropertylist.Name),' ')
	LIKE BINARY CONCAT('% ',LOWER(eanprod.chainlist.ChainName),' %')
	WHERE (TRIM(IFNULL(activepropertylist.ChainCodeID,'')) = '')
	GROUP BY EANHotelID;
END
$$
DELIMITER ;

############################################################
## STATIC CONTENT FILES
## All Properties (Venere, Expedia, Vacation Rentals) 
############################################################
DROP TABLE IF EXISTS expediaactive;
CREATE TABLE expediaactive (
HotelID INT NOT NULL,
Name VARCHAR(70),
AirportCode VARCHAR(3),
Address1 VARCHAR(50),
Address2 VARCHAR(50),
Address3 VARCHAR(50),
City VARCHAR(50),
StateProvince VARCHAR(50),
Country VARCHAR(50),
PostalCode VARCHAR(15),
Longitude NUMERIC(8,5),
Latitude NUMERIC(8,5),
LowRate NUMERIC(19,4),
HighRate NUMERIC(19,4),
MarketingLevel INT,
Confidence INT,
HotelModified varchar(32),
PropertyType VARCHAR(3),
TimeZone VARCHAR(80),
GMTOffset VARCHAR(6),
YearPropertyOpened varchar(256),
YearPropertyRenovated varchar(256),
NativeCurrency varchar(3),
NumberOfRooms int,
NumberOfSuites int,
NumberOfFloors int,
CheckInTime varchar(10),
CheckOutTime varchar(10),
HasValetParking varchar(1),
HasContinentalBreakfast varchar(1),
HasInRoomMovies varchar(1),
HasSauna varchar(1),
HasWhirlpool varchar(1),
HasVoiceMail varchar(1),
Has24HourSecurity varchar(1),
HasParkingGarage varchar(1),
HasElectronicRoomKeys varchar(1),
HasCoffeeTeaMaker varchar(1),
HasSafe varchar(1),
HasVideoCheckOut varchar(1),
HasRestrictedAccess varchar(1),
HasInteriorRoomEntrance varchar(1),
HasExteriorRoomEntrance varchar(1),
HasCombination varchar(1),
HasFitnessFacility varchar(1),
HasGameRoom varchar(1),
HasTennisCourt varchar(1),
HasGolfCourse varchar(1),
HasInHouseDining varchar(1),
HasInHouseBar varchar(1),
HasHandicapAccessible varchar(1),
HasChildrenAllowed varchar(1),
HasPetsAllowed varchar(1),
HasTVInRoom varchar(1),
HasDataPorts varchar(1),
HasMeetingRooms varchar(1),
HasBusinessCenter varchar(1),
HasDryCleaning varchar(1),
HasIndoorPool varchar(1),
HasOutdoorPool varchar(1),
HasNonSmokingRooms varchar(1),
HasAirportTransportation varchar(1),
HasAirConditioning varchar(1),
HasClothingIron varchar(1),
HasWakeUpService varchar(1),
HasMiniBarInRoom varchar(1),
HasRoomService varchar(1),
HasHairDryer varchar(1),
HasCarRentDesk varchar(1),
HasFamilyRooms varchar(1),
HasKitchen varchar(1),
HasMap varchar(1),
PropertyDescription TEXT,
GDSChainCode  varchar(10),
GDSChaincodeName  varchar(70),
DestinationID varchar(60),
DrivingDirections TEXT,
NearbyAttractions TEXT,
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (HotelID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;

DROP TABLE IF EXISTS vacationrentalsactive;
CREATE TABLE vacationrentalsactive (
HotelID INT NOT NULL,
Name VARCHAR(70),
AirportCode VARCHAR(3),
Address1 VARCHAR(50),
Address2 VARCHAR(50),
Address3 VARCHAR(50),
City VARCHAR(50),
StateProvince VARCHAR(50),
Country VARCHAR(50),
PostalCode VARCHAR(15),
Longitude NUMERIC(8,5),
Latitude NUMERIC(8,5),
LowRate NUMERIC(19,4),
HighRate NUMERIC(19,4),
MarketingLevel INT,
Confidence INT,
HotelModified varchar(32),
PropertyType VARCHAR(3),
TimeZone VARCHAR(80),
GMTOffset VARCHAR(6),
YearPropertyOpened varchar(256),
YearPropertyRenovated varchar(256),
NativeCurrency varchar(3),
NumberOfRooms int,
NumberOfSuites int,
NumberOfFloors int,
CheckInTime varchar(10),
CheckOutTime varchar(10),
HasValetParking varchar(1),
HasContinentalBreakfast varchar(1),
HasInRoomMovies varchar(1),
HasSauna varchar(1),
HasWhirlpool varchar(1),
HasVoiceMail varchar(1),
Has24HourSecurity varchar(1),
HasParkingGarage varchar(1),
HasElectronicRoomKeys varchar(1),
HasCoffeeTeaMaker varchar(1),
HasSafe varchar(1),
HasVideoCheckOut varchar(1),
HasRestrictedAccess varchar(1),
HasInteriorRoomEntrance varchar(1),
HasExteriorRoomEntrance varchar(1),
HasCombination varchar(1),
HasFitnessFacility varchar(1),
HasGameRoom varchar(1),
HasTennisCourt varchar(1),
HasGolfCourse varchar(1),
HasInHouseDining varchar(1),
HasInHouseBar varchar(1),
HasHandicapAccessible varchar(1),
HasChildrenAllowed varchar(1),
HasPetsAllowed varchar(1),
HasTVInRoom varchar(1),
HasDataPorts varchar(1),
HasMeetingRooms varchar(1),
HasBusinessCenter varchar(1),
HasDryCleaning varchar(1),
HasIndoorPool varchar(1),
HasOutdoorPool varchar(1),
HasNonSmokingRooms varchar(1),
HasAirportTransportation varchar(1),
HasAirConditioning varchar(1),
HasClothingIron varchar(1),
HasWakeUpService varchar(1),
HasMiniBarInRoom varchar(1),
HasRoomService varchar(1),
HasHairDryer varchar(1),
HasCarRentDesk varchar(1),
HasFamilyRooms varchar(1),
HasKitchen varchar(1),
HasMap varchar(1),
PropertyDescription TEXT,
GDSChainCode  varchar(10),
GDSChaincodeName  varchar(70),
DestinationID varchar(60),
DrivingDirections TEXT,
NearbyAttractions TEXT,
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (HotelID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;



#########################
### EAN Special Files ###
#########################
## file based in the file: Destination IDs
DROP TABLE IF EXISTS destinationids;
CREATE TABLE destinationids
(
Destination 	varchar(280),
DestinationID 	varchar(50) NOT NULL,
CenterLongitude numeric(12,8),
CenterLatitude 	numeric(12,8),
StateProvince 	varchar(2),
Country 	    varchar(3),
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (DestinationID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;

DROP TABLE IF EXISTS landmark;
CREATE TABLE landmark
(
DestinationID 	varchar(50) NOT NULL,
Name			varchar(280),
City			varchar(4000),
StateProvince 	varchar(2),
Country			varchar(3),
CenterLatitude 	numeric(12,8),
CenterLongitude numeric(12,8),
Type 	    	int,
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (DestinationID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;

## file based in the file: Property ID Cross Reference
DROP TABLE IF EXISTS propertyidcrossreference;
CREATE TABLE propertyidcrossreference
(
	ExpediaID INT NOT NULL,
	AirportCodes VARCHAR(50),
	EANHotelID INT NOT NULL,
	Hotel_Name VARCHAR(70),
	City VARCHAR(50),
	StateProvince VARCHAR(2),
	Country VARCHAR(2),
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (EANHotelID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;
## index by Expedia Property ID to use for reverse searches
CREATE INDEX idx_expediaid ON propertyidcrossreference(ExpediaID);

## file based in the file: PropertySupplierMapping
## Supplier Type is the same as in activepropertylist
##  2: Expedia Collect hotels
##  3: Sabre hotels
##  9: Expedia Collect condos
## 10: Worldspan hotels 
## 13: Expedia.com properties
## 14: Venere.com properties
DROP TABLE IF EXISTS propertysuppliermapping;
CREATE TABLE propertysuppliermapping
(
	EANPropertyID INT NOT NULL,
	SupplierPropertyID VARCHAR(20),
	StatusCode VARCHAR(1),
    SupplierID INT NOT NULL,
    TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
#    PRIMARY KEY (EANPropertyID,SupplierID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;
## index by Supplier Property ID to use for reverse searches
CREATE INDEX idx_eanpropertyid ON propertysuppliermapping(EANPropertyID);
CREATE INDEX idx_supplierpropertyid ON propertysuppliermapping(SupplierPropertyID);

# table to store the allCountries.txt file from http://download.geonames.org/export/dump/
# will be best to run once with allCountries, then just apply the daily updates
DROP TABLE IF EXISTS geonames;
CREATE TABLE geonames
(
GeoNameID INT NOT NULL,
Name VARCHAR(200),
AsciiName VARCHAR(200),
AlternateNames TEXT,
Latitude numeric(9,6),
Longitude numeric(9,6),
FeatureClass char(1),
FeatureCode varchar(10),
CountryCode  char(2),
AlternativeCountryCode varchar(60),
AdminCode1 varchar(20),
AdminCode2 varchar(80), 
AdminCode3 varchar(20),
AdminCode4 varchar(20),
Population BIGINT,
Elevation INT,
Dem INT,
Timezone varchar(40),
ModificationDate date,
TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (GeoNameID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;
## index by Latitude, Longitude to use for geosearches
## we add the FeatureCode to the index to spped up filtered searches
CREATE INDEX geonames_geoloc ON geonames(Latitude, Longitude,FeatureCode);
## index to speed the usual search by name,country filtered by FeatureClass and code
CREATE INDEX geonames_fastasciiname ON geonames(AsciiName, CountryCode, FeatureClass, FeatureCode);

##################################################################
## search what is close to a GPSPoint using Geonames table content
## EXAMPLE IS: 286020 – Carin Hotel (London) GPSPoint ( 51.51274,-0.18305)
## call sp_geonames_from_point(51.51274,-0.18305,1);
##################################################################
DROP PROCEDURE IF EXISTS sp_geonames_from_point;
DELIMITER $$
CREATE PROCEDURE sp_geonames_from_point(IN lat double,lon double, maxdist int)
BEGIN
SELECT GeoNameID,AsciiName,Name,CountryCode,FeatureClass,FeatureCode,AdminCode1,AdminCode2,AdminCode3,AdminCode4,Latitude,Longitude,
# this calculate the distance from the given longitude, latitude
    round( sqrt( 
        (POW(a.Latitude - lat, 2)* 68.1 * 68.1) + 
        (POW(a.Longitude - lon, 2) * 53.1 * 53.1) 
     )) AS distance
FROM geonames AS a 
WHERE 1=1
HAVING distance < maxdist
ORDER BY distance ASC;
# to use LIMIT you need to use a prepared statement to avoid errors
END 
$$
DELIMITER ;

##################################################################
##this version will allow you to restrict the results:
##only return Specific FeatureCode
## http://www.geonames.org/export/codes.html
##################################################################
DROP PROCEDURE IF EXISTS sp_geonames_from_point_featcode;
DELIMITER $$
CREATE PROCEDURE sp_geonames_from_point_featcode(IN lat double,lon double, maxdist int, featcode varchar(60))
BEGIN
SET @s = CONCAT('SELECT GeoNameID,AsciiName,Name,CountryCode,FeatureClass,FeatureCode,AdminCode1,AdminCode2,AdminCode3,AdminCode4,Latitude,Longitude,',
		' sqrt((POW(a.Latitude-',lat,',2)*68.1*68.1)+', 
		'(POW(a.Longitude-',lon,',2)*53.1*53.1)) AS distance',
		' FROM geonames as a WHERE FeatureCode=\'',featcode,
		'\' HAVING distance < ',maxdist,
		' ORDER BY distance ASC;');
Select @s;
PREPARE stmt1 FROM @s; 
EXECUTE stmt1; 
DEALLOCATE PREPARE stmt1;
END 
$$
DELIMITER ;


####################################################################
## table to keep track of cloud update process
## loggign the EANHotelIDs and the record type
####################################################################
DROP TABLE IF EXISTS cloudupdateslog;
CREATE TABLE cloudupdateslog (
EANHotelID INT NOT NULL,
DocType varchar(20),
Locale varchar(5),
TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;
## index
CREATE INDEX cloudupdates_log ON cloudupdateslog(TimeStamp, EANHotelID, DocType, Locale);

#######################################################################
## process to discover Venere Airport codes
## creating a new link table
## and using the stored procedure to search the closest airport code
#######################################################################

DROP TABLE IF EXISTS venere_airports;
CREATE TABLE venere_airports (
EANHotelID INT NOT NULL,
AirportCode varchar(3),
Distance INT,
TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
PRIMARY KEY (EANHotelID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;

DROP PROCEDURE IF EXISTS sp_find_venere_airports;
DELIMITER $$
CREATE PROCEDURE sp_find_venere_airports()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE cEANHotelID INT;
  DECLARE cAirportCode VARCHAR(3);
  DECLARE cCountryCode VARCHAR(2);
  DECLARE cLatitude,cLongitude NUMERIC(8,5);
    DECLARE cur CURSOR FOR SELECT EANHotelID,Latitude,Longitude,Country FROM eanprod.activepropertylist WHERE SupplierType='EEM' LIMIT 10;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  OPEN cur;
  read_loop: LOOP
    FETCH cur INTO cEANHotelID,cLatitude,cLongitude,cCountryCode;
    IF done THEN
      LEAVE read_loop;
    END IF;
   SET @s = CONCAT('INSERT INTO eanextras.venere_airports (EANHotelID,AirportCode,Distance) ',
            'VALUES (SELECT ',cEANHotelID,' as EANHotelID,AirportCode,',
                ' round( sqrt((POW(a.Latitude-',cLatitude,',2)*68.1*68.1)+(POW(a.Longitude-',cLongitude,',2)*53.1* 53.1))) AS distance', 
				 ' FROM eanprod.airportcoordinateslist AS a ',
				 ' WHERE CountryCode=','\'',cCountryCode,'\'',
                ' ORDER BY distance ASC LIMIT 2);');
	PREPARE stmt1 FROM @s; 
	EXECUTE stmt1; 
	DEALLOCATE PREPARE stmt1;
  END LOOP;
  CLOSE cur;
END
$$
DELIMITER ;
