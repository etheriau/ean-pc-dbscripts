/*
*********************************************************
** MSSQL_create_eanprod.sql                     v2.8   **
** SCRIPT TO GENERATE EAN DATABASE IN Microsoft SQL    **
** BE CAREFUL AS IT WILL ERASE THE EXISTING DATABASE   **
** YOU CAN USE SECTIONS OF IT TO RE-CREATE TABLES      **
** WILL CREATE USER: eanuser                           **
** table names are lowercase so it will work for all   **
** platforms the same.                                 **
*********************************************************
*/
USE master;
GO
IF EXISTS(SELECT * FROM sys.databases WHERE NAME='eanprod')
BEGIN
   DROP DATABASE eanprod;
END
GO

/*
************************************************************
** MS-SQL can use SQL Server collation/Windows collations **
** specify the collation to manage your language properly **
** http://msdn.microsoft.com/en-us/library/ms180175.aspx  **
** CP1 specifies code page 1252                           **
** CI specifies case-insensitive, CS specifies            **
** case-sensitive AI specifies accent-insensitive,        **
** AS specifies accent-sensitive                          **
** To use UTF-16 collations available in SQL Server 2012, **
** append the suffix _SC to any of these collations       **
************************************************************
*/
CREATE DATABASE eanprod COLLATE SQL_Latin1_General_CP1_CS_AS;
GO
USE eanprod;
GO

-- users permisions / server principals
IF NOT EXISTS(SELECT name FROM sys.server_principals WHERE name = 'eanuser')
BEGIN
   CREATE LOGIN eanuser WITH PASSWORD = 'Passw@rd1';
END

-- add the 'bulkadmin' role so it can executes the BULK INSERT statement
-- 'bulkadmin' is a Server Role
EXEC sp_addsrvrolemember 'eanuser','bulkadmin'
GO

-- users permisions / database level 
USE eanprod;
GO
IF NOT EXISTS(SELECT name FROM sys.database_principals WHERE name = 'eanuser')
BEGIN
   CREATE USER eanuser FOR LOGIN eanuser;
END
GO

-- enable OPENROWSET and OPENDATASOURCE
sp_configure 'show advanced options', 1
RECONFIGURE
GO
sp_configure 'Ad Hoc Distributed Queries', 1
RECONFIGURE
GO
 
/*
********************************************************
** TABLES CREATED FROM THE EAN RELATIONAL DOWNLOADED  **
** FILES.                                             **
**                                                    **
********************************************************
*/
-- use dbo.sysobjects for SQL 2000
if exists (select * from sys.objects where name = 'airportcoordinateslist' and type = 'u')
    drop table airportcoordinateslist
GO
CREATE TABLE airportcoordinateslist
(
	AirportID INT NOT NULL,
	AirportCode NCHAR(3) NOT NULL,
	AirportName NVARCHAR(70),
	Latitude NUMERIC(9,6),
	Longitude NUMERIC(9,6),
	MainCityID INT,
	CountryCode NCHAR(2),
    TimeStamp rowversion,
	PRIMARY KEY (AirportCode)
) 
GO

-- index by Airport Name to use for text searches
CREATE INDEX idx_airportcoordinatelist_airportname ON airportcoordinateslist(AirportName);
-- index by MainCityID to use as relational key
CREATE INDEX idx_airportcoordinatelist_maincityid ON airportcoordinateslist(MainCityID);

if exists (select * from sys.objects where name = 'activepropertylist' and type = 'u')
   drop table activepropertylist
GO
CREATE TABLE activepropertylist
(
	EANHotelID INT NOT NULL,
	SequenceNumber INT,
	Name NVARCHAR(70),
	Address1 NVARCHAR(50),
	Address2 NVARCHAR(50),
	City NVARCHAR(50),
	StateProvince NCHAR(2),
	PostalCode NVARCHAR(15),
	Country NCHAR(2),
	Latitude numeric(8,5),
	Longitude numeric(8,5),
	AirportCode NCHAR(3),
	PropertyCategory INT,
	PropertyCurrency NCHAR(3),
	StarRating numeric(2,1),
	Confidence INT,
	SupplierType NCHAR(3),
	Location NVARCHAR(80),
	ChainCodeID NCHAR(5),
	RegionID INT,
	HighRate numeric(19,4),
	LowRate numeric(19,4),
	CheckInTime NCHAR(10),
	CheckOutTime NCHAR(10),
    TimeStamp rowversion,
	PRIMARY KEY (EANHotelID)
)
GO

