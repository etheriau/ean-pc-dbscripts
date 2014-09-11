#query to get Regions of Type=Multi-City (Vicinity)
use eanprod;
SELECT RegionID,RegionNameLong,RegionType,SubClass from parentregionlist
WHERE RegionType IN ('Multi-City (Vicinity)')  AND SubClass='';

