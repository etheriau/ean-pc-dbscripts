#query to get Regions of Type=Neighborhood
# CLEAN RegionNameLong version
use eanprod;
SELECT RegionID,RegionNameLong,RegionType,SubClass from parentregionlist
WHERE RegionType='Neighborhood' AND SubClass IN ('downtown','neighbor','regional');


