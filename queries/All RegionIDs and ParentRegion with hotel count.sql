#Query to get Amount of Hotels in ALL Regions whth its Parent also
USE eanprod;
SELECT RegionID,RegionType AS 'Type',SubClass AS 'SubType',RegionNameLong,HOTELS_IN_REGION_COUNT(RegionID) AS 'AmtHotels',
ParentRegionID,ParentRegionType,ParentRegionNameLong, HOTELS_IN_REGION_COUNT(ParentRegionID) AS 'ParentAmtHotels' 
from parentregionlist 
#WHERE RegionNameLong LIKE "%Lihue%" 
#AND RegionType NOT LIKE "%Point of Interest%"
ORDER BY RegionID


#UPDATE my_table SET my_column='new value' WHERE something='some value'; 