if exists (select * from sys.objects where name = 'pointsofinterestcoordinateslist' and type = 'u')
   drop table pointsofinterestcoordinateslist;
GO
CREATE TABLE pointsofinterestcoordinateslist
(
	RegionID INT NOT NULL,
	RegionName NVARCHAR(255), 
	RegionNameLong NVARCHAR(191),
	Latitude numeric(9,6),
	Longitude numeric(9,6),
	SubClassification NVARCHAR(20),
    TimeStamp rowversion,
	PRIMARY KEY (RegionNameLong)
)
GO

-- index by RegionID to use as relational key
CREATE INDEX idx_pointsofinterestcoordinateslist_regionid ON pointsofinterestcoordinateslist(RegionID);
GO

-- use dbo.sysobjects for SQL 2000
if exists (select * from sys.objects where name = 'countrylist' and type = 'u')
    drop table countrylist
GO
CREATE TABLE countrylist
(
	CountryID INT NOT NULL,
	LanguageCode NVARCHAR(5),
	CountryName NVARCHAR(256),
	CountryCode NVARCHAR(2) NOT NULL,
	Transliteration NVARCHAR(256),
	ContinentID INT,
    TimeStamp rowversion,
	PRIMARY KEY (CountryID)
)
GO
-- add indexes by country code & country name
CREATE INDEX idx_countrylist_countrycode ON countrylist(CountryCode);
GO
CREATE INDEX idx_countrylist_countryname ON countrylist(CountryName);
GO

-- use dbo.sysobjects for SQL 2000
if exists (select * from sys.objects where name = 'propertytypelist' and type = 'u')
    drop table propertytypelist
GO
CREATE TABLE propertytypelist
(
	PropertyCategory INT NOT NULL,
	LanguageCode NVARCHAR(5),
	PropertyCategoryDesc NVARCHAR(256),
    TimeStamp rowversion,
	PRIMARY KEY (PropertyCategory)
)
GO

-- use dbo.sysobjects for SQL 2000
if exists (select * from sys.objects where name = 'chainlist' and type = 'u')
    drop table chainlist
GO
CREATE TABLE chainlist
(
	ChainCodeID INT NOT NULL,
	ChainName NVARCHAR(30),
    TimeStamp rowversion,
	PRIMARY KEY (ChainCodeID)
) 
GO



-- use dbo.sysobjects for SQL 2000
if exists (select * from sys.objects where name = 'propertydescriptionlist' and type = 'u')
    drop table propertydescriptionlist
GO
CREATE TABLE propertydescriptionlist
(
	EANHotelID INT NOT NULL,
	LanguageCode NVARCHAR(5),
	PropertyDescription NVARCHAR(4000),
    TimeStamp rowversion,
	PRIMARY KEY (EANHotelID)
) 
GO


-- use dbo.sysobjects for SQL 2000
if exists (select * from sys.objects where name = 'policydescriptionlist' and type = 'u')
    drop table policydescriptionlist
GO
CREATE TABLE policydescriptionlist
(
	EANHotelID INT NOT NULL,
	LanguageCode NVARCHAR(5),
	PolicyDescription NVARCHAR(4000),
    TimeStamp rowversion,
	PRIMARY KEY (EANHotelID)
)
GO


-- use dbo.sysobjects for SQL 2000
if exists (select * from sys.objects where name = 'recreationdescriptionlist' and type = 'u')
    drop table recreationdescriptionlist
GO
CREATE TABLE recreationdescriptionlist
(
	EANHotelID INT NOT NULL,
	LanguageCode NVARCHAR(5),
	RecreationDescription NVARCHAR(4000),
    TimeStamp rowversion,
	PRIMARY KEY (EANHotelID)
)
GO


-- use dbo.sysobjects for SQL 2000
if exists (select * from sys.objects where name = 'areaattractionslist' and type = 'u')
    drop table areaattractionslist
