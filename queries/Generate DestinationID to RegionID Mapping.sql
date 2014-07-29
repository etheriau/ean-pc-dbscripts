## Generate Master Multi-language Destination and RegionID
## 
## DataType=P-Point of Interest, A-Airport, C-City
## SearchType=GPS, DestinationString, DestinationID, File}
## SearchValue={number|string|geopoint|file-name}

use eanextras;
SELECT parentregionlist.RegionID as 'RegionID',regioncentercoordinateslist.CenterLatitude as 'Latitude',
regioncentercoordinateslist.CenterLongitude as 'Longitude',parentregionlist.RegionNameLong AS 'English', 
regionlist_es_es.RegionNameLong as 'Spanish',regionlist_pt_br.RegionNameLong as 'Portuguese','C' AS 'DataType',
regionidtodestinationid.DestinationID as 'DestinationID'
FROM eanprod.parentregionlist
# get the DestinationID
JOIN eanextras.regionidtodestinationid
ON parentregionlist.RegionID = regionidtodestinationid.RegionID
# get the coordinates
JOIN eanprod.regioncentercoordinateslist
ON parentregionlist.RegionID = regioncentercoordinateslist.RegionID
# get the Spanish Name
JOIN eanprod.regionlist_es_es
ON parentregionlist.RegionID = regionlist_es_es.RegionID
# get the Portuguese Name
JOIN eanprod.regionlist_pt_br
ON parentregionlist.RegionID = regionlist_pt_br.RegionID
# eliminate all those ending with "(type #)" as they are duplicated
WHERE parentregionlist.RegionType='City' AND parentregionlist.SubClass=''
##
UNION ALL
##
## Airport data based in MainCity Region of the Airport
SELECT  airportcoordinateslist.MainCityID as 'RegionID',airportcoordinateslist.Latitude as 'Latitude',
airportcoordinateslist.Longitude as 'Longitude',airportcoordinateslist.AirportName AS 'English', 
regionlist_es_es.RegionNameLong as 'Spanish',regionlist_pt_br.RegionNameLong as 'Portuguese','A' AS 'DataType',
regionidtodestinationid.DestinationID as 'DestinationID'
FROM eanprod.airportcoordinateslist
# get the DestinationID
JOIN eanextras.regionidtodestinationid
ON airportcoordinateslist.MainCityID = regionidtodestinationid.RegionID
# get the Spanish Name
JOIN eanprod.regionlist_es_es
ON airportcoordinateslist.AirportID = regionlist_es_es.RegionID
# get the Portuguese Name
JOIN eanprod.regionlist_pt_br
ON airportcoordinateslist.AirportID = regionlist_pt_br.RegionID
##
UNION ALL
##
## POI data based in GPS
SELECT pointsofinterestcoordinateslist.RegionID as 'RegionID',pointsofinterestcoordinateslist.Latitude as 'Latitude',
pointsofinterestcoordinateslist.Longitude as 'Longitude',pointsofinterestcoordinateslist.RegionNameLong AS 'English', 
regionlist_es_es.RegionNameLong as 'Spanish',regionlist_pt_br.RegionNameLong as 'Portuguese','P' AS 'DataType',
regionidtodestinationid.DestinationID as 'DestinationID' 
FROM eanprod.pointsofinterestcoordinateslist
# get the DestinationID
JOIN eanextras.regionidtodestinationid
ON pointsofinterestcoordinateslist.RegionID = regionidtodestinationid.RegionID
# get the Spanish Name
JOIN eanprod.regionlist_es_es
ON pointsofinterestcoordinateslist.RegionID = regionlist_es_es.RegionID
# get the Portuguese Name
JOIN eanprod.regionlist_pt_br
ON pointsofinterestcoordinateslist.RegionID = regionlist_pt_br.RegionID
;
