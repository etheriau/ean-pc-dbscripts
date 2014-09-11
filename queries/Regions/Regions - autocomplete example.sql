#query to create the autocomplete example
#close simulation of Travelnow
use eanextras;
DROP TABLE IF EXISTS autocomplete;
CREATE TABLE autocomplete
(
	English VARCHAR(510),
	EANRegionID INT,
	Latitude numeric(9,6),
	Longitude numeric(9,6),
	EANHotelCount INT,
	EANHotelIDList TEXT,
	DisplayType VARCHAR(20),
  TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = MYISAM CHARACTER SET utf8 COLLATE utf8_unicode_ci;
CREATE FULLTEXT INDEX ft_en    ON autocomplete(English);

## insert the data of the massive UNION ALL of all selected groups of data
INSERT INTO eanextras.autocomplete (English,EANRegionID,Latitude,Longitude,EANHotelCount,EANHotelIDList,DisplayType) 
SELECT * FROM (
## the Multi-City (Vicinity) records
SELECT eanprod.REGION_NAME_CLEAN(RegionNameLong) AS 'English',parentregionlist.RegionID AS 'EANRegionID',
       CenterLatitude AS 'Latitude',CenterLongitude AS 'Longitude',
	   eanprod.HOTELS_IN_REGION_COUNT(parentregionlist.RegionID) AS 'EANHotelIDCount',
	   eanprod.HOTELS_IN_REGION(parentregionlist.RegionID) AS 'EANHotelIDList',
	   'Cities/Area' AS 'DisplayType'
FROM eanprod.parentregionlist
LEFT JOIN eanprod.regioncentercoordinateslist
ON parentregionlist.RegionID = regioncentercoordinateslist.RegionID
WHERE RegionType='Multi-City (Vicinity)' AND SubClass=''

UNION ALL
## the City records
SELECT eanprod.REGION_NAME_CLEAN(RegionNameLong) AS 'English',parentregionlist.RegionID AS 'EANRegionID',
       CenterLatitude AS 'Latitude',CenterLongitude AS 'Longitude',
	   eanprod.HOTELS_IN_REGION_COUNT(parentregionlist.RegionID) AS 'EANHotelIDCount',
	   eanprod.HOTELS_IN_REGION(parentregionlist.RegionID) AS 'EANHotelIDList',
	   'Cities/Areas' AS 'DisplayType'
FROM eanprod.parentregionlist
LEFT JOIN eanprod.regioncentercoordinateslist
ON parentregionlist.RegionID = regioncentercoordinateslist.RegionID
WHERE parentregionlist.RegionType='City' AND SubClass=''

UNION ALL
## the Airports records
SELECT AirportName AS 'English',MainCityID AS 'EANRegionID',Latitude,Longitude,
	   eanprod.HOTELS_IN_REGION_COUNT(parentregionlist.RegionID) AS 'EANHotelIDCount',
	   eanprod.HOTELS_IN_REGION(parentregionlist.RegionID) AS 'EANHotelIDList',
	   'Airports' AS 'DisplayType' 
FROM eanprod.airportcoordinateslist
JOIN eanprod.parentregionlist
ON airportcoordinateslist.MainCityID = parentregionlist.RegionID

UNION ALL
## the Point Of Interest Records
SELECT RegionNameLong AS 'English',RegionID,Latitude,Longitude,
	   eanprod.HOTELS_IN_REGION_COUNT(pointsofinterestcoordinateslist.RegionID) AS 'EANHotelIDCount',
	   eanprod.HOTELS_IN_REGION(pointsofinterestcoordinateslist.RegionID) AS 'EANHotelIDList',
	   'Landmark' AS 'DisplayType'  
FROM eanprod.pointsofinterestcoordinateslist

UNION ALL
## the Hotels Records
SELECT  Name AS 'English',NULL AS 'EANREgionID',Latitude,Longitude,
	   1 AS 'EANHotelIDCount',EANHotelID AS 'EANHotelIDList','Hotels' AS 'DisplayType' 
FROM eanprod.activepropertylist
) AS T
# just add the ones we can actually have hotels to sell
WHERE EANHotelIDList > 0;
