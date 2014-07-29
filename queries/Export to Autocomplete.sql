## Generate Master Multi-language Target Files
## 
## DataType=L-Landmark, A-Airport, C-City
## SearchType=GPS, DestinationString, DestinationID, File}
## SearchValue={number|string|geopoint|file-name}
## SortFactor={0…100}
#FROM parentregionlist
#WHERE RegionType='City' AND SubClass=''

SELECT SHA(parentregionlist.RegionNameLong) as 'TargetID',regioncentercoordinateslist.CenterLatitude as 'Latitude',
regioncentercoordinateslist.CenterLongitude as 'Longitude',parentregionlist.RegionNameLong AS 'English', 
regionlist_es_es.RegionNameLong as 'Spanish',regionlist_pt_br.RegionNameLong as 'Portuguese','C' AS 'DataType',
'DestinationString' as 'SearchType',parentregionlist.RegionNameLong as 'SearchValue',0 as 'SortFactor' 
FROM eanprod.parentregionlist
# get the coordinates
JOIN regioncentercoordinateslist
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
## Airport data based in GPS
SELECT SHA(airportcoordinateslist.AirportName) as 'TargetID',airportcoordinateslist.Latitude as 'Latitude',
airportcoordinateslist.Longitude as 'Longitude',airportcoordinateslist.AirportName AS 'English', 
regionlist_es_es.RegionNameLong as 'Spanish',regionlist_pt_br.RegionNameLong as 'Portuguese','A' AS 'DataType',
'GPS' as 'SearchType',CONCAT(airportcoordinateslist.Latitude,',',airportcoordinateslist.Longitude) as 'SearchValue',0 as 'SortFactor' 
FROM eanprod.airportcoordinateslist
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
SELECT SHA(pointsofinterestcoordinateslist.RegionNameLong) as 'TargetID',pointsofinterestcoordinateslist.Latitude as 'Latitude',
pointsofinterestcoordinateslist.Longitude as 'Longitude',pointsofinterestcoordinateslist.RegionNameLong AS 'English', 
regionlist_es_es.RegionNameLong as 'Spanish',regionlist_pt_br.RegionNameLong as 'Portuguese','P' AS 'DataType',
'GPS' as 'SearchType',CONCAT(pointsofinterestcoordinateslist.Latitude,',',pointsofinterestcoordinateslist.Longitude) as 'SearchValue',0 as 'SortFactor' 
FROM eanprod.pointsofinterestcoordinateslist
# get the Spanish Name
JOIN eanprod.regionlist_es_es
ON pointsofinterestcoordinateslist.RegionID = regionlist_es_es.RegionID
# get the Portuguese Name
JOIN eanprod.regionlist_pt_br
ON pointsofinterestcoordinateslist.RegionID = regionlist_pt_br.RegionID
;
