## this query will show The Hotel REgion and Parent Region
# 236239 - Quality Inn El Tuque, Ponce PR
# 105350 - The Westin Galleria Dallas, Dallas, TX, US
SELECT activepropertylist.EANHotelID,ParentRegionNameLong, RegionNameLong
FROM activepropertylist,regioneanhotelidmapping,parentregionlist 
WHERE activepropertylist.EANHotelID=236239
AND activepropertylist.EANHotelID = regioneanhotelidmapping.EANHotelID 
and regioneanhotelidmapping.RegionID = parentregionlist.RegionID 
;