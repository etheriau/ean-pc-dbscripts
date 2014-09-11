#query to get Regions of Type=City
USE eanprod;
SELECT RegionID,RegionNameLong,RegionType,SubClass FROM parentregionlist
WHERE parentregionlist.RegionType='City' AND SubClass='';

