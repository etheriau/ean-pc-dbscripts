# Query to list all Cities, RegionID and its GPS Coordinates
use eanprod;
SELECT parentregionlist.RegionNameLong AS 'English',parentregionlist.RegionID as 'EANRegionID',
regioncentercoordinateslist.CenterLatitude as 'Latitude',regioncentercoordinateslist.CenterLongitude as 'Longitude'
FROM eanprod.parentregionlist
# get the coordinates
JOIN regioncentercoordinateslist
ON parentregionlist.RegionID = regioncentercoordinateslist.RegionID
WHERE parentregionlist.RegionType='City' AND parentregionlist.SubClass='';