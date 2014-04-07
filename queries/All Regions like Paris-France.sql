# All Regions of Paris, France
select * from parentregionlist 
WHERE RegionNameLong LIKE '%Paris, France%' and RegionType <> 'Point of Interest Shadow';
;