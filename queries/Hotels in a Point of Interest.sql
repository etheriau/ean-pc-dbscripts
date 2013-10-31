## retrieve all hotels in a point of interest
SELECT 
pointsofinterestcoordinateslist.RegionName,
pointsofinterestcoordinateslist.RegionNameLong,
pointsofinterestcoordinateslist.RegionID,
parentregionlist.ParentRegionID,
regioneanhotelidmapping.EANHotelID,
activepropertylist.Name, activepropertylist.Address1, activepropertylist.Address2,
activepropertylist.City, activepropertylist.StateProvince, activepropertylist.PostalCode,
activepropertylist.Country
FROM pointsofinterestcoordinateslist
JOIN parentregionlist
ON pointsofinterestcoordinateslist.RegionID = parentregionlist.RegionID
JOIN regioneanhotelidmapping
ON parentregionlist.RegionID = regioneanhotelidmapping.RegionID
JOIN activepropertylist
ON regioneanhotelidmapping.EANHotelID = activepropertylist.EANHotelID

WHERE pointsofinterestcoordinateslist.RegionNameLong LIKE "Tamarindo Beach, Tamarindo, Costa Rica";