GO
CREATE TABLE areaattractionslist
(
	EANHotelID INT NOT NULL,
	LanguageCode NVARCHAR(5),
	AreaAttractions NVARCHAR(4000),
    TimeStamp rowversion,
	PRIMARY KEY (EANHotelID)
)
GO


-- use dbo.sysobjects for SQL 2000
if exists (select * from sys.objects where name = 'diningdescriptionlist' and type = 'u')
    drop table diningdescriptionlist
GO
CREATE TABLE diningdescriptionlist
(
	EANHotelID INT NOT NULL,
	LanguageCode NVARCHAR(5),
	DiningDescription NVARCHAR(4000),
    TimeStamp rowversion,
	PRIMARY KEY (EANHotelID)
)
GO

-- use dbo.sysobjects for SQL 2000
if exists (select * from sys.objects where name = 'spadescriptionlist' and type = 'u')
    drop table spadescriptionlist
GO
CREATE TABLE spadescriptionlist
(
	EANHotelID INT NOT NULL,
	LanguageCode NVARCHAR(5),
	SpaDescription NVARCHAR(4000),
    TimeStamp rowversion,
	PRIMARY KEY (EANHotelID)
)
GO


-- use dbo.sysobjects for SQL 2000
if exists (select * from sys.objects where name = 'whattoexpectlist' and type = 'u')
    drop table whattoexpectlist
GO
CREATE TABLE whattoexpectlist
(
	EANHotelID INT NOT NULL,
	LanguageCode NVARCHAR(5),
	WhatToExpect NVARCHAR(4000),
    TimeStamp rowversion,
	PRIMARY KEY (EANHotelID)
)
GO


-- Multiple rooms per each hotel - so a compound primary key
-- use dbo.sysobjects for SQL 2000
if exists (select * from sys.objects where name = 'roomtypelist' and type = 'u')
    drop table roomtypelist
GO
CREATE TABLE roomtypelist
(
	EANHotelID INT NOT NULL,
	RoomTypeID INT NOT NULL,
	LanguageCode NVARCHAR(5),
	RoomTypeImage NVARCHAR(256),
	RoomTypeName NVARCHAR(200),
	RoomTypeDescription NVARCHAR(4000),
    TimeStamp rowversion,
	PRIMARY KEY (EANHotelID, RoomTypeID)
)
GO


-- use dbo.sysobjects for SQL 2000
if exists (select * from sys.objects where name = 'attributelist' and type = 'u')
    drop table attributelist
GO
CREATE TABLE attributelist
(
	AttributeID INT NOT NULL,
	LanguageCode NVARCHAR(5),
	AttributeDesc NVARCHAR(255),
	Type NVARCHAR(15),
	SubType NVARCHAR(15),
    TimeStamp rowversion,
	PRIMARY KEY (AttributeID)
)
GO


-- use dbo.sysobjects for SQL 2000
if exists (select * from sys.objects where name = 'propertyattributelink' and type = 'u')
    drop table propertyattributelink
GO
CREATE TABLE propertyattributelink
(
	EANHotelID INT NOT NULL,
	AttributeID INT NOT NULL,
	LanguageCode NVARCHAR(5),
	AppendTxt NVARCHAR(191),
    TimeStamp rowversion,
-- table so far do not present the same problem as GDSpropertyattributelink
	PRIMARY KEY (EANHotelID, AttributeID)
)
GO



-- use dbo.sysobjects for SQL 2000
if exists (select * from sys.objects where name = 'gdsattributelist' and type = 'u')
    drop table gdsattributelist
GO
CREATE TABLE gdsattributelist
(
	AttributeID INT NOT NULL,
	LanguageCode NVARCHAR(5),
	AttributeDesc NVARCHAR(255),
	Type NVARCHAR(15),
	SubType NVARCHAR(15),
    TimeStamp rowversion,
	PRIMARY KEY (AttributeID)
)
GO

-- use dbo.sysobjects for SQL 2000
if exists (select * from sys.objects where name = 'gdspropertyattributelink' and type = 'u')
    drop table gdspropertyattributelink
