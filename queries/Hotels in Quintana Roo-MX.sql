## this query will show the hotel RegionName and ParentRegionName 
## so you could solve the stateProvince
SELECT activepropertylist.EANHotelID,Name,StateProvince,City,Country,
parentregionlist.RegionNameLong,parentregionlist.ParentRegionNameLong,
citycoordinateslist.RegionName 
FROM activepropertylist,regioneanhotelidmapping,parentregionlist,citycoordinateslist 
WHERE activepropertylist.EANHotelID = regioneanhotelidmapping.EANHotelID 
and regioneanhotelidmapping.RegionID = parentregionlist.RegionID
and parentregionlist.RegionID = citycoordinateslist.RegionID 
and citycoordinateslist.RegionName LIKE "%Quintana Roo, Mexico"
ORDER BY activepropertylist.City;