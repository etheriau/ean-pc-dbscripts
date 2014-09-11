#query to get Regions of Type=Multi-City (Vicinity)
# CLEAN RegionNameLong version
use eanprod;
SELECT RegionID,REGION_NAME_CLEAN(RegionNameLong),RegionType,SubClass from parentregionlist
WHERE RegionType='Multi-City (Vicinity)' AND SubClass='';

