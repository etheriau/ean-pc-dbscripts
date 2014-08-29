# show all hotels in a given RegionID
# 6148556 - Champs-Elysees, Paris, France
select parentregionlist.RegionID,parentregionlist.RegionNameLong,
activepropertylist.EANHotelID,activepropertylist.Name,Address1,Address2,City,StateProvince,PostalCode 
FROM parentregionlist
JOIN regioneanhotelidmapping
ON parentregionlist.RegionID = regioneanhotelidmapping.RegionID
JOIN activepropertylist 
ON activepropertylist.EANHotelID=regioneanhotelidmapping.EANHotelID 
WHERE parentregionlist.RegionID = 6148556
ORDER BY activepropertylist.EANHotelID;
