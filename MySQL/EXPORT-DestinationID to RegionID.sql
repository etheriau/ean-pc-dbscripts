# Generate the DestinationID to RegionID file with the current mappings of EANRegionIDs
# including current inventory
use eanextras;
select regionidtodestinationid.DestinationID as 'EANDestinationID',regionidtodestinationid.Destination,DestinationType,IFNULL(IF(AirportID=NULL,RegionID,IF(MainCityID=0,RegionID,MainCityID)),RegionID) AS 'EANRegionID',
Latitude AS 'Latitude',Longitude AS 'Longitude',
RegionName,RegionType,eanprod.HOTELS_IN_REGION_COUNT(IFNULL(IF(AirportID=NULL,RegionID,IF(MainCityID=0,RegionID,MainCityID)),RegionID)) AS 'AmtOfHotels',
eanprod.HOTELS_IN_REGION(IFNULL(IF(AirportID=NULL,RegionID,IF(MainCityID=0,RegionID,MainCityID)),RegionID)) AS 'HotelIDList'
FROM regionidtodestinationid
# Airports - try to map to the MainCityID if exist
LEFT JOIN eanprod.airportcoordinateslist 
ON regionidtodestinationid.RegionID = airportcoordinateslist.AirportID
WHERE RegionType LIKE '%Airport Shadow%'

UNION ALL

# Citites, Multi-regions and Niegborhoods
SELECT regionidtodestinationid.DestinationID as 'EANDestinationID',regionidtodestinationid.Destination,DestinationType,RegionID AS 'EANRegionID',
CenterLatitude AS 'Latitude',CenterLongitude AS 'Longitude',
RegionName,RegionType,eanprod.HOTELS_IN_REGION_COUNT(RegionID) AS 'AmtOfHotels',
eanprod.HOTELS_IN_REGION(RegionID) AS 'HotelIDList'
FROM regionidtodestinationid
# DestinationIDs - give the Latitude and Longitude
LEFT JOIN eanextras.destinationids
ON regionidtodestinationid.DestinationID=destinationids.DestinationID
LEFT JOIN eanextras.destinationids
ON regionidtodestinationid.DestinationID=destinationids.DestinationID
WHERE RegionType LIKE '%Multi-City (Vicinity)%' OR RegionType LIKE '%City%' OR RegionType LIKE '%Neighborhood%' OR RegionType LIKE '%Multi-Region (within a country)%' OR RegionType LIKE '%Country%'
OR RegionType LIKE '%Custom - Small%'

UNION ALL

# Point of Interest
SELECT regionidtodestinationid.DestinationID as 'EANDestinationID',regionidtodestinationid.Destination,DestinationType,RegionID AS 'EANRegionID',
CenterLatitude AS 'Latitude',CenterLongitude AS 'Longitude',
RegionName,RegionType,eanprod.HOTELS_IN_REGION_COUNT(RegionID) AS 'AmtOfHotels',
eanprod.HOTELS_IN_REGION(RegionID) AS 'HotelIDList'
FROM regionidtodestinationid
# DestinationIDs - give the Latitude and Longitude
# Landmarks (take of the { } from the DestinationIDs
LEFT JOIN eanextras.landmark
ON regionidtodestinationid.DestinationID=SUBSTRING(landmark.DestinationID,2,LENGTH(landmark.DestinationID)-2)
WHERE RegionType LIKE '%Metro Station Shadow%' OR RegionType LIKE '%Point of Interest Shadow%' OR RegionType LIKE '%Train Station Shadow%'