GO
CREATE TABLE gdspropertyattributelink
(
	EANHotelID INT NOT NULL,
	AttributeID INT NOT NULL,
	LanguageCode NVARCHAR(5),
	AppendTxt NVARCHAR(191),
    TimeStamp rowversion,
-- need all those fields to make a uniquekey
	PRIMARY KEY (EANHotelID, AttributeID, AppendTxt)
)
GO


/*
************** Image Data *****************
*/
-- there are multiple images for an hotel 
-- even with the same caption
-- to make a unique index we need to use
-- the URL instead

-- use dbo.sysobjects for SQL 2000
if exists (select * from sys.objects where name = 'hotelimagelist' and type = 'u')
    drop table hotelimagelist
GO
CREATE TABLE hotelimagelist
(
	EANHotelID INT NOT NULL,
	Caption NVARCHAR(70),
-- URLs are now max 80 NCHARs
	URL NVARCHAR(150) NOT NULL,
	Width INT,
	Height INT,
	ByteSize INT,
	ThumbnailURL NVARCHAR(300),
	DefaultImage bit,
    TimeStamp rowversion,
	PRIMARY KEY (URL)
)
GO
CREATE INDEX idx_hotelimagelist_eanhotelid ON hotelimagelist(EANHotelID);
GO


/*
****************** Geography Data ****************
*/
-- use dbo.sysobjects for SQL 2000
if exists (select * from sys.objects where name = 'citycoordinateslist' and type = 'u')
    drop table citycoordinateslist
GO
CREATE TABLE citycoordinateslist
(
	RegionID INT NOT NULL,
	RegionName NVARCHAR(255),
	Coordinates NVARCHAR(4000),
    TimeStamp rowversion,
	PRIMARY KEY (RegionID)
)
GO

-- table to correct search term for a region
-- notice there are NO spaces between words
-- use dbo.sysobjects for SQL 2000
if exists (select * from sys.objects where name = 'aliasregionlist' and type = 'u')
    drop table aliasregionlist
GO
CREATE TABLE aliasregionlist
(
	RegionID INT NOT NULL,
	LanguageCode NVARCHAR(5),
	AliasString NVARCHAR(255),
    TimeStamp rowversion
-- no primary key for this table, need to investigate
--	PRIMARY KEY (RegionID, AliasString)
)
GO
CREATE INDEX idx_aliasregionid_regionid ON aliasregionlist(RegionID);
GO

-- use dbo.sysobjects for SQL 2000
if exists (select * from sys.objects where name = 'parentregionlist' and type = 'u')
    drop table parentregionlist
GO
CREATE TABLE parentregionlist
(
	RegionID INT NOT NULL,
	RegionType NVARCHAR(50),
	RelativeSignificance NVARCHAR(3),
	SubClass NVARCHAR(50),
	RegionName NVARCHAR(255),
	RegionNameLong NVARCHAR(510),
	ParentRegionID INT,
	ParentRegionType NVARCHAR(50),
	ParentRegionName NVARCHAR(255),
	ParentRegionNameLong NVARCHAR(510),
    TimeStamp rowversion,
	PRIMARY KEY (RegionID)
)
GO


-- use dbo.sysobjects for SQL 2000
if exists (select * from sys.objects where name = 'neighborhoodcoordinateslist' and type = 'u')
    drop table neighborhoodcoordinateslist
GO
CREATE TABLE neighborhoodcoordinateslist
(
	RegionID INT NOT NULL,
	RegionName NVARCHAR(255),
	Coordinates NVARCHAR(4000),
    TimeStamp rowversion,
	PRIMARY KEY (RegionID)
)
GO

-- use dbo.sysobjects for SQL 2000
if exists (select * from sys.objects where name = 'regioncentercoordinateslist' and type = 'u')
    drop table regioncentercoordinateslist
GO
CREATE TABLE regioncentercoordinateslist
(
	RegionID INT NOT NULL,
	RegionName NVARCHAR(255),
	CenterLatitude numeric(9,6),
	CenterLongitude numeric(9,6),
    TimeStamp rowversion,
	PRIMARY KEY (RegionID)
)
GO

-- use dbo.sysobjects for SQL 2000
if exists (select * from sys.objects where name = 'regioneanhotelidmapping' and type = 'u')
    drop table regioneanhotelidmapping
