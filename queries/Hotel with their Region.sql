## this query will show The Hotel REgion and Parent Region
# 236239 - Quality Inn El Tuque, Ponce PR
# 105350 - The Westin Galleria Dallas, Dallas, TX, US

SELECT activepropertylist.EANHotelID,Name,City,StateProvince,PostalCode,Country,
parentregionlist.RegionType, RelativeSignificance, SubClass, RegionName,
RegionNameLong, ParentRegionID, ParentRegionType, ParentRegionName,
ParentRegionNameLong,AliasString
FROM activepropertylist,regioneanhotelidmapping,parentregionlist,aliasregionlist 
WHERE regioneanhotelidmapping.EANHotelID = 105350 
and regioneanhotelidmapping.RegionID = parentregionlist.RegionID 
and regioneanhotelidmapping.RegionID = aliasregionlist.RegionID 
#and Country="US" and City="Dallas"
;