GO
CREATE TABLE regioneanhotelidmapping
(
	RegionID INT NOT NULL,
	EANHotelID INT NOT NULL,
    TimeStamp rowversion,
	PRIMARY KEY (RegionID, EANHotelID)
)
GO

/*
********************************************************
** TABLES ADDED FROM MINORREV=25                      **
**                                                    **
********************************************************
*/
-- use dbo.sysobjects for SQL 2000
if exists (select * from sys.objects where name = 'propertylocationlist' and type = 'u')
    drop table propertylocationlist
GO
CREATE TABLE propertylocationlist
(
	EANHotelID INT NOT NULL,
	LanguageCode NVARCHAR(5),
	PropertyLocationDescription NVARCHAR(4000),
    TimeStamp rowversion,
	PRIMARY KEY (EANHotelID)
)
GO
-- use dbo.sysobjects for SQL 2000
if exists (select * from sys.objects where name = 'propertyamenitieslist' and type = 'u')
    drop table propertyamenitieslist
GO
CREATE TABLE propertyamenitieslist
(
	EANHotelID INT NOT NULL,
	LanguageCode NVARCHAR(5),
	PropertyAmenitiesDescription NVARCHAR(4000),
    TimeStamp rowversion,
	PRIMARY KEY (EANHotelID)
)
GO
-- use dbo.sysobjects for SQL 2000
if exists (select * from sys.objects where name = 'propertyroomslist' and type = 'u')
    drop table propertyroomslist
GO
CREATE TABLE propertyroomslist
(
	EANHotelID INT NOT NULL,
	LanguageCode NVARCHAR(5),
	PropertyRoomsDescription NVARCHAR(4000),
    TimeStamp rowversion,
	PRIMARY KEY (EANHotelID)
)
GO
-- use dbo.sysobjects for SQL 2000
if exists (select * from sys.objects where name = 'propertybusinessamenitieslist' and type = 'u')
    drop table propertybusinessamenitieslist
GO
CREATE TABLE propertybusinessamenitieslist
(
	EANHotelID INT NOT NULL,
	LanguageCode NVARCHAR(5),
	PropertyBusinessAmenitiesDescription NVARCHAR(4000),
    TimeStamp rowversion,
	PRIMARY KEY (EANHotelID)
)
GO
-- use dbo.sysobjects for SQL 2000
if exists (select * from sys.objects where name = 'propertynationalratingslist' and type = 'u')
    drop table propertynationalratingslist
GO
CREATE TABLE propertynationalratingslist
(
	EANHotelID INT NOT NULL,
	LanguageCode NVARCHAR(5),
	PropertyNationalRatingsDescription NVARCHAR(4000),
    TimeStamp rowversion,
	PRIMARY KEY (EANHotelID)
)
GO
-- use dbo.sysobjects for SQL 2000
if exists (select * from sys.objects where name = 'propertyfeeslist' and type = 'u')
    drop table propertyfeeslist
GO
CREATE TABLE propertyfeeslist
(
	EANHotelID INT NOT NULL,
	LanguageCode NVARCHAR(5),
	PropertyFeesDescription NVARCHAR(4000),
    TimeStamp rowversion,
	PRIMARY KEY (EANHotelID)
)
GO
-- use dbo.sysobjects for SQL 2000
if exists (select * from sys.objects where name = 'propertymandatoryfeeslist' and type = 'u')
    drop table propertymandatoryfeeslist
GO
CREATE TABLE propertymandatoryfeeslist
(
	EANHotelID INT NOT NULL,
	LanguageCode NVARCHAR(5),
	PropertyMandatoryFeesDescription NVARCHAR(4000),
    TimeStamp rowversion,
	PRIMARY KEY (EANHotelID)
)
GO
-- use dbo.sysobjects for SQL 2000
if exists (select * from sys.objects where name = 'propertyrenovationslist' and type = 'u')
    drop table propertyrenovationslist
GO
CREATE TABLE propertyrenovationslist
(
	EANHotelID INT NOT NULL,
	LanguageCode NVARCHAR(5),
	PropertyRenovationsDescription NVARCHAR(4000),
    TimeStamp rowversion,
	PRIMARY KEY (EANHotelID)
)
GO